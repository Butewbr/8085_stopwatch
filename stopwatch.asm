; stopwatch.asm
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

.define
    EndDigito A000H     ; definir endereço do valor HEX para 0
    StartDigito A009H   ; definir o endereço do valor HEX para 9
    DigitoCinco A005H   ; definir o endereço do valor HEX para 5
	digit0 77H	        ; valor HEX do algarismo 0 no display
	digit1 44H		    ; valor HEX do algarismo 1 no display
	digit2 3EH		    ; valor HEX do algarismo 2 no display
	digit3 6EH		    ; valor HEX do algarismo 3 no display
	digit4 4DH		    ; valor HEX do algarismo 4 no display
	digit5 6BH		    ; valor HEX do algarismo 5 no display
	digit6 7BH		    ; valor HEX do algarismo 6 no display
	digit7 46H		    ; valor HEX do algarismo 7 no display
	digit8 7FH		    ; valor HEX do algarismo 8 no display
	digit9 4FH		    ; valor HEX do algarismo 9 no display

.data EndDigito		    ; salvamos os endereços com seus respectivos algarismos
	DB digit0, digit1, digit2, digit3, digit4
	DB digit5, digit6, digit7, digit8, digit9	

.org 0005H              ; programa começa em 0005H
    JMP zerar           ; coloca 00:00 no display

turnoff:                ; sub-rotina de parada
    LXI H, 0002H        ; apontamos pro sinalizador de on/off
    MVI M, 00H          ; sinalizamos que o cronômetro está desligado
stdby:                  ; sub-rotina de loop infinito
    JMP stdby           ; pula para si mesmo infinitamente

check:                  ; sub-rotina de checagem se o temporizador estava ou não rodando
    EI                  ; reabilitamos as interrupções
    LXI H, 0002H        ; apontamos M para a coordenada 0002H
    MVI A, 00H          ; zeramos o acumulador
    CMP M               ; comparamos M com A
    JZ start            ; se M = 0, significa que o cronômetro não estava rodando, então, iniciamos ele
    MVI M, 00H          ; se não for zero, o cronômetro estava rodando, então paramos e colocamos M = 0 na coordenada para indicar que a próxima ativação da interrupção TRAP é para começar
    JMP stdby           ; pula para o standby

.org 0024H              ; quando o TRAP for ativado, começar a contagem progressiva ou parar o relógio
    JMP check           ; pula para a checagem de rodando/desligado

.org 002CH              ; o programa zera tudo na coordenada 002CH (do RST 5.5) e para
    JMP zerar           ; saltamos para a sub-rotina de zerar

.org 0034H              ; o programa lê os valores dos cronômetros na coordenada 0034H (do RST 6.5)
    JMP readUS          ; saltamos para a sub-rotina de leitura

.org 003CH              ; programa para o RST 7.5
    JMP check7          ; pulamos para checagem de se o cronômetro está ou não ligado

zerar:                  ; subtrotina para zerar o display
    EI                  ; reabilitar interruptores
    MVI A, digit0       ; colocamos o dígito 0 do display de 7 segmentos
    OUT 00H             ; salvamos o 0 em todos os dígitos do display
    OUT 01H             ; salvamos o 0 em todos os dígitos do display
    OUT 02H             ; salvamos o 0 em todos os dígitos do display
    OUT 03H             ; salvamos o 0 em todos os dígitos do display
    LXI B, EndDigito    ; o par de registradores BC é utilizado para o dígito da unidade
	LXI D, EndDigito	; o par de registradores DE é utilizado para o dígito da dezena
    
    MVI A, 00H          ; zeramos o acumulador
    STA 0000H           ; resetando unidade de minutos
    STA 0001H           ; resetando dezena de minutos
    
    JMP turnoff         ; desligamos o cronômetro

delay:                  ; sub-rotina de delay de 1 s
    MVI H, FFH          ; H=FFH
delay2:
    MVI L, FFH          ; L=FFH
delay1:
    NOP                 ; delay
    NOP                 ; delay
    NOP                 ; delay
    NOP                 ; delay
    DCR L               ; L-1
    JNZ delay1          ; se L não for zero repetimos o processo
    DCR H               ; se L=0, fazemos H-1 e reiniciamos o loop do L
    JNZ delay2          ; se H=0 terminamos o delay de 1 s

