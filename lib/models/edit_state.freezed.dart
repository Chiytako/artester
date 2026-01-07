// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'edit_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

EditState _$EditStateFromJson(Map<String, dynamic> json) {
  return _EditState.fromJson(json);
}

/// @nodoc
mixin _$EditState {
  /// 編集対象の画像（メモリ上）
  @JsonKey(includeFromJson: false, includeToJson: false)
  ui.Image? get image => throw _privateConstructorUsedError;

  /// LUT画像（メモリ上）
  @JsonKey(includeFromJson: false, includeToJson: false)
  ui.Image? get lutImage => throw _privateConstructorUsedError;

  /// 編集パラメータ（キー: パラメータ名、値: 調整値）
  /// 例: {'brightness': 0.0, 'contrast': 0.0, 'saturation': 0.0}
  Map<String, double> get parameters => throw _privateConstructorUsedError;

  /// 現在適用中のプリセットID（null = プリセット未使用）
  String? get currentPresetId => throw _privateConstructorUsedError;

  /// 画像パス（null = 画像未選択）
  String? get imagePath => throw _privateConstructorUsedError;

  /// LUT画像パス（null = LUT未適用、'generated' = 生成済みLUT使用）
  String? get activeLutPath => throw _privateConstructorUsedError;

  /// LUT適用強度（0.0〜1.0）
  double get lutIntensity => throw _privateConstructorUsedError;

  /// フィルター適用強度（0.0〜1.0）
  double get filterStrength => throw _privateConstructorUsedError;

  /// 回転状態 (0=0°, 1=90°, 2=180°, 3=270°)
  int get rotation => throw _privateConstructorUsedError;

  /// 水平反転
  bool get flipX => throw _privateConstructorUsedError;

  /// 垂直反転
  bool get flipY => throw _privateConstructorUsedError;

  /// ローディング状態
  bool get isLoading => throw _privateConstructorUsedError;

  /// Serializes this EditState to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of EditState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $EditStateCopyWith<EditState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $EditStateCopyWith<$Res> {
  factory $EditStateCopyWith(EditState value, $Res Function(EditState) then) =
      _$EditStateCopyWithImpl<$Res, EditState>;
  @useResult
  $Res call({
    @JsonKey(includeFromJson: false, includeToJson: false) ui.Image? image,
    @JsonKey(includeFromJson: false, includeToJson: false) ui.Image? lutImage,
    Map<String, double> parameters,
    String? currentPresetId,
    String? imagePath,
    String? activeLutPath,
    double lutIntensity,
    double filterStrength,
    int rotation,
    bool flipX,
    bool flipY,
    bool isLoading,
  });
}

