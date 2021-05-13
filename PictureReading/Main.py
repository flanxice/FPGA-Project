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
    # RGB1 = PicPro.ReadNOTblackcolor(imageArray)
    # print(RGB1)
    # print(len(RGB1))
    RGB = PicPro.ReadNOTblackcolorall(imageArray)
    print(RGB)
    print(len(RGB))
    # RGBedge = PicPro.getedge(RGB)
    # print(RGBedge)
    # print(len(RGBedge))
    RGBdatas = PicPro.Get01Array(imageArray)
    print(RGBdatas)
    print('width = {}'.format(len(RGBdatas)))
    print('length = {}'.format(len(RGBdatas[0])))
    # RGBdatasArray = np.array(RGBdatas)
    # print(RGBdatasArray)
    # RGBdatasArray.tofile("RGB.bin")
    PicPro.SaveAsTxt(RGBdatas)
    PicPro.DrawPictureRGB01(RGBdatas)
