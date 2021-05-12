# -*- coding = utf-8 -*-
# @Time : 2021/5/12 18:54
# @Author : SBP
# @File : PictureProcessing.py
# @Software : PyCharm

from PIL import Image
import numpy as np
from matplotlib import pyplot as plt

Lenth, Width = 640, 480
BLACK = [0, 0, 0]
RED = [255, 0, 0]
WHITE = [255, 255, 255]


###################### Load Picture ##############################3
# LoadPicture
# Return Image and ImageRGB
def LoadPicture(path):
    ImageOrigial = Image.open(path)
    ImageRGB = Image.open(path).convert('RGB')
    return ImageOrigial, ImageRGB


# Picture2RGBarray
# Return ImageRGB Array
def Picture2RGBarray(path):
    ImageRGB = Image.open(path).convert('RGB')
    ImageRGB_Array = np.array(ImageRGB)
    return ImageRGB_Array


####################### Picture processing ###########################
# create a Background with only one color
def CreateBackGroundArray(color=BLACK, lenth=Lenth, width=Width):
    bufferAll = []
    for i in range(width):
        bufferRow = []
        for j in range(lenth):
            bufferRow.append(color)
        bufferAll.append(bufferRow)
    resultArray = np.array(bufferAll)
    return resultArray


# read a Background witch is designed
# read color whitch is not BLACK
# return edge of (!BLACK)
def ReadNOTblackcolor(ImageDatas, lenth=Lenth, width=Width):
    tempRGB = []
    for i in range(width):
        # tempPre = BLACK;
        tempRGBrow = [i]
        for j in range(lenth - 1):
            if (all(ImageDatas[i, j] == WHITE)) and (all(ImageDatas[i, j + 1] == BLACK)):
                tempRGBrow.append(j)
            if (all(ImageDatas[i, j] == BLACK)) and all(ImageDatas[i, j + 1] == WHITE):
                tempRGBrow.append((j - 1))
        if (len(tempRGBrow) > 1):
            tempRGB.append(tempRGBrow)
    return tempRGB


###################### Draw Picture ##################################


def DrawPicture(ImageDatas, form, lenth=Lenth, width=Width, save=True, show=True):
    if (form == 'PIL'):
        newImage = Image.new('RGB', (lenth, width))
        for i in range(width):
            for j in range(lenth):
                newImage.putpixel((j, i), tuple(ImageDatas[i, j]))
        if save:
            newImage.save('PIL.jpg')
        if show:
            newImage.show()
    if (form == 'plt'):
        plt.figure(1)
        plt.imshow(ImageDatas)
        plt.xticks([])
        plt.yticks([])
        if save:
            plt.savefig('plt.jpg')
        if show:
            plt.show()

######################### Test #################################
# pictureArray = Picture2RGBarray('./BLACK.jpg')
# print(pictureArray)
# print(pictureArray[30, 40])
# print(tuple(pictureArray[30,40]))

# imageArray = CreateBackGroundArray(color=BLACK, lenth=Lenth, width=Width)
# # print(imageArray)
# DrawPicture(imageArray, form='PIL', lenth=Lenth, width=Width, save=True, show=True)

# imageArray = Picture2RGBarray('./PIL.jpg')
# print(imageArray)
