# TFLite Models Directory

This directory contains TensorFlow Lite models for AI features in Artester.

## Required Model for Style Transfer

To use the Style Transfer feature, you need to add a TFLite model file:

**Filename**: `style_transfer_quant.tflite`

### Where to Get Models

#### Option 1: TensorFlow Hub
Download pre-trained style transfer models from TensorFlow Hub:
- https://tfhub.dev/s?module-type=image-style-transfer

Example:
```bash
# Download from TensorFlow Hub
wget https://tfhub.dev/google/lite-model/magenta/arbitrary-image-stylization-v1-256/int8/prediction/1?lite-format=tflite -O style_transfer_quant.tflite
```

#### Option 2: Use Pre-trained Models
Popular style transfer models:
- **Magenta Arbitrary Style Transfer**: General-purpose artistic styles
- **Fast Style Transfer**: Optimized for mobile devices
- **Neural Style Transfer**: High-quality artistic rendering

#### Option 3: Convert Your Own Model
If you have a TensorFlow or PyTorch model:
1. Convert to TensorFlow Lite format
2. Quantize for better performance
3. Save as `.tflite` file

### Model Requirements

Your TFLite model should meet these specifications:

- **Input Shape**: `[1, 384, 384, 3]` (batch, height, width, RGB channels)
- **Output Shape**: `[1, 384, 384, 3]`
- **Input Range**: Normalized to 0.0-1.0
- **Output Range**: 0.0-1.0 (will be denormalized to 0-255)

**Note**: If your model uses different input/output shapes or normalization, you may need to adjust the `StyleTransferService` class in `lib/services/style_transfer_service.dart`.

### Adding Multiple Styles

You can add multiple model files with different names:
- `vangogh_style.tflite`
- `monet_style.tflite`
- `ukiyoe_style.tflite`
- `picasso_style.tflite`

Then update `lib/widgets/control_panel.dart` to add buttons for each style:

```dart
_buildStyleButton(
  context: context,
  ref: ref,
  label: 'Van Gogh',
  modelPath: 'models/vangogh_style.tflite',
  icon: Icons.brush,
),
```

## File Structure

```
assets/models/
├── README.md (this file)
├── style_transfer_quant.tflite (required - add this file)
├── vangogh_style.tflite (optional)
├── monet_style.tflite (optional)
└── ... (other style models)
```

## Testing

Once you've added a model file:
1. Run `flutter pub get` if you haven't already
2. Build and run the app
3. Load an image
4. Go to the AI tab
5. Tap the style transfer button
6. Wait for processing (3-10 seconds)
7. Your image should be transformed!

## Troubleshooting

### "Model file not found" error
- Check that the file is named exactly `style_transfer_quant.tflite`
- Ensure the file is in `assets/models/` directory
- Run `flutter clean` then `flutter pub get`
- Rebuild the app

### Processing takes too long
- Use a quantized model (smaller file size, faster)
- Ensure GPU delegate is supported on your device
- Consider reducing the input size in `StyleTransferService`

### Poor quality results
- Try a different model
- Check if input normalization matches your model's requirements
- Verify the model's input/output specifications

## Resources

- TensorFlow Lite: https://www.tensorflow.org/lite
- TensorFlow Hub: https://tfhub.dev/
- Magenta Project: https://magenta.tensorflow.org/
- Style Transfer Tutorial: https://www.tensorflow.org/lite/examples/style_transfer/overview

---

**Important**: This directory is currently empty. You must add at least one `.tflite` model file before using the Style Transfer feature.
