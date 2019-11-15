##########################################################################################
# CityXen 16 Relay Board Serial Bridge Program
# by Deadline
#
# NOTE: This is subject to heavy modification, especially the way it converts the signals
# so don't presume that the state it is in now is the way it will stay
#
# Raspberry Pi (Any model with 40 GPIO should work)
# https://amzn.to/34X5Xnj
#
# The Serial connector board is a MAX3232 based mini board with a 9 pin dsub 
# https://amzn.to/32G9Viv
# 
# Null modem required to work with Amiga serial port
# https://amzn.to/32BrHDC
#
# 8 Channel Relay Board
# https://amzn.to/2Xwerh4
#
# Prototype Wiring 
# https://amzn.to/2LHDNX9
#
# GPIO Pins used for the serial device
#
# Pin 6  Ground
# Pin 8  TXD
# Pin 10 RXD
# Pin 1  3 volt
#
# GPIO Pins used for the Relay Boards
#
# Relay Board 1
# Pin 2  5 volt VCC Relay Board 1
# Pin 9  Ground Relay Board 1
# Pin 12 Relay 1
# Pin 7  Relay 2
# Pin 11 Relay 3
# Pin 13 Relay 4
# Pin 15 Relay 5
# Pin 19 Relay 6
# Pin 21 Relay 7
# Pin 23 Relay 8
#
# Relay Board 2
# Pin 4  5 volt VCC Relay Board 2
# Pin 39 Ground Relay Board 2
# Pin 16 Relay 1
# Pin 18 Relay 2
# Pin 22 Relay 3
# Pin 40 Relay 4
# Pin 38 Relay 5
# Pin 36 Relay 6
# Pin 32 Relay 7
# Pin 37 Relay 8
#
##########################################################################################

import RPi.GPIO as GPIO
import time
import serial
import argparse

# Set up some variables
sb_version    = "1.0"
serial_device = "/dev/ttyAMA0"
serial_baud   = "19200"
encoding      = "DEFAULT"
init_test     = False
counter       = 0

print("CityXen Serial Bridge version %s" % (sb_version))
print("pass -h for help")

# Parse arguments
ap=argparse.ArgumentParser()
ap.add_argument("-s","--serial_device",required=False,help="Serial Device")
ap.add_argument("-e","--encoding",required=False,help="Encoding Method (Methods: DEFAULT or 16B)\nDEFAULT: 1-8 and q-i operate relays\n16B: 16 bit binary strings should be passed")
ap.add_argument("-b","--serial_baud",required=False,help="Serial Baud Rate")
ap.add_argument("-t","--init_test",required=False,help="Test all relays on startup")
args=vars(ap.parse_args())
if(args["serial_device"]):
    serial_device=args["serial_device"]
if(args["serial_baud"]):
    serial_baud = args["serial_baud"]
if(args["encoding"]):
    encoding    = args["encoding"]
if(args["init_test"]):
    init_test   = True if (args["init_test"]=="1") else False
print("Using "+serial_device+" at "+serial_baud+" baud and "+encoding+" encoding")

# Set up serial device
ser = serial.Serial(
    serial_device,
    serial_baud,
    parity=serial.PARITY_NONE,
    stopbits=serial.STOPBITS_ONE,
    bytesize=serial.EIGHTBITS,
    xonxoff=0,
    timeout=None,
    rtscts=0
)

# Set up a dictionary for GPIO pins used for the relay up/down states
gp = {12:False, 7:False,11:False,13:False,15:False,19:False,21:False,23:False,
      16:False,18:False,22:False,40:False,38:False,36:False,32:False,37:False}

# Set up GPIO device
GPIO.setwarnings(False) # Ignore some warnings
GPIO.setmode(GPIO.BOARD)
for i in gp:
    GPIO.setup(i, GPIO.OUT) # Set pins to out

# Define some functions
def set_gpio(): # Set the GPIO pins from dict values
    global gp
    for i in gp:
        GPIO.output(i,gp[i])

def all_on(): # Turn all dict values to on
    global gp
    for i in gp:
        gp[i]=False

def all_off(): # Turn all dict values to off
    global gp
    for i in gp:
        gp[i]=True

def test_sequence(): # Turn on and off all dict values and then set the GPIO pins
    global gp
    for i in gp:
        gp[i]=False
        set_gpio()
        time.sleep(.1)
        gp[i]=True
        set_gpio()

# Do or do not, there is no try...
if(init_test):
    print("Initialization Test")
    test_sequence() # Do a quick system test

# Turn off all GPIO pins
all_off()
set_gpio()

# Print out a ready message
ser.write(b'CityXen Serial Bridge now active\n\r')
print("CityXen Serial Bridge now active")

# Main program, check for encoding method then loop
if(encoding=="16B"):
    while True:
        x=ser.readline().lstrip('\x00').rstrip("\x00\n\r")

        if(len(x)):
            print("IN STRLEN:"+str(len(x))+":"+x)

        if(len(x)>15):
            gp[12]=False if x[0] =="1" else True
            gp[7] =False if x[1] =="1" else True
            gp[11]=False if x[2] =="1" else True
            gp[13]=False if x[3] =="1" else True
            gp[15]=False if x[4] =="1" else True
            gp[19]=False if x[5] =="1" else True
            gp[21]=False if x[6] =="1" else True
            gp[23]=False if x[7] =="1" else True
            gp[16]=False if x[8] =="1" else True
            gp[18]=False if x[9] =="1" else True
            gp[22]=False if x[10]=="1" else True
            gp[40]=False if x[11]=="1" else True
            gp[38]=False if x[12]=="1" else True
            gp[36]=False if x[13]=="1" else True
            gp[32]=False if x[14]=="1" else True
            gp[37]=False if x[15]=="1" else True
            set_gpio()

        counter=counter+1
        if counter > 1000:
            ser.write(b'16B BURmP\n\r')
            print("16B BURmP")
            counter=0

# Default Encoding method (1-8 and q-i)
if(encoding=="DEFAULT"):
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
            ser.write(b'DEFAULT BURmP\n\r')
            print("DEFAULT BURmP")
            counter=0

GPIO.cleanup()
