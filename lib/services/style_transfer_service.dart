import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';

/// Style Transfer Service using TensorFlow Lite (Two-Stage Pipeline)
///
/// Uses two models:
/// 1. style_predict: Extracts style vector from style image -> [1, 1, 1, 100]
/// 2. style_transform: Applies style vector to content image -> stylized image
class StyleTransferService {
  Interpreter? _predictInterpreter;
  Interpreter? _transformInterpreter;
  bool _isInitialized = false;

  // Model input/output specifications
  // style_predict: input 256x256 style image -> output [1,1,1,100] style vector
  // style_transform: input 384x384 content + style vector -> output 384x384 styled image
  static const int _contentSize =
      384; // Content image input size (transform model)
  static const int _styleSize = 256; // Style image input size (predict model)
  static const int _channels = 3; // RGB channels
  static const int _styleVectorSize = 100; // Style bottleneck vector size

  /// Initialize both TFLite interpreters
  ///
  /// [predictModelPath] - Asset path to style_predict model
  /// [transformModelPath] - Asset path to style_transform model
  Future<void> initialize(
    String predictModelPath,
    String transformModelPath,
  ) async {
    try {
      debugPrint('=== Style Transfer Initialization (Two-Stage) ===');

      // Load Style Predict model
      debugPrint('Loading Style Predict model: $predictModelPath');
      final predictOptions = InterpreterOptions();
      try {
        predictOptions.addDelegate(GpuDelegateV2());
      } catch (e) {
        debugPrint('GPU delegate not available for predict model: $e');
      }
      _predictInterpreter = await Interpreter.fromAsset(
        predictModelPath,
        options: predictOptions,
      );
      _logModelInfo('Predict', _predictInterpreter!);

      // Load Style Transform model
      debugPrint('Loading Style Transform model: $transformModelPath');
      final transformOptions = InterpreterOptions();
      try {
        transformOptions.addDelegate(GpuDelegateV2());
      } catch (e) {
        debugPrint('GPU delegate not available for transform model: $e');
      }
      _transformInterpreter = await Interpreter.fromAsset(
        transformModelPath,
        options: transformOptions,
      );
      _logModelInfo('Transform', _transformInterpreter!);

      _isInitialized = true;
      debugPrint('=== Initialization Complete ===');
    } catch (e, stackTrace) {
      debugPrint('=== Error loading TFLite models ===');
      debugPrint('Error: $e');
      debugPrint('Stack trace: $stackTrace');
      _isInitialized = false;
      rethrow;
    }
  }

  void _logModelInfo(String name, Interpreter interpreter) {
    final inputTensors = interpreter.getInputTensors();
    final outputTensors = interpreter.getOutputTensors();
    debugPrint(
      '$name model - Inputs: ${inputTensors.length}, Outputs: ${outputTensors.length}',
    );
    for (var i = 0; i < inputTensors.length; i++) {
      debugPrint(
        '  Input $i: ${inputTensors[i].shape} ${inputTensors[i].type}',
      );
    }
    for (var i = 0; i < outputTensors.length; i++) {
      debugPrint(
        '  Output $i: ${outputTensors[i].shape} ${outputTensors[i].type}',
      );
    }
  }

  /// Check if the service is initialized
  bool get isInitialized => _isInitialized;

