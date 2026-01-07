// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'filter_preset.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$FilterPresetImpl _$$FilterPresetImplFromJson(Map<String, dynamic> json) =>
    _$FilterPresetImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      thumbnailPath: json['thumbnailPath'] as String?,
      parameters: (json['parameters'] as Map<String, dynamic>).map(
        (k, e) => MapEntry(k, (e as num).toDouble()),
      ),
      createdAt: DateTime.parse(json['createdAt'] as String),
      category: json['category'] as String?,
      isFavorite: json['isFavorite'] as bool? ?? false,
      lutPath: json['lutPath'] as String?,
    );

Map<String, dynamic> _$$FilterPresetImplToJson(_$FilterPresetImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'thumbnailPath': instance.thumbnailPath,
      'parameters': instance.parameters,
      'createdAt': instance.createdAt.toIso8601String(),
      'category': instance.category,
      'isFavorite': instance.isFavorite,
      'lutPath': instance.lutPath,
    };
