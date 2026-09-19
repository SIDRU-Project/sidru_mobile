import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sidru_mobile/core/notifications/fcm_handler.dart';
import 'package:sidru_mobile/features/auth/data/auth_repository.dart';
import 'package:sidru_mobile/features/auth/data/models/sign_in_response.dart';
import 'package:sidru_mobile/features/auth/data/models/sign_up_response.dart';
import 'package:sidru_mobile/features/auth/presentation/auth_provider.dart';
import 'package:sidru_mobile/features/sessions/data/models/recycling_session.dart';
import 'package:sidru_mobile/features/sessions/data/models/smart_bin.dart';
import 'package:sidru_mobile/features/sessions/data/session_repository.dart';
import 'package:sidru_mobile/features/sessions/presentation/session_provider.dart';
import 'package:sidru_mobile/features/user/data/models/update_profile_request.dart';
import 'package:sidru_mobile/features/user/data/models/user_profile.dart';
import 'package:sidru_mobile/features/user/data/user_repository.dart';
import 'package:sidru_mobile/features/user/presentation/user_provider.dart';

/// Hotfix: al cerrar sesión y entrar con otra cuenta, la app seguía mostrando los datos
/// del usuario anterior (userNotifierProvider/sessionListProvider/etc. son globales, no
/// autoDispose, y conservaban su estado entre sesiones).
///
/// FcmHandler no necesita un doble: sin `initialize()` (nunca se llama aquí), sus métodos
/// ya son no-op porque `_available` empieza en false — se usa la clase real tal cual.
class FakeAuthRepository implements AuthRepository {
  int logoutCalls = 0;

  @override
  Future<SignInResponse> signIn(String email, String password) async {
    return SignInResponse(id: email.hashCode, email: email, token: 'jwt-$email');
  }

  @override
  Future<SignUpResponse> signUp({
    required String fullName,
    required String email,
    required String password,
    required String phone,
    required String district,
  }) => throw UnimplementedError();

  @override
  Future<void> logout() async {
    logoutCalls++;
  }

  @override
  Future<UserProfile?> tryRestoreSession() async => null;
}

/// Perfil del "usuario actual": la prueba lo cambia a mano al alternar de cuenta,
/// simulando que el backend ahora responde con los datos de quien tiene el JWT activo.
class FakeUserRepository implements UserRepository {
  UserProfile? current;
  int getProfileCalls = 0;

  @override
  Future<UserProfile> getProfile() async {
    getProfileCalls++;
    return current!;
  }

  @override
  Future<UserProfile> updateProfile(UpdateProfileRequest request) =>
      throw UnimplementedError();
}

class FakeSessionRepository implements SessionRepository {
  List<RecyclingSession> current = const [];
  int getMySessionsCalls = 0;

  @override
  Future<List<RecyclingSession>> getMySessions() async {
    getMySessionsCalls++;
    return current;
  }

  @override
  Future<RecyclingSession> getSessionById(int id) => throw UnimplementedError();

  @override
  Future<RecyclingSession> getSessionByQr(String qrToken) =>
      throw UnimplementedError();

  @override
  Future<RecyclingSession> confirmSessionByQr(String qrToken) =>
      throw UnimplementedError();

  @override
  Future<SmartBin> getSmartBin(int id) => throw UnimplementedError();
}

UserProfile _profile(int id, String name) => UserProfile(
  id: id,
  userId: id,
  fullName: name,
  phone: null,
  district: null,
  totalPoints: id * 100,
  totalCaps: id * 10,
  totalSessions: id,
);

RecyclingSession _session(int id) => RecyclingSession(
  id: id,
  smartBinId: 1,
  capCount: id,
  weightGrams: id * 50.0,
  pointsEarned: id * 10,
  qrToken: 'token-$id',
  status: RecyclingSessionStatus.confirmed,
);

