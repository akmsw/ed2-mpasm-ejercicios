;   Ejercicio 4.7:
;
;   Realizar un programa en lenguaje Assembly que cuente de 0 a 9
;   indefinidamente. Cada número permanecerá encendido un segundo (retardo por
;   software). El conteo iniciará en 0 al apretarse un pulsador en RB0 y se
;   detendrá al volver a pulsarlo en el valor que esté la cuenta. La salida
;   será por PORTD. El oscilador es de 4[MHz].

;-------------------LIBRERIAS---------------------------------------------------

	#INCLUDE    <P16F887.INC>

	    LIST    P = 16F887

;-------------------CONFIGURACION PIC-------------------------------------------

	__CONFIG    _CONFIG1, _FOSC_INTRC_NOCLKOUT & _WDTE_OFF & _PWRTE_OFF & _MCLRE_ON & _CP_OFF & _CPD_OFF & _BOREN_ON & _IESO_ON & _FCMEN_ON & _LVP_ON
	__CONFIG    _CONFIG2, _BOR4V_BOR40V & _WRT_OFF
	
;-------------------DECLARACION DE VARIABLES------------------------------------
	    
	    ORG	    0x00
	    
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
   	    V1	    EQU	    0x30    ; Variables para los loops del retardo de
	    V2	    EQU	    0x31    ; un segundo.
	    V3	    EQU	    0x32

;-------------------CONFIGURACION DE REGISTROS----------------------------------
	    
	    ;	      hgfedcba
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
	    BANKSEL TRISB	    ; Seteo RB0 como input digital.
	    MOVLW   b'00000001'
	    MOVWF   TRISB
	    BANKSEL ANSELH
	    CLRF    ANSELH
	    BANKSEL TRISD	    ; Seteo PORTD como output digital.
	    CLRF    TRISD
	    BANKSEL PORTA	    ; Vuelvo al banco de PORTA para comenzar.
	    CLRF    PORTD	    ; Limpio los registros a utilizar para
	    CLRW		    ; evitar trabajar con basura.

;-------------------INICIO DEL PROGRAMA-----------------------------------------
	    
    POLL    BTFSS   PORTB,0	    ; Chequeo el estado de RB0. Si está
	    GOTO    PRESSED_B0	    ; presionado, voy al antirrebote.
	    GOTO    POLL
	    
PRESSED_B0  BTFSS   PORTB,0
	    GOTO    $-1
	    GOTO    COUNT
	    
   COUNT    GOTO    SET_FSR	    ; Cargo FSR con la primera posición de
    LOOP    MOVFW   INDF	    ; memoria con los valores para mostrar en
	    MOVWF   PORTD	    ; PORTD. Voy mostrando por PORTD esperando
	    CALL    TIMER_1S	    ; un segundo.
	    MOVFW   FSR		    ; Si llegué a la posición 0x29, reseteo el
	    SUBLW   0x29	    ; contador.
	    BTFSC   STATUS,Z
	    GOTO    SET_FSR
	    INCF    FSR
	    BTFSS   PORTB,0	    ; Chequeo el estado de RB0. Si está
	    GOTO    PRESSED_B02	    ; presionado, hago un nuevo polling sin
	    GOTO    LOOP	    ; resetear la cuenta.
	    
PRESSED_B02 BTFSC   PORTB,0	    ; Cuando RB0 cambia de estado, voy a un
	    GOTO    POLL2	    ; polling de pausa que luego me llevará a
	    GOTO    PRESSED_B02	    ; LOOP en vez de a COUNT, para no resetar
				    ; el valor del registro FSR.
	    
   POLL2    BTFSS   PORTB,0	    ; Chequeo el estado de RB0. Si está
	    GOTO    PRESSED_B03	    ; presionado, voy al nuevo antirrebote.
	    GOTO    POLL2
	    
PRESSED_B03 BTFSC   PORTB,0	    ; En este tercer antirrebote voy a LOOP y no
	    GOTO    LOOP	    ; a COUNT para que el contador siga desde
	    GOTO    PRESSED_B03	    ; donde quedó el registro FSR.
	    
TIMER_1S    MOVLW   .6		    ; Cargo V1, V2 y V3 con valores previamente
	    MOVWF   V3		    ; calculados para que el ciclo dure 1[s].
    LMED    MOVLW   .217
	    MOVWF   V2
    LINT    MOVLW   .255
	    MOVWF   V1
	    DECFSZ  V1		    ; Decremento V1. Si aún no es cero...
	    GOTO    $-1		    ; sigo decrementando V1.
	    DECFSZ  V2		    ; Si V1 es cero, decremento V2.
	    GOTO    LINT	    ; Si V2 aún no es cero, recargo V1 y repito.
	    DECFSZ  V3		    ; Si V2 es cero, decremento V3.
	    GOTO    LMED	    ; Si V3 aún no es cero, recargo V2 y repito.
	    RETURN		    ; Si V3 es cero, vuelvo.
	    
 SET_FSR    MOVLW   0x20
	    MOVWF   FSR
	    GOTO    LOOP
	    
;-------------------COMENTARIOS-------------------------------------------------
;
;	Una vez más, este ejercicio tiene complicaciones por no trabajar con
;	interrupciones. Si bien la pulsación que comienza el conteo funciona
;	correctamente, la pulsación que lo detiene tiene la misma particularidad
;	que los ejercicios 4.6 y 4.5: hay que mantener presionado el botón hasta
;	que el PIC registre el cambio de estado por polling y luego se lo puede
;	soltar para continuar con la ejecución del programa.
	    
	    END