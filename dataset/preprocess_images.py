"""
Preprocessing Script for Palm Oil Fresh Fruit Bunch (FFB) Dataset
Converts raw RGB JPG/PNG images into 32x32 RGB BMP & INT8 hex arrays for Cyclone V FPGA verification.
"""

import os
import glob
import numpy as np
from PIL import Image

RAW_DIR = os.path.join(os.path.dirname(__file__), "sample_raw")
OUT_DIR = os.path.join(os.path.dirname(__file__), "processed_32x32")
os.makedirs(OUT_DIR, exist_ok=True)

def preprocess_dataset(target_size=(32, 32)):
    image_paths = sorted(glob.glob(os.path.join(RAW_DIR, "*.jpg")) + glob.glob(os.path.join(RAW_DIR, "*.png")))
    if not image_paths:
        print("No JPG/PNG images found in sample_raw/")
        return

    for img_path in image_paths:
        fname = os.path.splitext(os.path.basename(img_path))[0]
        img = Image.open(img_path).convert("RGB")
        img_resized = img.resize(target_size, Image.Resampling.BILINEAR)

        # Save 32x32 RGB BMP for hardware testbench verification
        bmp_path = os.path.join(OUT_DIR, f"{fname}.bmp")
        img_resized.save(bmp_path, format="BMP")

        # Convert [0, 255] uint8 RGB to [-128, 127] signed INT8
        arr_uint8 = np.array(img_resized, dtype=np.uint8)
        arr_int8 = (arr_uint8.astype(np.int16) - 128).astype(np.int8)

        hex_path = os.path.join(OUT_DIR, f"{fname}_rgb.hex")
        with open(hex_path, "w") as f:
            f.write(f"// 32x32x3 RGB INT8 Image Memory File: {fname}\n")
            for val in arr_int8.flatten():
                f.write(f"{int(val) & 0xFF:02x}\n")

        print(f"Processed {fname}: shape={arr_int8.shape}, saved BMP & HEX.")

if __name__ == "__main__":
    preprocess_dataset()
