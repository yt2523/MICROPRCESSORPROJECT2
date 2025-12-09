#include <xc.inc>
        
global mydata
extrn  SPI_MasterInit, SPI_MasterTransmit
extrn  bmp388_init
extrn  UART_Setup, UART_Transmit_Byte, UART_SendHex
extrn  delay_ms,bmp388_addr, bmp388_value,bmp388_config
extRn  bmp388_press_L,bmp388_press_H,HEX_TEMP,TEMP_W


psect   udata_acs
test_byte:      ds 1	
mydata:	ds  2
byte0:   ds 1
byte1:   ds 1
byte2:   ds 1
byte3:   ds 1
mydata_len	EQU 2

psect   code, abs
rst:    ORG     0x0
        goto    start

start:
        clrf    TRISA, A
        clrf    TRISB, A
        clrf    TRISD, A
        clrf    TRISE, A
        
        ; ??? SPI
        call    SPI_MasterInit
        bcf     CFGS
        bsf     EEPGD
        call    UART_Setup
        
        movlw   100
        call    delay_ms
        
;        ; ====== ?? 1: SPI ???? ======
;        movlw   'T'
;        call    UART_Transmit_Byte
;        movlw   '1'
;        call    UART_Transmit_Byte
;        movlw   'n'
;        call    UART_Transmit_Byte
;        
;        ; ?? SDO1(RC5) ? SDI1(RC4) - SPI ??
;        movlw   0x07            ; ?? 0xAA
;        call    SPI_MasterTransmit
;        movf    SSP1BUF, W, A
;        call    UART_SendHex    ; ???? AA
;        
;        movlw   'n'
;        call    UART_Transmit_Byte
;        
;        movlw   0xAA            ; ?? 0x55
;        call    SPI_MasterTransmit
;        movf    SSP1BUF, W, A
;        call    UART_SendHex    ; ???? 55
;        
;        movlw   'n'
;        call    UART_Transmit_Byte
;	
;;        return     start
;        ; ====== ?? 2: ?? CS ?? ======
;        movlw   'T'
;        call    UART_Transmit_Byte
;        movlw   '2'
;        call    UART_Transmit_Byte
;        movlw   'n'
;        call    UART_Transmit_Byte
;        
;        ; ?? RE0 ???
;        bcf     TRISE, 0, A
;        
;        ; ?? CS ??
;        bcf     LATE, 1, A      ; CS = 0
;        movlw   100
;        call    delay_ms
;        bsf     LATE, 1, A      ; CS = 1
;        movlw   100
;        call    delay_ms
;        
;        movlw   'O'
;        call    UART_Transmit_Byte
;        movlw   'K'
;        call    UART_Transmit_Byte
;        movlw   'n'
;        call    UART_Transmit_Byte
        
        ; ====== ?? 3: ?????? ID ======
read:    
;	movlw   'T'
;        call    UART_Transmit_Byte
;        movlw   '3'
;        call    UART_Transmit_Byte
;        movlw   'n'
;        call    UART_Transmit_Byte
        
;        call    bmp388_init
;	call    bmp388_config
	
;bmp388_read_reg:
;        movwf   0x04
;        movwf   bmp388_addr, A
;
;        ; adress: bit7 = 1 (read), bit6..0 = ??
;        bcf     bmp388_addr, 7, A   ; ????? bit7
;        bsf     bmp388_addr, 7, A   ; ? 1 ???
;
;        bcf     LATE,1
;
;        ; send adress
;        movf    bmp388_addr, W, A
;        call    SPI_MasterTransmit   ; ?????
;
;        ;LSB  first 8-bit
;        movlw   0x00    ;dummy
;        call    SPI_MasterTransmit
;        movf    SSP1BUF, W, A
;         movwf   bmp388_press_L, A  ; 
;        ;next 8-bit  
;        movlw   0x00    ;dummy
;        call    SPI_MasterTransmit
;        movf    SSP1BUF, W, A
;        movwf   bmp388_press_H, A   ; ????
;
;        bsf     LATE,1
;	
;        return	
;	
;	movf    bmp388_press_L, W, A
;        call    UART_SendHex    ; ???? 55
;	
;	movf    bmp388_press_H, W, A
;        call    UART_SendHex    ; ???? 55
	
;bmp388_read_reg:
;	    movlw   0x06
;	    movwf   bmp388_addr, A

	    ; ????: bit7 = 1 (read), bit6..0 = adress
;	    bcf     bmp388_addr, 7, A   ; ????? bit7
;	    bsf     bmp388_addr, 7, A   ; ? 1 ???

;	    bcf     LATE,1

	    ; ??????
;	    movf    bmp388_addr, W, A
;	    call    SPI_MasterTransmit   ; ?????

	    ; dummy ??
    ;        movlw   0x00
    ;        call    SPI_MasterTransmit  


	    ; ????? SSP1BUF
;	    movf    SSP1BUF, W, A

;	    bsf     LATE,1
;	    nop
;	    nop
;	    nop
;	    call    UART_SendHex

bmp388_read_reg:
        movlw   0x00
        movwf   bmp388_addr, A

        ; ????: bit7 = 1 (read), bit6..0 = adress
;        bcf     bmp388_addr, 7, A   ; ????? bit7
        bsf     bmp388_addr, 7, A   ; ? 1 ???

        bcf     LATE,1

        ; ??????
        movf    bmp388_addr, W, A
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

        bsf     LATE,1
	nop
	nop
	nop
	call    UART_Sendraw
	
main_loop:

;        
        bra     bmp388_read_reg

UART_Sendraw:
        movf    byte0, W
	call    UART_Transmit_Byte
	movf    byte1, W
	call    UART_Transmit_Byte
	movf    byte2, W
	call    UART_Transmit_Byte
	movf    byte3, W
	call    UART_Transmit_Byte

	goto $
	return
END     rst