void main() {
  late FakeAuthRepository fakeAuth;
  late FakeUserRepository fakeUser;
  late FakeSessionRepository fakeSessions;
  late ProviderContainer container;

  setUp(() {
    fakeAuth = FakeAuthRepository();
    fakeUser = FakeUserRepository();
    fakeSessions = FakeSessionRepository();
    container = ProviderContainer(
      overrides: [
        authRepositoryProvider.overrideWithValue(fakeAuth),
        fcmHandlerProvider.overrideWithValue(FcmHandler()),
        userRepositoryProvider.overrideWithValue(fakeUser),
        sessionRepositoryProvider.overrideWithValue(fakeSessions),
      ],
    );
  });

  tearDown(() => container.dispose());

  test(
    'logout limpia el estado por-usuario sin llamar a la API; el siguiente login trae el del nuevo usuario',
    () async {
      final profileA = _profile(1, 'Ciudadano A');
      final sessionsA = [_session(1)];
      final profileB = _profile(2, 'Ciudadano B');
      final sessionsB = [_session(2), _session(3)];

      // --- signIn como A ---
      fakeUser.current = profileA;
      fakeSessions.current = sessionsA;
      await container.read(authNotifierProvider).signIn('a@sidru.pe', 'x');

      expect(await container.read(userNotifierProvider.future), profileA);
      expect(await container.read(sessionListProvider.future), sessionsA);
      expect(fakeUser.getProfileCalls, 1);
      expect(fakeSessions.getMySessionsCalls, 1);

      // --- logout ---
      await container.read(authNotifierProvider).logout();

      expect(await container.read(userNotifierProvider.future), isNull);
      expect(await container.read(sessionListProvider.future), isEmpty);
      expect(fakeUser.getProfileCalls, 1,
          reason: 'tras logout no debe volver a llamarse a la API de perfil');
      expect(fakeSessions.getMySessionsCalls, 1,
          reason: 'tras logout no debe volver a llamarse a la API de sesiones');

      // --- signIn como B: no debe arrastrar nada de A ---
      fakeUser.current = profileB;
      fakeSessions.current = sessionsB;
      await container.read(authNotifierProvider).signIn('b@sidru.pe', 'x');

      expect(await container.read(userNotifierProvider.future), profileB);
      expect(await container.read(sessionListProvider.future), sessionsB);
    },
  );

  test('logout() dos veces seguidas es idempotente: no repite el borrado ni el epoch', () async {
    fakeUser.current = _profile(1, 'Ciudadano A');
    fakeSessions.current = [_session(1)];
    await container.read(authNotifierProvider).signIn('a@sidru.pe', 'x');

    await container.read(authNotifierProvider).logout();
    final logoutCallsTrasElPrimero = fakeAuth.logoutCalls;
    final epochTrasElPrimero = container.read(authNotifierProvider).sessionEpoch;

    await container.read(authNotifierProvider).logout();

    expect(fakeAuth.logoutCalls, logoutCallsTrasElPrimero,
        reason: 'un logout ya cerrado no debe volver a llamar a repository.logout()');
    expect(container.read(authNotifierProvider).sessionEpoch, epochTrasElPrimero,
        reason: 'un logout ya cerrado no debe incrementar sessionEpoch de nuevo');
  });

  test('dos logout() concurrentes solo borran la sesión una vez', () async {
    fakeUser.current = _profile(1, 'Ciudadano A');
    fakeSessions.current = [_session(1)];
    final auth = container.read(authNotifierProvider);
    await auth.signIn('a@sidru.pe', 'x');
    final epochTrasElLogin = auth.sessionEpoch;

    await Future.wait([auth.logout(), auth.logout()]);

    expect(fakeAuth.logoutCalls, 1,
        reason: 'dos logout() concurrentes no deben duplicar el borrado de sesión');
    expect(auth.sessionEpoch, epochTrasElLogin + 1,
        reason: 'dos logout() concurrentes solo deben incrementar el epoch una vez');
  });
}
