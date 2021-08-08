;   Ejercicio 7.4 (LA CONSIGNA SE CAMBIÓ PARA SIMPLICIDAD):
;
;   Utilizando PORTA y PORTC para controlar la multiplexación de seis displays
;   de siete segmentos de cátodo común, desarrolle un programa que funcione como
;   cronómetro; teniendo un pulsador conectado a RB1 que oficie de botón de
;   start/stop del cronómetro, y muestre el valor en formato HHMMSS.
    
;-------------------LIBRERIAS---------------------------------------------------

	#INCLUDE    <P16F887.INC>

	    LIST    P = 16F887

;-------------------CONFIGURACION PIC-------------------------------------------

	__CONFIG    _CONFIG1, _FOSC_INTRC_NOCLKOUT & _WDTE_OFF & _PWRTE_OFF & _MCLRE_ON & _CP_OFF & _CPD_OFF & _BOREN_ON & _IESO_ON & _FCMEN_ON & _LVP_ON
	__CONFIG    _CONFIG2, _BOR4V_BOR40V & _WRT_OFF
	
;-------------------DECLARACION DE VARIABLES------------------------------------
	
	      S1    EQU	    0x20	; Registros para los segundos, minutos y
	      S2    EQU	    0x21	; horas con sus respectivos límites.
	      M1    EQU	    0x22
	      M2    EQU	    0x23
	      H1    EQU	    0x24
	      H2    EQU	    0x25
	   LIM_1    EQU	    0x26
	   LIM_2    EQU	    0x27
	  LIM_H1    EQU	    0x28
	  LIM_H2    EQU	    0x29
	    D_ON    EQU	    0x2A	; Display a encender.
	     D_Q    EQU	    0x2B	; Cantidad de displays a usar.
	   T0_OF    EQU	    0x2C	; Overflow para TMR0.
	  SAVE_S    EQU	    0x2D	; Registros para salvar contexto.
	  SAVE_W    EQU	    0x2E
	      V1    EQU	    0x2F	; Registros para retardos.
	      V2    EQU	    0x30
	
;-------------------INICIO DEL PROGRAMA-----------------------------------------

	    ORG	    0x00
	    GOTO    CONFIG_
	    
	    ORG	    0x04
	    GOTO    RUT_IN
	    
;-------------------CONFIGURACION DE REGISTROS----------------------------------

	    ORG	    0x05
	    
 CONFIG_    CLRF    S1			; Comienzo en 000000 y voy a ir hasta
	    CLRF    S2			; 235959.
	    CLRF    M1
	    CLRF    M2
	    CLRF    H1
	    CLRF    H2
	    MOVLW   0x0A
	    MOVWF   LIM_1
	    MOVLW   0x06
	    MOVWF   LIM_2
	    MOVLW   0x04
	    MOVWF   LIM_H1
	    MOVLW   0x03
	    MOVWF   LIM_H2
	    CLRF    D_ON		; Empiezo a multiplexar desde el display
	    MOVLW   0x06		; 0, y voy a trabajar con 6 displays.
	    MOVWF   D_Q
	    MOVLW   0x14		; Voy a contar 20 veces 50[ms].
	    MOVWF   T0_OF
	    BANKSEL TRISB		; RB1 será input digital, y PORTA será
	    BSF	    TRISB,1		; de outputs digitales junto a PORTC.
	    BANKSEL ANSELH
	    CLRF    ANSELH
	    BANKSEL INTCON		; Habilito interrupciones por PORTB.
	    BSF	    INTCON,GIE
	    BCF	    INTCON,T0IE
	    BSF	    INTCON,RBIE
	    BCF	    INTCON,RBIF
	    BANKSEL OPTION_REG		; Desactivo resistencias de pull-up en
	    BSF	    OPTION_REG,NOT_RBPU	; PORTB, y asigno a TMR0 un prescaler de
	    BCF	    OPTION_REG,T0CS	; 1:256.
	    BCF	    OPTION_REG,PSA
	    BSF	    OPTION_REG,PS2
	    BSF	    OPTION_REG,PS1
	    BSF	    OPTION_REG,PS0
	    BANKSEL WPUB
	    CLRF    WPUB
	    BANKSEL IOCB		; Habilito interrupciones por cambio en
	    BSF	    IOCB,1		; RB1.
	    BANKSEL TRISA
	    CLRF    TRISA
	    BANKSEL ANSEL
	    CLRF    ANSEL
	    BANKSEL TRISC
	    CLRF    TRISC
	    BANKSEL PORTA		; Vuelvo al banco de PORTA para empezar.
	    CLRF    PORTA
	    CLRF    PORTC
	    GOTO    MUX
 
     MUX    MOVFW   D_ON		; Multiplexo indefinidamente los seis
	    CALL    D_SELECT		; displays. Sólo a los displays de M1 y
	    MOVWF   PORTC		; de H1 les enciendo el DP para que sea
	    MOVFW   D_ON		; más legible la hora (quedará de la
	    CALL    S_M_OR_H		; forma HH.MM.SS).
	    MOVWF   FSR
	    MOVFW   INDF
	    CALL    D7S_VALUES
	    MOVWF   PORTA
	    MOVFW   D_ON
	    CALL    DP_ON_OFF
	    ADDWF   PORTA,F
	    CALL    T_10MS
	    INCF    D_ON
	    MOVFW   D_ON
	    SUBWF   D_Q,W
	    BTFSC   STATUS,Z
	    CLRF    D_ON
	    GOTO    MUX
 
