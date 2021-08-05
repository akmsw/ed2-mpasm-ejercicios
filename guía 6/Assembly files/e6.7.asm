;   Ejercicio 6.7: (LA CONSIGNA SE CAMBIÓ PARA COMPLETITUD)
;
;   Conectar a un PIC un teclado matricial 4x4 y un arreglo de 6 displays de 7
;   segmentos de ánodo común. Considere que los segmentos se activan por 0.
;   Almacenar en un buffer circular de 6 posiciones las últimas 6 teclas que se
;   hayan presionado y mostrarlo por los displays (un display por registro). Al
;   comenzar, como los registros estarán en '0', los correspondientes displays
;   estarán apagados hasta que el registro se sobrescriba. A continuación se
;   muestra el reemplazo de valores en el teclado KEYPAD-SMALLCALC ofrecido por
;   Proteus:
;
;   * TECLA '/'	    -> A
;   * TECLA 'X'	    -> B
;   * TECLA '-'	    -> C
;   * TECLA '+'	    -> D
;   * TECLA 'ON/C'  -> E
;   * TECLA '='	    -> F

;-------------------LIBRERIAS---------------------------------------------------

	#INCLUDE    <P16F887.INC>

	    LIST    P = 16F887

;-------------------CONFIGURACION PIC-------------------------------------------

	__CONFIG    _CONFIG1, _FOSC_INTRC_NOCLKOUT & _WDTE_OFF & _PWRTE_OFF & _MCLRE_ON & _CP_OFF & _CPD_OFF & _BOREN_ON & _IESO_ON & _FCMEN_ON & _LVP_ON
	__CONFIG    _CONFIG2, _BOR4V_BOR40V & _WRT_OFF
	
;-------------------DECLARACION DE VARIABLES------------------------------------
	
	  COL_HAB   EQU	    0x20    ; Registros auxiliares para decodificar las
      COL_HAB_AUX   EQU	    0x21    ; filas y columnas.
	   COLUMN   EQU	    0x22
	      ROW   EQU	    0x23
	  MAX_COL   EQU	    0x24    ; Registros con la cantidad de filas y
	  MAX_ROW   EQU	    0x25    ; columnas del teclado.
	     D_ON   EQU	    0x26    ; Display a encender.
	    D_QUA   EQU	    0x27    ; Cantidad total de displays.
	 BUFF_INI   EQU	    0x28    ; Dirección inicial del buffer circular.
	 BUFF_LIM   EQU	    0x29    ; Dirección final del buffer circular + 1.
	   BUFF_W   EQU	    0x2A    ; Dirección del buffer a escribir.
	       V1   EQU	    0x2B    ; Variables para el retardo por software.
	       V2   EQU	    0x2C
	      AUX   EQU	    0x2D    ; Variable auxiliar para escritura.
	
;-------------------INICIO DEL PROGRAMA-----------------------------------------

	    ORG	    0x00
	    GOTO    CONFIG_
	    
	    ORG	    0x04
	    GOTO    RUT_IN
	    
;-------------------CONFIGURACION DE REGISTROS----------------------------------

	    ORG	    0x05
	    
 CONFIG_    MOVLW   0x04	    ; Vamos a trabajar con un teclado 4x4.
	    MOVWF   MAX_COL
	    MOVWF   MAX_ROW
	    CLRF    D_ON	    ; Vamos a trabajar con 6 displays y vamos a
	    MOVLW   0x06	    ; comenzar por el display 0.
	    MOVWF   D_QUA
	    MOVLW   0x37	    ; El buffer tendrá 6 registros.
	    MOVWF   BUFF_LIM
	    CLRF    COLUMN	    ; Limpio registros a usar para evitar
	    CLRF    ROW		    ; basura de ejecuciones anteriores.
	    CLRF    COL_HAB
	    CLRF    COL_HAB_AUX
	    MOVLW   0x30	    ; El buffer circular comenzará en el
	    MOVWF   BUFF_INI	    ; registro 0x30.
	    MOVWF   BUFF_W
	    BANKSEL TRISB	    ; Seteo RB<0:3> como outputs digitales, y
	    MOVLW   0xF0	    ; RB<4:7> como inputs digitales, y PORTC y
	    MOVWF   TRISB	    ; PORTD como puertos de outputs digitales.
	    BANKSEL ANSELH
	    CLRF    ANSELH
	    BANKSEL TRISC
	    CLRF    TRISC
	    BANKSEL TRISD
	    CLRF    TRISD
	    BANKSEL INTCON	    ; Habilito interrupciones por RB<4:7>, y
	    BSF	    INTCON,GIE	    ; habilito las resistencias de pull-up en el
	    BSF	    INTCON,RBIE	    ; nibble inferior de PORTB.
	    BCF	    INTCON,RBIF
	    BANKSEL OPTION_REG
	    BCF	    OPTION_REG,NOT_RBPU
	    BANKSEL WPUB
	    MOVLW   0xF0
	    MOVWF   WPUB
	    BANKSEL IOCB
	    MOVLW   0xF0
	    MOVWF   IOCB
	    BANKSEL PORTC	    ; Vuelvo al banco de PORTC para comenzar.
	    CALL    CLEAR_BUFF	    ; Limpio el buffer para que comience vacío.
	    CLRF    PORTB
	    CLRF    PORTC
	    CLRF    PORTD
	    CLRF    AUX
	    GOTO    INIT
	    
CLEAR_BUFF  MOVFW   BUFF_INI	    ; Seteo a 0xFF todos los bytes del buffer
	    MOVWF   FSR		    ; por estar trabajando con displays de ánodo
