##########################################################################################
# CityXen 16 Relay Board Serial Bridge Program
# by Deadline
#
##########################################################################################
sb_version="1.0"

import RPi.GPIO as GPIO
import time
import serial
import sys

print("CityXen Serial Bridge version %s" % (sb_version))
print("USAGE: python bridge.py [serial_device (default is /dev/ttyAMA0)]")
print("EXAMPLE: python bridge.py /dev/ttyUSB0")

args=len(sys.argv)-1
scriptname=sys.argv[0]
parm1=sys.argv[1]

serial_device="/dev/ttyAMA0"
if(args==1):
    serial_device=parm1

print("Using %s" % (serial_device))
ser = serial.Serial(serial_device,19200,parity=serial.PARITY_NONE,stopbits=serial.STOPBITS_ONE,bytesize=serial.EIGHTBITS,xonxoff=0,timeout=.01,rtscts=0)
# Note the GPIO pins for the uart device are used for serial device
# Pin 6  Ground
# Pin 8  TXD
# Pin 10 RXD
# Pin 1  3 volt

GPIO.setwarnings(False) # Ignore some warnings
GPIO.setmode(GPIO.BOARD)

# Set up a dictionary for GPIO pins
gp = {7:False,11:False,13:False,15:False,19:False,21:False,23:False,12:False,16:False,18:False,22:False,40:False,38:False,36:False,32:False,37:False}

for i in gp:
    GPIO.setup(i, GPIO.OUT) # Set pins to out

def set_gpio():
    global gp
    for i in gp:
        GPIO.output(i,gp[i])

def all_on():
    global gp
    for i in gp:
        gp[i]=False

def all_off():
    global gp
    for i in gp:
        gp[i]=True

def test_sequence():
    global gp
    for i in gp:
        gp[i]=False
        set_gpio()
        time.sleep(.1)
        gp[i]=True
        set_gpio()

# Do a quick system test
all_on()
set_gpio()
time.sleep(1)
all_off()
set_gpio()
test_sequence()

ser.write(b'CityXen Serial Bridge now active\n\r')
print("CityXen Serial Bridge now active")

counter=0

while True:

    x=ser.readline()

    if x == '1':
        if gp[12] == False:
            gp[12]=True
        else:
            gp[12]=False

    if x == '2':
        if gp[7] == False:
            gp[7]=True
        else:
            gp[7]=False

    if x == '3':
        if gp[11] == False:
            gp[11]=True
        else:
            gp[11]=False

    if x == '4':
        if gp[13] == False:
            gp[13]=True
        else:
            gp[13]=False

    if x == '5':
        if gp[15] == False:
            gp[15]=True
        else:
            gp[15]=False

    if x == '6':
        if gp[19] == False:
            gp[19]=True
        else:
            gp[19]=False

    if x == '7':
        if gp[21] == False:
            gp[21]=True
        else:
            gp[21]=False

    if x == '8':
        if gp[23] == False:
            gp[23]=True
        else:
            gp[23]=False

    if x == 'q':
        if gp[16] == False:
            gp[16]=True
        else:
            gp[16]=False

    if x == 'w':
        if gp[18] == False:
            gp[18]=True
        else:
            gp[18]=False

    if x == 'e':
        if gp[22] == False:
            gp[22]=True
        else:
            gp[22]=False

    if x == 'r':
        if gp[40] == False:
            gp[40]=True
        else:
            gp[40]=False

    if x == 't':
        if gp[38] == False:
            gp[38]=True
        else:
            gp[38]=False

    if x == 'y':
        if gp[36] == False:
            gp[36]=True
        else:
            gp[36]=False

    if x == 'u':
        if gp[32] == False:
            gp[32]=True
        else:
            gp[32]=False

    if x == 'i':
        if gp[37] == False:
            gp[37]=True
        else:
            gp[37]=False

    set_gpio()

    counter=counter+1
    if counter > 1000:
        ser.write(b'BURmP\n\r')
        print("BURmP")
        counter=0


GPIO.cleanup()

