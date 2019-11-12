import random
import time
import serial

serial_device="/dev/ttyUSB0"
serial_baud="57600"
ser = serial.Serial(serial_device,serial_baud,parity=serial.PARITY_NONE,stopbits=serial.STOPBITS_ONE,bytesize=serial.EIGHTBITS,xonxoff=0,timeout=.01,rtscts=0)
while True:
    bout=bin(random.randint(0,65535))[2:]
    bout=bout.zfill(16)
    ser.write(bout.encode())
    print(bout)
    time.sleep(.05)