  /// Apply style transfer using two-stage pipeline
  ///
  /// [contentImage] - The input ui.Image to apply style transfer to
  /// [styleImagePath] - Asset path to the style image (e.g., 'assets/styles/wave.jpg')
  /// Returns a new ui.Image with the style applied
  Future<ui.Image> applyStyleTransfer(
    ui.Image contentImage,
    String styleImagePath,
  ) async {
    if (!_isInitialized ||
        _predictInterpreter == null ||
        _transformInterpreter == null) {
      throw Exception(
        'StyleTransferService not initialized. Call initialize() first.',
      );
    }

    debugPrint('Starting two-stage style transfer...');
    debugPrint('Content: ${contentImage.width}x${contentImage.height}');
    debugPrint('Style: $styleImagePath');

    // Stage 1: Extract style vector from style image
    debugPrint('Stage 1: Extracting style vector...');
    final styleImage = await _loadStyleImage(styleImagePath);
    final styleVector = _runStylePredict(styleImage);
    debugPrint('Style vector extracted: ${styleVector.length} elements');

    // Stage 2: Apply style to content image
    debugPrint('Stage 2: Applying style to content...');
    final contentImgImage = await _convertUiImageToImage(contentImage);
    final styledOutput = _runStyleTransform(contentImgImage, styleVector);

    // Convert output to ui.Image
    final resultImage = await _postprocessOutput(
      styledOutput,
      contentImage.width,
      contentImage.height,
    );

    debugPrint('Style transfer completed successfully!');
    return resultImage;
  }

  /// Load style image from assets
  Future<img.Image> _loadStyleImage(String assetPath) async {
    final data = await rootBundle.load(assetPath);
    final bytes = data.buffer.asUint8List();
    final image = img.decodeImage(bytes);
    if (image == null) {
      throw Exception('Failed to load style image: $assetPath');
    }
    return image;
  }

  /// Convert ui.Image to image.Image
  Future<img.Image> _convertUiImageToImage(ui.Image uiImage) async {
    final byteData = await uiImage.toByteData(
      format: ui.ImageByteFormat.rawRgba,
    );
    if (byteData == null) {
      throw Exception('Failed to convert ui.Image to bytes');
    }
    final bytes = byteData.buffer.asUint8List();
    return img.Image.fromBytes(
      width: uiImage.width,
      height: uiImage.height,
      bytes: bytes.buffer,
      numChannels: 4,
    );
  }

  /// Run style prediction to extract style vector
  Float32List _runStylePredict(img.Image styleImage) {
    // Resize to style input size (256x256)
    final resized = img.copyResize(
      styleImage,
      width: _styleSize,
      height: _styleSize,
      interpolation: img.Interpolation.linear,
    );

    // Prepare input: [1, 256, 256, 3]
    final inputBuffer = Float32List(1 * _styleSize * _styleSize * _channels);
    int pixelIndex = 0;
    for (int y = 0; y < _styleSize; y++) {
      for (int x = 0; x < _styleSize; x++) {
        final pixel = resized.getPixel(x, y);
        inputBuffer[pixelIndex++] = pixel.r / 255.0;
        inputBuffer[pixelIndex++] = pixel.g / 255.0;
        inputBuffer[pixelIndex++] = pixel.b / 255.0;
      }
    }

    // Reshape input
    final input = inputBuffer.reshape([1, _styleSize, _styleSize, _channels]);

    // Prepare output: [1, 1, 1, 100]
    final output = List.generate(
      1,
      (_) => List.generate(
        1,
        (_) => List.generate(1, (_) => List.filled(_styleVectorSize, 0.0)),
      ),
    );

    // Run inference
    _predictInterpreter!.run(input, output);

    // Flatten to 1D array [100]
    final styleVector = Float32List(_styleVectorSize);
    for (int i = 0; i < _styleVectorSize; i++) {
      styleVector[i] = (output[0][0][0][i] as num).toDouble();
    }

    return styleVector;
  }

