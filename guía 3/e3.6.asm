;   Ejercicio 3.6:
;
;   Escribir un programa que su ejecución demore un segundo (cristal de 4[MHz]).

;-------------------LIBRERIAS---------------------------------------------------

	#INCLUDE    <P16F887.INC>

	    LIST    P = 16F887

;-------------------CONFIGURACION PIC-------------------------------------------

	__CONFIG    _CONFIG1, _FOSC_INTRC_NOCLKOUT & _WDTE_OFF & _PWRTE_OFF & _MCLRE_ON & _CP_OFF & _CPD_OFF & _BOREN_ON & _IESO_ON & _FCMEN_ON & _LVP_ON
	__CONFIG    _CONFIG2, _BOR4V_BOR40V & _WRT_OFF

;-------------------DECLARACION DE VARIABLES------------------------------------
	    
	    ORG	    0x00

	    V1	    EQU	    0x20    ; Variable para el loop interno.
	    V2	    EQU	    0x21    ; Variable para el loop medio.
	    V3	    EQU	    0x22    ; Variable para el loop externo.

;-------------------CONFIGURACION DE REGISTROS----------------------------------
	    
	    CLRF    V1		    ; Limpio los registros a utilizar para
	    CLRF    V2		    ; evitar residuos de ejecuciones anteriores.
	    CLRF    V3
	    CLRW

;-------------------INICIO DEL PROGRAMA-----------------------------------------

    LEXT    MOVLW   .6		    ; Cargo V1, V2 y V3 con valores previamente
	    MOVWF   V3		    ; calculados para que el ciclo dure 1[s].
    LMED    MOVLW   .217
	    MOVWF   V2
    LINT    MOVLW   .255
	    MOVWF   V1
	    DECFSZ  V1		    ; Decremento V1. Si aún no es cero...
	    GOTO    $-1		    ; sigo decrementando V1.
	    DECFSZ  V2		    ; Si V1 es cero, decremento V2.
	    GOTO    LINT	    ; Si V2 aún no es cero, recargo V1 y repito.
	    DECFSZ  V3		    ; Si V2 es cero, decremento V3.
	    GOTO    LMED	    ; Si V3 aún no es cero, recargo V2 y repito.
	    GOTO    LEXT	    ; Si V3 es cero, recargo V3 y repito.
	    
	    END
