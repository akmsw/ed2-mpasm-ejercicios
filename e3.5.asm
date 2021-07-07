;   Ejercicio 3.5:
;
;   Escribir un programa que su ejecución dure un milisegundo
;   (cristal de 4MHz).

;-------------------LIBRERIAS---------------------------------------------------

	#INCLUDE    <P16F887.INC>

	    LIST    P = 16F887

;-------------------CONFIGURACION PIC-------------------------------------------

	__CONFIG    _CONFIG1, _FOSC_INTRC_NOCLKOUT & _WDTE_OFF & _PWRTE_OFF & _MCLRE_ON & _CP_OFF & _CPD_OFF & _BOREN_ON & _IESO_ON & _FCMEN_ON & _LVP_ON
	__CONFIG    _CONFIG2, _BOR4V_BOR40V & _WRT_OFF

;-------------------DECLARACION DE VARIABLES------------------------------------
	    
	    ORG	    0x00

	    V1	    EQU	    0x20    ; Variable para el loop interno.
	    V2	    EQU	    0x21    ; Variable para el loop externo.

;-------------------CONFIGURACION DE REGISTROS----------------------------------
	    
	    CLRF    V1		    ; Limpio los registros a utilizar para
	    CLRF    V2		    ; evitar residuos de ejecuciones anteriores.
	    CLRW

;-------------------INICIO DEL PROGRAMA-----------------------------------------

    LEXT    MOVLW   .4		    ; Cargo V1 y V2 con valores precalculados
	    MOVWF   V2		    ; para que el ciclo dure 1[ms].
    LINT    MOVLW   .83
	    MOVWF   V1
	    DECFSZ  V1		    ; Decremento V1. Si aún no es cero...
	    GOTO    $-1		    ; sigo decrementando V1.
	    DECFSZ  V2		    ; Si V1 es cero, decremento V2.
	    GOTO    LINT	    ; Si V2 aún no es cero, recargo V1 y repito.
	    GOTO    LEXT	    ; Si V2 es cero, recargo V2 y repito.
	    
	    END
