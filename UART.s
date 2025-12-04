#include <xc.inc>
    
global  UART_Setup, UART_Transmit_Message,UART_SendHex

psect	udata_acs   ; reserve data space in access ram
UART_counter: ds    1	    ; reserve 1 byte for variable UART_counter

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

    GLOBAL UART_SendHex
    GLOBAL HexToAscii

UART_SendHex:
        movwf   HEX_TEMP, A         

        ; sent high nibble
        swapf   HEX_TEMP, W, A       ; high4digit to low4digit
        andlw   0x0F
        call    HexToAscii
        call    UART_Transmit_Byte

        ; sent high nibble
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
        addlw   -10
        btfss   STATUS, 0          ; C=1 original nibble >=10
        goto    digit

   
        addlw   'A'                 ; W = (original W-10)+'A'
        return

digit:
        addlw   '0'+10              ; compensate previouse -10??? + '0'
        return



psect udata_acs
HEX_TEMP:   ds 1



