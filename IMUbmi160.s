; ===============================
; bmi160.asm
; BMI160 ??????????
; ===============================
        #include <xc.inc>

        GLOBAL  bmi160_init

        extrn  SPI_MasterInit
        extrn  SPI_MasterTransmit

; ---- BMI160 ? CS ? RE0 ----
BMI160_CS_LOW   macro
        bcf     LATE,0      ; RE0 = 0 ? ?? BMI160
        endm

BMI160_CS_HIGH  macro
        bsf     LATE,0      ; RE0 = 1 ? ????
        endm

; ===============================
; bmi160_init
; ????? CS ????????????? init
; ===============================
bmi160_init:
        ; RE0 ????
        bcf     TRISE,0
        ; ?????????????
        BMI160_CS_HIGH

        return