segunid:                ; sub-rotina de aumento da unidade de segundo (segunid = Segundo Unidade)
    LDAX B		        ; colocamos no acumulador o valor na coordenada de B
    CPI digit9          ; comparamos com o dígito 9 do display
    JZ segdez	        ; se a comparação der 0 (os dois forem iguais), precisamos incrementar a dezena
	INX B			    ; se não for 9, incrementamos em 1 a unidade

    MVI A, 6EH          ; para o delay de 1 ms, A=6EH
minidelay:              ; sub-rotina de delay de 1 ms
    DCR A               ; A-1
    NOP                 ; delay
    JNZ minidelay       ; se A-1 não zerar, repetimos o processo
    NOP                 ; delay
    NOP                 ; delay
    NOP                 ; delay
    NOP                 ; delay

	LDAX B		        ; depois do delay de 1 ms, lemos o novo valor da unidade
	OUT 03H		        ; salvamos no display
    JMP delay           ; retornamos ao delay de 1 s

segdez:                 ; sub-rotina de aumento da dezena de segundo (segdez = Segundo Dezena)
	LDAX D              ; colocamos no acumulador o valor apontado por DE
	CPI digit5	        ; comparamos com o dígito máximo 5
	JZ minunid		    ; se for 5, temos que incrementar a unidade de minuto
    LXI B, EndDigito	; resetamos o contador de dezena de segundo
	LDAX B	            ; colocamos o dígito 0 no acumulador
	OUT 03H		        ; salvamos no display
	INX D			    ; par DE aponta para o próximo dígito da dezena de segundo
	LDAX D		        ; lemos o dígito da dezena
	OUT 02H		        ; salvamos no display
    JMP delay           ; retornamos ao delay de 1 s

minunid:                ; sub-rotina de aumento de unidade de minuto (minunid = Minuto Unidade)
    MOV A, M            ; A = M
    CPI 09H             ; comparamos com 09H
    JZ mindez           ; se for 9, precismamos incrementar a dezena de minuto
    INR M               ; incrementa o que tá em 0000H
    MOV A, M            ; bota o valor de M em A
    LXI H, EndDigito    ; apontamos HL para os dígitos
qtmin:                  ; sub-rotina para descobrirmos a quantidade de minutos que estamos (qtmin = Quantidade de Minutos)
    INX H               ; caminhamos entre os dígitos de 7 segmentos até chegar no número que precisamos
    DCR A               ; A-1
    JNZ qtmin           ; se for zero, estamos no algarismo certo, senão, continuamos caminhando
    MOV A, M            ; movemos o valor HEX que equivale ao algarismo para o acumulador
    OUT 01H             ; salvamos na porta de saída da unidade do minuto

secres:                 ; subrotina para zerar os segundos (secres = Seconds Reset)
    LXI D, EndDigito    ; resetamos o par DE para apontar ao dígito 0
	LDAX D		        ; lemos o valor de DE
	OUT 02h             ; salvamos no display
    LXI B, EndDigito    ; resetamos o par BC para apontar ao dígito 0
    LDAX B              ; lemos o valor de BC
    OUT 03H             ; salvamos no display
    JMP delay           ; retornamos ao delay

mindez:                 ; sub-rotina de aumento da dezena de minuto (mindez = Minuto Dezena)
    INX H               ; apontamos HL pra 0001H (onde guardamos o valor das dezenas de minutos)
    MOV A, M            ; A = valor das dezenas
    CPI 05H             ; comparamos com 5 pra ver se chegamos em 60 min
    JZ turnoff          ; se M=5, chegamos em 1h
    INR M               ; acrescentamos em 1 o valor das dezenas
    DCX H               ; voltamos ao valor da unidade de minuto
    MVI M, 00H          ; zeramos a unidade dos minutos
    MVI A, digit0       ; A = 00H
    OUT 01H             ; zeramos no display a unidade de minuto
    INX H               ; apontamos HL para 0001H (onde guardaremos o valor das dezenas de minutos)
    MOV A, M            ; movemos a quantidade da dezena de minuto ao acumulador
    LXI H, EndDigito    ; apontamos HL para os dígitos HEX do display
