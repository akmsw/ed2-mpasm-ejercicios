;   Ejercicio 6.2A: (EJERCICIO PARA PRACTICAR INTERRUPCIONES POR PORTB Y USO DE
;		     DISPLAYS ÁNODO COMÚN ANTES DEL EJERCICIO 6.7)
;
;   Implementar el ejercicio 6.1 pero con interrupciones por RB<4:7> y usando un
;   display de 7 segmentos de ánodo común para mostrar la tecla presionada.

;-------------------LIBRERIAS---------------------------------------------------

	#INCLUDE    <P16F887.INC>

	    LIST    P = 16F887

;-------------------CONFIGURACION PIC-------------------------------------------

	__CONFIG    _CONFIG1, _FOSC_INTRC_NOCLKOUT & _WDTE_OFF & _PWRTE_OFF & _MCLRE_ON & _CP_OFF & _CPD_OFF & _BOREN_ON & _IESO_ON & _FCMEN_ON & _LVP_ON
	__CONFIG    _CONFIG2, _BOR4V_BOR40V & _WRT_OFF

;-------------------DECLARACION DE VARIABLES------------------------------------

	  COL_HAB   EQU	    0x20    ; Registros auxiliares para el polling de
      COL_HAB_AUX   EQU	    0x21    ; filas y columnas.
	   COLUMN   EQU	    0x22
	      ROW   EQU	    0x23
	  MAX_COL   EQU	    0x24    ; Registros con la cantidad de filas y
	  MAX_ROW   EQU	    0x25    ; columnas del teclado.

;-------------------INICIO DEL PROGRAMA-----------------------------------------

	    ORG	    0x00
	    GOTO    CONFIG_

	    ORG	    0x04
	    GOTO    RUT_IN
		    
;-------------------CONFIGURACION DE REGISTROS----------------------------------

	    ORG	    0x05

 CONFIG_    CLRF    COL_HAB	    ; Limpio los registros a utilizar.
	    CLRF    COL_HAB_AUX
	    CLRF    COLUMN
	    CLRF    ROW
	    MOVLW   .4		    ; El teclado es de 4x4.
	    MOVWF   MAX_COL
	    MOVWF   MAX_ROW
	    BANKSEL INTCON	    ; Habilito las interrupciones por RB<4:7> y
	    BSF	    INTCON,GIE	    ; habilito también las resistencias de
	    BSF	    INTCON,RBIE	    ; pull-up en esos pines.
	    BCF	    INTCON,RBIF
	    BANKSEL OPTION_REG
	    BCF	    OPTION_REG,NOT_RBPU
	    BANKSEL WPUB
	    MOVLW   0xF0
	    MOVWF   WPUB
	    BANKSEL TRISB	    ; RB<0:3> >> inputs digitales.
	    MOVLW   0xF0	    ; RB<4:7> >> outputs digitales.
	    MOVWF   TRISB
	    BANKSEL ANSELH
	    CLRF    ANSELH
	    BANKSEL IOCB
	    MOVLW   0xF0
	    MOVWF   IOCB
	    BANKSEL TRISC	    ; Seteo PORTC como output digital.
	    CLRF    TRISC
	    BANKSEL PORTB	    ; Vuelvo al banco de PORTB para comenzar, y
	    CLRF    PORTB	    ; limpio los puertos a utilizar.
	    CLRF    PORTC
	    COMF    PORTC
	    GOTO    INIT
	    
    INIT    GOTO    $		    ; Me quedo esperando una interrupción.
		    
;-------------------TABLAS------------------------------------------------------
		    
ROWS_TEST   ADDWF   PCL,F
	    RETLW   B'11111110'
	    RETLW   B'11111101'
	    RETLW   B'11111011'
	    RETLW   B'11110111'

D7S_VALUES  ADDWF   PCL,F	    ; Retorno el valor a mostrar por el display.
	    RETLW   B'11111000'	    ; (0,0) = 7
	    RETLW   B'10011001'	    ; (1,0) = 4
	    RETLW   B'11111001'	    ; (2,0) = 1
	    RETLW   B'10000110'	    ; (3,0) = E
	    RETLW   B'10000000'	    ; (0,1) = 8
	    RETLW   B'10010010'	    ; (1,1) = 5
	    RETLW   B'10100100'	    ; (2,1) = 2
	    RETLW   B'11000000'	    ; (3,1) = 0
	    RETLW   B'10010000'	    ; (0,2) = 9
	    RETLW   B'10000010'	    ; (1,2) = 6
	    RETLW   B'10110000'	    ; (2,2) = 3
	    RETLW   B'10001110'	    ; (3,2) = F
	    RETLW   B'10001000'	    ; (0,3) = A
	    RETLW   B'10000011'	    ; (1,3) = B
	    RETLW   B'11000110'	    ; (2,3) = C
	    RETLW   B'10100001'	    ; (3,3) = D
		    
;-------------------RUTINA DE INTERRUPCIÓN--------------------------------------
	    
  RUT_IN    BTFSS   INTCON,RBIF	    ; Sólo atiendo interrupciones por RB<4:7>.
	    RETFIE
	    MOVFW   PORTB
	    ANDLW   0xF0
	    MOVWF   COL_HAB
	    MOVWF   COL_HAB_AUX
	    SWAPF   COL_HAB,F
    TEST    RRF	    COL_HAB,F	    ; Roto COL_HAB hacia la derecha hasta que el
	    BTFSS   STATUS,C	    ; 0 llegue al carry. A medida que roto, voy
	    GOTO    ROW_DEC	    ; incrementando una variable que cuenta las
	    INCF    COLUMN,F	    ; columnas (siempre verificando no pasar el
	    MOVFW   COLUMN	    ; límite de columnas del teclado). Cuando el
	    SUBWF   MAX_COL,W	    ; 0 llega al carry significa que encontré la
	    BTFSC   STATUS,Z	    ; columna y voy a buscar la fila.
	    GOTO    FINISH
	    GOTO    TEST
	    
 ROW_DEC    MOVFW   ROW		    ; Envío por PORTB de a uno los valores de la
	    CALL    ROWS_TEST	    ; tabla ROWS_TEST. Chequeo el nibble
	    MOVWF   PORTB	    ; inferior del resultado de la resta entre
	    MOVFW   COL_HAB_AUX	    ; PORTB y COL_HAB_AUX hasta encontrar el
	    SUBWF   PORTB,W	    ; mismo valor de fila (la resta daría 0).
	    ANDLW   0xF0	    ; A medida que mando valores incremento la
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
	    MOVWF   PORTC	    ; COLUMN y busco en la tabla D7S_VALUES el
	    GOTO    FINISH	    ; valor correspondiente a mostrar por PORTD.

  FINISH    CLRF    PORTB	    ; Limpio PORTB y reseteo los valores de
	    CLRF    ROW		    ; fila y columna para la próxima búsqueda.
	    CLRF    COLUMN
	    RETFIE
  
	    END