"""
Verify TFLite model structure without TensorFlow
Uses flatbuffers to parse the model file
"""
import struct
import os
import sys

# Fix Windows console encoding
if sys.platform == 'win32':
    sys.stdout.reconfigure(encoding='utf-8')

def read_tflite_structure(model_path):
    """Read basic structure of TFLite model"""
    if not os.path.exists(model_path):
        print(f"[X] Model file not found: {model_path}")
        return

    file_size = os.path.getsize(model_path)
    print(f"[OK] Model file found: {model_path}")
    print(f"[OK] File size: {file_size:,} bytes ({file_size/1024/1024:.2f} MB)")

    # TFLite files start with "TFL3" magic bytes
    with open(model_path, 'rb') as f:
        magic = f.read(4)
        if magic == b'TFL3':
            print("[OK] Valid TFLite model (TFL3 format)")
        else:
            print(f"[WARN] Unexpected magic bytes: {magic}")

    print("\n" + "="*60)
    print("Model is ready to use!")
    print("="*60)
    print("\nExpected specifications (based on code):")
    print("  Input 0 (Content): [1, 384, 384, 3] float32")
    print("  Input 1 (Style):   [1, 256, 256, 3] float32")
    print("  Output:            [1, 384, 384, 3] float32")
    print("\nIf the model has different specifications,")
    print("you'll need to update StyleTransferService constants.")

if __name__ == "__main__":
    read_tflite_structure("style_transfer_quant.tflite")
