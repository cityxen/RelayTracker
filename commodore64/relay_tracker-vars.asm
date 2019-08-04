//////////////////////////////////////////////////////////////////////////
// Relay Tracker (VARS)
//
// Version: 1.1b
// Author: Deadline
//
// 2019 CityXen
//////////////////////////////////////////////////////////////////////////

// zero page vars
.const zp_pointer_lo  = $fb
.const zp_pointer_hi  = $fc

// disk vars
.var filename            = $4b8 // 16 bytes
.var filename_color      = $d8b8
.var filename_buffer     = $3fe0
.var filename_buffer_end = $3fd2
.var filename_cursor     = $3fd3
.var filename_length     = $3fd4
.var drive               = $3fd5
.var filename_save       = $3ff0 // - $802f

// track block (256 bytes)
.var track_block         = $4000 // - $40fe
.var track_block_length  = $41ff // track block total length
.var track_block_cursor  = $41fe // current track block cursor position
.const track_block_cursor_init = 0

// pattern (256 bytes x 2) + 1 byte for length
.var current_speed       = $41fd
.var pattern_cursor      = $41fc
.const pattern_cursor_init = 0
.const pattern_length    = $4100 // for each pattern (up to pattern_max), a byte will indicate what the length of the pattern will be
.var pattern_block_start = $4000
.var pattern_block_end   = $9fff
.const pattern_block_start_lo = $00
.const pattern_block_start_hi = $40
.const pattern_block_end_lo = $ff
.const pattern_block_end_hi = $9f
// .const pattern_block     = $fb
// .const pattern_block_lo  = $fb
// .const pattern_block_hi  = $fc
.const pattern_min       = $00
.const pattern_max       = $1e

// Joystick Control Mode
.var joystick_control_mode = $41fb
.const max_joystick_control_modes = $04
    // Joystick control modes: (ALL JOYSTICK FUNCS ARE ON PORT 2)
    // 0 = OFF: off
    // 1 = PLAY MODE: Joystick button plays
    // 2 = FREESTYLE MODE: Joystick directions toggle relays 1-4 directions + button toggle relays 5-8
    // 3 = TRACKER MODE: Joystick UP and DOWN control play of tracker
    // 4 = EDIT MODE: Directions move cursor on pattern editor, fire toggles relay bit