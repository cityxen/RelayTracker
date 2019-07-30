//////////////////////////////////////////////////////////////////////////
// Relay Tracker
// by Deadline
// (c)2019 CityXen
//////////////////////////////////////////////////////////////////////////

#import "../../Commodore64_Programming/include/Constants.asm"
#import "../../Commodore64_Programming/include/Macros.asm"
#import "relay_tracker-vars.asm"

*=$3000 "customfont"
#import "relay_tracker-charset.asm"
#import "relay_tracker-screen.asm"

*=$0801 "BASIC"
    BasicUpstart($0810)
*=$0810

    ClearScreen(BLACK) // from Macros.asm
	lda VIC_MEM_POINTERS // point to the new characters
    ora #$0c
    sta VIC_MEM_POINTERS
    jsr initialize
    jsr draw_screen

mainloop:
//////////////////////////////////////////////////
// CHECK KEYBOARD FOR KEY HITS
    jsr KERNAL_GETIN
//////////////////////////////////////////////////
// SPACE (PLAY/PAUSE)
check_space_hit:
    cmp #$20
    bne check_dollar_hit
    // TODO: play/pause stuff
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
// C (Change Speed)
check_c_hit:
    cmp #$43
    bne check_d_hit
    // TODO: Change speed
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
    // TODO: Erase File
    jmp mainloop
//////////////////////////////////////////////////
// F (Change Filename)
check_f_hit:
    cmp #$46
    bne check_n_hit
    jsr change_filename
    jmp mainloop
//////////////////////////////////////////////////
// N (New Data)
check_n_hit:
    cmp #$4e
    bne check_colon_hit
    // TODO: New Data
    jmp mainloop
//////////////////////////////////////////////////
// COLON (Change Pattern DOWN)
check_colon_hit:
    cmp #58
    bne check_semicolon_hit
    ldx track_block_cursor
    lda track_block,x
    cmp #$00
    beq check_colon_nope
    dec track_block,x
check_colon_nope:
    jsr refresh_track_blocks
    jmp mainloop
//////////////////////////////////////////////////
// SEMICOLON (Change Pattern UP)
check_semicolon_hit:
    cmp #59
    bne check_s_hit
    ldx track_block_cursor
    lda track_block,x
    cmp #$ff
    beq check_semicolon_nope
    inc track_block,x
check_semicolon_nope:
    jsr refresh_track_blocks
    jmp mainloop
//////////////////////////////////////////////////
// S (Save File)
check_s_hit:
    cmp #$53
    bne check_1_hit
    jsr save_file
    jmp mainloop
//////////////////////////////////////////////////
// 1 (Set Relay 1)
check_1_hit:
    cmp #$31
    bne check_2_hit
    // TODO: Set Relay 1
    jmp mainloop
//////////////////////////////////////////////////
// 2 (Set Relay 2)
check_2_hit:
    cmp #$32
    bne check_3_hit
    // TODO: Set Relay 2
    jmp mainloop
//////////////////////////////////////////////////
// 3 (Set Relay 3)
check_3_hit:
    cmp #$33
    bne check_4_hit
    // TODO: Set Relay 3
    jmp mainloop
//////////////////////////////////////////////////
// 4 (Set Relay 4)
check_4_hit:
    cmp #$34
    bne check_5_hit
    // TODO: Set Relay 4
    jmp mainloop
//////////////////////////////////////////////////
// 5 (Set Relay 5)
check_5_hit:
    cmp #$35
    bne check_6_hit
    // TODO: Set Relay 5
    jmp mainloop
//////////////////////////////////////////////////
// 6 (Set Relay 6)
check_6_hit:
    cmp #$36
    bne check_7_hit
    // TODO: Set Relay 6
    jmp mainloop
//////////////////////////////////////////////////
// 7 (Set Relay 7)
check_7_hit:
    cmp #$37
    bne check_8_hit
    // TODO: Set Relay 7
    jmp mainloop
//////////////////////////////////////////////////
// 8 (Set Relay 8)
check_8_hit:
    cmp #$38
    bne check_minus_hit
    // TODO: Set Relay 8
    jmp mainloop
//////////////////////////////////////////////////
// MINUS (Turn OFF all relays)
check_minus_hit:
    cmp #$2d
    bne check_plus_hit
    // TODO: Turn OFF all relays
    jmp mainloop
