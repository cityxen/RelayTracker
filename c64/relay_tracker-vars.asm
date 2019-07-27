//////////////////////////////////////////////////////////////////////////
// Relay Tracker (VARS)
// by Deadline
// (c)2019 CityXen
//////////////////////////////////////////////////////////////////////////

// disk vars
.const filename         = $4b8 // 15 bytes
.const filename_color   = $d8b8
.const filename_buffer  = $8000
.const filename_cursor  = $8011
.const drive            = $8013



// track data (16 tracks)
.const current_track   = $8014 
.const track_data      = $8015 //

// pattern (255 length)
.const current_pattern = $8016
.const current_speed   = $8017
.const pattern_cursor  = $8018