  /// Run style transform to apply style to content
  Float32List _runStyleTransform(
    img.Image contentImage,
    Float32List styleVector,
  ) {
    // Resize content to transform input size (384x384)
    final resized = img.copyResize(
      contentImage,
      width: _contentSize,
      height: _contentSize,
      interpolation: img.Interpolation.linear,
    );

    // Prepare content input: [1, 384, 384, 3]
    final contentBuffer = Float32List(
      1 * _contentSize * _contentSize * _channels,
    );
    int pixelIndex = 0;
    for (int y = 0; y < _contentSize; y++) {
      for (int x = 0; x < _contentSize; x++) {
        final pixel = resized.getPixel(x, y);
        contentBuffer[pixelIndex++] = pixel.r / 255.0;
        contentBuffer[pixelIndex++] = pixel.g / 255.0;
        contentBuffer[pixelIndex++] = pixel.b / 255.0;
      }
    }

    // Reshape inputs
    final contentInput = contentBuffer.reshape([
      1,
      _contentSize,
      _contentSize,
      _channels,
    ]);
    final styleInput = styleVector.reshape([1, 1, 1, _styleVectorSize]);

    // Prepare output: [1, 384, 384, 3]
    final output = List.generate(
      1,
      (_) => List.generate(
        _contentSize,
        (_) => List.generate(_contentSize, (_) => List.filled(_channels, 0.0)),
      ),
    );

    // Determine correct input order by checking tensor shapes
    // Input 0 could be either style bottleneck [1,1,1,100] or content [1,384,384,3]
    final inputTensors = _transformInterpreter!.getInputTensors();
    debugPrint('Transform model input tensors:');
    for (var i = 0; i < inputTensors.length; i++) {
      debugPrint(
        '  Input $i: ${inputTensors[i].shape} name=${inputTensors[i].name}',
      );
    }

    // Check if input 0 is the style bottleneck (small tensor) or content image (large tensor)
    final input0Shape = inputTensors[0].shape;
    final isInput0Style =
        input0Shape.length == 4 && input0Shape[1] == 1 && input0Shape[2] == 1;

    final List<Object> inputs;
    if (isInput0Style) {
      debugPrint('Input order: [style, content]');
      inputs = [styleInput, contentInput];
    } else {
      debugPrint('Input order: [content, style]');
      inputs = [contentInput, styleInput];
    }

    final outputs = {0: output};

    _transformInterpreter!.runForMultipleInputs(inputs, outputs);

    // Debug: Check output range
    double minVal = double.infinity;
    double maxVal = double.negativeInfinity;

    // Flatten output
    final flatOutput = Float32List(_contentSize * _contentSize * _channels);
    int index = 0;
    for (int y = 0; y < _contentSize; y++) {
      for (int x = 0; x < _contentSize; x++) {
        for (int c = 0; c < _channels; c++) {
          final val = (output[0][y][x][c] as num).toDouble();
          flatOutput[index++] = val;
          if (val < minVal) minVal = val;
          if (val > maxVal) maxVal = val;
        }
      }
    }

    debugPrint('Output value range: min=$minVal, max=$maxVal');

    return flatOutput;
  }

  /// Postprocess model output back to ui.Image
  Future<ui.Image> _postprocessOutput(
    Float32List output,
    int targetWidth,
    int targetHeight,
  ) async {
    final imgImage = img.Image(width: _contentSize, height: _contentSize);

    int pixelIndex = 0;
    for (int y = 0; y < _contentSize; y++) {
      for (int x = 0; x < _contentSize; x++) {
        final r = (output[pixelIndex++] * 255.0).clamp(0, 255).toInt();
        final g = (output[pixelIndex++] * 255.0).clamp(0, 255).toInt();
        final b = (output[pixelIndex++] * 255.0).clamp(0, 255).toInt();
        imgImage.setPixelRgba(x, y, r, g, b, 255);
      }
    }

    // Resize back to original dimensions
    final resized = img.copyResize(
      imgImage,
      width: targetWidth,
      height: targetHeight,
      interpolation: img.Interpolation.linear,
    );

    return _convertImageToUiImage(resized);
  }

  /// Convert image.Image to ui.Image
  Future<ui.Image> _convertImageToUiImage(img.Image image) async {
    final bytes = img.encodePng(image);
    final codec = await ui.instantiateImageCodec(bytes);
    final frame = await codec.getNextFrame();
    return frame.image;
  }

  /// Dispose of resources
  void dispose() {
    _predictInterpreter?.close();
    _transformInterpreter?.close();
    _predictInterpreter = null;
    _transformInterpreter = null;
    _isInitialized = false;
    debugPrint('StyleTransferService disposed');
  }
}