;-------------------TABLAS------------------------------------------------------
	    
D7S_VALUES  ADDWF   PCL,F	    ; Retorno el valor a mostrar por el display.
	    RETLW   B'00111111'	    ; 0
	    RETLW   B'00000110'	    ; 1
	    RETLW   B'01011011'	    ; 2
	    RETLW   B'01001111'	    ; 3
	    RETLW   B'01100110'	    ; 4
	    RETLW   B'01101101'	    ; 5
	    RETLW   B'01111101'	    ; 6
	    RETLW   B'00000111'	    ; 7
	    RETLW   B'01111111'	    ; 8
	    RETLW   B'01101111'	    ; 9
	    
D_SELECT    ADDWF   PCL,F	    ; Tabla para elegir qué display encender.
	    RETLW   B'11111110'
	    RETLW   B'11111101'
	    RETLW   B'11111011'
	    RETLW   B'11110111'
	    RETLW   B'11101111'
	    RETLW   B'11011111'

S_M_OR_H    ADDWF   PCL,F	    ; Tabla para mover a FSR la dirección de
	    RETLW   0x20	    ; los segundos, minutos u horas según el
	    RETLW   0x21	    ; display a encender.
	    RETLW   0x22
	    RETLW   0x23
	    RETLW   0x24
	    RETLW   0x25
	    
DP_ON_OFF   ADDWF   PCL,F
	    RETLW   B'00000000'
	    RETLW   B'00000000'
	    RETLW   B'10000000'
	    RETLW   B'00000000'
	    RETLW   B'10000000'
	    RETLW   B'00000000'
	    
;-------------------RETARDOS----------------------------------------------------
	    
  T_10MS    MOVLW   .12		    ; Retardo por software de ~10[ms].
	    MOVWF   V2
    LINT    MOVLW   .255
	    MOVWF   V1
	    DECFSZ  V1
	    GOTO    $-1
	    DECFSZ  V2
	    GOTO    LINT
	    RETURN
	    