qtdmin:                 ; sub-rotina para descobrirmos a quantidade de dezenas minutos que estamos (qtdmin = Quantidade de Dezenas de Minutos)
    INX H               ; caminhamos entre os dígitos de 7 segmentos até chegar no número que precisamos
    DCR A               ; A-1
    JNZ qtdmin          ; se for zero estamos no algarismo certo, senão, continuamos caminhando
    MOV A, M            ; movemos o valor HEX que equivale ao algarismo para o acumulador
    OUT 00H             ; salvamos na porta de saída da dezena do minuto
    JMP secres          ; resetamos os segundos


start:                  ; sub-rotina de começar contagem
    MVI M, 01H          ; sinalizamos que o cronômetro está ligado
    JMP delay           ; pula para o delay de 1 s

check7:                 ; as labels que possuem 7 na nomeação representam os comandos de contagem reversa, ligados ao interruptor 7.5
    EI                  ; reabilitamos os interruptores
    LXI H, 0002H        ; apontamos M para a coordenada 0002H
    MVI A, 00H          ; A = 0
    CMP M               ; comparamos M com A
    JZ reverse            ; se M = 0, significa que o cronômetro não estava rodando, então, começamos
    MVI M, 00H          ; se não for zero, o cronômetro estava rodando, então paramos e colocamos M = 0 na coordenada para indicar que a próxima ativação da interrupção TRAP é para começar
    JMP stdby           ; pula para o standby

reverse:
    MVI M, 01H          ; sinalizamos que o cronômetro está ligado
    JMP delay7          ; pulamos para o delay de 1 s do loop reverso

delay7:                 ; sub-rotina de delay de 1 s
    MVI H, FFH          ; H=FFH
delay72:
    MVI L, FFH          ; L=FFH
delay71:
    NOP                 ; delay
    NOP                 ; delay
    NOP                 ; delay
    NOP                 ; delay
    DCR L               ; L-1
    JNZ delay71         ; se L não for zero repetimos o processo
    DCR H               ; se L=0, fazemos H-1 e reiniciamos o loop do L
    JNZ delay72         ; se H=0 terminamos o delay de 1 s

segunid7:
    LDAX B		        ; colocamos no acumulador o valor na coordenada de B
    CPI digit0          ; comparamos com o dígito HEX 0
    JZ segdez7	        ; se for zero, precisamos decrementar da dezena
	DCX B			    ; se não for zero, apontamos BC para o dígito anterior

    MVI A, 6EH          ; para o delay de 1 ms
minidelay7:  
    DCR A               ; A-1
    NOP                 ; delay
    JNZ minidelay7      ; se A não zerar, repetimos o processo
    NOP                 ; delay
    NOP                 ; delay
    NOP                 ; delay
    NOP                 ; delay

    LDAX B		        ; lemos o valor apontado por BC
	OUT 03H		        ; salvamos na unidade de segundo
    JMP delay7          ; retornamos ao delay de 1 s

segdez7:
	LDAX D              ; lemos o valor apontado por DE
	CPI digit0	        ; comparamos com o dígito HEX 0
	JZ minunid7		    ; se for zero decrementar o dígito do minuto
    LXI B, StartDigito	; resetamos as unidades, apontando para o dígito 9
	LDAX B	            ; lemos o dígito 9
	OUT 03H		        ; salvamos no display
	DCX D			    ; fazemos o par DE apontar ao dígito anterior
	LDAX D		        ; lemos o valor
	OUT 02H		        ; salvamos no display
    JMP delay7          ; retornamos ao loop

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
    OUT 01H             ; salvamos no display
    JMP secres7         ; resetamos os segundos
qtmin7:
    INX H               ; caminhamos entre os dígitos de 7 segmentos até chegar no número que precisamos
    DCR A               ; A-1
    JNZ qtmin7          ; se for zero, estamos no algarismo certo, senão, continuamos caminhando
    MOV A, M            ; movemos o valor HEX que equivale ao algarismo para o acumulador
    OUT 01H             ; salvamos na porta de saída da unidade do minuto

