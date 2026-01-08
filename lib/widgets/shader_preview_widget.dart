import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/edit_state.dart';
import '../providers/edit_provider.dart';
import '../utils/lut_generator.dart';

/// シェーダーを使用して画像をリアルタイム処理するウィジェット
///
/// FragmentProgramを使用してGPUで描画。
/// パラメータ変更時に自動で再描画される。
/// LUTフィルターと高度な補正の両方に対応。
class ShaderPreviewWidget extends ConsumerStatefulWidget {
  /// シェーダーリソースが準備できたときのコールバック
  /// Export機能で使用するためにprogramとneutralLutを公開
  final void Function(ui.FragmentProgram program, ui.Image neutralLut)? onReady;

  const ShaderPreviewWidget({super.key, this.onReady});

  @override
  ConsumerState<ShaderPreviewWidget> createState() =>
      _ShaderPreviewWidgetState();
}

class _ShaderPreviewWidgetState extends ConsumerState<ShaderPreviewWidget> {
  ui.FragmentProgram? _program;
  ui.Image? _neutralLut;
  String? _error;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    await Future.wait([_loadShader(), _loadNeutralLut()]);
    // Export機能用にリソースを公開
    if (_program != null && _neutralLut != null && widget.onReady != null) {
      widget.onReady!(_program!, _neutralLut!);
    }
  }

  Future<void> _loadShader() async {
    try {
      debugPrint('Loading shader...');
      _program = await ui.FragmentProgram.fromAsset(
        'shaders/advanced_adjustment.frag',
      );
      debugPrint('Shader loaded successfully');
      if (mounted) setState(() {});
    } catch (e) {
      debugPrint('Shader load error: $e');
      if (mounted) {
        setState(() {
          _error = 'シェーダーの読み込みに失敗しました: $e';
        });
      }
    }
  }

  /// Neutral LUTを生成（LUT未選択時に使用）
  Future<void> _loadNeutralLut() async {
    try {
      debugPrint('Generating neutral LUT...');
      _neutralLut = await LutGenerator.generateNeutralLut();
      debugPrint(
        'Neutral LUT generated successfully: ${_neutralLut?.width}x${_neutralLut?.height}',
      );
      if (mounted) setState(() {});
    } catch (e) {
      debugPrint('Neutral LUT生成エラー: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final editState = ref.watch(editProvider);

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            _error!,
            style: const TextStyle(color: Colors.red),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    if (_program == null || _neutralLut == null) {
      return const Center(child: CircularProgressIndicator());
    }

    if (editState.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (editState.image == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.add_photo_alternate_outlined,
              size: 80,
              color: Colors.grey.shade600,
            ),
            const SizedBox(height: 16),
            Text(
              '画像を選択してください',
              style: TextStyle(color: Colors.grey.shade400, fontSize: 16),
            ),
          ],
        ),
      );
    }

    // 使用するLUT画像（カスタムLUTまたはNeutral）
    final activeLut = editState.lutImage ?? _neutralLut!;
    final hasLut = editState.lutImage != null;
    final notifier = ref.read(editProvider.notifier);

    return LayoutBuilder(
      builder: (context, constraints) {
        return GestureDetector(
          // 長押しで比較モード開始
          onLongPressStart: (_) {
            notifier.setComparing(true);
          },
          // 長押し終了で比較モード終了
          onLongPressEnd: (_) {
            notifier.setComparing(false);
          },
          child: InteractiveViewer(
            minScale: 0.1,
            maxScale: 5.0,
            boundaryMargin: const EdgeInsets.all(double.infinity),
            clipBehavior: Clip.none,
            child: CustomPaint(
              size: Size(constraints.maxWidth, constraints.maxHeight),
              painter: _ShaderPainter(
                program: _program!,
                image: editState.image!,
                lutImage: activeLut,
                hasLut: hasLut,
                lutIntensity: editState.lutIntensity,
                parameters: editState.parameters,
                rotation: editState.rotation,
                flipX: editState.flipX,
                flipY: editState.flipY,
                maskImage: editState.maskImage,
                hasMask: editState.hasMask,
                isComparing: editState.isComparing,
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}

/// シェーダーを使用して描画するCustomPainter
class _ShaderPainter extends CustomPainter {
  final ui.FragmentProgram program;
  final ui.Image image;
  final ui.Image lutImage;
  final bool hasLut;
  final double lutIntensity;
  final Map<String, double> parameters;
  final int rotation;
  final bool flipX;
  final bool flipY;
  final ui.Image? maskImage;
  final bool hasMask;
  final bool isComparing;

  _ShaderPainter({
    required this.program,
    required this.image,
    required this.lutImage,
    required this.hasLut,
    required this.lutIntensity,
    required this.parameters,
    required this.rotation,
    required this.flipX,
    required this.flipY,
    this.maskImage,
    required this.hasMask,
    required this.isComparing,
  });

  double _get(String key) => parameters[key] ?? 0.0;

  @override
  void paint(Canvas canvas, Size size) {
    try {
      final shader = program.fragmentShader();

      // 画像のアスペクト比を維持しながらフィット
      // 回転を考慮 (90度・270度の場合は縦横入れ替わり)
      final isRotated = rotation % 2 != 0;
      final imageWidth = isRotated
          ? image.height.toDouble()
          : image.width.toDouble();
      final imageHeight = isRotated
          ? image.width.toDouble()
          : image.height.toDouble();

      final imageAspect = imageWidth / imageHeight;
      final canvasAspect = size.width / size.height;

      double drawWidth, drawHeight;
      double offsetX = 0, offsetY = 0;

      if (imageAspect > canvasAspect) {
        drawWidth = size.width;
        drawHeight = size.width / imageAspect;
        offsetY = (size.height - drawHeight) / 2;
      } else {
        drawHeight = size.height;
        drawWidth = size.height * imageAspect;
        offsetX = (size.width - drawWidth) / 2;
      }

      // サンプラー設定（Flutter要件：サンプラーは最初に設定）
      // 重要: シェーダーで定義されているすべてのサンプラーを設定する必要がある
      shader.setImageSampler(0, image); // uTexture
      shader.setImageSampler(1, lutImage); // uLut
      // マスクがない場合はダミーとしてLUT画像を使用（uHasMaskフラグで無効化）
      shader.setImageSampler(
        2,
        hasMask && maskImage != null ? maskImage! : lutImage,
      ); // uMask

      // Float uniforms（シェーダーのuniform定義順序に厳密に合わせて設定）
      int idx = 0;

      // uSize (vec2) - 描画サイズ
      shader.setFloat(idx++, drawWidth);
      shader.setFloat(idx++, drawHeight);

      // LUT Parameters
      shader.setFloat(idx++, lutIntensity); // uLutIntensity
      shader.setFloat(idx++, hasLut ? 1.0 : 0.0); // uHasLut

      // Light Parameters
      shader.setFloat(idx++, _get('exposure')); // uExposure
      shader.setFloat(idx++, _get('brightness')); // uBrightness
      shader.setFloat(idx++, _get('contrast')); // uContrast
      shader.setFloat(idx++, _get('highlight')); // uHighlight
      shader.setFloat(idx++, _get('shadow')); // uShadow

      // Color Parameters
      shader.setFloat(idx++, _get('saturation')); // uSaturation
      shader.setFloat(idx++, _get('temperature')); // uTemperature
      shader.setFloat(idx++, _get('tint')); // uTint

      // Effect Parameters
      shader.setFloat(idx++, _get('vignette')); // uVignette
      shader.setFloat(idx++, _get('grain')); // uGrain

      // Geometry Parameters
      shader.setFloat(idx++, rotation.toDouble()); // uRotation
      shader.setFloat(idx++, flipX ? 1.0 : 0.0); // uFlipX
      shader.setFloat(idx++, flipY ? 1.0 : 0.0); // uFlipY

      // AI Segmentation Parameters
      shader.setFloat(idx++, hasMask ? 1.0 : 0.0); // uHasMask
      shader.setFloat(idx++, _get('bgSaturation')); // uBgSaturation
      shader.setFloat(idx++, _get('bgExposure')); // uBgExposure

      // Compare Mode Parameter
      shader.setFloat(idx++, isComparing ? 1.0 : 0.0); // uShowOriginal

      // 描画
      canvas.save();
      canvas.translate(offsetX, offsetY);

      final paint = Paint()
        ..shader = shader
        ..filterQuality = FilterQuality.medium;
      canvas.drawRect(Rect.fromLTWH(0, 0, drawWidth, drawHeight), paint);

      canvas.restore();
    } catch (e) {
      debugPrint('Shader paint error: $e');
      // エラー時は黒い画面の代わりにエラーメッセージを表示
      canvas.drawRect(
        Rect.fromLTWH(0, 0, size.width, size.height),
        Paint()..color = const Color(0xFF121212),
      );
    }
  }

  @override
  bool shouldRepaint(_ShaderPainter oldDelegate) {
    if (hasLut != oldDelegate.hasLut ||
        lutIntensity != oldDelegate.lutIntensity ||
        image != oldDelegate.image ||
        lutImage != oldDelegate.lutImage ||
        rotation != oldDelegate.rotation ||
        flipX != oldDelegate.flipX ||
        flipY != oldDelegate.flipY ||
        hasMask != oldDelegate.hasMask ||
        maskImage != oldDelegate.maskImage ||
        isComparing != oldDelegate.isComparing) {
      return true;
    }

    // パラメータの変更をチェック
    for (final key in EditState.defaultParameters.keys) {
      if ((parameters[key] ?? 0.0) != (oldDelegate.parameters[key] ?? 0.0)) {
        return true;
      }
    }
    return false;
  }
}
