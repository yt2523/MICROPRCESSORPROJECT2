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
    extrn   logic_map_GLCD_coordinate

    ; Variables from graphic.asm
    extrn   logic_x, logic_y, ClearCntH, ClearCntL
    extrn   circle_r, circle_x, circle_y
    extrn   X_end, Y_end
    extrn   bit_mask, page_, col_, bit_store
    extrn   idxL, idxH

    ; Define absolute code section
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

    ; ===========================================
    ; DEBUG MODE SELECTION:
    ; Comment/uncomment the following lines to choose what to draw
    ; ===========================================
    
    ; ====== OPTION 1: Draw a cross at (25,25) ======
    ; Uncomment the next 2 lines to draw cross
    ;movlw   25
    ;call    draw_cross_at_point

    ; ====== OPTION 2: Draw a circle with r=5 ======
    ; Uncomment the next 2 lines to draw circle
    movlw   5
    call    draw_circle_with_radius

    ; ====== OPTION 3: Draw both ======
    ; Uncomment both sections above to draw both

    ; ====== Add a reference point at (0,0) to verify coordinates ======
    movlw   0
    movwf   logic_x, A
    movwf   logic_y, A
    call    logic_map_GLCD_coordinate
    call    buffer_SetPixel

    ; Update GLCD with buffer contents
    call    buffer_to_GLCD

loop: 
    bra     loop

; ====== Draw cross at specified X coordinate ======
; Input: W register = X coordinate (Y will also be the same)
draw_cross_at_point:
    movwf   X_end, A      ; X coordinate
    movwf   Y_end, A      ; Y coordinate (same as X for (x,x) point)
    call    Draw_cross_point
    return

; ====== Draw circle with specified radius ======
; Input: W register = radius
draw_circle_with_radius:
    movwf   circle_r, A   ; Set radius
    call    Bresenham_circle_loop
    return

; ====== Debug function: Print coordinate mapping ======
; This function can be called to see what the mapping produces
debug_print_mapping:
    ; Save result to specific memory addresses for debugging
    movff   logic_x, 0xF0  ; Save original logic_x
    movff   logic_y, 0xF1  ; Save original logic_y
    
    call    logic_map_GLCD_coordinate
    
    ; Save mapping results
    movff   col_, 0xF2     ; Calculated column
    movff   page_, 0xF3    ; Calculated page
    movff   bit_mask, 0xF4 ; Calculated bit mask
    
    ; Save index calculation
    movff   idxL, 0xF5     ; Index low byte
    movff   idxH, 0xF6     ; Index high byte
    
    return

    end main


