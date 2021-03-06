;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*               PLACA DE APRENDIZAGEM: USTART FOR PIC		   *
;*		 PROGRAMAÇÃO EM ASSEMBLY DO PIC18F4550		   *
;*			AUTOR: MARISMAR COSTA                      *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
    
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                     ARQUIVOS DE DEFINIÇÕES                      *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *	
LIST p=18f4550, r=hex  
#INCLUDE <p18f4550.inc>		;ARQUIVO PADRÃO MICROCHIP PARA 18F4550
    
; CONFIG1L
  CONFIG  PLLDIV = 1            ; PLL PRESCALER SELECTION BITS (NO PRESCALE (4 MHZ OSCILLATOR INPUT DRIVES PLL DIRECTLY))
  CONFIG  CPUDIV = OSC1_PLL2    ; SYSTEM CLOCK POSTSCALER SELECTION BITS ([PRIMARY OSCILLATOR SRC: /1][96 MHZ PLL SRC: /2])
  CONFIG  USBDIV = 1            ; USB CLOCK SELECTION BIT (USED IN FULL-SPEED USB MODE ONLY; UCFG:FSEN = 1) (USB CLOCK SOURCE COMES DIRECTLY FROM THE PRIMARY OSCILLATOR BLOCK WITH NO POSTSCALE)

; CONFIG1H
  CONFIG  FOSC = INTOSCIO_EC    ; OSCILLATOR SELECTION BITS (INTERNAL OSCILLATOR, PORT FUNCTION ON RA6, EC USED BY USB (INTIO))
  CONFIG  FCMEN = OFF           ; FAIL-SAFE CLOCK MONITOR ENABLE BIT (FAIL-SAFE CLOCK MONITOR DISABLED)
  CONFIG  IESO = OFF            ; INTERNAL/EXTERNAL OSCILLATOR SWITCHOVER BIT (OSCILLATOR SWITCHOVER MODE DISABLED)

; CONFIG2L
  CONFIG  PWRT = ON             ; POWER-UP TIMER ENABLE BIT (PWRT ENABLED)
  CONFIG  BOR = ON              ; BROWN-OUT RESET ENABLE BITS (BROWN-OUT RESET ENABLED IN HARDWARE ONLY (SBOREN IS DISABLED))
  CONFIG  BORV = 3              ; BROWN-OUT RESET VOLTAGE BITS (MINIMUM SETTING 2.05V)
  CONFIG  VREGEN = OFF          ; USB VOLTAGE REGULATOR ENABLE BIT (USB VOLTAGE REGULATOR DISABLED)

; CONFIG2H
  CONFIG  WDT = OFF             ; WATCHDOG TIMER ENABLE BIT (WDT DISABLED (CONTROL IS PLACED ON THE SWDTEN BIT))
  CONFIG  WDTPS = 32768         ; WATCHDOG TIMER POSTSCALE SELECT BITS (1:32768)

; CONFIG3H
  CONFIG  CCP2MX = ON           ; CCP2 MUX BIT (CCP2 INPUT/OUTPUT IS MULTIPLEXED WITH RC1)
  CONFIG  PBADEN = OFF          ; PORTB A/D ENABLE BIT (PORTB<4:0> PINS ARE CONFIGURED AS DIGITAL I/O ON RESET)
  CONFIG  LPT1OSC = OFF         ; LOW-POWER TIMER 1 OSCILLATOR ENABLE BIT (TIMER1 CONFIGURED FOR HIGHER POWER OPERATION)
  CONFIG  MCLRE = ON            ; MCLR PIN ENABLE BIT (MCLR PIN ENABLED; RE3 INPUT PIN DISABLED)

; CONFIG4L
  CONFIG  STVREN = ON           ; STACK FULL/UNDERFLOW RESET ENABLE BIT (STACK FULL/UNDERFLOW WILL CAUSE RESET)
  CONFIG  LVP = OFF             ; SINGLE-SUPPLY ICSP ENABLE BIT (SINGLE-SUPPLY ICSP DISABLED)
  CONFIG  ICPRT = ON            ; DEDICATED IN-CIRCUIT DEBUG/PROGRAMMING PORT (ICPORT) ENABLE BIT (ICPORT ENABLED)
  CONFIG  XINST = OFF           ; EXTENDED INSTRUCTION SET ENABLE BIT (INSTRUCTION SET EXTENSION AND INDEXED ADDRESSING MODE DISABLED (LEGACY MODE))

; CONFIG5L
  CONFIG  CP0 = OFF             ; CODE PROTECTION BIT (BLOCK 0 (000800-001FFFH) IS NOT CODE-PROTECTED)
  CONFIG  CP1 = OFF             ; CODE PROTECTION BIT (BLOCK 1 (002000-003FFFH) IS NOT CODE-PROTECTED)
  CONFIG  CP2 = OFF             ; CODE PROTECTION BIT (BLOCK 2 (004000-005FFFH) IS NOT CODE-PROTECTED)
  CONFIG  CP3 = OFF             ; CODE PROTECTION BIT (BLOCK 3 (006000-007FFFH) IS NOT CODE-PROTECTED)

