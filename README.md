# 8085_stopwatch
Programa feito em Assembly 8085 de um cronômetro.\
Este programa foi feito para uma tarefa da disciplina Organização e Arquitetura de Computadores I. Segue a descrição da tarefa:

## Tarefa 4
Atividade:
1. O cronômetro deverá exibir os dígitos no formato mm:ss, em que mm representam os dígitos de minutos (entre 00 e 59) e ss representam os dígitos de segundos (entre 00 e 59).
2. Os dígitos devero ser exibidos no display de 7-segmentos. A tabela abaixo indica o valor
hexadecimal que deverá estar na porta de saída para representar cada dígito decimal.
    <table>
    <tbody>
    <tr>
    <td>Número Decimal</td>
    <td>0</td>
    <td>1</td>
    <td>2</td>
    <td>3</td>
    <td>4</td>
    <td>5</td>
    <td>6</td>
    <td>7</td>
    <td>8</td>
    <td>9</td>
    <tr>
    <tr>
    <td>Valor Hexadecimal</td>
    <td>77H</td>
    <td>44H</td>
    <td>3EH</td>
    <td>6EH</td>
    <td>4DH</td>
    <td>6BH</td>
    <td>7BH</td>
    <td>46H</td>
    <td>7FH</td>
    <td>4FH</td>
    <tr>
    </tbody>
    </table>
3. Utilize as seguintes portas de saída para cada dígito:
    <table>
    <tr>
    <td>Dígito</td>
    <td>Porta de Saída</td>
    </tr>
    <tr>
    <td>Unidade de Segundo</td> <td>03H</td>
    </tr>
    <tr>
    <td>Dezena de Segundo</td> <td>02H</td>
    </tr>
    <tr>
    <td>Unidade de Minuto</td> <td>01H</td>
    </tr>
    <tr>
    <td>Dezena de Minuto</td> <td>00H</td>
    </tr>
    </table>
4. Funções do cronômetro:
    * Se o cronômetro estiver parado a interrupção TRAP for acionada ento, o cronômetro deverá contar em forma progressiva. Se quando a interrupção TRAP for acionada o cronômetro já estiver funcionando, então o cronômetro deverá parar.
    * Se o cronômetro estiver parado a interrupção RST 7.5 for acionada então, o cronômetro deverá contar em forma regressiva. Se quando a interrupção RST 7.5 for acionada o cronômetro já estiver funcionando, então o cronômetro deverá parar.
    * Quando a interrupção RST 6.5 for acionada o cronômetro deverá substituir os dígitos de segundos pelo valor que estiver na porta de entrada 00h e os dígitos de minutos pelo valor que estiver na porta de entrada 01h.
        * Não é necessário fazer nenhum tipo de consideração caso o valor nas portas de entrada seja inválido.
    * Quando a interrupção RST 5.5 for acionada o cronômetro deverá parar e zerar todos os dígitos.
    * Quando o cronômetro progressivo chegar em 59:59 ou o regressivo chegar em 00:00 fica a critério do programador decidir o que fazer (parar o cronômetro ou recomeçar a contagem).

## Resumo dos passos: