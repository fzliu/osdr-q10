import numpy as np
import re
import string
from mem import int2str
INTLEN = 12
a = np.load('data.npy')
#print(a[0].real)
#print(a[0].imag)



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
