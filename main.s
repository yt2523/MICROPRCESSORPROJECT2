; ===============================
; main.asm
; ?????
; ===============================
        #include <xc.inc>

        extrn  SPI_MasterInit
        extrn  bmi160_init

;; ---- ????????????????? ----
;        CONFIG  FOSC = HSHP
;        CONFIG  WDTEN = OFF
;        CONFIG  LVP = OFF
    psect   resetVec, class=CODE, delta=2
; ????
        ORG     0x0000
        goto    start

; ===============================
; start??????
; ===============================
start:
        ; ------- System Init????? -------
        clrf    TRISA
        clrf    TRISB
        ; TRISC ? spi_init ?????
        clrf    TRISD
        clrf    TRISE          ; RE0 ??????? bmi160_init ??

        ; ------- SPI1 ??? -------
        call    SPI_MasterInit

        ; ------- BMI160 ???????? CS?-------
        call    bmi160_init

main_loop:
        ; ???????????????? IMU ? ??? ? ?? GLCD
        bra     main_loop

        END

