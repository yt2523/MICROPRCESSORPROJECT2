#include <xc.inc>

global  SPI_MasterInit
global  SPI_MasterTransmit


psect	spi_code,class=CODE

SPI_MasterInit:
        ; 1) ??? I/O ?????????? SPI ????
        bcf     TRISC, 5, A         ; RC5 = SDO1 
        bcf     TRISC, 3, A         ; RC3 = SCK1 
        bsf     TRISC, 4, A         ; RC4 = SDI1 
        
        ; 2) ?? SPI??????????
        clrf    SSP1CON1, A
        
        ; 3) ?? SSP1STAT
        ;    CKE = 1 
        ;    SMP = 0 
;        movlw   0x40                ; CKE = 1, SMP = 0
        movlw   0x40                ; CKE = 0, SMP = 1
        movwf   SSP1STAT, A
        
        ; 4) ?? SSP1CON1
        ;    SSPEN = 1 ( SPI)
        ;    CKP = 0 
        ;    SSPM = 0001 (SPI Master mode, clock = Fosc/16)
        ;    ???? Fosc/16 ? Fosc/64 ?????
        movlw   00100010B               ; 0010 0001
                                    ; bit5 = SSPEN = 1
                                    ; bit3-0 = SSPM = 0001 (Fosc/16)
        movwf   SSP1CON1, A
        
        ; 5) ??????
        bcf     PIR1, 3, A          ; ?? SSP1IF
        
        return



SPI_MasterTransmit:
        ; Start transmission of data (held in W)
	bcf   SSP1IF 
        movwf   SSP1BUF, A          ; write data to output buffer

Wait_Transmit:
        ; Wait for transmission to complete
        btfss   SSP1IF          ; check SSP1IF flag
        bra     Wait_Transmit
	movf    SSP1BUF, W, A   ;??????get data?
	bcf     SSP1IF           ; clear SSP1IF flag
        return


