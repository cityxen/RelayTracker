# Relay Tracker

## Commodore 64 Version 2.0

All commands now working, VIC-Rel support added

This program allows you to program and playback a sequence of states for an 8 Channel relay board similar to a VIC-Rel for the Commodore 64. It may even work with a VIC-Rel, but can't test it. If someone has a VIC-Rel and would like to test it, please let us know if it works. The schematic for each device will be in the folder for that machine.

Here is a brief demo of what this looks like in operation during the early stages of development: https://www.youtube.com/watch?v=qtZTxJKP-fk

![C64Version](https://github.com/cityxen/RelayTracker/blob/master/commodore64/screenshots/relay_tracker-image-actual-v2.0-1-tn.png)

## Amiga Version

Started folder, working on some preliminary code to send 16 bit binary strings to the serial bridge

## Python Version pre-alpha

Added rt.py which sends a continuous stream of 16 bit binary strings to the serial bridge for testing

## Atari 800XL Version pre-alpha

Started folder, looking at how to get it started

## TI994A Version pre-alpha

Started folder, looking at how to get it started

## Serial Bridge (Raspberry Pi)

Python code for taking in serial input and converting it to GPIO up/down signals
Added bridge.py