; CONFIG5H
  CONFIG  CPB = OFF             ; BOOT BLOCK CODE PROTECTION BIT (BOOT BLOCK (000000-0007FFH) IS NOT CODE-PROTECTED)
  CONFIG  CPD = OFF             ; DATA EEPROM CODE PROTECTION BIT (DATA EEPROM IS NOT CODE-PROTECTED)

; CONFIG6L
  CONFIG  WRT0 = OFF            ; WRITE PROTECTION BIT (BLOCK 0 (000800-001FFFH) IS NOT WRITE-PROTECTED)
  CONFIG  WRT1 = OFF            ; WRITE PROTECTION BIT (BLOCK 1 (002000-003FFFH) IS NOT WRITE-PROTECTED)
  CONFIG  WRT2 = OFF            ; WRITE PROTECTION BIT (BLOCK 2 (004000-005FFFH) IS NOT WRITE-PROTECTED)
  CONFIG  WRT3 = OFF            ; WRITE PROTECTION BIT (BLOCK 3 (006000-007FFFH) IS NOT WRITE-PROTECTED)

; CONFIG6H
  CONFIG  WRTC = OFF            ; CONFIGURATION REGISTER WRITE PROTECTION BIT (CONFIGURATION REGISTERS (300000-3000FFH) ARE NOT WRITE-PROTECTED)
  CONFIG  WRTB = OFF            ; BOOT BLOCK WRITE PROTECTION BIT (BOOT BLOCK (000000-0007FFH) IS NOT WRITE-PROTECTED)
  CONFIG  WRTD = OFF            ; DATA EEPROM WRITE PROTECTION BIT (DATA EEPROM IS NOT WRITE-PROTECTED)

; CONFIG7L
  CONFIG  EBTR0 = OFF           ; TABLE READ PROTECTION BIT (BLOCK 0 (000800-001FFFH) IS NOT PROTECTED FROM TABLE READS EXECUTED IN OTHER BLOCKS)
  CONFIG  EBTR1 = OFF           ; TABLE READ PROTECTION BIT (BLOCK 1 (002000-003FFFH) IS NOT PROTECTED FROM TABLE READS EXECUTED IN OTHER BLOCKS)
  CONFIG  EBTR2 = OFF           ; TABLE READ PROTECTION BIT (BLOCK 2 (004000-005FFFH) IS NOT PROTECTED FROM TABLE READS EXECUTED IN OTHER BLOCKS)
  CONFIG  EBTR3 = OFF           ; TABLE READ PROTECTION BIT (BLOCK 3 (006000-007FFFH) IS NOT PROTECTED FROM TABLE READS EXECUTED IN OTHER BLOCKS)

; CONFIG7H
  CONFIG  EBTRB = OFF           ; BOOT BLOCK TABLE READ PROTECTION BIT (BOOT BLOCK (000000-0007FFH) IS NOT PROTECTED FROM TABLE READS EXECUTED IN OTHER BLOCKS)

	
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                         VARIÁVEIS                               *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; DEFINIÇÃO DOS NOMES E ENDEREÇOS DE TODAS AS VARIÁVEIS UTILIZADAS 
; PELO SISTEMA

	CBLOCK	0x10		;ENDEREÇO INICIAL DA MEMÓRIA DE USUÁRIO
		W_TEMP		;REGISTRADORES TEMPORÁRIOS PARA USO
		STATUS_TEMP	;JUNTO ÀS INTERRUPÇÕES

		;NOVAS VARIÁVEIS
		DELAY1		
		DELAY2
		DELAY3

	ENDC			;FIM DO BLOCO DE MEMÓRIA

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*			      VETORES                              *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

	ORG 0x0000		;ENDEREÇO INICIAL DO PROGRAMA
	GOTO INICIO
    
	ORG 0x0008		;ENDEREÇO DA INTERRUPÇÃO DE ALTA PRIORIDADE
	GOTO HIGH_INT
    
	ORG 0x0018		;ENDEREÇO DA INTERRUPÇÃO DE BAIXA PRIORIDADE
	GOTO LOW_INT
    
    
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*            INÍCIO DA INTERRUPÇÃO DE ALTA PRIORIDADE             *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; ENDEREÇO DE DESVIO DAS INTERRUPÇÕES. A PRIMEIRA TAREFA É SALVAR OS
; VALORES DE "W" E "STATUS" PARA RECUPERAÇÃO FUTURA
    
HIGH_INT:
	MOVWF	W_TEMP		;COPIA W PARA W_TEMP
	SWAPF	STATUS,W
	MOVWF	STATUS_TEMP	;COPIA STATUS PARA STATUS_TEMP

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*            ROTINA DE INTERRUPÇÃO DE ALTA PRIORIDADE             *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; AQUI SERÃO ESCRITAS AS ROTINAS DE RECONHECIMENTO E TRATAMENTO DAS
; INTERRUPÇÕES

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*       ROTINA DE SAÍDA DA INTERRUPÇÃO DE ALTA PRIORIDADE         *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; OS VALORES DE "W" E "STATUS" DEVEM SER RECUPERADOS ANTES DE 
; RETORNAR DA INTERRUPÇÃO

