#!/usr/bin/python
import os
filename = 'tmon3.h'
f = open(filename, "r")
lines = f.readlines()
f.close()
os.remove(filename)

f = open(filename, "w")
guard = '#ifndef TMON3_H\n#define TMON3_H\n'
f.write(guard)
for i in lines:
    num = int(i.strip('\n').split('=')[2])
    nums = '{:04X}'.format(num)
    outline = i.split('=')[1] + ' = $' + nums + '\n'
    f.write(outline)
f.write('#endif\n')
f.flush()
f.close()
