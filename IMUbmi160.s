
        #include <xc.inc>

        GLOBAL  bmi160_init
        GLOBAL  bmi160_read_reg
        GLOBAL  bmi160_write_reg
        GLOBAL  bmi160_read_gyro_xyz
        GLOBAL  bmi160_read_chipid
	GLOBAL  bmi160_gyro_config

        extrn   SPI_MasterInit
        extrn   SPI_MasterTransmit

        psect   udata_acs         
bmi160_addr:        ds 1      ; ????????? / ??
bmi160_value:       ds 1      ; write_reg ??????
bmi160_chip_id:     ds 1      ; ???? CHIP_ID

bmi160_gx_l:        ds 1      ; gyro X LSB
bmi160_gx_h:        ds 1      ; gyro X MSB
bmi160_gy_l:        ds 1      ; gyro Y LSB
bmi160_gy_h:        ds 1      ; gyro Y MSB
bmi160_gz_l:        ds 1      ; gyro Z LSB
bmi160_gz_h:        ds 1      ; gyro Z MSB


GYRO_X_L_REG       EQU 0x0C
GYRO_X_H_REG       EQU 0x0D
GYRO_Y_L_REG       EQU 0x0E
GYRO_Y_H_REG       EQU 0x0F
GYRO_Z_L_REG       EQU 0x10
GYRO_Z_H_REG       EQU 0x11
CHIP_ID_REG        EQU 0x00
	
GYR_CONF_REG       EQU 0x42   ; ?????
GYR_RANGE_REG      EQU 0x43   ; ?????
CMD_REG            EQU 0x7E   ; PMU ?????


BMI160_CS_LOW   macro
        bcf     LATE,0      ; RE0 = 0 ?? BMI160
        endm

BMI160_CS_HIGH  macro
        bsf     LATE,0      ; RE0 = 1 ????
        endm


        psect   bmi160_code, class=CODE, delta=2

; ===============================
; bmi160_init
; 1. ? RE0 ????????? CSB
; 2. ? CS ???-??????? SPI ??
; 3. ? 0x7F ????? SPI ??dummy?
; 4. ?? bmi160_read_chipid?? CHIP_ID ?? bmi160_chip_id
; ===============================
bmi160_init:
        ; RE0 ?????
        bcf     TRISE,0, A

        ; ????? CSB???? BMI160?
        BMI160_CS_HIGH

        ; ------- 1) ? CS ???-?????? SPI ?? -------
        BMI160_CS_LOW
        BMI160_CS_HIGH

        ; ------- 2) ?????? 0x7F ????? SPI ? -------
        ; ???? = (0x7F << 1) | 1 = 0xFF
        BMI160_CS_LOW

        movlw   0xFF                ; 0x7F ???
        call    SPI_MasterTransmit   ; ????????????

        movlw   0x00                ; dummy byte
        call    SPI_MasterTransmit   ; ???????????

        BMI160_CS_HIGH

        ; ------- 3) ? CHIP_ID (??? 0x00) ? bmi160_chip_id -------
        call    bmi160_read_chipid

        return


; ===============================
; bmi160_read_reg
; ??: W = ????? (0x00..0x7F)
; ??: W = ?????
; ??: bmi160_addr, STATUS
; ===============================
bmi160_read_reg:
        ; ????
        movwf   bmi160_addr, A

        ; ?? SPI ??: (addr << 1) | 1   (bit0=1 => read)
        rlcf    bmi160_addr, F, A   ; ????
        bsf     bmi160_addr, 0, A   ; bit0 = 1

        ; ?? BMI160
        BMI160_CS_LOW

        ; ??????
        movf    bmi160_addr, W, A
        call    SPI_MasterTransmit   ; ???????

        ; ?? dummy byte ??????????
        movlw   0x00
        call    SPI_MasterTransmit

        ; SPI_MasterTransmit ????????? SSP1BUF
        movf    SSP1BUF, W, A       ; W = ?????

        ; ???? BMI160
        BMI160_CS_HIGH
        return


; ===============================
; bmi160_write_reg
; ??:
;   W = ?????
;   bmi160_value = ??????
; ??: ?
; ===============================
bmi160_write_reg:
        ; ????
        movwf   bmi160_addr, A

        ; ?? SPI ??: (addr << 1) & ~1   (bit0=0 => write)
        rlcf    bmi160_addr, F, A   ; ????
        bcf     bmi160_addr, 0, A   ; ?? bit0=0

        ; ?? BMI160
        BMI160_CS_LOW

        ; ??????
        movf    bmi160_addr, W, A
        call    SPI_MasterTransmit

        ; ??????
        movf    bmi160_value, W, A
        call    SPI_MasterTransmit

        ; ? SSP1BUF ? BF???????
        movf    SSP1BUF, W, A

        ; ????
        BMI160_CS_HIGH
        return



bmi160_read_chipid:
        movlw   CHIP_ID_REG
        call    bmi160_read_reg
        movwf   bmi160_chip_id, A
        return

bmi160_read_gyro_xyz:
        ; GYRO X
        movlw   GYRO_X_L_REG
        call    bmi160_read_reg
        movwf   bmi160_gx_l, A

        movlw   GYRO_X_H_REG
        call    bmi160_read_reg
        movwf   bmi160_gx_h, A

        ; GYRO Y
        movlw   GYRO_Y_L_REG
        call    bmi160_read_reg
        movwf   bmi160_gy_l, A

        movlw   GYRO_Y_H_REG
        call    bmi160_read_reg
        movwf   bmi160_gy_h, A

        ; GYRO Z
        movlw   GYRO_Z_L_REG
        call    bmi160_read_reg
        movwf   bmi160_gz_l, A

        movlw   GYRO_Z_H_REG
        call    bmi160_read_reg
        movwf   bmi160_gz_h, A
; ===============================
; bmi160_gyro_config
; ???
;   1) ?? GYR_CONF = 0x28   (ODR=100Hz, normal filter)
;   2) ?? GYR_RANGE = 0x00  (±2000 °/s)
;   3) ? CMD ??? 0x7E = 0x15?? gyro ?? normal mode
; ===============================
bmi160_gyro_config:
        ; ---- 1) GYR_CONF = 0x28 ----
        movlw   0x28               ; gyr_bwp=010, gyr_odr=1000 => 100Hz normal
        movwf   bmi160_value, A
        movlw   GYR_CONF_REG
        call    bmi160_write_reg

        ; ---- 2) GYR_RANGE = 0x00 => ±2000°/s ----
        movlw   0x00               ; gyr_range[2:0] = 000
        movwf   bmi160_value, A
        movlw   GYR_RANGE_REG
        call    bmi160_write_reg

        ; ---- 3) PMU_CMD: gyro normal mode ----
        ; datasheet: ? CMD_REG = 0x15 => gyr_set_pmu_mode(normal)
        movlw   0x15
        movwf   bmi160_value, A
        movlw   CMD_REG
        call    bmi160_write_reg

        ; ---- 4) ?? delay ?? (~?? ms) ? gyro ?? ----
        movlw   0xFF
        movwf   bmi160_addr, A      ; ? bmi160_addr ????1
gyro_delay_outer:
        movlw   0xFF
        movwf   bmi160_value, A     ; ????2
gyro_delay_inner:
        decfsz  bmi160_value, F, A
        bra     gyro_delay_inner
        decfsz  bmi160_addr, F, A
        bra     gyro_delay_outer

        return
