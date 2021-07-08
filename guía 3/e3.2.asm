;   Ejercicio 3.2:
;
;   Escribir un programa que sume dos valores guardados en los registros 21H
;   y 22H con resultado en 23H y 24H.

;-------------------LIBRERIAS---------------------------------------------------

	#INCLUDE    <P16F887.INC>

	    LIST    P = 16F887

;-------------------CONFIGURACION PIC-------------------------------------------

	__CONFIG    _CONFIG1, _FOSC_INTRC_NOCLKOUT & _WDTE_OFF & _PWRTE_OFF & _MCLRE_ON & _CP_OFF & _CPD_OFF & _BOREN_ON & _IESO_ON & _FCMEN_ON & _LVP_ON
	__CONFIG    _CONFIG2, _BOR4V_BOR40V & _WRT_OFF

;-------------------DECLARACION DE VARIABLES------------------------------------

	    VAR1    EQU	    0x21    ; Estos registros van a ser sumados.
	    VAR2    EQU	    0x22
	    RES1    EQU	    0x23    ; En estos registros voy a almacenar
	    RES2    EQU	    0x24    ; el resultado de la suma.

;-------------------CONFIGURACION DE REGISTROS----------------------------------
	    
	    ORG	    0x00
	    
	    MOVLW   .255	    ; Cargo valores aleatorios en VAR1 y VAR2.
	    MOVWF   VAR1
	    MOVLW   .1
	    MOVWF   VAR2
	    CLRF    RES1	    ; Limpio los registros de resultado para
	    CLRF    RES2	    ; evitar tener valores incorrectos.

;-------------------INICIO DEL PROGRAMA-----------------------------------------

	    MOVFW   VAR1	    ; Cargo el valor de VAR1 en W.
	    ADDWF   VAR2,0	    ; Sumo lo que hay en W con VAR2
				    ; y lo almaceno en W.
            MOVWF   RES1	    ; Almaceno W + VAR2 en RES1.
	    RLF	    RES2	    ; Roto mediante el bit de carry el registro
				    ; RES2 por si la suma es 255 + 1.
	    END