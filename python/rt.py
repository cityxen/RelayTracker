import random
import time
import serial

serial_device="/dev/ttyUSB0"
serial_baud="57600"
ser = serial.Serial(serial_device,serial_baud,parity=serial.PARITY_NONE,stopbits=serial.STOPBITS_ONE,bytesize=serial.EIGHTBITS,xonxoff=0,timeout=.01,rtscts=0)

def swrite(x,t):
    ser.write(x.encode())
    print(x)
    time.sleep(t)

while True:
    bout=bin(random.randint(0,65535))[2:]
    bout=bout.zfill(16)
    swrite(bout,2)
    spd=.3
    swrite("1000000000000000",spd)
    swrite("0100000000000000",spd)
    swrite("0010000000000000",spd)
    swrite("0001000000000000",spd)
    swrite("0000100000000000",spd)
    swrite("0000010000000000",spd)
    swrite("0000001000000000",spd)
    swrite("0000000100000000",spd)
    swrite("0000000010000000",spd)
    swrite("0000000001000000",spd)
    swrite("0000000000100000",spd)
    swrite("0000000000010000",spd)
    swrite("0000000000001000",spd)
    swrite("0000000000000100",spd)
    swrite("0000000000000010",spd)
    swrite("0000000000000001",spd)