//////////////////////////////////////////////////
// PLUS (Turn ON all relays)
check_plus_hit:
    cmp #$2b
    bne check_star_hit
    // TODO: Turn ON all relays
    jmp mainloop
//////////////////////////////////////////////////
// STAR (Change Command)
check_star_hit:
    cmp #$38
    bne check_equal_hit
    // TODO: Change Command
    jmp mainloop
//////////////////////////////////////////////////
// EQUAL (Change Command Value)
check_equal_hit:
    cmp #$38
    bne check_f1_hit
    // TODO: Change Command Value
    jmp mainloop
//////////////////////////////////////////////////
// F1 (Move Track Position UP)
check_f1_hit:
    cmp #$85
    bne check_f3_hit
    lda track_block_cursor
    cmp #$ff
    beq check_f1_hit_too_high
    inc track_block_cursor
    jsr refresh_track_blocks
check_f1_hit_too_high:
    jmp mainloop
//////////////////////////////////////////////////
// F3 (Move Track Position DOWN)
check_f3_hit:
    cmp #$86
    bne check_f5_hit
    lda track_block_cursor
    cmp #$00
    beq check_f3_hit_too_low
    dec track_block_cursor
    jsr refresh_track_blocks
check_f3_hit_too_low:
    jmp mainloop
//////////////////////////////////////////////////
// F5 (Page UP in current Pattern)
check_f5_hit:
    cmp #$87
    bne check_f7_hit
    // TODO: Page UP in current Pattern
    jmp mainloop
//////////////////////////////////////////////////
// F7 (Page DOWN in current Pattern)
check_f7_hit:
    cmp #$88
    bne check_cursor_up_hit
    // TODO: Page DOWN in current Pattern
    jmp mainloop
//////////////////////////////////////////////////
// Cursor UP (Move up one position in current pattern)
check_cursor_up_hit:
    cmp #$11
    bne check_cursor_down_hit
    // TODO: Move up one position in current pattern
    jmp mainloop
//////////////////////////////////////////////////
// Cursor DOWN (Move down one position in current pattern)
check_cursor_down_hit:
    cmp #$91
    bne check_home_hit
    // TODO: Move down one position in current pattern
    jmp mainloop
//////////////////////////////////////////////////
// HOME (Move to top position in current pattern)
check_home_hit:
    cmp #$13
    bne check_clr_hit
    // TODO: Move to top position in current pattern)
    jmp mainloop
//////////////////////////////////////////////////
// CLR (Move to end position in current pattern)
check_clr_hit:
    cmp #$93
    bne check_keys_done
    // TODO: Move to end position in current pattern
    jmp mainloop

check_keys_done:
    jmp mainloop


////////////////////////////////////////////////////
// initialize
initialize:
    lda #08
    sta drive
    
    ldx #00
init_fn_loop:
    lda initial_filename,x
    sta filename_buffer,x
    inx
    cpx #$10
    bne init_fn_loop
    ldx #00
    stx filename_cursor

    lda #track_block_cursor_init
    sta track_block_cursor

    rts
initial_filename:
.text "filename.rtd"
.byte 0,0,0,0

////////////////////////////////////////////////////
// draw screen
draw_screen:
    ldx #$00
ds_loop:
    lda screen_001+2,x
    sta 1024,x
    lda screen_001+2+256,x
    sta 1024+256,x
    lda screen_001+2+512,x
    sta 1024+512,x
    lda screen_001+2+512+256,x
    sta 1024+512+256,x
    lda screen_001+1000+2,x
    sta COLOR_RAM,x
    lda screen_001+1000+2+256,x
    sta COLOR_RAM+256,x
    lda screen_001+1000+2+512,x
    sta COLOR_RAM+512,x
    lda screen_001+1000+2+512+256,x
    sta COLOR_RAM+512+256,x
    inx
    bne ds_loop

    ldx #$00
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

    jsr show_drive
    jsr refresh_track_blocks
    rts

////////////////////////////////////////////////////
// refresh track blocks
refresh_track_blocks:

    lda #$20
    ldx #$00
