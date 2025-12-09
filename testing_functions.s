    #include <xc.inc>

    global  IMU_Read
    global  Baro_ReadPressure

    extrn   bmi160_gz_h, bmi160_gz_l
    extrn   baro_p_h, baro_p_l

psect   q_code, class=code
  
IMU_Read:
    movlw   0x01
    movwf   bmi160_gz_h, A
    movlw   0x00
    movwf   bmi160_gz_l, A
    return

Baro_ReadPressure:
    incf    baro_p_l, F, A
    movlw   0x01
    movwf   baro_p_h, A
    return





