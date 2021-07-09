;   Ejercicio 4.5:
;
;   Se desea que al apretar el pulsador conectado a RA4 parpadeen, a una
;   frecuencia de 0.5[MHz], los 8 LEDs conectados en cátodo comñun a los 8
;   terminales del puerto D de un microcontrolador PIC16F887. Dicho parpadeo
;   se debe interurmpir durante unos instantes (3 segundos) si se aprieta el
;   pulsador conectado a RB0. Inicialmente, los LEDs están apagados.
;   El oscilador es de 4[MHz].

;-------------------LIBRERIAS---------------------------------------------------

	#INCLUDE    <P16F887.INC>

	    LIST    P = 16F887

;-------------------CONFIGURACION PIC-------------------------------------------

	__CONFIG    _CONFIG1, _FOSC_INTRC_NOCLKOUT & _WDTE_OFF & _PWRTE_OFF & _MCLRE_ON & _CP_OFF & _CPD_OFF & _BOREN_ON & _IESO_ON & _FCMEN_ON & _LVP_ON
	__CONFIG    _CONFIG2, _BOR4V_BOR40V & _WRT_OFF
	
;-------------------DECLARACION DE VARIABLES------------------------------------
	    
	    ORG	    0x00

	    V1	    EQU	    0x20    ; Variable para el loop interno.
	    V2	    EQU	    0x21    ; Variable para el loop medio.
	    V3	    EQU	    0x22    ; Variable para el loop externo.

;-------------------CONFIGURACION DE REGISTROS----------------------------------
	    
	    BANKSEL TRISD	; Seteo PORTD como salida.
	    CLRF    TRISD
	    BANKSEL TRISB	; Seteo RA4 y RB0 como inputs.
	    MOVLW   b'00000001'
	    MOVWF   TRISB
	    BANKSEL TRISA
	    MOVLW   b'00010000'
	    BANKSEL ANSEL	; Seteo PORTA y PORTB como digitales.
	    CLRF    ANSEL
	    BANKSEL ANSELH
	    CLRF    ANSELH
	    BANKSEL PORTD	; Apago los LEDs de PORTD.
	    CLRF    PORTD
	    BANKSEL PORTA	; Vuelvo al banco de PORTA.
	    CLRF    PORTA	; Limpio los registros a utilizar para evitar
	    CLRF    PORTB	; trabajar con basura de ejecuciones anteriores.
	    CLRW

;-------------------INICIO DEL PROGRAMA-----------------------------------------
	    
    LOOP    BTFSS   PORTA,4	; Chequeo el estado de RA4.
	    GOTO    PRESSEDA	; Si se apretó, hago el antirrebote.
	    GOTO    LOOP	; Sino, sigo haciendo polling en RA4.
	    
PRESSEDA    BTFSS   PORTA,4	; Cuando el estado de RA4 cambie, continúo.
	    GOTO    $-1
  TOGGLE    COMF    PORTD,1	; Complemento el valor de PORTD.
	    CALL    TIMER_2S	; Espero dos segundos.
	    BTFSS   PORTB,0	; Chequeo el estado de RB0.
	    CALL    PRESSEDB	; Si se apretó, hago el antirrebote.
	    GOTO    TOGGLE	; Y vuelvo.
	    
PRESSEDB    BTFSS   PORTB,0	; Cuando el estado de RB0 cambie, continúo.
	    GOTO    $-1
	    CALL    TIMER_3S	; Espero tres segundos.
	    RETURN		; Vuelvo
	    
TIMER_2S    NOP			; --SUBRUTINA DE TIEMPO DE DOS SEGUNDOS--
	    MOVLW   .11		; Cargo V1, V2 y V3 con valores previamente
	    MOVWF   V3		; calculados para que el ciclo dure 3[s].
   LEXT2    MOVLW   .255
	    MOVWF   V2
   LINT2    MOVLW   .255
	    MOVWF   V1
	    DECFSZ  V1		; Decremento V1. Si aún no es cero...
	    GOTO    $-1		; sigo decrementando V1.
	    DECFSZ  V2		; Si V1 es cero, decremento V2.
	    GOTO    LINT2	; Si V2 aún no es cero, recargo V1 y repito.
	    DECFSZ  V3		; Si V2 es cero, decremento V3.
	    GOTO    LEXT2	; Si V3 aún no es cero, recargo V2 y repito.
	    RETURN		; Si V3 es cero, salgo de la subrutina.
	    
TIMER_3S    NOP			; --SUBRUTINA DE TIEMPO DE TRES SEGUNDOS--
	    MOVLW   .16		; Cargo V1, V2 y V3 con valores previamente
	    MOVWF   V3		; calculados para que el ciclo dure 3[s].
   LEXT3    MOVLW   .255
	    MOVWF   V2
   LINT3    MOVLW   .255
	    MOVWF   V1
	    DECFSZ  V1		; Decremento V1. Si aún no es cero...
	    GOTO    $-1		; sigo decrementando V1.
	    DECFSZ  V2		; Si V1 es cero, decremento V2.
	    GOTO    LINT3	; Si V2 aún no es cero, recargo V1 y repito.
	    DECFSZ  V3		; Si V2 es cero, decremento V3.
	    GOTO    LEXT3	; Si V3 aún no es cero, recargo V2 y repito.
	    RETURN		; Si V3 es cero, salgo de la subrutina.
	    
;-------------------COMENTARIOS-------------------------------------------------
;
;	Este ejercicio está resuelto de manera burda. Es complicado controlar
;	el comportamiento de los LEDs teniendo en cuenta el pulsador RB0 sin
;	hacer uso de interrupciones. Como el tema de interrupciones no se
;	abarca en la guía 4, este ejercicio se intentó resolver por polling.
;	Para que se muestre el correcto funcionamiento, en la simulación en
;	Proteus se deberá mantener presionado el botón de RB0 hasta que el
;	PIC detecte que está presionado (por polling). Una vez hecho esto, se
;	debe levantar el botón para que el antirrebote permita continuar con
;	la ejecución del programa. Así se verán reflejados los tres segundos
;	de pausa que se indican en la consigna.
	    
	    END
