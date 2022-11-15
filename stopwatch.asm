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
	digit0 77h	    ; Valor hex para o display mostrar o digit 0
	digit1 44h		; Valor hex para o display mostrar o digit 1
	digit2 3Eh		; Valor hex para o display mostrar o digit 2
	digit3 6Eh		; Valor hex para o display mostrar o digit 3
	digit4 4Dh		; Valor hex para o display mostrar o digit 4
	digit5 6Bh		; Valor hex para o display mostrar o digit 5
	digit6 7Bh		; Valor hex para o display mostrar o digit 6
	digit7 46h		; Valor hex para o display mostrar o digit 7
	digit8 7Fh		; Valor hex para o display mostrar o digit 8
	digit9 4Fh		; Valor hex para o display mostrar o digit 9
    delayv F423H    ; valor do delay

.org 002CH              ; o programa zera tudo na coordenada 002CH (do RST 5.5)
    EI              ; reabilitar interruptores
    MVI A, 77H      ; colocamos o dígito 0 do display de 7 segmentos
    OUT 00H         ; salvamos o 0 em todos os dígitos do display
    OUT 01H         ; salvamos o 0 em todos os dígitos do display
    OUT 02H         ; salvamos o 0 em todos os dígitos do display
    OUT 03H         ; salvamos o 0 em todos os dígitos do display
    LXI D, 0000H    ; zeramos o par DE

delay1segundo:
    LXI H, delayv   ; 10 T-states
    NOP             ; 4 T-states
    NOP             ; 4 T-states
    NOP             ; 4 T-states
    NOP             ; 4 T-states
    NOP             ; 4 T-states
    NOP             ; 4 T-states
delay:
    NOP             ; 4 T-states
    NOP             ; 4 T-states
    NOP             ; 4 T-states
    NOP             ; 4 T-states
    DCX H           ; 6 T-states
    JNZ delay        ; 10 / 7 T-states

contagem:
    LDAX B