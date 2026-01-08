import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import 'package:flutter/material.dart'; // For BuildContext and Colors
import 'package:image_cropper/image_cropper.dart';

import '../models/edit_state.dart';
import '../models/filter_preset.dart';
import '../services/ai_segmentation_service.dart';
import '../services/export_service.dart';
import '../services/preset_storage_service.dart';
import '../services/style_transfer_service.dart';
import '../utils/lut_generator.dart';

/// 編集状態のプロバイダー
final editProvider = StateNotifierProvider<EditNotifier, EditState>((ref) {
  return EditNotifier();
});

/// 現在選択中のパラメータタブ
final selectedParameterProvider = StateProvider<String>((ref) => 'brightness');

/// シェーダーリソース（切り抜き機能などで使用）
final shaderResourcesProvider = StateProvider<ShaderResources?>((ref) => null);

class ShaderResources {
  final ui.FragmentProgram program;
  final ui.Image neutralLut;
  ShaderResources(this.program, this.neutralLut);
}

/// 画像編集ロジックを管理するNotifier
///
/// Undo/Redo対応の設計：
/// - _history: 過去の状態を保持
/// - _redoStack: Redo用のスタック
class EditNotifier extends StateNotifier<EditState> {
  EditNotifier() : super(EditState.initial());

  // Undo/Redo用の履歴スタック
  final List<EditState> _history = [];
  final List<EditState> _redoStack = [];
  static const int _maxHistorySize = 50;

  final ImagePicker _picker = ImagePicker();

  /// パラメータを個別に変更（スライダー操作）
  /// [saveHistory] - 履歴に保存するかどうか（デフォルトはfalse）
  void updateParameter(String key, double value, {bool saveHistory = false}) {
    if (saveHistory) {
      _saveToHistory();
    }
    final newParams = Map<String, double>.from(state.parameters);
    newParams[key] = value;
    state = state.copyWith(parameters: newParams);
  }

  /// フィルター適用強度を変更
  void updateFilterStrength(double value) {
    state = state.copyWith(filterStrength: value.clamp(0.0, 1.0));
  }

  /// アセットからLUTを読み込んで設定
  Future<void> setLut(String? assetPath) async {
    if (assetPath == null) {
      clearLut();
      return;
    }

    _saveToHistory();
    state = state.copyWith(isLoading: true);

    try {
      final data = await rootBundle.load(assetPath);
      final bytes = data.buffer.asUint8List();
      final codec = await ui.instantiateImageCodec(bytes);
      final frame = await codec.getNextFrame();

      state = state.copyWith(
        lutImage: frame.image,
        activeLutPath: assetPath,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false);
      rethrow;
    }
  }

  /// 生成されたLUTを使用（デバッグ用）
  Future<void> useGeneratedLut(String lutType) async {
    _saveToHistory();
    state = state.copyWith(isLoading: true);

    try {
      ui.Image lutImage;

      switch (lutType) {
        case 'warm':
          lutImage = await LutGenerator.generateWarmLut();
          break;
        case 'cool':
          lutImage = await LutGenerator.generateCoolLut();
          break;
        case 'vintage':
          lutImage = await LutGenerator.generateVintageLut();
          break;
        case 'cinematic':
          lutImage = await LutGenerator.generateCinematicLut();
          break;
        case 'neutral':
        default:
          lutImage = await LutGenerator.generateNeutralLut();
          break;
      }

      state = state.copyWith(
        lutImage: lutImage,
        activeLutPath: 'generated:$lutType',
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false);
      rethrow;
    }
  }

  /// LUT強度を変更
  void updateLutIntensity(double value) {
    state = state.copyWith(lutIntensity: value.clamp(0.0, 1.0));
  }

  /// LUTをクリア
  void clearLut() {
    _saveToHistory();
    state = state.copyWith(
      lutImage: null,
      activeLutPath: null,
      lutIntensity: 1.0,
    );
  }

