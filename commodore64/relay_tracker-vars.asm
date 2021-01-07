//////////////////////////////////////////////////////////////////////////
// Relay Tracker (VARS)
//
// Version: 2.1
// Author: Deadline
//
// 2019 CityXen
//////////////////////////////////////////////////////////////////////////

// zero page vars
.const zp_pointer_lo         = $fb
.const zp_pointer_hi         = $fc
.const zp_temp               = $fd
.const zp_temp2              = $fa

// disk vars
.var filename                = $4b8 // 16 bytes
.var filename_color          = $d8b8
.var filename_buffer         = $3fe0
.var filename_buffer_end     = $3fd2
.var filename_cursor         = $3fd3
.var filename_length         = $3fd4
.var drive                   = $3fd5
.var filename_save           = $3ff0 // - $3fff

// playback data
.var playback_pos_track      = $41fa
.var playback_pos_pattern    = $41f9
.var playback_pos_pattern_c  = $41f8
.var playback_speed          = $41f7
.var playback_playing        = $41f6
.var playback_speed_counter  = $41f2
.var playback_speed_counter2 = $41f1
.const playback_default_speed= $1f

// track data
.const tracker_data_start    = $4000
.const tracker_data_start_hi = $40
.const tracker_data_start_lo = $00
.const tracker_data_end      = $9fff
.const tracker_data_end_hi   = $9f
.const tracker_data_end_lo   = $ff

// track block (256 bytes)
.var track_block             = $4000 // - $40ff
.var track_block_length      = $41ff // track block total length
.var track_block_cursor      = $41fe // current track block cursor position
.const track_block_cursor_init = 0

// pattern (256 bytes x 2) + 1 byte for length
.const current_speed         = $41fd
.const pattern_cursor        = $41fc
.const pattern_cursor_init   = 0
.const pattern_length        = $4100 // for each pattern (up to pattern_max), a byte will indicate what the length of the pattern will be
.const pattern_block_start   = $4200
.const pattern_block_start_lo= $00
.const pattern_block_start_hi= $42
.const pattern_min           = $00
.const pattern_max           = $1e

// command/data stuff
.const command_block_start     = $4300
.const command_block_start_lo  = $00
.const command_block_start_hi  = $43

// command = xx------
// data    = --xxxxxx
// current commands:
// ----- (Empty)
// SPEED (00-1f)
// STOP  (End playback)
// FLASH (00-1f)

// Joystick Control Mode
.var joystick_control_mode   = $41fb
.var jcm_edit_cursor_x       = $41f4
.var jcm_edit_cursor_y       = $41f3

.const max_joystick_control_modes = $01
    // Joystick control modes: (ALL JOYSTICK FUNCS ARE ON PORT 2)
    // 0 = OFF: off
    // 1 = PLAY: Joystick button plays
    // TODO:
    // 2 = SS: Fire toggles playback (start / stop)
    // 3 = FREE: Joystick directions toggle relays 1-4 directions + button toggle relays 5-8
    // 4 = TRAK: Joystick UP and DOWN control play of tracker
    // 5 = EDIT: Directions move cursor on pattern editor, fire toggles relay bit


// VIC-Rel Mode
.var vic_rel_mode            = $41f0