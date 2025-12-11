#include <xc.inc>

;	extrn Gyro_DoCalculation
	extrn Baro_DoCalculation
	
;	extrn  bmi160_gz_h
;	extrn  bmi160_gz_l
;	extrn  angle_h
;	extrn  angle_l
	extrn  baro_p_h, baro_p_l,baro_p_m
	extrn  baro_base_h, baro_base_l,baro_base_m
	extrn  zoom_h, zoom_l,zoom_m
;	extrn  IMU_Read
	extrn  Baro_ReadPressure
	extrn  radius
;	extrn  SPI_Init
;	extrn  IMU_Init
;	extrn  Baro_Init
;	extrn  UART_Init
	
;	global Start
	
;	psect   udata_acs
;   
;;angle after integration
;angle_l:         ds 1      ; low angle
;angle_h:         ds 1      ; high angle
    
psect	code, abs	
rst: 	org 0x0000
 	goto	 Start

 psect code, class=CODE, abs
    org     0x0100
Start:  ;all change to real function name latter
    
;    call SPI_Init
;    call IMU_Init
;    call Baro_Init
;    call UART_Init
    
GOww:    
    movlw   15
    movwf   radius, A
;    clrf    angle_l, A ;clean angle
;    clrf    angle_h, A
    call    Baro_ReadPressure ;read once as baseline pressure ? ?3????current loop????
    movff   baro_p_h, baro_base_h ;move base pressure
    movff   baro_p_l, baro_base_l
    movff   baro_p_m, baro_base_m

    
Mainloop:
    
;;    IMU
;    call    IMU_Read ;change name to real function
;    call    Gyro_DoCalculation
    
;    barometer
    call    Baro_ReadPressure ;change name to real function
;    movff   baro_p_h, baro_base_h ;move base pressure
;    movff   baro_p_l, baro_base_l
    call    Baro_DoCalculation
    
    goto    Mainloop
    
; add delay
 
    
END Start