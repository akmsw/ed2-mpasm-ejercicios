;   Ejercicio 7.3 (LA CONSIGNA SE CAMBIÓ PARA SIMPLICIDAD A LA HORA DE TESTEAR):
;
;   Utilizando PORTA y PORTC para controlar la multiplexación de dos displays
;   de siete segmentos de cátodo común, desarrolle un programa que cuente desde
;   '00' hasta '99'. El contador avanza una cuenta cada un segundo y al llegar a
;   '99' se resetea, volviendo a contar desde '00' indefinidamente.
    
;-------------------LIBRERÍAS---------------------------------------------------

	#INCLUDE    <P16F887.INC>

	    LIST    P = 16F887

;-------------------CONFIGURACIÓN PIC-------------------------------------------

	__CONFIG    _CONFIG1, _FOSC_INTRC_NOCLKOUT & _WDTE_OFF & _PWRTE_OFF & _MCLRE_ON & _CP_OFF & _CPD_OFF & _BOREN_ON & _IESO_ON & _FCMEN_ON & _LVP_ON
	__CONFIG    _CONFIG2, _BOR4V_BOR40V & _WRT_OFF
	
;-------------------DECLARACIÓN DE VARIABLES------------------------------------
	
	    UNI_    EQU	    0x20    ; Unidades y decenas, con sus respectivos
	    DEC_    EQU	    0x21    ; límites para hacer el ejercicio más
	 LIM_UNI    EQU	    0x22    ; genérico.
	 LIM_DEC    EQU	    0x23
	    D_ON    EQU	    0x24    ; Display a encender.
	     D_Q    EQU	    0x25    ; Cantidad de displays utilizados.
	   T0_OF    EQU	    0x26    ; Overflow para el TMR0 para contar 1[s].
	      V1    EQU	    0x27    ; Variables para el retardo de multiplexado.
	      V2    EQU	    0x28
	  SAVE_S    EQU	    0x29    ; Registros para salvar contexto.
	  SAVE_W    EQU	    0x2A
	
;-------------------INICIO DEL PROGARMA-----------------------------------------

	    ORG	    0x00
	    GOTO    CONFIG_
	    
	    ORG	    0x04
	    GOTO    RUT_IN
	    
;-------------------CONFIGURACIÓN DE REGISTROS----------------------------------

	    ORG	    0x05
	    
 CONFIG_    CLRF    UNI_	    ; Comienzo en 00 y voy hasta 99.
	    CLRF    DEC_
	    MOVLW   0x0A
	    MOVWF   LIM_UNI
	    MOVWF   LIM_DEC
	    CLRF    D_ON	    ; Comienzo con el display 0, y voy a
	    MOVLW   0x02	    ; trabajar con dos displays en total.
	    MOVWF   D_Q
	    MOVLW   .20	    	    ; Voy a contar 20 veces 50[ms].
	    MOVWF   T0_OF
	    BANKSEL TRISA	    ; PORTA y PORTC serán outputs digitales.
	    CLRF    TRISA
	    BANKSEL ANSEL
	    CLRF    ANSEL
	    BANKSEL TRISC
	    CLRF    TRISC
	    BANKSEL OPTION_REG	    ; Configuro TMR0 con un prescaler de 1:256
	    BCF	    OPTION_REG,T0CS ; usando el clock interno.
	    BCF	    OPTION_REG,PSA
	    BSF	    OPTION_REG,PS2
	    BSF	    OPTION_REG,PS1
	    BSF	    OPTION_REG,PS0
	    BANKSEL INTCON	    ; Habilito interrupciones por TMR0.
	    BSF	    INTCON,GIE
	    BSF	    INTCON,T0IE
	    BCF	    INTCON,T0IF
	    BANKSEL TMR0	    ; Pongo a TMR0 a contar.
	    MOVLW   .60
	    MOVWF   TMR0
	    BANKSEL PORTA	    ; Vuelvo al banco de PORTA para comenzar.
	    GOTO    MUX
 
     MUX    MOVFW   D_ON
	    CALL    D_SELECT
	    MOVWF   PORTC
	    MOVFW   D_ON
	    CALL    D_OR_U
	    MOVWF   FSR
	    MOVFW   INDF
	    CALL    D7S_VALUES
	    MOVWF   PORTA
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

  D_OR_U    ADDWF   PCL,F	    ; Tabla para mover a FSR la dirección de
	    RETLW   0x20	    ; las unidades o decenas según el display a
	    RETLW   0x21	    ; encender.
	    
;-------------------RETARDOS----------------------------------------------------
	    
  T_10MS    MOVLW   .13		    ; Retardo por software de ~10[ms].
	    MOVWF   V2
    LINT    MOVLW   .255
	    MOVWF   V1
	    DECFSZ  V1
	    GOTO    $-1
	    DECFSZ  V2
	    GOTO    LINT
	    RETURN
	    
;-------------------RUTINA DE INTERRUPCIÓN--------------------------------------
	    
  RUT_IN    CALL    CTX_SAVE	    ; Salvo contexto para evitar problemas.
	    BTFSS   INTCON,T0IF	    ; Sólo atiendo interrupciones por TMR0.
	    GOTO    FINISH
	    DECFSZ  T0_OF	    ; Cada 1[s] actualizo el valor de UNI_, y
	    GOTO    RESET_TMR0	    ; cada 10[s] actualizo el valor de DEC_,
	    CALL    RESET_OF	    ; siempre chequeando no pasar el límite.
	    INCF    UNI_,F
	    MOVFW   UNI_
	    SUBWF   LIM_UNI,W
	    BTFSC   STATUS,Z
	    CALL    RESET_UNI
	    GOTO    FINISH
	    
CTX_SAVE    MOVWF   SAVE_W	    ; Salvo el estado de W y STATUS para evitar
	    SWAPF   STATUS,W	    ; cargar el PCL con direcciones de memoria
	    MOVWF   SAVE_S	    ; de programa erróneas.
	    RETURN
	    
RESET_TMR0  MOVLW   .60
	    MOVWF   TMR0
	    GOTO    FINISH
	    
RESET_OF    MOVLW   .20
	    MOVWF   T0_OF
	    RETURN
	    
RESET_UNI   CLRF    UNI_
	    INCF    DEC_,F
	    MOVFW   DEC_
	    SUBWF   LIM_DEC,W
	    BTFSC   STATUS,Z
	    CLRF    DEC_
	    RETURN
	    
  FINISH    SWAPF   SAVE_S,W	    ; Cargo contexto para volver y bajo la flag.
	    MOVWF   STATUS
	    SWAPF   SAVE_W,F
	    SWAPF   SAVE_W,W
	    BCF	    INTCON,T0IF
	    RETFIE
	    
	    END