import 'package:freezed_annotation/freezed_annotation.dart';

part 'reward.freezed.dart';
part 'reward.g.dart';

/// Respuesta de GET /rewards y GET /rewards/{id}
///
/// imageUrl es nullable: el backend puede devolver null si la recompensa
/// no tiene imagen cargada. La UI debe mostrar un placeholder en ese caso.
@freezed
class Reward with _$Reward {
  const factory Reward({
    required int id,
    required String name,
    required String description,
    required int pointsCost,
    required int stock,
    required bool active,
    String? imageUrl,
  }) = _Reward;

  factory Reward.fromJson(Map<String, dynamic> json) => _$RewardFromJson(json);
}
