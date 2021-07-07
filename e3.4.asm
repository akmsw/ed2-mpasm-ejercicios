;   Ejercicio 3.4:
;
;   Escribir un programa que sume dos números de 16 bits A (20H, 21H) y
;   y B (22H, 23H) y al resultado colocarlo en A.

;-------------------LIBRERIAS---------------------------------------------------

	#INCLUDE    <P16F887.INC>

	    LIST    P = 16F887

;-------------------CONFIGURACION PIC-------------------------------------------

	__CONFIG    _CONFIG1, _FOSC_INTRC_NOCLKOUT & _WDTE_OFF & _PWRTE_OFF & _MCLRE_ON & _CP_OFF & _CPD_OFF & _BOREN_ON & _IESO_ON & _FCMEN_ON & _LVP_ON
	__CONFIG    _CONFIG2, _BOR4V_BOR40V & _WRT_OFF

;-------------------DECLARACION DE VARIABLES------------------------------------
	    
	    ORG	    0x00

	    A1	    EQU	    0x21    ; Estos registros van a conformar la
	    A2	    EQU	    0x20    ; operación.
	    B1	    EQU	    0x23
	    B2	    EQU	    0x22
	    AUX	    EQU	    0x24    ; Variable auxiliar.

;-------------------CONFIGURACION DE REGISTROS----------------------------------
	    
	    MOVLW   0xFF	    ; Cargo valores aleatorios en cada
	    MOVWF   A1		    ; variable.
	    MOVLW   0xFF
	    MOVWF   A2
	    MOVLW   0xFF
	    MOVWF   B1
	    MOVLW   0xFF
	    MOVWF   B2
	    CLRW		    ; Limpio W para evitar tener basura.
	    CLRF    AUX		    ; Limpio AUX con el mismo fin.

;-------------------INICIO DEL PROGRAMA-----------------------------------------

	    MOVFW   A1		    ; Cargo A1 en W.
	    ADDWF   B1,0	    ; Sumo A1 + B1 y guardo el resultado en W.
	    MOVWF   A1		    ; Almaceno esta primer suma en A1.
	    BTFSC   STATUS,C	    ; Si el bit de carry está en 1...
	    INCF    A2,1	    ; Sumo 1 a A2 y lo guardo en A2.
	    BTFSC   STATUS,C	    ; Si el bit de carry está en 1...
	    INCF    AUX,1	    ; Incremento en 1 a AUX y lo guardo en AUX.
	    MOVFW   A2		    ; Cargo A2 en W.
	    ADDWF   B2,0	    ; Sumo A2 + B2 y guardo el resultado en W.
	    MOVWF   A2		    ; Almaceno esta segunda suma en A2.
	    BTFSC   AUX,0	    ; Si AUX vale 1 (hubo carry)...
	    RRF	    AUX		    ; Roto AUX a la derecha para poner el 1
				    ; en el bit de carry.

            END