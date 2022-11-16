; bernardo_pandolfi_costa_stopwatch.asm
;
; Title: Stopwatch
;
; Author: Bernardo Pandolfi Costa (19207646)
;
; Date: 30-Nov-2022
;
; Atividade:
;   1. O cronômetro deverá exibir os dígitos no formato mm:ss, em que mm representam os dígitos de minutos (entre 00 e 59) e ss representam os dígitos de segundos (entre 00 e 59).
;   2. Os dígitos deverão ser exibidos no display de 7-segmentos.
;   3. Utilize as seguintes portas de saída para cada dígito:
;       * Unidade de Segundo: 03H
;       * Dezena de Segundo: 02H
;       * Unidade de Minuto: 01H
;       * Dezena de Minuto: 00H
;   4. Funções do cronômetro:
;       * Se o cronômetro estiver parado a interrupção TRAP for acionada então, o cronômetro deverá contar em forma progressiva. Se quando a interrupção TRAP for acionada o cronômetro já estiver funcionando, então o cronômetro deverá parar.
;       * Se o cronômetro estiver parado a interrupção RST 7.5 for acionada então, o cronômetro deverá contar em forma regressiva. Se quando a interrupção RST 7.5 for acionada o cronômetro já estiver funcionando, então o cronômetro deverá parar.
;       * Quando a interrupção RST 6.5 for acionada o cronômetro deverá substituir os dígitos de segundos pelo valor que estiver na porta de entrada 00h e os dígitos de minutos pelo valor que estiver na porta de entrada 01h.
;           * Não é necessário fazer nenhum tipo de consideração caso o valor nas portas de entrada seja inválido.
;       * Quando a interrupção RST 5.5 for acionada o cronômetro deverá parar e zerar todos os dígitos.
;       * Quando o cronômetro progressivo chegar em 59:59 ou o regressivo chegar em 00:00 fica a critério do programador decidir o que fazer (parar o cronômetro ou recomeçar a contagem).
;   5. Antes de atualizar o dígito da unidade de segundo, o programa deverá passar por uma sub-rotina que insere um delay de, aproximadamente, 1 ms.
;       * Para fins de cálculo, considere um clock com frequência de 2 MHz.
; 
; Resumo dos passos:

.define
    EndDigito A000h
    StartDigito A009h
	digit0 77h	        ; Valor hex para o display mostrar o digit 0
	digit1 44h		    ; Valor hex para o display mostrar o digit 1
	digit2 3Eh		    ; Valor hex para o display mostrar o digit 2
	digit3 6Eh		    ; Valor hex para o display mostrar o digit 3
	digit4 4Dh		    ; Valor hex para o display mostrar o digit 4
	digit5 6Bh		    ; Valor hex para o display mostrar o digit 5
	digit6 7Bh		    ; Valor hex para o display mostrar o digit 6
	digit7 46h		    ; Valor hex para o display mostrar o digit 7
	digit8 7Fh		    ; Valor hex para o display mostrar o digit 8
	digit9 4Fh		    ; Valor hex para o display mostrar o digit 9
    delayv F423H        ; valor do delay

.data EndDigito		    ; Salvando os valores hex no endereço indicado
	DB digit0, digit1, digit2, digit3, digit4
	DB digit5, digit6, digit7, digit8, digit9	

.org 0000H
    JMP zerar           ; programa começa colocando 00:00

stdby:
    JMP stdby           ; pula para si mesmo infinitamente

check:
    EI
    LXI H, 0A03H        ; apontamos M para a coordenada 0A03H
    MVI A, 00H          ; A = 0
    CMP M               ; comparamos M com A
    JZ start            ; se M = 0, significa que o cronômetro não estava rodando, então, começamos
    MVI M, 00H          ; se não for zero, o cronômetro estava rodando, então paramos e colocamos M = 0 na coordenada para indicar que a próxima ativação da interrupção TRAP é para começar
    JMP stdby           ; pula para o standby