  /// プリセットを適用（再編集の開始）
  void applyPreset(FilterPreset preset) {
    _saveToHistory();
    state = state.copyWith(
      parameters: Map.from(preset.parameters),
      currentPresetId: preset.id,
    );
  }

  /// 現在の状態からプリセットを作成
  FilterPreset createPresetFromCurrent({
    required String id,
    required String name,
    String? category,
  }) {
    return FilterPreset.fromEditState(
      id: id,
      name: name,
      parameters: state.parameters,
      category: category,
    );
  }

  /// JSONデータ（共有されたファイル）をインポート
  FilterPreset? importPresetFromString(String jsonString) {
    try {
      final json = jsonDecode(jsonString) as Map<String, dynamic>;
      final preset = FilterPreset.fromJson(json);
      applyPreset(preset);
      return preset;
    } catch (e) {
      return null;
    }
  }

  /// 画像を選択
  Future<bool> pickImage() async {
    try {
      final XFile? picked = await _picker.pickImage(
        source: ImageSource.gallery,
      );
      if (picked != null) {
        debugPrint('Image picked: ${picked.path}');
        state = state.copyWith(isLoading: true);

        final file = File(picked.path);
        final bytes = await file.readAsBytes();
        debugPrint('Image bytes loaded: ${bytes.length} bytes');

        final codec = await ui.instantiateImageCodec(bytes);
        final frame = await codec.getNextFrame();
        debugPrint('Image decoded: ${frame.image.width}x${frame.image.height}');

        state = state.copyWith(
          image: frame.image,
          imagePath: picked.path,
          isLoading: false,
        );
        debugPrint('Image state updated');
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error picking image: $e');
      state = state.copyWith(isLoading: false);
      return false;
    }
  }

  /// 全てのパラメータをリセット
  void resetAllParameters() {
    _saveToHistory();
    state = state.copyWith(
      parameters: Map.from(EditState.defaultParameters),
      currentPresetId: null,
      lutImage: null,
      activeLutPath: null,
      lutIntensity: 1.0,
    );
  }

  /// 特定のパラメータをデフォルト値にリセット
  void resetParameter(String key) {
    _saveToHistory();
    final defaultValue = EditState.defaultParameters[key] ?? 0.0;
    final newParams = Map<String, double>.from(state.parameters);
    newParams[key] = defaultValue;
    state = state.copyWith(parameters: newParams);
  }

  /// Undo操作
  void undo() {
    if (_history.isEmpty) return;
    _redoStack.add(state);
    state = _history.removeLast();
  }

  /// Redo操作
  void redo() {
    if (_redoStack.isEmpty) return;
    _history.add(state);
    state = _redoStack.removeLast();
  }

  /// Undoが可能か
  bool get canUndo => _history.isNotEmpty;

  /// Redoが可能か
  bool get canRedo => _redoStack.isNotEmpty;

  /// 比較モードを切り替え（長押し中にオリジナル画像を表示）
  void setComparing(bool isComparing) {
    state = state.copyWith(isComparing: isComparing);
  }

  /// 90度回転（時計回り）
  void rotate90() {
    _saveToHistory();
    // 0 -> 1 -> 2 -> 3 -> 0
    state = state.copyWith(rotation: (state.rotation + 1) % 4);
  }

  /// 90度回転（反時計回り）
  void rotateLeft() {
    _saveToHistory();
    // 0 -> 3 -> 2 -> 1 -> 0
    state = state.copyWith(rotation: (state.rotation + 3) % 4);
  }

  /// 水平反転
  void flipHorizontal() {
    _saveToHistory();
    state = state.copyWith(flipX: !state.flipX);
  }

  /// 垂直反転
  void flipVertical() {
    _saveToHistory();
    state = state.copyWith(flipY: !state.flipY);
  }

  /// 画像切り抜き（現在の回転・反転を焼付けた上で切り抜き）
  Future<void> cropImage(
    BuildContext context,
    ui.FragmentProgram program,
    ui.Image neutralLut,
  ) async {
    if (state.image == null) return;

    _saveToHistory();
    state = state.copyWith(isLoading: true);

    try {
      // 1. 現在の回転・反転を適用した一時画像を生成（色調整は適用しない）
      final tempPath = await _exportService.exportToTempFile(
        program: program,
        originalImage: state.image!,
        lutImage: neutralLut,
        rotation: state.rotation,
        flipX: state.flipX,
        flipY: state.flipY,
      );

      // 2. ImageCropper UIを起動
      final croppedFile = await ImageCropper().cropImage(
        sourcePath: tempPath,
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Crop & Rotate',
            toolbarColor: const Color(0xFF212121),
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: false,
          ),
          IOSUiSettings(title: 'Crop & Rotate'),
        ],
      );

      if (croppedFile != null) {
        // 3. 切り抜かれた画像を読み込み
        final file = File(croppedFile.path);
        final bytes = await file.readAsBytes();
        final codec = await ui.instantiateImageCodec(bytes);
        final frame = await codec.getNextFrame();

        // 4. 新しい画像でステート更新（回転・反転はリセット、色調整は維持）
        // マスクもクリア（切り抜き後は座標が合わなくなるため）
        final newParams = Map<String, double>.from(state.parameters);
        newParams['bgSaturation'] = 0.0;
        newParams['bgExposure'] = 0.0;

        state = state.copyWith(
          image: frame.image,
          imagePath: croppedFile.path, // 切り抜き後の一時パスを保存
          rotation: 0,
          flipX: false,
          flipY: false,
          maskImage: null, // マスクをクリア
          parameters: newParams, // 背景パラメータもリセット
          isLoading: false,
        );
      } else {
        // キャンセル時はローディング解除のみ
        state = state.copyWith(isLoading: false);
      }
    } catch (e) {
      debugPrint('Crop error: $e');
      state = state.copyWith(isLoading: false);
      // エラー処理（必要ならToast表示など）
    }
  }

  // 履歴に保存
  void _saveToHistory() {
    _history.add(state);
    _redoStack.clear();

    // 履歴サイズ制限
    while (_history.length > _maxHistorySize) {
      _history.removeAt(0);
    }
  }

  // ========== Export & Preset Methods ==========

  final ExportService _exportService = ExportService();
  final PresetStorageService _presetStorageService = PresetStorageService();
  final AiSegmentationService _aiService = AiSegmentationService();
  final StyleTransferService _styleTransferService = StyleTransferService();

  /// AI被写体セグメンテーションを実行
  Future<void> runAiSegmentation(
    ui.FragmentProgram program,
    ui.Image neutralLut,
  ) async {
    if (state.image == null) return;

    _saveToHistory();
    state = state.copyWith(isAiProcessing: true);

    try {
      final maskImage = await _aiService.generateMask(
        originalImage: state.image!,
        rotation: state.rotation,
        flipX: state.flipX,
        flipY: state.flipY,
        program: program,
        neutralLut: neutralLut,
      );

      state = state.copyWith(
        maskImage: maskImage,
        isAiProcessing: false,
      );
    } catch (e) {
      debugPrint('AI segmentation error: $e');
      state = state.copyWith(isAiProcessing: false);
      rethrow;
    }
  }

  /// マスクと背景パラメータをクリア
  void clearMask() {
    _saveToHistory();
    final newParams = Map<String, double>.from(state.parameters);
    newParams['bgSaturation'] = 0.0;
    newParams['bgExposure'] = 0.0;

    state = state.copyWith(
      maskImage: null,
      parameters: newParams,
    );
  }

  /// AI Style Transferを実行
  ///
  /// [modelPath] - TFLiteモデルファイルのパス（例: 'models/style_transfer_quant.tflite'）
  /// [styleImagePath] - スタイル画像のアセットパス（例: 'assets/styles/wave.jpg'）
  Future<void> applyStyleTransfer(String modelPath, String styleImagePath) async {
    if (state.image == null) return;

    _saveToHistory();
    state = state.copyWith(isAiProcessing: true);

    try {
      // Initialize the model if not already initialized
      if (!_styleTransferService.isInitialized) {
        await _styleTransferService.initialize(modelPath);
      }

      // Apply style transfer with style image
      final styledImage = await _styleTransferService.applyStyleTransfer(
        state.image!,
        styleImagePath,
      );

      // Update state with the styled image
      state = state.copyWith(
        image: styledImage,
        isAiProcessing: false,
      );

      debugPrint('Style transfer applied successfully');
    } catch (e) {
      debugPrint('Style transfer error: $e');
      state = state.copyWith(isAiProcessing: false);
      rethrow;
    }
  }

  /// 現在の編集結果をエクスポート
  ///
  /// [program] - シェーダープログラム（ShaderPreviewWidgetから渡す）
  /// [neutralLut] - Neutral LUT（LUT未選択時に使用）
  Future<void> exportResult(
    ui.FragmentProgram program,
    ui.Image neutralLut,
  ) async {
    if (state.image == null) {
      throw Exception('No image loaded');
    }

    state = state.copyWith(isLoading: true);

    try {
      final activeLut = state.lutImage ?? neutralLut;
      final hasLut = state.lutImage != null;

      await _exportService.exportImage(
        program: program,
        originalImage: state.image!,
        lutImage: activeLut,
        hasLut: hasLut,
        lutIntensity: state.lutIntensity,
        parameters: state.parameters,
        rotation: state.rotation,
        flipX: state.flipX,
        flipY: state.flipY,
        maskImage: state.maskImage,
        hasMask: state.hasMask,
        bgSaturation: state.getParameter('bgSaturation'),
        bgExposure: state.getParameter('bgExposure'),
      );

      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false);
      rethrow;
    }
  }

  /// 現在のパラメータをユーザープリセットとして保存
  Future<FilterPreset> saveCurrentAsPreset(String name) async {
    final id = 'user_${DateTime.now().millisecondsSinceEpoch}';
    final preset = FilterPreset.fromEditState(
      id: id,
      name: name,
      parameters: state.parameters,
      lutPath: state.activeLutPath,
    );

    await _presetStorageService.addPreset(preset);
    return preset;
  }

  /// ユーザープリセットを読み込み
  Future<List<FilterPreset>> loadUserPresets() async {
    return await _presetStorageService.loadPresets();
  }

  /// ユーザープリセットを削除
  Future<void> deleteUserPreset(String presetId) async {
    await _presetStorageService.deletePreset(presetId);
  }
}

/// ユーザープリセット一覧のプロバイダー
final userPresetsProvider =
    StateNotifierProvider<UserPresetsNotifier, List<FilterPreset>>((ref) {
      return UserPresetsNotifier();
    });

/// ユーザープリセット管理のNotifier
class UserPresetsNotifier extends StateNotifier<List<FilterPreset>> {
  UserPresetsNotifier() : super([]) {
    _loadPresets();
  }

  final PresetStorageService _storageService = PresetStorageService();

  /// 起動時にプリセットを読み込み
  Future<void> _loadPresets() async {
    state = await _storageService.loadPresets();
  }

  /// プリセットを追加
  Future<void> addPreset(FilterPreset preset) async {
    await _storageService.addPreset(preset);
    state = await _storageService.loadPresets();
  }

  /// プリセットを削除
  Future<void> deletePreset(String presetId) async {
    await _storageService.deletePreset(presetId);
    state = await _storageService.loadPresets();
  }

  /// リストを更新
  Future<void> refresh() async {
    state = await _storageService.loadPresets();
  }
}
