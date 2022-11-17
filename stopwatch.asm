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
    EndDigito A000H
    StartDigito A009H
    DigitoCinco A005H
	digit0 77H	        ; Valor hex para o display mostrar o digit 0
	digit1 44H		    ; Valor hex para o display mostrar o digit 1
	digit2 3EH		    ; Valor hex para o display mostrar o digit 2
	digit3 6EH		    ; Valor hex para o display mostrar o digit 3
	digit4 4DH		    ; Valor hex para o display mostrar o digit 4
	digit5 6BH		    ; Valor hex para o display mostrar o digit 5
	digit6 7BH		    ; Valor hex para o display mostrar o digit 6
	digit7 46H		    ; Valor hex para o display mostrar o digit 7
	digit8 7FH		    ; Valor hex para o display mostrar o digit 8
	digit9 4FH		    ; Valor hex para o display mostrar o digit 9

.data EndDigito		    ; Salvando os valores hex no endereço indicado
	DB digit0, digit1, digit2, digit3, digit4
	DB digit5, digit6, digit7, digit8, digit9	

.org 0005H
    JMP zerar           ; programa começa colocando 00:00

turnoff:
    LXI H, 0002H        ; apontamos pro sinalizador de on/off
    MVI M, 00H          ; sinalizamos que o cronômetro está desligado
stdby:
    JMP stdby           ; pula para si mesmo infinitamente

check:
    EI
    LXI H, 0002H        ; apontamos M para a coordenada 0002H
    MVI A, 00H          ; A = 0
    CMP M               ; comparamos M com A
    JZ start            ; se M = 0, significa que o cronômetro não estava rodando, então, começamos
    MVI M, 00H          ; se não for zero, o cronômetro estava rodando, então paramos e colocamos M = 0 na coordenada para indicar que a próxima ativação da interrupção TRAP é para começar
    JMP stdby           ; pula para o standby

.org 0024H              ; quando o TRAP for ativado, começar a contagem
    JMP check           ; tive que criar uma label para a checagem ao invés de fazer aqui porque as instruções chegavam até a coordenada 002CH, conflitando com o código do RST 5.5

.org 002CH              ; o programa zera tudo na coordenada 002CH (do RST 5.5) e para
    JMP zerar

.org 0034H              ; o programa lê os valores dos cronômetros na coordenada 0034H (do RST 6.5)
    JMP readUS

.org 003CH              ; programa para o RST 7.5
    JMP check7          ; pulamos para checagem de se o cronômetro está ou não ligado

zerar:
    EI                  ; reabilitar interruptores
    MVI A, digit0       ; colocamos o dígito 0 do display de 7 segmentos
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
    JMP turnoff

delay:
    MVI H, FFH
delay2:
    MVI L, FFH
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
    CPI digit9          ; Comparar com o valor hex para 9
    JZ segdez	        ; Se zero, incrementar o d�gito da dezena
	INX B			    ; Par BC apontar para o pr�ximo digito

    MVI A, 6EH          ; para o delay de 1 ms:
    minidelay:  
    DCR A
    NOP
    JNZ minidelay
    NOP
    NOP
    NOP
    NOP

	LDAX B		
	OUT 03H		
    JMP delay

segdez:
	LDAX D
	CPI digit5	        ; Comparar com o valor hex do d�gito 5
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
    JZ turnoff             ; se M=5, chegamos em 1h
    INR M               ; acrescentamos em 1 o valor das dezenas
    DCX H               ; voltamos ao valor da unidade de minuto
    MVI M, 00H          ; zeramos a unidade dos minutos
    MVI A, digit0       ; A = 00H
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
    LXI H, 0002H        ; apontamos M para a coordenada 0002H
    MVI A, 00H          ; A = 0
    CMP M               ; comparamos M com A
    JZ reverse            ; se M = 0, significa que o cronômetro não estava rodando, então, começamos
    MVI M, 00H          ; se não for zero, o cronômetro estava rodando, então paramos e colocamos M = 0 na coordenada para indicar que a próxima ativação da interrupção TRAP é para começar
    JMP stdby           ; pula para o standby

reverse:
    MVI M, 01H          ; sinalizamos que o cronômetro está ligado
    JMP delay7

delay7:
    MVI H, FFH
delay72:
    MVI L, FFH
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
    CPI digit0          ; Comparar com o valor hex para 0
    JZ segdez7	        ; Se zero, decrementar o d�gito da dezena
	DCX B			    ; Par BC apontar para o  dígito anterior

    MVI A, 6EH          ; para o delay de 1 ms
minidelay7:  
    DCR A
    NOP
    JNZ minidelay7
    NOP
    NOP
    NOP
    NOP

    LDAX B		
	OUT 03H		
    JMP delay7

segdez7:
	LDAX D
	CPI digit0	        ; Comparar com o valor hex do d�gito 0
	JZ minunid7		    ; se for zero decrementar o dígito do minuto
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
    JZ mindez7          ; se for zero decrementamos o dígito da dezena
    DCR M               ; decrementa o que tá em 0000H
    MOV A, M            ; bota o valor de M em A
    LXI H, EndDigito    ; apontamos HL para os dígitos
    CPI 00H             ; checamos se M agora é zero
    JNZ qtmin7          ; se não for, salvamos os dígitos normalmente
    MVI A, digit0       ; se for, colocamos 0 na unidade de minuto
    OUT 01H
    JMP secres7
