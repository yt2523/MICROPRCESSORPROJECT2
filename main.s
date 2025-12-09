	#include <xc.inc>

	extrn Gyro_DoCalculation
	extrn Baro_DoCalculation
	
	extrn  bmi160_gz_h
	extrn  bmi160_gz_l
	extrn  angle_h
	extrn  angle_l
	extrn  baro_p_h, baro_p_l
	extrn  baro_base_h, baro_base_l
	extrn  zoom_h, zoom_l
	extrn  IMU_Read
	extrn  Baro_ReadPressure
;	extrn  SPI_Init
;	extrn  IMU_Init
;	extrn  Baro_Init
;	extrn  UART_Init
	
	global Start
	
;	psect   udata_acs
;   
;;angle after integration
;angle_l:         ds 1      ; low angle
;angle_h:         ds 1      ; high angle
    
    psect code, abs
 
Start:  ;all change to real function name latter
    
;    call SPI_Init
;    call IMU_Init
;    call Baro_Init
;    call UART_Init
;    
    clrf    angle_l, A ;clean angle
    clrf    angle_h, A


    call    Baro_ReadPressure ;read once as baseline pressure
    movff   baro_p_h, baro_base_h ;move base pressure
    movff   baro_p_l, baro_base_l
    
Mainloop:
    
;    IMU
    call    IMU_Read ;change name to real function
    call    Gyro_DoCalculation
    
;    barometer
    call    Baro_ReadPressure ;change name to real function
    call    Baro_DoCalculation
    
    goto    Mainloop
    
; add delay
 
    
END