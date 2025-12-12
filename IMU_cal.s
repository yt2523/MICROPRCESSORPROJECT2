#include <xc.inc>

global  Gyro_DoCalculation
global  bmi160_gz_l
global  bmi160_gz_h
global	omega_h
global	omega_l
global	angle_l
global	angle_h, angle_d,omega_d
    
extrn   bmi160_gz_l,bmi160_gz_h

;

psect   udata_acs
   
ANGLE_360_H  EQU 0x01      ; constant 360 = 0x0168
ANGLE_360_L  EQU 0x68

angle_tmp_h:    ds 1   ; reserve to temporary save angle
angle_tmp_l:    ds 1
    
;reserve to save data that after magnification(temporary variable)    
omega_h:          ds 1              ; angular velocity high after magnification
omega_l:          ds 1              ; angular velocity low after magnification
omega_d:          ds 1              ; decimal changing angle
angle_l:          ds 1      ; low angle
angle_h:          ds 1      ; high angle
angle_d:          ds 1      ; decimal angle

psect   IMUcal_code, class=CODE

    ; arethematic right shift 8 times
    
Gyro_DoCalculation:
    ;copy original 16 byte angular velocity to temporary variables
    movff   bmi160_gz_h, omega_h
    movff   bmi160_gz_l, omega_l
    
    btfsc   omega_h,7,A     ; check bit7 if negative
    bra    left
    
right:    
    ; 14 times right shift(original angle * 1/256~ 0.0039)
    call    ASR
    call    ASR
    call    ASR
    call    ASR
    call    ASR   ;5
    call    ASR
    call    ASR   ;8
    call    ASR
    call    ASR
    call    ASR   ;10
    call    ASR
    call    ASR
    
    ;add back angle increment to original angle
    bcf     STATUS, 0, A        ; C = 0, ????
    movf    omega_d, W, A       ; add decimal
    addwf   angle_d, F, A
    movf    omega_l, W, A       ; add low byte
    addwfc   angle_l, F, A
    movf    omega_h, W, A       ; add high byte
    addwfc  angle_h, F, A
    goto  normalize
    
left:    
    ; 14 times right shift(original angle * 1/256~ 0.0039)
    call    ASR
    call    ASR
    call    ASR
    call    ASR
    call    ASR   ;5
    call    ASR
    call    ASR   ;8
    call    ASR
    call    ASR
    call    ASR   ;10
    call    ASR
    call    ASR
    call    ASR
    call    ASR
;    call    ASR
    
    ;add back angle increment to original angle
    bcf     STATUS, 0, A        ; C = 0, ????
    movf    omega_d, W, A       ; add decimal
    addwf   angle_d, F, A
    movf    omega_l, W, A       ; add low byte
    addwfc   angle_l, F, A
    movf    omega_h, W, A       ; add high byte
    addwfc  angle_h, F, A
    goto  normalize
    
normalize:
    ; normalized angle process
    ; check if the angle is negative
    btfss   angle_h, 7, A       ; check if bit7=1 ? negative?bit7=0 ? positive
    goto    check_ge_360        ; positive ? check if >= 360

    ;if it is negative, calculation will comes here
    movlw   ANGLE_360_L
    addwf   angle_l, F, A
    movlw   ANGLE_360_H
    addwfc  angle_h, F, A
    goto    check_ge_360 ;manually add 360 for negative angle,but still might larger than 360

check_ge_360:
    movff   angle_h, angle_tmp_h ;move current angle to temporary angle
    movff   angle_l, angle_tmp_l

    movlw   ANGLE_360_L ; make difference between 360 and current angle
    subwf   angle_tmp_l, F, A
    movlw   ANGLE_360_H
    subwfb  angle_tmp_h, F, A
    
    ;if C=1 angle >= 360,if c=0 angle < 360
    btfss   STATUS, 0, A        ; C=1 jumpover next line
    goto    norm_done           ; C=0 ? angle<360 ? directly ended
    
    ;for C=1 angle = angle - 360
    movff   angle_tmp_h, angle_h
    movff   angle_tmp_l, angle_l
    
norm_done:
    return
    
ASR: 
    bcf     STATUS, 0,A       ; reset
    btfsc   omega_h,7,A     ; check bit7 if negative
    bsf     STATUS, 0,A       ; if negative let C=1

    ; right shift
    rrcf    omega_h, F, A
    rrcf    omega_l, F, A
    rrcf    omega_d, F, A
    return
    
;ASR: 
;    bcf     STATUS, 0,A       ; reset
;    btfsc   omega_h, 7,A     ; check bit7 if negative
;    bsf     STATUS, 0,A       ; if negative let C=1
;
;    ; right shift
;    rrcf    omega_h, F, A
;    rrcf    omega_l, F, A
;    return