CONTINUE    CLRF    INDF	    ; común.
	    COMF    INDF
	    INCF    FSR,F
	    MOVFW   FSR
	    SUBWF   BUFF_LIM,W
	    BTFSC   STATUS,Z
	    RETURN
	    GOTO    CONTINUE
	    
    INIT    MOVFW   D_ON
	    CALL    D_SELECT
	    MOVWF   PORTD
	    MOVFW   D_ON
	    ADDWF   BUFF_INI,W
	    MOVWF   FSR
	    MOVFW   INDF
	    MOVWF   PORTC
	    CALL    TIMER
	    INCF    D_ON,F
	    MOVFW   D_ON
	    SUBWF   D_QUA,W
	    BTFSC   STATUS,Z
	    CLRF    D_ON
	    GOTO    INIT
 
;-------------------RETARDOS----------------------------------------------------
    
   TIMER    MOVLW   .12		    ; Cargo V1 y V2 con valores previamente
	    MOVWF   V2		    ; calculados para que el ciclo dure ~10[ms].
    LINT    MOVLW   .255
	    MOVWF   V1
	    DECFSZ  V1
	    GOTO    $-1
	    DECFSZ  V2
	    GOTO    LINT
	    RETURN
 
;-------------------TABLAS------------------------------------------------------
    
D_SELECT    ADDWF   PCL,F	    ; Tabla para elegir qué display encender.
	    RETLW   B'00000001'
	    RETLW   B'00000010'
	    RETLW   B'00000100'
	    RETLW   B'00001000'
	    RETLW   B'00010000'
	    RETLW   B'00100000'
	    
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
	    
ROWS_TEST   ADDWF   PCL,F
	    RETLW   B'11111110'
	    RETLW   B'11111101'
	    RETLW   B'11111011'
	    RETLW   B'11110111'
	    
;-------------------RUTINA DE INTERRUPCIÓN--------------------------------------
	    
  RUT_IN    BTFSS   INTCON,RBIF	    ; Sólo atiendo interrupciones por RB<4:7>.
	    RETFIE
	    MOVFW   PORTB	    ; Decodifico lo pulsado como en el ejercicio
	    ANDLW   0xF0	    ; 6.3a.
	    MOVWF   COL_HAB
	    MOVWF   COL_HAB_AUX
	    SWAPF   COL_HAB,F
    TEST    RRF	    COL_HAB,F
	    BTFSS   STATUS,C
	    GOTO    ROW_DEC
	    INCF    COLUMN,F
	    MOVFW   COLUMN
	    SUBWF   MAX_COL,W
	    BTFSC   STATUS,Z
	    GOTO    FINISH
	    GOTO    TEST
	    
 ROW_DEC    MOVFW   ROW
	    CALL    ROWS_TEST
	    MOVWF   PORTB
	    MOVFW   COL_HAB_AUX
	    SUBWF   PORTB,W
	    ANDLW   0xF0
	    BTFSC   STATUS,Z
	    GOTO    SHOW_RES
	    INCF    ROW
	    MOVFW   ROW
	    SUBWF   MAX_ROW,W
	    BTFSC   STATUS,Z
	    GOTO    FINISH
	    GOTO    ROW_DEC
	    
SHOW_RES    BCF	    STATUS,C
	    RLF	    ROW,F
	    RLF	    ROW,W
	    ADDWF   COLUMN,W
	    CALL    D7S_VALUES
	    CALL    SAVE_
	    GOTO    FINISH
	    
   SAVE_    MOVWF   AUX			; Guardo momentáneamente en AUX lo que
	    MOVFW   BUFF_W		; se decodificó para guardarlo donde
	    MOVWF   FSR			; corresponde.
	    MOVFW   AUX
	    MOVWF   INDF		; Lo que se pulsó se guarda en el buffer
	    INCF    BUFF_W,F		; y se incrementa el registro a escribir
	    MOVFW   BUFF_W		; chequeando no sobrepasar el límite.
	    SUBWF   BUFF_LIM,W
	    BTFSC   STATUS,Z
	    CALL    RESET_BUFF
	    RETURN
	    
RESET_BUFF  MOVFW   BUFF_INI		; Resteo el buffer. La siguiente
	    MOVWF   BUFF_W		; posición a escribir será aquella en la
	    RETURN			; que comienza el buffer.

  FINISH    CLRF    PORTB		; Limpio la flag y reseteo los valores
	    MOVFW   PORTB		; de fila y columna para la próxima
    	    BCF	    INTCON,RBIF		; decodificación (ver COMENTARIOS).
	    CLRF    ROW
	    CLRF    COLUMN
	    RETFIE
	    
;-------------------COMENTARIOS-------------------------------------------------

;   De acuerdo con la documentación y con la prueba y error, para poder limpiar
;   correctamente la flag RBIF se debe primero limpiar PORTB, luego hacer una
;   lectura/escritura sobre el mismo puerto y luego limpiar RBIF. Caso contrario
;   la flag no se limpiará y eso causará errores en la implementación del
;   código.
;   Como comentario, hay dos bugs que no he podido identificar en el código, y
;   que sólo se pueden apreciar en las simulaciones en Proteus:
;
;   1)	Cuando el programa arranca, la primer pulsación en el teclado no se
;	toma, recién a la segunda pulsada se comienza a escribir en el buffer.
;   2)	Cuando se llega a la última posición del buffer (todos los displays han
;	sido escritos), ocurre nuevamente el bug #1: la primera pulsada no se
;	registra, pero la siguiente sí.
;
;   Fuera de esto, el programa funciona correctamente.
 
	    END