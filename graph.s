#include <xc.inc>
	extrn  GLCD_WriteCommand, GLCD_WriteData
        extrn  GLCD_SelectLeft, GLCD_SelectRight
	extrn  AngleXTable, AngleYTable
    global  ScreenBuffer, logic_x, logic_y,ClearCntH,ClearCntL, idxL,idxH,  bit_mask, page_, col_, bit_store 
    global  graphic_init, logic_map_GLCD_coordinate
    global  buffer_SetPixel, buffer_to_GLCD,Bresenham_circle_loop,Draw_cross_point
    global  circle_r, circle_x, circle_y,X_end, Y_end
    global  buffer_clear_all  ,GetAngleXY,angle_deg
    global  ScreenBuffer,ScreenBuffer2, ScreenBuffer3, ScreenBuffer4
    global  angle_deg


    ;calculation variable
psect   udata_acs
GLCD_CMD_SET_X_BASE      EQU 0xB8
GLCD_CMD_SET_Y_BASE      EQU 0x40
bit_mask:    ds 1  ; draw pixel point position on specifit page (8-bit)(8)
page_:     ds 1  ; draw page on specifit col (8)
col_:      ds 1  ; draw col (x coordiate) (69)
bit_store: ds  1  ; store bit in calculation
idxL:       ds 1  ;store pointer idx for 128*8 buffer  LOW8bits
idxH:       ds 1  ;store pointer idx for 128*8 buffer  High8bits
logic_x:  ds 1  ; logic x coordinate
logic_y:  ds 1  ; logic y coordinate
ClearCntH:   ds 1     ; clear
ClearCntL:   ds 1     ; clear
angle_deg:    ds 2   ;raw data of angle (0-359) 360=0 

    
X_end:      ds 1    ;the x coordinate of end of the line, find in table
Y_end:      ds 1    ;the y coordinate of end of the line,  find in table
X_cur:      ds 1    ;the x coordinate for circle calculation,tmp
Y_cur:      ds 1    ;the y coordinate for circle calculation, tmp
circle_x:   ds 1    ;the x coordinate of edge of circle, reference point for 8 symetric point.
circle_y:   ds 1    ;the y coordinate of edge of circle, reference point for 8 symetric point.
circle_r:   ds 1    ; radius of circle
circle_d:   ds 1      ;desision index d
circle_tmp: ds 1      ; tmp
    
;data in draw line

;64 or 69?????????????????????????????????????????????????????????????????????
    
