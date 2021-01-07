# CLICK-A-TRON (Raspberry Pi Serial Bridge)


![CLICK-A-TRON-1](https://raw.githubusercontent.com/cityxen/RelayTracker/master/click-a-tron/images/click-a-tron-1.jpg)
![CLICK-A-TRON-2](https://raw.githubusercontent.com/cityxen/RelayTracker/master/click-a-tron/images/click-a-tron-2.jpg)

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

The CLICK-A-TRON was designed and used for the Christmas 2019 video on our YouTube channel. The housing was built later.

https://www.youtube.com/watch?v=SHh5UJvnV2c





