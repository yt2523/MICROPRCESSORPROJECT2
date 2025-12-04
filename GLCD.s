; GLCD ?????????? -> PORTD, ?? -> PORTB
    #include <xc.inc>

    global  GLCD_Init, GLCD_clean_all
    global  GLCD_SelectLeft,  GLCD_SelectRight,GLCD_WriteData,GLCD_WriteCommand

    ; control variable (bit numbers remain same)
    psect udata_acs
GLCD_E      EQU 4        ; RB0 ? Enable
GLCD_DI     EQU 2        ; RB1 ? D/I (1=Data,0=Instruction)
GLCD_RW     EQU 3        ; RB2 ? R/W
GLCD_CS1    EQU 0        ; RB3 ? CS1
GLCD_CS2    EQU 1        ; RB4 ? CS2
GLCD_RST    EQU 5        ; RB5 ? Reset

GLCD_CMD_DISPLAY_ON      EQU 0x3F
GLCD_CMD_DISPLAY_OFF     EQU 0x3E
GLCD_CMD_SET_Y_BASE      EQU 0x40
GLCD_CMD_SET_X_BASE      EQU 0xB8
GLCD_CMD_SET_START_BASE  EQU 0xC0

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
    ; ????????????
    movlw   0xFF
    movwf   ANCON0, A
    movwf   ANCON1, A

    ; init data/control outputs all zero
    clrf    LATB, A      ; control on PORTB
    clrf    LATD, A      ; data on PORTD

    clrf    TRISB, A     ; PORTB as outputs for control signals
    clrf    TRISD, A     ; PORTD as outputs for data bus

    ; small delay
    movlw   20
    call    GLCD_delay_ms

    ; Reset pulse (on RB5)
    bcf     LATB, GLCD_RST, A
    movlw   2
    call    GLCD_delay_ms
    bsf     LATB, GLCD_RST, A

    ; Select left chip (uses PORTB CS bits)
    call    GLCD_SelectLeft

    ; Start line = 0
    movlw   GLCD_CMD_SET_START_BASE | 0x00
    call    GLCD_WriteCommand

    movlw   GLCD_CMD_DISPLAY_ON
    call    GLCD_WriteCommand

    call    GLCD_SelectRight
    movlw   GLCD_CMD_SET_START_BASE | 0x00
    call    GLCD_WriteCommand
    movlw   GLCD_CMD_DISPLAY_ON
    call    GLCD_WriteCommand

    return

;------------------------------------------------------------
GLCD_clean_all:
    clrf    GLCD_page, A

GLCD_PageLoop:
    call    GLCD_SelectLeft

    movf    GLCD_page, W, A
    addlw   GLCD_CMD_SET_X_BASE
    call    GLCD_WriteCommand
    movlw   2
    call    GLCD_delay_x4us

    movlw   GLCD_CMD_SET_Y_BASE | 0x00
    call    GLCD_WriteCommand
    movlw   2
    call    GLCD_delay_x4us

    clrf    GLCD_col, A
GLCD_LeftColLoop:
    movlw   0x00
    call    GLCD_WriteData

    incf    GLCD_col, F, A
    movlw   64
    cpfseq  GLCD_col, A
    bra     GLCD_LeftColLoop

    call    GLCD_SelectRight

    movf    GLCD_page, W, A
    addlw   GLCD_CMD_SET_X_BASE
    call    GLCD_WriteCommand
    movlw   2
    call    GLCD_delay_x4us

    movlw   GLCD_CMD_SET_Y_BASE | 0x00
    call    GLCD_WriteCommand
    movlw   2
    call    GLCD_delay_x4us

    clrf    GLCD_col, A
GLCD_RightColLoop:
    movlw   0x00
    call    GLCD_WriteData

    incf    GLCD_col, F, A
    movlw   64
    cpfseq  GLCD_col, A
    bra     GLCD_RightColLoop

    incf    GLCD_page, F, A
    movlw   8
    cpfseq  GLCD_page, A
    bra     GLCD_PageLoop

    return

GLCD_SelectLeft:
    ; CS1 = 0 (select), CS2 = 1 (deselect) - use PORTB bits
    bcf     LATB, GLCD_CS1, A
    bsf     LATB, GLCD_CS2, A
    movlw   2
    call    GLCD_delay_x4us
    return

GLCD_SelectRight:
    bsf     LATB, GLCD_CS1, A
    bcf     LATB, GLCD_CS2, A
    movlw   2
    call    GLCD_delay_x4us
    return

; W/R command/Data
GLCD_WriteCommand:
    bcf     LATB, GLCD_DI, A  ; D/I = 0 (instruction)
    bcf     LATB, GLCD_RW, A  ; R/W = 0 (write)

    movwf   LATD, A           ; ?? PORTD??????

    bsf     LATB, GLCD_E, A
    nop
    nop
    nop
    bcf     LATB, GLCD_E, A

    movlw   2
    call    GLCD_delay_x4us
    return

GLCD_WriteData:
    bsf     LATB, GLCD_DI, A ; D/I = 1 (data)
    bcf     LATB, GLCD_RW, A

    movwf   LATD, A

    bsf     LATB, GLCD_E, A
    nop
    nop
    nop
    bcf     LATB, GLCD_E, A

    movlw   2
    call    GLCD_delay_x4us
    return

; delays (unchanged)
GLCD_delay_ms:
    movwf   GLCD_cnt_ms, A
GLCD_lpm2:
    movlw   250
    call    GLCD_delay_x4us
    decfsz  GLCD_cnt_ms, A
    bra     GLCD_lpm2
    return

GLCD_delay_x4us:
    movwf   GLCD_cnt_l, A
    swapf   GLCD_cnt_l, F, A
    movlw   0x0f
    andwf   GLCD_cnt_l, W, A
    movwf   GLCD_cnt_h, A
    movlw   0xf0
    andwf   GLCD_cnt_l, F, A
    call    GLCD_delay
    return

GLCD_delay:
    movlw   0x00
GLCD_lpm1:
    decf    GLCD_cnt_l, F, A
    subwfb  GLCD_cnt_h, F, A
    bc      GLCD_lpm1
    return

    end