END_INT:
	SWAPF	STATUS_TEMP,W
	MOVWF	STATUS		;MOVE STATUS_TEMP PARA STATUS
	SWAPF	W_TEMP,F
	SWAPF	W_TEMP,W	;MOVE W_TEMP PARA W
	RETFIE
    
	
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*            INÍCIO DA INTERRUPÇÃO DE BAIXA PRIORIDADE            *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; ENDEREÇO DE DESVIO DAS INTERRUPÇÕES. A PRIMEIRA TAREFA É SALVAR OS
; VALORES DE "W" E "STATUS" PARA RECUPERAÇÃO FUTURA
	
LOW_INT:
	MOVWF	W_TEMP		;COPIA W PARA W_TEMP
	SWAPF	STATUS,W
	MOVWF	STATUS_TEMP	;COPIA STATUS PARA STATUS_TEMP

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*           ROTINA DE INTERRUPÇÃO DE BAIXA PRIORIDADE             *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; AQUI SERÃO ESCRITAS AS ROTINAS DE RECONHECIMENTO E TRATAMENTO DAS
; INTERRUPÇÕES
	
	NOP
	
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*      ROTINA DE SAÍDA DA INTERRUPÇÃO DE BAIXA PRIORIDADE         *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; OS VALORES DE "W" E "STATUS" DEVEM SER RECUPERADOS ANTES DE 
; RETORNAR DA INTERRUPÇÃO
	
	SWAPF	STATUS_TEMP,W
	MOVWF	STATUS		;MOVE STATUS_TEMP PARA STATUS
	SWAPF	W_TEMP,F
	SWAPF	W_TEMP,W	;MOVE W_TEMP PARA W
	RETFIE
    
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*	            	 ROTINAS E SUBROTINAS                      *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; CADA ROTINA OU SUBROTINA DEVE POSSUIR A DESCRIÇÃO DE FUNCIONAMENTO
; E UM NOME COERENTE ÀS SUAS FUNÇÕES.

SUBROTINA1

	;CORPO DA ROTINA

	RETURN

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                     INICIO DO PROGRAMA                          *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
	
INICIO:
	;INTCON (1,2 e 3) funcionam de acordo com os valores encontrados em RCON,IPEN
	;Neste caso, RCON,IPEN = 0 (incialização padrão)
	MOVLW	B'00100001'
	MOVWF	T0CON
	
	;INICIALIZA TIMER
	MOVLW   0x00
	MOVWF   TMR0H
	MOVLW   0x00
	MOVWF   TMR0L

	;INTCON2,TMR0IP define se o estouro do timer desvia para hi_int ou low_int
	BSF	    INTCON2,TMR0IP ; Timer 0 - INTCON2,TMR0IP = 1 - Alta prioridade
	BSF	    T0CON,TMR0ON   ; Timer 0 - Habilita Timer0
	BCF	    INTCON,GIE     ; Habilita interrupções globais
		
	CLRF    PORTC		; INICIALIZA PORTC
	CLRF    LATC 
	MOVLW   07h 
	movlw   B'00000000'
	MOVWF   TRISC

	CLRF    PORTB		; INICIALIZA PORTB
	CLRF    LATB
	MOVLW   0Eh
	MOVLW   B'00001111'	;DESABILITA O ADCON1
	MOVWF   ADCON1		; PINOS DE E/S DIGITAL 
	MOVLW   0CFh ;
	MOVLW   B'00000000'
	MOVWF   TRISB		;SETA AS PORTAS COMO ENTRADA OU SAÍDA

	;CONFIGURAÇÃO DO SPI MODE
	MOVLW   B'00110000'
	MOVWF   SSPCON1		; CONTROLE DO SPI MODE
	MOVLW   B'11000000'
	MOVWF   SSPSTAT		; STATUS DE FLAGS RELACIONADAS AO SPI

	; CONFIGURANDO O CLOCK
	MOVLW   B'01100111'
	MOVWF   OSCCON		;CONFIGURA O MODO DE OPERAÇÃO DO CLOCK INTERNO
	MOVLW   B'10000000'
	MOVWF   OSCTUNE		;REGISTRADOR QUE CALIBRA A VELOCIDADE DO CLOCK

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                     INICIALIZAÇÃO DAS VARIÁVEIS                 *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
	
	
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                     ROTINA PRINCIPAL                            *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
MAIN
	; Serial Data Out (SDO) - RC7/RX/DT/SDO
	; Serial Clock (SCK) - RB1/AN10/INT1/SCK/SCL
	; CKE E CKP CONTROLAM O MODO DE OPERAÇÃO DO CLOCK DO MASTER
	; CKE = 1, CKP = 1 ESCOLHIDO POR MARISMAR
	BSF	LATA,2	    ; TESTE DE VELOCIDADE DE INSTRUÇÃO
	BCF	LATA,2
	; TESTANDO ENVIO DE DADOS POR SPI
	MOVLW   .6
	MOVWF   SSPBUF
    
	GOTO MAIN

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                       FIM DO PROGRAMA                           *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

	END
