import tensorflow as tf

# Load the TFLite model
interpreter = tf.lite.Interpreter(model_path="style_transfer_quant.tflite")
interpreter.allocate_tensors()

# Get input details
input_details = interpreter.get_input_details()
print("=== INPUT DETAILS ===")
for i, detail in enumerate(input_details):
    print(f"\nInput {i}:")
    print(f"  Name: {detail['name']}")
    print(f"  Shape: {detail['shape']}")
    print(f"  Type: {detail['dtype']}")

# Get output details
output_details = interpreter.get_output_details()
print("\n=== OUTPUT DETAILS ===")
for i, detail in enumerate(output_details):
    print(f"\nOutput {i}:")
    print(f"  Name: {detail['name']}")
    print(f"  Shape: {detail['shape']}")
    print(f"  Type: {detail['dtype']}")
