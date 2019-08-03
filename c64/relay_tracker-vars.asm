//////////////////////////////////////////////////////////////////////////
// Relay Tracker (VARS)
// by Deadline
// (c)2019 CityXen
//////////////////////////////////////////////////////////////////////////

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
.var track_block_length  = $40ff
.var track_block_cursor  = $3fd6
.const track_block_cursor_init = 0

// pattern (256 bytes x 3)
.var current_pattern     = $3fd7
.var current_speed       = $3fd8
.var pattern_cursor      = $3fd9
.const pattern_cursor_init = 0
.var pattern_block_start = $4100
.const pattern_block     = $fb
.const pattern_block_lo  = $fb
.const pattern_block_hi  = $fc
.const pattern_min       = $00
.const pattern_max       = $1f



// .var pattern_block       = pattern_block_start
.var pattern_block_end   = $9fff

