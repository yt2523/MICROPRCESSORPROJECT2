#include <xc.inc>

global  Gyro_DoCalculation
global  bmi160_gz_l
global  bmi160_gz_h
global	omega_h
global	omega_l
global	angle_l
global	angle_h
    

;extrn  bmi160_gz_h
;extrn  bmi160_gz_l
;extrn  angle_h
;extrn  angle_l
;

    psect   udata_acs

bmi160_gz_l:     ds 1      ; original angular velocity low
bmi160_gz_h:     ds 1      ; original angular velocity high
    
;reserve to save data that after magnification(temporary variable)
    
omega_h:          ds 1              ; angular velocity high after magnification
omega_l:          ds 1              ; angular velocity low after magnification
angle_l:          ds 1      ; low angle
angle_h:          ds 1      ; high angle

    psect   q_code, class=code 

    ; arethematic right shift 8 times
    ARITHMETIC_SHIFT_RIGHT MACRO
        bcf     STATUS, 0       ; reset
        btfsc   omega_h, 7      ; check bit7 if negative
        bsf     STATUS, 0       ; if negative let C=1
        
	; right shift
        rrcf    omega_h, F, A
        rrcf    omega_l, F, A
    ENDM
    
Gyro_DoCalculation:
    ;copy original 16 byte angular velocity to temporary variables
    movff   bmi160_gz_h, omega_h
    movff   bmi160_gz_l, omega_l
    
    ; 8 times right shift(original angle * 1/256~ 0.0039)
    ARITHMETIC_SHIFT_RIGHT
    ARITHMETIC_SHIFT_RIGHT
    ARITHMETIC_SHIFT_RIGHT
    ARITHMETIC_SHIFT_RIGHT
    ARITHMETIC_SHIFT_RIGHT
    ARITHMETIC_SHIFT_RIGHT
    ARITHMETIC_SHIFT_RIGHT
    ARITHMETIC_SHIFT_RIGHT
    
    ;add back angle increment to original angle
    movf    omega_l, W, A       ; add low byte
    addwf   angle_l, F, A
    movf    omega_h, W, A       ; add high byte
    addwfc  angle_h, F, A
    
    return


