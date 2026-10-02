import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sidru_mobile/core/auth/social_auth_service.dart';
import 'package:sidru_mobile/core/network/api_exception.dart';
import 'package:sidru_mobile/core/notifications/fcm_handler.dart';
import 'package:sidru_mobile/core/storage/secure_storage.dart';
import 'package:sidru_mobile/features/auth/data/auth_api.dart';
import 'package:sidru_mobile/features/auth/data/auth_repository.dart';
import 'package:sidru_mobile/features/auth/data/models/auth_providers.dart';
import 'package:sidru_mobile/features/auth/data/models/sign_in_response.dart';
import 'package:sidru_mobile/features/auth/presentation/auth_provider.dart';
import 'package:sidru_mobile/features/auth/presentation/google_sign_in_section.dart';

/// 4a.5 — login con Google: repositorio (token + newUser) y botón según /providers.

class FakeAuthApi implements AuthApi {
  SignInResponse? googleResponse;
  Object? googleError;
  AuthProviders? providersResponse;
  Object? providersError;
  String? lastIdToken;

  @override
  Future<SignInResponse> google(String idToken) async {
    lastIdToken = idToken;
    if (googleError != null) throw googleError!;
    return googleResponse!;
  }

  @override
  Future<AuthProviders> providers() async {
    if (providersError != null) throw providersError!;
    return providersResponse!;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

class FakeStorage implements SecureStorage {
  String? token;
  int clears = 0;

  @override
  Future<void> saveToken(String t) async => token = t;

  @override
  Future<void> clearSession() async {
    clears++;
    token = null;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

class FakeSocial extends SocialAuthService {
  String? initializedWith;
  int signOuts = 0;

  @override
  Future<void> init(
    String clientId, {
    required void Function(String idToken) onIdToken,
    required void Function(Object error) onError,
  }) async {
    initializedWith = clientId;
  }

  @override
  Future<void> signOut() async => signOuts++;
}

void main() {
  group('AuthRepository.signInWithGoogle', () {
    late FakeAuthApi api;
    late FakeStorage storage;
    late AuthRepository repo;

    setUp(() {
      api = FakeAuthApi();
      storage = FakeStorage();
      repo = AuthRepository(api, storage);
    });

    test('guarda el JWT de SIDRU y propaga newUser', () async {
      api.googleResponse = const SignInResponse(
        id: 7,
        email: 'ana@gmail.com',
        token: 'sidru-jwt',
        newUser: true,
      );

      final res = await repo.signInWithGoogle('google-id-token');

      expect(api.lastIdToken, 'google-id-token');
      expect(storage.token, 'sidru-jwt');
      expect(res.newUser, isTrue);
    });

    test('un login de cuenta existente trae newUser=false', () async {
      api.googleResponse = const SignInResponse(
        id: 7,
        email: 'ana@gmail.com',
        token: 't',
      );
      expect((await repo.signInWithGoogle('x')).newUser, isFalse);
    });

    test('si el backend rechaza el token no se guarda nada', () async {
      api.googleError = const ApiException(
        type: ApiErrorType.unauthorized,
        message: 'inválido',
      );

      await expectLater(
        repo.signInWithGoogle('malo'),
        throwsA(isA<ApiException>()),
      );
      expect(storage.token, isNull);
    });

    test('SignInResponse sin newUser (login normal) queda en false', () {
      final res = SignInResponse.fromJson({
        'id': 1,
        'email': 'a@b.com',
        'token': 't',
      });
      expect(res.newUser, isFalse);
    });
  });

  group('AuthNotifier con Google', () {
    late FakeAuthApi api;
    late FakeStorage storage;
    late FakeSocial social;
    late ProviderContainer container;

    setUp(() {
      api = FakeAuthApi();
      storage = FakeStorage();
      social = FakeSocial();
      container = ProviderContainer(
        overrides: [
          authRepositoryProvider.overrideWithValue(
            AuthRepository(api, storage),
          ),
          fcmHandlerProvider.overrideWithValue(FcmHandler()),
          socialAuthServiceProvider.overrideWithValue(social),
        ],
      );
    });

    tearDown(() => container.dispose());

    test(
      'cuenta nueva: autentica y marca el paso de completar perfil una vez',
      () async {
        api.googleResponse = const SignInResponse(
          id: 1,
          email: 'nuevo@gmail.com',
          token: 'jwt',
          newUser: true,
        );
        final auth = container.read(authNotifierProvider);
        await Future<void>.delayed(Duration.zero); // _restoreSession sin token

        await auth.signInWithGoogle('tok');

        expect(auth.state.isAuthenticated, isTrue);
        expect(auth.pendingProfileCompletion, isTrue);
        auth.finishProfileCompletion();
        expect(auth.pendingProfileCompletion, isFalse);
      },
    );

    test('cuenta existente: autentica sin pedir completar perfil', () async {
      api.googleResponse = const SignInResponse(
        id: 1,
        email: 'viejo@gmail.com',
        token: 'jwt',
      );
      final auth = container.read(authNotifierProvider);
      await Future<void>.delayed(Duration.zero);

      await auth.signInWithGoogle('tok');

      expect(auth.state.isAuthenticated, isTrue);
      expect(auth.pendingProfileCompletion, isFalse);
    });

    test('409 del backend muestra mensaje y no autentica', () async {
      api.googleError = const ApiException(
        type: ApiErrorType.conflict,
        message: 'conflicto',
      );
      final auth = container.read(authNotifierProvider);
      await Future<void>.delayed(Duration.zero);

      await auth.signInWithGoogle('tok');

      expect(auth.state.isAuthenticated, isFalse);
      expect(auth.state.errorMessage, contains('correo y contraseña'));
    });

    test('logout también cierra la sesión de Google', () async {
      api.googleResponse = const SignInResponse(
        id: 1,
        email: 'a@gmail.com',
        token: 'jwt',
      );
      final auth = container.read(authNotifierProvider);
      await Future<void>.delayed(Duration.zero);
      await auth.signInWithGoogle('tok');

      await auth.logout();

      expect(social.signOuts, 1);
      expect(storage.clears, greaterThanOrEqualTo(1));
    });
  });

  group('GoogleSignInSection', () {
    Future<FakeSocial> pump(
      WidgetTester tester,
      AuthProviders providers, {
      bool isWeb = true,
    }) async {
      final social = FakeSocial();
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authProvidersProvider.overrideWith((ref) async => providers),
            authRepositoryProvider.overrideWithValue(
              AuthRepository(FakeAuthApi(), FakeStorage()),
            ),
            fcmHandlerProvider.overrideWithValue(FcmHandler()),
            socialAuthServiceProvider.overrideWithValue(social),
          ],
          child: MaterialApp(
            home: Scaffold(body: GoogleSignInSection(isWeb: isWeb)),
          ),
        ),
      );
      await tester.pumpAndSettle();
      return social;
    }

    testWidgets('muestra el botón e inicializa con el client ID del backend', (
      tester,
    ) async {
      final social = await pump(
        tester,
        const AuthProviders(googleClientId: 'abc.apps.googleusercontent.com'),
      );

      expect(find.text('Continuar con Google'), findsOneWidget);
      expect(social.initializedWith, 'abc.apps.googleusercontent.com');
    });

    testWidgets(
      'en nativo no hay botón ni se inicializa aunque /providers traiga google',
      (tester) async {
        final social = await pump(
          tester,
          const AuthProviders(googleClientId: 'abc.apps.googleusercontent.com'),
          isWeb: false,
        );

        expect(find.text('Continuar con Google'), findsNothing);
        expect(social.initializedWith, isNull);
      },
    );

    testWidgets('sin google en /providers no hay botón ni se inicializa nada', (
      tester,
    ) async {
      final social = await pump(tester, AuthProviders.passwordOnly);

      expect(find.text('Continuar con Google'), findsNothing);
      expect(social.initializedWith, isNull);
    });

    test(
      'si /providers falla el provider cae a solo correo y contraseña',
      () async {
        final api = FakeAuthApi()..providersError = Exception('sin red');
        final container = ProviderContainer(
          overrides: [
            authRepositoryProvider.overrideWithValue(
              AuthRepository(api, FakeStorage()),
            ),
          ],
        );
        addTearDown(container.dispose);

        final result = await container.read(authProvidersProvider.future);

        expect(result.hasGoogle, isFalse);
        expect(result.password, isTrue);
      },
    );
  });
}
