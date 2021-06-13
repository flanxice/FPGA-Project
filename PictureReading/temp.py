# -*- coding = utf-8 -*-
# @Time : 2021/6/13 1:21
# @Author : SBP
# @File : temp.py
# @Software : PyCharm

from PIL import Image
import PictureProcessing as pic

path = "./menu3.jpg"
array = pic.CreateBackGroundArray(lenth=190, width=50)

pic.DrawPicture(array, form='PIL', lenth=190, width=50)
# path = "./temp.txt"
# file = open(path, mode='w')
# for row in range(51, 101):
#     string = "datas[{}]".format(row)+" <= 190'd0\n"
#     file.write(string)
# file.close()
