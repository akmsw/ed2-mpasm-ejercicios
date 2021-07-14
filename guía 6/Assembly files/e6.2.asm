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
	
	  COL_HAB   EQU	    0x20    ; Registros auxiliares para el polling de
      COL_HAB_AUX   EQU	    0x21    ; filas y columnas.
	   COLUMN   EQU	    0x22
	      ROW   EQU	    0x23
	  MAX_REG   EQU	    0x24    ; Registro con la máxima dirección.
	  MAX_COL   EQU	    0x25    ; Registros con la cantidad de filas y
	  MAX_ROW   EQU	    0x26    ; columnas del teclado para limitar la
				    ; decodificación al pulsar una tecla.

;-------------------CONFIGURACION DE REGISTROS----------------------------------

            MOVLW   0x37	    ; Cargo la máxima dirección de memoria a
	    MOVWF   MAX_REG	    ; modificar por el FSR + 1.
            MOVLW   .4		    ; Cargo 4 como al cantidad de filas y de
	    MOVWF   MAX_ROW	    ; columnas del teclado.
	    MOVWF   MAX_COL
	    MOVLW   0x2F	    ; Configuro el valor inicial de FSR.
	    MOVWF   FSR
	    BANKSEL TRISD	    ; Seteo PORTD como output.
	    CLRF    TRISD
	    BANKSEL TRISB	    ; Seteo RB<0:3> como inputs y RB<4:7> como
	    MOVLW   0x0F	    ; outputs.
	    MOVWF   TRISB
	    BANKSEL ANSELH	    ; Seteo PORTB como puerto digital.
	    CLRF    ANSELH
	    BANKSEL OPTION_REG	    ; Habilito resistencias de pull-up en PORTB.
	    CLRF    OPTION_REG
	    BANKSEL WPUB	    ; Seteo las resistencias de pull-up.
	    MOVLW   0x0F
	    MOVWF   WPUB
	    BANKSEL PORTB	    ; Vuelvo al banco de PORTB para comenzar.
	    CLRF    PORTB	    ; Limpio los registros a utilizar para
	    CLRF    PORTD	    ; evitar basura de ejecuciones anteriores.
	    CLRF    COLUMN
	    CLRF    ROW
	    CLRW

;-------------------INICIO DEL PROGRAMA-----------------------------------------

	    CALL    KEY_POLL	    ; Hago polling indefinidamente.
	    GOTO    $-1

KEY_POLL    MOVFW   PORTB	    ; Leo el nibble inferior de PORTB, y hago
	    ANDLW   0x0F	    ; 0x0F - W. Si la resta da 0 significa que
	    MOVWF   COL_HAB	    ; ninguna tecla fue presionada así que en
	    MOVWF   COL_HAB_AUX	    ; ese caso vuelvo a KEY_POLL.
	    SUBLW   0x0F	    ; Si no da cero significa que alguna tecla
	    BTFSC   STATUS,Z	    ; fue presionada y allí comienzo la
	    GOTO    KEY_POLL	    ; decodificación de la fila y columna.
	    GOTO    COL_DEC

 COL_DEC    RRF	    COL_HAB,F	    ; Roto COL_HAB hacia la derecha hasta que el
	    BTFSS   STATUS,C	    ; 0 llegue al carry. A medida que roto, voy
	    GOTO    ROW_DEC	    ; incrementando una variable que cuenta las
	    INCF    COLUMN,F	    ; columnas (siempre verificando no pasar el
	    MOVFW   COLUMN	    ; límite de columnas del teclado). Cuando el
	    SUBWF   MAX_COL,W	    ; 0 llega al carry significa que encontré la
	    BTFSC   STATUS,Z	    ; columna y voy a buscar la fila.
	    GOTO    FINISH
	    GOTO    COL_DEC
	    
 ROW_DEC    MOVFW   ROW		    ; Envío por PORTB de a uno los valores de la
	    CALL    ROWS_TEST	    ; tabla ROWS_TEST. Chequeo el nibble
	    MOVWF   PORTB	    ; inferior del resultado de la resta entre
	    MOVFW   COL_HAB_AUX	    ; PORTB y COL_HAB_AUX hasta encontrar el
	    SUBWF   PORTB,W	    ; mismo valor de fila (la resta daría 0).
	    ANDLW   0x0F	    ; A medida que mando valores incremento la
	    BTFSC   STATUS,Z	    ; variable contadora ROW. Cuando encuentro
	    GOTO    SAVE_RES	    ; el valor de fila, voy a mostrar el
	    INCF    ROW		    ; resultado por PORTD.
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
	    BCF	    STATUS,C	    ; Limpio el bit de carry.
	    RLF	    ROW,F	    ; La posición de la tecla viene dada por la
	    RLF	    ROW,W	    ; ecuación KEY = 4*ROW + COLUMN. Para esto,
	    ADDWF   COLUMN,W	    ; roto dos veces hacia la izquierda a ROW
	    CALL    VALUES	    ; (eso me da 4*ROW) y al resultado le sumo
	    MOVWF   INDF	    ; COLUMN y busco en la tabla VALUES el
            GOTO    FINISH	    ; valor correspondiente a almacenar.
	    
 SET_FSR    MOVLW   0x30	    ; Cargo el FSR con la dirección de memoria
	    MOVWF   FSR		    ; inicial para darle la vuelta al buffer
	    RETURN		    ; circular y sobrescribir los valores.

  FINISH    CLRF    PORTB	    ; Limpio PORTB y reseteo los valores de
	    CLRF    ROW		    ; fila y columna para la próxima búsqueda.
	    CLRF    COLUMN
	    RETURN

;-------------------TABLAS------------------------------------------------------

ROWS_TEST   ADDWF   PCL,F	    ; Sumo al PC el valor de fila y retorno el
	    RETLW   0xEF	    ; número binario a mostrar por PORTB para
	    RETLW   0xDF	    ; testear cada fila (mando un '0' en RB4 con
	    RETLW   0xBF	    ; 0xEF, un '0' por RB5 con 0xDF y así)
	    RETLW   0x7F	    ; mientras el resto de pines queda en '1'.

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

	    END