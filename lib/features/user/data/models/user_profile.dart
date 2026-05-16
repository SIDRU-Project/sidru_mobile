import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_profile.freezed.dart';
part 'user_profile.g.dart';

/// Respuesta de GET /profiles/me y PUT /profiles/me
/// {
///   "id": 1, "userId": 1, "fullName": "...", "phone": "...",
///   "district": "...", "totalPoints": 850, "totalCaps": 85, "totalSessions": 4
/// }
@freezed
class UserProfile with _$UserProfile {
  const factory UserProfile({
    required int id,
    required int userId,
    required String fullName,
    required String phone,
    required String district,
    required int totalPoints,
    required int totalCaps,
    required int totalSessions,
  }) = _UserProfile;

  factory UserProfile.fromJson(Map<String, dynamic> json) =>
      _$UserProfileFromJson(json);
}
