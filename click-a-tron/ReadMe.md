# CLICK-A-TRON (Raspberry Pi Serial Bridge)

This is a python script that runs when the Raspberry Pi boots.

It listens on the serial port at 9600 baud for 16 character strings of 1 and 0.

Example:
```
1110000101010001
0000000000000001
```

Usage:
```
python bridge.py -b 9600 -t 1 -e 16B
python bridge.py -b 19200 -t 1 -e 16B
```



