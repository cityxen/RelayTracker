//////////////////////////////////////////////////////////////////////////
// Relay Tracker Version: 2.3
// Author: Deadline
// 2019-2021 CityXen
//
// As seen on our youtube channel:
// https://www.youtube.com/CityXen
//
// Assembly files are for use with KickAssembler
// http://theweb.dk/KickAssembler
//
// Notes: If you're going to attempt to compile this, you'll
// need the Macros and Constants from this repo:
// https://github.com/cityxen/Commodore64_Programming
//
// How To setup KickAssembler in Windows 10:
// https://www.youtube.com/watch?v=R9VE2U_p060
//
//////////////////////////////////////////////////////////////////////////

.segment Code []
.file [name="relaytracker.prg",segments="Code"]
.disk [filename="relaytracker.d64", name="RELAYTRACKER", id="CXN19" ] { [name="RELAYTRACKER", type="prg",  segments="Code"] }

*=$2f52 "constants"
#import "../../Commodore64_Programming/include/Constants.asm"
#import "../../Commodore64_Programming/include/Macros.asm"
#import "../../Commodore64_Programming/include/PrintSubRoutines.asm"
#import "relay_tracker-vars.asm"

*=$3000 "customfont"
#import "relay_tracker-charset.asm"
*=$3800 "screendata"
#import "relay_tracker-screen.asm"

//////////////////////////////////////////////////////////
// START OF PROGRAM
*=$0801 "BASIC"
    BasicUpstart($080d)

*=$080d "Program"

    lda #$01
    sta 54

    sei
    lda #<irq
    ldx #>irq
    sta $314
    stx $315
    cli

    lda VIC_MEM_POINTERS // point to the new characters
    ora #$0c
    sta VIC_MEM_POINTERS
    jsr initialize
    jsr draw_screen

    jmp mainloop

////////////////////////////////////////////////////
// IRQ
irq:
    jmp $ea31

//////////////////////////////////////////////////////////
// START OF MAIN LOOP
mainloop:
//////////////////////////////////////////////////////////
// Joystick Control Mode
    jsr joystick_control_mode_check
//////////////////////////////////////////////////////////
// Playback if it is on
    jsr playback
//////////////////////////////////////////////////////////
// Draw Playback Status
    jsr draw_playback_status
//////////////////////////////////////////////////////////
// CHECK KEYBOARD FOR KEY HITS
    jsr KERNAL_GETIN
//////////////////////////////////////////////////////////
// SPACE (PLAY/PAUSE)
check_space_hit:
    cmp #$20
    bne check_dollar_hit
    clc
    lda playback_playing
    cmp #$01
    beq chk_spc_hit2
    inc playback_playing
    jmp mainloop
chk_spc_hit2:
    lda #$00
    sta playback_playing
    jmp mainloop
//////////////////////////////////////////////////////////
// $ (Show Directory)
check_dollar_hit:
    cmp #$24
    bne check_c_hit
    jsr show_directory
    jsr draw_screen
    jmp mainloop
//////////////////////////////////////////////////////////
// C (Change Command)
check_c_hit:
    cmp #$43
    bne check_d_hit
    jsr change_command
    jsr refresh_pattern
    jmp mainloop
//////////////////////////////////////////////////
// D (Change Drive)
check_d_hit:
    cmp #$44
    bne check_e_hit
    jsr change_drive
    jmp mainloop
//////////////////////////////////////////////////
// E (Erase File)
check_e_hit:
    cmp #$45
    bne check_f_hit
    jsr erase_file_confirm
    jsr draw_screen
    jmp mainloop
//////////////////////////////////////////////////
// F (Change Filename)
check_f_hit:
    cmp #$46
    bne check_j_hit
    jsr change_filename
    jmp mainloop
//////////////////////////////////////////////////
// J (Toggle Joystick Control Mode)
check_j_hit:
    cmp #$4a
    bne check_l_hit
    clc
    lda joystick_control_mode
    cmp #max_joystick_control_modes
    beq chk_j_wut
    inc joystick_control_mode
    jmp chk_j_done
chk_j_wut:
    lda #$00
    sta joystick_control_mode
chk_j_done:
    jsr draw_jcm
    jmp mainloop
//////////////////////////////////////////////////
// L (Load File)
check_l_hit:
    cmp #$4c
    bne check_n_hit
    jsr load_file
    jsr draw_screen
    jmp mainloop
//////////////////////////////////////////////////
// N (New Data)
check_n_hit:
    cmp #$4e
    bne check_s_hit
    jsr new_data_confirm
    jsr draw_screen
    jmp mainloop
//////////////////////////////////////////////////
// S (Save File)
check_s_hit:
    cmp #$53
    bne check_v_hit
    jsr save_file
    jsr draw_screen
    jmp mainloop
//////////////////////////////////////////////////
// V (Toggle VIC-Rel mode)
check_v_hit:
    cmp #$56
    bne check_colon_hit
    inc vic_rel_mode
    lda vic_rel_mode
    cmp #$02
    bne v_mode_ok
    lda #$00
    sta vic_rel_mode
v_mode_ok:
    clc
    lda vic_rel_mode
    adc #48
    sta $44a
    jsr draw_screen
    jsr draw_current_relays
    jmp mainloop
//////////////////////////////////////////////////
// COLON (Change Pattern DOWN)
check_colon_hit:
    cmp #58
    bne check_semicolon_hit
    ldx track_block_cursor
    lda track_block,x
    cmp #pattern_min
    beq check_colon_nope
    dec track_block,x
check_colon_nope:
    jsr refresh_track_blocks
    jsr calculate_pattern_block
    jsr refresh_pattern
    jsr draw_current_relays
    jmp mainloop
//////////////////////////////////////////////////
// SEMICOLON (Change Pattern UP)
check_semicolon_hit:
    cmp #59
    bne check_1_hit
    ldx track_block_cursor
    lda track_block,x
    cmp #pattern_max
    beq check_semicolon_nope
    inc track_block,x
check_semicolon_nope:
    jsr refresh_track_blocks
    jsr calculate_pattern_block
    jsr refresh_pattern
    jsr draw_current_relays
    jmp mainloop
//////////////////////////////////////////////////
// 1 (Set Relay 1)
check_1_hit:
    cmp #$31
    bne check_2_hit
    jsr toggle_relay_1
    jmp mainloop