rtb_loop1:
    sta $400+3*40,x
    sta $400+4*40,x
    sta $400+5*40,x
    inx
    cpx #$07
    bne rtb_loop1

    ldx track_block_cursor
    dex
    cpx #$ff
    beq rtb_skip_top
    
    lda #58
    sta $400+3+3*40

    txa
    PrintHex(1,3)
    ldx track_block_cursor
    dex
    lda track_block,x
    PrintHex(4,3)

rtb_skip_top:

    lda #58
    sta $400+3+4*40
    
    ldx track_block_cursor
    txa
    PrintHex(1,4)
    ldx track_block_cursor
    lda track_block,x
    PrintHex(4,4)

    lda #58
    sta $400+3+5*40

    ldx track_block_cursor
    inx
    txa
    PrintHex(1,5)
    ldx track_block_cursor
    inx
    lda track_block,x
    PrintHex(4,5)

    ldx #$00
rtb_rev:
    lda $400+4*40,x
    adc #$80
    sta $400+4*40,x
    lda #$01
    sta $d800+4*40,x
    inx
    cpx #$07
    bne rtb_rev
    rts



////////////////////////////////////////////////////
// change filename
change_filename:
    ldx #$00
fn_reverse:
    lda filename,x
    ora #$80
    sta filename,x
    lda #$01
    sta filename_color,x
    inx
    cpx #$10
    bne fn_reverse

fn_kb_chk:

    lda #$55
    cmp VIC_RASTER_COUNTER
    bne fn_kb_chk_no_crs

    ldx filename_cursor
    lda filename,x
    cmp #$80
    bcs fn_kb_chk_crs_not_revd
    ora #$80
    sta filename,x
    jmp fn_kb_chk_no_crs
fn_kb_chk_crs_not_revd:
    and #$7f
    sta filename,x

fn_kb_chk_no_crs:

    ldx filename_cursor
    cpx #$10
    bne fn_kb_not_too_long
    ldx #$0f
    stx filename_cursor
fn_kb_not_too_long:

    jsr KERNAL_GETIN
    cmp #$00
    beq fn_kb_chk

    cmp #13
    beq fn_kb_chk_end

    cmp #20
    bne fn_kb_chk_not_del
    ldx filename_cursor
    cpx #$00
    beq fn_kb_chk_del_first_pos
    lda #$a0
    ldx filename_cursor
    sta filename,x
    dec filename_cursor
    jmp fn_kb_chk
fn_kb_chk_del_first_pos:
    lda #$a0
    sta filename
    jmp fn_kb_chk

fn_kb_chk_not_del:
    cmp #64
    bcc fn_kb_num
    sbc #64
fn_kb_num:
    ora #$80
    ldx filename_cursor
    sta filename,x
    inc filename_cursor
    jmp fn_kb_chk
     
fn_kb_chk_end:
    ldx #00

fn_rereverse:
    lda filename,x
    and #$7f
    sta filename,x
    sta filename_buffer,x
    inx
    cpx #$10
    bne fn_rereverse
    ldx #$00

// fill in spaces on end with 0
    ldx #$0f
fn_trim:
    lda filename_buffer,x
    cmp #$20
    bne fn_out
    lda #00
    sta filename_buffer,x
    dex
    jmp fn_trim

fn_out:
    rts

////////////////////////////////////////////////////
// change drive
change_drive:
    inc drive
show_drive:
    lda drive
    cmp #08
    bne cd_2
    lda #48
    sta $491
    lda #56
    sta $492
    rts
cd_2:
    cmp #09
    bne cd_3
    lda #48
    sta $491
    lda #57
    sta $492
    rts
cd_3:
    cmp #10
    bne cd_4
    lda #49
    sta $491
    lda #48
    sta $492
    rts
cd_4:
    cmp #11
    bne cd_5
    lda #49
    sta $491
    lda #49
    sta $492
    rts
cd_5:
    lda #07
    sta drive
    jmp change_drive

////////////////////////////////////////////////////
// show directory
show_directory:
    lda #$01
    sta $0286
    jsr $e544      // clear screen
    lda #$01
    ldx #<dirname
    ldy #>dirname
    jsr KERNAL_SETNAM // set filename "$"
    lda drive
    sta $ba
    lda #$60
    sta $b9        // secondary chn
    jsr $f3d5      // open for serial bus devices
    jsr $f219      // set input device
    ldy #$04
