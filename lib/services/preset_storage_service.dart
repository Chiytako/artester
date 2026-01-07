import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/filter_preset.dart';

/// ユーザープリセットの永続化サービス
///
/// SharedPreferencesを使用してプリセットをJSON形式で保存。
/// アプリ再起動後もプリセットを復元可能。
class PresetStorageService {
  static const String _presetsKey = 'user_presets';

  /// ユーザープリセットをすべて保存
  Future<void> savePresets(List<FilterPreset> presets) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = presets.map((p) => p.toJson()).toList();
    await prefs.setString(_presetsKey, jsonEncode(jsonList));
  }

  /// ユーザープリセットをすべて読み込み
  Future<List<FilterPreset>> loadPresets() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_presetsKey);

    if (jsonString == null || jsonString.isEmpty) {
      return [];
    }

    try {
      final jsonList = jsonDecode(jsonString) as List<dynamic>;
      return jsonList
          .map((json) => FilterPreset.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      // JSONパースエラーの場合は空のリストを返す
      return [];
    }
  }

  /// プリセットを追加
  Future<void> addPreset(FilterPreset preset) async {
    final presets = await loadPresets();
    // 既存のプリセットを上書き or 追加
    final existingIndex = presets.indexWhere((p) => p.id == preset.id);
    if (existingIndex >= 0) {
      presets[existingIndex] = preset;
    } else {
      presets.add(preset);
    }
    await savePresets(presets);
  }

  /// プリセットを削除
  Future<void> deletePreset(String presetId) async {
    final presets = await loadPresets();
    presets.removeWhere((p) => p.id == presetId);
    await savePresets(presets);
  }

  /// 全プリセットをクリア
  Future<void> clearAllPresets() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_presetsKey);
  }
}
