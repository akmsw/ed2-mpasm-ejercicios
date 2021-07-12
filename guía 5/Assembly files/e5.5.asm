;   Ejercicio 5.5:
;
;   Se desea que al apretar el pulsador conectado a RA4 parpadeen, a una
;   frecuencia de 0.5[Hz], los 8 LEDs conectados en cátodo comñun a los 8
;   terminales del puerto D de un microcontrolador PIC16F887. Dicho parpadeo
;   se debe interurmpir durante unos instantes (3 segundos) si se aprieta el
;   pulsador conectado al terminal RB0. Inicialmente, los LEDs están apagados.
;   El oscilador es de 4[MHz].

;-------------------LIBRERIAS---------------------------------------------------

	#INCLUDE    <P16F887.INC>

	    LIST    P = 16F887

;-------------------CONFIGURACION PIC-------------------------------------------

	__CONFIG    _CONFIG1, _FOSC_INTRC_NOCLKOUT & _WDTE_OFF & _PWRTE_OFF & _MCLRE_ON & _CP_OFF & _CPD_OFF & _BOREN_ON & _IESO_ON & _FCMEN_ON & _LVP_ON
	__CONFIG    _CONFIG2, _BOR4V_BOR40V & _WRT_OFF
	
;-------------------DECLARACION DE VARIABLES------------------------------------
	    
	    V1	    EQU	    0x20    ; Variable para el loop interno.
	    V2	    EQU	    0x21    ; Variable para el loop medio.
	    V3	    EQU	    0x22    ; Variable para el loop externo.
	
;-------------------INICIALIZACIÓN----------------------------------------------
	    
	    ORG	    0x00
	    
	    GOTO    CONFIG_	    ; Comienzo configurando todo.
	    
	    ORG	    0x04
	    
	    GOTO    RUT_INT	    ; Cuando ocurre una interrupción, voy a la
				    ; rutina de la misma.

;-------------------CONFIGURACION DE REGISTROS----------------------------------
	    
            ORG	    0x05
	    
 CONFIG_    NOP			    ; Para evitar bug de MPLAB.
	    BANKSEL TRISD	    ; Seteo PORTD como salida.
	    CLRF    TRISD
	    BANKSEL TRISB	    ; Seteo RA4 y RB0 como inputs.
	    MOVLW   b'00000001'
	    MOVWF   TRISB
	    BANKSEL TRISA
	    MOVLW   b'00010000'
	    BANKSEL ANSEL	    ; Seteo PORTA y PORTB como digitales.
	    CLRF    ANSEL
	    BANKSEL ANSELH
	    CLRF    ANSELH
	    BANKSEL INTCON	    ; Habilito las interrupciones por PORTB.
	    MOVLW   b'10010000'
	    MOVWF   INTCON
	    BANKSEL IOCB	    ; Habilito RB0 como fuente de interrupciones.
	    MOVLW   b'00000001'
	    MOVWF   IOCB
	    BANKSEL PORTD	    ; Apago los LEDs de PORTD.
	    CLRF    PORTD
	    BANKSEL PORTA	    ; Vuelvo al banco de PORTA.
	    CLRF    PORTA	    ; Limpio los registros a utilizar para evitar
	    CLRF    PORTB	    ; trabajar con basura de ejecuciones anteriores.
	    CLRW
	    GOTO    LOOP

;-------------------INICIO DEL PROGRAMA-----------------------------------------
	    
    LOOP    BTFSS   PORTA,4	    ; Chequeo el estado de RA4.
	    GOTO    TOGGLE	    ; Si se apretó, hago el antirrebote.
	    GOTO    LOOP	    ; Sino, sigo haciendo polling en RA4.
	    
  TOGGLE    COMF    PORTD,1	    ; Complemento el valor de PORTD.
	    CALL    TIMER_1S	    ; Espero dos segundos...
	    CALL    TIMER_1S
	    GOTO    TOGGLE	    ; Y vuelvo.
	    
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
	    
;-------------------RUTINA DE INTERRUPCIÓN--------------------------------------
	    
 RUT_INT    BCF	    INTCON,INTF	    ; Limpio la flag de interrupción, espero 3
	    CALL    TIMER_1S	    ; segundos y vuelvo.
	    CALL    TIMER_1S
	    CALL    TIMER_1S
	    RETFIE
				    
;-------------------COMENTARIOS-------------------------------------------------
;
;	Si bien la lógica del ejercicio funciona correctamente, en la
;	simulación de Proteus no se consigue este funcionamiento y puede que
;	sea por hacer los retardos por software sin usar TMR0 (alguna variable
;	contadora queda en un loop infinito y deja al programa en un deadlock).
;	No se implementaron retardos por software con TMR0 porque no es tema de
;	esta unidad. Resolver el ejercicio con TMR0 solucionaría este problema.
;	Tratar de solucionarlo sin TMR0 es engorroso y poco fructífero.
	    
	    END