/// @nodoc
class _$EditStateCopyWithImpl<$Res, $Val extends EditState>
    implements $EditStateCopyWith<$Res> {
  _$EditStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of EditState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? image = freezed,
    Object? lutImage = freezed,
    Object? parameters = null,
    Object? currentPresetId = freezed,
    Object? imagePath = freezed,
    Object? activeLutPath = freezed,
    Object? lutIntensity = null,
    Object? filterStrength = null,
    Object? rotation = null,
    Object? flipX = null,
    Object? flipY = null,
    Object? isLoading = null,
  }) {
    return _then(
      _value.copyWith(
            image: freezed == image
                ? _value.image
                : image // ignore: cast_nullable_to_non_nullable
                      as ui.Image?,
            lutImage: freezed == lutImage
                ? _value.lutImage
                : lutImage // ignore: cast_nullable_to_non_nullable
                      as ui.Image?,
            parameters: null == parameters
                ? _value.parameters
                : parameters // ignore: cast_nullable_to_non_nullable
                      as Map<String, double>,
            currentPresetId: freezed == currentPresetId
                ? _value.currentPresetId
                : currentPresetId // ignore: cast_nullable_to_non_nullable
                      as String?,
            imagePath: freezed == imagePath
                ? _value.imagePath
                : imagePath // ignore: cast_nullable_to_non_nullable
                      as String?,
            activeLutPath: freezed == activeLutPath
                ? _value.activeLutPath
                : activeLutPath // ignore: cast_nullable_to_non_nullable
                      as String?,
            lutIntensity: null == lutIntensity
                ? _value.lutIntensity
                : lutIntensity // ignore: cast_nullable_to_non_nullable
                      as double,
            filterStrength: null == filterStrength
                ? _value.filterStrength
                : filterStrength // ignore: cast_nullable_to_non_nullable
                      as double,
            rotation: null == rotation
                ? _value.rotation
                : rotation // ignore: cast_nullable_to_non_nullable
                      as int,
            flipX: null == flipX
                ? _value.flipX
                : flipX // ignore: cast_nullable_to_non_nullable
                      as bool,
            flipY: null == flipY
                ? _value.flipY
                : flipY // ignore: cast_nullable_to_non_nullable
                      as bool,
            isLoading: null == isLoading
                ? _value.isLoading
                : isLoading // ignore: cast_nullable_to_non_nullable
                      as bool,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$EditStateImplCopyWith<$Res>
    implements $EditStateCopyWith<$Res> {
  factory _$$EditStateImplCopyWith(
    _$EditStateImpl value,
    $Res Function(_$EditStateImpl) then,
  ) = __$$EditStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @JsonKey(includeFromJson: false, includeToJson: false) ui.Image? image,
    @JsonKey(includeFromJson: false, includeToJson: false) ui.Image? lutImage,
    Map<String, double> parameters,
    String? currentPresetId,
    String? imagePath,
    String? activeLutPath,
    double lutIntensity,
    double filterStrength,
    int rotation,
    bool flipX,
    bool flipY,
    bool isLoading,
  });
}

/// @nodoc
class __$$EditStateImplCopyWithImpl<$Res>
    extends _$EditStateCopyWithImpl<$Res, _$EditStateImpl>
    implements _$$EditStateImplCopyWith<$Res> {
  __$$EditStateImplCopyWithImpl(
    _$EditStateImpl _value,
    $Res Function(_$EditStateImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of EditState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? image = freezed,
    Object? lutImage = freezed,
    Object? parameters = null,
    Object? currentPresetId = freezed,
    Object? imagePath = freezed,
    Object? activeLutPath = freezed,
    Object? lutIntensity = null,
    Object? filterStrength = null,
    Object? rotation = null,
    Object? flipX = null,
    Object? flipY = null,
    Object? isLoading = null,
  }) {
    return _then(
      _$EditStateImpl(
        image: freezed == image
            ? _value.image
            : image // ignore: cast_nullable_to_non_nullable
                  as ui.Image?,
        lutImage: freezed == lutImage
            ? _value.lutImage
            : lutImage // ignore: cast_nullable_to_non_nullable
                  as ui.Image?,
        parameters: null == parameters
            ? _value._parameters
            : parameters // ignore: cast_nullable_to_non_nullable
                  as Map<String, double>,
        currentPresetId: freezed == currentPresetId
            ? _value.currentPresetId
            : currentPresetId // ignore: cast_nullable_to_non_nullable
                  as String?,
        imagePath: freezed == imagePath
            ? _value.imagePath
            : imagePath // ignore: cast_nullable_to_non_nullable
                  as String?,
        activeLutPath: freezed == activeLutPath
            ? _value.activeLutPath
            : activeLutPath // ignore: cast_nullable_to_non_nullable
                  as String?,
        lutIntensity: null == lutIntensity
            ? _value.lutIntensity
            : lutIntensity // ignore: cast_nullable_to_non_nullable
                  as double,
        filterStrength: null == filterStrength
            ? _value.filterStrength
            : filterStrength // ignore: cast_nullable_to_non_nullable
                  as double,
        rotation: null == rotation
            ? _value.rotation
            : rotation // ignore: cast_nullable_to_non_nullable
                  as int,
        flipX: null == flipX
            ? _value.flipX
            : flipX // ignore: cast_nullable_to_non_nullable
                  as bool,
        flipY: null == flipY
            ? _value.flipY
            : flipY // ignore: cast_nullable_to_non_nullable
                  as bool,
        isLoading: null == isLoading
            ? _value.isLoading
            : isLoading // ignore: cast_nullable_to_non_nullable
                  as bool,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$EditStateImpl extends _EditState {
  const _$EditStateImpl({
    @JsonKey(includeFromJson: false, includeToJson: false) this.image,
    @JsonKey(includeFromJson: false, includeToJson: false) this.lutImage,
    final Map<String, double> parameters = const {},
    this.currentPresetId,
    this.imagePath,
    this.activeLutPath,
    this.lutIntensity = 1.0,
    this.filterStrength = 1.0,
    this.rotation = 0,
    this.flipX = false,
    this.flipY = false,
    this.isLoading = false,
  }) : _parameters = parameters,
       super._();

  factory _$EditStateImpl.fromJson(Map<String, dynamic> json) =>
      _$$EditStateImplFromJson(json);

  /// 編集対象の画像（メモリ上）
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  final ui.Image? image;

  /// LUT画像（メモリ上）
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  final ui.Image? lutImage;

  /// 編集パラメータ（キー: パラメータ名、値: 調整値）
  /// 例: {'brightness': 0.0, 'contrast': 0.0, 'saturation': 0.0}
  final Map<String, double> _parameters;

  /// 編集パラメータ（キー: パラメータ名、値: 調整値）
  /// 例: {'brightness': 0.0, 'contrast': 0.0, 'saturation': 0.0}
  @override
  @JsonKey()
  Map<String, double> get parameters {
    if (_parameters is EqualUnmodifiableMapView) return _parameters;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_parameters);
  }

  /// 現在適用中のプリセットID（null = プリセット未使用）
  @override
  final String? currentPresetId;

  /// 画像パス（null = 画像未選択）
  @override
  final String? imagePath;

  /// LUT画像パス（null = LUT未適用、'generated' = 生成済みLUT使用）
  @override
  final String? activeLutPath;

  /// LUT適用強度（0.0〜1.0）
  @override
  @JsonKey()
  final double lutIntensity;

  /// フィルター適用強度（0.0〜1.0）
  @override
  @JsonKey()
  final double filterStrength;

  /// 回転状態 (0=0°, 1=90°, 2=180°, 3=270°)
  @override
  @JsonKey()
  final int rotation;

  /// 水平反転
  @override
  @JsonKey()
  final bool flipX;

  /// 垂直反転
  @override
  @JsonKey()
  final bool flipY;

  /// ローディング状態
  @override
  @JsonKey()
  final bool isLoading;

  @override
  String toString() {
    return 'EditState(image: $image, lutImage: $lutImage, parameters: $parameters, currentPresetId: $currentPresetId, imagePath: $imagePath, activeLutPath: $activeLutPath, lutIntensity: $lutIntensity, filterStrength: $filterStrength, rotation: $rotation, flipX: $flipX, flipY: $flipY, isLoading: $isLoading)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$EditStateImpl &&
            (identical(other.image, image) || other.image == image) &&
            (identical(other.lutImage, lutImage) ||
                other.lutImage == lutImage) &&
            const DeepCollectionEquality().equals(
              other._parameters,
              _parameters,
            ) &&
            (identical(other.currentPresetId, currentPresetId) ||
                other.currentPresetId == currentPresetId) &&
            (identical(other.imagePath, imagePath) ||
                other.imagePath == imagePath) &&
            (identical(other.activeLutPath, activeLutPath) ||
                other.activeLutPath == activeLutPath) &&
            (identical(other.lutIntensity, lutIntensity) ||
                other.lutIntensity == lutIntensity) &&
            (identical(other.filterStrength, filterStrength) ||
                other.filterStrength == filterStrength) &&
            (identical(other.rotation, rotation) ||
                other.rotation == rotation) &&
            (identical(other.flipX, flipX) || other.flipX == flipX) &&
            (identical(other.flipY, flipY) || other.flipY == flipY) &&
            (identical(other.isLoading, isLoading) ||
                other.isLoading == isLoading));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    image,
    lutImage,
    const DeepCollectionEquality().hash(_parameters),
    currentPresetId,
    imagePath,
    activeLutPath,
    lutIntensity,
    filterStrength,
    rotation,
    flipX,
    flipY,
    isLoading,
  );

  /// Create a copy of EditState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$EditStateImplCopyWith<_$EditStateImpl> get copyWith =>
      __$$EditStateImplCopyWithImpl<_$EditStateImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$EditStateImplToJson(this);
  }
}

abstract class _EditState extends EditState {
  const factory _EditState({
    @JsonKey(includeFromJson: false, includeToJson: false)
    final ui.Image? image,
    @JsonKey(includeFromJson: false, includeToJson: false)
    final ui.Image? lutImage,
    final Map<String, double> parameters,
    final String? currentPresetId,
    final String? imagePath,
    final String? activeLutPath,
    final double lutIntensity,
    final double filterStrength,
    final int rotation,
    final bool flipX,
    final bool flipY,
    final bool isLoading,
  }) = _$EditStateImpl;
  const _EditState._() : super._();

  factory _EditState.fromJson(Map<String, dynamic> json) =
      _$EditStateImpl.fromJson;

  /// 編集対象の画像（メモリ上）
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  ui.Image? get image;

  /// LUT画像（メモリ上）
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  ui.Image? get lutImage;

  /// 編集パラメータ（キー: パラメータ名、値: 調整値）
  /// 例: {'brightness': 0.0, 'contrast': 0.0, 'saturation': 0.0}
  @override
  Map<String, double> get parameters;

  /// 現在適用中のプリセットID（null = プリセット未使用）
  @override
  String? get currentPresetId;

  /// 画像パス（null = 画像未選択）
  @override
  String? get imagePath;

  /// LUT画像パス（null = LUT未適用、'generated' = 生成済みLUT使用）
  @override
  String? get activeLutPath;

  /// LUT適用強度（0.0〜1.0）
  @override
  double get lutIntensity;

  /// フィルター適用強度（0.0〜1.0）
  @override
  double get filterStrength;

  /// 回転状態 (0=0°, 1=90°, 2=180°, 3=270°)
  @override
  int get rotation;

  /// 水平反転
  @override
  bool get flipX;

  /// 垂直反転
  @override
  bool get flipY;

  /// ローディング状態
  @override
  bool get isLoading;

  /// Create a copy of EditState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$EditStateImplCopyWith<_$EditStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
