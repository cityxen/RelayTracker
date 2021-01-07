

get_bin = lambda x: format(x, 'b')
binary = lambda n: '' if n==0 else binary(n/2) + str(n%2)

print("TEST")
f=open("t1","rb")
fileout=open("test1-moon-hydrogen.rtd","wt")
pos=0
skiplines=0
while True:
    f1=f.read(1)
    if not f1:
        break
    if pos == 0:
        pos += 1
        f2=f1
    else:
        skiplines += 1
        if skiplines > 20:
            skiplines = 0
            pos=0
            #print("%d %d " %(ord(f1), ord(f2)))
            f3=(ord(f1)*256)+ord(f2)
            #print(f3)
            #for bytex in f3:
            x=(bin(f3)[2:].zfill(16))
            #print(x)
            fileout.write("%s\n" %(x))
            #wtf=bin(f3)[2:]
            # print(wtf)
            #print("{0:b}".format(ord(f1)))
            #print("{0:b}".format(ord(f2)))

f.close()
fileout.close()

