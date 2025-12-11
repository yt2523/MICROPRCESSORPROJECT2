
        #include <xc.inc>

        GLOBAL  bmi160_init, bmi160_gyro_config;SPI Mode set + read chip id
        GLOBAL  bmi160_read_reg 
        GLOBAL  bmi160_write_reg
        GLOBAL  bmi160_read_gyro_xyz
        GLOBAL  bmi160_read_chipid, bmi160_chip_id
	GLOBAL	bmi160_gz_h,bmi160_gz_l
	GLOBAL  CHIP_ID_REG,bmi160_read_reg,bmi160_write_reg,bmi160_addr,bmi160_value

        extrn   SPI_MasterTransmit,delay_ms

psect   udata_acs        
   
; byte that gonna print in UART
bmi160_addr:        ds 1      
bmi160_value:       ds 1      
bmi160_chip_id:     ds 1      ; CHIP_ID
bmi160_gz_l:        ds 1      ; gyro Z LSB
bmi160_gz_h:        ds 1      ; gyro Z MSB

; registers address
GYRO_Z_L_REG       EQU 0x10
GYRO_Z_H_REG       EQU 0x11
CHIP_ID_REG        EQU 0x00
	
GYR_CONF_REG       EQU 0x42   
GYR_RANGE_REG      EQU 0x43   
CMD_REG            EQU 0x7E
ACC_CONF	   EQU 0x40
ACC_RANGE	   EQU 0x41

psect   bmi160_code, class=CODE


bmi160_init:
        ; RE0 set as output + rise CS
        bcf     TRISE,1, A 
        bcf     LATE,1, A

	movlw   10  
	call  delay_ms

	 ; soft reset BMI160
	movlw   0xB6                ; soft com
        movwf   bmi160_value, A     ; ? ?? bmi160_value
        movlw   0x7E                ; adress for soft reset
        call    bmi160_write_reg    ; ? ?????
        
        movlw   200
	call  delay_ms

        ; ------- 3) READ CHIP_ID store in bmi160_chip_id -------
;        call    bmi160_read_chipid

        return


bmi160_read_reg:

        movwf   bmi160_addr, A ; save original register address
	
;        ; move left for 7bit for 1 unit
;        rlcf    bmi160_addr, F, A   
        bsf     bmi160_addr, 7, A   ; bit0 = 1, read mode
	
        ;low CS
        bcf     LATE,1, A   
        ; send adress
        movf    bmi160_addr, W, A
        call    SPI_MasterTransmit  

        movlw   0x00 
        call    SPI_MasterTransmit ; sent dummy byte

	; high CS
        bsf     LATE,1, A 
        return
	; W return with data

bmi160_write_reg:
        movwf   bmi160_addr, A

;        rlcf    bmi160_addr, F, A   
        bcf     bmi160_addr, 7, A   ; bit0=0 => write
;	bcf     bmi160_addr, 7, A 

	; low CS
        bcf     LATE,1, A

        movf    bmi160_addr, W, A
        call    SPI_MasterTransmit ; sent address

        movf    bmi160_value, W, A
        call    SPI_MasterTransmit ; sent value

        movf    SSP1BUF, W, A ; clean BF

        ; high CS
        bsf     LATE,1, A
	
        return



bmi160_read_chipid:
        movlw   CHIP_ID_REG
        call    bmi160_read_reg
        movwf   bmi160_chip_id, A
        return

bmi160_read_gyro_xyz:
        ; GYRO Z
        movlw   GYRO_Z_L_REG
        call    bmi160_read_reg
        movwf   bmi160_gz_l, A

        movlw   GYRO_Z_H_REG
        call    bmi160_read_reg
        movwf   bmi160_gz_h, A
	
	return
	
bmi160_gyro_config:
            ; ---- 1) GYR_CONF = 0x28(100Hz) ----
        movlw   0x28               ; gyr_bwp=010, gyr_odr=1000 => 100Hz normal
        movwf   bmi160_value, A
        movlw   GYR_CONF_REG
        call    bmi160_write_reg
	
	movlw   200                  ; ????
        call    delay_ms
	
		     ; ---- 2) GYR_RANGE = 0x00 => ±250°/s ----
        movlw   0x03               ; gyr_range[2:0] = 011
        movwf   bmi160_value, A
        movlw   GYR_RANGE_REG
        call    bmi160_write_reg
	
		
	movlw   200                 ; ??80-100ms
        call    delay_ms
	
            ; ---- 3) PMU_CMD: gyro normal mode ----
        ; work at normal mode CMD_REG = 0x15 => processing time 55-80ms
        movlw   0x15
        movwf   bmi160_value, A
        movlw   CMD_REG
        call    bmi160_write_reg
	
	movlw   200                 ; ??80-100ms
        call    delay_ms
	return	
	
	


