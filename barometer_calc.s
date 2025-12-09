#include <xc.inc>

global  Baro_DoCalculation
global	delta_h
global	delta_l
global	delta_tmp_h
global	delta_tmp_l
global	baro_p_h
global	baro_p_l
global	baro_base_h
global	baro_base_l
global	zoom_h
global	zoom_l
;extrn  baro_p_h, baro_p_l
;extrn  baro_base_h, baro_base_l
;extrn  zoom_h, zoom_l

psect   udata_acs
delta_h:    ds 1
delta_l:    ds 1
delta_tmp_h: ds 1
delta_tmp_l: ds 1
baro_p_h:      ds 1
baro_p_l:      ds 1
baro_base_h:   ds 1
baro_base_l:   ds 1
zoom_h:        ds 1
zoom_l:        ds 1

psect   q_code, class=code

; right shift
ARITH_SHIFT_RIGHT MACRO
    bcf     STATUS, 0           ; clean
    btfsc   delta_h, 7          ; check bit7
    bsf     STATUS, 0           ; if negative,let C=1
    rrcf    delta_h, F, A       ; right shift
    rrcf    delta_l, F, A       
ENDM

Baro_DoCalculation:
    ; delta pressure = base - current
    movff   baro_base_h, delta_h
    movff   baro_base_l, delta_l
    
    movf    baro_p_l, W, A
    subwf   delta_l, F, A
    movf    baro_p_h, W, A
    subwfb  delta_h, F, A
    
    ; move original delta p to delta_tmp
    movff   delta_h, delta_tmp_h
    movff   delta_l, delta_tmp_l
    
    ; delta = delta + tmp  ? 2 * delta
    movf    delta_tmp_l, W, A
    addwf   delta_l, F, A
    movf    delta_tmp_h, W, A
    addwfc  delta_h, F, A
    
    ; delta = delta + tmp  ? 3 * delta
    movf    delta_tmp_l, W, A
    addwf   delta_l, F, A
    movf    delta_tmp_h, W, A
    addwfc  delta_h, F, A
    
    
    ; right shift 1 time = (3 * delta) / 2
    ARITH_SHIFT_RIGHT
  
;    write in
    movff   delta_h, zoom_h
    movff   delta_l, zoom_l
    
    return



