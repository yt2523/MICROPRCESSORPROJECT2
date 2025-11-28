	#include <xc.inc>
	extrn  GLCD_WriteCommand, GLCD_WriteData
        extrn  GLCD_SelectLeft, GLCD_SelectRight
    global  ScreenBuffer, logic_x, logic_y
    global  graphic_init, logic_map_GLCD_coordinate
    global  buffer_SetPixel, buffer_to_GLCD


GLCD_CMD_SET_X_BASE      EQU 0xB8
GLCD_CMD_SET_Y_BASE      EQU 0x40

    ;calculation variable
    psect   udata_acs
bit_mask:    ds 1  ; draw pixel point position on specifit page (8-bit)(8)
page_:     ds 1  ; draw page on specifit col (8)
col_:      ds 1  ; draw col (x coordiate) (69)
bit_store: ds  1  ; store bit in calculation
idxL:       ds 1  ;store pointer idx for 128*8 buffer  LOW8bits
idxH:       ds 1  ;store pointer idx for 128*8 buffer  High8bits
logic_x:  ds 1  ; logic x coordinate
logic_y:  ds 1  ; logic y coordinate

;64 or 69?????????????????????????????????????????????????????????????????????
    
psect   udata
ScreenBuffer:   ds 1024      ; 8 pages * 128 columns (each store a 8-bit (a page)data
  
psect   graphic_code, class=CODE

graphic_init:
    ;clean all varables
    clrf bit_mask,A
    clrf page_,A
    clrf col_,A
    clrf bit_store,A
    clrf idxL,A
    clrf idxH,A
    clrf logic_x,A
    clrf logic_y,A

    clrf  FSR1L,A
    clrf  FSR1H,A
    
    
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
    movwf   col_, A          ; col = 0..127    save col

    ; Y_glcd = 31 - logic_y , saveback to logic_y
    movlw   31
    subwf   logic_y, W, A   ; W = 31 - logic_y
    movwf   logic_y, A  ; logic_y  to  Y_glcd(still logic but shift) ,  saveback to logic_y

    ; page = Y_glcd %8 remains are pixel
    movf    logic_y, W, A
    movwf   page_, A
    bcf     STATUS, C      ; /2    Rotate Right through Carry    carry=0     b7 b6 b5 b4 b3 b2 b1 b0  to  b0 b7 b6 b5 b4 b3 b2 b1
    rrcf    page_, F, A     
    bcf     STATUS, C      ; /4    b1 b0 b7 b6 b5 b4 b3 b2
    rrcf    page_, F, A  
    bcf     STATUS, C       ; /8  , page = 0..7    b2 b1 b0 b7 b6 b5 b4 b3
    rrcf    page_, F, A

    ; bit = Y_glcd and 0x07
    movf    logic_y, W, A
    andlw   0x07           ;and00000111B,  only 1 and 1 = 1  get last_3_B
    movwf   bit_store, A      ; bit_store = 0..7

    ; bit_mask = 1 << bit_idx
    movlw   0x01         ; as a basis 00000001B
    movwf   bit_mask, A    
BitMaskLoop:
     ; bit_store = 0? BitMaskDone,return
    movf    bit_store, W, A
    bz      BitMaskDone

    ; left shift 
    rlcf    bit_mask, F, A
    decfsz  bit_store, F, A
    bra     BitMaskLoop
 
BitMaskDone:
    return
    ;tansfer (x,y) to pixel page col
    
buffer_SetPixel:
    ;given pixel page col, update one pixel in buffer
    lfsr    1, ScreenBuffer     ;make FSR1 point to ScreenBuffer[0], ?FSR1 or FSR0 difference?
    ;1.calculate  pointer idx(idxH:idxL)  
    ;idx = page * 128 + col
    movf    page_, W, A           ; W = page
    movwf   idxH, A              ; idxH = page  idx = page *256, now 128=2^7
    ;idxH right shift /2?carry zero
    bcf     STATUS, C, A
    rrcf    idxH, F, A       ; idxH = page_ >> 1   (page_/2)
    ; idxL ?page??????????????0
    movf    page_, W, A           ; W = page
    clrf    idxL, A              ; idxL = 0  
    btfss   page_, 0, A      ; if last bit is 1?skip to full pointer index
    bra     idx_pointng
    movlw   10000000B
    movwf   idxL, A ;last digit is zero, idxL = 1000 0000b = 128
idx_pointng:  
    ;add col number
    movf    col_, W, A
    addwf   idxL, F, A          add to l 
    addwfc  idxH, F, A          carry to H
    ;2.FSR1 = &ScreenBuffer[0] + idx
    movf idxL, W, A 
    addwf FSR1L, F, A 
    movf idxH, W, A 
    addwfc FSR1H, F, A
    ;3. buffer[page][col] |= bit_mask
    movf    INDF1, W, A          ; read byte in this position of buffer
    iorwf   bit_mask, W, A       ; Inclusive OR ,write in W  W = old | bit_mask
    movwf   INDF1, A             ; write back to the position in buffer
    
    return
 
buffer_to_GLCD:
    ;write all data in buffer frame to GLCD

    lfsr    1, ScreenBuffer   ; FSR1 ?? buffer ??

    clrf    page_, A          ; page_ = 0

BTG_PageLoop:
    ; left screen
    call    GLCD_SelectLeft

    movf    page_, W, A
    addlw   GLCD_CMD_SET_X_BASE
    call    GLCD_WriteCommand

    movlw   GLCD_CMD_SET_Y_BASE | 0x00
    call    GLCD_WriteCommand

    clrf    col_, A
BTG_LeftColLoop:
    movf    POSTINC1, W, A    ; read a byte from buffer?FSR1++
    call    GLCD_WriteData

    incf    col_, F, A
    movlw   64                
    cpfseq  col_, A
    bra     BTG_LeftColLoop

    ; right screen
    call    GLCD_SelectRight

    movf    page_, W, A
    addlw   GLCD_CMD_SET_X_BASE
    call    GLCD_WriteCommand

    movlw   GLCD_CMD_SET_Y_BASE | 0x00
    call    GLCD_WriteCommand

    clrf    col_, A
BTG_RightColLoop:
    movf    POSTINC1, W, A
    call    GLCD_WriteData

    incf    col_, F, A
    movlw   64                
    cpfseq  col_, A
    bra     BTG_RightColLoop

    ; next page
    incf    page_, F, A
    movlw   8
    cpfseq  page_, A
    bra     BTG_PageLoop

    return
    


