;   Ejercicio 5.4: (LA CONSIGNA SE CAMBIÓ PARA SIMPLICIDAD)
;
;   Escribir un código en assembler que realice una interrupción por RB cuando
;   se realice un cambio de nivel en cualquiera de los puertos RB<7:4>. En el
;   servicio a la interrupción (ISR) generar un retardo de 100[ms] e incrementar
;   un contador. Mostrar la cuenta por PORTD. Suponer un reloj de 4[MHz].
	
;-------------------LIBRERIAS---------------------------------------------------

	#INCLUDE    <P16F887.INC>

	    LIST    P = 16F887

;-------------------CONFIGURACION PIC-------------------------------------------

	__CONFIG    _CONFIG1, _FOSC_INTRC_NOCLKOUT & _WDTE_OFF & _PWRTE_OFF & _MCLRE_ON & _CP_OFF & _CPD_OFF & _BOREN_ON & _IESO_ON & _FCMEN_ON & _LVP_ON
	__CONFIG    _CONFIG2, _BOR4V_BOR40V & _WRT_OFF
	
;-------------------DECLARACION DE VARIABLES------------------------------------
	    
	    AUX	    EQU	    0x20    ; Variable auxiliar.
	    V1	    EQU	    0x21    ; Variables para los loops del retardo.
	    V2	    EQU	    0x22
	    COUNT   EQU	    0x23    ; Variable a incrementar.
   
;-------------------INICIALIZACIÓN----------------------------------------------
	    
	    ORG	    0x00
	    
	    GOTO    CONFIG_	    ; Comienzo configurando todo.
	    
	    ORG	    0x04
	    
	    GOTO    RUT_INT	    ; Cuando ocurre una interrupción, voy a la
				    ; rutina de la misma.

;-------------------CONFIGURACION DE REGISTROS----------------------------------
	    
            ORG	    0x05
	    
 CONFIG_    NOP			    ; Para evitar bug de MPLAB.
	    BANKSEL TRISB	    ; Seteo RB<7:4> como inputs y el resto de
	    MOVLW   b'11110000'	    ; bits de PORTB como outputs.
	    MOVWF   TRISB
	    BANKSEL ANSELH	    ; Seteo PORTB como digital.
	    CLRF    ANSELH
	    BANKSEL TRISD	    ; Seteo PORTD como outputs.
	    CLRF    TRISD
	    BANKSEL INTCON	    ; Habilito interrupciones por RB<7:4>.
	    MOVLW   b'10001000'
	    MOVWF   INTCON
	    BANKSEL IOCB
	    MOVLW   b'11110000'	    ; Habilito RB<7:4> como fuentes de
	    MOVWF   IOCB	    ; interrupción
	    BANKSEL PORTB	    ; Vuelvo al banco de PORTB para comenzar.
	    MOVLW   b'11110000'	    ; Limpio los registros a utilizar para
	    MOVWF   PORTB	    ; evitar basura.
	    clrf    PORTD
	    CLRF    AUX
	    CLRF    V1
	    CLRF    V2
	    CLRF    COUNT
	    CLRW	    
	    GOTO    START

;-------------------INICIO DEL PROGRAMA-----------------------------------------
	    
   START    GOTO    $		    ; El programa principal no hace nada.
				    ; Espero a que ocurra una interrupción.
				    
;-------------------RUTINA DE INTERRUPCIÓN--------------------------------------
	    
 RUT_INT    BTFSC   INTCON,RBIF	    ; Si la interrupción fue por RB<7:4>,
	    GOTO    RB_TEST	    ; incremento COUNT, limpio la flag y vuelvo.
	    GOTO    FINISH	    ; Sino, la interrupción no me interesa,
				    ; así que limpio la flag y vuelvo.
	    
RB_TEST	    BTFSS   PORTB,4	    ; Testeo de dónde viene la interrupción
	    GOTO    AR_4	    ; para hacer el antirrebote.
	    BTFSS   PORTB,5
	    GOTO    AR_5
	    BTFSS   PORTB,6
	    GOTO    AR_6
	    BTFSS   PORTB,7
	    GOTO    AR_7
	    GOTO    FINISH
	    
    AR_4    BTFSS   PORTB,4	    ; Hago el antirrebote en el pin necesario,
	    GOTO    $-1		    ; espero los 100[ms], incremento COUNT,
	    CALL    TIMER_100MS	    ; lo muestro por PORTD, bajo la flag y
	    CALL    INC_COUNT	    ; vuelvo.
	    GOTO    FINISH
	    
    AR_5    BTFSS   PORTB,5
	    GOTO    $-1
	    CALL    TIMER_100MS
	    CALL    INC_COUNT
	    GOTO    FINISH
	    
    AR_6    BTFSS   PORTB,6
	    GOTO    $-1
	    CALL    TIMER_100MS
	    CALL    INC_COUNT
	    GOTO    FINISH
	    
    AR_7    BTFSS   PORTB,7
	    GOTO    $-1
	    CALL    TIMER_100MS
	    CALL    INC_COUNT
	    GOTO    FINISH
	    
TIMER_100MS NOP	    
  LMED10    MOVLW   .130	    ; Cargo V1, y V2 con valores previamente
	    MOVWF   V2		    ; calculados para que el ciclo dure 100[ms].
  LINT10    MOVLW   .255
	    MOVWF   V1
	    DECFSZ  V1		    ; Decremento V1. Si aún no es cero...
	    GOTO    $-1		    ; sigo decrementando V1.
	    DECFSZ  V2		    ; Si V1 es cero, decremento V2.
	    GOTO    LINT10	    ; Si V2 aún no es cero, recargo V1 y repito.
	    RETURN		    ; Si V2 es cero, vuelvo.
	    
INC_COUNT   INCF    COUNT,1	    ; Incremento COUNT en 1, muestro por PORTD
	    MOVFW   COUNT	    ; y vuelvo.
	    MOVWF   PORTD
	    RETURN
	    
  FINISH    BCF	    INTCON,RBIF	    ; Limpio la flag de interrupción y vuelvo.
	    RETFIE
	    
	    END