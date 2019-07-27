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
    jsr KERNAL_GETIN
check_space_hit: // DEFAULT EXPRESSION
    cmp #$20
    bne check_dollar_hit
    // do space
    jmp mainloop
//////////////////////////////////////////////////////////
// show directory
check_dollar_hit:
    cmp #$24
    bne check_a_hit
    jsr show_directory
    jsr draw_screen
    jmp mainloop
check_a_hit:
    cmp #$41
    bne check_b_hit
    // do q
    jmp mainloop
check_b_hit:
    cmp #$42
    bne check_c_hit
    // do q
    jmp mainloop
check_c_hit:
    cmp #$43
    bne check_d_hit
    // do w
    jmp mainloop
//////////////////////////////////////////////////
// change drive
check_d_hit:
    cmp #$44
    bne check_e_hit
    jsr change_drive
    jmp mainloop
//////////////////////////////////////////////////
// 
check_e_hit:
    cmp #$45
    bne check_f_hit
    // do e
    jmp mainloop
//////////////////////////////////////////////////
// change filename
check_f_hit:
    cmp #$46
    bne check_r_hit
    jsr change_filename
    jmp mainloop
check_r_hit:
    cmp #$52
    bne check_s_hit
    // do r
    jmp mainloop
//////////////////////////////////////////////////
// save file
check_s_hit:
    cmp #$53
    bne check_0_hit
    jsr save_file
    jmp mainloop    
check_0_hit:
    cmp #$30
    bne check_1_hit
    // do 1
    jmp mainloop
check_1_hit:
    cmp #$31
    bne check_2_hit
    // do 1
    jmp mainloop
check_2_hit:
    cmp #$32
    bne check_3_hit
    // do 2
    jmp mainloop
check_3_hit:
    cmp #$33
    bne check_4_hit
    // do 3
    jmp mainloop
check_4_hit:
    cmp #$34
    bne check_5_hit
    // do 4
    jmp mainloop
check_5_hit:
    cmp #$35
    bne check_6_hit
    // do 5
    jmp mainloop
check_6_hit:
    cmp #$36
    // do 6
    jmp mainloop
check_7_hit:
    cmp #$37
    bne check_8_hit
    // do 7
    jmp mainloop
check_8_hit:
    cmp #$38
    bne check_9_hit
    // do 8
    jmp mainloop
check_9_hit:
    cmp #$39
    bne check_keys_done
    // do 9
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
    cpx #$0f
    bne init_fn_loop
    rts
initial_filename:
.text "filename.dat    "

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
    ldx #00
ds_fn_loop:
    lda filename_buffer,x
    sta filename,x
    inx
    cpx #$0f
    bne ds_fn_loop
    rts

////////////////////////////////////////////////////
// change filename
change_filename:
    ldx #00
    stx filename_cursor
fn_reverse:
    lda filename,x
    ora #$80
    sta filename,x
    lda #$01
    sta filename_color,x
    inx
    cpx #$0f
    bne fn_reverse
fn_kb_chk:
    jsr KERNAL_GETIN
    cmp #$00
    beq fn_kb_chk
    cmp #13
    beq fn_kb_chk_end
    cmp #20
    bne fn_kb_chk_not_del
    ldx filename_cursor
    cpx #$00
    beq fn_kb_chk
    lda #$a0
    dec filename_cursor
    ldx filename_cursor
    sta filename,x
    jmp fn_kb_chk
fn_kb_chk_not_del:
    cmp #64
    bcc fn_kb_num
    sbc #64
fn_kb_num:
    ldx filename_cursor
    cpx #15
    beq fn_kb_too_long
    ora #$80
    sta filename,x
    inc filename_cursor
fn_kb_too_long:
    jmp fn_kb_chk
fn_kb_chk_end:
    ldx #00
fn_rereverse:
    lda filename,x
    and #$7f
    sta filename,x
    sta filename_buffer,x
    inx
    cpx #$0f
    bne fn_rereverse
    ldx #$00
    rts

////////////////////////////////////////////////////
// change drive
change_drive:
    inc drive
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
        jsr $ffbd      // set filename "$"
        lda drive
        sta $ba
        lda #$60
        sta $b9        // secondary chn
        jsr $f3d5      // open for serial bus devices
        jsr $f219      // set input device
        ldy #$04
labl1:  jsr $ee13      // input byte on serial bus
        dey
        bne labl1      // get rid of y bytes
        lda $c6        // key pressed?
        ora $90        // or eof?
        bne labl2      // if yes exit
        jsr $ee13      // now get in ax the dimension
        tax            // of the file
        jsr $ee13
        jsr $bdcd      // print number from ax
labl3:  jsr $ee13      // now the filename
        jsr $e716      // put a character to screen
        bne labl3      // while not 0 encountered
        jsr $aad7      // put a cr , end line
        ldy #$02       // set 2 bytes to skip
        bne labl1      // repeat
labl2:  jsr $f642      // close serial bus device
        jsr $f6f3      // restore i/o devices to default
labl4:  jsr $f142      // w8 a key
        beq labl4
        rts
dirname:
.text "$"

////////////////////////////////////////////////////
// save file
save_file:

.var tmpalow = $fb 
.var tmpahigh = $fc 
.var savefrom = $3000 
.var saveto = $37ff 

   lda #$0f
   ldx drive
   ldy #$ff
   jsr $ffba // SETLFS
    
   lda #$0f
   ldx #<filename_buffer
   ldy #>filename_buffer
   jsr $ffbd // SETNAM
    
   lda #<savefrom      // Set Start Address
   sta tmpalow
   lda #>savefrom
   sta tmpahigh
    
   ldx #<saveto   // Set End Address 
   ldy #>saveto 
    
   lda #<tmpalow
    
   jsr $ffd8   // Save 
    
   rts 


