# Relay Tracker - Commodore 64 Version

Version: 2.0

Author: Deadline

Up to 256 Tracks

Up to 31 Patterns of 256 different states

Notes: If you're going to attempt to compile this, you'll need the Macros and Constants from https://github.com/cityxen/Commodore64_Programming repo

Relay Tracker Data is located from $4000 - $9fff

Commands:

D - change drive number (toggles between drives 08,09,10,11)

F - change filename (allows you to change the working filename)

$ - shows directory of current disk

S - saves data to filename on drive

L - loads data from filename from drive

E - Erase File

F1 - Moves Track Block Cursor UP

F3 - Moves Track Block Cursor DOWN

; - Changes Pattern for current track UP

: - Changes Pattern for current track DOWN

Cursor Down - Move Pattern Down

Cursor Up - Move Pattern Up

1-8 - Toggle relay

MINUS - Turn off all relays

PLUS - Turn on all relays

HOME - Move Pattern Cursor to TOP

CLR - Move Pattern Cursor to BOTTOM

F5 - Pattern Cursor Page UP

F7 - Pattern Cursor Page DOWN

F2 - Track Block Length DOWN

F4 - Track Block Length UP

J - Toggle Joystick Control Mode (JCM Modes: OFF,PLAY)
* OFF  = Joystick doesn't affect anything
* PLAY = While fire button is pressed, track will play

    (
        TODO: These functions do not work yet 

        SS,FREE,TRAK,EDIT
        
        SS   = Fire toggles playback (start / stop)
        FREE = Up,Down,Left,Right toggle relays 1-4 Fire+Up,Down,Left or Right, toggle relays 2-8
        TRAK = Up Move Pattern Cursor Up, Down Move Pattern Cursor Down
        EDIT = Move Joystick Cursor within Pattern area to move, Fire toggle relay bit
    )

N - Clear memory

C - Change Command (Current commands: SPEED, STOP)

** - Change Command Data Up (Command Data range is from 00-3F)

= - Change Command Data Down

SPACE - Play/Pause

V - VIC-Rel mode (On or Off)

