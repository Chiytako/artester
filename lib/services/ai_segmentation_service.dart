import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:google_mlkit_subject_segmentation/google_mlkit_subject_segmentation.dart';

import '../utils/geometry_utils.dart';
import 'export_service.dart';

/// AI 被写体セグメンテーションサービス
///
/// Google ML Kitを使用して画像から被写体（人物など）を分離し、
/// 背景とのマスク画像を生成する。
class AiSegmentationService {
  final ExportService _exportService = ExportService();
  SubjectSegmenter? _segmenter;

  /// セグメンテーションマスクを生成
  ///
  /// [originalImage] - 元画像
  /// [rotation] - 回転状態 (0=0°, 1=90°, 2=180°, 3=270°)
  /// [flipX] - 水平反転
  /// [flipY] - 垂直反転
  /// [program] - シェーダープログラム（変換適用用）
  /// [neutralLut] - ニュートラルLUT
  Future<ui.Image> generateMask({
    required ui.Image originalImage,
    required int rotation,
    required bool flipX,
    required bool flipY,
    required ui.FragmentProgram program,
    required ui.Image neutralLut,
  }) async {
    try {
      debugPrint('[AI] Starting segmentation...');
      debugPrint('[AI] Original image: ${originalImage.width}x${originalImage.height}');

      // 1. 回転・反転を適用した一時画像を生成（座標ズレ防止）
      debugPrint('[AI] Exporting temp file with rotation=$rotation, flipX=$flipX, flipY=$flipY');
      final tempImagePath = await _exportService.exportToTempFile(
        program: program,
        originalImage: originalImage,
        lutImage: neutralLut,
        rotation: rotation,
        flipX: flipX,
        flipY: flipY,
      );
      debugPrint('[AI] Temp file created: $tempImagePath');

      try {
        // 2. 一時画像からInputImageを作成
        final inputImage = InputImage.fromFilePath(tempImagePath);
        debugPrint('[AI] InputImage created');

        // メタデータを確認
        if (inputImage.metadata == null) {
          debugPrint('[AI] Warning: InputImage metadata is null, using original image size');
        } else {
          debugPrint('[AI] InputImage metadata: ${inputImage.metadata!.size.width}x${inputImage.metadata!.size.height}');
        }

        // 3. セグメンターを初期化（初回のみ）
        if (_segmenter == null) {
          debugPrint('[AI] Initializing ML Kit segmenter...');
          _segmenter = SubjectSegmenter(
            options: SubjectSegmenterOptions(
              enableForegroundBitmap: false,
              enableForegroundConfidenceMask: true,
              enableMultipleSubjects: SubjectResultOptions(
                enableConfidenceMask: false,
                enableSubjectBitmap: false,
              ),
            ),
          );
          debugPrint('[AI] Segmenter initialized');
        }

        // 4. セグメンテーション実行
        debugPrint('[AI] Processing image with ML Kit...');
        final result = await _segmenter!.processImage(inputImage);
        debugPrint('[AI] ML Kit processing completed');

        // 5. 画像サイズを取得（メタデータがnullの場合は元画像のサイズを使用）
        final int maskWidth;
        final int maskHeight;

        if (inputImage.metadata != null) {
          maskWidth = inputImage.metadata!.size.width.toInt();
          maskHeight = inputImage.metadata!.size.height.toInt();
        } else {
          // 回転を考慮してサイズを計算
          final rotatedSize = GeometryUtils.getRotatedIntSize(
            originalImage.width,
            originalImage.height,
            rotation,
          );
          maskWidth = rotatedSize['width']!;
          maskHeight = rotatedSize['height']!;
        }

        debugPrint('[AI] Using mask size: ${maskWidth}x${maskHeight}');

        // 6. マスクデータをui.Imageに変換
        final maskImage = await _convertMaskToImage(
          result,
          maskWidth,
          maskHeight,
        );
        debugPrint('[AI] Mask image created: ${maskImage.width}x${maskImage.height}');

        return maskImage;
      } finally {
        // 6. 一時ファイルを削除
        try {
          final file = File(tempImagePath);
          if (await file.exists()) {
            await file.delete();
            debugPrint('[AI] Temp file deleted');
          }
        } catch (e) {
          debugPrint('[AI] Failed to delete temp file: $e');
        }
      }
    } catch (e, stackTrace) {
      debugPrint('[AI] Error during segmentation: $e');
      debugPrint('[AI] Stack trace: $stackTrace');
      rethrow;
    }
  }

  /// ML Kitのマスクデータをグレースケールのui.Imageに変換
  ///
  /// [result] - ML Kitから返されたセグメンテーション結果
  /// [width] - 画像の幅
  /// [height] - 画像の高さ
  Future<ui.Image> _convertMaskToImage(
    SubjectSegmentationResult result,
    int width,
    int height,
  ) async {
    // ML Kitの信頼度マスクデータを取得（0.0〜1.0の値）
    final confidenceMask = result.foregroundConfidenceMask;

    if (confidenceMask == null || confidenceMask.isEmpty) {
      // マスクがない場合は白い画像を返す（全てを被写体として扱う）
      final rgbaBytes = Uint8List(width * height * 4);
      for (int i = 0; i < width * height; i++) {
        final pixelIndex = i * 4;
        rgbaBytes[pixelIndex] = 255; // R
        rgbaBytes[pixelIndex + 1] = 255; // G
        rgbaBytes[pixelIndex + 2] = 255; // B
        rgbaBytes[pixelIndex + 3] = 255; // A
      }

      // Completerを使用してui.Imageを取得
      final completer = Completer<ui.Image>();
      ui.decodeImageFromPixels(
        rgbaBytes,
        width,
        height,
        ui.PixelFormat.rgba8888,
        completer.complete,
      );
      return completer.future;
    }

    // RGBAバッファを作成（信頼度値をグレースケールに変換）
    final rgbaBytes = Uint8List(width * height * 4);
    for (int i = 0; i < confidenceMask.length && i < width * height; i++) {
      final value = (confidenceMask[i] * 255)
          .clamp(0, 255)
          .toInt(); // 0.0-1.0 → 0-255
      final pixelIndex = i * 4;
      rgbaBytes[pixelIndex] = value; // R
      rgbaBytes[pixelIndex + 1] = value; // G
      rgbaBytes[pixelIndex + 2] = value; // B
      rgbaBytes[pixelIndex + 3] = 255; // A（完全不透明）
    }

    // ui.Imageに変換（decodeImageFromPixelsを使用）
    final completer = Completer<ui.Image>();
    ui.decodeImageFromPixels(
      rgbaBytes,
      width,
      height,
      ui.PixelFormat.rgba8888,
      completer.complete,
    );
    return completer.future;
  }

  /// リソースを解放
  void dispose() {
    _segmenter?.close();
    _segmenter = null;
  }
}
