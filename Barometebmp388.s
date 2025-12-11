; ===============================
; Barometebmp388.s
; BMP388 barometer driver (SPI)
; ===============================
        #include <xc.inc>

        GLOBAL  bmp388_init
        GLOBAL  bmp388_config
        GLOBAL  bmp388_read_reg
        GLOBAL  bmp388_write_reg
        GLOBAL  bmp388_read_raw_P
	GLOBAL	bmp388_chip_id
	global  bmp388_addr, bmp388_value
	global  bmp388_p_l, bmp388_p_m, bmp388_p_h,bmp388_t_xlsb, bmp388_t_lsb, bmp388_t_msb

        extrn   SPI_MasterInit,delay_ms
        extrn   SPI_MasterTransmit

; --------- BMP388 RAM ?? ---------
psect   udata_acs
dumm_var:	    ds 1
bmp388_addr:        ds 1      ;address now
bmp388_value:       ds 1      ;write data now
bmp388_chip_id:     ds 1      ; CHIP_ID

; ???? 24bit
bmp388_p_l:      ds 1
bmp388_p_m:       ds 1
bmp388_p_h:       ds 1

; ???? 24bit
bmp388_t_xlsb:      ds 1
bmp388_t_lsb:       ds 1
bmp388_t_msb:       ds 1

; --------- adress ----------
BMP388_CHIP_ID_REG  EQU 0x00
BMP388_ERR_REG      EQU 0x02
BMP388_STATUS_REG   EQU 0x03

BMP388_DATA0_REG    EQU 0x04   ; pressure XLSB
; 0x05 DATA_1, 0x06 DATA_2
; 0x07 DATA_3, 0x08 DATA_4, 0x09 DATA_5

BMP388_INT_CTRL_REG EQU 0x19
BMP388_IF_CONF_REG  EQU 0x1A
BMP388_PWR_CTRL_REG EQU 0x1B
BMP388_OSR_REG      EQU 0x1C
BMP388_ODR_REG      EQU 0x1D
BMP388_CONFIG_REG   EQU 0x1F
BMP388_CMD_REG      EQU 0x7E


psect   bmp388_code, class=CODE
      
;______________________intial__________________________________
;______________________________________________________________
bmp388_config:
        ; ---- 1) OSR oversampling 16----
        ; osr_p = 100b (x16), osr_t = 010b (x4)
        ; bits: [5..3]=010, [2..0]=100 -> 0b0010_100 = 0x28
        movlw   0x04
        movwf   bmp388_value, A
        movlw   BMP388_OSR_REG
        call    bmp388_write_reg
	
        movlw   200           
        call    delay_ms

        ; ---- 2) ODR: 25 Hz ----  read frequency?
        ; odr_sel = 0x03 -> 25Hz (??? 42)
        movlw   0x03
        movwf   bmp388_value, A
        movlw   BMP388_ODR_REG
        call    bmp388_write_reg
	
	movlw   200                 ; ??80-100ms
        call    delay_ms

        ; ---- 3) CONFIG: IIR filter coef_3 ----
        ; iir_filter bits [3..1] = 011 -> 0x0E
        movlw   0x04
        movwf   bmp388_value, A
        movlw   BMP388_CONFIG_REG
        call    bmp388_write_reg
	
	movlw   200            
        call    delay_ms

        ; ---- 4) INT_CTRL: press+temp on, normal mode ----
        ; bits: [5..4]=11 (normal), [1]=1 temp_en, [0]=1 press_en -> 0b0011_0011 = 0x33
        movlw   0x42
        movwf   bmp388_value, A
        movlw   BMP388_INT_CTRL_REG
        call    bmp388_write_reg
	
	movlw   200           
        call    delay_ms

	; ---- 4) IF_CONF: press+temp on, normal mode ----
        ; bits: [5..4]=11 (normal), [1]=1 temp_en, [0]=1 press_en -> 0b0011_0011 = 0x33
        movlw   0x06
        movwf   bmp388_value, A
        movlw   BMP388_IF_CONF_REG
        call    bmp388_write_reg
	
	movlw   200            
        call    delay_ms

	; ---- 5) PWR_CTRL: press+temp on, normal mode ----
        ; bits: [5..4]=11 (normal), [1]=1 temp_en, [0]=1 press_en -> 0b0011_0011 = 0x33
        movlw   0x33
        movwf   bmp388_value, A
        movlw   BMP388_PWR_CTRL_REG
        call    bmp388_write_reg
	
	movlw   200                 ;
        call    delay_ms

        return
	
bmp388_init:
        ; RE1 as output  CS
