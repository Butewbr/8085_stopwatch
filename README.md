# 8085 Stopwatch
Programa feito em Assembly 8085 de um cronômetro.\
Este programa foi feito para uma tarefa da disciplina Organização e Arquitetura de Computadores I. Segue a descrição da tarefa:

## Tarefa 4
Atividade:
1. O cronômetro deverá exibir os dígitos no formato mm:ss, em que mm representam os dígitos de minutos (entre 00 e 59) e ss representam os dígitos de segundos (entre 00 e 59).
2. Os dígitos devero ser exibidos no display de 7-segmentos. A tabela abaixo indica o valor
hexadecimal que deverá estar na porta de saída para representar cada dígito decimal.
    <center>
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
    </center>
3. Utilize as seguintes portas de saída para cada dígito:
    <center>
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
    </center>
4. Funções do cronômetro:
    * Se o cronômetro estiver parado a interrupção TRAP for acionada ento, o cronômetro deverá contar em forma progressiva. Se quando a interrupção TRAP for acionada o cronômetro já estiver funcionando, então o cronômetro deverá parar.
    * Se o cronômetro estiver parado a interrupção RST 7.5 for acionada então, o cronômetro deverá contar em forma regressiva. Se quando a interrupção RST 7.5 for acionada o cronômetro já estiver funcionando, então o cronômetro deverá parar.
    * Quando a interrupção RST 6.5 for acionada o cronômetro deverá substituir os dígitos de segundos pelo valor que estiver na porta de entrada 00h e os dígitos de minutos pelo valor que estiver na porta de entrada 01h.
        * Não é necessário fazer nenhum tipo de consideração caso o valor nas portas de entrada seja inválido.
    * Quando a interrupção RST 5.5 for acionada o cronômetro deverá parar e zerar todos os dígitos.
    * Quando o cronômetro progressivo chegar em 59:59 ou o regressivo chegar em 00:00 fica a critério do programador decidir o que fazer (parar o cronômetro ou recomeçar a contagem).
5. Antes de atualizar o dígito da unidade de segundo, o programa deverá passar por uma sub-rotina que insere um delay de, aproximadamente, 1 ms.
    * Para fins de cálculo, considere um clock com frequência de 2 MHz.

### Sobre Interrupções no 8085
Quando uma interrupção ocorre, o Contador do Programa (PC) é atualizado conforme a tabela:

<center>
<table>
<tr><td><b>Interrupção</b></td><td><b>Endereço</b></td></tr>
<tr>
<td>TRAP</td>
<td>0024H</td>
</tr>
<tr>
<td>RST 5.5</td>
<td>002CH</td>
</tr>
<tr>
<td>RST 6.5</td>
<td>0034H</td>
</tr>
<tr>
<td>RST 7.5</td>
<td>003CH</td>
</tr>
</table>
</center>

Sempre que uma interrupção for executada, o microprocessador desabilita as interrupções por padrão, com exceção da TRAP. Para reabilitar, utiliza-se o comando `EI` (*Enable Interruptions*).

## Cálculo do Delay
### Delay de 1 segundo:
Calculando o período:
$$T=\frac{1}{2\cdot10^{6}}$$
$$x\cdot\frac{1}{2\cdot10^6}=1$$
$$x=2\cdot10^6$$
Ou seja, são necessários 2 milhões de T-states para causar um delay de 1 segundo.\
Usando a subrotina
```assembly
delay:
    MVI H, FFH      ; 7 T-states
delay2:
    MVI L, FFH      ; 7 T-states
delay1:
    NOP             ; 4 T-states
    NOP             ; 4 T-states
    NOP             ; 4 T-states
    NOP             ; 4 T-states
    DCR L           ; 4 T-states
    JNZ delay1      ; 10 / 7 T-states
    DCR H           ; 4 T-states
    JNZ delay2      ; 10 / 7 T-states
```
obtém-se uma quantidade de T-states próxima do objetivo: \
$7+(7+(4+4+4+4+4+10)\cdot255-3+4+10)\cdot255-3=1955344 \text{ T-states}$, o que equivale a 0.977672 segundos.


### Delay de 1 ms
Cálculo de quantos T-states são necessários para causar o *delay* de 1 ms:
$$T=\frac{1}{2\cdot10^6}$$
$$x\cdot\frac{1}{2\cdot10^6}=1\cdot10^{-3}$$
$$x=2\cdot10^3$$
Ou seja, 2000 T-states causam um *delay* de 1 ms para um *clock* de 2 MHz. Calculando a partir da sub-rotina
```assembly
        MVI A, 6EH  ; 7 T-states
mDelay:  
        DCR A       ; 4 T-states
        NOP         ; 4 T-states
        JNZ mDelay  ; 10 ou 7 T-states
        NOP         ; 4 T-states
        NOP         ; 4 T-states
        NOP         ; 4 T-states
        NOP         ; 4 T-states
```
obtém-se:
$$7+[(4+4+10)\cdot110]-3+4+4+4+4=2000\text{ T-states}$$
Que é exatamente 1 ms.
## Cronômetro
Para criar a funcionalidade do cronômetro, foram definidas variáveis para auxiliar na busca dos dígitos do display de 7 segmentos. Usando `.define` no início do programa, foram definidas veriáveis para cada dígito e seu respectivo valor HEX, assim como endereços chave de funcionamento do programa. Os dígitos, então, são salvos entre os endereços A000H e A009H a partir do comando `DB`.
### Segundos


### Minutos
O valor salvo na coordenada 0000H vai ser o algarismo da unidade do minuto. Usando do fato que cada loop do delay termina com o par HL em 0000H, posso salvar essa informação adicionando +1 ao par cada vez que 1 minuto for completado. Assim, podemos acessar o valor através da memória M.