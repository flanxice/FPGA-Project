# -*- coding = utf-8 -*-
# @Time : 2021/5/30 23:23
# @Author : SBP
# @File : makeTXT.py
# @Software : PyCharm

path = 'RGB01.txt'

datas = []
with open(path, "r") as f:
    for line in f.readlines():
        line = line.strip('\n')
        datas.append(line)
    f.close()

datasH = []
for i in range(len(datas)):
    data = datas[i]
    dataH = 'data['+str(i)+"]<=640'd"+str(int(data,2))+';\n'
    datasH.append(dataH)

# print(datasH)

savepath = 'RGB01data.txt'
with open(savepath,'w') as f:
    f.writelines(datasH)


