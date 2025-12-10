#include <xc.inc>
    
global  UART_Setup, UART_Transmit_Message,UART_SendHex,HexToAscii,UART_Transmit_Byte,HEX_TEMP,TEMP_W
global  UART_Wait, UART_Sendraw_P
extrn   bmp388_p_l, bmp388_p_m, bmp388_p_h

psect	udata_acs   ; reserve data space in access ram
UART_counter: ds    1	    ; reserve 1 byte for variable UART_counter
HEX_TEMP:   ds 1
MSG_TEMP:   ds 1
temp:     ds 1
TEMP_W:   ds  1

psect	uart_code,class=CODE
UART_Setup:
    
    bsf	    SPEN	; enable
    bcf	    SYNC	; synchronous
    bcf	    BRGH	; slow speed
    bsf	    TXEN	; enable transmit
    bcf	    BRG16	; 8-bit generator only
    movlw   103		; gives 9600 Baud rate (actually 9615)
    movwf   SPBRG1, A	; set baud rate
    bsf	    TRISC, PORTC_TX1_POSN, A	; TX1 pin is output on RC6 pin
					; must set TRISC6 to 1
    return

UART_Transmit_Message:	    ; Message stored at FSR2, length stored in W
    movwf   UART_counter, A
UART_Loop_message:
    movf    POSTINC2, W, A
    call    UART_Transmit_Byte
    decfsz  UART_counter, A
    bra	    UART_Loop_message
    return

UART_Transmit_Byte:	    ; Transmits byte stored in W
    btfss   TX1IF	    ; TX1IF is set when TXREG1 is empty
    bra	    UART_Transmit_Byte
    movwf   TXREG1, A
    return

UART_Wait:
    btfss   TX1IF	    ; TX1IF is set when TXREG1 is empty
    bra	    UART_Wait
    return  
    
UART_Sendraw_P:
        movlw   0x00
	call    UART_Transmit_Byte
        movf    bmp388_p_h, W, A
	call    UART_Transmit_Byte
	movf    bmp388_p_m, W, A
	call    UART_Transmit_Byte
	movf    bmp388_p_l, W, A
	call    UART_Transmit_Byte
        movlw   0x00
	call    UART_Transmit_Byte
	return
    
    
UART_SendHex:
        movwf   HEX_TEMP, A         

        ; sent high nibble
        swapf   HEX_TEMP, W, A       ; high4digit to low4digit
        andlw   0x0F
        call    HexToAscii
        call    UART_Transmit_Byte

        ; sent low nibble
        movf    HEX_TEMP, W, A
        andlw   0x0F
        call    HexToAscii
        call    UART_Transmit_Byte

        ; sent 1 space 
        movlw   ' '
        call    UART_Transmit_Byte
        return
	


; nibble (0~15) ? ASCII ('0'..'9','A'..'F')
HexToAscii:
        movwf   TEMP_W, A
        addlw   -10
        btfss   STATUS, 0, A          ; C=1 original nibble >=10
        goto    digit
	
letter:	
	addlw   'A'                 ; W = (original W-10)+'A'
        return

digit:
        movf    TEMP_W, W, A               ; ??????W = (-10) + 10 = ??
	addlw   '0'                 ; ???? ASCII?W = ?? + '0'
	return