qtmin7:
    INX H               ; caminhamos entre os dígitos de 7 segmentos até chegar no número que precisamos
    DCR A               ; A-1
    JNZ qtmin7          ; se for zero, estamos no algarismo certo, senão, continuamos caminhando
    MOV A, M            ; movemos o valor HEX que equivale ao algarismo para o acumulador
    OUT 01H             ; salvamos na porta de saída da unidade do minuto

secres7:
    LXI D, DigitoCinco    ; Resetar o endere�o apontado pelo par DE
	LDAX D		
	OUT 02h
    LXI B, StartDigito
    LDAX B
    OUT 03H
    JMP delay7

mindez7:
    INX H               ; apontamos HL pra 0001H (onde guardamos o valor das dezenas de minutos)
    MOV A, M            ; A = valor das dezenas
    CPI 00H             ; comparamos com 0 para ver se chegamos em 0 min
    JZ turnoff          ; se M=0, chegamos em 00:00
    DCR M               ; decrescemos em 1 o valor das dezenas
    DCX H               ; voltamos ao valor da unidade de minuto
    MVI M, 09H          ; colocamos a unidade dos minutos em 9
    MVI A, digit9       ; A = 4FH (9 no display)
    OUT 01H             ; salvamos no display a unidade de minuto
    INX H               ; apontamos HL para 0001H (onde guardaremos o valor das dezenas de minutos)
    MOV A, M            ; botamos o valor de M em A
    LXI H, EndDigito    ; apontamos HL para os dígitos
    CPI 00H             ; checamos se M agora é zero
    JNZ qtdmin7         ; se não for, salvamos os dígitos normalmente
    MVI A, digit0       ; se for, colocamos 0 na unidade de minuto
    OUT 00H
    JMP secres7         ; voltamos ao loop
qtdmin7:
    INX H
    DCR A
    JNZ qtdmin7
    MOV A, M
    OUT 00H
    JMP secres7

readUS:
    EI
    IN 00H              ; lemos o que foi salvo na porta de entrada 00H
    ANI 0FH             ; fazendo AND 0FH, salvamos no acumulador apenas o algarismo das unidades
    CPI 00H             ; comparamos com 00H
    JZ uS0              ; se for 0 salvamos 0
    LXI B, EndDigito    ; apontamos BC para o dígito 0
find_unitS:
    INX B               ; vamos ao próximo dígito HEX
    DCR A               ; decrementamos o acumulador
    JNZ find_unitS       ; se não for zero, ainda temos que caminhar
    LDAX B              ; salvamos no acumulador o valor HEX do número dado
    OUT 03H

readDS:
    IN 00H              ; lemos o que foi salvo na porta de entrada 00H
    ANI F0H             ; fazendo AND F0H, salvamos no acumulador apenas o algarismo das dezenas
    RAR                 ; rotacionamos pra direita o acumulador 4x pra ter o número certo do algarismo
    RAR
    RAR
    RAR
    CPI 00H
    JZ dS0
    LXI D, EndDigito    ; apontamos BC para o dígito 0
find_dezS:
    INX D               ; vamos ao próximo dígito HEX
    DCR A               ; decrementamos o acumulador
    JNZ find_dezS       ; se não for zero, ainda temos que caminhar
    LDAX D              ; salvamos no acumulador o valor HEX do número dado
    OUT 02H

readUM:    
    IN 01H              ; lemos o que foi salvo na porta de entrada 01H
    ANI 0FH             ; fazendo AND 0FH, salvamos no acumulador apenas o algarismo das unidades
    LXI H, 0000H        ; direcionamos M para 0000H
    MOV M, A            ; salvamos na memória o valor da unidade do minuto
    CPI 00H             ; comparamos com 00H
    JZ uM0              ; se for 0, zerar no display
    LXI H, EndDigito    ; apontamos M para os dígitos HEX
find_unitM:
    INX H               ; caminhamos entre os dígitos de 7 segmentos até chegar no número que precisamos
    DCR A               ; A-1
    JNZ find_unitM          ; se for zero, estamos no algarismo certo, senão, continuamos caminhando
    MOV A, M            ; movemos o valor HEX que equivale ao algarismo para o acumulador
    OUT 01H             ; salvamos na porta de saída da unidade do minuto

readDM:
    IN 01H              ; lemos o que foi salvo na porta de entrada 01H
    ANI F0H             ; fazendo AND F0H, salvamos no acumulador apenas o algarismo das dezenas
    RAR                 ; rotacionamos pra direita o acumulador 4x pra ter o número certo do algarismo
    RAR
    RAR
    RAR
    LXI H, 0001H        ; direcionamos M para 0001H
    MOV M, A            ; salvamos na memória o valor da dezena do minuto
    CPI 00H             ; comparamos com 00H
    JZ dM0              ; zeramos o display
    LXI H, EndDigito
find_dezM:
    INX H               ; caminhamos entre os dígitos de 7 segmentos até chegar no número que precisamos
    DCR A               ; A-1
    JNZ find_dezM          ; se for zero, estamos no algarismo certo, senão, continuamos caminhando
    MOV A, M            ; movemos o valor HEX que equivale ao algarismo para o acumulador
    OUT 00H             ; salvamos na porta de saída da unidade do minuto
    JMP turnoff
    
uS0:
    LXI B, EndDigito
    LDAX B
    OUT 03H
    JMP readDS

dS0:
    LXI D, EndDigito
    LDAX D
    OUT 02H
    JMP readUM

uM0:
    MVI A, 77H
    OUT 01H
    JMP readDM

dM0:
    MVI A, 77H
    OUT 00H
    JMP turnoff