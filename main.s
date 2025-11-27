	#include <xc.inc>
extrn	UART_Setup, UART_Transmit_Message  ;UART transmit data,use to record
extrn	GLCD_Setup,                        ;GLCD 
extrn   Sensor_Setup                       ;sensor

psect	udata_acs   ; reserve data space in access ram
;variables calculate each loop
R_C:    ds 1    ; radius of circle
A_L:    ds 1    ; angle of line
P_reading:    ds 2  ;reading form pressure sensor
O_reading:    ds 2  ;reading form orientation sensor
P_reference:  ds 2  ;pressure reference
O_reference:  ds 2  ;orientation reference

   
psect	code, abs

rst: 	org 0x0
 	goto	setup

	;____________________set up________________________
setup:	call	UART_Setup	
	call	GLCD_Setup	
	call	Sensor_Setup	
	;__________________initialization___________________	
set_reset_bottom:
        ;use portJ, RJ0 as input
	movlw 	0xFF
	movwf	TRISJ, A	    ; Port J all input

	BSF     LATJ, 0, A     
clean_var:
        CLRF  P_reading, A  ;if its 16bits, also clean P_reading+1
	CLRF  O_reading, A
	CLRF  A_L, A
	CLRF  R_C, A
	CLRF  O_reference, A
	clrf  P_reference, A
	
set_reference:
        ;call sensor accept
        call    read_sensor
	;call UART send data,output message to UART
	call	UART_Transmit_Message
	
	;___________________mian control loop _____________
control_loop:
        ;1.read sensor
	call   read_sensor
	
	;2.check reset botton   RJ0=0 continue  RJ0=1 pressed
	btfsc   PORTJ, 0, A    ;check RJ0 value, skip next line if is 0
	call    reset_reference  ;00000001B-bottom pressed, maybe add need check twice(?
        ;3. calculate control
	
	
	;4. ploting & send data to GLCD
	
	bra  control_loop



read_sensor:; read two sensor and store variable in P_reading and O_reading
        call
	return
	
reset_reference:; clear all calculation, set the reading now as reference value
        movff   P_reading, P_reference  
	movff   O_reading, O_reference
	CLRF  P_reading, A
	CLRF  O_reading, A
	return control_loop