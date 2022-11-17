# 8085 Stopwatch
Programa feito em Assembly 8085 de um cronômetro.\
Este programa foi feito para uma tarefa da disciplina Organização e Arquitetura de Computadores I. Segue a descrição da tarefa:

## Tarefa 5
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
#### Unidade
Para a contagem da unidade dos segundos, o par de registradores BC foi utilizado. O par apontará para o endereço em que o respectivo dígito HEX do display de 7 segmentos condiz com o valor da unidade do segundo. Por exemplo: se o cronômetro marca 2 segundos na unidade, o par de registradores BC terá o valor A002H, referente ao endereço do dígito HEX 3EH (2 no display).\
A cada passagem no loop, faz-se a comparação do valor da coordenada indicada pelo par BC com o valor 4FH (dígito 9 no display), para verificiar se o valor máximo da unidade foi atingido. Se foi, o programa adiciona +1 à dezena dos segundos e zera o valor da unidade, colocando o valor de BC como A000H.
#### Dezena
A casa da dezena dos segundos seguiu um processo similar à casa das unidades, desta vez, com o par de registradores DE. A diferença é que verifica-se o valor máximo como 6BH (dígito 5 no display). Caso o valor máximo de 5 for atingido e temos que incrementar, passamos para o incremento do minuto. 

### Minutos
Para os minutos, como não haviam registradores sobrando, um método diferente foi abordado. Usando do fato de que cada delay termina com o par HL em 0000H, é possível prontamente acessar os valores deste endereço a partir de M. Assim, 
os valores salvos em 0000H foram usados para indicar o número de minutos. Para a dezena, o endereço 0001H foi usado.\
Pntão, para salvar os dígitos no display, o par HL é redirecionado para A000H (onde estão armazenados os dígitos HEX). Em seguida, é feito um loop com base nos valores salvos em 0000H e 0001H para unidade e dezena respectivamente até que o par HL esteja no algarismo correto. Este, pois, é salvo na respectiva porta de saída. Finalmente, são zerados os valores dos segundos.

## Funcionalidade da TRAP
A funcionalidade TRAP implica que o programa ou pare ou inicie a contagem ascendente. A fim de saber se o cronômetro está ativo ou inativo, sempre que a contagem for iniciada, tanto de forma progressiva quanto regressiva, o valor 01H é salvo no endereço 0002H da memória. Analogamente, quando o sistema é parado, salva-se 00H neste endereço. Sempre que o interruptor TRAP é ativado, então, faz-se uma verificação de qual valor está guardado em 0002H. Com base nisso, o programa ou inicia ou para.
## Funcionalidade 7.5