.org 0024H              ; quando o TRAP for ativado, começar a contagem
    JMP check           ; tive que criar uma label para a checagem ao invés de fazer aqui porque as instruções chegavam até a coordenada 002CH, conflitando com o código do RST 5.5

.org 002CH              ; o programa zera tudo na coordenada 002CH (do RST 5.5) e para
    JMP zerar

.org 003CH              ; programa para o RST 7.5
    JMP check7          ; pulamos para checagem de se o cronômetro está ou não ligado

zerar:
    EI                  ; reabilitar interruptores
    LXI H, 0A03H        ; apontamos M para a coordenada 0A03H
    MVI M, 00H          ; indicamos que o cronômetro parou
    MVI A, 77H          ; colocamos o dígito 0 do display de 7 segmentos
    OUT 00H             ; salvamos o 0 em todos os dígitos do display
    OUT 01H             ; salvamos o 0 em todos os dígitos do display
    OUT 02H             ; salvamos o 0 em todos os dígitos do display
    OUT 03H             ; salvamos o 0 em todos os dígitos do display
    LXI B, EndDigito    ; Par de registradores BC utilizado para o d�gito de unidade
	LXI D, EndDigito	; Par de registradores DE utilizado para o d�gito da dezena
    
    MVI A, 00H
    STA 0000H           ; resetando unidade de minutos
    STA 0001H           ; resetando dezena de minutos
    
    LDA EndDigito
    JMP stdby

delay:
    MVI H, 10H
delay2:
    MVI L, 02H
delay1:
    NOP
    NOP
    NOP
    NOP
    DCR L
    JNZ delay1
    DCR H
    JNZ delay2

segunid:
    LDAX B		        ; colocamos no acumulador o valor na coordenada de B
    CPI 4FH	            ; Comparar com o valor hex para 9
    JZ segdez	        ; Se zero, incrementar o d�gito da dezena
	INX B			    ; Par BC apontar para o pr�ximo digito
	LDAX B		
	OUT 03H		
    JMP delay

segdez:
	LDAX D
	CPI 6BH		        ; Comparar com o valor hex do d�gito 6
	JZ minunid		
    LXI B, EndDigito	; Resetar o endere�o apontado pelo par BC
	LDAX B	
	OUT 03H		
	INX D			    ; Par DE apontar para o pr�ximo d�gito
	LDAX D		
	OUT 02H		
    JMP delay

minunid:
    MOV A, M            ; A = M
    CPI 09H             ; comparamos com 09H
    JZ mindez
    INR M               ; incrementa o que tá em 0000H
    MOV A, M            ; bota o valor de M em A
    LXI H, EndDigito    ; apontamos HL para os dígitos
qtmin:
    INX H               ; caminhamos entre os dígitos de 7 segmentos até chegar no número que precisamos
    DCR A               ; A-1
    JNZ qtmin           ; se for zero, estamos no algarismo certo, senão, continuamos caminhando
    MOV A, M            ; movemos o valor HEX que equivale ao algarismo para o acumulador
    OUT 01H             ; salvamos na porta de saída da unidade do minuto

secres:
    LXI D, EndDigito    ; Resetar o endere�o apontado pelo par DE
	LDAX D		
	OUT 02h
    LXI B, EndDigito
    LDAX B
    OUT 03H
    JMP delay

mindez:
    INX H               ; apontamos HL pra 0001H (onde guardamos o valor das dezenas de minutos)
    MOV A, M            ; A = valor das dezenas
    CPI 05H             ; comparamos com 5 pra ver se chegamos em 60 min
    JZ stdby             ; se M=5, chegamos em 1h
    INR M               ; acrescentamos em 1 o valor das dezenas
    DCX H               ; voltamos ao valor da unidade de minuto
    MVI M, 00H          ; zeramos a unidade dos minutos
    MVI A, 77H          ; A = 00H
    OUT 01H             ; zeramos no display a unidade de minuto
    INX H               ; apontamos HL para 0001H (onde guardaremos o valor das dezenas de minutos)
    MOV A, M            ; movemos a quantidade da dezena de minuto ao acumulador
    LXI H, EndDigito
