;   Ejercicio 3.3:
;
;   Escribir un programa que resuelva la ecuación (A + B) - C con posiciones
;   21H, 22H y 23H.

;-------------------LIBRERIAS---------------------------------------------------

	#INCLUDE    <P16F887.INC>

	    LIST    P = 16F887

;-------------------CONFIGURACION PIC-------------------------------------------

	__CONFIG    _CONFIG1, _FOSC_INTRC_NOCLKOUT & _WDTE_OFF & _PWRTE_OFF & _MCLRE_ON & _CP_OFF & _CPD_OFF & _BOREN_ON & _IESO_ON & _FCMEN_ON & _LVP_ON
	__CONFIG    _CONFIG2, _BOR4V_BOR40V & _WRT_OFF

;-------------------DECLARACION DE VARIABLES------------------------------------
	    
	    ORG	    0x00

	    VARA    EQU	    0x21    ; Estos registros van a conformar la
	    VARB    EQU	    0x22    ; ecuación.
	    VARC    EQU	    0x23
	    RESS    EQU	    0x24    ; Registro que alcamenará el resultado de
				    ; la suma.
            REST    EQU	    0x25    ; Registro que almacenará el resultado
				    ; total.

;-------------------CONFIGURACION DE REGISTROS----------------------------------
	    
	    MOVLW   .6		    ; Cargo valores aleatorios en cada variable.
	    MOVWF   VARA
	    MOVLW   .4
	    MOVWF   VARB
	    MOVLW   .2
	    MOVWF   VARC
	    CLRF    RESS	    ; Limpio los registros de resultados
	    CLRF    REST	    ; para evitar tener basura.
	    CLRW		    ; Limpio el registro W con el mismo fin.

;-------------------INICIO DEL PROGRAMA-----------------------------------------

	    MOVFW   VARA	    ; Cargo VARA en W.
	    ADDWF   VARB,0	    ; Sumo W con VARB y almaceno el resultado
				    ; en W (W ahora tiene A + B).
            MOVWF   RESS	    ; Almaceno la suma en RESS.
            MOVFW   VARC	    ; Cargo VARC en W.
	    SUBWF   RESS,0	    ; Hago RESS - W = RESS - VARC = (A + B) - C
				    ; y almaceno el resultado en W.
            MOVWF   REST	    ; Guardo el resultado final en REST.

            END