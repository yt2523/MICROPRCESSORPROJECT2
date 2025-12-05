
    #include <xc.inc>
        
    global mydata
    extrn  SPI_MasterInit,SPI_MasterRead,SPI_MasterTransmit
    extrn  bmi160_init
    extrn  bmi160_gyro_config
    extrn  bmi160_read_gyro_xyz
    extrn  bmp388_init
    extrn  bmp388_config
    extrn  bmp388_read_raw
    extrn  UART_Setup
    extrn  UART_SendHex, UART_Transmit_Byte, UART_Transmit_Message
    extrn  bmi160_gz_h, delay_ms
    extrn  bmi160_gz_h,bmi160_gz_l
	
    mydata:	ds  2
    mydata_len	EQU 2


psect   code, abs

rst:	ORG     0x0
        goto    start

start:
        clrf    TRISA, A
        clrf    TRISB, A
        clrf    TRISD, A
        clrf    TRISE, A          ; RE0 = CS

        ; ------- SPI1 -------
        call    SPI_MasterInit

;        ; ------- BMI160 CS  + dummy read +  chipid -------
        call    bmi160_init
;
;        ; ------- gyro: range + ODR + PMU normal -------
        call    bmi160_gyro_config
;	
;        ; ------- BMP388 init + config -------
;        call    bmp388_init
;        call    bmp388_config
	bcf	CFGS
	bsf	EEPGD
	call	UART_Setup


main_loop:
        call    bmi160_read_gyro_xyz   ;  IMU renew RAM
;        movf    bmi160_gz_h, W, A      ; take Z axis
;	movlw	0x00
;	movwf	myArray, A
;	lfsr	2, myArray
        
    
        
	movf	bmi160_gz_h,W,A
	call    UART_SendHex
	movf	bmi160_gz_l,W,A
	call    UART_SendHex
;        movlw	'Q'
;        CALL    SPI_MasterTransmit
;        CALL    SPI_MasterRead
	
	movlw   0x0D    ; ??
        call    UART_Transmit_Byte
        movlw   0x0A    ; ??
        call    UART_Transmit_Byte
;	lfsr	2, mydata
;	movwf	mydata_len
;        call    UART_Transmit_Message          ; transfer HEX + sent
;	movlw   100
;	call    delay_ms
;
;        bra     main_loop


END	rst