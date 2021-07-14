;   Ejercicio 6.2: (LA CONSIGNA SE CAMBIÓ PARA SIMPLICIDAD)
;
;   Con la configuración del ejercicio 6.1, considere ahora que el micro tiene
;   un buffer circular de 6 teclas a partir de la dirección 30H.
;   Se pide que el buffer sea llenado cno un byte por tecla que tenga el nibble
;   superior igual a 0 y que el nibble inferior sea igual al número que
;   representa la tecla.
;   Por ejemplo, si se presiona primero la tecla (0,3), en 30H guardo 0x03.
;   Si luego presiono la tecla (2,3), en 31H guardo 0x0B (es la onceava tecla).
;   Una vez que llene de 30H a 36H, el valor de la próxima tecla se almacenará
;   en 30H sobrescribiendo el valor que este registro tenía anteriormente.

;-------------------LIBRERIAS---------------------------------------------------

	#INCLUDE    <P16F887.INC>

	    LIST    P = 16F887

;-------------------CONFIGURACION PIC-------------------------------------------

	__CONFIG    _CONFIG1, _FOSC_INTRC_NOCLKOUT & _WDTE_OFF & _PWRTE_OFF & _MCLRE_ON & _CP_OFF & _CPD_OFF & _BOREN_ON & _IESO_ON & _FCMEN_ON & _LVP_ON
	__CONFIG    _CONFIG2, _BOR4V_BOR40V & _WRT_OFF

;-------------------DECLARACION DE VARIABLES------------------------------------

		    ORG	    0x00

	  COL_HAB   EQU	    0x20
      COL_HAB_AUX   EQU	    0x21
	   COLUMN   EQU	    0x22
	      ROW   EQU	    0x23
	  MAX_REG   EQU	    0x24    ; Registro con la máxima dirección.
	  MAX_COL   EQU	    0x25
	  MAX_ROW   EQU	    0x26

;-------------------CONFIGURACION DE REGISTROS----------------------------------

            MOVLW   0x37	    ; Cargo la máxima dirección de memoria a
	    MOVWF   MAX_REG	    ; modificar por el FSR + 1.
            MOVLW   .4
	    MOVWF   MAX_ROW
	    MOVWF   MAX_COL
	    MOVLW   0x2F	    ; Configuro el valor inicial de FSR.
	    MOVWF   FSR
	    BANKSEL TRISD
	    CLRF    TRISD
	    BANKSEL TRISB
	    MOVLW   0x0F
	    MOVWF   TRISB
	    BANKSEL ANSELH
	    CLRF    ANSELH
	    BANKSEL OPTION_REG
	    CLRF    OPTION_REG
	    BANKSEL WPUB
	    MOVLW   0x0F
	    MOVWF   WPUB
	    BANKSEL PORTB
	    CLRF    PORTB
	    CLRF    PORTD
	    CLRF    COLUMN
	    CLRF    ROW
	    CLRW

;-------------------INICIO DEL PROGRAMA-----------------------------------------

	    CALL    KEY_POLL	    ; Hago polling indefinidamente.
	    GOTO    $-1

KEY_POLL    MOVFW   PORTB
	    ANDLW   0x0F
	    MOVWF   COL_HAB
	    MOVWF   COL_HAB_AUX
	    SUBLW   0x0F
	    BTFSC   STATUS,Z
	    GOTO    KEY_POLL
	    GOTO    COL_DEC

 COL_DEC    RRF	    COL_HAB,F
	    BTFSS   STATUS,C
	    GOTO    ROW_DEC
	    INCF    COLUMN,F
	    MOVFW   COLUMN
	    SUBWF   MAX_COL,W
	    BTFSC   STATUS,Z
	    GOTO    FINISH
	    GOTO    COL_DEC
	    
 ROW_DEC    MOVFW   ROW
	    CALL    ROWS_TEST
	    MOVWF   PORTB
	    MOVFW   COL_HAB_AUX
	    SUBWF   PORTB,W
	    ANDLW   0x0F
	    BTFSC   STATUS,Z
	    GOTO    SAVE_RES
	    INCF    ROW
	    MOVFW   ROW
	    SUBWF   MAX_ROW,W
	    BTFSC   STATUS,Z
	    GOTO    FINISH
	    GOTO    ROW_DEC
	    
SAVE_RES    INCF    FSR		    ; Incremento FSR testeando si tengo que
	    MOVFW   FSR		    ; resetearlo por haber llegado al límite.
	    SUBWF   MAX_REG,W
	    BTFSC   STATUS,Z
	    CALL    SET_FSR
	    BCF	    STATUS,C
	    RLF	    ROW,F
	    RLF	    ROW,W
	    ADDWF   COLUMN,W
	    CALL    VALUES
	    MOVWF   INDF
            GOTO    FINISH
	    
 SET_FSR    MOVLW   0x30	    ; Cargo el FSR con la dirección de memoria
	    MOVWF   FSR		    ; inicial para darle la vuelta al buffer
	    RETURN		    ; circular y sobrescribir los valores.

  FINISH    CLRF    PORTB
	    CLRF    ROW
	    CLRF    COLUMN
	    RETURN

;-------------------TABLAS------------------------------------------------------

ROWS_TEST   ADDWF   PCL,F
	    RETLW   0xEF
	    RETLW   0xDF
	    RETLW   0xBF
	    RETLW   0x7F

    VALUES  ADDWF   PCL,F	    ; Retorno el valor a almacenar.
	    RETLW   0x00
	    RETLW   0x01
	    RETLW   0x02
	    RETLW   0x03
	    RETLW   0x04
	    RETLW   0x05
	    RETLW   0x06
	    RETLW   0x07
	    RETLW   0x08
	    RETLW   0x09
	    RETLW   0x0A
	    RETLW   0x0B
	    RETLW   0x0C
	    RETLW   0x0D
	    RETLW   0x0E
	    RETLW   0x0F
	    
;-------------------COMENTARIOS-------------------------------------------------
;	    
;	Para entender el funcionamiento del teclado, revisar el ejercicio 6.1
;	donde se explica completamente.
	    
	    END
