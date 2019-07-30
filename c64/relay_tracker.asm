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
    bne check_p_hit
    // TODO: New Data
    jmp mainloop
//////////////////////////////////////////////////
// P (Change Pattern)
check_p_hit:
    cmp #$50
    bne check_s_hit
    // TODO: Change Pattern
    jmp mainloop
//////////////////////////////////////////////////
// S (Save File)
check_s_hit:
    cmp #$53
    bne check_1_hit
    jsr save_file
    jmp mainloop
//////////////////////////////////////////////////
// Set relays
check_1_hit:
    cmp #$31
    bne check_2_hit
    // TODO: Set Relay 1
    jmp mainloop
check_2_hit:
    cmp #$32
    bne check_3_hit
    // TODO: Set Relay 2
    jmp mainloop
check_3_hit:
    cmp #$33
    bne check_4_hit
    // TODO: Set Relay 3
    jmp mainloop
check_4_hit:
    cmp #$34
    bne check_5_hit
    // TODO: Set Relay 4
    jmp mainloop
check_5_hit:
    cmp #$35
    bne check_6_hit
    // TODO: Set Relay 5
    jmp mainloop
check_6_hit:
    cmp #$36
    bne check_7_hit
    // TODO: Set Relay 6
    jmp mainloop
check_7_hit:
    cmp #$37
    bne check_8_hit
    // TODO: Set Relay 7
    jmp mainloop
check_8_hit:
    cmp #$38
    bne check_f1_hit
    // TODO: Set Relay 8
    jmp mainloop
//////////////////////////////////////////////////
// F1 (Move Track Position UP)
check_f1_hit:
    cmp #$85
    bne check_f3_hit
    // TODO: Move Track Position UP
    jmp mainloop
//////////////////////////////////////////////////
// F2 (Move Track Position DOWN)
check_f3_hit:
    cmp #$86
    bne check_f5_hit
    // TODO: Move Track Position DOWN
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
.var savefrom = $3000 
.var saveto = $31ff 

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