//////////////////////////////////////////////////
// 2 (Set Relay 2)
check_2_hit:
    cmp #$32
    bne check_3_hit
    jsr toggle_relay_2
    jmp mainloop
//////////////////////////////////////////////////
// 3 (Set Relay 3)
check_3_hit:
    cmp #$33
    bne check_4_hit
    jsr toggle_relay_3
    jmp mainloop
//////////////////////////////////////////////////
// 4 (Set Relay 4)
check_4_hit:
    cmp #$34
    bne check_5_hit
    jsr toggle_relay_4
    jmp mainloop
//////////////////////////////////////////////////
// 5 (Set Relay 5)
check_5_hit:
    cmp #$35
    bne check_6_hit
    jsr toggle_relay_5
    jmp mainloop
//////////////////////////////////////////////////
// 6 (Set Relay 6)
check_6_hit:
    cmp #$36
    bne check_7_hit
    jsr toggle_relay_6
    jmp mainloop
//////////////////////////////////////////////////
// 7 (Set Relay 7)
check_7_hit:
    cmp #$37
    bne check_8_hit
    jsr toggle_relay_7
    jmp mainloop
//////////////////////////////////////////////////
// 8 (Set Relay 8)
check_8_hit:
    cmp #$38
    bne check_minus_hit
    jsr toggle_relay_8
    jmp mainloop
//////////////////////////////////////////////////
// MINUS (Turn OFF all relays)
check_minus_hit:
    cmp #$2d
    bne check_plus_hit
    jsr all_relay_off
    jmp mainloop
//////////////////////////////////////////////////
// PLUS (Turn ON all relays)
check_plus_hit:
    cmp #$2b
    bne check_equal_hit
    jsr all_relay_on
    jmp mainloop
//////////////////////////////////////////////////
// EQUAL (Change Command Value DOWN)
check_equal_hit:
    cmp #$3d
    bne check_star_hit
    jsr change_command_data_down
    jsr refresh_pattern
    jmp mainloop
//////////////////////////////////////////////////
// STAR (Change Command Value UP)
check_star_hit:
    cmp #$2a
    bne check_f1_hit
    jsr change_command_data_up
    jsr refresh_pattern
    jmp mainloop
//////////////////////////////////////////////////
// F1 (Move Track Position UP)
check_f1_hit:
    cmp #$85
    bne check_f2_hit
    lda track_block_cursor
    cmp #$00
    beq check_f1_hit_too_high
    dec track_block_cursor
    jsr refresh_track_blocks
    jsr calculate_pattern_block
    jsr refresh_pattern
    jsr draw_current_relays
check_f1_hit_too_high:
    jmp mainloop
//////////////////////////////////////////////////
// F2 (Track Length DOWN)
check_f2_hit:
    cmp #$89
    bne check_f3_hit
    lda track_block_length
    cmp #$00
    beq chk_f2_nope
    dec track_block_length
    lda track_block_length
    sta track_block_cursor
chk_f2_nope:
    lda #$00
    sta pattern_cursor
    jsr calculate_pattern_block
    jsr refresh_track_blocks
    jsr refresh_pattern
    jsr draw_current_relays
    jmp mainloop
//////////////////////////////////////////////////
// F3 (Move Track Position DOWN)
check_f3_hit:
    cmp #$86
    bne check_f4_hit
    lda track_block_cursor
    cmp track_block_length
    beq check_f3_hit_too_low
    inc track_block_cursor
    jsr refresh_track_blocks
    jsr calculate_pattern_block
    jsr refresh_pattern
    jsr draw_current_relays
check_f3_hit_too_low:
    jmp mainloop
//////////////////////////////////////////////////
// F4 (Track Length UP)
check_f4_hit:
    cmp #$8a
    bne check_f5_hit
    lda track_block_length
    cmp #$ff
    beq chk_f4_nope
    inc track_block_length
    lda track_block_length
    sta track_block_cursor
chk_f4_nope:
    lda #$00
    sta pattern_cursor
    jsr calculate_pattern_block
    jsr refresh_track_blocks
    jsr refresh_pattern
    jsr draw_current_relays
    jmp mainloop
//////////////////////////////////////////////////
// F5 (Page UP in current Pattern)
check_f5_hit:
    cmp #$87
    bne check_f6_hit
    clc
    lda pattern_cursor
    sbc #$05
    bcs c_f5_1
    lda #$00
c_f5_1:
    sta pattern_cursor
    jsr calculate_pattern_block
    jsr refresh_pattern
    jsr draw_current_relays
    jmp mainloop
//////////////////////////////////////////////////
// F6
check_f6_hit:
    cmp #$8b
    bne check_f7_hit
    jmp mainloop
//////////////////////////////////////////////////
// F7 (Page DOWN in current Pattern)
check_f7_hit:
    cmp #$88
    bne check_f8_hit
    clc
    lda pattern_cursor
    adc #$05
    bcc c_f7_1
    lda #$ff
c_f7_1:
    sta pattern_cursor
    jsr calculate_pattern_block
    jsr refresh_pattern
    jsr draw_current_relays
    jmp mainloop
//////////////////////////////////////////////////
// F8
check_f8_hit:
    cmp #$89
    bne check_cursor_up_hit
    jmp mainloop
//////////////////////////////////////////////////
// Cursor UP (Move down one position in current pattern)
check_cursor_up_hit:
    cmp #$11
    bne check_cursor_down_hit
    lda pattern_cursor
    cmp #$ff
    beq check_pattern_too_low
    inc pattern_cursor
    jsr calculate_pattern_block
    jsr refresh_pattern
    jsr draw_current_relays
check_pattern_too_low:
    jmp mainloop
//////////////////////////////////////////////////
// Cursor DOWN (Move up one position in current pattern)
check_cursor_down_hit:
    cmp #$91
    bne check_home_hit
    lda pattern_cursor
    cmp #$00
    beq check_pattern_too_high
    dec pattern_cursor
    jsr calculate_pattern_block
    jsr refresh_pattern
    jsr draw_current_relays
check_pattern_too_high:
    jmp mainloop