;	bcf     ANSELE,1, A
        bcf     TRISE,1, A 
        bcf     LATE,1, A

        ; softreset: CMD = 0xB6
        movlw   0xB6
        movwf   bmp388_value, A
        movlw   BMP388_CMD_REG
        call    bmp388_write_reg
        
	movlw	200
	call	delay_ms
	
        ; read CHIP_ID
        movlw   BMP388_CHIP_ID_REG
        call    bmp388_read_reg
        movwf   bmp388_chip_id, A
	bsf	LATE, 1, A
        return

;______________________read and write__________________________________
;______________________________________________________________	

    ; read 8 bit
bmp388_read_reg:
        ; expected bmp388_addr in W
        movwf   bmp388_addr, A
	; bit7=1 read
	bsf     bmp388_addr, 7, A  
	
        ;low CS
        bcf     LATE,1, A   
        ; send adress
        movf    bmp388_addr, W, A
        call    SPI_MasterTransmit  
        ;dummy
        movlw   0x00 
        call    SPI_MasterTransmit
	; read register
        movlw   0x00
        call    SPI_MasterTransmit
	; high CS
        bsf     LATE,1, A  
	
	; expected data in W
        return

	;write 8 bit
bmp388_write_reg:
        ; expected bmp388_addr in W
        movwf   bmp388_addr, A
        ;bit7=0 write
        bcf     bmp388_addr, 7, A
	
	; low CS
        bcf     LATE,1, A
	;send data
        movf    bmp388_addr, W, A
        call    SPI_MasterTransmit
        ;???
        movf    bmp388_value, W, A
        call    SPI_MasterTransmit
        ;move data? to W?
        movf    SSP1BUF, W, A
        ; high CS
        bsf     LATE,1, A
	; expected data in W????
        return

bmp388_read_raw_P:
        ; expected bmp388_addr in W
	movlw   0x04
        movwf   bmp388_addr, A
	; bit7=1 read
	bsf     bmp388_addr, 7, A  
	
        ;low CS
        bcf     LATE,1, A   
        ; send adress
        movf    bmp388_addr, W, A
        call    SPI_MasterTransmit  
        ;dummy
        movlw   0x00 
        call    SPI_MasterTransmit
	;0x04 lowest
        movlw   0x00
        call    SPI_MasterTransmit
	movwf   bmp388_p_l, A 
	;0x05 mid
        movlw   0x00
        call    SPI_MasterTransmit
	movwf   bmp388_p_m, A 
	;0x05 high
        movlw   0x00
        call    SPI_MasterTransmit
	movwf   bmp388_p_h, A 
		;0x04 lowest
        movlw   0x00
        call    SPI_MasterTransmit
	movwf   bmp388_t_xlsb, A 
	;0x05 mid
        movlw   0x00
        call    SPI_MasterTransmit
	movwf   bmp388_t_lsb, A 
	;0x05 high
        movlw   0x00
        call    SPI_MasterTransmit
	movwf   bmp388_t_msb, A 
	nop
        ;high CS
        bsf     LATE,1, A
	
	return
	
	
	

	
;bmp388_read_raw:
;        ; ???? = 0x04 & 0x7F | 0x80 = 0x84
;        movlw   BMP388_DATA0_REG
;        movwf   bmp388_addr, A
;        bcf     bmp388_addr, 7, A
;        bsf     bmp388_addr, 7, A   ; bit7=1 -> read
;
;        bcf     LATE,1, A
;
;        ; ?????
;        movf    bmp388_addr, W, A
;        call    SPI_MasterTransmit   ; ????
;
;        ; ???? dummy
; ;       movlw   0x00
;  ;      call    SPI_MasterTransmit   ; ?? SSP1BUF
;
;        ; ---- 6 ????P(3) + T(3) ----
;        ; P_xlsb
;        movlw   0x00
;        call    SPI_MasterTransmit
;        movf    SSP1BUF, W, A
;        movwf   bmp388_p_xlsb, A
;
;        ; P_lsb
;        movlw   0x00
;        call    SPI_MasterTransmit
;        movf    SSP1BUF, W, A
;        movwf   bmp388_p_lsb, A
;
;        ; P_msb
;        movlw   0x00
;        call    SPI_MasterTransmit
;        movf    SSP1BUF, W, A
;        movwf   bmp388_p_msb, A
;
;        ; T_xlsb
;        movlw   0x00
;        call    SPI_MasterTransmit
;        movf    SSP1BUF, W, A
;        movwf   bmp388_t_xlsb, A
;
;        ; T_lsb
;        movlw   0x00
;        call    SPI_MasterTransmit
;        movf    SSP1BUF, W, A
;        movwf   bmp388_t_lsb, A
;
;        ; T_msb
;        movlw   0x00
;        call    SPI_MasterTransmit
;        movf    SSP1BUF, W, A
;        movwf   bmp388_t_msb, A
;
;        bsf     LATE,1, A
;        return