psect   udata_bank3
ScreenBuffer:   ds 256      ; 8 pages * 128 columns (each store a 8-bit (a page)data
psect   udata_bank4
ScreenBuffer2:   ds 256 
psect   udata_bank5
ScreenBuffer3:   ds 256 
psect   udata_bank6
ScreenBuffer4:   ds 256 
    
     ; angel_table?N = 120?every step= 3°?R = 19
    ; logic center is (0,0)?(X_table[i], Y_table[i]) = the i angle point 
  
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
    clrf  bit_store,A
    CLRF  ClearCntH,A
    CLRF  ClearCntL,A
    clrf X_end,A
    clrf Y_end,A
    clrf X_cur,A
    clrf Y_cur,A

    clrf  FSR1L,A
    clrf  FSR1H,A
      
main_control:
    ;for each points : calculate (x,y), convert to GLCDcoordinate, update in buffer,(or logic )
    ;do it for all logic pixel come from Bresenham method, for both line and circle
    ;update all data in buffer to GLCD,
GetAngleXY:
;     read  X_table[angle_idx]
;     set TBLPTR to AngleXTable 0
    movlw   low highword(AngleXTable)
    movwf   TBLPTRU, A
    movlw   high(AngleXTable)
    movwf   TBLPTRH, A
    movlw   low(AngleXTable)
    movwf   TBLPTRL, A

    ; add idx
    movf    angle_deg, W, A
    addwf   TBLPTRL, F, A      ; ?????
    movlw   0
    addwfc  TBLPTRH, F, A      ; ??????
    addwfc  TBLPTRU, F, A 

    ; read data 
    tblrd*                  
    movf    TABLAT, W, A       ; to W
    movwf   X_end, A           ; to X_end

    ; read Y_table[angle_idx]-
    ; set TBLPTR to AngleYTable 0
    movlw   low highword(AngleYTable)
    movwf   TBLPTRU, A
    movlw   high(AngleYTable)
    movwf   TBLPTRH, A
    movlw   low(AngleYTable)
    movwf   TBLPTRL, A

    ; ddd idx
    movf    angle_deg, W, A
    addwf   TBLPTRL, F, A      ; ?????
    movf    angle_deg+1, W, A
    addwfc  TBLPTRH, F, A      ; ??????
    movlw   0 
    addwfc  TBLPTRU, F, A 

    ; read data
    tblrd*
    movf    TABLAT, W, A       ; to W
    movwf   Y_end, A           ; to X_end
    ; ????? AngleXTable[0]
    
    
    movlw   low highword(AngleXTable)
    movwf   TBLPTRU, A
    movlw   high(AngleXTable)
    movwf   TBLPTRH, A
    movlw   low(AngleXTable)
    movwf   TBLPTRL, A
    
    tblrd*
    movf    TABLAT, W, A
    movwf   X_end, A
    return
    
Draw_cross_point:
    ;get (x,y) pixel points instead of line, 
    ;assume  X_end:  Y_end: already has points
    
    ;draw mid point
    movf    X_end, W, A
    movwf   logic_x, A
    movf    Y_end, W, A
    movwf   logic_y, A

    call    logic_map_GLCD_coordinate
    call    buffer_SetPixel

    ;right (x+1,y)
    movf    X_end, W, A
    movwf   logic_x, A
    incf   logic_x, F ,A     ; logic_x+ 1
    movf    Y_end, W, A
    movwf   logic_y, A

    call    logic_map_GLCD_coordinate
    call    buffer_SetPixel

    ; left (x-1, y)
    movf    X_end, W, A
    movwf   logic_x, A
    decf   logic_x, F, A      ; logic_x- 1
    movf    Y_end, W, A
    movwf   logic_y, A

    call    logic_map_GLCD_coordinate
    call    buffer_SetPixel

    ; up (x, y+1)
    movf    X_end, W, A
    movwf   logic_x, A
    movf    Y_end, W, A    
    movwf   logic_y, A
    incf    logic_y, F,A  ; logic_y+ 1

    call    logic_map_GLCD_coordinate
    call    buffer_SetPixel

    ; down (x, y-1)
    movf    X_end, W, A
    movwf   logic_x, A
    movf    Y_end, W, A
    movwf   logic_y, A
    decf   logic_y, F, A      ; logic_y- 1

    call    logic_map_GLCD_coordinate
    call    buffer_SetPixel

    return
    
;Bresenham_line_loop:
;    ;get (x,y) pixel line 
    

    
Bresenham_circle_loop:
    ;get (x,y) pixel circle
    ;notes that the pixel is not sqaur,so it may not a regular circle.
    ; initialize, start at (0,r)    x = 0, y = r,              
    ;d = 1-r =  M=(1,r-0.5)   for inital deterninant
    clrf    circle_x, A           ; x = 0

    movf    circle_r, W, A
    movwf   circle_y, A           ; y = r
    
    ; circle_d = 5 - 4r  
    movlw   1
    movwf   circle_d, A           ; d = 5
    
    movf    circle_r, W, A        ; W = r
    subwf   circle_d, F, A        ;circle_d = circle_d - W = 1 - r   circle_d

Circle_MainLoop:
    ; while (x < = y) 
    movf    circle_x, W, A
    subwf   circle_y, W, A        ; W = y - x, ???? C
    bc      Circle_DoPoints       ;branch if carry = 1   which is y-x>0
    bra     Circle_Done           ; when y<x, break, return

Circle_DoPoints:
    ; draw eight points first
    call    Circle_Plot_8_sym
    ;get next point
    ; if (d <= 0)  in the circle, only x+1
    movf    circle_d, W, A
    bz      Circle_d_less_zero      ;branch if zero d=0
    btfsc   circle_d, 7, A        ;bit test file, skip if clear
    bra     Circle_d_less_zero       ;bit7 = 1, do not skip

    ; if d > 0 
    ; d = d + 2*(x - y) + 5
    ; tmp = x - y
    movf    circle_x, W, A
    movwf   circle_tmp, A         ; tmp = x
    movf    circle_y, W, A
    subwf   circle_tmp, F, A      ; tmp = x - y  
    ; tmp = 2 * tmp
    movf    circle_tmp, W, A
    addwf  circle_tmp, F, A       ; tmp = 2*(x-y)
    ; tmp = 2*(x-y) + 5
    movlw   5
    addwf   circle_tmp, F, A

    ; d += tep
    movf    circle_tmp, W, A
    addwf   circle_d, F, A

    ;update y (y = y - 1) and x back to loop 
    decf    circle_y, F, A
    bra     Circle_UpdateX

Circle_d_less_zero:
    ;situation d<=0 
    ; d = d + 2*x + 3
    movf    circle_x, W, A
    movwf   circle_tmp, A         ; tmp = x

    ; tmp = 2*x
    movf    circle_tmp, W, A
    addwf   circle_tmp, F, A      ; tmp = 2x
    ; tmp = 2x + 3
    movlw   3
    addwf   circle_tmp, F, A

    ; d += tmp
    movf    circle_tmp, W, A
    addwf   circle_d, F, A

Circle_UpdateX:
    ; x+1
    incf    circle_x, F, A
    
    bra     Circle_MainLoop

Circle_Done:
    return
    

Circle_Plot_8_sym:
    ;use  circle_x, circle_y generate 8  symmetric points
    ; 1(+x, +y)
    movf    circle_x, W, A
    movwf   X_cur, A
    movf    circle_y, W, A
    movwf   Y_cur, A
    call    PlotCirclePoint

    ; 2 (-x, +y)
    movf    circle_x, W, A
    movwf   X_cur, A
    comf    X_cur, F, A      ; X_cur = ~x  0b0000 0101 to 0b1111 1010
    incf    X_cur, F, A      ; X_cur = -x  0b1111 1011 negative
    movf    circle_y, W, A
    movwf   Y_cur, A
    call    PlotCirclePoint

    ; 3 (+x, -y)
    movf    circle_x, W, A
    movwf   X_cur, A
    movf    circle_y, W, A
    movwf   Y_cur, A
    comf    Y_cur, F, A      ; Y_cur = ~y
    incf    Y_cur, F, A      ; Y_cur = -y
    call    PlotCirclePoint

    ; 4 (-x, -y)
    movf    circle_x, W, A
    movwf   X_cur, A
    comf    X_cur, F, A
    incf    X_cur, F, A      ; X_cur = -x
    movf    circle_y, W, A
    movwf   Y_cur, A
    comf    Y_cur, F, A
    incf    Y_cur, F, A      ; Y_cur = -y
    call    PlotCirclePoint

    ; 5 (+y, +x)
    movf    circle_y, W, A
    movwf   X_cur, A
    movf    circle_x, W, A
    movwf   Y_cur, A
    call    PlotCirclePoint

    ; 6 (-y, +x)
    movf    circle_y, W, A
    movwf   X_cur, A
    comf    X_cur, F, A
    incf    X_cur, F, A      ; X_cur = -y
    movf    circle_x, W, A
    movwf   Y_cur, A
    call    PlotCirclePoint

    ; 7 (+y, -x)
    movf    circle_y, W, A
    movwf   X_cur, A
    movf    circle_x, W, A
    movwf   Y_cur, A
    comf    Y_cur, F, A
    incf    Y_cur, F, A      ; Y_cur = -x
    call    PlotCirclePoint

    ; 8 (-y, -x)
    movf    circle_y, W, A
    movwf   X_cur, A
    comf    X_cur, F, A
    incf    X_cur, F, A      ; X_cur = -y
    movf    circle_x, W, A
    movwf   Y_cur, A
    comf    Y_cur, F, A
    incf    Y_cur, F, A      ; Y_cur = -x
    call    PlotCirclePoint

    return

PlotCirclePoint:
    ; put current xy into logic , map ,and buffer
    movf    X_cur, W, A
    movwf   logic_x, A
    movf    Y_cur, W, A
    movwf   logic_y, A

    call    logic_map_GLCD_coordinate
    call    buffer_SetPixel
    return

    
logic_map_GLCD_coordinate:
     ; X_glcd = logic_x + 64
    movf    logic_x, W, A
    addlw   64
    movwf   col_, A          ; col = 0..127    save col

    ; Y_glcd = 31 - logic_y , saveback to logic_y
    movf    logic_y, W, A   ; W = logic_y
    sublw   31              ; W = 31 - W = 31 - logic_y
    movwf   logic_y, A  ; logic_y  to  Y_glcd(still logic but shift) ,  saveback to logic_y

    ; page = Y_glcd %8 remains are pixel
    movf    logic_y, W, A
    movwf   page_, A
    bcf     STATUS, 0,A      ; /2    Rotate Right through Carry    carry=0     b7 b6 b5 b4 b3 b2 b1 b0  to  b0 b7 b6 b5 b4 b3 b2 b1
    rrcf    page_, F, A     
    bcf     STATUS, 0,A      ; /4    b1 b0 b7 b6 b5 b4 b3 b2
    rrcf    page_, F, A  
    bcf     STATUS, 0,A      ; /8  , page = 0..7    b2 b1 b0 b7 b6 b5 b4 b3
    rrcf    page_, F, A

    ; bit = Y_glcd and 0x07
    movf    logic_y, W, A
    andlw   0x07           ;and00000111B,  only 1 and 1 = 1  get last_3_B
    movwf   bit_store, A      ; bit_store = 0..7

    ; bit_mask = 1 << bit_idx
    movlw   0x01         ; as a basis 00000001B
    movwf   bit_mask, A    
    bcf     STATUS, 0, A    ; C = 0????????
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
    ; ????
    clrf    idxL, A
    clrf    idxH, A
    
    ; ?? idx = page_ × 128 + col_
    
    ; idxH = page_ / 2
    movf    page_, W, A
    movwf   idxH, A
    bcf     STATUS, 0, A      ; ??????
    rrcf    idxH, F, A        ; idxH = page_ >> 1
    
    ; ?? page_ ????idxL = 128??? idxL = 0
    btfsc   page_, 0, A       ; ??bit0=0???
    bsf     idxL, 7, A        ; ??idxL?bit7?128?
    
    ; ?? col_?????
    movf    col_, W, A
    addwf   idxL, F, A        ; idxL += col_
    
    ; ??????? idxH
    movlw   0
    btfsc   STATUS, 0, A      ; ????
    movlw   1                 ; ??????W=1
    addwf   idxH, F, A        ; idxH += ??
    
    ; FSR1 = ScreenBuffer + idx
    lfsr    1, ScreenBuffer
    movf    idxL, W, A
    addwf   FSR1L, F, A
    movf    idxH, W, A
    addwfc  FSR1H, F, A
    
    ; ????
    movf    bit_mask, W, A
    iorwf   INDF1, F, A       ; ??OR???
    
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
    movf   POSTINC1,W,A
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
    movf   POSTINC1,W,A
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
    

buffer_clear_all:
    lfsr    1, ScreenBuffer
    movlw   4           ; 4 * 256 = 1024??
    movwf   ClearCntH, A
BC_Outer:
    movlw   0
    movwf   ClearCntL, A  ; 256???
    
BC_Inner:
    clrf    POSTINC1, A   ; ???????
    
    decfsz  ClearCntL, F, A
    bra     BC_Inner
    
    decfsz  ClearCntH, F, A
    bra     BC_Outer
    
    return