//////////////////////////////////////////////////
// HOME (Move to top position in current pattern)
check_home_hit:
    cmp #$13
    bne check_clr_hit
    lda #$00
    sta pattern_cursor
    jsr calculate_pattern_block
    jsr refresh_pattern
    jsr draw_current_relays
    jmp mainloop
//////////////////////////////////////////////////
// CLR (Move to end position in current pattern)
check_clr_hit:
    cmp #$93
    bne check_keys_done
    lda #$ff
    sta pattern_cursor
    jsr calculate_pattern_block
    jsr refresh_pattern
    jsr draw_current_relays
check_keys_done:
    jmp mainloop
// END OF MAIN LOOP
////////////////////////////////////////////////////

////////////////////////////////////////////////////
// Joystick Control Mode
joystick_control_mode_check:
    clc
    lda joystick_control_mode
    cmp #$00
    bne jcm_mode_on
    rts
jcm_mode_on:
    cmp #$01
    bne jcm_not_play
    lda JOYSTICK_PORT_2
    jsr sub_read_joystick_2_fire
	cmp #$01
    bne jcm_play_off
    lda #$01
    sta playback_playing
    rts
jcm_play_off:
    lda #$00
    sta playback_playing
    rts

jcm_not_play:
    rts

sub_read_joystick_2_fire:
	lda JOYSTICK_PORT_2
	lsr
	lsr
	lsr
	lsr
	lsr
	bcc read_joystick_2_fire
	lda #$00
	rts
read_joystick_2_fire:
	lda #$01
	rts

////////////////////////////////////////////////////
// Change Command UP
change_command_data_up:
    jsr calculate_pattern_block
    inc zp_pointer_hi
    ldx #$00
    lda (zp_pointer_lo,x)
    and #$c0
    sta zp_temp
    lda (zp_pointer_lo,x)
    clc
    and #$3f
    sta zp_temp2
    inc zp_temp2
    lda zp_temp2
    clc
    cmp #$40
    bcs ccdu_jmp1
    ora zp_temp
    sta (zp_pointer_lo,x)
    rts
ccdu_jmp1:
    lda zp_temp
    sta (zp_pointer_lo,x)
    rts

////////////////////////////////////////////////////
// Change Command DOWN
change_command_data_down:
    jsr calculate_pattern_block
    inc zp_pointer_hi
    ldx #$00
    lda (zp_pointer_lo,x)
    and #$c0
    sta zp_temp
    lda (zp_pointer_lo,x)
    clc
    and #$3f
    sta zp_temp2
    dec zp_temp2
    lda zp_temp2
    clc
    cmp #$ff
    bcs ccdd_jmp1
    ora zp_temp
    sta (zp_pointer_lo,x)
    rts
ccdd_jmp1:
    lda zp_temp
    ora #$3F
    sta (zp_pointer_lo,x)
    rts

////////////////////////////////////////////////////
// Change Command
change_command:
    jsr calculate_pattern_block
    inc zp_pointer_hi
    ldx #$00
    lda (zp_pointer_lo,x)
    clc
    adc #$40
    bcc cc_2
    lda (zp_pointer_lo,x)
    and #$3f
cc_2:
    sta (zp_pointer_lo,x)

    // lda (zp_pointer_lo,x)
    // and #$c0
    // PrintHex(34,7)

    ldx #$00
    lda (zp_pointer_lo,x)
    and #$c0
    cmp #$40
    bne cc_not_speed
    lda (zp_pointer_lo,x)
    ora #playback_default_speed
    sta (zp_pointer_lo,x)
    rts
cc_not_speed:
    lda (zp_pointer_lo,x)
    and #$c0
    sta (zp_pointer_lo,x)
    rts

////////////////////////////////////////////////////
// Playback
playback:
    clc
    lda playback_playing
    cmp #$01
    beq not_playing
    rts
not_playing:
    // process command
    jsr calculate_pattern_block
    inc zp_pointer_hi
    ldx #$00
    lda (zp_pointer_lo,x)
    tax
    and #$c0
    clc
    ror
    ror
    ror
    ror
    ror
    ror
    cmp #$01
    bne pb_pc_2
    // speed
    txa
    and #$3f
    sta playback_speed
    jmp pb_pc_end
pb_pc_2:
    cmp #$02
    bne pb_pc_3
    // stop
    lda #$00
    sta playback_playing
    jmp pb_pc_end
pb_pc_3:

pb_pc_end:


    // do speed stuff
    jsr KERNAL_RDTIM
    and #$01
    cmp #$01
    beq pb_speed_chk
    rts
pb_speed_chk:
    inc playback_speed_counter
    clc
    lda playback_speed
    rol
    rol
    cmp playback_speed_counter
    bcc pb_speed_chk2
    rts
pb_speed_chk2:
    lda #$00
    sta playback_speed_counter
    inc playback_speed_counter2
    lda playback_speed_counter2
    cmp #$04
    beq pb_speed_chk3
    rts
pb_speed_chk3:
    lda #$00
    sta playback_speed_counter2

    clc
    lda playback_pos_pattern_c
    cmp #$ff
    bne pb_ppc_out

    clc
    lda playback_pos_track
    cmp track_block_length
    bne pb_ppt_out

    lda #$ff
    sta playback_pos_track

pb_ppt_out:
    inc playback_pos_track

pb_ppc_out:
    inc playback_pos_pattern_c

    lda playback_pos_track
    sta track_block_cursor

    tax
    lda track_block,x
    sta playback_pos_pattern

    lda playback_pos_pattern_c
    sta pattern_cursor

    jsr calculate_pattern_block
    jsr refresh_pattern
    jsr refresh_track_blocks
    jsr draw_current_relays


    rts

////////////////////////////////////////////////////
// Initialize
initialize:
    lda #08     // Set drive
    sta drive   //           to 8
    lda #$ff    // Set all DATA Direction
    sta USER_PORT_DATA_DIR // on user port
    ldx #00     // Store initial_filename in filename_buffer
