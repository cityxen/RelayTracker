//////////////////////////////////////////////////////////////////////////
// Relay Tracker Disk Stuff
// Author: Deadline
// 2019-2021 CityXen
//////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////
// Change Filename
change_filename:
    ldx #$00 // Reverse the editing area
fn_reverse:
    lda filename,x
    ora #$80
    sta filename,x
    lda #$01
    sta filename_color,x
    inx
    cpx #$10
    bne fn_reverse
fn_kb_chk: // Check Keyboard loop
    clc
    lda $a2
    cmp #$10
    bcc fn_kb_chk_no_crs
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
fn_kb_chk_no_crs: // End of flash cursor stuff
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
fn_rereverse:   // Done editing, re-reverse all the characters
    lda filename,x
    and #$7f
    sta filename,x
    sta filename_buffer,x
    inx
    cpx #$10
    bne fn_rereverse
    ldx #$00
    ldx #$0f // fill in spaces on end with 0 (start at end and work backward)
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
// Change Drive
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
// Show Disk Directory
show_directory:
    ClearScreen(BLACK)
    lda #dirname_end-dirname
    ldx #<dirname
    ldy #>dirname
    jsr $ffbd      // call setnam
    lda #$02       // filenumber 2
    ldx drive       // default to device number 8
    ldy #$00      // secondary address 0 (required for dir reading!)
    jsr $ffba      // call setlfs
    jsr $ffc0      // call open (open the directory)      
    bcs error     // quit if open failed
    ldx #$02       // filenumber 2
    jsr $ffc6      // call chkin
    ldy #$04       // skip 4 bytes on the first dir line
    bne skip2
next:
    ldy #$02       // skip 2 bytes on all other lines
skip2:  
    jsr getbyte    // get a byte from dir and ignore it
    dey
    bne skip2

    jsr getbyte    // get low byte of basic line number
    tay
    jsr getbyte    // get high byte of basic line number
    pha
    tya            // transfer y to x without changing akku
    tax
    pla
    jsr $bdcd      // print basic line number
    lda #$20       // print a space first
char:
    jsr $ffd2      // call chrout (print character)
    jsr getbyte
    bne char      // continue until end of line

    lda #$0d
    jsr $ffd2      // print return
    jsr $ffe1      // run/stop pressed?
    bne next      // no run/stop -> continue
error:
    // akkumulator contains basic error code
    // most likely error:
    // a = $05 (device not present)
exit:
    lda #$02       // filenumber 2
    jsr $ffc3      // call close
    jsr $ffcc     // call clrchn

    lda #$0d
    jsr KERNAL_CHROUT

    jsr show_drive_status

    ldx #$00
labl22:
    lda dir_presskey,x
    beq sdlabl4
    jsr KERNAL_CHROUT
    inx
    jmp labl22

sdlabl4:
    jsr KERNAL_WAIT_KEY
    beq sdlabl4
    rts

getbyte:
    jsr $ffb7      // call readst (read status byte)
    bne end       // read error or end of file
    jmp $ffcf      // call chrin (read byte from directory)
end:
    pla            // don't return to dir reading loop
    pla
    jmp exit

dirname:
.text "$"
dirname_end:
dir_presskey:
.encoding "screencode_mixed"
.byte 13
.text "PRESS ANY KEY"
.byte 0

////////////////////////////////////////////////////
// Convert Filename for Disk I/O
convert_filename:
    ldx #$00
cfn_labl0:
    lda #$00
    sta filename_save,x
    inx
    cpx #$10
    bne cfn_labl0
cfn_labl2:
    ldx #$00
cfn_labl4:
    lda filename_buffer,x
    cmp #$00
    beq cfn_labl5
    cmp #27
    bcs cfn_dont_add
    adc #$40
cfn_dont_add:
    sta filename_save,x
    inx
    jmp cfn_labl4
cfn_labl5:
    stx filename_length
    rts

////////////////////////////////////////////////////
// Save File
save_file_are_you_sure:
    // Add are you sure prompt here

save_file:
    ClearScreen(BLACK)
    ldx #$00
sv_labl1:
    lda save_saving,x
    beq sv_labl2
    sta SCREEN_RAM,x
    inx
    jmp sv_labl1
sv_labl2:
    jsr convert_filename
  ldx #$00
sv_labl3:
    lda filename_buffer,x
    beq sv_labl4
    sta SCREEN_RAM+7,x
    inx
    cpx #$10
    bne sv_labl3
sv_labl4:
    lda #$0f
    ldx drive
    ldy #$ff
    jsr KERNAL_SETLFS
    lda filename_length
    ldx #<filename_save
    ldy #>filename_save
    jsr KERNAL_SETNAM
    lda #<tracker_data_start // Set Start Address
    sta zp_pointer_lo
    lda #>tracker_data_start
    sta zp_pointer_hi
    ldx #<tracker_data_end // Set End Address
    ldy #>tracker_data_end
    lda #<zp_pointer_lo
    jsr KERNAL_SAVE
    lda #13
    jsr KERNAL_CHROUT
    jsr KERNAL_CHROUT
    jsr show_drive_status
    ldx #$00
