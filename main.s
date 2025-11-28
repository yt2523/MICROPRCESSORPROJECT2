;     #include <xc.inc>
;    ; Declare external GLCD routines
;    extrn  GLCD_Init, GLCD_clean_all
;
;    ; Define absolute code section
;    psect   code, abs
;
;    ;Reset vector
;    org     0x0000
;    goto    main            ; Jump to main program
;
;    ; Main program starts here
;    org     0x0100
;main:
;    ; Initialize GLCD
;    call    GLCD_Init
;loop:
;    ; Fill entire GLCD with all pixels ON
;    call    GLCD_clean_all
;    bra     loop
;
;    end  main

    
    #include <xc.inc>

    ;===== ??????? =====
    extrn   GLCD_Init
    extrn   graphic_init
    extrn   logic_map_GLCD_coordinate
    extrn   buffer_SetPixel
    extrn   buffer_to_GLCD

    extrn   ScreenBuffer      ; ?? graphic ?????? buffer

    ; ????? graphic ???????????????????
    extrn   logic_x
    extrn   logic_y

    ;===== ?????????? buffer ?? =====
    psect   udata_acs
ClearCntH: ds 1
ClearCntL: ds 1

    ;===== reset ?? =====
    psect   resetVec, class=CODE, delta=2, abs
    org     0x0000
    goto    MAIN

    ;===== ??? =====
    psect   code, class=CODE, delta=2

;-------------------------------------------------
; ? ScreenBuffer ? 0?1024 ???
;-------------------------------------------------
Clear_ScreenBuffer:
    lfsr    0, ScreenBuffer      ; FSR0 -> buffer ??

    movlw   4
    movwf   ClearCntH, A         ; ???? 4 ???? 256 ????? 1024

ClearOuterLoop:
    clrf    ClearCntL, A         ; ????? 0 ???decfsz ? 256 ??

ClearInnerLoop:
    clrf    INDF0, A             ; ????? 0

    ; FSR0++ ???? +1?
    incf    FSR0L, F, A
    btfsc   STATUS, 0, A 
    incf    FSR0H, F, A

    decfsz  ClearCntL, F, A
    bra     ClearInnerLoop       ; 256 ?

    decfsz  ClearCntH, F, A
    bra     ClearOuterLoop       ; ? 4*256 = 1024 ??

    return

;-------------------------------------------------
; ??????? ? ? buffer ? ????? ? ??
;-------------------------------------------------
MAIN:
    ; 1. ??? GLCD ??? graphic ??
    call    GLCD_Init
    call    graphic_init

    ; 2. ???? ScreenBuffer
    call    Clear_ScreenBuffer

    ; 3. ?????????????? (0,0)
    ;    ????????? (5,10) ?????
    movlw   5
    movwf   logic_x, A       ; x = 0
    movlw   10
    movwf   logic_y, A       ; y = 0

    ; 3.1 ? (logic_x, logic_y) ??? page_/col_/bit_mask
    call    logic_map_GLCD_coordinate

    ; 3.2 ?? ScreenBuffer ????
    call    buffer_SetPixel

    ; 4. ??? buffer ?? GLCD ?
    call    buffer_to_GLCD

Main_Hang:
    bra     Main_Hang        ; ????????

    end
