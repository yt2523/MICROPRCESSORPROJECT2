	#include <xc.inc>
	extern  GLCD_Init, GLCD_FillAllOn, GLCD_DrawVerticalCenterLine
	
    ;calculation variable
    psect   udata_acs
bit_mask:    ds 1  ; draw pixel point position on specifit page (8-bit)(8)
page:     ds 1  ; draw page on specifit col (8)
col:      ds 1  ; draw col (x coordiate) (69)
bit_store: ds  1  ; store bit in calculation
logic_x:  ds 1  ; logic x coordinate
logic_y:  ds 1  ; logic y coordinate
    
psect   udata
ScreenBuffer:   ds 1024      ; 8 pages * 128 columns (each store a 8-bit (a page)data
  
psect   graphic_code, class=CODE

main_control:
    ;for each points : calculate (x,y), convert to GLCDcoordinate, update in buffer,(or logic )
    ;do it for all logic pixel come from Bresenham method, for both line and circle
    ;update all data in buffer to GLCD,
Bresenham_line_loop:
    ;get (x,y) pixel line
    
Bresenham_circle_loop:
    ;get (x,y) pixel circle

logic_map_GLCD_coordinate:
     ; X_glcd = logic_x + 64
    movf    logic_x, W, A
    addlw   64
    movwf   col, A          ; col = 0..127    save col

    ; Y_glcd = 31 - logic_y , saveback to logic_y
    movlw   31
    subwf   logic_y, W, A   ; W = 31 - logic_y
    movwf   logic_y, A  ; logic_y  to  Y_glcd(still logic but shift) ,  saveback to logic_y

    ; page = Y_glcd %8 remains are pixel
    movf    logic_y, W, A
    movwf   page, A
    bcf     STATUS, C      ; /2    Rotate Right through Carry    carry=0     b7 b6 b5 b4 b3 b2 b1 b0  to  b0 b7 b6 b5 b4 b3 b2 b1
    rrcf    page, F, A     
    bcf     STATUS, C      ; /4    b1 b0 b7 b6 b5 b4 b3 b2
    rrcf    page, F, A  
    bcf     STATUS, C       ; /8  , page = 0..7    b2 b1 b0 b7 b6 b5 b4 b3
    rrcf    page, F, A

    ; bit = Y_glcd and 0x07
    movf    logic_y, W, A
    andlw   0x07           ;and00000111B,  only 1 and 1 = 1  get last_3_B
    movwf   bit_store, A      ; bit_store = 0..7

    ; bit_mask = 1 << bit_idx
    movlw   0x01         ; as a basis 00000001B
    movwf   bit_mask, A    
BitMaskLoop:
    decfsz  bit_idx, F, A    ;decrease until zero
    rlcf    bit_mask, F, A    ;00000001B to 00000010B
    bnz     BitMaskLoop

    return
    ;tansfer (x,y) to pixel page col
    
buffer_SetPixel:
    ;given pixel page col, update one pixel in buffer
    
buffer_to_GLCD:
    ;write all data in buffer frame to GLCD
    


