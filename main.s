
        #include <xc.inc>

        extrn  SPI_MasterInit
        extrn  bmi160_init
	extrn  bmi160_gyro_config
        extrn  bmi160_read_gyro_xyz
	extrn bmp388_init
        extrn bmp388_config
        extrn bmp388_read_raw


    psect   resetVec, class=CODE, delta=2

        ORG     0x0000
        goto    start

start:

        clrf    TRISA
        clrf    TRISB
        clrf    TRISD
        clrf    TRISE          ; RE0 = CS

        ; ------- SPI1 -------
        call    SPI_MasterInit

        ; ------- BMI160 CS  + dummy read +  chipid -------
        call    bmi160_init

        ; ------- gyro: range + ODR + PMU normal -------
        call    bmi160_gyro_config
	
        ; ------- BMP388 init + config -------
        call    bmp388_init
        call    bmp388_config

main_loop:
   
        ;   call bmi160_read_gyro_xyz
      
        bra     main_loop

        END


