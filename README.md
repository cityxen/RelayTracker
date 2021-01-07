# Relay Tracker

## Commodore 64 Version 2.1

All commands now working, VIC-Rel support added. v2.1 fixes vicrel mode corruption bug on load.

This program allows you to program and playback a sequence of states for an 8 Channel relay board similar to a VIC-Rel for the Commodore 64. It does work with the VIC-Rel (Thanks to Saj Tron for testing it). The schematic for each device will be in the folder for that machine.

Here is a brief demo of what this looks like in operation during the early stages of development: https://www.youtube.com/watch?v=qtZTxJKP-fk

![C64Version](https://github.com/cityxen/RelayTracker/blob/master/commodore64/screenshots/relay_tracker-image-actual-v2.0-1-tn.png)

## Amiga Version

Serial program made with SASC to send 16 bit binary strings to the serial bridge.
Will now read in a text file of 16 bit binary strings and transfer to serial.
rt2.c

## Python Version pre-alpha

Added rt.py which sends a continuous stream of 16 bit binary strings to the serial bridge for testing

## Atari 800XL Version pre-alpha

Started folder, looking at how to get it started

## TI994A Version pre-alpha

Started folder, looking at how to get it started

## Serial Bridge (Raspberry Pi)

Python code for taking in serial input and converting it to GPIO up/down signals
Added bridge.py
