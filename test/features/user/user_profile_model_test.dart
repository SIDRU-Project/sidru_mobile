import 'package:flutter_test/flutter_test.dart';
import 'package:sidru_mobile/features/user/data/models/user_profile.dart';

/// GET /profiles/me puede devolver `phone`/`district` en null: el backend
/// (`SignUpResource`) solo los valida con `@Size`, no son obligatorios.
void main() {
  group('UserProfile - fromJson con phone/district nulos', () {
    test('parsea sin lanzar y deja ambos campos en null', () {
      final json = {
        'id': 6,
        'userId': 6,
        'fullName': 'Piloto SIDRU',
        'phone': null,
        'district': null,
        'totalPoints': 500,
        'totalCaps': 50,
        'totalSessions': 1,
      };

      final profile = UserProfile.fromJson(json);

      expect(profile.phone, isNull);
      expect(profile.district, isNull);
      expect(profile.fullName, 'Piloto SIDRU');
      expect(profile.totalPoints, 500);
    });

    test('un JSON completo conserva los valores de phone y district', () {
      final json = {
        'id': 6,
        'userId': 6,
        'fullName': 'Piloto SIDRU',
        'phone': '987654321',
        'district': 'San Miguel',
        'totalPoints': 500,
        'totalCaps': 50,
        'totalSessions': 1,
      };

      final profile = UserProfile.fromJson(json);

      expect(profile.phone, '987654321');
      expect(profile.district, 'San Miguel');
    });

    test('toJson de un perfil con nulos vuelve a poner null (round-trip)', () {
      const profile = UserProfile(
        id: 6,
        userId: 6,
        fullName: 'Piloto SIDRU',
        phone: null,
        district: null,
        totalPoints: 500,
        totalCaps: 50,
        totalSessions: 1,
      );

      final json = profile.toJson();

      expect(json['phone'], isNull);
      expect(json['district'], isNull);
    });
  });
}