init_fn_loop:
    lda initial_filename,x
    sta filename_buffer,x
    inx
    cpx #$10
    bne init_fn_loop
    jsr convert_filename
    ldx filename_length
    stx filename_cursor
    ldx #track_block_cursor_init // Set Track block cursor to 0
    stx track_block_cursor
    txa
    sta track_block,x
    lda #pattern_cursor_init    // Set Pattern cursor to 0
    sta pattern_cursor
    lda #$00
    sta track_block_length
    jsr calculate_pattern_block
    lda #$00
    sta joystick_control_mode
    sta playback_pos_track
    sta playback_pos_pattern
    sta playback_pos_pattern_c
    sta playback_playing
    lda #playback_default_speed
    sta playback_speed
    lda #$00
    sta playback_speed_counter
    lda #$00
    sta vic_rel_mode
    rts

initial_filename:
.text "filename.rtd"
.byte 0,0,0,0

////////////////////////////////////////////////////
// New Data
new_data_confirm:
    jsr draw_confirm_question
ndc_loop2:
    jsr KERNAL_GETIN
    cmp #$00
    beq ndc_loop2
ndc_check_y_hit: // Y (Yes New Memory)
    cmp #$59
    beq new_data
    jsr draw_screen
    rts
new_data:
    pha
    lda #$00
    sta zp_pointer_lo
    lda #tracker_data_start_hi
    sta zp_pointer_hi
    ldx #$00
clrloop:
    txa
    pha
    lda zp_pointer_hi
    PrintHex(0,0)
    sta BACKGROUND_COLOR
    lda zp_pointer_lo
    PrintHex(2,0)
    sta BORDER_COLOR
    pla
    tax
    lda #$00
    sta (zp_pointer_lo,x)
    inc zp_pointer_lo
    lda zp_pointer_lo
    cmp #$00
    bne clrloop
    inc zp_pointer_hi
    lda zp_pointer_hi
    cmp #tracker_data_end_hi
    bne clrloop
    pla
    rts

////////////////////////////////////////////////////
// Draw Confirm Question
draw_confirm_question:
    ldy #$02
    ldx #$00
ndc_loop:
    lda confirm_text,x
    sta SCREEN_RAM+12+11*40,x
    tya
    sta COLOR_RAM+12+11*40,x
    lda confirm_text+15,x
    sta SCREEN_RAM+12+12*40,x
    tya
    sta COLOR_RAM+12+12*40,x
    lda confirm_text+30,x
    sta SCREEN_RAM+12+13*40,x
    tya
    sta COLOR_RAM+12+13*40,x
    inx
    cpx #15
    bne ndc_loop
    rts

confirm_text:
.byte 079,119,119,119,119,119,119,119,119,119,119,119,119,119,080
.byte 101,001,018,005,032,025,015,021,032,019,021,018,005,063,103
.byte 076,111,111,111,111,111,111,111,111,111,111,111,111,111,122

////////////////////////////////////////////////////
// Draw Playback Status
draw_playback_status:
    lda playback_speed
    PrintHex(24,1) // draw playback speed
    ldx playback_playing
    lda playback_text,x
    sta SCREEN_RAM+16+1*40 // draw playback_playing
    lda playback_pos_track
    PrintHex(17,1) // draw track pos
    lda playback_pos_pattern
    PrintHex(19,1) // draw pattern pos
    lda playback_pos_pattern_c
    PrintHex(21,1) // draw pattern cursor
    rts

playback_text:
.byte 05,16

////////////////////////////////////////////////////
// Draw Screen
draw_screen:
    ////////////////////////////////////////////////
    // Draw the Petmate Screen... START
    lda screen_001
    sta BORDER_COLOR
    lda screen_001+1
    sta BACKGROUND_COLOR
    ldx #$00 // Draw the screen from memory location
dpms_loop:
    lda screen_001+2,x // Petmate screen (+2 is to skip over background/border color)
    sta 1024,x
    lda screen_001+2+256,x
    sta 1024+256,x
    lda screen_001+2+512,x
    sta 1024+512,x
    lda screen_001+2+512+256,x
    sta 1024+512+256,x
    lda screen_001+1000+2,x
    sta COLOR_RAM,x // And the colors
    lda screen_001+1000+2+256,x
    sta COLOR_RAM+256,x
    lda screen_001+1000+2+512,x
    sta COLOR_RAM+512,x
    lda screen_001+1000+2+512+256,x
    sta COLOR_RAM+512+256,x
    inx
    bne dpms_loop
    // Draw the Petmate Screen... END
    ////////////////////////////////////////////////
    ldx #$00    // Draw the filename onto the screen
ds_fn_loop:
    lda filename_buffer,x
    cmp #$00
    bne ds_fn_2
    lda #$20
ds_fn_2:
    sta filename,x
    lda #$01
    sta filename_color,x
    inx
    cpx #$10
    bne ds_fn_loop
    jsr show_drive  // Draw the drive onto the screen
    jsr refresh_track_blocks // Update track blocks
    jsr calculate_pattern_block
    jsr refresh_pattern // Update pattern
    jsr draw_current_relays
    jsr draw_jcm
    lda vic_rel_mode
    adc #47
    sta $44a
    rts

////////////////////////////////////////////////////
// Draw Relays (new method)
drawgpio:
    stx zp_temp
    sty zp_temp2
    jsr calculate_screen_pos // zp_ptr_screen // screen location
    ldx zp_temp
    ldy zp_temp2
    jsr calculate_color_pos // zp_ptr_color // screen location
    //////////////////////////////////////////////////
    // BLOCK 1 (First 8 bits)
    ldx #$00; lda (zp_block1,x) // get first block of gpio data
    jsr drawgpio_block
    //////////////////////////////////////////////////
    // BLOCK 2 (Next 8 bits)
    ldx #$00; lda (zp_block2,x) // get next block of gpio data
    jsr drawgpio_block 
    //////////////////////////////////////////////////
    // BLOCK 3 (Next 8 bits)
    ldx #$00; lda (zp_block3,x) // get next block of gpio data
    jsr drawgpio_block
    //////////////////////////////////////////////////
    // BLOCK 4 (Next 8 bits)
    ldx #$00; lda (zp_block4,x) // get next block of gpio data
    jsr drawgpio_block
    rts

drawgpio_block:
    sta zp_temp
    ldy #$08
!dgpb:
    lda zp_temp
    clc
    asl
    sta zp_temp
    bcs !dgpb+
    lda #gpio_off
    ldx #$00
    sta (zp_ptr_screen,x)
    lda #gpio_off_color
    ldx #$00
    sta (zp_ptr_color,x)
    jmp !dgpb++
