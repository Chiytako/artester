// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'filter_preset.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

FilterPreset _$FilterPresetFromJson(Map<String, dynamic> json) {
  return _FilterPreset.fromJson(json);
}

/// @nodoc
mixin _$FilterPreset {
  /// ユニークな識別子
  String get id => throw _privateConstructorUsedError;

  /// プリセット名（ユーザー表示用）
  String get name => throw _privateConstructorUsedError;

  /// サムネイル画像パス（オプション）
  String? get thumbnailPath => throw _privateConstructorUsedError;

  /// 調整パラメータのマップ
  /// 将来的に 'vignette', 'grain', 'split_tone_shadow' などが増えても
  /// このMapに追加するだけで対応可能
  Map<String, double> get parameters => throw _privateConstructorUsedError;

  /// 作成日時
  DateTime get createdAt => throw _privateConstructorUsedError;

  /// カテゴリ（例: 'vintage', 'portrait', 'landscape'）
  String? get category => throw _privateConstructorUsedError;

  /// お気に入りフラグ
  bool get isFavorite => throw _privateConstructorUsedError;

  /// LUTパス（LUT使用時に保存）
  String? get lutPath => throw _privateConstructorUsedError;

  /// Serializes this FilterPreset to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of FilterPreset
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $FilterPresetCopyWith<FilterPreset> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $FilterPresetCopyWith<$Res> {
  factory $FilterPresetCopyWith(
    FilterPreset value,
    $Res Function(FilterPreset) then,
  ) = _$FilterPresetCopyWithImpl<$Res, FilterPreset>;
  @useResult
  $Res call({
    String id,
    String name,
    String? thumbnailPath,
    Map<String, double> parameters,
    DateTime createdAt,
    String? category,
    bool isFavorite,
    String? lutPath,
  });
}

/// @nodoc
class _$FilterPresetCopyWithImpl<$Res, $Val extends FilterPreset>
    implements $FilterPresetCopyWith<$Res> {
  _$FilterPresetCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of FilterPreset
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? thumbnailPath = freezed,
    Object? parameters = null,
    Object? createdAt = null,
    Object? category = freezed,
    Object? isFavorite = null,
    Object? lutPath = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
            thumbnailPath: freezed == thumbnailPath
                ? _value.thumbnailPath
                : thumbnailPath // ignore: cast_nullable_to_non_nullable
                      as String?,
            parameters: null == parameters
                ? _value.parameters
                : parameters // ignore: cast_nullable_to_non_nullable
                      as Map<String, double>,
            createdAt: null == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            category: freezed == category
                ? _value.category
                : category // ignore: cast_nullable_to_non_nullable
                      as String?,
            isFavorite: null == isFavorite
                ? _value.isFavorite
                : isFavorite // ignore: cast_nullable_to_non_nullable
                      as bool,
            lutPath: freezed == lutPath
                ? _value.lutPath
                : lutPath // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$FilterPresetImplCopyWith<$Res>
    implements $FilterPresetCopyWith<$Res> {
  factory _$$FilterPresetImplCopyWith(
    _$FilterPresetImpl value,
    $Res Function(_$FilterPresetImpl) then,
  ) = __$$FilterPresetImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String name,
    String? thumbnailPath,
    Map<String, double> parameters,
    DateTime createdAt,
    String? category,
    bool isFavorite,
    String? lutPath,
  });
}

