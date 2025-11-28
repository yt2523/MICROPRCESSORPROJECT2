	 #include <xc.inc>

        global  SPI_MasterInit
        global  SPI_MasterTransmit, SPI_MasterRead, spi_data_out

psect	udata_acs   ; reserve data space in access ram
spi_data_out: ds    1	    ; reserve 1 byte for variable UART_counter

psect	spi_code,class=CODE
; =====================================
; SPI_MasterInit
; ???? SPI2 ????? SPI1 + PORTC
;   - CKP = 0, CKE1 = 1  --> SPI mode 0
;   - ????, ?? Fosc/64?????
;   - SDO1: RC5 ??
;   - SCK1: RC3 ??
;   - SDI1: RC4 ??
; =====================================
SPI_MasterInit:
        ; ???????CKE1 = 1 (???????????)?CKP=0
        bsf     CKE1                ; CKE1 bit in SSP1STAT

        ; MSSP1 enable; CKP=0; SPI master, clock = Fosc/64
        ; ? PPT ???????
        ; movlw ( SSP2CON1_SSPEN_MASK )|( SSP2CON1_CKP_MASK )|( SSP2CON1_SSPM1_MASK )
        ; ?? SSP1 ?????? CKP ??=0?
        movlw   ( SSP1CON1_SSPEN_MASK ) | ( SSP1CON1_SSPM1_MASK )
        movwf   SSP1CON1, A

        ; SDO1 output; SCK1 output; SDI1 input
        ; ?????? PPT ????????
        ;   bcf TRISD, PORTD_SDO2_POSN, A
        ;   bcf TRISD, PORTD_SCK2_POSN, A
        ; ???? PORTC ?? SDO1 / SCK1 / SDI1
        bcf     TRISC, PORTC_SDO1_POSN, A   ; RC5 = SDO1 ??
        bcf     TRISC, PORTC_SCK1_POSN, A   ; RC3 = SCK1 ??
        bsf     TRISC, PORTC_SDI1_POSN, A   ; RC4 = SDI1 ??

        return


; =====================================
; SPI_MasterTransmit
; ?? PPT ?? SPI_MasterTransmit ??
; ??:   WREG = ??????
; ??:   ??? SSP1BUF ?????????
; ????? MISO ?????????? movf SSP1BUF,W
; =====================================
SPI_MasterTransmit:
        ; Start transmission of data (held in W)
        movwf   SSP1BUF, A          ; write data to output buffer

Wait_Transmit:
        ; Wait for transmission to complete
        ; ? SPI2?PPT ????btfss PIR2, 5   /   bcf PIR2, 5
        ; ? SPI1?SSP1IF ? PIR1 ? bit3
        btfss   PIR1, 3, A          ; check SSP1IF flag
        bra     Wait_Transmit

        bcf     PIR1, 3, A          ; clear SSP1IF flag
        return

SPI_MasterRead:
        ; Reads byte from address held in W
	; Returns data read in W
	iorlw	1000000b
	call	SPI_MasterTransmit
	call	SPI_MasterTransmit
	movf	SSP1BUF, W, A          ; read data into W
	
	return

SPI_MasterWrite:
        ; writes byte from address data_byte_out 
	; to address held in W
	andlw	01111111b
	call	SPI_MasterTransmit
	movf	spi_data_out, W, A
	call	SPI_MasterTransmit
	
	return
