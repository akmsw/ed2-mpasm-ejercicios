;   Ejercicio 3.8:
;
;   Escribir un programa para almacenar el valor 33D en 15 posiciones contiguas
;   de la memoria de datos, empezando en la dirección 30H.

;-------------------LIBRERIAS---------------------------------------------------

	#INCLUDE    <P16F887.INC>

	    LIST    P = 16F887

;-------------------CONFIGURACION PIC-------------------------------------------

	__CONFIG    _CONFIG1, _FOSC_INTRC_NOCLKOUT & _WDTE_OFF & _PWRTE_OFF & _MCLRE_ON & _CP_OFF & _CPD_OFF & _BOREN_ON & _IESO_ON & _FCMEN_ON & _LVP_ON
	__CONFIG    _CONFIG2, _BOR4V_BOR40V & _WRT_OFF

;-------------------DECLARACION DE VARIABLES------------------------------------
	    
	    ORG	    0x00

	    AMOUNT  EQU	    0x20    ; Cantidad de registros a escribir (.15).

;-------------------CONFIGURACION DE REGISTROS----------------------------------
	    
	    CLRW		    ; Limpio los registros a utilizar para
				    ; evitar basura de ejecuciones anteriores.
	    MOVLW   0x0F	    ; Cargo la cantidad de registros a escribir
	    MOVWF   AMOUNT	    ; (.15).

;-------------------INICIO DEL PROGRAMA-----------------------------------------

	    MOVLW   0x30	    ; Cargo en W la dirección inicial.
	    MOVWF   FSR		    ; Cargo en FSR la dirección de memoria.
    LOOP    MOVLW   0x21	    ; Cargo en W el valor a almacenar.
	    MOVWF   INDF	    ; Cargo el valor de W en INDF.
	    DECFSZ  AMOUNT	    ; Decremento AMOUNT. Si no es cero...
	    GOTO    CONTINUE	    ; Voy a la etiqueta CONTINUE.
	    GOTO    $		    ; Si es cero, termino el programa.

CONTINUE    INCF    FSR		    ; Incremento el valor de FSR (la dirección
	    GOTO    LOOP	    ; de memoria) y vuelvo al loop.
	    
	    END