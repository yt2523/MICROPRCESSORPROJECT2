	 #include <xc.inc>

        global  SPI_MasterInit
        global  SPI_MasterTransmit, SPI_MasterRead, spi_data_out, SPI_MasterWrite

psect	udata_acs   ; reserve data space in access ram
spi_data_out: ds    1	    ; reserve 1 byte for variable UART_counter

psect	spi_code,class=CODE

SPI_MasterInit:
    bsf     CKE1                    ; CKE = 1
    movlw   ( SSP1CON1_SSPEN_MASK ) | ( SSP1CON1_SSPM1_MASK )
    movwf   SSP1CON1, A

    bcf     SSP1CON1, SSP1CON1_CKP_POSN, A ; CKP = 0

     
        bcf     TRISC, PORTC_SDO1_POSN, A   ; RC5 = SDO1 
        bcf     TRISC, PORTC_SCK1_POSN, A   ; RC3 = SCK1 
        bsf     TRISC, PORTC_SDI1_POSN, A   ; RC4 = SDI1 

        return



SPI_MasterTransmit:
        ; Start transmission of data (held in W)
        movwf   SSP1BUF, A          ; write data to output buffer

Wait_Transmit:
        ; Wait for transmission to complete
        btfss   PIR1, 3, A          ; check SSP1IF flag
        bra     Wait_Transmit

        bcf     PIR1, 3, A          ; clear SSP1IF flag
        return

SPI_MasterRead:
    
	iorlw	10000000b             

        ; sent order
	call	SPI_MasterTransmit

        ; sent dummy byte, received returned data
        movlw   0x00                 ; dummy = 0x00
	call	SPI_MasterTransmit

        ; end of second transfer, the readed byte is in SSP1BUF
	movf	SSP1BUF, W, A          ; put data back to W

	return


SPI_MasterWrite:
        ; writes a byte from the address data_byte_out 
	; to address held in W
	andlw	01111111b
	call	SPI_MasterTransmit
	movf	spi_data_out, W, A
	call	SPI_MasterTransmit
	
	return
