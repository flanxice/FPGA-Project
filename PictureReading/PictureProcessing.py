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
                tempRGBrow.append(j + 1)
        if (len(tempRGBrow) > 1):
            tempRGB.append(tempRGBrow)
    return tempRGB


# read a Background witch is designed
# read color whitch is not BLACK
# return x,y of (!BLACK)
def ReadNOTblackcolorall(ImageDatas, lenth=Lenth, width=Width):
    tempRGB = []
    for i in range(width):
        # tempPre = BLACK;
        tempRGBrow = [i]
        for j in range(lenth):
            if (all(ImageDatas[i, j] == WHITE)):
                tempRGBrow.append(j)
        if (len(tempRGBrow) > 1):
            tempRGB.append(tempRGBrow)
    return tempRGB


# deal with tempRGB(!BLACK)
# return edge
def getedge(RGBall):
    RGBedge = []
    for i in range(len(RGBall)):
        temprow = RGBall[i]
        need = temprow[0:2]
        for j in range(len(temprow)):
            if (j > 1 and j < (len(temprow) - 1)):
                if (temprow[j] != (temprow[j - 1] + 1)):
                    need.append('Start')
                    need.append(temprow[j])
                elif (temprow[j] != (temprow[j + 1] - 1)):
                    need.append('End')
                    need.append(temprow[j])
        need.append(temprow[-1])
        RGBedge.append(need)
    return RGBedge


# read (!black) RGB to 1
def Get01Array(ImageDatas, lenth=Lenth, width=Width):
    RGBdatas = []
    for i in range(width):
        RGBrow = []
        for j in range(lenth):
            if (list(ImageDatas[i, j]) == WHITE):
                RGBrow.append(1)
            else:
                RGBrow.append(0)
        RGBdatas.append(RGBrow)
    return RGBdatas


# input 1 or 0
# return pixel [a,b,c]
def GetRGB1pixel(RGB01):
    if (RGB01 == 1):
        return WHITE
    elif (RGB01 == 0):
        return BLACK


###################### Draw Picture ##################################
def DrawPicture(ImageDatas, form='PIL', lenth=Lenth, width=Width, save=True, show=True):
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


# draw picture with RGB01
def DrawPictureRGB01(RGB01, lenth=Lenth, width=Width, save=True, show=True):
    newImage = Image.new('RGB', (lenth, width))
    for i in range(width):
        for j in range(lenth):
            RGB = GetRGB1pixel(RGB01[i][j])
            newImage.putpixel((j, i), tuple(RGB))
    if save:
        newImage.save('RGB01.jpg')
    if show:
        newImage.show()


########################## Save as Txt #########################
def SaveAsTxt(RGB01, lenth=Lenth, width=Width):
    filetxt = open('RGB01.txt', mode='w')
    for j in RGB01:
        str = ''
        for i in j:
            str = str + '{}'.format(i)
        filetxt.write(str)
        filetxt.write('\n')
    filetxt.close()

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
