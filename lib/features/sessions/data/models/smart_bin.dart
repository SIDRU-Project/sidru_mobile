import 'package:freezed_annotation/freezed_annotation.dart';

part 'smart_bin.freezed.dart';
part 'smart_bin.g.dart';

/// Respuesta de GET /smart-bins/{id}
/// Se usa opcionalmente en SessionDetailScreen para mostrar la ubicación.
@freezed
class SmartBin with _$SmartBin {
  const factory SmartBin({
    required int id,
    required String deviceCode,
    required String location,
    required String district,
    required String status,
    required int totalCapsCollected,
  }) = _SmartBin;

  factory SmartBin.fromJson(Map<String, dynamic> json) =>
      _$SmartBinFromJson(json);
}
