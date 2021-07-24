;   Ejercicio 6.2A: (EJERCICIO PARA PRACTICAR TMR0 ANTES DEL EJERCICIO 6.3)
;
;   Utilizando el módulo TMR0, desarrolle un programa en Assembly que haga
;   parpadear un LED cada 500[ms] conectado al pin RB3. Hacer uso de
;   interrupciones, no por polling.

;-------------------LIBRERIAS---------------------------------------------------

	#INCLUDE    <P16F887.INC>

	    LIST    P = 16F887

;-------------------CONFIGURACION PIC-------------------------------------------

	__CONFIG    _CONFIG1, _FOSC_INTRC_NOCLKOUT & _WDTE_OFF & _PWRTE_OFF & _MCLRE_ON & _CP_OFF & _CPD_OFF & _BOREN_ON & _IESO_ON & _FCMEN_ON & _LVP_ON
	__CONFIG    _CONFIG2, _BOR4V_BOR40V & _WRT_OFF

;-------------------DECLARACION DE VARIABLES------------------------------------

	    COUNT   EQU	    0x20    ; Contador para el overflow de TMR0,

;-------------------INICIO DEL PROGRAMA-----------------------------------------

	    ORG	    0x00
	    
	    GOTO    CONFIG_
	    
	    ORG	    0x04
	    
	    GOTO    RUT_IN
   
;-------------------CONFIGURACION DE REGISTROS----------------------------------
	    
	    ORG	    0x05
	    
 CONFIG_    NOP			    ; Para evitar bug de MPLAB.
	    BANKSEL OPTION_REG	    ; deshabilito resistencias de pull-up, uso
	    MOVLW   b'10000111'	    ; el clock interno y asigno un prescaler de
	    MOVWF   OPTION_REG	    ; 1:256 a TMR0.
	    BANKSEL INTCON	    ; Habilito interrupciones globales y por
	    MOVLW   b'10100000'	    ; TMR0.
	    MOVWF   INTCON
	    BANKSEL TRISB	    ; Seteo RB3 como output.
	    BCF	    TRISB,3
	    BANKSEL ANSELH	    ; Limpio ANSELH para que PORTB quede como
	    CLRF    ANSELH	    ; puerto digital.
	    BANKSEL PORTB
	    CALL    SET_COUNT	    ; Configuro el registro COUNT.
	    CALL    SET_TMR0
	    CLRF    PORTB	    ; Limpio los registros a usar para evitar
	    CLRW		    ; basura de ejecuciones anteriores.
	    GOTO    INIT
	    
    INIT    GOTO    $		    ; No hago nada, me quedo esperando una 
				    ; interrupción (el led comienza apagado).
				    
SET_TMR0    NOP
	    BANKSEL TMR0	    ; Cargo TMR0 con 60 para lograr 50[ms] para
	    MOVLW   .60		    ; overflow.
	    MOVWF   TMR0
	    RETURN
	    
;-------------------RUTINA DE INTERRUPCIÓN--------------------------------------
	    
  RUT_IN    BTFSS   INTCON,T0IF	    ; Chequeo la flag de interrupción por TMR0.
	    GOTO    FINISH	    ; Si fue un falso positivo, vuelvo.
	    GOTO    RESET_TMR0	    ; Sino, reseteo TMR0 y vuelvo.
	    
RESET_TMR0  BCF	    INTCON,T0IF	    ; Limpio la flag de interrupción por TMR0 y
	    CALL    SET_TMR0	    ; reseteo TMR0 con el valor precalculado.
	    DECFSZ  COUNT	    ; Si pasaron 500[ms], toggleo el LED. Sino,
	    RETFIE		    ; vuelvo.
	    CALL    TOGGLE_RB3
	    CALL    SET_COUNT
	    RETFIE
	    
TOGGLE_RB3  BTFSC   PORTB,3	    ; Si RB3 estaba en 1, lo paso a 0 y
	    GOTO    SET_LOW	    ; viceversa.
	    GOTO    SET_HIGH
	    
 SET_LOW    BCF	    PORTB,3
	    RETURN
	    
SET_HIGH    BSF	    PORTB,3
	    RETURN
	    
SET_COUNT   MOVLW   .10		    ; Cargo COUNT con 10 para contar diez veces
	    MOVWF   COUNT	    ; 50[ms] y así llegar a los 500[ms].
	    RETURN
	    
  FINISH    BCF	    INTCON,T0IF	    ; Limpio la flag correspondiente a TMR0 y
	    RETFIE		    ; vuelvo.
  
	    END