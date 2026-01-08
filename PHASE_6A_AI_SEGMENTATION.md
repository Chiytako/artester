# Phase 6-A: AI Intelligence (Subject Segmentation)

## Overview

This phase implements AI-powered subject segmentation using Google ML Kit to separate subjects (people, etc.) from backgrounds, enabling selective background adjustments.

## Implementation Summary

### ✅ Completed Features

1. **Dependencies** ([pubspec.yaml](pubspec.yaml))
   - Added `google_mlkit_subject_segmentation: ^0.0.2`

2. **AI Segmentation Service** ([lib/services/ai_segmentation_service.dart](lib/services/ai_segmentation_service.dart))
   - `generateMask()`: Generates subject mask from image
   - Handles rotation/flip transformations to prevent coordinate misalignment
   - Converts ML Kit confidence mask (Float) to ui.Image (Grayscale RGBA)
   - Uses temporary file approach to ensure current edit state is analyzed

3. **State Management** ([lib/models/edit_state.dart](lib/models/edit_state.dart))
   - `maskImage`: Stores the generated mask (ui.Image)
   - `isAiProcessing`: Loading state for AI operations
   - `hasMask`: Convenience getter to check mask availability
   - Default parameters: `bgSaturation` and `bgExposure`

4. **Shader Enhancement** ([shaders/advanced_adjustment.frag](shaders/advanced_adjustment.frag))
   - **New Uniforms**:
     - `sampler2D uMask`: Mask texture (Index 2)
     - `float uHasMask`: Mask availability flag
     - `float uBgSaturation`: Background saturation adjustment (-1.0 ~ 1.0)
     - `float uBgExposure`: Background exposure adjustment (-1.0 ~ 1.0)
   - **Phase 8 Logic**: AI Background Adjustment
     ```glsl
     if (uHasMask > 0.5) {
         float mask = texture(uMask, uv).r;  // 0.0 = bg, 1.0 = subject
         vec3 bgRgb = rgb;
         bgRgb *= pow(2.0, uBgExposure);
         float bgGray = dot(bgRgb, vec3(0.299, 0.587, 0.114));
         bgRgb = mix(vec3(bgGray), bgRgb, 1.0 + uBgSaturation);
         rgb = mix(bgRgb, rgb, mask);  // Blend based on mask
     }
     ```

5. **Provider Integration** ([lib/providers/edit_provider.dart](lib/providers/edit_provider.dart))
   - `runAiSegmentation()`: Executes AI processing
     - Exports current edit state to temp file
     - Calls AiSegmentationService
     - Stores result in state.maskImage
   - `clearMask()`: Removes mask and resets background parameters
   - Integrated with Undo/Redo system
   - Auto-clears mask on crop operation (prevents coordinate mismatch)

6. **UI Controls** ([lib/widgets/control_panel.dart](lib/widgets/control_panel.dart))
   - **New Category**: "AI" tab with AI icon
   - **Three States**:
     1. **No Mask**: Shows "Detect Subject" button
     2. **Processing**: Shows loading indicator with "Detecting subject..."
     3. **Mask Active**: Shows:
        - Background Saturation slider
        - Background Exposure slider
        - "Clear" button to remove mask

7. **Widget Updates** ([lib/widgets/shader_preview_widget.dart](lib/widgets/shader_preview_widget.dart))
   - Added `maskImage` and `hasMask` to _ShaderPainter
   - Sets sampler index 2 for mask texture
   - Passes `uHasMask`, `uBgSaturation`, `uBgExposure` uniforms

8. **Export Support** ([lib/services/export_service.dart](lib/services/export_service.dart))
   - `exportImage()` accepts mask parameters
   - Full-resolution mask application in exported images
   - Maintains mask alignment with rotated/flipped images

## Key Design Decisions

### 1. Coordinate Alignment Strategy
**Problem**: AI segmentation analyzes the original image, but users may have rotated/flipped it.

**Solution**: Export current edit state (with rotation/flip) to a temporary file before analysis.
- Ensures mask coordinates perfectly align with displayed image
- Prevents "shifted mask" artifacts
- Same approach used in crop operation

