# -*- coding = utf-8 -*-
# @Time : 2021/6/3 9:43
# @Author : SBP
# @File : makecolorTXT.py
# @Software : PyCharm

path = './coloredse.txt'
savepath = './color10se.txt'

datas = []
with open(path, "r") as f:
    for line in f.readlines():
        line = line.strip('\n')
        datas.append(line)
    f.close()

datasH = []
for i in range(len(datas)):
    data = datas[i]
    dataH = 'R['+str(i)+"]<=2560'd"+str(int(data,2))+';\n'
    datasH.append(dataH)

# print(datasH)

with open(savepath,'w') as f:
    f.writelines(datasH)