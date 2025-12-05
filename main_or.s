
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
        
    
        
	lfsr	0, mydata
	movwf	bmi160_gz_h,A
	movwf	POSTINC0, A
	movwf	bmi160_gz_l,A
	movwf	POSTINC0, A
;        movlw	'Q'
;        CALL    SPI_MasterTransmit
;        CALL    SPI_MasterRead
	
	lfsr	2, mydata
	movwf	mydata_len
        call    UART_Transmit_Message          ; transfer HEX + sent
	movlw   100
	call    delay_ms

        bra     main_loop


END	rst

	
	
	
		
;        
;    global mydata
;    extrn  SPI_MasterInit, SPI_MasterTransmit
;    extrn  bmi160_init, bmi160_read_chipid
;    extrn  UART_Setup, UART_Transmit_Byte, UART_SendHex
;    extrn  delay_ms
;    extrn  bmi160_chip_id
;
;psect   udata_acs
;test_byte:      ds 1
;
;psect   code, abs
;rst:    ORG     0x0
;        goto    start
;
;start:
;        clrf    TRISA, A
;        clrf    TRISB, A
;        clrf    TRISD, A
;        clrf    TRISE, A
;        
;        ; ???
;        call    SPI_MasterInit
;	bcf	CFGS
;	bsf	EEPGD
;        call    UART_Setup
;        
;        movlw   100
;        call    delay_ms
;        
;        ; ====== ?? 1: SPI ???? ======
;        movlw   'T'
;        call    UART_Transmit_Byte
;        movlw   '1'
;        call    UART_Transmit_Byte
;        movlw   '\n'
;        call    UART_Transmit_Byte
;        
;        ; ?? SDO1(RC5) ? SDI1(RC4)??? SPI
;        movlw   0xAA            ; ???
;        call    SPI_MasterTransmit
;        movf    SSP1BUF, W, A
;        call    UART_SendHex    ; ???? AA
;        
;        movlw   '\n'
;        call    UART_Transmit_Byte
;        
;        movlw   0x55            ; ??????
;        call    SPI_MasterTransmit
;        movf    SSP1BUF, W, A
;        call    UART_SendHex    ; ???? 55
;        
;        movlw   '\n'
;        call    UART_Transmit_Byte
;        
;        ; ====== ?? 2: ?? CS ?? ======
;        movlw   'T'
;        call    UART_Transmit_Byte
;        movlw   '2'
;        call    UART_Transmit_Byte
;        movlw   '\n'
;        call    UART_Transmit_Byte
;        
;        ; ?? RE0 ???
;        bcf     TRISE, 0, A
;        
;        ; ?? CS ??
;        bcf     LATE, 0, A      ; CS = 0
;        movlw   100
;        call    delay_ms
;        bsf     LATE, 0, A      ; CS = 1
;        movlw   100
;        call    delay_ms
;        
;        movlw   'O'
;        call    UART_Transmit_Byte
;        movlw   'K'
;        call    UART_Transmit_Byte
;        movlw   '\n'
;        call    UART_Transmit_Byte
;        
;        ; ====== ?? 3: ?????? BMI160 ======
;        movlw   'T'
;        call    UART_Transmit_Byte
;        movlw   '3'
;        call    UART_Transmit_Byte
;        movlw   '\n'
;        call    UART_Transmit_Byte
;        
;        call    bmi160_init
;        
;        movlw   200
;        call    delay_ms
;
;main_loop:
;        ; ?? CHIP_ID
;        call    bmi160_read_chipid
;        
;        ; ????
;        movlw   'I'
;        call    UART_Transmit_Byte
;        movlw   'D'
;        call    UART_Transmit_Byte
;        movlw   '='
;        call    UART_Transmit_Byte
;        
;        movf    bmi160_chip_id, W, A
;        call    UART_SendHex
;        
;        movlw   '\n'
;        call    UART_Transmit_Byte
;        
;        ; ???? SSP1BUF ??????????
;        movlw   'B'
;        call    UART_Transmit_Byte
;        movlw   'U'
;        call    UART_Transmit_Byte
;        movlw   'F'
;        call    UART_Transmit_Byte
;        movlw   '='
;        call    UART_Transmit_Byte
;        
;        movf    SSP1BUF, W, A
;        call    UART_SendHex
;        
;        movlw   '\n'
;        call    UART_Transmit_Byte
;        movlw   '\n'
;        call    UART_Transmit_Byte
;        
;        movlw   250
;        call    delay_ms
;        
;        bra     main_loop
;
;END     rst

    global mydata
    extrn  SPI_MasterInit, SPI_MasterTransmit
    extrn  bmi160_init, bmi160_read_chipid
    extrn  UART_Setup, UART_Transmit_Byte, UART_SendHex
    extrn  delay_ms
    extrn  bmi160_chip_id

