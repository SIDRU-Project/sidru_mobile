// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'point_transaction.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

PointTransaction _$PointTransactionFromJson(Map<String, dynamic> json) {
  return _PointTransaction.fromJson(json);
}

/// @nodoc
mixin _$PointTransaction {
  int get id => throw _privateConstructorUsedError;
  int get userId => throw _privateConstructorUsedError;
  PointTransactionType get type => throw _privateConstructorUsedError;
  int get points => throw _privateConstructorUsedError;
  String get description => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;

  /// Serializes this PointTransaction to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of PointTransaction
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PointTransactionCopyWith<PointTransaction> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PointTransactionCopyWith<$Res> {
  factory $PointTransactionCopyWith(
    PointTransaction value,
    $Res Function(PointTransaction) then,
  ) = _$PointTransactionCopyWithImpl<$Res, PointTransaction>;
  @useResult
  $Res call({
    int id,
    int userId,
    PointTransactionType type,
    int points,
    String description,
    DateTime createdAt,
  });
}

/// @nodoc
class _$PointTransactionCopyWithImpl<$Res, $Val extends PointTransaction>
    implements $PointTransactionCopyWith<$Res> {
  _$PointTransactionCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PointTransaction
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? type = null,
    Object? points = null,
    Object? description = null,
    Object? createdAt = null,
  }) {
    return _then(
      _value.copyWith(
            id:
                null == id
                    ? _value.id
                    : id // ignore: cast_nullable_to_non_nullable
                        as int,
            userId:
                null == userId
                    ? _value.userId
                    : userId // ignore: cast_nullable_to_non_nullable
                        as int,
            type:
                null == type
                    ? _value.type
                    : type // ignore: cast_nullable_to_non_nullable
                        as PointTransactionType,
            points:
                null == points
                    ? _value.points
                    : points // ignore: cast_nullable_to_non_nullable
                        as int,
            description:
                null == description
                    ? _value.description
                    : description // ignore: cast_nullable_to_non_nullable
                        as String,
            createdAt:
                null == createdAt
                    ? _value.createdAt
                    : createdAt // ignore: cast_nullable_to_non_nullable
                        as DateTime,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$PointTransactionImplCopyWith<$Res>
    implements $PointTransactionCopyWith<$Res> {
  factory _$$PointTransactionImplCopyWith(
    _$PointTransactionImpl value,
    $Res Function(_$PointTransactionImpl) then,
  ) = __$$PointTransactionImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    int id,
    int userId,
    PointTransactionType type,
    int points,
    String description,
    DateTime createdAt,
  });
}

/// @nodoc
class __$$PointTransactionImplCopyWithImpl<$Res>
    extends _$PointTransactionCopyWithImpl<$Res, _$PointTransactionImpl>
    implements _$$PointTransactionImplCopyWith<$Res> {
  __$$PointTransactionImplCopyWithImpl(
    _$PointTransactionImpl _value,
    $Res Function(_$PointTransactionImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of PointTransaction
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? type = null,
    Object? points = null,
    Object? description = null,
    Object? createdAt = null,
  }) {
    return _then(
      _$PointTransactionImpl(
        id:
            null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                    as int,
        userId:
            null == userId
                ? _value.userId
                : userId // ignore: cast_nullable_to_non_nullable
                    as int,
        type:
            null == type
                ? _value.type
                : type // ignore: cast_nullable_to_non_nullable
                    as PointTransactionType,
        points:
            null == points
                ? _value.points
                : points // ignore: cast_nullable_to_non_nullable
                    as int,
        description:
            null == description
                ? _value.description
                : description // ignore: cast_nullable_to_non_nullable
                    as String,
        createdAt:
            null == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                    as DateTime,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$PointTransactionImpl implements _PointTransaction {
  const _$PointTransactionImpl({
    required this.id,
    required this.userId,
    required this.type,
    required this.points,
    required this.description,
    required this.createdAt,
  });

  factory _$PointTransactionImpl.fromJson(Map<String, dynamic> json) =>
      _$$PointTransactionImplFromJson(json);

  @override
  final int id;
  @override
  final int userId;
  @override
  final PointTransactionType type;
  @override
  final int points;
  @override
  final String description;
  @override
  final DateTime createdAt;

  @override
  String toString() {
    return 'PointTransaction(id: $id, userId: $userId, type: $type, points: $points, description: $description, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PointTransactionImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.points, points) || other.points == points) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    userId,
    type,
    points,
    description,
    createdAt,
  );

  /// Create a copy of PointTransaction
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PointTransactionImplCopyWith<_$PointTransactionImpl> get copyWith =>
      __$$PointTransactionImplCopyWithImpl<_$PointTransactionImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$PointTransactionImplToJson(this);
  }
}

abstract class _PointTransaction implements PointTransaction {
  const factory _PointTransaction({
    required final int id,
    required final int userId,
    required final PointTransactionType type,
    required final int points,
    required final String description,
    required final DateTime createdAt,
  }) = _$PointTransactionImpl;

  factory _PointTransaction.fromJson(Map<String, dynamic> json) =
      _$PointTransactionImpl.fromJson;

  @override
  int get id;
  @override
  int get userId;
  @override
  PointTransactionType get type;
  @override
  int get points;
  @override
  String get description;
  @override
  DateTime get createdAt;

  /// Create a copy of PointTransaction
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PointTransactionImplCopyWith<_$PointTransactionImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