### 2. Mask Representation
**Format**: RGBA Grayscale Image
- Red channel stores mask value (0-255)
- 255 = Subject (no background adjustment)
- 0 = Background (full adjustment)
- Intermediate values = smooth transition

**Why not Alpha-only?**
- Flutter shaders sample RGBA textures
- Using R channel is clearer and more compatible

### 3. Mask Lifecycle
**Auto-Clear on Crop**: When user crops the image, mask is automatically cleared and background parameters reset to 0.
- Prevents coordinate mismatch issues
- User must re-run detection after crop

**Manual Clear**: "Clear" button in AI tab removes mask and resets parameters.

### 4. Parameter Naming
- `bgSaturation`: Background Saturation (follows existing naming: `saturation`)
- `bgExposure`: Background Exposure (follows existing naming: `exposure`)
- Consistent with app's parameter convention

## Usage Flow

1. **Load Image**: User selects an image
2. **Optional Edits**: User can rotate, flip, or adjust colors first
3. **AI Detection**:
   - Navigate to "AI" tab
   - Tap "Detect Subject" button
   - Wait for processing (shows spinner)
4. **Background Adjustment**:
   - Adjust "Bg Saturation" slider (-1.0 = B&W background, 0.0 = normal, +1.0 = vibrant)
   - Adjust "Bg Exposure" slider (-1.0 = dark background, 0.0 = normal, +1.0 = bright)
5. **Export**: Export button saves image with background adjustments applied

## Example Use Cases

### 1. Subject Isolation (B&W Background)
- Detect subject
- Set `bgSaturation = -1.0`
- **Result**: Subject in color, background in black & white

### 2. Subject Emphasis (Dark Background)
- Detect subject
- Set `bgExposure = -0.8`
- **Result**: Subject bright, background darkened

### 3. Dramatic Portrait
- Detect subject
- Set `bgSaturation = -1.0` and `bgExposure = -0.5`
- **Result**: Subject in color, background dark & desaturated

## Technical Notes

### Performance
- AI processing time: ~1-3 seconds (device-dependent)
- Uses ML Kit's on-device processing (no internet required)
- Mask generation happens once; adjustments are real-time

### Limitations
- **Subject Detection**: Works best with clear subjects (people, animals)
- **Mask Persistence**: Mask is cleared on crop/rotation operations
- **Platform Support**: Requires ML Kit support (Android/iOS)

### Error Handling
- If AI fails, `isAiProcessing` returns to false
- Error is printed to debug console
- User can retry detection

## Validation Checklist

✅ Load image and rotate/flip
✅ Run "Detect Subject" - mask aligns correctly
✅ Adjust "Bg Saturation" to -1.0 - background becomes B&W, subject stays color
✅ Adjust "Bg Exposure" to -0.8 - background darkens, subject unaffected
✅ Export image - adjustments persist in saved file
✅ Clear mask - sliders reset, full-image adjustments work again
✅ Undo/Redo works with AI operations

## Files Modified

- [pubspec.yaml](pubspec.yaml) - Added ML Kit dependency
- [lib/services/ai_segmentation_service.dart](lib/services/ai_segmentation_service.dart) - Created (NEW)
- [lib/models/edit_state.dart](lib/models/edit_state.dart) - Added mask fields
- [lib/providers/edit_provider.dart](lib/providers/edit_provider.dart) - Added AI methods
- [shaders/advanced_adjustment.frag](shaders/advanced_adjustment.frag) - Added mask logic
- [lib/widgets/control_panel.dart](lib/widgets/control_panel.dart) - Added AI tab
- [lib/widgets/shader_preview_widget.dart](lib/widgets/shader_preview_widget.dart) - Pass mask to shader
- [lib/services/export_service.dart](lib/services/export_service.dart) - Export with mask

## Next Steps (Future Enhancements)

- **Mask Editing**: Manual brush to refine AI-generated mask
- **Multiple Subjects**: Detect and adjust individual subjects separately
- **Background Replacement**: Replace background with solid color or image
- **Edge Refinement**: Improve mask edge quality with feathering
- **Mask Preview**: Toggle overlay to visualize detected subject area
