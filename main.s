#include <xc.inc>
        
global byte0, byte1, byte2, byte3
extrn  SPI_MasterInit, SPI_MasterTransmit
extrn  bmp388_init
extrn  UART_Setup, UART_Transmit_Byte, UART_SendHex, UART_Wait, UART_Sendraw_P
extrn  delay_ms,bmp388_addr, bmp388_value,bmp388_config
extrn  HEX_TEMP,TEMP_W
extrn  bmp388_read_raw_P


psect   udata_acs
test_byte:      ds 1	
byte0:   ds 1
byte1:   ds 1
byte2:   ds 1
byte3:   ds 1

psect   code, abs
rst:    ORG     0x0
        goto    start

start:
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

	
		
        ;  SPI init
        call    SPI_MasterInit
	; UART init 
        bcf     CFGS
        bsf     EEPGD
        call    UART_Setup
	; bmp  init
	call	bmp388_init
	call	bmp388_config
        ; delay
        movlw   100
        call    delay_ms

do_config:
	call	bmp388_config
        
        movlw   100
        call    delay_ms
     
read:    
        movlw   0x00
        movwf   bmp388_addr, A


bmp388_read_reg:
        movlw   0x04
        movwf   bmp388_addr, A


        ; ????: bit7 = 1 (read), bit6..0 = adress
;        bcf     bmp388_addr, 7, A   ; ????? bit7
	bcf	bmp388_addr, 7, A
        bcf     LATE,1, A

        ; ??????
        movf    bmp388_addr, W, A
	iorlw	0x80	; set read operation
        call    SPI_MasterTransmit   ; ?????
	
	movlw   0x00
	call    SPI_MasterTransmit

        ; dummy ??
        movlw   0x00
        call    SPI_MasterTransmit
	movwf   byte0, A 
	        ; dummy ??
        movlw   0x00
        call    SPI_MasterTransmit
	movwf   byte1, A 
	        ; dummy ??
        movlw   0x00
        call    SPI_MasterTransmit
	movwf   byte2, A 
	nop

        movlw   0x00
        call    SPI_MasterTransmit
	movwf   byte3, A 
	nop

        ; ????? SSP1BUF
;        movf    SSP1BUF, W, A

        bsf     LATE,1, A
	nop
	nop
	nop
	call    UART_Sendraw
	
main_loop:

;        
	bra	do_config
        bra     bmp388_read_reg

UART_Sendraw:
        movf    bmp388_addr, W, A
	andlw	0x7f
	call    UART_Transmit_Byte
	incf	bmp388_addr, F, A
        movf    byte0, W, A
	call    UART_Transmit_Byte
        movf    bmp388_addr, W, A
	andlw	0x7f
	call    UART_Transmit_Byte
	incf	bmp388_addr, F, A
	movf    byte1, W, A
	call    UART_Transmit_Byte
        movf    bmp388_addr, W, A
	andlw	0x7f
	call    UART_Transmit_Byte
	incf	bmp388_addr, F, A
	movf    byte2, W, A
	call    UART_Transmit_Byte
        movf    bmp388_addr, W, A
	andlw	0x7f
	call    UART_Transmit_Byte
	incf	bmp388_addr, F, A
	movf    byte3, W, A
	call    UART_Transmit_Byte
	call	UART_Wait

	return
	
;main:
;        clrf    TRISA, A
;        clrf    TRISB, A
;        clrf    TRISD, A
;        clrf    TRISE, A
;	bsf	LATE, 1, A
;	nop
;	nop
;	nop
;	nop
;        bcf     LATE, 1, A
;	nop
;	nop
;	nop
;	nop
;        bsf     LATE, 1, A
;    
;        ;SPI init
;        call    SPI_MasterInit
;	; UART init 
;        bcf     CFGS
;        bsf     EEPGD
;        call    UART_Setup
;	; bmp  init
;	call	bmp388_init
;	call	bmp388_config
;        ; delay
;        movlw   100
;        call    delay_ms
;	
;try:
;        call   bmp388_read_raw_P
;	call   UART_Sendraw_P
;	bra    try
;	
;	
END     rst