#include <xc.inc>
        
global mydata
extrn  SPI_MasterInit, SPI_MasterTransmit
extrn  bmp388_init
extrn  UART_Setup, UART_Transmit_Byte, UART_SendHex
extrn  delay_ms


psect   udata_acs
test_byte:      ds 1	
mydata:	ds  2
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
        
        ; ====== ?? 1: SPI ???? ======
        movlw   'T'
        call    UART_Transmit_Byte
        movlw   '1'
        call    UART_Transmit_Byte
        movlw   'n'
        call    UART_Transmit_Byte
        
        ; ?? SDO1(RC5) ? SDI1(RC4) - SPI ??
        movlw   0xAA            ; ?? 0xAA
        call    SPI_MasterTransmit
        movf    SSP1BUF, W, A
        call    UART_SendHex    ; ???? AA
        
        movlw   'n'
        call    UART_Transmit_Byte
        
        movlw   0x55            ; ?? 0x55
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
        
        ; ====== ?? 3: ?????? ID ======
        movlw   'T'
        call    UART_Transmit_Byte
        movlw   '3'
        call    UART_Transmit_Byte
        movlw   'n'
        call    UART_Transmit_Byte
        
        call    bmp388_init
        
        movlw   200
        call    delay_ms

main_loop:
;        ; ?? CHIP_ID
;        call    bmi160_read_chipid
;        
;        ; ?? "ID="
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
;        movlw   'n'
;        call    UART_Transmit_Byte
;        
;        ; ???? SSP1BUF ??????
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
;        movlw   'n'
;        call    UART_Transmit_Byte
;        movlw   'n'
;        call    UART_Transmit_Byte
;        
;        movlw   250
;        call    delay_ms
;        
        bra     start

END     rst