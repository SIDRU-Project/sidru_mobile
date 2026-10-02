import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:sidru_mobile/core/auth/browser_session.dart';
import 'package:sidru_mobile/core/auth/google_redirect_flow.dart';
import 'package:sidru_mobile/core/notifications/fcm_handler.dart';
import 'package:sidru_mobile/features/auth/data/auth_repository.dart';
import 'package:sidru_mobile/features/auth/data/models/auth_providers.dart';
import 'package:sidru_mobile/features/auth/data/models/sign_in_response.dart';
import 'package:sidru_mobile/features/auth/presentation/auth_provider.dart';
import 'package:sidru_mobile/features/auth/presentation/google_callback_screen.dart';
import 'package:sidru_mobile/features/auth/presentation/google_sign_in_section.dart';

import 'google_login_test.dart' show FakeAuthApi, FakeSocial, FakeStorage;

/// 4c.4 — login con Google por redirección (OIDC id_token): URL, state/nonce y pantalla de callback.

class FakeBrowser implements BrowserSession {
  final Map<String, String> storage = {};
  @override
  String initialFragment;
  @override
  String origin;
  String? navigatedTo;
  int fragmentClears = 0;

  FakeBrowser({
    this.initialFragment = '',
    this.origin = 'http://localhost:5000',
  });

  @override
  String? getItem(String key) => storage[key];
  @override
  void setItem(String key, String value) => storage[key] = value;
  @override
  void removeItem(String key) => storage.remove(key);
  @override
  void clearUrlFragment() => fragmentClears++;
  @override
  void navigate(String url) => navigatedTo = url;
}

