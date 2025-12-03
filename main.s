#include <xc.inc>
    ; Declare external GLCD routines
    extrn  GLCD_Init, GLCD_clean_all
    extrn  graphic_init, buffer_to_GLCD
    extrn  Bresenham_circle_loop
    extrn   graphic_init
    extrn   buffer_clear_all
    extrn   buffer_SetPixel
    extrn   buffer_to_GLCD
    extrn   logic_map_GLCD_coordinate

    ; Variables from other file
    extrn  circle_r, circle_x, circle_y
    extrn   logic_x, logic_y, ClearCntH, ClearCntL
    extrn    ScreenBuffer, ScreenBuffer2, ScreenBuffer3, ScreenBuffer4
    extrn   bit_mask, page_, col_, bit_store  ; ????????
    extrn   idxH, idxL

    ; Debug variables - ?????????
    psect   udata_acs
debug_col:    ds 1  ; ???
debug_page:   ds 1  ; ???
debug_mask:   ds 1  ; ???
debug_index:  ds 2  ; ????? (idxH:idxL)

    ; Define absolute code section
    psect   code, abs

    ; Reset vector
    org     0x0000
    goto    main            ; Jump to main program

    ; Main program starts here
    org     0x0010

main:
    call    GLCD_Init
    call    graphic_init
    call    GLCD_clean_all 
    call    buffer_clear_all

    ; ====== ?????? ======
    
    ; ???1: ??? (0,0)
    movlw   0
    movwf   logic_x, A
    movlw   0
    movwf   logic_y, A
    call    test_coordinate_mapping
    
    ; ???2: ??? (63,31)
    movlw   63
    movwf   logic_x, A
    movlw   31
    movwf   logic_y, A
    call    test_coordinate_mapping
    
    ; ???3: ??? (-64,-32)
    movlw   -64  ; ???-64????0xC0 (256-64=192)
    movwf   logic_x, A
    movlw   -32  ; -32????0xE0 (256-32=224)
    movwf   logic_y, A
    call    test_coordinate_mapping
    
    ; ???4: (10,10)
    movlw   10
    movwf   logic_x, A
    movlw   10
    movwf   logic_y, A
    call    test_coordinate_mapping
    
    ; ???5: (-10,-10)
    movlw   -10  ; 0xF6
    movwf   logic_x, A
    movlw   -10  ; 0xF6
    movwf   logic_y, A
    call    test_coordinate_mapping
    
    ; ====== ?????? ======
    
    ; ???????????????
    ; 1. ???
    movlw   0
    movwf   logic_x, A
    movlw   0
    movwf   logic_y, A
    call    logic_map_GLCD_coordinate
    call    buffer_SetPixel
    
    ; 2. ???? (???????)
    movlw   63
    movwf   logic_x, A
    movlw   0
    movwf   logic_y, A
    call    logic_map_GLCD_coordinate
    call    buffer_SetPixel
    
    ; 3. ???? (???????)
    movlw   -64
    movwf   logic_x, A
    movlw   0
    movwf   logic_y, A
    call    logic_map_GLCD_coordinate
    call    buffer_SetPixel
    
    ; 4. ???
    movlw   0
    movwf   logic_x, A
    movlw   31
    movwf   logic_y, A
    call    logic_map_GLCD_coordinate
    call    buffer_SetPixel
    
    ; 5. ???
    movlw   0
    movwf   logic_x, A
    movlw   -32
    movwf   logic_y, A
    call    logic_map_GLCD_coordinate
    call    buffer_SetPixel
    
    ; ???GLCD
    call    buffer_to_GLCD

loop: 
    bra     loop

; ====== ???????? ======
; ??: logic_x, logic_y
; ??: ???????debug????????
test_coordinate_mapping:
    ; ????logic_x, logic_y
    movff   logic_x, 0x100  ; ???????????
    movff   logic_y, 0x101
    
    ; ??????
    call    logic_map_GLCD_coordinate
     ; ???????debug??
    movff   col_, 0x102
    movff   page_, 0x103
    movff   bit_mask, 0x104
    
    ; ????????
    movff   idxL, 0x105
    movff   idxH, 0x106
;    ; ???????debug??
;    movff   col_, debug_col
;    movff   page_, debug_page
;    movff   bit_mask, debug_mask
;    
;    ; ????????
;    movff   idxL, debug_index
;    movff   idxH, debug_index+1
    
    ; ????
    call    buffer_SetPixel
    
    return

    end main