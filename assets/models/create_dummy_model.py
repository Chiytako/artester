#!/usr/bin/env python3
"""
Create a dummy style transfer model for testing.
This model applies a simple artistic effect (sepia tone) to images.
"""

import tensorflow as tf
import numpy as np

print("Creating style transfer model...")

# Define a simple style transfer model
class StyleTransferModel(tf.Module):
    @tf.function(input_signature=[
        tf.TensorSpec(shape=[1, 384, 384, 3], dtype=tf.float32)
    ])
    def call(self, x):
        """
        Apply a simple artistic effect.
        This creates a warm, vintage-style effect.
        """
        # Extract RGB channels
        r = x[:, :, :, 0:1]
        g = x[:, :, :, 1:2]
        b = x[:, :, :, 2:3]

        # Apply sepia-like transformation matrix
        # New R = 0.393*R + 0.769*G + 0.189*B
        # New G = 0.349*R + 0.686*G + 0.168*B
        # New B = 0.272*R + 0.534*G + 0.131*B
        new_r = 0.393 * r + 0.769 * g + 0.189 * b
        new_g = 0.349 * r + 0.686 * g + 0.168 * b
        new_b = 0.272 * r + 0.534 * g + 0.131 * b

        # Combine channels
        output = tf.concat([new_r, new_g, new_b], axis=3)

        # Clip values to [0, 1] range
        output = tf.clip_by_value(output, 0.0, 1.0)

        return output

# Create and save the model
print("Building model...")
model = StyleTransferModel()

# Get concrete function
concrete_func = model.call.get_concrete_function()

# Convert to TFLite
print("Converting to TFLite format...")
converter = tf.lite.TFLiteConverter.from_concrete_functions([concrete_func])
converter.optimizations = [tf.lite.Optimize.DEFAULT]
tflite_model = converter.convert()

# Save the model
output_path = 'style_transfer_quant.tflite'
with open(output_path, 'wb') as f:
    f.write(tflite_model)

print(f"✅ Model created successfully: {output_path}")
print(f"   File size: {len(tflite_model) / 1024:.2f} KB")
print(f"   Input: [1, 384, 384, 3] float32")
print(f"   Output: [1, 384, 384, 3] float32")
print(f"   Effect: Warm vintage/sepia style")
print("\nYou can now test the style transfer feature in the app!")
