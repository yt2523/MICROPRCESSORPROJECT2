     #include <xc.inc>
    ; Declare external GLCD routines
    extrn  GLCD_Init, GLCD_clean_all

    ; Define absolute code section
    psect   code, abs

    ;Reset vector
    org     0x0000
    goto    main            ; Jump to main program

    ; Main program starts here
    org     0x0100
main:
    ; Initialize GLCD
    call    GLCD_Init
loop:
    ; Fill entire GLCD with all pixels ON
    call    GLCD_clean_all
    bra     loop

    end  main

