// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'recycling_session.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

RecyclingSession _$RecyclingSessionFromJson(Map<String, dynamic> json) {
  return _RecyclingSession.fromJson(json);
}

/// @nodoc
mixin _$RecyclingSession {
  int get id => throw _privateConstructorUsedError;
  int get smartBinId => throw _privateConstructorUsedError;
  int? get userId => throw _privateConstructorUsedError;
  int get capCount => throw _privateConstructorUsedError;
  double get weightGrams => throw _privateConstructorUsedError;
  int get pointsEarned => throw _privateConstructorUsedError;
  String get qrToken => throw _privateConstructorUsedError;
  RecyclingSessionStatus get status => throw _privateConstructorUsedError;
  DateTime? get expiresAt => throw _privateConstructorUsedError;
  DateTime? get confirmedAt => throw _privateConstructorUsedError;
  String? get blockchainTxHash => throw _privateConstructorUsedError;

  /// Serializes this RecyclingSession to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of RecyclingSession
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $RecyclingSessionCopyWith<RecyclingSession> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $RecyclingSessionCopyWith<$Res> {
  factory $RecyclingSessionCopyWith(
    RecyclingSession value,
    $Res Function(RecyclingSession) then,
  ) = _$RecyclingSessionCopyWithImpl<$Res, RecyclingSession>;
  @useResult
  $Res call({
    int id,
    int smartBinId,
    int? userId,
    int capCount,
    double weightGrams,
    int pointsEarned,
    String qrToken,
    RecyclingSessionStatus status,
    DateTime? expiresAt,
    DateTime? confirmedAt,
    String? blockchainTxHash,
  });
}

/// @nodoc
class _$RecyclingSessionCopyWithImpl<$Res, $Val extends RecyclingSession>
    implements $RecyclingSessionCopyWith<$Res> {
  _$RecyclingSessionCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of RecyclingSession
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? smartBinId = null,
    Object? userId = freezed,
    Object? capCount = null,
    Object? weightGrams = null,
    Object? pointsEarned = null,
    Object? qrToken = null,
    Object? status = null,
    Object? expiresAt = freezed,
    Object? confirmedAt = freezed,
    Object? blockchainTxHash = freezed,
  }) {
    return _then(
      _value.copyWith(
            id:
                null == id
                    ? _value.id
                    : id // ignore: cast_nullable_to_non_nullable
                        as int,
            smartBinId:
                null == smartBinId
                    ? _value.smartBinId
                    : smartBinId // ignore: cast_nullable_to_non_nullable
                        as int,
            userId:
                freezed == userId
                    ? _value.userId
                    : userId // ignore: cast_nullable_to_non_nullable
                        as int?,
            capCount:
                null == capCount
                    ? _value.capCount
                    : capCount // ignore: cast_nullable_to_non_nullable
                        as int,
            weightGrams:
                null == weightGrams
                    ? _value.weightGrams
                    : weightGrams // ignore: cast_nullable_to_non_nullable
                        as double,
            pointsEarned:
                null == pointsEarned
                    ? _value.pointsEarned
                    : pointsEarned // ignore: cast_nullable_to_non_nullable
                        as int,
            qrToken:
                null == qrToken
                    ? _value.qrToken
                    : qrToken // ignore: cast_nullable_to_non_nullable
                        as String,
            status:
                null == status
                    ? _value.status
                    : status // ignore: cast_nullable_to_non_nullable
                        as RecyclingSessionStatus,
            expiresAt:
                freezed == expiresAt
                    ? _value.expiresAt
                    : expiresAt // ignore: cast_nullable_to_non_nullable
                        as DateTime?,
            confirmedAt:
                freezed == confirmedAt
                    ? _value.confirmedAt
                    : confirmedAt // ignore: cast_nullable_to_non_nullable
                        as DateTime?,
            blockchainTxHash:
                freezed == blockchainTxHash
                    ? _value.blockchainTxHash
                    : blockchainTxHash // ignore: cast_nullable_to_non_nullable
                        as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$RecyclingSessionImplCopyWith<$Res>
    implements $RecyclingSessionCopyWith<$Res> {
  factory _$$RecyclingSessionImplCopyWith(
    _$RecyclingSessionImpl value,
    $Res Function(_$RecyclingSessionImpl) then,
  ) = __$$RecyclingSessionImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    int id,
    int smartBinId,
    int? userId,
    int capCount,
    double weightGrams,
    int pointsEarned,
    String qrToken,
    RecyclingSessionStatus status,
    DateTime? expiresAt,
    DateTime? confirmedAt,
    String? blockchainTxHash,
  });
}

/// @nodoc
class __$$RecyclingSessionImplCopyWithImpl<$Res>
    extends _$RecyclingSessionCopyWithImpl<$Res, _$RecyclingSessionImpl>
    implements _$$RecyclingSessionImplCopyWith<$Res> {
  __$$RecyclingSessionImplCopyWithImpl(
    _$RecyclingSessionImpl _value,
    $Res Function(_$RecyclingSessionImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of RecyclingSession
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? smartBinId = null,
    Object? userId = freezed,
    Object? capCount = null,
    Object? weightGrams = null,
    Object? pointsEarned = null,
    Object? qrToken = null,
    Object? status = null,
    Object? expiresAt = freezed,
    Object? confirmedAt = freezed,
    Object? blockchainTxHash = freezed,
  }) {
    return _then(
      _$RecyclingSessionImpl(
        id:
            null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                    as int,
        smartBinId:
            null == smartBinId
                ? _value.smartBinId
                : smartBinId // ignore: cast_nullable_to_non_nullable
                    as int,
        userId:
            freezed == userId
                ? _value.userId
                : userId // ignore: cast_nullable_to_non_nullable
                    as int?,
        capCount:
            null == capCount
                ? _value.capCount
                : capCount // ignore: cast_nullable_to_non_nullable
                    as int,
        weightGrams:
            null == weightGrams
                ? _value.weightGrams
                : weightGrams // ignore: cast_nullable_to_non_nullable
                    as double,
        pointsEarned:
            null == pointsEarned
                ? _value.pointsEarned
                : pointsEarned // ignore: cast_nullable_to_non_nullable
                    as int,
        qrToken:
            null == qrToken
                ? _value.qrToken
                : qrToken // ignore: cast_nullable_to_non_nullable
                    as String,
        status:
            null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                    as RecyclingSessionStatus,
        expiresAt:
            freezed == expiresAt
                ? _value.expiresAt
                : expiresAt // ignore: cast_nullable_to_non_nullable
                    as DateTime?,
        confirmedAt:
            freezed == confirmedAt
                ? _value.confirmedAt
                : confirmedAt // ignore: cast_nullable_to_non_nullable
                    as DateTime?,
        blockchainTxHash:
            freezed == blockchainTxHash
                ? _value.blockchainTxHash
                : blockchainTxHash // ignore: cast_nullable_to_non_nullable
                    as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$RecyclingSessionImpl implements _RecyclingSession {
  const _$RecyclingSessionImpl({
    required this.id,
    required this.smartBinId,
    this.userId,
    required this.capCount,
    required this.weightGrams,
    required this.pointsEarned,
    required this.qrToken,
    required this.status,
    this.expiresAt,
    this.confirmedAt,
    this.blockchainTxHash,
  });

  factory _$RecyclingSessionImpl.fromJson(Map<String, dynamic> json) =>
      _$$RecyclingSessionImplFromJson(json);

  @override
  final int id;
  @override
  final int smartBinId;
  @override
  final int? userId;
  @override
  final int capCount;
  @override
  final double weightGrams;
  @override
  final int pointsEarned;
  @override
  final String qrToken;
  @override
  final RecyclingSessionStatus status;
  @override
  final DateTime? expiresAt;
  @override
  final DateTime? confirmedAt;
  @override
  final String? blockchainTxHash;

  @override
  String toString() {
    return 'RecyclingSession(id: $id, smartBinId: $smartBinId, userId: $userId, capCount: $capCount, weightGrams: $weightGrams, pointsEarned: $pointsEarned, qrToken: $qrToken, status: $status, expiresAt: $expiresAt, confirmedAt: $confirmedAt, blockchainTxHash: $blockchainTxHash)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RecyclingSessionImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.smartBinId, smartBinId) ||
                other.smartBinId == smartBinId) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.capCount, capCount) ||
                other.capCount == capCount) &&
            (identical(other.weightGrams, weightGrams) ||
                other.weightGrams == weightGrams) &&
            (identical(other.pointsEarned, pointsEarned) ||
                other.pointsEarned == pointsEarned) &&
            (identical(other.qrToken, qrToken) || other.qrToken == qrToken) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.expiresAt, expiresAt) ||
                other.expiresAt == expiresAt) &&
            (identical(other.confirmedAt, confirmedAt) ||
                other.confirmedAt == confirmedAt) &&
            (identical(other.blockchainTxHash, blockchainTxHash) ||
                other.blockchainTxHash == blockchainTxHash));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    smartBinId,
    userId,
    capCount,
    weightGrams,
    pointsEarned,
    qrToken,
    status,
    expiresAt,
    confirmedAt,
    blockchainTxHash,
  );

  /// Create a copy of RecyclingSession
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$RecyclingSessionImplCopyWith<_$RecyclingSessionImpl> get copyWith =>
      __$$RecyclingSessionImplCopyWithImpl<_$RecyclingSessionImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$RecyclingSessionImplToJson(this);
  }
}

abstract class _RecyclingSession implements RecyclingSession {
  const factory _RecyclingSession({
    required final int id,
    required final int smartBinId,
    final int? userId,
    required final int capCount,
    required final double weightGrams,
    required final int pointsEarned,
    required final String qrToken,
    required final RecyclingSessionStatus status,
    final DateTime? expiresAt,
    final DateTime? confirmedAt,
    final String? blockchainTxHash,
  }) = _$RecyclingSessionImpl;

  factory _RecyclingSession.fromJson(Map<String, dynamic> json) =
      _$RecyclingSessionImpl.fromJson;

  @override
  int get id;
  @override
  int get smartBinId;
  @override
  int? get userId;
  @override
  int get capCount;
  @override
  double get weightGrams;
  @override
  int get pointsEarned;
  @override
  String get qrToken;
  @override
  RecyclingSessionStatus get status;
  @override
  DateTime? get expiresAt;
  @override
  DateTime? get confirmedAt;
  @override
  String? get blockchainTxHash;

  /// Create a copy of RecyclingSession
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$RecyclingSessionImplCopyWith<_$RecyclingSessionImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