secres7:
    LXI D, DigitoCinco  ; apontamos o par DE ao dígito 5
	LDAX D		        ; lemos o dígito apontado por DE
	OUT 02h             ; salvamos na dezena de segundos
    LXI B, StartDigito  ; apontamos BC para o dígito 9
    LDAX B              ; lemos o dígito apontado por BC
    OUT 03H             ; salvamos na unidade de segundos
    JMP delay7          ; retornamos ao delay

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
    OUT 00H             ; salvamos no display
    JMP secres7         ; voltamos ao loop
qtdmin7:
    INX H               ; caminhamos entre os dígitos de 7 segmentos até chegar no número que precisamos
    DCR A               ; A-1
    JNZ qtdmin7         ; se for zero estamos no algarismo certo, senão, continuamos caminhando
    MOV A, M            ; movemos o valor HEX que equivale ao algarismo para o acumulador
    OUT 00H             ; salvamos na porta de saída da dezena do minuto
    JMP secres7         ; resetamos os segundos

readUS:                 ; sub-rotina de leitura da unidade de segundos
    EI                  ; reabilitamos os interruptores
    IN 00H              ; lemos o que foi salvo na porta de entrada 00H
    ANI 0FH             ; fazendo AND 0FH, salvamos no acumulador apenas o algarismo das unidades
    CPI 00H             ; comparamos com 00H
    JZ uS0              ; se for 0, salvamos 0
    LXI B, EndDigito    ; apontamos BC para o dígito 0
find_unitS:
    INX B               ; vamos ao próximo dígito HEX
    DCR A               ; decrementamos o acumulador
    JNZ find_unitS      ; se não for zero, ainda temos que caminhar
    LDAX B              ; salvamos no acumulador o valor HEX do número dado
    OUT 03H             ; salvamos no display

readDS:                 ; sub-rotina de leitura da dezena de segundos
    IN 00H              ; lemos o que foi salvo na porta de entrada 00H
    ANI F0H             ; fazendo AND F0H, salvamos no acumulador apenas o algarismo das dezenas
    RAR                 ; rotacionamos pra direita o acumulador 4x pra ter o número certo do algarismo
    RAR
    RAR
    RAR
    CPI 00H             ; comparamos com 0
    JZ dS0              ; se for 0, salvamos 0
    LXI D, EndDigito    ; apontamos BC para o dígito 0
find_dezS:
    INX D               ; vamos ao próximo dígito HEX
    DCR A               ; decrementamos o acumulador
    JNZ find_dezS       ; se não for zero, ainda temos que caminhar
    LDAX D              ; salvamos no acumulador o valor HEX do número dado
    OUT 02H             ; salvamos no display

readUM:                 ; sub-rotina de leitura de unidade de minuto
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
    JNZ find_unitM      ; se for zero, estamos no algarismo certo, senão, continuamos caminhando
    MOV A, M            ; movemos o valor HEX que equivale ao algarismo para o acumulador
    OUT 01H             ; salvamos na porta de saída da unidade do minuto

readDM:                 ; sub-rotina de leitura da dezena de minuto
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
    JNZ find_dezM       ; se for zero, estamos no algarismo certo, senão, continuamos caminhando
    MOV A, M            ; movemos o valor HEX que equivale ao algarismo para o acumulador
    OUT 00H             ; salvamos na porta de saída da unidade do minuto
    JMP turnoff         ; desligamos o contador
    
uS0:                    ; unidade de segundo = 0
    LXI B, EndDigito    ; redirecionamos BC para o dígito 0
    LDAX B              ; lemos o valor de BC
    OUT 03H             ; salvamos no display
    JMP readDS          ; voltamos para ler a dezena de segundo

dS0:                    ; dezena de segundo = 0
    LXI D, EndDigito    ; redirecionamos DE para o dígito 0
    LDAX D              ; lemos o valor de DE
    OUT 02H             ; salvamos no display
    JMP readUM          ; voltamos para ler a unidade de minuto

uM0:                    ; unidade de minuto = 0
    MVI A, digit0       ; A=77H (referente ao dígito 0 no display)
    OUT 01H             ; salvamos no display
    JMP readDM          ; voltamos para ler a dezena de minuto

dM0:                    ; dezena de minuto = 0
    MVI A, digit0       ; A=77H (referente ao dígito 0 no display)
    OUT 00H             ; salvamos no display
    JMP turnoff         ; desligamos o contador