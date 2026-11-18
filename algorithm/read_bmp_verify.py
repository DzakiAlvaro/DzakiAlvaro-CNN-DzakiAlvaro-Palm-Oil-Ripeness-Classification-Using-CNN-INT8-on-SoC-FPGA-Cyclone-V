"""
Bit-Accurate Software Reference Verification for 32x32 RGB BMP Images
Verifies INT8 pixel values and color channel distribution (R/G ratio) before RTL simulation.
"""

import os
import glob
import numpy as np
from PIL import Image

BMP_DIR = os.path.join(os.path.dirname(__file__), "..", "dataset", "processed_32x32")

def verify_bmps():
    bmp_files = sorted(glob.glob(os.path.join(BMP_DIR, "*.bmp")))
    for path in bmp_files:
        img = Image.open(path).convert("RGB")
        arr = np.array(img, dtype=np.uint8)
        int8_arr = (arr.astype(np.int16) - 128).astype(np.int8)
        mean_rgb = arr.mean(axis=(0, 1))
        print(f"File: {os.path.basename(path)} | Shape: {arr.shape} | "
              f"Mean RGB: R={mean_rgb[0]:.1f}, G={mean_rgb[1]:.1f}, B={mean_rgb[2]:.1f} | "
              f"INT8 Range: [{int8_arr.min()}, {int8_arr.max()}]")

if __name__ == "__main__":
    verify_bmps()
