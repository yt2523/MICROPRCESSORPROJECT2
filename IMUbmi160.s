
        #include <xc.inc>

        GLOBAL  bmi160_init;SPI Mode set + read chip id
        GLOBAL  bmi160_read_reg 
        GLOBAL  bmi160_write_reg
        GLOBAL  bmi160_read_gyro_xyz
        GLOBAL  bmi160_read_chipid, bmi160_chip_id
	GLOBAL  bmi160_gyro_config
	GLOBAL	bmi160_gz_h,bmi160_gz_l,CHIP_ID_REG,bmi160_read_reg,bmi160_write_reg,bmi160_addr,bmi160_value

        extrn   SPI_MasterInit
        extrn   SPI_MasterTransmit,delay_ms,delay_cnt_ms

psect   udata_acs        
   
; byte that gonna print in UART
bmi160_addr:        ds 1      
bmi160_value:       ds 1      
bmi160_chip_id:     ds 1      ; CHIP_ID

;bmi160_gx_l:        ds 1      ; gyro X LSB
;bmi160_gx_h:        ds 1      ; gyro X MSB
;bmi160_gy_l:        ds 1      ; gyro Y LSB
;bmi160_gy_h:        ds 1      ; gyro Y MSB
bmi160_gz_l:        ds 1      ; gyro Z LSB
bmi160_gz_h:        ds 1      ; gyro Z MSB

; registers address
;GYRO_X_L_REG       EQU 0x0C
;GYRO_X_H_REG       EQU 0x0D
;GYRO_Y_L_REG       EQU 0x0E
;GYRO_Y_H_REG       EQU 0x0F
GYRO_Z_L_REG       EQU 0x10
GYRO_Z_H_REG       EQU 0x11
CHIP_ID_REG        EQU 0x00
	
GYR_CONF_REG       EQU 0x42   
GYR_RANGE_REG      EQU 0x43   
CMD_REG            EQU 0x7E
ACC_CONF	   EQU 0x40
ACC_RANGE	   EQU 0x41

; set RE0 as CS
BMI160_CS_LOW   macro
        bcf     LATE,0      ; RE0 = 0
        endm

BMI160_CS_HIGH  macro
        bsf     LATE,0       ; RE0 = 1
        endm


        psect   bmi160_code, class=CODE, delta=2


bmi160_init:
        ; RE0 set as output + rise CS
        bcf     TRISE,0, A  ;E as output
        BMI160_CS_HIGH  ; set CS high
	movlw   10  
	call  delay_ms

	 ; soft reset BMI160
	movlw   0xB6                ; ? ?????
        movwf   bmi160_value, A     ; ? ?? bmi160_value
        movlw   0x7E                ; ? ?????
        call    bmi160_write_reg    ; ? ?????
        
        movlw   100
	call  delay_ms

        ; ------- 3) READ CHIP_ID store in bmi160_chip_id -------
;        call    bmi160_read_chipid

        return


bmi160_read_reg:
        ; input?W = registor adress(like 0x00)
        ; output ?W = data in adress
        movwf   bmi160_addr, A ; save original register address
;
;        ; move left for 7bit for 1 unit
        rlcf    bmi160_addr, F, A   
        bsf     bmi160_addr, 0, A   ; bit0 = 1, read mode
	
	 ; ??????bit7 = 1
;        bsf     bmi160_addr, 7, A   ; ????bit7?1
        ; ???0x00 ? 0x80, 0x0C ? 0x8C

        bcf     LATE,0
	bcf     LATE,0 
	movlw  0x22
        movf    bmi160_addr, W, A
        call    SPI_MasterTransmit   ; sent address + read

        movlw   0x00 
        call    SPI_MasterTransmit ; sent dummy byte

        movf    SSP1BUF, W, A       ; BMI160 returned data in SSP1BUF
	nop
	nop
	nop
        bsf     LATE,0 
        return
	; W return with data



bmi160_write_reg:
        movwf   bmi160_addr, A

        rlcf    bmi160_addr, F, A   
        bcf     bmi160_addr, 0, A   ; bit0=0 => write
;	bcf     bmi160_addr, 7, A 

    ;    BMI160_CS_LOW
	bcf     LATE,0

        movf    bmi160_addr, W, A
        call    SPI_MasterTransmit ; sent address

        movf    bmi160_value, W, A
        call    SPI_MasterTransmit ; sent value

        movf    SSP1BUF, W, A ; clean BF
	nop
	nop
	nop
	nop	
    ;    BMI160_CS_HIGH
	bsf     LATE,0
        return



bmi160_read_chipid:
        movlw   CHIP_ID_REG
        call    bmi160_read_reg
        movwf   bmi160_chip_id, A
        return

bmi160_read_gyro_xyz:
;        ; GYRO X
;        movlw   GYRO_X_L_REG
;        call    bmi160_read_reg
;        movwf   bmi160_gx_l, A
;
;        movlw   GYRO_X_H_REG
;        call    bmi160_read_reg
;        movwf   bmi160_gx_h, A
;
;        ; GYRO Y
;        movlw   GYRO_Y_L_REG
;        call    bmi160_read_reg
;        movwf   bmi160_gy_l, A
;
;        movlw   GYRO_Y_H_REG
;        call    bmi160_read_reg
;        movwf   bmi160_gy_h, A

        ; GYRO Z
        movlw   GYRO_Z_L_REG
        call    bmi160_read_reg
        movwf   bmi160_gz_l, A

        movlw   GYRO_Z_H_REG
        call    bmi160_read_reg
        movwf   bmi160_gz_h, A
	
	return
	
bmi160_gyro_config:
            ; ---- 3) PMU_CMD: gyro normal mode ----
        ; work at normal mode CMD_REG = 0x15 => processing time 55-80ms
        movlw   0x15
        movwf   bmi160_value, A
        movlw   CMD_REG
        call    bmi160_write_reg
	
	movlw   100                 ; ??80-100ms
        call    delay_ms
	
	     ; ---- 2) GYR_RANGE = 0x00 => ±2000°/s ----
        movlw   0x00               ; gyr_range[2:0] = 000
        movwf   bmi160_value, A
        movlw   GYR_RANGE_REG
        call    bmi160_write_reg
	
	
        ; ---- 1) GYR_CONF = 0x28(100Hz) ----
        movlw   0x28               ; gyr_bwp=010, gyr_odr=1000 => 100Hz normal
        movwf   bmi160_value, A
        movlw   GYR_CONF_REG
        call    bmi160_write_reg
	
	movlw   50                  ; ????
        call    delay_ms
	
gyro_delay_outer:
        movlw   0xFF
        movwf   bmi160_value, A     
gyro_delay_inner:
        decfsz  bmi160_value, F, A
        bra     gyro_delay_inner
        decfsz  bmi160_addr, F, A
        bra     gyro_delay_outer

	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
        return