!dgpb:
    lda #gpio_on
    ldx #$00
    sta (zp_ptr_screen,x)
    lda #gpio_on_color
    ldx #$00
    sta (zp_ptr_color,x)
!dgpb:
    jsr increment_screen_pos
    jsr increment_color_pos
    dey
    bne !dgpb---
    rts    

////////////////////////////////////////////////////
// Draw Relays Macro
.macro DrawRelays(xpos,ypos) { // Macro for drawing relay settings

    ldy vic_rel_mode

    pha
    clc
    lsr
    tax
    bcc dr_1_1
    lda #90
    sta SCREEN_RAM+xpos+ypos*40,y
    lda #02
    sta COLOR_RAM+xpos+ypos*40,y
    jmp dr_1_2
dr_1_1:
    lda #94
    sta SCREEN_RAM+xpos+ypos*40,y
    lda #11
    sta COLOR_RAM+xpos+ypos*40,y
dr_1_2:
    clc
    txa
    lsr
    tax
    bcc dr_2_1
    lda #90
    sta SCREEN_RAM+1+xpos+ypos*40,y
    lda #02
    sta COLOR_RAM+1+xpos+ypos*40,y
    jmp dr_2_2
dr_2_1:
    lda #94
    sta SCREEN_RAM+1+xpos+ypos*40,y
    lda #11
    sta COLOR_RAM+1+xpos+ypos*40,y
dr_2_2:
    clc
    txa
    lsr
    tax
    bcc dr_3_1
    lda #90
    sta SCREEN_RAM+2+xpos+ypos*40,y
    lda #02
    sta COLOR_RAM+2+xpos+ypos*40,y
    jmp dr_3_2
dr_3_1:
    lda #94
    sta SCREEN_RAM+2+xpos+ypos*40,y
    lda #11
    sta COLOR_RAM+2+xpos+ypos*40,y
dr_3_2:
    clc
    txa
    lsr
    tax
    bcc dr_4_1
    lda #90
    sta SCREEN_RAM+3+xpos+ypos*40,y
    lda #02
    sta COLOR_RAM+3+xpos+ypos*40,y
    jmp dr_4_2
dr_4_1:
    lda #94
    sta SCREEN_RAM+3+xpos+ypos*40,y
    lda #11
    sta COLOR_RAM+3+xpos+ypos*40,y
dr_4_2:
    clc
    txa
    lsr
    tax
    bcc dr_5_1
    lda #90
    sta SCREEN_RAM+4+xpos+ypos*40,y
    lda #02
    sta COLOR_RAM+4+xpos+ypos*40,y
    jmp dr_5_2
dr_5_1:
    lda #94
    sta SCREEN_RAM+4+xpos+ypos*40,y
    lda #11
    sta COLOR_RAM+4+xpos+ypos*40,y
dr_5_2:
    clc
    txa
    lsr
    tax
    bcc dr_6_1
    lda #90
    sta SCREEN_RAM+5+xpos+ypos*40,y
    lda #02
    sta COLOR_RAM+5+xpos+ypos*40,y
    jmp dr_6_2
dr_6_1:
    lda #94
    sta SCREEN_RAM+5+xpos+ypos*40,y
    lda #11
    sta COLOR_RAM+5+xpos+ypos*40,y
dr_6_2:
    cpy #$01
    beq dr_8_2
    clc
    txa
    lsr
    tax
    bcc dr_7_1
    lda #90
    sta SCREEN_RAM+6+xpos+ypos*40,y
    lda #02
    sta COLOR_RAM+6+xpos+ypos*40,y
    jmp dr_7_2
dr_7_1:
    lda #94
    sta SCREEN_RAM+6+xpos+ypos*40,y
    lda #11
    sta COLOR_RAM+6+xpos+ypos*40,y
dr_7_2:
    clc
    txa
    lsr
    tax
    bcc dr_8_1
    lda #90
    sta SCREEN_RAM+7+xpos+ypos*40,y
    lda #02
    sta COLOR_RAM+7+xpos+ypos*40,y
    jmp dr_8_2
dr_8_1:
    lda #94
    sta SCREEN_RAM+7+xpos+ypos*40,y
    lda #11
    sta COLOR_RAM+7+xpos+ypos*40,y
dr_8_2:
    pla
}

////////////////////////////////////////////////////
// Refresh Joystick Control Mode
refresh_jcm:
draw_jcm:
    // 0 = OFF: off
    // 1 = PLAY MODE: Joystick button plays
    // 2 = FREESTYLE MODE: Joystick directions toggle relays 1-4 directions + button toggle relays 5-8
    // 3 = TRACKER MODE: Joystick UP and DOWN control play of tracker
    // 4 = EDIT
    clc
    lda joystick_control_mode
    cmp #$00
    beq jcm_is_zero
    clc
    lda joystick_control_mode
    rol
    rol
jcm_is_zero:
    tax
    lda jcm_modes_text,x
    sta SCREEN_RAM+28+1*40
    inx
    lda jcm_modes_text,x
    sta SCREEN_RAM+1+28+1*40
    inx
    lda jcm_modes_text,x
    sta SCREEN_RAM+2+28+1*40
    inx
    lda jcm_modes_text,x
    sta SCREEN_RAM+3+28+1*40
    rts

jcm_modes_text:
.text "off "
.text "play"
.text "free"
.text "trak"
.text "edit"

////////////////////////////////////////////////////
// Clear Pattern Line Macro
.macro ClearPatternLine(line) {
    lda #$20 // Clear pattern area
    ldx #$00
rp_loop1:
    sta SCREEN_RAM+line*40+1,x // POS Column
    sta SCREEN_RAM+line*40+17,x // VA Column
    inx
    cpx #$04
    bne rp_loop1
    ldx#$00
rp_loop2:
    sta SCREEN_RAM+line*40+6,x // RELAY Column
    inx
    cpx#$0a
    bne rp_loop2
    ldx #$00
rp_loop3:
    sta SCREEN_RAM+line*40+22,x // Command Column
    inx
    cpx #$09
    bne rp_loop3
    ldx #$00
rp_loop4:
    sta SCREEN_RAM+line*40+32,x // Command DATA Column
    inx
    cpx #$07
    bne rp_loop4
}

