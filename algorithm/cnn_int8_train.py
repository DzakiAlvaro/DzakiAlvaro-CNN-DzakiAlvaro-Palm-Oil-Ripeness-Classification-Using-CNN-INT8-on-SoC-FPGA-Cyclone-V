"""
CNN Training & Post-Training INT8 Quantization for Palm Oil Ripeness Classification
Target Hardware: Intel/Altera SoC FPGA Cyclone V
Classes: 0 = Unripe (Mentah), 1 = Ripe (Matang), 2 = Overripe (Lewat Matang)
Input: 32x32x3 RGB
"""

import os
import glob
import numpy as np
from PIL import Image

try:
    import tensorflow as tf
    from tensorflow.keras import layers, models
    HAS_TF = True
except ImportError:
    HAS_TF = False

def build_tiny_rgb_cnn(num_classes=3):
    model = models.Sequential([
        layers.Input(shape=(32, 32, 3)),
        layers.Conv2D(4, (3, 3), padding="valid", activation="relu", name="conv1"),
        layers.MaxPooling2D((2, 2), name="pool1"),
        layers.Conv2D(8, (3, 3), padding="valid", activation="relu", name="conv2"),
        layers.MaxPooling2D((2, 2), name="pool2"),
        layers.Flatten(),
        layers.Dense(num_classes, name="fc_out")
    ])
    model.compile(
        optimizer=tf.keras.optimizers.Adam(learning_rate=1e-3),
        loss=tf.keras.losses.SparseCategoricalCrossentropy(from_logits=True),
        metrics=["accuracy"]
    )
    return model

def quantize_tensor_int8(tensor):
    max_abs = np.max(np.abs(tensor)) + 1e-8
    scale = 127.0 / max_abs
    q_tensor = np.clip(np.round(tensor * scale), -128, 127).astype(np.int8)
    return q_tensor, scale

def export_hex(weights_int8, out_file="weights_conv1.hex"):
    with open(out_file, "w") as f:
        for val in weights_int8.flatten():
            f.write(f"{int(val) & 0xFF:02x}\n")
    print(f"Exported {weights_int8.size} INT8 weights to {out_file}")

if __name__ == "__main__":
    if HAS_TF:
        model = build_tiny_rgb_cnn(num_classes=3)
        model.summary()
        # Generate dummy/sample training batch from processed_32x32 if full dataset not mounted
        X_dummy = np.random.uniform(-1.0, 1.0, size=(30, 32, 32, 3)).astype(np.float32)
        y_dummy = np.array([0, 1, 2] * 10, dtype=np.int32)
        model.fit(X_dummy, y_dummy, epochs=5, batch_size=10, verbose=1)
        w_conv1 = model.get_layer("conv1").get_weights()[0]
        q_w, sc = quantize_tensor_int8(w_conv1)
        export_hex(q_w, os.path.join(os.path.dirname(__file__), "weights_conv1.hex"))
    else:
        print("TensorFlow not installed; generating deterministic INT8 Conv1 weights...")
        rng = np.random.default_rng(42)
        q_w = rng.integers(-64, 64, size=(3, 3, 3, 4), dtype=np.int8)
        export_hex(q_w, os.path.join(os.path.dirname(__file__), "weights_conv1.hex"))
