import numpy
import re
import string
INTLEN = 12
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