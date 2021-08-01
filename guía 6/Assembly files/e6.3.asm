;   Ejercicio 6.3: (LA CONSIGNA SE CAMBIÓ PARA SIMPLICIDAD)
;
;   Utilizando técnicas de multiplexado de display e interrupciones por TMR0, 
;   desarrolle un programa en Assembly que muestre '000005' al iniciarse el
;   programa. El número 5 se desplazará hacia la izquierda una posición cada 3
;   segundos. Al llegar a '500000' se repetirá la rutina indefinidamente.
;   Considerar un cristal de 4[MHz].

;-------------------LIBRERIAS---------------------------------------------------

	#INCLUDE    <P16F887.INC>

	    LIST    P = 16F887

;-------------------CONFIGURACION PIC-------------------------------------------

	__CONFIG    _CONFIG1, _FOSC_INTRC_NOCLKOUT & _WDTE_OFF & _PWRTE_OFF & _MCLRE_ON & _CP_OFF & _CPD_OFF & _BOREN_ON & _IESO_ON & _FCMEN_ON & _LVP_ON
	__CONFIG    _CONFIG2, _BOR4V_BOR40V & _WRT_OFF

;-------------------DECLARACION DE VARIABLES------------------------------------

	    D_ON    EQU	    0x20    ; Display a encender.
	   D_QUA    EQU	    0x21    ; Cantidad total de displays.
	      V1    EQU	    0x22    ; Variables para el retardo por software.
	      V2    EQU	    0x23
	      V3    EQU	    0x24
	 WHERE_5    EQU	    0x25    ; Dónde debe estar el 5.
	   T0_OF    EQU	    0x26    ; Cantidad de veces que TMR0 debe hacer
				    ; overflow para llegar a los tiempos que
				    ; necesitamos.

;-------------------INICIO DEL PROGRAMA-----------------------------------------

	    ORG	    0x00
	    
	    GOTO    CONFIG_
	    
	    ORG	    0X04
	    
	    GOTO    RUT_IN
	    
;-------------------CONFIGURACION DE REGISTROS----------------------------------

	    ORG	    0x05
	    
 CONFIG_    MOVLW   .6		    ; Vamos a trabajar con 6 displays
	    MOVWF   D_QUA
	    CLRF    D_ON	    ; Empiezo por el display 0.
	    CLRF    WHERE_5	    ; El 5 comienza en el display 0.
	    BANKSEL TRISC	    ; Seteo PORTC y PORTD como outputs.
	    CLRF    TRISC
	    BANKSEL TRISD
	    CLRF    TRISD
	    BANKSEL INTCON	    ; Habilito las interrupciones por TMR0.
	    BSF	    INTCON,GIE
	    BSF	    INTCON,T0IE
	    BCF	    INTCON,T0IF
	    BANKSEL OPTION_REG	    ; Trabajo con clock interno y asigno el
	    BCF	    OPTION_REG,T0CS ; prescaler 1:256 a TMR0.
	    BCF	    OPTION_REG,PSA
	    BSF	    OPTION_REG,PS0
	    BSF	    OPTION_REG,PS1
	    BSF	    OPTION_REG,PS2
	    BANKSEL TMR0	    ; Cuento 60 veces 50[ms] con TMR0 para
	    MOVLW   .60		    ; llegar a los 3[s] necesarios.
	    MOVWF   T0_OF
	    MOVWF   TMR0
	    GOTO    INIT
	    
    INIT    MOVFW   D_ON	    ; Selecciono el display a encender.
	    CALL    D_SELECT
	    MOVWF   PORTD
	    CALL    F_OR_Z	    ; Muestro un 5 o un 0 según corresponda.
	    CALL    VALUES
	    MOVWF   PORTC
	    CALL    TIMER	    ; Lo muestro por 20[ms] y paso al siguiente
	    INCF    D_ON,F	    ; display, chequeando no sobrepasar la
	    MOVFW   D_ON	    ; cantidad de displays del arreglo.
	    SUBWF   D_QUA,W
	    BTFSC   STATUS,Z
	    CLRF    D_ON
	    GOTO    INIT
	    
  F_OR_Z    MOVFW   D_ON	    ; Si el 5 debe estar en el display a
	    SUBWF   WHERE_5,W	    ; encender, vuelvo con un 1 en W; sino,
	    BTFSC   STATUS,Z	    ; vuelvo con un 0.
	    RETLW   .1
	    RETLW   .0
    
;-------------------RETARDOS----------------------------------------------------

   TIMER    MOVLW   .12		    ; Cargo V1 y V2 y V3 con valores previamente
	    MOVWF   V2		    ; calculados para que el ciclo dure ~10[ms].
    LINT    MOVLW   .255
	    MOVWF   V1
	    DECFSZ  V1		    ; Decremento V1.
	    GOTO    $-1		    ; Si V1 aún no es cero, sigo decrementando.
	    DECFSZ  V2		    ; Si V1 es cero, decremento V2.
	    GOTO    LINT	    ; Si V2 aún no es cero, recargo V1 y repito.
	    RETURN		    ; Si V2 es cero, vuelvo.

;-------------------TABLAS------------------------------------------------------
	    
  VALUES    ADDWF   PCL,F	    ; Tabla para elegir qué mostrar.
	    RETLW   b'00111111'	    ; 0
	    RETLW   b'01101101'	    ; 5
	    
D_SELECT    ADDWF   PCL,F	    ; Tabla para elegir qué display encender.
	    RETLW   b'11111110'
	    RETLW   b'11111101'
	    RETLW   b'11111011'
	    RETLW   b'11110111'
	    RETLW   b'11101111'
	    RETLW   b'11011111'
	    RETLW   b'10111111'
	    RETLW   b'01111111'
	    
;-------------------RUTINA DE INTERRUPCIÓN--------------------------------------
	    
  RUT_IN    BTFSS   INTCON,T0IF ; Si no fue interrupción por TMR0, vuelvo.
	    RETFIE
	    BCF	    INTCON,T0IF
	    DECFSZ  T0_OF	    ; Si no pasaron 3[s], recargo TMR0 y vuelvo.
	    GOTO    LOAD_T0	    ; Si pasaron 3[s], corro de lugar el 5 Y
	    MOVLW   .60		    ; reseteo el valor del overflow, siempre
	    MOVWF   T0_OF	    ; chequeando no sobrepasar la cantidad de
	    INCF    WHERE_5,F	    ; displays del arreglo.
	    MOVFW   WHERE_5
	    SUBWF   D_QUA,W
	    BTFSC   STATUS,Z
	    CLRF    WHERE_5
	    RETFIE
	    
 LOAD_T0    MOVLW   .60
	    MOVWF   TMR0
	    RETFIE
	    
	    END
