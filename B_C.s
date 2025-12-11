#include <xc.inc>

global  Baro_DoCalculation
global	delta_h
global	delta_l
global	delta_m
global	delta_tmp_h
global	delta_tmp_l
global	delta_tmp_m
global	baro_p_m
global	baro_p_h
global	baro_p_l
global	baro_base_m
global	baro_base_h
global	baro_base_l
global	zoom_h
global	zoom_l
global	zoom_m
global  radius

;extrn  baro_p_h, baro_p_l
;extrn  baro_base_h, baro_base_l
;extrn  zoom_h, zoom_l

psect   udata_acs
delta_h:    ds 1
delta_l:    ds 1
delta_m:    ds 1
delta_tmp_m: ds 1
delta_tmp_h: ds 1
delta_tmp_l: ds 1
baro_p_h:      ds 1
baro_p_l:      ds 1
baro_p_m:      ds 1
baro_base_m:   ds 1
baro_base_h:   ds 1
baro_base_l:   ds 1
zoom_h:        ds 1
zoom_l:        ds 1
zoom_m:        ds 1
radius:        ds 1



psect   y_code, class=code
    
    org     0x0300
    
Baro_DoCalculation:
    ; delta pressure = base - current
    movff   baro_base_h, delta_h
    movff   baro_base_l, delta_l
    movff   baro_base_m, delta_m
    
    movf    baro_p_l, W, A
    subwf   delta_l, F, A
    movf    baro_p_h, W, A
    subwfb  delta_h, F, A
    movf    baro_p_m, W, A      
    subwfb  delta_m, F, A
    
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
    call  ASR2
  
;    write in
    movff   delta_h, zoom_h
    movff   delta_l, zoom_l
    
;   delta > 0 ? radius+
;   delta < 0 ? radius-
;   delta = 0 ? radius unchanged
;   radius restrict [R_MIN, R_MAX]
    
    ; justify if delta = 0
    movf    delta_h, W, A
    iorwf   delta_l, W, A      ; W = delta_h OR delta_l
    bz      radius_done        ; both byte radius = 0 ? unchanged

    ; justify if delta < 0
    btfsc   delta_h, 7, A ;check bit7 to see whether negative or not
    goto    radius_negative
    
radius_positive:
    ; delta > 0  ? radius+
    incf    radius, F, A
    ; R_MAX = 30(can be changed)
    movlw   30
    cpfslt  radius, A          ; if radius < 15 jumpover next line
    movwf   radius, A          ; radius >= 15 ? set as 15
    goto    radius_done
    
radius_negative:
    decf    radius, F, A
    ; R_MIN = 0(can be changed)
    movlw   0
    cpfsgt  radius, A          ; radius > 15, go next line
    movwf   radius, A          ; radius <= 15 ? set as 15
    
; update baseline 
radius_done:
    movff   baro_p_h, baro_base_h
    movff   baro_p_m, baro_base_m
    movff   baro_p_l, baro_base_l
    
    return

; right shift
ASR2:
    bcf     STATUS, 0 ,A          ; clean
    btfsc   delta_h, 7          ; check bit7
    bsf     STATUS, 0  ,A       ; if negative,let C=1
    rrcf    delta_h, F, A       ; right shift
    rrcf    delta_m, F, A
    rrcf    delta_l, F, A       
    return
    
;???15pixiel?????baseline???