void main() {
  group('GoogleRedirectFlow', () {
    test(
      'start guarda state y nonce y navega a Google con todos los parámetros',
      () {
        final browser = FakeBrowser();
        GoogleRedirectFlow(browser).start('abc.apps.googleusercontent.com');

        final uri = Uri.parse(browser.navigatedTo!);
        expect(uri.host, 'accounts.google.com');
        expect(uri.path, '/o/oauth2/v2/auth');
        expect(
          uri.queryParameters['client_id'],
          'abc.apps.googleusercontent.com',
        );
        expect(
          uri.queryParameters['redirect_uri'],
          'http://localhost:5000/auth/google/callback',
        );
        expect(uri.queryParameters['response_type'], 'id_token');
        expect(uri.queryParameters['scope'], 'openid email profile');
        expect(uri.queryParameters['prompt'], 'select_account');
        expect(
          uri.queryParameters['state'],
          browser.storage[GoogleRedirectFlow.stateKey],
        );
        expect(
          uri.queryParameters['nonce'],
          browser.storage[GoogleRedirectFlow.nonceKey],
        );
        expect(
          uri.queryParameters['state'],
          isNot(uri.queryParameters['nonce']),
        );
        expect(uri.queryParameters['state']!.length, greaterThanOrEqualTo(43));
        expect(browser.navigatedTo, contains('scope=openid%20email%20profile'));
      },
    );

    test('state y nonce cambian en cada intento', () {
      final browser = FakeBrowser();
      final flow = GoogleRedirectFlow(browser);
      flow.start('c');
      final first = browser.storage[GoogleRedirectFlow.stateKey];
      flow.start('c');
      expect(browser.storage[GoogleRedirectFlow.stateKey], isNot(first));
    });

    GoogleRedirectFlow flowReturning(
      FakeBrowser b,
      String fragment, {
      String state = 'S',
      String? nonce = 'N',
    }) {
      if (state.isNotEmpty) b.storage[GoogleRedirectFlow.stateKey] = state;
      if (nonce != null) b.storage[GoogleRedirectFlow.nonceKey] = nonce;
      b.initialFragment = fragment;
      return GoogleRedirectFlow(b);
    }

    test(
      'state válido con id_token: éxito con el nonce guardado, y se consume todo',
      () {
        final b = FakeBrowser();
        final flow = flowReturning(b, 'id_token=tok.en.x&state=S&authuser=0');
        final r = flow.consumeCallback();

        expect(r, isA<GoogleCallbackSuccess>());
        expect((r as GoogleCallbackSuccess).idToken, 'tok.en.x');
        expect(r.nonce, 'N');
        expect(b.storage, isEmpty);
        expect(b.fragmentClears, 1);
        // Una segunda lectura (recarga) no puede reutilizar nada.
        expect(flow.consumeCallback(), isA<GoogleCallbackInvalid>());
      },
    );

    test('state distinto: inválido, y state/nonce se consumen igual', () {
      final b = FakeBrowser();
      final r = flowReturning(b, 'id_token=t&state=OTRO').consumeCallback();
      expect(r, isA<GoogleCallbackInvalid>());
      expect(b.storage, isEmpty);
    });

    test('sin state en la URL o sin state guardado: inválido', () {
      expect(
        flowReturning(FakeBrowser(), 'id_token=t').consumeCallback(),
        isA<GoogleCallbackInvalid>(),
      );
      expect(
        flowReturning(
          FakeBrowser(),
          'id_token=t&state=S',
          state: '',
        ).consumeCallback(),
        isA<GoogleCallbackInvalid>(),
      );
    });

    test('sin fragmento (recarga del callback): inválido', () {
      expect(
        flowReturning(FakeBrowser(), '').consumeCallback(),
        isA<GoogleCallbackInvalid>(),
      );
    });

    test('error=access_denied con state válido: cancelado', () {
      final b = FakeBrowser();
      final r =
          flowReturning(b, 'error=access_denied&state=S').consumeCallback();
      expect(r, isA<GoogleCallbackCancelled>());
      expect(b.storage, isEmpty);
    });

    test('otro error o state ajeno con error: inválido', () {
      expect(
        flowReturning(
          FakeBrowser(),
          'error=server_error&state=S',
        ).consumeCallback(),
        isA<GoogleCallbackInvalid>(),
      );
      expect(
        flowReturning(
          FakeBrowser(),
          'error=access_denied&state=X',
        ).consumeCallback(),
        isA<GoogleCallbackInvalid>(),
      );
    });

    test('id_token sin nonce guardado: inválido', () {
      expect(
        flowReturning(
          FakeBrowser(),
          'id_token=t&state=S',
          nonce: null,
        ).consumeCallback(),
        isA<GoogleCallbackInvalid>(),
      );
    });
  });

  group('Botón "Continuar con Google" (redirección)', () {
    Future<FakeBrowser> pump(
      WidgetTester tester,
      AuthProviders providers, {
      bool isWeb = true,
    }) async {
      final browser = FakeBrowser();
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authProvidersProvider.overrideWith((ref) async => providers),
            authRepositoryProvider.overrideWithValue(
              AuthRepository(FakeAuthApi(), FakeStorage()),
            ),
            fcmHandlerProvider.overrideWithValue(FcmHandler()),
            socialAuthServiceProvider.overrideWithValue(FakeSocial()),
            browserSessionProvider.overrideWithValue(browser),
          ],
          child: MaterialApp(
            home: Scaffold(body: GoogleSignInSection(isWeb: isWeb)),
          ),
        ),
      );
      await tester.pumpAndSettle();
      return browser;
    }

    testWidgets('el tap sale a Google con el client ID de /providers', (
      tester,
    ) async {
      final browser = await pump(
        tester,
        const AuthProviders(googleClientId: 'abc.apps.googleusercontent.com'),
      );
      await tester.tap(find.text('Continuar con Google'));
      await tester.pump();

      expect(browser.navigatedTo, startsWith('https://accounts.google.com/'));
      expect(
        browser.navigatedTo,
        contains('client_id=abc.apps.googleusercontent.com'),
      );
    });

    testWidgets('no aparece en nativo ni sin google en /providers', (
      tester,
    ) async {
      await pump(
        tester,
        const AuthProviders(googleClientId: 'x'),
        isWeb: false,
      );
      expect(find.text('Continuar con Google'), findsNothing);
    });

    testWidgets('sin google en /providers no hay botón', (tester) async {
      await pump(tester, AuthProviders.passwordOnly);
      expect(find.text('Continuar con Google'), findsNothing);
    });
  });

  group('GoogleCallbackScreen', () {
    late FakeAuthApi api;
    late FakeBrowser browser;
    late ProviderContainer container;
    late GoRouter router;

    Future<void> pump(
      WidgetTester tester,
      String fragment, {
      String state = 'S',
    }) async {
      api = FakeAuthApi();
      browser = FakeBrowser(initialFragment: fragment);
      browser.storage[GoogleRedirectFlow.stateKey] = state;
      browser.storage[GoogleRedirectFlow.nonceKey] = 'N';
      api.googleResponse = const SignInResponse(
        id: 1,
        email: 'ana@gmail.com',
        token: 'jwt',
        newUser: true,
      );
      container = ProviderContainer(
        overrides: [
          authRepositoryProvider.overrideWithValue(
            AuthRepository(api, FakeStorage()),
          ),
          fcmHandlerProvider.overrideWithValue(FcmHandler()),
          socialAuthServiceProvider.overrideWithValue(FakeSocial()),
          browserSessionProvider.overrideWithValue(browser),
        ],
      );
      addTearDown(container.dispose);
      router = GoRouter(
        initialLocation: '/auth/google/callback',
        routes: [
          GoRoute(
            path: '/auth/google/callback',
            builder: (_, __) => const GoogleCallbackScreen(),
          ),
          GoRoute(
            path: '/onboarding',
            builder: (_, __) => const Scaffold(body: Text('ONBOARDING')),
          ),
          GoRoute(
            path: '/login',
            builder: (_, __) => const Scaffold(body: Text('LOGIN')),
          ),
        ],
      );
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp.router(routerConfig: router),
        ),
      );
      // El spinner del callback no se asienta si no hay redirect: pasos de tiempo en vez de pumpAndSettle.
      for (var i = 0; i < 6; i++) {
        await tester.pump(const Duration(milliseconds: 200));
      }
    }

    testWidgets(
      'state válido: llama a la API con id_token y nonce y autentica',
      (tester) async {
        await pump(tester, 'id_token=tok&state=S');

        expect(api.lastIdToken, 'tok');
        expect(api.lastNonce, 'N');
        expect(
          container.read(authNotifierProvider).state.isAuthenticated,
          isTrue,
        );
        expect(
          container.read(authNotifierProvider).pendingProfileCompletion,
          isTrue,
        );
        expect(browser.storage, isEmpty);
      },
    );

    testWidgets(
      'state inválido: no llama a la API y vuelve al onboarding con aviso',
      (tester) async {
        await pump(tester, 'id_token=tok&state=MALO');

        expect(api.lastIdToken, isNull);
        expect(find.text('ONBOARDING'), findsOneWidget);
        expect(
          find.text(
            'No se pudo verificar el inicio de sesión. Inténtalo de nuevo.',
          ),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'access_denied: vuelve al onboarding sin llamar a la API ni avisar',
      (tester) async {
        await pump(tester, 'error=access_denied&state=S');

        expect(api.lastIdToken, isNull);
        expect(find.text('ONBOARDING'), findsOneWidget);
        expect(find.textContaining('No se pudo verificar'), findsNothing);
      },
    );
  });
}
