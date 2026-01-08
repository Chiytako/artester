import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';

/// Style Transfer Service using TensorFlow Lite (2-input model)
///
/// This service manages the TFLite interpreter and executes style transfer
/// with both content and style images.
class StyleTransferService {
  Interpreter? _interpreter;
  bool _isInitialized = false;

  // Model input/output specifications
  static const int _contentSize = 384; // Content image input size
  static const int _styleSize = 256; // Style image input size
  static const int _channels = 3; // RGB channels

  /// Initialize the TFLite interpreter with a model file
  ///
  /// [modelPath] - Asset path to the .tflite model file
  /// Example: 'models/style_transfer_quant.tflite'
  Future<void> initialize(String modelPath) async {
    try {
      debugPrint('=== Style Transfer Initialization ===');
      debugPrint('Loading TFLite model from: $modelPath');

      // Load model from assets
      final interpreterOptions = InterpreterOptions();

      // Try to use GPU delegate if available (improves performance)
      try {
        interpreterOptions.addDelegate(GpuDelegateV2());
        debugPrint('GPU delegate enabled');
      } catch (e) {
        debugPrint('GPU delegate not available, using CPU: $e');
      }

      _interpreter = await Interpreter.fromAsset(
        modelPath,
        options: interpreterOptions,
      );

      _isInitialized = true;
      debugPrint('TFLite model loaded successfully');

      // Enhanced debugging
      final inputTensors = _interpreter!.getInputTensors();
      final outputTensors = _interpreter!.getOutputTensors();

      debugPrint('Number of inputs: ${inputTensors.length}');
      for (var i = 0; i < inputTensors.length; i++) {
        debugPrint('  Input $i: ${inputTensors[i].shape} ${inputTensors[i].type}');
      }

      debugPrint('Number of outputs: ${outputTensors.length}');
      for (var i = 0; i < outputTensors.length; i++) {
        debugPrint('  Output $i: ${outputTensors[i].shape} ${outputTensors[i].type}');
      }

      debugPrint('=== Initialization Complete ===');
    } catch (e, stackTrace) {
      debugPrint('=== Error loading TFLite model ===');
      debugPrint('Error: $e');
      debugPrint('Stack trace: $stackTrace');
      _isInitialized = false;
      rethrow;
    }
  }

  /// Check if the service is initialized
  bool get isInitialized => _isInitialized;

  /// Apply style transfer to an image with a style image
  ///
  /// [contentImage] - The input ui.Image to apply style transfer to
  /// [styleImagePath] - Asset path to the style image (e.g., 'assets/styles/wave.jpg')
  /// Returns a new ui.Image with the style applied
  Future<ui.Image> applyStyleTransfer(
    ui.Image contentImage,
    String styleImagePath,
  ) async {
    if (!_isInitialized || _interpreter == null) {
      throw Exception(
          'StyleTransferService not initialized. Call initialize() first.');
    }

    debugPrint(
        'Starting style transfer on image: ${contentImage.width}x${contentImage.height}');
    debugPrint('Using style: $styleImagePath');

    // Step 1: Load and preprocess style image
    final styleImage = await _loadStyleImage(styleImagePath);
    final preprocessedStyle = _preprocessStyleImage(styleImage);

    // Step 2: Convert and preprocess content image
    final contentImgImage = await _convertUiImageToImage(contentImage);
    final preprocessedContent = _preprocessContentImage(contentImgImage);

    // Step 3: Run inference with both inputs
    final output = _runInference(preprocessedContent, preprocessedStyle);

    // Step 4: Postprocess - convert output back to image
    final resultImage =
        await _postprocessOutput(output, contentImage.width, contentImage.height);

    debugPrint('Style transfer completed');
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
    final byteData =
        await uiImage.toByteData(format: ui.ImageByteFormat.rawRgba);
    if (byteData == null) {
      throw Exception('Failed to convert ui.Image to bytes');
    }

    final bytes = byteData.buffer.asUint8List();
    final imgImage = img.Image.fromBytes(
      width: uiImage.width,
      height: uiImage.height,
      bytes: bytes.buffer,
      numChannels: 4,
    );

    return imgImage;
  }

  /// Preprocess content image for model input
  Float32List _preprocessContentImage(img.Image image) {
    // Resize to content input size
    final resized = img.copyResize(
      image,
      width: _contentSize,
      height: _contentSize,
      interpolation: img.Interpolation.linear,
    );

    // Prepare input buffer: [1, 384, 384, 3]
    final inputBuffer = Float32List(1 * _contentSize * _contentSize * _channels);

    int pixelIndex = 0;
    for (int y = 0; y < _contentSize; y++) {
      for (int x = 0; x < _contentSize; x++) {
        final pixel = resized.getPixel(x, y);

        // Normalize to 0.0-1.0 range
        inputBuffer[pixelIndex++] = pixel.r / 255.0;
        inputBuffer[pixelIndex++] = pixel.g / 255.0;
        inputBuffer[pixelIndex++] = pixel.b / 255.0;
      }
    }

    return inputBuffer;
  }

