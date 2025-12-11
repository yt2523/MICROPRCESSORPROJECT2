#include <xc.inc>
    
global  UART_Setup
global  UART_Transmit_Message
global  UART_Transmit_Byte
global  UART_Sendraw_O, UART_Send_angle
;global  UART_Sendraw_P
;extrn   bmp388_p_l, bmp388_p_m, bmp388_p_h, bmp388_t_xlsb, bmp388_t_lsb, bmp388_t_msb
extrn   bmi160_gz_h,bmi160_gz_l,angle_h,angle_l

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

UART_Wait:
    btfss   TX1IF	    ; TX1IF is set when TXREG1 is empty
    bra	    UART_Wait
    return  
    
;UART_Sendraw_P:
;        movlw   0x00
;	call    UART_Transmit_Byte
;        movf    bmp388_p_h, W, A
;	call    UART_Transmit_Byte
;	movf    bmp388_p_m, W, A
;	call    UART_Transmit_Byte
;	movf    bmp388_p_l, W, A
;	call    UART_Transmit_Byte
;	
;        call    UART_Transmit_Byte
;        movf    bmp388_t_msb, W, A
;	call    UART_Transmit_Byte
;	movf    bmp388_t_lsb, W, A
;	call    UART_Transmit_Byte
;	movf    bmp388_t_xlsb, W, A
;	call    UART_Transmit_Byte
;        movlw   0x00
;	call    UART_Transmit_Byte
;	return
    
UART_Sendraw_O:
        movlw   0x00
	call    UART_Transmit_Byte
        movf    bmi160_gz_h, W, A
	call    UART_Transmit_Byte
	movf    bmi160_gz_l, W, A
	call    UART_Transmit_Byte
        movlw   0x00
	call    UART_Transmit_Byte
	return
	
UART_Send_angle:
        movlw   0x11
	call    UART_Transmit_Byte
        movf    angle_h, W, A
	call    UART_Transmit_Byte
	movf    angle_l, W, A
	call    UART_Transmit_Byte
        movlw   0x11
	call    UART_Transmit_Byte
	return