qtdmin:
    INX H
    DCR A
    JNZ qtdmin
    MOV A, M
    OUT 00H
    JMP secres


start:
    MVI M, 01H          ; sinalizamos que o cronômetro está ligado
    JMP delay

check7:
    EI
    LXI H, 0A03H        ; apontamos M para a coordenada 0A03H
    MVI A, 00H          ; A = 0
    CMP M               ; comparamos M com A
    JZ reverse            ; se M = 0, significa que o cronômetro não estava rodando, então, começamos
    MVI M, 00H          ; se não for zero, o cronômetro estava rodando, então paramos e colocamos M = 0 na coordenada para indicar que a próxima ativação da interrupção TRAP é para começar
    JMP stdby           ; pula para o standby

reverse:
    MVI M, 01H          ; sinalizamos que o cronômetro está ligado
    JMP delay7

delay7:
    MVI H, 10H
delay72:
    MVI L, 70H
delay71:
    NOP
    NOP
    NOP
    NOP
    DCR L
    JNZ delay71
    DCR H
    JNZ delay72

segunid7:
    LDAX B		        ; colocamos no acumulador o valor na coordenada de B
    CPI 77H	            ; Comparar com o valor hex para 0
    JZ segdez7	        ; Se zero, decrementar o d�gito da dezena
	DCX B			    ; Par BC apontar para o  dígito anterior
	LDAX B		
	OUT 03H		
    JMP delay7

segdez7:
	LDAX D
	CPI 77H		        ; Comparar com o valor hex do d�gito 0
	JZ minunid7		
    LXI B, StartDigito	; Resetar o endere�o apontado pelo par BC
	LDAX B	
	OUT 03H		
	DCX D			    ; Par DE apontar para o dígito anterior
	LDAX D		
	OUT 02H		
    JMP delay7

minunid7:
    MOV A, M            ; A = M
    CPI 00H             ; comparamos com 00H
    JZ mindez7
    DCR M               ; decrementa o que tá em 0000H
    MOV A, M            ; bota o valor de M em A
    LXI H, EndDigito    ; apontamos HL para os dígitos
qtmin7:
    INX H               ; caminhamos entre os dígitos de 7 segmentos até chegar no número que precisamos
    DCR A               ; A-1
    JNZ qtmin7          ; se for zero, estamos no algarismo certo, senão, continuamos caminhando
    MOV A, M            ; movemos o valor HEX que equivale ao algarismo para o acumulador
    OUT 01H             ; salvamos na porta de saída da unidade do minuto

secres7:
    LXI D, StartDigito    ; Resetar o endere�o apontado pelo par DE
	LDAX D		
	OUT 02h
    LXI B, StartDigito
    LDAX B
    OUT 03H
    JMP delay7

mindez7:
    INX H               ; apontamos HL pra 0001H (onde guardamos o valor das dezenas de minutos)
    MOV A, M            ; A = valor das dezenas
    CPI 77H             ; comparamos com 0 para ver se chegamos em 0 min
    JZ stdby            ; se M=5, chegamos em 1h
    DCR M               ; decrescemos em 1 o valor das dezenas
    DCX H               ; voltamos ao valor da unidade de minuto
    MVI M, 09H          ; colocamos a unidade dos minutos em 9
    MVI A, 4FH          ; A = 4FH (9 no display)
    OUT 01H             ; zeramos no display a unidade de minuto
    INX H               ; apontamos HL para 0001H (onde guardaremos o valor das dezenas de minutos)
    MOV A, M            ; movemos a quantidade da dezena de minuto ao acumulador
    LXI H, EndDigito
qtdmin7:
    INX H
    DCR A
    JNZ qtdmin7
    MOV A, M
    OUT 00H
    JMP secres7