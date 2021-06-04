# -*- coding = utf-8 -*-
# @Time : 2021/6/3 23:27
# @Author : SBP
# @File : RGBalltest.py
# @Software : PyCharm

from PIL import Image
import numpy as np
from matplotlib import pyplot as plt

Imag = Image.open('./coloredPicDatas/se.jpg').convert('RGB')
Imagdatas = np.array(Imag)
Imagdatas_16 = Imagdatas // 16
Imagdatas_16list = Imagdatas_16.tolist()
Rdatas = Imagdatas_16[:, :, 0].tolist()
Gdatas = Imagdatas_16[:, :, 1].tolist()
Bdatas = Imagdatas_16[:, :, 2].tolist()

B0, B1, B2, B3 = [], [], [], []
for j in Bdatas:
    string0 = ""
    string1 = ""
    string2 = ""
    string3 = ""
    for i in j:
        string0 = string0 + bin(i)[2:].zfill(4)[0]
        string1 = string1 + bin(i)[2:].zfill(4)[1]
        string2 = string2 + bin(i)[2:].zfill(4)[2]
        string3 = string3 + bin(i)[2:].zfill(4)[3]
    B0.append(string0)
    B1.append(string1)
    B2.append(string2)
    B3.append(string3)

path0 = './coloredtxt/B0.txt'
path1 = './coloredtxt/B1.txt'
path2 = './coloredtxt/B2.txt'
path3 = './coloredtxt/B3.txt'

filetxt0 = open(path0, mode='w')
filetxt1 = open(path1, mode='w')
filetxt2 = open(path2, mode='w')
filetxt3 = open(path3, mode='w')

for j in range(480):
    string0 = "B0[{}] <= 640'h".format(j) + hex(int(B0[j], 2))[2:] + '\n'
    string1 = "B1[{}] <= 640'h".format(j) + hex(int(B1[j], 2))[2:] + '\n'
    string2 = "B2[{}] <= 640'h".format(j) + hex(int(B2[j], 2))[2:] + '\n'
    string3 = "B3[{}] <= 640'h".format(j) + hex(int(B3[j], 2))[2:] + '\n'
    # string0 = "R0[{}] <= 640'h".format(j) + R0[j] + '\n'
    # string1 = "R1[{}] <= 640'h".format(j) + R1[j] + '\n'
    # string2 = "R2[{}] <= 640'h".format(j) + R2[j] + '\n'
    # string3 = "R3[{}] <= 640'h".format(j) + R3[j] + '\n'
    filetxt0.write(string0)
    filetxt1.write(string1)
    filetxt2.write(string2)
    filetxt3.write(string3)
filetxt0.close()
filetxt1.close()
filetxt2.close()
filetxt3.close()
