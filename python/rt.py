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
    time.sleep(2)

    ser.write("1000000000000000".encode())
    time.sleep(.5)
    ser.write("0100000000000000".encode())
    time.sleep(.5)
    ser.write("0010000000000000".encode())
    time.sleep(.5)
    ser.write("0001000000000000".encode())
    time.sleep(.5)
    ser.write("0000100000000000".encode())
    time.sleep(.5)
    ser.write("0000010000000000".encode())
    time.sleep(.5)
    ser.write("0000001000000000".encode())
    time.sleep(.5)
    ser.write("0000000100000000".encode())
    time.sleep(.5)
    ser.write("0000000010000000".encode())
    time.sleep(.5)
    ser.write("0000000001000000".encode())
    time.sleep(.5)
    ser.write("0000000000100000".encode())
    time.sleep(.5)
    ser.write("0000000000010000".encode())
    time.sleep(.5)
    ser.write("0000000000001000".encode())
    time.sleep(.5)
    ser.write("0000000000000100".encode())
    time.sleep(.5)
    ser.write("0000000000000010".encode())
    time.sleep(.5)
    ser.write("0000000000000001".encode())
    time.sleep(.5)



