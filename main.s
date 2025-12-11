	#include <xc.inc> 
extrn   SPI_MasterInit, UART_Setup,bmi160_init,bmi160_gyro_config,GLCD_Init,graphic_init,GLCD_clean_all,buffer_clear_all
extrn   angle_l,angle_h
extrn   bmi160_read_gyro_xyz
extrn   delay_ms
extrn   UART_Send_angle
extrn   Gyro_DoCalculation
extrn   UART_Sendraw_O
extrn   omega_l,omega_h
extrn   angle_deg
extrn   GetAngleXY, Draw_cross_point
extrn   X_end, Y_end
	
	
psect	udata_acs   ; reserve data space in access ram
;variables calculate each loop

   
psect	code, abs

rst: 	org 0x0000
 	goto	setup
	;____________________set up________________________
setup:	
        clrf    TRISA ,A
	clrf    TRISB ,A
	clrf    TRISD ,A
	clrf    TRISE ,A
	bsf     LATE, 1, A
	
        bcf     CFGS    ; POINT TO FLASH 
        bsf     EEPGD
	call    GLCD_Init
	call    graphic_init
	call    GLCD_clean_all 
        call    buffer_clear_all
        call	SPI_MasterInit
	call	UART_Setup	
	call	bmi160_init
	call    bmi160_gyro_config
	;__________________initialization___________________	
;set_reset_bottom:
;        ;use portJ, RJ0 as input
;	movlw 	0xFF
;	movwf	TRISJ, A	    ; Port J all input
;
;	BSF     LATJ, 0, A     
clean_var:
        clrf    angle_l, A
	clrf    angle_h, A

	
set_reference:
        ;call sensor accept
        ;call    read_sensor
	;call UART send data,output message to UART
	;call	UART_Transmit_Message
	
	;___________________mian control loop _____________
control_loop:
;        call  bmi160_read_gyro_xyz
;        call  UART_Sendraw_O  ; show raw data 
;	
;	call  Gyro_DoCalculation
;	call  UART_Send_angle
;	
;	; angle_deg[0] = angle_l
;        movf    angle_l, W,A
;        movwf   angle_deg, A
;
;        ; angle_deg[1] = angle_h
;        movf    angle_h, W,A
;        movwf   angle_deg+1, A
;	call    GetAngleXY
    
        movlw   25
        movwf   X_end, A      ; X coordinate
        movwf   Y_end, A      ; Y coordinate (same as X for (x,x) point)
	call    Draw_cross_point
	
	movlw  200
	call   delay_ms
	call    buffer_clear_all
	bra   control_loop

end  rst