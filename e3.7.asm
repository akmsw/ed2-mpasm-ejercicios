;   Ejercicio 3.7:
;
;   Escribir un programa que compare dos números A y B.

;-------------------LIBRERIAS---------------------------------------------------

	#INCLUDE    <P16F887.INC>

	    LIST    P = 16F887

;-------------------CONFIGURACION PIC-------------------------------------------

	__CONFIG    _CONFIG1, _FOSC_INTRC_NOCLKOUT & _WDTE_OFF & _PWRTE_OFF & _MCLRE_ON & _CP_OFF & _CPD_OFF & _BOREN_ON & _IESO_ON & _FCMEN_ON & _LVP_ON
	__CONFIG    _CONFIG2, _BOR4V_BOR40V & _WRT_OFF

;-------------------DECLARACION DE VARIABLES------------------------------------
	    
	    ORG	    0x00

	    VARA    EQU	    0x20    ; Variables a comparar.
	    VARB    EQU	    0x21
	    ANS	    EQU	    0x22    ; Variable que almacena el resultado de la
				    ; comparación:  * 0 = son iguales
				    ;		    * 1 = A < B
				    ;		    * 2 = A > B

;-------------------CONFIGURACION DE REGISTROS----------------------------------
	    
	    CLRW		    ; Limpio el registro W para eliminar basura.

;-------------------INICIO DEL PROGRAMA-----------------------------------------

	    MOVLW   .4		    ; Cargo VARA y VARB con valores aleatorios.
	    MOVWF   VARA
	    MOVLW   .3
	    MOVWF   VARB
	    MOVFW   VARA    
	    SUBWF   VARB,0	    ; Resto B - A y almaceno el resultado en W.
	    BTFSC   STATUS,Z	    ; Si la resta dio cero (A = B)...
	    GOTO    EQUALS	    ; Voy a la etiqueta EQUALS.
	    BTFSC   STATUS,C	    ; Si hubo carry (A < B por complem. a 2)...
	    GOTO    AMINOR
	    GOTO    ABIGGER
	    
EQUALS	    CLRF    ANS		    ; Si A = B, cargo 0 en ANS.
	    GOTO    $

AMINOR	    MOVLW   .1		    ; Si A < B, cargo 1 en ANS.
	    MOVWF   ANS
	    GOTO    $

ABIGGER	    MOVLW   .2		    ; Si A > B, cargo 2 en ANS.
	    MOVWF   ANS
	    GOTO    $
	    
	    END