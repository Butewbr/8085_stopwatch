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
; Resumo dos passos: