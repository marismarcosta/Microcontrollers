;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*              MODIFICA��ES PARA USO COM 12F675                   *
;*                FEITAS PELO PROF. MARDSON                        *
;*                      JUNHO DE 2019                              *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                       NOME DO PROJETO                           *
;*                           CLIENTE                               *
;*         DESENVOLVIDO PELA MOSAICO ENGENHARIA E CONSULTORIA      *
;*   VERS�O: 1.0                           DATA: 17/06/03          *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                     DESCRI��O DO ARQUIVO                        *
;*-----------------------------------------------------------------*
;*   MODELO PARA O PIC 12F675                                      *
;*                                                                 *
;*                                                                 *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                     ARQUIVOS DE DEFINI��ES                      *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
#INCLUDE <p12f675.inc>	;ARQUIVO PADR�O MICROCHIP PARA 12F675

	__CONFIG _BODEN_OFF & _CP_OFF & _PWRTE_ON & _WDT_OFF & _MCLRE_ON & _INTRC_OSC_NOCLKOUT

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                    PAGINA��O DE MEM�RIA                         *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;DEFINI��O DE COMANDOS DE USU�RIO PARA ALTERA��O DA P�GINA DE MEM�RIA
#DEFINE	BANK0	BCF STATUS,RP0	;SETA BANK 0 DE MEM�RIA
#DEFINE	BANK1	BSF STATUS,RP0	;SETA BANK 1 DE MAM�RIA

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                         VARI�VEIS                               *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; DEFINI��O DOS NOMES E ENDERE�OS DE TODAS AS VARI�VEIS UTILIZADAS 
; PELO SISTEMA

	CBLOCK	0x20	;ENDERE�O INICIAL DA MEM�RIA DE
					;USU�RIO
		W_TEMP		;REGISTRADORES TEMPOR�RIOS PARA USO
		STATUS_TEMP	;JUNTO �S INTERRUP��ES
		
		COUNTER		; SABER SE CHEGOU UM BYTE
		VAR		; USADA NO ROTATE
		DADO		; VARI�VEL QUE � ENVIADA
		FLAG		; INDICA QUE O BYTE CHEGOU
		AUX1		; 
		AUX2		; GUARDA O VALOR DO DADO_2 E DADO_3
		AUX3		; GUARDA O VALOR DO DADO_1 E DADO_0
		AUX4		; GUARDA O NIBBLE MAIS SIGNIFICATIVO DE AUX3
		AUX5		; GUARDA O NIBBLE MAIS SIGNIFICATIVO DE AUX2  
		CHECK_SUM	; VERIFICA SE OS DADOS EST�O CORRETOS
		VARH
		ADRS		; ENDERE�O A SER IMPRESSO
		COUNTER2
		;NOVAS VARI�VEIS

	ENDC			;FIM DO BLOCO DE MEM�RIA
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                        FLAGS INTERNOS                           *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; DEFINI��O DE TODOS OS FLAGS UTILIZADOS PELO SISTEMA
	#DEFINE	FLAG_0  FLAG,0		    ; AQUI INDICA QUE � O PRIMEIRO BYTE CHEGOU
	#DEFINE	SEM_ERRO  FLAG,1	    ; SINALIZA SE HOUVE ERRO
	#DEFINE	TIME_OUT  FLAG,2   
	
	
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                         CONSTANTES                              *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; DEFINI��O DE TODAS AS CONSTANTES UTILIZADAS PELO SISTEMA

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                           ENTRADAS                              *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; DEFINI��O DE TODOS OS PINOS QUE SER�O UTILIZADOS COMO ENTRADA
; RECOMENDAMOS TAMB�M COMENTAR O SIGNIFICADO DE SEUS ESTADOS (0 E 1)

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                           SA�DAS                                *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; DEFINI��O DE TODOS OS PINOS QUE SER�O UTILIZADOS COMO SA�DA
; RECOMENDAMOS TAMB�M COMENTAR O SIGNIFICADO DE SEUS ESTADOS (0 E 1)

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                       VETOR DE RESET                            *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

	ORG	0x00			;ENDERE�O INICIAL DE PROCESSAMENTO
	GOTO	INICIO
	
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                    IN�CIO DA INTERRUP��O                        *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; ENDERE�O DE DESVIO DAS INTERRUP��ES. A PRIMEIRA TAREFA � SALVAR OS
; VALORES DE "W" E "STATUS" PARA RECUPERA��O FUTURA

	ORG	0x04			;ENDERE�O INICIAL DA INTERRUP��O
	MOVWF	W_TEMP		;COPIA W PARA W_TEMP
	SWAPF	STATUS,W
	MOVWF	STATUS_TEMP	;COPIA STATUS PARA STATUS_TEMP

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                    ROTINA DE INTERRUP��O                        *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; AQUI SER�O ESCRITAS AS ROTINAS DE RECONHECIMENTO E TRATAMENTO DAS
; INTERRUP��ES

	BTFSC	GPIO,GP1    ;O QUE � LIDO � DIRETAMENTE ENVIADO
	GOTO	SETA
	
	BCF	STATUS,C
	GOTO	FIM
SETA          
	BSF	STATUS,C
FIM
	RLF	AUX1	    ; GUARDA O VALOR ENVIADO DO MASTER
	DECFSZ	COUNTER	    
	GOTO	CONTINUA
	BSF	FLAG_0	    ; FLAG_0 = 1, O SLAVE ESPERA NOVAMENTE
CONTINUA
	;CLRF	TMR1L
	;CLRF	TMR1H
	BCF	PIR1,TMR1IF
	BCF	INTCON,INTF
	
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                 ROTINA DE SA�DA DA INTERRUP��O                  *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; OS VALORES DE "W" E "STATUS" DEVEM SER RECUPERADOS ANTES DE 
; RETORNAR DA INTERRUP��O

SAI_INT
	SWAPF	STATUS_TEMP,W
	MOVWF	STATUS		;MOVE STATUS_TEMP PARA STATUS
	SWAPF	W_TEMP,F
	SWAPF	W_TEMP,W	;MOVE W_TEMP PARA W
	RETFIE

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*	            	 ROTINAS E SUBROTINAS                      *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; CADA ROTINA OU SUBROTINA DEVE POSSUIR A DESCRI��O DE FUNCIONAMENTO
; E UM NOME COERENTE �S SUAS FUN��ES.

ENVIA			; ************ SUBROTINA 1 *******************
	RLF	DADO	    ; RECEBE TODOS OS VALORES PARA SEREM ENVIADOS
	BTFSC	STATUS,C    ; BASTA ATUALIZAR DADO 
	GOTO	SETA1
	BCF	GPIO,GP0
	GOTO	FIM_ENVIA
SETA1
	BSF	GPIO,GP0
	
FIM_ENVIA
	BSF	GPIO,GP4	; PULSO DO SLAVE PARA O SHIFT-REGISTER 
	BCF	GPIO,GP4	;
	DECFSZ	COUNTER
	GOTO	ENVIA
	
	BSF	GPIO,GP5	; PULSO GERAL DO SLAVE QUE ENVIA TODOS OS 
	BCF	GPIO,GP5	; BITS PARA OS DISPLAYS DE 7 SEG
	MOVLW	.8
	MOVWF	COUNTER
	
	RETURN

; ************************** FUN��O DE VERIFICA��O DE ERRO ***************************
VER_ERRO
	MOVF	AUX3,W
	ADDWF	AUX2		   ; VERIFICAR SE A SOMA PASSOU DE 255
	MOVF	AUX2,W
	
	BTFSC	STATUS,C
	GOTO	ESTOUROU	   ; SOMA PASSOU DE 255	    
				   ; SE N�O PASSOU SHOW DE BOLA 
SUBTRAI
	SUBWF	CHECK_SUM
	BTFSS	STATUS,C
	GOTO	FIM_VER_ERRO
	
	MOVLW	.1
	SUBWF	CHECK_SUM
	BTFSC	STATUS,C
	GOTO	ENCONTREI_ERRO
	GOTO	NAO_DEU_ERRO

ESTOUROU			    ; S� ANALISO O NIBBLE MENOS SIGNIFICATIVO
	BCF	STATUS,C	    ; DESLOCA O NIBBLE MENOS SIGNIFICATIVO
	RLF	AUX2		    ; E FAZ UM SWAPF NO FINAL
	DECFSZ	VAR
	GOTO	ESTOUROU
	
	SWAPF	AUX2,W
	GOTO	SUBTRAI
	
NAO_DEU_ERRO
	BCF	SEM_ERRO
	GOTO	FIM_VER_ERRO
ENCONTREI_ERRO
	BSF	SEM_ERRO
	
FIM_VER_ERRO
	RETURN
	
; ******************************* DELAY PARA IMPRIMIR NOS DISPLAYS **************************
DELAY	
	MOVF	VARH,W
	MOVWF	TMR1H
	MOVF	FLAG,W
	MOVWF	TMR1L
LOOP_DELAY
	BTFSS	PIR1,TMR1IF	;VERIFICA SE HOUVE ESTOURO NA FLAG
	GOTO	LOOP_DELAY
	;BCF	T1CON,0	    ; DESABILITA O TIMER1
	CLRF	TMR1L
	BCF	PIR1,TMR1IF
	RETURN
	
; ******************************* ATUALIZA DADO_0 *******************************
MEU_DADO0
	BCF	STATUS,C
	RLF	DADO
	DECFSZ	VAR
	GOTO	MEU_DADO0
	
	MOVF	ADRS,W	
	IORWF	DADO,W		; 
	MOVWF	DADO	
	MOVLW	.4
	MOVWF	VAR
	BCF	STATUS,C
	RRF	ADRS
	RETURN
	
; ************************* IMPRIME EM TODOS OS DISPLAYS *************************
IMPRIME			;TESTEANDO
	BSF	T1CON,0
	MOVLW	.253
	MOVWF	VARH
	MOVLW	.255
	MOVWF	FLAG

	MOVF	AUX5,W		; NIBBLE MAIS SIGNIFICATIVO DO
	MOVWF	DADO		; BYTE MAIS SIGNIFICATIVO
	CALL	MEU_DADO0
	CALL	ENVIA
	MOVLW	.250
	MOVWF	VARH
	CALL	DELAY
	
	MOVLW	.253
	MOVWF	VARH
	
	MOVF 	AUX3,W		; NIBBLE MENOS SIGNIFICATIVO DO
	MOVWF	DADO		; BYTE MAIS SIGNIFICATIVO
	CALL	MEU_DADO0
	CALL	ENVIA
	CALL	DELAY
	
	MOVF	AUX4,W		; NIBBLE MAIS SIGNIFICATIVO DO
	MOVWF	DADO		; BYTE MENOS SIGNIFICATIVO
	CALL	MEU_DADO0
	CALL	ENVIA
	CALL	DELAY
	
	MOVF	AUX2,W		; NIBBLE MENOS SIGNIFICATIVO DO
	MOVWF	DADO		; BYTE MENOS SIGNIFICATIVO
	CALL	MEU_DADO0
	CALL	ENVIA
	MOVLW	.255
	MOVWF	VARH
	CALL	DELAY

	CLRF	TMR1L
	;CLRF	TMR1H
	BCF	T1CON,0	
	CLRF	FLAG	
	MOVLW	.8
	MOVWF	COUNTER
	MOVLW	.3
	MOVWF	COUNTER2
	MOVLW	.4
	MOVWF	VAR
	MOVLW	B'00001000'
	MOVWF	ADRS
	RETURN
	

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                     INICIO DO PROGRAMA                          *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
	
INICIO
	BANK1				;ALTERA PARA O BANCO 1
	MOVLW	B'00000110'	;CONFIGURA TODAS AS PORTAS DO GPIO (PINOS)
	MOVWF	TRISIO		;COMO SA�DAS
	CLRF	ANSEL 		;DEFINE PORTAS COMO Digital I/O
	MOVLW	B'01000000'
	MOVWF	OPTION_REG	;DEFINE OP��ES DE OPERA��O
	MOVLW	B'00000000'	;INTERRUP��O DE PERIF�RICO HABILITADO
	MOVWF	INTCON		;DEFINE OP��ES DE INTERRUP��ES
	;CALL	0X3FF
	;MOVWF	OSCCAL
	
	BANK0				;RETORNA PARA O BANCO
	MOVLW	B'00000111'	; 011 CONFIGURA��O DO COMPARADOR
	MOVWF	CMCON		;DEFINE O MODO DE OPERA��O DO COMPARADOR ANAL�GICO
	MOVLW	B'00100000'	;PRESCALE DE 1:2
	MOVWF	T1CON
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                     INICIALIZA��O DAS VARI�VEIS                 *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
	MOVLW	.8
	MOVWF	COUNTER		    
	MOVLW	.4
	MOVWF	VAR
	CLRF	GPIO
	MOVLW	B'00000000'
	MOVWF	AUX3	
	MOVWF	AUX2
	MOVWF	AUX4
	MOVWF	AUX5
	MOVLW	.3
	MOVWF	COUNTER2
	CLRF	TMR1L
	MOVLW	B'00001000'
	MOVWF	ADRS

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                     ROTINA PRINCIPAL                            *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
MAIN
	; ------------------ PARTE DE SINCRONIZA��O PRONTA (FUNCIONA) ------------------
	
	MOVLW	.240		    
	MOVWF	TMR0
TESTA
	BTFSS	GPIO,GP2	    ; GP2 EM HIGH POR 40us
	GOTO	MAIN		    ;ENQUANTO GP2, REINICIE O TMR0
	BTFSS	INTCON,T0IF	    ; SE GP2=1 NUM TEMPO SUFICIENTE
	GOTO	TESTA		    ; SE GP2=0, ANTES QUE ESTOURE, � ZERADO O TMR0
	
	MOVLW	B'10010000'	    ; HABILITO INTERRUP��O POR TMR0 TAMB�M
	MOVWF	INTCON
	BCF	FLAG_0		    ; FLAG QUE INDICA SE TODOS OS DADOS FORAM RECEBIDOS
	BSF	T1CON,0
	MOVLW	.250
	MOVWF	TMR1H
	
LOOP				    ; ESPERA A INTERRUP��O DE RECEBIMENTO DOS DADOS
	BTFSC	FLAG_0		    ; PRECISO ENVIAR OS DADOS NO LOOP
	GOTO	GUARDA_BYTE
				    ;TIME-OUT DE 6ms
	BTFSC	PIR1,TMR1IF
	GOTO	DEBUGANDO;DEU_CERTO	    ; CASO D� TIME-OUT EXIBE O QUE J� FOI SALVO NAS VARI�VEIS	
	GOTO	LOOP		    ; SER�O EXIBIDOS OS �LTIMOS VALORES SALVOS NA EEPROM
	
GUARDA_BYTE
	BCF	T1CON,0
	
	MOVLW	.1
	SUBWF	COUNTER2,W
	BTFSS	STATUS,C	    ; C=1 DADO >= W
	GOTO	DEU_CERTO	    ; C=0 DADO < W
	
	MOVLW	.2
	SUBWF	COUNTER2,W
	BTFSS	STATUS,C
	GOTO	TERCEIRO_B_CHEGOU
	
	MOVLW	.3
	SUBWF	COUNTER2,W
	BTFSS	STATUS,C
	GOTO	SEGUNDO_B_CHEGOU
	
	;   -------------- CHEGOU O PRIMEIRO BYTE ---------------
	MOVF	AUX1,W
	MOVWF	AUX3
	MOVWF	AUX5
	SWAPF	AUX5
	GOTO	TESTE
	
SEGUNDO_B_CHEGOU
	MOVF	AUX1,W
	MOVWF	AUX2
	MOVWF	AUX4
	SWAPF	AUX4
	GOTO	TESTE
	
TERCEIRO_B_CHEGOU
	MOVF	AUX1,W
	MOVWF	CHECK_SUM
	CLRF	INTCON
	GOTO	DEU_CERTO
TESTE
	DECFSZ	COUNTER2    
	GOTO	ESPERA_PROXIMO_BYTE
	GOTO	DEU_CERTO
	
ESPERA_PROXIMO_BYTE	
	MOVLW	.8	    ; RENOVA O VALOR DE COUNTER
	MOVWF	COUNTER	    ; AP�S O ENVIO DOS 8 BITS
	BCF	FLAG_0
	BSF	T1CON,0
	CLRF	TMR1L
	MOVLW	.250
	MOVWF	TMR1H
	BCF	PIR1,TMR1IF
	GOTO	LOOP
; *************** FINAL DA PARTE DE SINCRONIZA��O ********************	
	
DEU_CERTO
	
	MOVLW	.8
	MOVWF	COUNTER
	MOVLW	.3
	MOVWF	COUNTER2
	
	MOVF	AUX2,W	    
	MOVWF	AUX1		;SALVA ESTADO ANTERIOR DE AUX2
	CALL	VER_ERRO
	MOVF	AUX1,W
	MOVWF	AUX2
	;********************** SE��O DE ENVIO ( MUDAR A ORDEM DOS NIBBLES DEPOIS ) ********************
	BTFSC	SEM_ERRO    ; SEM_ERRO = 0, ENT�O DEU TUDO CERTO
	GOTO	DEU_RUIM
DEBUGANDO
	CLRF	INTCON
	MOVLW	.4
	MOVWF	VAR
	MOVLW	.8
	MOVWF	COUNTER		    
	CLRF	GPIO
	MOVLW	.3
	MOVWF	COUNTER2
	
	CALL	IMPRIME
;	MOVLW	.4
;	MOVWF	VAR
;	MOVLW	.8
;	MOVWF	COUNTER		    
;	CLRF	GPIO
;	MOVLW	.3
;	MOVWF	COUNTER2
;	CLRF	TMR1L
;	MOVLW	B'00001000'
;	MOVWF	ADRS
	;CLRF	TMR1L
	;GOTO	INICIO
	GOTO	MAIN
	
DEU_RUIM
	
	MOVLW	B'00011111'	; PRINTA ZERO EM TODOS OS DISPLAYS
	MOVWF	DADO		; 
	CALL	ENVIA
	BSF	T1CON,0
	
	MOVLW	.0
	MOVWF	FLAG
	MOVLW	.60
	MOVWF	VARH
	BCF	PIR1,TMR1IF
	CALL	DELAY		; DELAY DE ALERTA POR 200ms
	
	MOVLW	B'00000000'	; DESLIGA TODO MUNDO POR 200ms
	MOVWF	DADO		
	CALL	ENVIA
	CALL	DELAY
	
	CLRF	FLAG
	MOVLW	.4
	MOVWF	VAR
	;CLRF	INTCON
	CLRF	TMR1L
	;CLRF	TMR1H
	BCF	T1CON,0
	MOVLW	B'00001000'
	MOVWF	ADRS
	;GOTO	MAIN	
	CLRF	INTCON
	MOVLW	.4
	MOVWF	VAR
	MOVLW	.8
	MOVWF	COUNTER		    
	CLRF	GPIO
	MOVLW	.3
	MOVWF	COUNTER2
	GOTO	MAIN	

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                       FIM DO PROGRAMA                           *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

	END