////////////////////////////////////////////////////
// Draw Command Macro
.macro DrawCommand(xpos,ypos) {
    and #$c0
    clc
    ror
    ror
    ror
    ror
    ror
    ror
    // PrintHex(38,24)
    sta zp_temp
    ldx #$00
dc_jmp3:
    lda zp_temp
    cmp #$00
    beq dc_jmp4
    inx
    inx
    inx
    inx
    inx
    inx
    inx
    dec zp_temp
    jmp dc_jmp3
dc_jmp4:
    ldy #$00
dc_loop1:
    lda command_table,x
    sta SCREEN_RAM+xpos+ypos*40,y
    inx
    iny
    cpy #$07
    bne dc_loop1
}

command_table:
.text "-------"
.text "speed  "
.text "stop   "
.text "future "

////////////////////////////////////////////////////
// Draw Command Data Macro
.macro DrawCommandData(xpos,ypos) {
    and #$3f
    PrintHex(xpos,ypos)
}

////////////////////////////////////////////////////
// Refresh Pattern
refresh_pattern:
    // current_pattern
    // pattern_cursor
    // pattern_block_start
    // pattern_block_end
    // pattern is 256 bytes (relay data)
    //            256 bytes (command data)
    // 13 shown pattern values on screen
    // 7 is the cursor position
rp_v1:
    jsr calculate_pattern_block
    clc
    lda pattern_cursor
    sbc #$05
    bcs rp_v1_2
    ClearPatternLine(11)
    jmp rp_v2
rp_v1_2:
    sta zp_pointer_lo
    PrintHex(2,11)
    ldx #$00
    lda (zp_pointer_lo,x)
    DrawRelays(7,11)
    PrintHex(18,11)
    inc zp_pointer_hi
    ldx #$00
    lda (zp_pointer_lo,x)
    DrawCommand(23,11)
    ldx #$00
    lda (zp_pointer_lo,x)
    DrawCommandData(35,11)
    dec zp_pointer_hi
rp_v2:
    clc
    lda pattern_cursor
    sbc #$04
    bcs rp_v2_2
    ClearPatternLine(12)
    jmp rp_v3
rp_v2_2:
    sta zp_pointer_lo
    PrintHex(2,12)
    ldx #$00
    lda (zp_pointer_lo,x)
    DrawRelays(7,12)
    PrintHex(18,12)
    inc zp_pointer_hi
    ldx #$00
    lda (zp_pointer_lo,x)
    DrawCommand(23,12)
    ldx #$00
    lda (zp_pointer_lo,x)
    DrawCommandData(35,12)
    dec zp_pointer_hi
rp_v3:
    clc
    lda pattern_cursor
    sbc #$03
    bcs rp_v3_2
    ClearPatternLine(13)
    jmp rp_v4
rp_v3_2:
    sta zp_pointer_lo
    PrintHex(2,13)
    ldx #$00
    lda (zp_pointer_lo,x)
    DrawRelays(7,13)
    PrintHex(18,13)
    inc zp_pointer_hi
    ldx #$00
    lda (zp_pointer_lo,x)
    DrawCommand(23,13)
    ldx #$00
    lda (zp_pointer_lo,x)
    DrawCommandData(35,13)
    dec zp_pointer_hi
rp_v4:
    clc
    lda pattern_cursor
    sbc #$02
    bcs rp_v4_2
    ClearPatternLine(14)
    jmp rp_v5
rp_v4_2:
    sta zp_pointer_lo
    PrintHex(2,14)
    ldx #$00
    lda (zp_pointer_lo,x)
    DrawRelays(7,14)
    PrintHex(18,14)
    inc zp_pointer_hi
    ldx #$00
    lda (zp_pointer_lo,x)
    DrawCommand(23,14)
    ldx #$00
    lda (zp_pointer_lo,x)
    DrawCommandData(35,14)
    dec zp_pointer_hi
rp_v5:
    clc
    lda pattern_cursor
    sbc #$01
    bcs rp_v5_2
    ClearPatternLine(15)
    jmp rp_v6
rp_v5_2:
    sta zp_pointer_lo
    PrintHex(2,15)
    ldx #$00
    lda (zp_pointer_lo,x)
    DrawRelays(7,15)
    PrintHex(18,15)
    inc zp_pointer_hi
    ldx #$00
    lda (zp_pointer_lo,x)
    DrawCommand(23,15)
    ldx #$00
    lda (zp_pointer_lo,x)
    DrawCommandData(35,15)
    dec zp_pointer_hi
rp_v6:
    clc
    lda pattern_cursor
    sbc #$00
    bcs rp_v6_2
    ClearPatternLine(16)
    jmp rp_v7
rp_v6_2:
    sta zp_pointer_lo
    PrintHex(2,16)
    ldx #$00
    lda (zp_pointer_lo,x)
    DrawRelays(7,16)
    PrintHex(18,16)
    inc zp_pointer_hi
    ldx #$00
    lda (zp_pointer_lo,x)
    DrawCommand(23,16)
    ldx #$00
    lda (zp_pointer_lo,x)
    DrawCommandData(35,16)
    dec zp_pointer_hi
rp_v7:
    lda pattern_cursor
    sta zp_pointer_lo
    PrintHex(2,17)
    ldx #$00
    lda (zp_pointer_lo,x)
    DrawRelays(7,17)
    PrintHex(18,17)
    inc zp_pointer_hi
    ldx #$00
    lda (zp_pointer_lo,x)
    DrawCommand(23,17)
    ldx #$00
    lda (zp_pointer_lo,x)
    DrawCommandData(35,17)
    dec zp_pointer_hi
rp_v8:
    clc
    lda pattern_cursor
    adc #$01
    bcc rp_v8_2
    ClearPatternLine(18)
    jmp rp_v9
rp_v8_2:
    sta zp_pointer_lo
    PrintHex(2,18)
    ldx #$00
    lda (zp_pointer_lo,x)
    DrawRelays(7,18)
    PrintHex(18,18)
    inc zp_pointer_hi
    ldx #$00
    lda (zp_pointer_lo,x)
    DrawCommand(23,18)
    ldx #$00
    lda (zp_pointer_lo,x)
    DrawCommandData(35,18)
    dec zp_pointer_hi
