import numpy as np
import re
import string
from mem import int2str
INTLEN = 12
a = np.load('data.npy')
#print(a[0].real)
#print(a[0].imag)


def int2str(i):
    a = bin(i)
    num = re.sub(r'0b', "", a)
    if (int(num, 2) < 0):
        num = re.sub(r'-', "0", num.zfill(INTLEN-1))
        j = 0
        l = list(num)
        while (j < INTLEN-1):
            if (num[j] == "0"):
                l[j] = "1"
            else:
                l[j] = "0"
            j += 1
        num = ''.join(l)
        num = bin(int(num, 2) + 1)
        num = re.sub(r'0b', "", num)
        num = num.rjust(INTLEN, "1")
    else:
        num = '0' + num.zfill(INTLEN-1)
    return num

'''
mem_a = []
i0 = 0;
i1 = 0;
mem_a_16 = []
with open("a.txt") as f:
    mem_a = f.readlines()
while (i0 < 1279):
    mem_a_16.append(int2str(int(mem_a[i0])))
    i0 += 1
while (i1 < 1279):
    with open("mem_a_16.txt", "a") as f0:
        f0.write(mem_a_16[i1] + "\n")
        f0.close()
    i1 += 1
'''


#for i0 in a:
with open("mem_a" + str(0) + ".txt", "a") as f0:
    i = 0
    for i1 in a[0].real:
        f0.write(int2str(int(a[0].real[i])) + "\n")
        f0.write(int2str(int(a[1].real[i])) + "\n")
        i += 1
    f0.close()
with open("mem_a" + str(1) + ".txt", "a") as f0:
    i = 0
    for i1 in a[0].real:
        f0.write(int2str(int(a[0].imag[i])) + "\n")
        f0.write(int2str(int(a[1].imag[i])) + "\n")
        i += 1
    f0.close()
with open("mem_b" + str(0) + ".txt", "a") as f0:
    i = 0
    for i1 in a[0].real:
        f0.write(int2str(int(a[2].real[i])) + "\n")
        f0.write(int2str(int(a[3].real[i])) + "\n")
        i += 1
    f0.close()
with open("mem_b" + str(1) + ".txt", "a") as f0:
    i = 0
    for i1 in a[0].real:
        f0.write(int2str(int(a[2].imag[i])) + "\n")
        f0.write(int2str(int(a[3].imag[i])) + "\n")
        i += 1
    f0.close()
    '''with open("mem_" + str(i) + "_b.txt", "a") as f1:
        for i2 in a[i].imag:
            f1.write(int2str(int(i2)) + "\n")
        f1.close()'''
#i += 1
