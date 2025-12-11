#include <xc.inc>
        
global byte0, byte1, byte2, byte3
extrn  SPI_MasterInit, SPI_MasterTransmit
extrn  bmp388_init, bmi160_read_chipid
extrn  UART_Setup, UART_Transmit_Byte, UART_SendHex, UART_Wait, UART_Sendraw_P
extrn  delay_ms,bmp388_addr, bmp388_value,bmp388_config
extrn  HEX_TEMP,TEMP_W
extrn  bmp388_read_raw_P
extrn  bmp388_p_l, bmp388_p_m, bmp388_p_h
extrn  bmi160_chip_id,bmi160_init,UART_Sendraw_O,bmi160_gyro_config,bmi160_read_gyro_xyz
    
psect   udata_acs
test_byte:      ds 1	
byte0:   ds 1
byte1:   ds 1
byte2:   ds 1
byte3:   ds 1

psect   code, abs
rst:    ORG     0x0
        goto    main
	
main:
        clrf    TRISA, A
        clrf    TRISB, A
        clrf    TRISD, A
        clrf    TRISE, A
	bsf	LATE, 1, A
	nop
	nop
	nop
	nop
        bcf     LATE, 1, A
	nop
	nop
	nop
	nop
        bsf     LATE, 1, A
    
        ;SPI init
        call    SPI_MasterInit
	; UART init 
        bcf     CFGS
        bsf     EEPGD
        call    UART_Setup
        call	bmi160_init
	call    bmi160_gyro_config
try:	
	; bmp  init
;	call	bmi160_init
	movlw   50
        call    delay_ms
        call   bmi160_read_gyro_xyz
	call   UART_Sendraw_O
	bra    try
	
;	call	bmp388_config
;        movlw   100
;        call    delay_ms
;	
;try:
;        call   bmp388_read_raw_P
;	call   UART_Sendraw_P
;	        ; delay
;        movlw   50     
;        call    delay_ms
;	bra    try
	
	
END     rst