  /// Preprocess style image for model input
  Float32List _preprocessStyleImage(img.Image image) {
    // Resize to style input size
    final resized = img.copyResize(
      image,
      width: _styleSize,
      height: _styleSize,
      interpolation: img.Interpolation.linear,
    );

    // Prepare input buffer: [1, 256, 256, 3]
    final inputBuffer = Float32List(1 * _styleSize * _styleSize * _channels);

    int pixelIndex = 0;
    for (int y = 0; y < _styleSize; y++) {
      for (int x = 0; x < _styleSize; x++) {
        final pixel = resized.getPixel(x, y);

        // Normalize to 0.0-1.0 range
        inputBuffer[pixelIndex++] = pixel.r / 255.0;
        inputBuffer[pixelIndex++] = pixel.g / 255.0;
        inputBuffer[pixelIndex++] = pixel.b / 255.0;
      }
    }

    return inputBuffer;
  }

  /// Run inference with both content and style inputs
  Float32List _runInference(Float32List contentInput, Float32List styleInput) {
    try {
      debugPrint('=== Running Inference ===');
      debugPrint('Content input size: ${contentInput.length}');
      debugPrint('Style input size: ${styleInput.length}');
      debugPrint('Expected content: ${1 * _contentSize * _contentSize * _channels}');
      debugPrint('Expected style: ${1 * _styleSize * _styleSize * _channels}');

      // Reshape inputs
      final contentReshaped =
          contentInput.reshape([1, _contentSize, _contentSize, _channels]);
      final styleReshaped =
          styleInput.reshape([1, _styleSize, _styleSize, _channels]);

      debugPrint('Content reshaped: ${contentReshaped.shape}');
      debugPrint('Style reshaped: ${styleReshaped.shape}');

      // Prepare inputs list (input 0: content, input 1: style)
      final inputs = [contentReshaped, styleReshaped];

      // Prepare output buffer as a shaped tensor
      final output = List.generate(
        1,
        (_) => List.generate(
          _contentSize,
          (_) => List.generate(
            _contentSize,
            (_) => List.filled(_channels, 0.0),
          ),
        ),
      );

      // Prepare outputs map
      final outputs = {0: output};

      debugPrint('Starting TFLite inference...');
      debugPrint('Inputs count: ${inputs.length}');
      debugPrint('Outputs count: ${outputs.length}');

      // Run inference with multiple inputs
      try {
        _interpreter!.runForMultipleInputs(inputs, outputs);
        debugPrint('Inference completed successfully');
      } catch (inferenceError) {
        debugPrint('=== Inference Error ===');
        debugPrint('Error: $inferenceError');
        debugPrint('This usually means:');
        debugPrint('  1. Model expects different input shapes');
        debugPrint('  2. Model expects different number of inputs');
        debugPrint('  3. Input/output tensor types mismatch');
        rethrow;
      }

      // Flatten output to Float32List
      final flatOutput = Float32List(_contentSize * _contentSize * _channels);
      int index = 0;
      for (int y = 0; y < _contentSize; y++) {
        for (int x = 0; x < _contentSize; x++) {
          for (int c = 0; c < _channels; c++) {
            flatOutput[index++] = (output[0][y][x][c] as num).toDouble();
          }
        }
      }

      debugPrint('Output flattened successfully');
      debugPrint('=== Inference Complete ===');

      return flatOutput;
    } catch (e, stackTrace) {
      debugPrint('=== Error during inference ===');
      debugPrint('Error: $e');
      debugPrint('Stack trace: $stackTrace');
      rethrow;
    }
  }

  /// Postprocess model output back to ui.Image
  Future<ui.Image> _postprocessOutput(
    Float32List output,
    int targetWidth,
    int targetHeight,
  ) async {
    // Convert output to image.Image
    final imgImage = img.Image(width: _contentSize, height: _contentSize);

    int pixelIndex = 0;
    for (int y = 0; y < _contentSize; y++) {
      for (int x = 0; x < _contentSize; x++) {
        // Denormalize and clamp to 0-255 range
        final r = (output[pixelIndex++] * 255.0).clamp(0, 255).toInt();
        final g = (output[pixelIndex++] * 255.0).clamp(0, 255).toInt();
        final b = (output[pixelIndex++] * 255.0).clamp(0, 255).toInt();

        imgImage.setPixelRgba(x, y, r, g, b, 255);
      }
    }

    // Resize back to original/target dimensions
    final resized = img.copyResize(
      imgImage,
      width: targetWidth,
      height: targetHeight,
      interpolation: img.Interpolation.linear,
    );

    // Convert back to ui.Image
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
    _interpreter?.close();
    _interpreter = null;
    _isInitialized = false;
    debugPrint('StyleTransferService disposed');
  }
}
