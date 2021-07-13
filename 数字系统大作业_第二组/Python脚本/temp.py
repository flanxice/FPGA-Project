# -*- coding = utf-8 -*-
# @Time : 2021/6/13 1:21
# @Author : SBP
# @File : temp.py
# @Software : PyCharm

from PIL import Image
import PictureProcessing as pic

path = "./menu1new.png"
ImageRGB_Array = pic.Picture2RGBarray(path)
print(ImageRGB_Array)
ImageRGB_Array16 = (ImageRGB_Array // 16)
print(ImageRGB_Array)
RGB01datas = pic.Get01Array16(ImageRGB_Array16)
# temp = []
# for item in RGB01datas:
#     temp.append(item[371:])
pic.SaveAsTxt(RGB01datas, path='./menu1new.txt')
pic.DrawPicture(ImageRGB_Array16 * 16)

# path = "./temp.txt"
# file = open(path, mode='w')
# for row in range(51, 101):
#     string = "datas[{}]".format(row)+" <= 190'd0\n"
#     file.write(string)
# file.close()