sv_labl22:
    lda dir_presskey,x
    beq sv_out
    jsr KERNAL_CHROUT
    inx
    jmp sv_labl22
sv_out:
    jsr KERNAL_WAIT_KEY
    beq sv_out
    rts

save_saving:
.encoding "screencode_mixed"
.text "saving "
.byte 0

////////////////////////////////////////////////////
// Load File
load_file:
    ClearScreen(BLACK)
    ldx #$00
ld_labl1:
    lda load_loading,x
    beq ld_labl2
    sta SCREEN_RAM,x
    inx
    jmp ld_labl1
ld_labl2:
    jsr convert_filename
    ldx #$00
ld_labl3:
    lda filename_buffer,x
    beq ld_labl4
    sta SCREEN_RAM+8,x
    inx
    cpx #$10
    bne ld_labl3
ld_labl4:
    lda #$0f
    ldx drive
    ldy #$ff
    jsr KERNAL_SETLFS
    lda filename_length //#$10
    ldx #<filename_save
    ldy #>filename_save
    jsr KERNAL_SETNAM
    ldx #<tracker_data_start // Set Load Address
    ldy #>tracker_data_start
    lda #00
    jsr KERNAL_LOAD
    lda #13
    jsr KERNAL_CHROUT
    jsr KERNAL_CHROUT
    jsr show_drive_status
    ldx #$00
ld_labl22:
    lda dir_presskey,x
    beq ld_out
    jsr KERNAL_CHROUT
    inx
    jmp ld_labl22
ld_out:
    jsr KERNAL_WAIT_KEY
    beq ld_out
    clc
    lda vic_rel_mode // Check to make sure vic_rel_mode is within bounds
    cmp #$02
    bcc ld_exit
    lda #$00
    sta vic_rel_mode
ld_exit:
    rts

load_loading:
.encoding "screencode_mixed"
.text "loading "
.byte 0

////////////////////////////////////////////////////
// Erase File
erase_file_confirm:
    jsr draw_confirm_question
efc_loop2:
    jsr KERNAL_GETIN
    cmp #$00
    beq efc_loop2
efc_check_y_hit: // Y (Yes New Memory)
    cmp #$59
    beq erase_file
    rts
    // Yes hit... erase the file
erase_file:
    jsr convert_filename
    ldx #$00
ef_cpfn:
    lda filename_save,x
    sta ef_cmd+3,x
    inx
    cpx filename_length
    bne ef_cpfn
    inx
    inx
    inx
    stx zp_temp
    ClearScreen(BLACK)
    ldx #$00
efw_print1:
    lda ef_text,x
    jsr KERNAL_CHROUT
    inx
    cpx #$08
    bne efw_print1
    ldx#$00
efw_print2:
    lda ef_cmd,x
    jsr KERNAL_CHROUT
    inx
    stx zp_temp2
    lda zp_temp
    cmp zp_temp2
    bne efw_print2
    lda #$0d
    jsr KERNAL_CHROUT
    jsr KERNAL_CHROUT
    lda zp_temp
    ldx #<ef_cmd
    ldy #>ef_cmd
    jsr $FFBD     // call SETNAM
    lda #$0F      // file number 15 
    ldx $BA       // last used device number 
    bne ef2skip 
    ldx drive     // default to device 8 
ef2skip:
    ldy #$0F      // secondary address 15 
    jsr $FFBA     // call SETLFS 
    jsr $FFC0     // call OPEN
    jsr show_drive_status
    bcc ef2_noerror     // if carry set, the file could not be opened 
    // Accumulator contains BASIC error code 
    // most likely errors: 
    // A = $05 (DEVICE NOT PRESENT) 
    // ... error handling for open errors ... 
ef2_noerror:
    lda #$0F      // filenumber 15 
    jsr $FFC3     // call CLOSE 
    jsr $FFCC     // call CLRCHN
ef_out:
    jsr KERNAL_WAIT_KEY
    beq ef_out
    rts

ef_text:
.encoding "screencode_mixed"
.text "ERASING "
ef_text_end:
ef_cmd:
.text "S0:" // command string
.byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
ef_cmd_end:

////////////////////////////////////////////////////
// Show Drive Status
show_drive_status:
    lda #$00
    sta $90       // clear status flags
    lda drive     // device number
    jsr $ffb1     // call listen
    lda #$6f      // secondary address 15 (command channel)
    jsr $ff93     // call seclsn (second)
    jsr $ffae     // call unlsn
    lda $90       // get status flags
    bne sds_devnp // device not present
    lda drive     // device number
    jsr $ffb4     // call talk
    lda #$6f      // secondary address 15 (error channel)
    jsr $ff96     // call sectlk (tksa)
sds_loop:
    lda $90       // get status flags
    bne sds_eof   // either eof or error
    jsr $ffa5     // call iecin (get byte from iec bus)
    jsr KERNAL_CHROUT     // call chrout (print byte to screen)
    jmp sds_loop  // next byte
sds_eof:
    jsr $ffab     // call untlk
    rts
sds_devnp:
    //  ... device not present handling ...
    rts