rp_v9:
    clc
    lda pattern_cursor
    adc #$02
    bcc rp_v9_2
    ClearPatternLine(19)
    jmp rp_v10
rp_v9_2:
    sta zp_pointer_lo
    PrintHex(2,19)
    ldx #$00
    lda (zp_pointer_lo,x)
    DrawRelays(7,19)
    PrintHex(18,19)
    inc zp_pointer_hi
    ldx #$00
    lda (zp_pointer_lo,x)
    DrawCommand(23,19)
    ldx #$00
    lda (zp_pointer_lo,x)
    DrawCommandData(35,19)
    dec zp_pointer_hi
rp_v10:
    clc
    lda pattern_cursor
    adc #$03
    bcc rp_v10_2
    ClearPatternLine(20)
    jmp rp_v11
rp_v10_2:
    sta zp_pointer_lo
    PrintHex(2,20)
    ldx #$00
    lda (zp_pointer_lo,x)
    DrawRelays(7,20)
    PrintHex(18,20)
    inc zp_pointer_hi
    ldx #$00
    lda (zp_pointer_lo,x)
    DrawCommand(23,20)
    ldx #$00
    lda (zp_pointer_lo,x)
    DrawCommandData(35,20)
    dec zp_pointer_hi
rp_v11:
    clc
    lda pattern_cursor
    adc #$04
    bcc rp_v11_2
    ClearPatternLine(21)
    jmp rp_v12
rp_v11_2:
    sta zp_pointer_lo
    PrintHex(2,21)
    ldx #$00
    lda (zp_pointer_lo,x)
    DrawRelays(7,21)
    PrintHex(18,21)
    inc zp_pointer_hi
    ldx #$00
    lda (zp_pointer_lo,x)
    DrawCommand(23,21)
    ldx #$00
    lda (zp_pointer_lo,x)
    DrawCommandData(35,21)
    dec zp_pointer_hi
rp_v12:
    clc
    lda pattern_cursor
    adc #$05
    bcc rp_v12_2
    ClearPatternLine(22)
    jmp rp_v13
rp_v12_2:
    sta zp_pointer_lo
    PrintHex(2,22)
    ldx #$00
    lda (zp_pointer_lo,x)
    DrawRelays(7,22)
    PrintHex(18,22)
    inc zp_pointer_hi
    ldx #$00
    lda (zp_pointer_lo,x)
    DrawCommand(23,22)
    ldx #$00
    lda (zp_pointer_lo,x)
    DrawCommandData(35,22)
    dec zp_pointer_hi
rp_v13:
    clc
    lda pattern_cursor
    adc #$06
    bcc rp_v13_2
    ClearPatternLine(23)
    jmp rp_v14
rp_v13_2:
    sta zp_pointer_lo
    PrintHex(2,23)
    ldx #$00
    lda (zp_pointer_lo,x)
    DrawRelays(7,23)
    PrintHex(18,23)
    inc zp_pointer_hi
    ldx #$00
    lda (zp_pointer_lo,x)
    DrawCommand(23,23)
    ldx #$00
    lda (zp_pointer_lo,x)
    DrawCommandData(35,23)
rp_v14:
    rts

////////////////////////////////////////////////////
// Refresh Track Blocks
refresh_track_blocks:
    lda #$20 // Clear Track Blocks Area
    ldx #$00
rtb_loop1:
    sta SCREEN_RAM+3*40,x
    sta SCREEN_RAM+4*40,x
    sta SCREEN_RAM+5*40,x
    inx
    cpx #$07
    bne rtb_loop1
    // Done clearing track blocks area
// track -1
    ldx track_block_cursor
    dex
    cpx #$ff
    beq rtb_skip_top
    lda #58 // put :
    sta SCREEN_RAM+3+3*40
    txa
    PrintHex(1,3) // print track -1
    ldx track_block_cursor
    dex
    lda track_block,x
    PrintHex(4,3) // print pattern of track -1
rtb_skip_top:
// track 0
    lda #58 // put :
    sta SCREEN_RAM+3+4*40
    lda track_block_cursor
    PrintHex(1,4) // print track
    ldx track_block_cursor
    lda track_block,x
    PrintHex(4,4) // print pattern in track area
    ldx track_block_cursor
    lda track_block,x
    PrintHex(16,3) // print pattern in pattern area
// track +1
    ldx track_block_cursor
    cpx track_block_length
    beq rtb_skip_bot
    lda #58 // put :
    sta SCREEN_RAM+3+5*40
    ldx track_block_cursor
    inx
    txa
    PrintHex(1,5) // print track +1
    ldx track_block_cursor
    inx
    lda track_block,x
    PrintHex(4,5) // print pattern of track +1
rtb_skip_bot:
    clc
    ldx #$00 // reverse the track cursor location
rtb_rev:
    lda SCREEN_RAM+4*40,x
    adc #$80
    sta SCREEN_RAM+4*40,x
    lda #$01 // and color
    sta COLOR_RAM+4*40,x // it white
    inx
    cpx #$07 // only do 7 characters
    bne rtb_rev
    rts

////////////////////////////////////////////////////
// Update / Draw Current Relay
update_current_relays:
draw_current_relays:
    jsr calculate_pattern_block
    ldx #$00
    lda (zp_pointer_lo,x) // Load the value from memory
    DrawRelays(7,17)      // Draw current relay at top right of screen
    DrawRelays(7,1)      // Draw current relay at current in track pattern cursor position
    lda (zp_pointer_lo,x) // Load the value from memory
    PrintHex(18,17)       // Print hex value of current relay in track pattern cursor position

    lda vic_rel_mode
    cmp #$00
    bne vic_rel_mode_on
    ldx #$00
    lda (zp_pointer_lo,x)
    eor #$ff              // Relay block is actually inverse of what is shown on screen
    sta USER_PORT_DATA
    rts
vic_rel_mode_on:
    ldx #$00
    lda (zp_pointer_lo,x)
    sta USER_PORT_DATA
    rts

////////////////////////////////////////////////////
// toggle relay 1
toggle_relay_1:
    jsr calculate_pattern_block
    clc
    ldx #$00
    lda (zp_pointer_lo,x)
    and #$01
    beq check_1_hit_offz
    jmp check_1_hit_off
