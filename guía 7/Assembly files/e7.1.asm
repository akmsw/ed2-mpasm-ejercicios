;   Ejercicio 7.1:
;
;   Realizar un programa que obtenga el valor de la tecla pulsada en un teclado
;   matricial 4x4 y lo almacene en código BCD empaquetado. Debe colocarla en un
;   buffer circular de 32 registros desde la posición 20H. La resolución de cuól
;   es la tecla apretada y su almacenamiento se resuelve óntegramente dentro de
;   la rutina de interrupción. Mostrar la óltima tecla pulsada en un display de
;   7 segmentos de ánodo común.
    
;-------------------LIBRERIAS---------------------------------------------------

	#INCLUDE    <P16F887.INC>

	    LIST    P = 16F887

;-------------------CONFIGURACION PIC-------------------------------------------

	__CONFIG    _CONFIG1, _FOSC_INTRC_NOCLKOUT & _WDTE_OFF & _PWRTE_OFF & _MCLRE_ON & _CP_OFF & _CPD_OFF & _BOREN_ON & _IESO_ON & _FCMEN_ON & _LVP_ON
	__CONFIG    _CONFIG2, _BOR4V_BOR40V & _WRT_OFF
	
;-------------------DECLARACION DE VARIABLES------------------------------------
	
	  COL_HAB   EQU	    0x40    ; Declaro los registros a utilizar desde 40H
      COL_HAB_AUX   EQU	    0x41    ; porque el buffer comienza en 20H y consta
	   COLUMN   EQU	    0x42    ; de 32 registros (20H + 20H = 40H).
	      ROW   EQU	    0x43
	  MAX_COL   EQU	    0x44
	  MAX_ROW   EQU	    0x45
	 BUFF_INI   EQU	    0x46
	 BUFF_LIM   EQU	    0x47
	   BUFF_W   EQU	    0x48
	       V1   EQU	    0x49
	       V2   EQU	    0x4A
	      AUX   EQU	    0x4B
	
;-------------------INICIO DEL PROGRAMA-----------------------------------------

	    ORG	    0x00
	    GOTO    CONFIG_
	    
	    ORG	    0x04
	    GOTO    RUT_IN
	    
;-------------------CONFIGURACION DE REGISTROS----------------------------------

	    ORG	    0x05
	    
 CONFIG_    MOVLW   0x04
	    MOVWF   MAX_COL
	    MOVWF   MAX_ROW
	    MOVLW   0x40
	    MOVWF   BUFF_LIM
	    CLRF    COLUMN
	    CLRF    ROW
	    CLRF    COL_HAB
	    CLRF    COL_HAB_AUX
	    MOVLW   0x20
	    MOVWF   BUFF_INI
	    MOVWF   BUFF_W
	    BANKSEL TRISB
	    MOVLW   0xF0
	    MOVWF   TRISB
	    BANKSEL ANSELH
	    CLRF    ANSELH
	    BANKSEL TRISC
	    CLRF    TRISC
	    BANKSEL INTCON
	    BSF	    INTCON,GIE
	    BSF	    INTCON,RBIE
	    BCF	    INTCON,RBIF
	    BANKSEL OPTION_REG
	    BCF	    OPTION_REG,NOT_RBPU
	    BANKSEL WPUB
	    MOVLW   0xF0
	    MOVWF   WPUB
	    BANKSEL IOCB
	    MOVLW   0xF0
	    MOVWF   IOCB
	    BANKSEL PORTC
	    CALL    CLEAR_BUFF
	    CLRF    PORTB
	    CLRF    PORTC
	    COMF    PORTC
	    CLRF    AUX
	    GOTO    INIT
	    
CLEAR_BUFF  MOVFW   BUFF_INI
	    MOVWF   FSR
CONTINUE    CLRF    INDF
	    COMF    INDF
	    INCF    FSR,F
	    MOVFW   FSR
	    SUBWF   BUFF_LIM,W
	    BTFSC   STATUS,Z
	    RETURN
	    GOTO    CONTINUE
 
    INIT    GOTO    $
 
;-------------------TABLAS------------------------------------------------------
	    
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
	    
;-------------------RUTINA DE INTERRUPCIóN--------------------------------------
	    
  RUT_IN    BTFSS   INTCON,RBIF
	    RETFIE
	    MOVFW   PORTB
	    ANDLW   0xF0
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
	    MOVWF   PORTC
	    CALL    SAVE_
	    GOTO    FINISH
	    
   SAVE_    MOVWF   AUX
	    MOVFW   BUFF_W
	    MOVWF   FSR
	    MOVFW   AUX
	    MOVWF   INDF
	    INCF    BUFF_W,F
	    MOVFW   BUFF_W
	    SUBWF   BUFF_LIM,W
	    BTFSC   STATUS,Z
	    CALL    RESET_BUFF
	    RETURN
	    
RESET_BUFF  MOVFW   BUFF_INI
	    MOVWF   BUFF_W
	    RETURN

  FINISH    CLRF    PORTB
	    MOVFW   PORTB
    	    BCF	    INTCON,RBIF
	    CLRF    ROW
	    CLRF    COLUMN
	    RETFIE
	    
	    END