psect   udata_acs
test_byte:      ds 1

psect   code, abs
rst:    ORG     0x0
        goto    start

start:
        clrf    TRISA, A
        clrf    TRISB, A
        clrf    TRISD, A
        clrf    TRISE, A
        
        ; ???
        call    SPI_MasterInit
	bcf	CFGS
	bsf	EEPGD
        call    UART_Setup
        
        movlw   100
        call    delay_ms
        
        ; ====== ?? 1: SPI ???? ======
        movlw   'T'
        call    UART_Transmit_Byte
        movlw   '1'
        call    UART_Transmit_Byte
        movlw   'n'
        call    UART_Transmit_Byte
        
        ; ?? SDO1(RC5) ? SDI1(RC4)??? SPI
        movlw   0xAA            ; ???
        call    SPI_MasterTransmit
        movf    SSP1BUF, W, A
        call    UART_SendHex    ; ???? AA
        
        movlw   'n'
        call    UART_Transmit_Byte
        
        movlw   0x55            ; ??????
        call    SPI_MasterTransmit
        movf    SSP1BUF, W, A
        call    UART_SendHex    ; ???? 55
        
        movlw   'n'
        call    UART_Transmit_Byte
        
        ; ====== ?? 2: ?? CS ?? ======
        movlw   'T'
        call    UART_Transmit_Byte
        movlw   '2'
        call    UART_Transmit_Byte
        movlw   'n'
        call    UART_Transmit_Byte
        
        ; ?? RE0 ???
        bcf     TRISE, 0, A
        
        ; ?? CS ??
        bcf     LATE, 0, A      ; CS = 0
        movlw   100
        call    delay_ms
        bsf     LATE, 0, A      ; CS = 1
        movlw   100
        call    delay_ms
        
        movlw   'O'
        call    UART_Transmit_Byte
        movlw   'K'
        call    UART_Transmit_Byte
        movlw   'n'
        call    UART_Transmit_Byte
        
        ; ====== ?? 3: ?????? BMI160 ======
        movlw   'T'
        call    UART_Transmit_Byte
        movlw   '3'
        call    UART_Transmit_Byte
        movlw   'n'
        call    UART_Transmit_Byte
        
        call    bmi160_init
        
        movlw   200
        call    delay_ms

main_loop:
        ; ?? CHIP_ID
        call    bmi160_read_chipid
        
        ; ????
        movlw   'I'
        call    UART_Transmit_Byte
        movlw   'D'
        call    UART_Transmit_Byte
        movlw   '='
        call    UART_Transmit_Byte
        
        movf    bmi160_chip_id, W, A
        call    UART_SendHex
        
        movlw   'n'
        call    UART_Transmit_Byte
        
        ; ???? SSP1BUF ??????????
        movlw   'B'
        call    UART_Transmit_Byte
        movlw   'U'
        call    UART_Transmit_Byte
        movlw   'F'
        call    UART_Transmit_Byte
        movlw   '='
        call    UART_Transmit_Byte
        
        movf    SSP1BUF, W, A
        call    UART_SendHex
        
        movlw   'n'
        call    UART_Transmit_Byte
        movlw   'n'
        call    UART_Transmit_Byte
        
        movlw   250
        call    delay_ms
        
        bra     main_loop

END     rst



