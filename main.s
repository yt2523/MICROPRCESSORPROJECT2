#include <xc.inc>
    ; Declare external GLCD routines
    extrn  GLCD_Init, GLCD_clean_all
    extrn  graphic_init, buffer_to_GLCD
    extrn  Bresenham_circle_loop
    extrn  Draw_cross_point
    extrn   graphic_init
    extrn   buffer_clear_all
    extrn   buffer_SetPixel
    extrn   buffer_to_GLCD
    extrn   logic_map_GLCD_coordinate, GetAngleXY

    ; Variables from graphic.asm
    extrn   logic_x, logic_y, ClearCntH, ClearCntL
    extrn   circle_r, circle_x, circle_y
    extrn   X_end, Y_end
    extrn   bit_mask, page_, col_, bit_store
    extrn   idxL, idxH, angle_deg

 ;Define absolute code section
    psect   code, abs

    ; Reset vector
    org     0x0000
    goto    main

    ; Main program starts here
    org     0x0010

main:
    ; Initialize GLCD and graphics
    call    GLCD_Init
    call    graphic_init
    call    GLCD_clean_all 
    
    ; Clear the screen buffer
    call    buffer_clear_all

  TestAngleConversion:
    ; ????????
    
    ; ??0?
    movlw   0
    movwf   angle_deg, A
    call    GetAngleXY
    ; angle_idx ???0
    
    ; ??90?
    movlw   90
    movwf   angle_deg, A
    call    GetAngleXY
    ; angle_idx ???30 (90/3=30)
    
    ; ??180?
    movlw   180
    movwf   angle_deg, A
    call    GetAngleXY
    ; angle_idx ???60
    
    ; ??359?
    movlw   359         ; 359????
    movwf   angle_deg, A
    call    GetAngleXY
    ; angle_idx ???119 (359/3=119?2)
    
    return

move:
    movff   X_end, 0x100
    movff   Y_end, 0x101  
    bra   move
    end main
