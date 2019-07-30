//////////////////////////////////////////////////////////////////////////
// Relay Tracker (VARS)
// by Deadline
// (c)2019 CityXen
//////////////////////////////////////////////////////////////////////////

// disk vars
.var filename            = $4b8 // 16 bytes
.var filename_color      = $d8b8
.var filename_buffer     = $c000
.var filename_buffer_end = $c011
.var filename_cursor     = $c012
.var filename_length     = $c013
.var drive               = $c014
.var filename_save       = $c020 // - $802f

// track block (256 bytes)
.var track_block         = $4000 // - $40ff
.var track_block_cursor  = $c030
.const track_block_cursor_init = 0

// pattern (256 bytes x 3)
.var current_pattern     = $c016
.var current_speed       = $c017
.var pattern_cursor      = $c018
.const pattern_block_cursor_init = 0
.var pattern_block_start = $4100
.var pattern_block_end   = $9fff