;-------------------RUTINA DE INTERRUPCIÓN--------------------------------------
	    
  RUT_IN    BTFSS   INTCON,RBIF	    ; Atiendo interrupciones por RB1 y TMR0.
	    GOTO    TEST_T0
	    GOTO    RB_IN
	    
 TEST_T0    BTFSS   INTCON,T0IF
	    RETFIE
	    GOTO    T0_IN
	    
   RB_IN    BTFSS   PORTB,1	    ; Si RB1 sigue en '0' a esta altura, no lo
	    GOTO    FINISH_RB1	    ; tomo como interrupción (antirrebote)
	    CALL    CTX_SAVE
	    BTFSC   INTCON,T0IE
	    GOTO    STOP
	    GOTO    START
	    
   START    BSF	    INTCON,T0IE	    ; Si debo comenzar/continuar, habilito las
	    CALL    LOAD_T0	    ; interrupciones por TMR0, y vuelvo.
	    GOTO    FINISH_RB1
	    
    STOP    BCF	    INTCON,T0IE	    ; Si debo parar, deshabilito las
	    GOTO    FINISH_RB1	    ; interrupciones por TMR0, y vuelvo.
	    
 LOAD_T0    MOVLW   0x3C	    ; Recargo TMR0 para contar 50[ms].
	    MOVWF   TMR0
	    RETURN
	    
   T0_IN    CALL    CTX_SAVE	    ; Si fue interrupción por TMR0, guardo
	    DECFSZ  T0_OF	    ; contexto y testeo si ya pasó 1[s].
	    GOTO    RESET_T0	    ; Si aún no, vuelvo.
	    CALL    RESET_OF	    ; Si sí, reseteo el contador de overflows e
	    INCF    S1		    ; incremento cada número chequeando si debo
	    MOVFW   S1		    ; o no incrementar el siguiente.
	    SUBWF   LIM_1,W
	    BTFSS   STATUS,Z
	    GOTO    RESET_T0
	    CLRF    S1
	    INCF    S2
	    MOVFW   S2
	    SUBWF   LIM_2,W
	    BTFSS   STATUS,Z
	    GOTO    RESET_T0
	    CLRF    S2
	    INCF    M1
	    MOVFW   M1
	    SUBWF   LIM_1,W
	    BTFSS   STATUS,Z
	    GOTO    RESET_T0
	    CLRF    M1
	    INCF    M2
	    MOVFW   M2
	    SUBWF   LIM_2,W
	    BTFSS   STATUS,Z
	    GOTO    RESET_T0
	    CLRF    M2
	    INCF    H1
	    MOVFW   H1
	    SUBWF   LIM_H1,W
	    BTFSS   STATUS,Z
	    GOTO    RESET_T0
	    CLRF    H1
	    INCF    H2
	    MOVFW   H2
	    SUBWF   LIM_H2,W
	    BTFSS   STATUS,Z
	    GOTO    RESET_T0
	    CLRF    H2
	    GOTO    RESET_T0
	    
RESET_OF    MOVLW   0x14
	    MOVWF   T0_OF
	    RETURN
	    
RESET_T0    BCF	    INTCON,T0IF	    ; Limpio la flag y reseteo TMR0.
	    MOVLW   0x3C
	    MOVWF   TMR0
	    GOTO    FINISH_T0
	    
FINISH_RB1  CLRF    PORTB	    ; Limpio la flag RBIF y devuelvo contexto.
	    MOVFW   PORTB
	    BANKSEL INTCON
	    BCF	    INTCON,RBIF
	    BANKSEL PORTA
	    CALL    CTX_LOAD
	    RETFIE
	    
FINISH_T0   BCF	    INTCON,T0IF	    ; Limpio la flag T0IF y devuelvo contexto.
	    CALL    CTX_LOAD
	    RETFIE
	    
CTX_SAVE    MOVWF   SAVE_W	    ; Salvo el estado de W y STATUS para evitar
	    SWAPF   STATUS,W	    ; cargar el PCL con direcciones de memoria
	    MOVWF   SAVE_S	    ; de programa erróneas.
	    RETURN
	    
CTX_LOAD    SWAPF   SAVE_S,W	    ; Cargo contexto para volver.
	    MOVWF   STATUS
	    SWAPF   SAVE_W,F
	    SWAPF   SAVE_W,W
	    RETURN
	    
	    END