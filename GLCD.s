
        #include <xc.inc>

        global  GLCD_Init, GLCD_FillAllOn

        ; control variable
GLCD_E      EQU 0        ; PORTE,0  ? Enable
GLCD_DI     EQU 1        ; PORTE,1  ? D/I (1=Data, 0=Instruction) ??????
GLCD_RW     EQU 2        ; PORTE,2  ? R/W (0=Write)  ???????
GLCD_CS1    EQU 3        ; PORTE,3  ? Chip select 1 (???)
GLCD_CS2    EQU 4        ; PORTE,4  ? Chip select 2 (???)
GLCD_RST    EQU 5        ; PORTE,5  ? Reset

        ;check the adress  ?????????
GLCD_CMD_DISPLAY_ON      EQU 0x3F   ; Display ON
GLCD_CMD_DISPLAY_OFF     EQU 0x3E   ; Display OFF
GLCD_CMD_SET_Y_BASE      EQU 0x40   ; 0x40 + column (0?63)
GLCD_CMD_SET_X_BASE      EQU 0xB8   ; 0xB8 + page   (0?7)
GLCD_CMD_SET_START_BASE  EQU 0xC0   ; 0xC0 + line   (?? 0)

        ;variable
        psect   udata_acs
GLCD_page:     ds 1
GLCD_col:      ds 1
GLCD_cnt_l:    ds 1
GLCD_cnt_h:    ds 1
GLCD_cnt_ms:   ds 1


        ;code
        psect   glcd_code, class=CODE

GLCD_Init:
        ; init data output all zero
        clrf    LATE, A  ;00000000B
        clrf    LATF, A

        clrf    TRISE, A          ; PORTE as output contral signal
        clrf    TRISF, A          ; PORTF as output data

        ; delay 
        movlw   20
        call    GLCD_delay_ms

        ; ?????RST ????????
        bcf     LATE, GLCD_RST, A
        movlw   2                 ; 2ms
        call    GLCD_delay_ms
        bsf     LATE, GLCD_RST, A

        ; ??????CS1 ???CS2 ?????????????????StartLine=0
        call    GLCD_SelectLeft

        ; Start line = 0
        movlw   GLCD_CMD_SET_START_BASE | 0x00
        call    GLCD_WriteCommand

        ; Display ON
        movlw   GLCD_CMD_DISPLAY_ON
        call    GLCD_WriteCommand

        ;?????? CS2 
        call    GLCD_SelectRight

        movlw   GLCD_CMD_SET_START_BASE | 0x00
        call    GLCD_WriteCommand

        movlw   GLCD_CMD_DISPLAY_ON
        call    GLCD_WriteCommand

        return


;------------------------------------------------------------
;  ?????GLCD_FillAllOn
;  - ?? page = 0..7
;  - ??????????? 64 ?? 0xFF
	;?????????
;------------------------------------------------------------
GLCD_FillAllOn:
        clrf    GLCD_page, A      ; page = 0

GLCD_PageLoop:
        ;============== ?????? page ======================
        call    GLCD_SelectLeft

        ; ?? X (page)
        movf    GLCD_page, W, A
        addlw   GLCD_CMD_SET_X_BASE
        call    GLCD_WriteCommand

        ; ?????? 0
        movlw   GLCD_CMD_SET_Y_BASE | 0x00
        call    GLCD_WriteCommand

        ; ?? 64 ?
        clrf    GLCD_col, A       ; col = 0
GLCD_LeftColLoop:
        movlw   0xFF              ; ??? 8 ?????
        call    GLCD_WriteData

        incf    GLCD_col, F, A
        movlw   64
        cpfseq  GLCD_col, A       ; ?? col != 64???
        bra     GLCD_LeftColLoop

        ;============== ?????? page ======================
        call    GLCD_SelectRight

        ; ???? X (page)
        movf    GLCD_page, W, A
        addlw   GLCD_CMD_SET_X_BASE
        call    GLCD_WriteCommand

        ; ?? 0 ??
        movlw   GLCD_CMD_SET_Y_BASE | 0x00
        call    GLCD_WriteCommand

        clrf    GLCD_col, A
GLCD_RightColLoop:
        movlw   0xFF
        call    GLCD_WriteData

        incf    GLCD_col, F, A
        movlw   64
        cpfseq  GLCD_col, A
        bra     GLCD_RightColLoop

        ;============== ??? ================================
        incf    GLCD_page, F, A
        movlw   8
        cpfseq  GLCD_page, A      ; page ? 8 ??
        bra     GLCD_PageLoop

        return

;------------------------------------------------------------
;  ???? / ???
;------------------------------------------------------------
GLCD_SelectLeft:
        bcf     LATE, GLCD_CS1, A     ; CS1 = 0 ? ??  bit clear to 0
        bsf     LATE, GLCD_CS2, A     ; CS2 = 1 ? ???  bit set 1
        return

GLCD_SelectRight:
        bsf     LATE, GLCD_CS1, A
        bcf     LATE, GLCD_CS2, A
        return

;W/R command/Data
GLCD_WriteCommand:           ; ???? W ?? cmd
        bcf     LATE, GLCD_DI, A  ;D/I = 0  I
        bcf     LATE, GLCD_RW, A  ;R/W = 0  W

        movwf   LATF, A      ; ???????

        ; ?? E ??   3 us  1 nop=1us
        bsf     LATE, GLCD_E, A
        nop
        nop
        nop
        bcf     LATE, GLCD_E, A

        ; ?????? 4us
        movlw   1
        call    GLCD_delay_x4us
        return

GLCD_WriteData:              ;  data in W
        ; D/I = 1 (??), R/W = 0 (?)
        bsf     LATE, GLCD_DI, A ;D/I = 1  D
        bcf     LATE, GLCD_RW, A

        movwf   LATF, A

        bsf     LATE, GLCD_E, A
        nop
        nop
        nop
        bcf     LATE, GLCD_E, A

        movlw   1
        call    GLCD_delay_x4us
        return

;============================================================
;  delay DLCD
;============================================================
GLCD_delay_ms:               ; delay in ms in W
        movwf   GLCD_cnt_ms, A
GLCD_lpm2:
        movlw   250           ; 1 ms delay
        call    GLCD_delay_x4us
        decfsz  GLCD_cnt_ms, A
        bra     GLCD_lpm2
        return

GLCD_delay_x4us:             ; delay in chunks of 4us in W
        movwf   GLCD_cnt_l, A
        swapf   GLCD_cnt_l, F, A
        movlw   0x0f
        andwf   GLCD_cnt_l, W, A
        movwf   GLCD_cnt_h, A
        movlw   0xf0
        andwf   GLCD_cnt_l, F, A
        call    GLCD_delay
        return

GLCD_delay:                  ; 4-instruction loop ? 250ns
        movlw   0x00
GLCD_lpm1:
        decf    GLCD_cnt_l, F, A
        subwfb  GLCD_cnt_h, F, A
        bc      GLCD_lpm1
        return

        end