/// @nodoc
class __$$FilterPresetImplCopyWithImpl<$Res>
    extends _$FilterPresetCopyWithImpl<$Res, _$FilterPresetImpl>
    implements _$$FilterPresetImplCopyWith<$Res> {
  __$$FilterPresetImplCopyWithImpl(
    _$FilterPresetImpl _value,
    $Res Function(_$FilterPresetImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of FilterPreset
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? thumbnailPath = freezed,
    Object? parameters = null,
    Object? createdAt = null,
    Object? category = freezed,
    Object? isFavorite = null,
    Object? lutPath = freezed,
  }) {
    return _then(
      _$FilterPresetImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        thumbnailPath: freezed == thumbnailPath
            ? _value.thumbnailPath
            : thumbnailPath // ignore: cast_nullable_to_non_nullable
                  as String?,
        parameters: null == parameters
            ? _value._parameters
            : parameters // ignore: cast_nullable_to_non_nullable
                  as Map<String, double>,
        createdAt: null == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        category: freezed == category
            ? _value.category
            : category // ignore: cast_nullable_to_non_nullable
                  as String?,
        isFavorite: null == isFavorite
            ? _value.isFavorite
            : isFavorite // ignore: cast_nullable_to_non_nullable
                  as bool,
        lutPath: freezed == lutPath
            ? _value.lutPath
            : lutPath // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$FilterPresetImpl extends _FilterPreset {
  const _$FilterPresetImpl({
    required this.id,
    required this.name,
    this.thumbnailPath,
    required final Map<String, double> parameters,
    required this.createdAt,
    this.category,
    this.isFavorite = false,
    this.lutPath,
  }) : _parameters = parameters,
       super._();

  factory _$FilterPresetImpl.fromJson(Map<String, dynamic> json) =>
      _$$FilterPresetImplFromJson(json);

  /// ユニークな識別子
  @override
  final String id;

  /// プリセット名（ユーザー表示用）
  @override
  final String name;

  /// サムネイル画像パス（オプション）
  @override
  final String? thumbnailPath;

  /// 調整パラメータのマップ
  /// 将来的に 'vignette', 'grain', 'split_tone_shadow' などが増えても
  /// このMapに追加するだけで対応可能
  final Map<String, double> _parameters;

  /// 調整パラメータのマップ
  /// 将来的に 'vignette', 'grain', 'split_tone_shadow' などが増えても
  /// このMapに追加するだけで対応可能
  @override
  Map<String, double> get parameters {
    if (_parameters is EqualUnmodifiableMapView) return _parameters;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_parameters);
  }

  /// 作成日時
  @override
  final DateTime createdAt;

  /// カテゴリ（例: 'vintage', 'portrait', 'landscape'）
  @override
  final String? category;

  /// お気に入りフラグ
  @override
  @JsonKey()
  final bool isFavorite;

  /// LUTパス（LUT使用時に保存）
  @override
  final String? lutPath;

  @override
  String toString() {
    return 'FilterPreset(id: $id, name: $name, thumbnailPath: $thumbnailPath, parameters: $parameters, createdAt: $createdAt, category: $category, isFavorite: $isFavorite, lutPath: $lutPath)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$FilterPresetImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.thumbnailPath, thumbnailPath) ||
                other.thumbnailPath == thumbnailPath) &&
            const DeepCollectionEquality().equals(
              other._parameters,
              _parameters,
            ) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.category, category) ||
                other.category == category) &&
            (identical(other.isFavorite, isFavorite) ||
                other.isFavorite == isFavorite) &&
            (identical(other.lutPath, lutPath) || other.lutPath == lutPath));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    name,
    thumbnailPath,
    const DeepCollectionEquality().hash(_parameters),
    createdAt,
    category,
    isFavorite,
    lutPath,
  );

  /// Create a copy of FilterPreset
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$FilterPresetImplCopyWith<_$FilterPresetImpl> get copyWith =>
      __$$FilterPresetImplCopyWithImpl<_$FilterPresetImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$FilterPresetImplToJson(this);
  }
}

abstract class _FilterPreset extends FilterPreset {
  const factory _FilterPreset({
    required final String id,
    required final String name,
    final String? thumbnailPath,
    required final Map<String, double> parameters,
    required final DateTime createdAt,
    final String? category,
    final bool isFavorite,
    final String? lutPath,
  }) = _$FilterPresetImpl;
  const _FilterPreset._() : super._();

  factory _FilterPreset.fromJson(Map<String, dynamic> json) =
      _$FilterPresetImpl.fromJson;

  /// ユニークな識別子
  @override
  String get id;

  /// プリセット名（ユーザー表示用）
  @override
  String get name;

  /// サムネイル画像パス（オプション）
  @override
  String? get thumbnailPath;

  /// 調整パラメータのマップ
  /// 将来的に 'vignette', 'grain', 'split_tone_shadow' などが増えても
  /// このMapに追加するだけで対応可能
  @override
  Map<String, double> get parameters;

  /// 作成日時
  @override
  DateTime get createdAt;

  /// カテゴリ（例: 'vintage', 'portrait', 'landscape'）
  @override
  String? get category;

  /// お気に入りフラグ
  @override
  bool get isFavorite;

  /// LUTパス（LUT使用時に保存）
  @override
  String? get lutPath;

  /// Create a copy of FilterPreset
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$FilterPresetImplCopyWith<_$FilterPresetImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
