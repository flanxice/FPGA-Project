# -*- coding = utf-8 -*-
# @Time : 2021/6/3 0:38
# @Author : SBP
# @File : colorPicProcess.py
# @Software : PyCharm

from PIL import Image
import numpy as np
from matplotlib import pyplot as plt
import PictureProcessing as PicPro

Lenth, Width = 640, 480
path = './coloredPicDatas/se.jpg'
imageArray = PicPro.Picture2RGBarray(path=path)
imageArray_16 = imageArray // 16
R = imageArray_16[:, :, 0]
G = imageArray_16[:, :, 1]
B = imageArray_16[:, :, 2]


def getbin(R):
    result = []
    for i in range(Width):
        row = []
        for j in range(Lenth):
            temp = bin(R[i, j])[2:].zfill(4)
            row.append(temp)
        result.append(row)
    return result


R01 = getbin(R)
G01 = getbin(G)
B01 = getbin(B)

print(R)
print(R01[0][0])
print(len(R01))
print(len(R01[0]))
savepath = './coloredse.txt'
PicPro.SaveAsTxtcolor(B01, path=savepath)
save10path = './colored10se.txt'


# PicPro.DrawPicture(ImageDatas=imageArrayrestore)
