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
extrn   AngleXTable,AngleYTable, buffer_to_GLCD,Bresenham_circle_loop,circle_r
	
	
;psect	udata_acs   ; reserve data space in access ram
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
	;call    GLCD_clean_all 
        call    buffer_clear_all
        call	SPI_MasterInit
	call	UART_Setup	
	call	bmi160_init
	call    bmi160_gyro_config
	;__________________initialization___________________	
set_reset_bottom:
        ;use portJ, RJ0 as input
	movlw 	0xFF
	movwf	TRISJ, A	    ; Port J all input

	bcf     LATJ, 0, A     
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

        call  bmi160_read_gyro_xyz
        call  UART_Sendraw_O  ; show raw data 
	
	call  Gyro_DoCalculation
	call  UART_Send_angle
	
        call  GetAngleXY
	call  Draw_cross_point
	
	movlw  25
	movwf  circle_r, A
	call   Bresenham_circle_loop
	nop
        call    buffer_to_GLCD
	call    buffer_clear_all
	
	btfss   PORTJ, 0, A   ;detect reset
	bra    control_loop
	bra     set_reset_bottom

end  rst