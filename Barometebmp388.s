; ===============================
; Barometebmp388.s
; BMP388 barometer driver (SPI)
; ===============================
        #include <xc.inc>

        GLOBAL  bmp388_init
        GLOBAL  bmp388_config
        GLOBAL  bmp388_read_reg
        GLOBAL  bmp388_write_reg
        GLOBAL  bmp388_read_raw

        extrn   SPI_MasterInit
        extrn   SPI_MasterTransmit

; --------- BMP388 RAM ?? ---------
        psect   udata_acs
bmp388_addr:        ds 1      ; ????? / ????
bmp388_value:       ds 1      ; ???????
bmp388_chip_id:     ds 1      ; CHIP_ID

; ???? 24bit
bmp388_p_xlsb:      ds 1
bmp388_p_lsb:       ds 1
bmp388_p_msb:       ds 1

; ???? 24bit
bmp388_t_xlsb:      ds 1
bmp388_t_lsb:       ds 1
bmp388_t_msb:       ds 1

; --------- ??????? ----------
BMP388_CHIP_ID_REG  EQU 0x00
BMP388_ERR_REG      EQU 0x02
BMP388_STATUS_REG   EQU 0x03

BMP388_DATA0_REG    EQU 0x04   ; pressure XLSB
; 0x05 DATA_1, 0x06 DATA_2
; 0x07 DATA_3, 0x08 DATA_4, 0x09 DATA_5

BMP388_PWR_CTRL_REG EQU 0x1B
BMP388_OSR_REG      EQU 0x1C
BMP388_ODR_REG      EQU 0x1D
BMP388_CONFIG_REG   EQU 0x1F
BMP388_CMD_REG      EQU 0x7E

; ---- BMP388 ? CS ??? RE1 ----
BARO_CS_LOW   macro
        bcf     LATE,1      ; RE1 = 0 ?? BMP388
        endm

BARO_CS_HIGH  macro
        bsf     LATE,1      ; RE1 = 1 ????
        endm

; ===============================
; ???
; ===============================
        psect   bmp388_code, class=CODE, delta=2

; ===============================
; bmp388_read_reg
; ??: W = ????? (0x00..0x7F/0xFF)
; ??: W = ?????
; ??: SPI ???? = (addr & 0x7F) | 0x80
; ===============================
bmp388_read_reg:
        movwf   bmp388_addr, A

        ; ????: bit7 = 1 (read), bit6..0 = ??
        bcf     bmp388_addr, 7, A   ; ????? bit7
        bsf     bmp388_addr, 7, A   ; ? 1 ???

        BARO_CS_LOW

        ; ??????
        movf    bmp388_addr, W, A
        call    SPI_MasterTransmit   ; ?????

        ; dummy ??
        movlw   0x00
        call    SPI_MasterTransmit

        ; ????? SSP1BUF
        movf    SSP1BUF, W, A

        BARO_CS_HIGH
        return


; ===============================
; bmp388_write_reg
; ??:
;   W = ?????
;   bmp388_value = ????
; ??: ?
; ??: ???? = (addr & 0x7F)  (bit7=0 => write)
; ===============================
bmp388_write_reg:
        movwf   bmp388_addr, A

        ; ????: bit7 = 0 (write), bit6..0 = ??
        bcf     bmp388_addr, 7, A   ; ?? bit7=0

        BARO_CS_LOW

        ; ??????
        movf    bmp388_addr, W, A
        call    SPI_MasterTransmit

        ; ????
        movf    bmp388_value, W, A
        call    SPI_MasterTransmit

        ; ? SSP1BUF ? BF
        movf    SSP1BUF, W, A

        BARO_CS_HIGH
        return


; ===============================
; bmp388_init
; 1. ? RE1 ?????? CS
; 2. ??: softreset
; 3. ??? CHIP_ID ?? bmp388_chip_id
; ===============================
bmp388_init:
        ; RE1 ??
        bcf     TRISE,1, A

        ; ?????
        BARO_CS_HIGH

        ; (??) softreset: CMD = 0xB6
        ;movlw   0xB6
        ;movwf   bmp388_value, A
        ;movlw   BMP388_CMD_REG
        ;call    bmp388_write_reg
        ;(??????? delay???????????)

        ; ??? CHIP_ID
        movlw   BMP388_CHIP_ID_REG
        call    bmp388_read_reg
        movwf   bmp388_chip_id, A

        return


