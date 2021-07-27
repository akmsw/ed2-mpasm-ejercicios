;   Ejercicio 6.2A: (EJERCICIO PARA PRACTICAR MULTIPLEXACIÓN
;		     ANTES DEL EJERCICIO 6.3)
;
;   Utilizando el módulo TMR0, retardos y técnicas de multiplexación, desarrolle
;   un programa en Assembly que muestre el valor '0123' en un arreglo de cuatro
;   displays de 7 segmentos de cátodo común. No usar TMR0.

;-------------------LIBRERIAS---------------------------------------------------

	#INCLUDE    <P16F887.INC>

	    LIST    P = 16F887

;-------------------CONFIGURACION PIC-------------------------------------------

	__CONFIG    _CONFIG1, _FOSC_INTRC_NOCLKOUT & _WDTE_OFF & _PWRTE_OFF & _MCLRE_ON & _CP_OFF & _CPD_OFF & _BOREN_ON & _IESO_ON & _FCMEN_ON & _LVP_ON
	__CONFIG    _CONFIG2, _BOR4V_BOR40V & _WRT_OFF

;-------------------DECLARACION DE VARIABLES------------------------------------

	    TR_ON   EQU	    0x20    ; Indicador para encender los transistores.
	    D_QUA   EQU	    0x21    ; Cantidad de displays en el arreglo.
	     D_ON   EQU	    0x22    ; Display a prender.
	       V1   EQU	    0x23    ; Variables para los loops del retardo.
	       V2   EQU	    0x24

;-------------------INICIO DEL PROGRAMA-----------------------------------------

	    ORG	    0x00
	    
 CONFIG_    MOVLW   .4		    ; Cargo la cantidad de displays a usar.
	    MOVWF   D_QUA
	    MOVLW   .1		    ; Voy a empezar encendiendo el primer
	    MOVWF   TR_ON	    ; transistor.
	    CLRF    D_ON	    ; Voy a empezar a trabajar con el display 0.
	    BANKSEL TRISC	    ; Configuro PORTC y PORTD como outputs.
	    CLRF    TRISC
	    BANKSEL TRISD
	    CLRF    TRISD
	    BANKSEL PORTC	    ; Vuelvo al banco de PORTC para empezar.
	    GOTO    INIT
	    
    INIT    MOVFW   D_ON	    ; Cargo el número de display a encender y
	    CALL    VALUES	    ; busco el valor que le corresponde mostrar.
	    MOVWF   PORTC
	    MOVFW   TR_ON	    ; Enciendo el transistor correspondiente.
	    MOVWF   PORTD
	    CALL    TIMER	    ; Espero el tiempo necesario, cambio el
	    GOTO    NEXT_D	    ; display a mostrar y repito
	    
  NEXT_D    INCF    D_ON,F	    ; Me muevo al siguiente display verificando
	    MOVFW   D_ON	    ; no haber sobrepasado la cantidad de
	    SUBWF   D_QUA,W	    ; displays del arreglo.
	    BTFSC   STATUS,Z
	    GOTO    RESET_D	    ; Si pasé el límite, reseteo D_ON y TR_ON.
	    BCF	    STATUS,C	    ; Sino, roto TR_ON para encender el
	    RLF	    TR_ON	    ; siguiente transistor.
	    GOTO    INIT
	    
 RESET_D    CLRF    D_ON	    ; Vuelvo a D_ON y a TR_ON a sus valores
	    MOVLW   .1		    ; iniciales.
	    MOVWF   TR_ON
	    GOTO    INIT
	    
;-------------------RETARDOS----------------------------------------------------
	    
   TIMER    MOVLW   .13		    ; Cargo V1 y V2 y V3 con valores previamente
	    MOVWF   V2		    ; calculados para que el ciclo dure 10[ms].
    LINT    MOVLW   .255
	    MOVWF   V1
	    DECFSZ  V1		    ; Decremento V1.
	    GOTO    $-1		    ; Si V1 aún no es cero, sigo decrementando.
	    DECFSZ  V2		    ; Si V1 es cero, decremento V2.
	    GOTO    LINT	    ; Si V2 aún no es cero, recargo V1 y repito.
	    RETURN		    ; Si V2 es cero, vuelvo.
    
;-------------------TABLAS------------------------------------------------------
    
  VALUES    ADDWF   PCL,F
	    RETLW   b'00111111'	    ; Display 0 = 0
	    RETLW   b'00000110'	    ; Display 1 = 1
	    RETLW   b'01011011'	    ; Display 2 = 2
	    RETLW   b'01001111'	    ; Display 3 = 3
	    
;-------------------COMENTARIOS-------------------------------------------------
;
;   Si bien el código funciona correctamente, en la simulación en Proteus
;   la multiplexación no se apreciadel todo por el hecho de estar usando los
;   displays de manera individual interconectando los pines correspondientes
;   entre ellos. Con el módulo de cuatro displays que ofrece Proteus, esto
;   deja de ser un problema, pero se decidió hacer el esquema circuital de esta
;   forma para dejar más en claro el funcionamiento electrónico.

	    END