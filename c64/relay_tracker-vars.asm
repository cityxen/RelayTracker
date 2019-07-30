//////////////////////////////////////////////////////////////////////////
// Relay Tracker (VARS)
// by Deadline
// (c)2019 CityXen
//////////////////////////////////////////////////////////////////////////

// disk vars
.var filename         = $4b8 // 16 bytes
.var filename_color   = $d8b8
.var filename_buffer  = $8000
.var filename_buffer_end = $8011
.var filename_cursor  = $8012
.var filename_length  = $8013
.var drive            = $8014
.var filename_save    = $8020



// track data (16 tracks)
.const current_track   = $8014 
.const track_data      = $8015 //

// pattern (255 length)
.const current_pattern = $8016
.const current_speed   = $8017
.const pattern_cursor  = $8018

