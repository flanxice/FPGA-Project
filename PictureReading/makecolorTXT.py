# -*- coding = utf-8 -*-
# @Time : 2021/6/3 9:43
# @Author : SBP
# @File : makecolorTXT.py
# @Software : PyCharm

path = './coloredse.txt'
# savepath = './color10se.txt'

datas = []
data1 = []
data2 = []
data3 = []
data4 = []
with open(path, "r") as f:
    for line in f.readlines():
        line = line.strip('\n')
        line1 = line[0:-1:4]
        line2 = line[1:-1:4]
        line3 = line[2:-1:4]
        line4 = line[3:-1:4] + line[-1]
        datas.append(line)
        data1.append(line1)
        data2.append(line2)
        data3.append(line3)
        data4.append(line4)
    f.close()


datas1 = []
for i in range(len(data1)):
    data = data1[i]
    dataH = 'B1[' + str(i) + "]<=640'd" + str(int(data, 2)) + ';\n'
    datas1.append(dataH)

datas2 = []
for i in range(len(data2)):
    data = data2[i]
    dataH = 'B2[' + str(i) + "]<=640'd" + str(int(data, 2)) + ';\n'
    datas2.append(dataH)

datas3 = []
for i in range(len(data3)):
    data = data3[i]
    dataH = 'B3[' + str(i) + "]<=640'd" + str(int(data, 2)) + ';\n'
    datas3.append(dataH)

datas4 = []
for i in range(len(data4)):
    data = data4[i]
    dataH = 'B2[' + str(i) + "]<=640'd" + str(int(data, 2)) + ';\n'
    datas4.append(dataH)

# print(datasH)

with open('./B1.txt', 'w') as f:
    f.writelines(datas1)
with open('./B2.txt', 'w') as f:
    f.writelines(datas2)
with open('./B3.txt', 'w') as f:
    f.writelines(datas3)
with open('./B4.txt', 'w') as f:
    f.writelines(datas4)
