from glob import glob
from PIL import Image
from matplotlib import pyplot as plt
import numpy as np

data_dir = '/home/alec/FOUND/data/range_images_val/range'


for file in glob(data_dir+"/*.png"):
    print(file)
    with open(file, "rb") as f:
        img = Image.open(f)
        img = img.convert("F")
        img = np.array(img)
        #16 bit to 8 bit 40m max to 8m max.
        threshold = np.floor((2**16 - 1) / 5)
        img[img > threshold] = threshold
        img -= 2000
        img *= 255 / (threshold - 2000)
        img = np.floor(img)
        img = Image.fromarray(np.uint8(img))
    with open(file, 'wb') as f:
        img.save(f)