check_1_hit_offz:
    ldx #$00
    lda (zp_pointer_lo,x)
    ora #$01
    sta (zp_pointer_lo,x)
    jsr draw_current_relays
    rts
check_1_hit_off:
    ldx #$00
    lda (zp_pointer_lo,x)
    and #$fe
    sta (zp_pointer_lo,x)
    jsr draw_current_relays
    rts

////////////////////////////////////////////////////
// toggle relay 2
toggle_relay_2:
    jsr calculate_pattern_block
    clc
    ldx #$00
    lda (zp_pointer_lo,x)
    and #$02
    beq check_2_hit_offz
    jmp check_2_hit_off
check_2_hit_offz:
    ldx #$00
    lda (zp_pointer_lo,x)
    ora #$02
    sta (zp_pointer_lo,x)
    jsr draw_current_relays
    rts
check_2_hit_off:
    ldx #$00
    lda (zp_pointer_lo,x)
    and #$fd
    sta (zp_pointer_lo,x)
    jsr draw_current_relays
    rts

////////////////////////////////////////////////////
// toggle relay 3
toggle_relay_3:
    jsr calculate_pattern_block
    clc
    ldx #$00
    lda (zp_pointer_lo,x)
    and #$04
    beq check_3_hit_offz
    jmp check_3_hit_off
check_3_hit_offz:
    ldx #$00
    lda (zp_pointer_lo,x)
    ora #$04
    sta (zp_pointer_lo,x)
    jsr draw_current_relays
    rts
check_3_hit_off:
    ldx #$00
    lda (zp_pointer_lo,x)
    and #$fb
    sta (zp_pointer_lo,x)
    jsr draw_current_relays
    rts

////////////////////////////////////////////////////
// toggle relay 4
toggle_relay_4:
    jsr calculate_pattern_block
    clc
    ldx #$00
    lda (zp_pointer_lo,x)
    and #$08
    beq check_4_hit_offz
    jmp check_4_hit_off
check_4_hit_offz:
    ldx #$00
    lda (zp_pointer_lo,x)
    ora #$08
    sta (zp_pointer_lo,x)
    jsr draw_current_relays
    rts
check_4_hit_off:
    ldx #$00
    lda (zp_pointer_lo,x)
    and #$f7
    sta (zp_pointer_lo,x)
    jsr draw_current_relays
    rts

////////////////////////////////////////////////////
// toggle relay 5
toggle_relay_5:
    jsr calculate_pattern_block
    clc
    ldx #$00
    lda (zp_pointer_lo,x)
    and #16
    beq check_5_hit_offz
    jmp check_5_hit_off
check_5_hit_offz:
    ldx #$00
    lda (zp_pointer_lo,x)
    ora #16
    sta (zp_pointer_lo,x)
    jsr draw_current_relays
    rts
check_5_hit_off:
    ldx #$00
    lda (zp_pointer_lo,x)
    and #$ef
    sta (zp_pointer_lo,x)
    jsr draw_current_relays
    rts

////////////////////////////////////////////////////
// toggle relay 6
toggle_relay_6:
    jsr calculate_pattern_block
    clc
    ldx #$00
    lda (zp_pointer_lo,x)
    and #32
    beq check_6_hit_offz
    jmp check_6_hit_off
check_6_hit_offz:
    ldx #$00
    lda (zp_pointer_lo,x)
    ora #32
    sta (zp_pointer_lo,x)
    jsr draw_current_relays
    rts
check_6_hit_off:
    ldx #$00
    lda (zp_pointer_lo,x)
    and #$df
    sta (zp_pointer_lo,x)
    jsr draw_current_relays
    rts

////////////////////////////////////////////////////
// toggle relay 7
toggle_relay_7:
    jsr calculate_pattern_block
    clc
    ldx #$00
    lda (zp_pointer_lo,x)
    and #64
    beq check_7_hit_offz
    jmp check_7_hit_off
check_7_hit_offz:
    ldx #$00
    lda (zp_pointer_lo,x)
    ora #64
    sta (zp_pointer_lo,x)
    jsr draw_current_relays
    rts
check_7_hit_off:
    ldx #$00
    lda (zp_pointer_lo,x)
    and #$bf
    sta (zp_pointer_lo,x)
    jsr draw_current_relays
    rts

////////////////////////////////////////////////////
// toggle relay 8
toggle_relay_8:
    jsr calculate_pattern_block
    clc
    ldx #$00
    lda (zp_pointer_lo,x)
    and #128
    beq check_8_hit_offz
    jmp check_8_hit_off
check_8_hit_offz:
    ldx #$00
    lda (zp_pointer_lo,x)
    ora #128
    sta (zp_pointer_lo,x)
    jsr draw_current_relays
    rts
check_8_hit_off:
    ldx #$00
    lda (zp_pointer_lo,x)
    and #$7f
    sta (zp_pointer_lo,x)
    jsr draw_current_relays
    rts

////////////////////////////////////////////////////
// all relays off
all_relay_off:
    jsr calculate_pattern_block
    lda #$00
    ldx #$00
    sta (zp_pointer_lo,x)
    jsr draw_current_relays
    rts

////////////////////////////////////////////////////
// all relays on
all_relay_on:
    jsr calculate_pattern_block
    lda #$ff
    ldx #$00
    sta (zp_pointer_lo,x)
    jsr draw_current_relays
    rts

///////////////////////////////////////////////////
// Calculate pattern block
calculate_pattern_block:
    lda pattern_cursor
    sta playback_pos_pattern_c
    sta zp_pointer_lo
    lda #pattern_block_start_hi
    sta zp_pointer_hi
    ldx track_block_cursor
    stx playback_pos_track
    lda track_block,x
    sta playback_pos_pattern
    tax
    cpx #$00
    beq cpb_2
cpb_1:
    lda zp_pointer_hi
    adc #$02
    sta zp_pointer_hi
    dex
    cpx #$00
    beq cpb_2
    jmp cpb_1
cpb_2:
    lda zp_pointer_lo
    PrintHex(38,1) // draw memory locations
    lda zp_pointer_hi
    PrintHex(36,1)
    rts

///////////////////////////////////////////////////

#import "relay_tracker-disk.asm"

// END OF PROGRAM
///////////////////////////////////////////////////