; ===============================
; bmp388_config
; ?????
;   OSR: osr_p = x16, osr_t = x4 -> OSR = 0x28
;   ODR: odr_sel = 0x03 -> 25 Hz -> ODR = 0x03
;   PWR_CTRL: press_en =1, temp_en=1, mode=normal(11) -> 0x33
;   CONFIG: IIR filter ?? = 7 (??) -> 0x0E
; ===============================
bmp388_config:
        ; ---- 1) OSR oversampling ----
        ; osr_p = 100b (x16), osr_t = 010b (x4)
        ; bits: [5..3]=010, [2..0]=100 -> 0b0010_100 = 0x28
        movlw   0x28
        movwf   bmp388_value, A
        movlw   BMP388_OSR_REG
        call    bmp388_write_reg

        ; ---- 2) ODR: 25 Hz ----
        ; odr_sel = 0x03 -> 25Hz (??? 42)
        movlw   0x03
        movwf   bmp388_value, A
        movlw   BMP388_ODR_REG
        call    bmp388_write_reg

        ; ---- 3) CONFIG: IIR filter coef_7 (??) ----
        ; iir_filter bits [3..1] = 011 -> 0x0E
        movlw   0x0E
        movwf   bmp388_value, A
        movlw   BMP388_CONFIG_REG
        call    bmp388_write_reg

        ; ---- 4) PWR_CTRL: press+temp on, normal mode ----
        ; bits: [5..4]=11 (normal), [1]=1 temp_en, [0]=1 press_en -> 0b0011_0011 = 0x33
        movlw   0x33
        movwf   bmp388_value, A
        movlw   BMP388_PWR_CTRL_REG
        call    bmp388_write_reg

        return


; ===============================
; bmp388_read_raw
; ? DATA_0 ????? burst read:
;   0x04 DATA_0 -> p_xlsb
;   0x05 DATA_1 -> p_lsb
;   0x06 DATA_2 -> p_msb
;   0x07 DATA_3 -> t_xlsb
;   0x08 DATA_4 -> t_lsb
;   0x09 DATA_5 -> t_msb
;
; ??????:
;   bmp388_p_xlsb, bmp388_p_lsb, bmp388_p_msb
;   bmp388_t_xlsb, bmp388_t_lsb, bmp388_t_msb
; ===============================
bmp388_read_raw:
        ; ???? = 0x04 & 0x7F | 0x80 = 0x84
        movlw   BMP388_DATA0_REG
        movwf   bmp388_addr, A
        bcf     bmp388_addr, 7, A
        bsf     bmp388_addr, 7, A   ; bit7=1 -> read

        BARO_CS_LOW

        ; ?????
        movf    bmp388_addr, W, A
        call    SPI_MasterTransmit   ; ????

        ; ???? dummy
        movlw   0x00
        call    SPI_MasterTransmit   ; ?? SSP1BUF

        ; ---- 6 ????P(3) + T(3) ----
        ; P_xlsb
        movlw   0x00
        call    SPI_MasterTransmit
        movf    SSP1BUF, W, A
        movwf   bmp388_p_xlsb, A

        ; P_lsb
        movlw   0x00
        call    SPI_MasterTransmit
        movf    SSP1BUF, W, A
        movwf   bmp388_p_lsb, A

        ; P_msb
        movlw   0x00
        call    SPI_MasterTransmit
        movf    SSP1BUF, W, A
        movwf   bmp388_p_msb, A

        ; T_xlsb
        movlw   0x00
        call    SPI_MasterTransmit
        movf    SSP1BUF, W, A
        movwf   bmp388_t_xlsb, A

        ; T_lsb
        movlw   0x00
        call    SPI_MasterTransmit
        movf    SSP1BUF, W, A
        movwf   bmp388_t_lsb, A

        ; T_msb
        movlw   0x00
        call    SPI_MasterTransmit
        movf    SSP1BUF, W, A
        movwf   bmp388_t_msb, A

        BARO_CS_HIGH
        return



