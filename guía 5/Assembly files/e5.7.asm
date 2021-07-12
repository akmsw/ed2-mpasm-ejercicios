;   Ejercicio 5.7:
;
;   Usando interrupciones por RB0, muestre mediante un display de 7 segmentos el
;   número de veces que sucedió un flanco descendiente. Considerar resistencias
;   de pull-up internas habilitadas para PORTB. Mostrar el resultado por PORTD.

;-------------------LIBRERIAS---------------------------------------------------

	#INCLUDE    <P16F887.INC>

	    LIST    P = 16F887

;-------------------CONFIGURACION PIC-------------------------------------------

	__CONFIG    _CONFIG1, _FOSC_INTRC_NOCLKOUT & _WDTE_OFF & _PWRTE_OFF & _MCLRE_ON & _CP_OFF & _CPD_OFF & _BOREN_ON & _IESO_ON & _FCMEN_ON & _LVP_ON
	__CONFIG    _CONFIG2, _BOR4V_BOR40V & _WRT_OFF
	
;-------------------DECLARACION DE VARIABLES------------------------------------
	    
	    D7S_0   EQU	    0x20    ; Registros que almacenarán los valores
	    D7S_1   EQU	    0x21    ; binarios para encender los LEDs de un
	    D7S_2   EQU	    0x22    ; display de 7 segmentos contando desde
	    D7S_3   EQU	    0x23    ; 0 hasta 9.
	    D7S_4   EQU	    0x24
	    D7S_5   EQU	    0x25
	    D7S_6   EQU	    0x26
	    D7S_7   EQU	    0x27
	    D7S_8   EQU	    0x28
	    D7S_9   EQU	    0x29
	
;-------------------INICIALIZACIÓN----------------------------------------------
	    
	    ORG	    0x00
	    
	    GOTO    CONFIG_	    ; Comienzo configurando todo.
	    
	    ORG	    0x04
	    
	    GOTO    RUT_INT	    ; Cuando ocurre una interrupción, voy a la
				    ; rutina de la misma.

;-------------------CONFIGURACION DE REGISTROS----------------------------------
	    
            ORG	    0x05
	    
 CONFIG_    ;	      hgfedcba	      Cargo los valores para encender los LEDs.
	    MOVLW   b'00111111'	    ; 0
	    MOVWF   D7S_0
	    MOVLW   b'00000110'	    ; 1
	    MOVWF   D7S_1
	    MOVLW   b'01011011'	    ; 2
	    MOVWF   D7S_2
	    MOVLW   b'01001111'	    ; 3
	    MOVWF   D7S_3
	    MOVLW   b'01100110'	    ; 4
	    MOVWF   D7S_4
	    MOVLW   b'01101101'	    ; 5
	    MOVWF   D7S_5
	    MOVLW   b'01111101'	    ; 6
	    MOVWF   D7S_6
	    MOVLW   b'00000111'	    ; 7
	    MOVWF   D7S_7
	    MOVLW   b'01111111'	    ; 8
	    MOVWF   D7S_8
	    MOVLW   b'01101111'	    ; 9
	    MOVWF   D7S_9
	    BANKSEL INTCON	    ; Habilito interrupciones por RB0.
	    MOVLW   b'10010000'
	    MOVWF   INTCON
	    BANKSEL IOCB	    ; Habilito RB0 como fuente de interrupción.
	    CLRF    IOCB
	    BSF	    IOCB,0
	    BANKSEL OPTION_REG	    ; Habilito las resistencias de pull-up de
	    CLRF    OPTION_REG	    ; PORTB y las interrupciones por flanco de
	    BANKSEL TRISB	    ; bajada. Seteo RB0 como input.
	    CLRF    TRISB
	    BSF	    TRISB,0
	    BANKSEL ANSELH	    ; Seteo PORTB como digital.
	    CLRF    ANSELH
	    BANKSEL TRISD	    ; Seteo PORTD como output digital.
	    CLRF    TRISD
	    BANKSEL PORTB	    ; Vuelvo al banco de PORTB para comenzar.
	    MOVLW   0x20	    ; Cargo el FSR con la primera dirección de
	    MOVWF   FSR		    ; memoria con los valores para los LEDs.
	    GOTO    START

;-------------------INICIO DEL PROGRAMA-----------------------------------------
	    
    START   MOVFW   INDF	    ; Cargo PORTD con 0 (valor inicial).
	    MOVWF   PORTD
	    GOTO    $		    ; No hago nada. Espero una interrupción.
	    
;-------------------RUTINA DE INTERRUPCIÓN--------------------------------------
	    
 RUT_INT    BTFSC   INTCON,INTF	    ; Si fue interrupción por RB0...
	    CALL    COUNT	    ; Voy a COUNT.
	    GOTO    FINISH	    ; Sino, vuelvo.
	    
   COUNT    INCF    FSR
	    MOVFW   INDF
	    MOVWF   PORTD
	    MOVFW   FSR
	    SUBLW   0x29
	    BTFSC   STATUS,Z
	    CALL    RESET_FSR
	    RETURN
	    
RESET_FSR   MOVLW   0x1F
	    MOVWF   FSR
	    RETURN
	    
  FINISH    BCF	    INTCON,INTF
	    RETFIE
	    
	    END