labl1:
    jsr $ee13      // input byte on serial bus
    dey
    bne labl1      // get rid of y bytes
    lda $c6        // key pressed?
    ora $90        // or eof?
    bne labl2      // if yes exit
    jsr $ee13      // now get in ax the dimension
    tax            // of the file
    jsr $ee13
    jsr $bdcd      // print number from ax
labl3:
    jsr $ee13      // now the filename
    jsr $e716      // put a character to screen
    bne labl3      // while not 0 encountered
    jsr $aad7      // put a cr , end line
    ldy #$02       // set 2 bytes to skip
    bne labl1      // repeat
labl2:
    jsr $f642      // close serial bus device
    jsr $f6f3      // restore i/o devices to default

    lda #13; jsr KERNAL_CHROUT
    jsr show_drive_status

    ldx #$00
labl22:
    lda dir_presskey,x
    beq labl4
    jsr KERNAL_CHROUT
    inx
    jmp labl22        

labl4:
    jsr $f142      // w8 a key
    beq labl4
    rts
dirname:
.text "$"
dir_presskey:
.encoding "screencode_mixed"
.byte 13
.text "PRESS ANY KEY"
.byte 0

////////////////////////////////////////////////////
// save file
save_file:

    lda #$01
    sta $0286
    jsr $e544      // clear screen

    ldx #$00
sv_labl1:
    lda save_saving,x
    beq sv_labl2
    sta SCREEN_RAM,x
    inx
    jmp sv_labl1
    
    ldx #$00
sv_labl0:
    lda #$00
    sta filename_save,x
    inx
    cpx #$10
    bne sv_labl0
sv_labl2:
    ldx #$00
sv_labl3:
    lda filename_buffer,x
    beq sv_labl33
    sta SCREEN_RAM+7,x
    inx
    cpx #$10
    bne sv_labl3
sv_labl33:
    ldx #$00
sv_labl4:
    lda filename_buffer,x
    cmp #$00
    beq sv_labl5
    cmp #27
    bcs sv_dont_add
    adc #$40
sv_dont_add:
    sta filename_save,x
    inx
    jmp sv_labl4
sv_labl5:
    stx filename_length

.var tmpalow = $fb 
.var tmpahigh = $fc 
.var savefrom = $4000 
.var saveto   = $9fff 

   lda #$0f
   ldx drive
   ldy #$ff
   jsr KERNAL_SETLFS
    
   lda filename_length //#$10
   ldx #<filename_save
   ldy #>filename_save
   jsr KERNAL_SETNAM
    
   lda #<savefrom // Set Start Address
   sta tmpalow
   lda #>savefrom
   sta tmpahigh
   ldx #<saveto // Set End Address 
   ldy #>saveto 
   lda #<tmpalow
   jsr KERNAL_SAVE 

    lda #13; jsr KERNAL_CHROUT
    lda #13; jsr KERNAL_CHROUT
    jsr show_drive_status

    ldx #$00
sv_labl22:
    lda dir_presskey,x
    beq sv_out
    jsr KERNAL_CHROUT
    inx
    jmp sv_labl22
sv_out:
    jsr $f142      // w8 a key
    beq sv_out
    jsr draw_screen
    rts

save_saving:
.encoding "screencode_mixed"
.text "saving "
.byte 0

////////////////////////////////////////////////////
// show drive status
show_drive_status:
    lda #$00
    sta $90       // clear status flags

    lda drive       // device number
    jsr $ffb1     // call listen
    lda #$6f      // secondary address 15 (command channel)
    jsr $ff93     // call seclsn (second)
    jsr $ffae     // call unlsn
    lda $90       // get status flags
    bne sds_devnp    // device not present

    lda drive       // device number
    jsr $ffb4     // call talk
    lda #$6f      // secondary address 15 (error channel)
    jsr $ff96     // call sectlk (tksa)

sds_loop:
    lda $90       // get status flags
    bne sds_eof      // either eof or error
    jsr $ffa5     // call iecin (get byte from iec bus)
    jsr $ffd2     // call chrout (print byte to screen)
    jmp sds_loop     // next byte
sds_eof:
    jsr $ffab     // call untlk
    rts
sds_devnp:
    //  ... device not present handling ...
    rts
