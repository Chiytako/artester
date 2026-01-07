// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'edit_state.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$EditStateImpl _$$EditStateImplFromJson(Map<String, dynamic> json) =>
    _$EditStateImpl(
      parameters:
          (json['parameters'] as Map<String, dynamic>?)?.map(
            (k, e) => MapEntry(k, (e as num).toDouble()),
          ) ??
          const {},
      currentPresetId: json['currentPresetId'] as String?,
      imagePath: json['imagePath'] as String?,
      activeLutPath: json['activeLutPath'] as String?,
      lutIntensity: (json['lutIntensity'] as num?)?.toDouble() ?? 1.0,
      filterStrength: (json['filterStrength'] as num?)?.toDouble() ?? 1.0,
      rotation: (json['rotation'] as num?)?.toInt() ?? 0,
      flipX: json['flipX'] as bool? ?? false,
      flipY: json['flipY'] as bool? ?? false,
      isLoading: json['isLoading'] as bool? ?? false,
    );

Map<String, dynamic> _$$EditStateImplToJson(_$EditStateImpl instance) =>
    <String, dynamic>{
      'parameters': instance.parameters,
      'currentPresetId': instance.currentPresetId,
      'imagePath': instance.imagePath,
      'activeLutPath': instance.activeLutPath,
      'lutIntensity': instance.lutIntensity,
      'filterStrength': instance.filterStrength,
      'rotation': instance.rotation,
      'flipX': instance.flipX,
      'flipY': instance.flipY,
      'isLoading': instance.isLoading,
    };
