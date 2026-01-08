"""
Create a simple style transfer model for testing
This model takes a single input image and applies a simple color transformation
"""
import numpy as np

# Create a simple TFLite model that works with single input
# Input: [1, 384, 384, 3] float32
# Output: [1, 384, 384, 3] float32

def create_simple_tflite_model():
    """Create a flatbuffer model manually"""
    # For now, we'll use the quantized model we downloaded
    # But document how to create a simpler single-input model
    
    instructions = """
# Simple Style Transfer Model Creation

This model requires TensorFlow to create. Install with:
pip install tensorflow

Then run:

import tensorflow as tf
import numpy as np

# Create a simple passthrough model with color adjustment
class SimpleStyleModel(tf.Module):
    @tf.function(input_signature=[
        tf.TensorSpec(shape=[1, 384, 384, 3], dtype=tf.float32)
    ])
    def __call__(self, x):
        # Simple style: adjust colors
        # Increase blue, reduce red slightly
        styled = tf.stack([
            x[:,:,:,0] * 0.9,  # Red channel
            x[:,:,:,1] * 1.0,  # Green channel  
            x[:,:,:,2] * 1.1,  # Blue channel (enhance)
        ], axis=-1)
        return tf.clip_by_value(styled, 0.0, 1.0)

# Create and convert
model = SimpleStyleModel()
concrete_func = model.__call__.get_concrete_function()

converter = tf.lite.TFLiteConverter.from_concrete_functions([concrete_func])
converter.optimizations = [tf.lite.Optimize.DEFAULT]
tflite_model = converter.convert()

# Save
with open('simple_style.tflite', 'wb') as f:
    f.write(tflite_model)

print("Simple model created: simple_style.tflite")
"""
    
    print(instructions)
    
    # Also print the current model info
    print("\n" + "="*60)
    print("CURRENT MODEL INFO")
    print("="*60)
    print("Downloaded model: style_transfer_quant.tflite (2.7MB)")
    print("This is the Magenta Arbitrary Style Transfer model")
    print("It requires 2 inputs: content image + style image")
    print("\nTo use this model, we need to update the code to handle:")
    print("Input 0: Content image [1, 384, 384, 3]")
    print("Input 1: Style image [1, 256, 256, 3]")  
    print("Output: Styled image [1, 384, 384, 3]")

if __name__ == "__main__":
    create_simple_tflite_model()
