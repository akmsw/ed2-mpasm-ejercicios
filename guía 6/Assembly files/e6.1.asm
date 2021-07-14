;   Ejercicio 6.1: (LA CONSIGNA SE CAMBIÓ PARA SIMPLICIDAD)
;
;   Realizar un programa que obtenga el valor de la tecla que se pulsa en un
;   teclado estándar de 4x4 conectado al puerto B de un microcontrolador
;   PIC16F887. El valor de la tecla se mostrará en un display 7 segmentos de
;   cátodo común conectado a PORTD. A continuación se muestra el reemplazo de
;   valores en el teclado KEYPAD-SMALLCALC ofrecido por Proteus:
;
;   * TECLA '/' -> A
;   * TECLA 'X' -> B
;   * TECLA '-' -> C
;   * TECLA '+' -> D
;   * TECLA 'ON/C' -> E
;   * TECLA '=' -> F
;
;   Se pide resolución utilizando el método polling.

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
	  MAX_COL   EQU	    0x24    ; Registros con la cantidad de filas y
	  MAX_ROW   EQU	    0x25    ; columnas del teclado para limitar la
				    ; decodificación al pulsar una tecla.

;-------------------CONFIGURACION DE REGISTROS----------------------------------

            MOVLW   .4		    ; Cargo 4 como al cantidad de filas y de
	    MOVWF   MAX_ROW	    ; columnas del teclado.
	    MOVWF   MAX_COL
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
	    GOTO    SHOW_RES	    ; el valor de fila, voy a mostrar el
	    INCF    ROW		    ; resultado por PORTD.
	    MOVFW   ROW
	    SUBWF   MAX_ROW,W
	    BTFSC   STATUS,Z
	    GOTO    FINISH
	    GOTO    ROW_DEC
	    
SHOW_RES    BCF	    STATUS,C	    ; Limpio el bit de carry.
	    RLF	    ROW,F	    ; La posición de la tecla viene dada por la
	    RLF	    ROW,W	    ; ecuación KEY = 4*ROW + COLUMN. Para esto,
	    ADDWF   COLUMN,W	    ; roto dos veces hacia la izquierda a ROW
	    CALL    D7S_VALUES	    ; (eso me da 4*ROW) y al resultado le sumo
	    MOVWF   PORTD	    ; COLUMN y busco en la tabla D7S_VALUES el
	    GOTO    FINISH	    ; valor correspondiente a mostrar por PORTD.

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

D7S_VALUES  ADDWF   PCL,F	    ; Retorno el valor a mostrar por el display.
	    RETLW   b'00000111'	    ; (0,0) = 7
	    RETLW   b'01111111'	    ; (0,1) = 8
	    RETLW   b'01101111'	    ; (0,2) = 9
	    RETLW   b'01110111'	    ; (0,3) = A
	    RETLW   b'01100110'	    ; (1,0) = 4
	    RETLW   b'01101101'	    ; (1,1) = 5
	    RETLW   b'01111101'	    ; (1,2) = 6
	    RETLW   b'01111100'	    ; (1,3) = B
	    RETLW   b'00000110'	    ; (2,0) = 1
	    RETLW   b'01011011'	    ; (2,1) = 2
	    RETLW   b'01001111'	    ; (2,2) = 3
	    RETLW   b'00111001'	    ; (2,3) = C
	    RETLW   b'01111001'	    ; (3,0) = E
	    RETLW   b'00111111'	    ; (3,1) = 0
	    RETLW   b'01110001'	    ; (3,2) = F
	    RETLW   b'01011110'	    ; (3,3) = D

	    END