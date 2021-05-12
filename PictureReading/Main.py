# -*- coding = utf-8 -*-
# @Time : 2021/5/12 21:12
# @Author : SBP
# @File : Main.py
# @Software : PyCharm


from PIL import Image
import numpy as np
from matplotlib import pyplot as plt
import PictureProcessing as PicPro

Lenth, Width = 640, 480
BLACK = [0, 0, 0]
RED = [255, 0, 0]

if __name__ == '__main__':
    path = './Menu.jpg'
    imageArray = PicPro.Picture2RGBarray(path=path)
    # print(imageArray)
    # PicPro.DrawPicture(imageArray, form='plt')
    RGB = PicPro.ReadNOTblackcolor(imageArray)
    print(RGB)
    print(len(RGB))
