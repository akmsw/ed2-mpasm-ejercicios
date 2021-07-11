;   Ejercicio 5.2:
;
;   Escribir un programa que prenda un LED que se va desplazando cada vez que
;   se pulsa la tecla conectada a RB0. Al pulsar por primera vez la tecla, se
;   enciende el LED conectado a RB1, y al llegar a RB3 vuelve a RB1 y así
;   indefinidamente. El programa principal no realiza tarea alguna y todo se
;   desarrolla dentro de la subrutina de interrupción
	
;-------------------LIBRERIAS---------------------------------------------------

	#INCLUDE    <P16F887.INC>

	    LIST    P = 16F887

;-------------------CONFIGURACION PIC-------------------------------------------

	__CONFIG    _CONFIG1, _FOSC_INTRC_NOCLKOUT & _WDTE_OFF & _PWRTE_OFF & _MCLRE_ON & _CP_OFF & _CPD_OFF & _BOREN_ON & _IESO_ON & _FCMEN_ON & _LVP_ON
	__CONFIG    _CONFIG2, _BOR4V_BOR40V & _WRT_OFF
	
;-------------------DECLARACION DE VARIABLES------------------------------------
	    
	    COUNT   EQU	    0x20    ; Variable que se mostrará por PORTB.
   
;-------------------INICIALIZACIÓN----------------------------------------------
	    
	    ORG	    0x00
	    
	    GOTO    CONFIG_	    ; Comienzo configurando todo.
	    
	    ORG	    0x04
	    
	    GOTO    RUT_INT	    ; Cuando ocurre una interrupción, voy a la
				    ; rutina de la misma.

;-------------------CONFIGURACION DE REGISTROS----------------------------------
	    
            ORG	    0x05
	    
 CONFIG_    NOP			    ; Para evitar bug de MPLAB.
	    BANKSEL TRISB	    ; Seteo PORTB como output (excepto RB0 que
	    MOVLW   b'00000001'	    ; es input).
	    MOVWF   TRISB
	    BANKSEL ANSELH	    ; Configuro PORTB como digital.
	    CLRF    ANSELH
	    BANKSEL INTCON	    ; Habilito interrupciones globales y también
	    MOVLW   b'10010000'	    ; por RB0.
	    MOVWF   INTCON
	    BANKSEL IOCB	    ; Habilito RB0 como fuente de interrupción.
	    MOVLW   b'00000001'
	    MOVWF   IOCB
	    BANKSEL PORTB	    ; Vuelvo al banco de PORTB para comenzar.
	    CALL    SET_COUNT	    ; Cargo el valor inicial a mostrar.
	    CLRF    PORTB	    ; Limpio los registros y puertos a utilizar
	    CLRW		    ; para evitar residuos de ejecuciones
	    GOTO    START	    ; anteriores.

;-------------------INICIO DEL PROGRAMA-----------------------------------------
	    
    START   GOTO    $		    ; El programa principal no hace nada.
				    ; Me quedo esperando a que ocurra alguna
				    ; interrupción.
				    
;-------------------RUTINA DE INTERRUPCIÓN--------------------------------------
	    
 RUT_INT    BTFSS   PORTB,0	    ; Antirrebote.
	    GOTO    $-1
	    BTFSC   INTCON,INTF	    ; Si la interrupción fue por RB0,
	    CALL    MOVE_LED	    ; desplazo el LED.
	    RETFIE

MOVE_LED    BCF	    STATUS,C	    ; Limpio el carry para evitar basura, y roto
	    RLF	    COUNT,1	    ; COUNT hacia la izquierda. Cuando el cuarto
	    BTFSC   COUNT,4	    ; bit esté en '1', reseteo COUNT.
	    CALL    RESET_COUNT
	    MOVFW   COUNT	    ; Muestro COUNT por PORTB.
	    MOVWF   PORTB
	    BCF	    INTCON,INTF	    ; Apago la flag de interrupción por RB0.
	    RETURN
	    
SET_COUNT   MOVLW   b'00000001'	    ; Seteo COUNT con su valor inicial.
	    MOVWF   COUNT
	    RETURN
	    
RESET_COUNT CALL    SET_COUNT	    ; Seteo COUNT con su valor inicial y lo roto
	    RLF	    COUNT,1	    ; para volver al primer LED encendido.
	    RETURN
	    
	    END