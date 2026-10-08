# Viabilidade — 08/10/2026

Pergunta: o projeto tem futuro? **Resposta provisória: sim, ancorada no SIM.** O alerta de registro
da hora (item 5) foi descartado; resta um quebra-cabeça de mecanismo.

Scripts, na ordem: `build/02_download_prf.R`, `build/03_clean_prf.R`,
`build/04_municipal_geo.R`, `analysis/code/01_viability.R`,
`02_sunset_design.R`, `03_switched_hour_event_study.R`.
Figuras: `analysis/output/graphs/fig01…fig03`. Números: `Dropbox/.../build/audit/*.rds`.

## 1. PRF baixada e limpa

- 19 arquivos (2007–2025), 2,19 milhões de acidentes. A hora está presente em
  todos, o município casa com o IBGE em 99,7% dos casos, e há coordenadas desde 2017.
- **Quebra de série:** o número de acidentes cai de ~190 mil por ano (2011) para
  ~65 mil (2018). A queda está quase toda nos acidentes **sem vítima**
  (120 mil em 2011 → 11 mil em 2019); os com feridos (49–65 mil) e os fatais
  ficam estáveis. A causa é a **e-DAT**: desde junho de 2015, acidente sem vítima
  pode ser declarado pela internet e sai da base da PRF. Antes disso ela já
  funcionava no Sul, no Sudeste, no CE e no DF, quase todo o grupo tratado,
  então a quebra é diferencial entre os grupos. **Usar mortes e acidentes com
  vítima, nunca a contagem total.**

## 2. Primeiro estágio: a abolição escureceu a noite (fortíssimo)

A PRF anota a fase do dia de cada acidente. Às 18–19h do relógio, na janela de
verão, a parcela anotada como anoitecer ou plena noite foi:

| | antes de 2019 | depois de 2019 |
|---|--:|--:|
| tratados | 47,2% | 82,8% |
| controle | 96,3% | 98,0% |

Diferença tripla: **+33,7 p.p. (EP 1,5)** (rodada com o SIM próprio,
2008/09–2023/24; antes 47,0 / 96,4 e +34 (1,4)). O tratamento é real, grande, e
medido por um terceiro que não sabe da pesquisa.

## 3. Blocos de hora no nível estadual: ruído

Com o relógio cortado em blocos fixos (17–20h etc.), as mortes de trânsito
sobem pouco ao entardecer e o total do dia não se mexe; o estudo de eventos por
temporada é ruidoso. Blocos fixos misturam a hora que mudou de luz com horas que
não mudaram.

Rodada vigente (SIM próprio, 2008/09–2023/24, `viability_numbers.rds`), 17–20h:
SIM trânsito +6,5% (p = 0,17; era +9%, p = 0,04 na rodada antiga); PRF mortes
+21% (p = 0,08); PRF com vítima −1,3% (p = 0,69). Dia todo: −0,8%, −6,4%, −0,9%.

**Sinal a examinar, não resultado:** as agressões do SIM (todos os locais,
inclusive hospital, hora do óbito) sobem no dia todo (+4,6%, p = 0,03), às
8–17h (+7,2%, p = 0,007) e às 17–20h (+16,4%, p = 0,003). No desenho afiado
(só óbito na via, hora que trocou de luz) a agressão dá +13,8%, p = 0,39. Um
efeito no nível do dia inteiro não tem a assinatura da luz; antes de qualquer
leitura, ver se é tendência diferencial da violência entre S/SE/CO e N/NE
(estudo de eventos por temporada).

## 4. O desenho afiado: a hora que trocou de luz

Para cada município e dia, calculei o pôr e o nascer do sol em hora padrão
(equações da NOAA, sede municipal). A hora do relógio
**[pôr do sol padrão, +60 min)** era clara com horário de verão e é escura sem
ele; as horas vizinhas têm a mesma luz nos dois regimes. No SIM entram só os
óbitos **na via pública**, porque o óbito no hospital tem a hora da morte e
não a do acidente.

Diferença tripla Poisson, tratado × janela × pós, EP por UF:

| desfecho | hora que escureceu | p | hora anterior | hora seguinte |
|---|--:|--:|--:|--:|
| SIM, mortes de transporte na via (V01–V89) | **+36,6%** | 0,001 | +5,9% | +19,4% |
| PRF, mortes | **+74,3%** | 0,005 | −32,3% | +13,3% |
| PRF, acidentes com vítima | **+23,8%** | <0,001 | −19,9% | +6,6% |
| SIM, agressões na via | +13,8% | 0,39 | −4,8% | +44,2% |

- Pela manhã (a hora que ganhou luz), os sinais são negativos e pequenos
  (−6%, −13%, −15%; só a PRF chega perto da significância, p = 0,055).
- **Placebo no tempo:** fingindo a abolição em cada temporada de 2011/12 a
  2017/18 (só dados pré), nenhuma das 7 estimativas falsas chega perto da
  verdadeira, nos três desfechos de trânsito. Mas com 7 placebos isso é p ≈ 1/8,
  não mais.
- **Ordem de grandeza:** só as mortes na via (SIM) na hora que escureceu eram
  ~110 por temporada nos tratados; +37% dá **~40 mortes a mais por verão**. É
  um limite inferior: exclui quem morre no hospital.

## 5. O alerta, e o teste que o resolveu em parte

Na PRF, a hora **anterior** à que escureceu cai quase tanto quanto a hora
escurecida sobe (−20% e +24% nos acidentes com vítima). Isso parecia um
deslocamento de uma hora por artefato de registro (hora anotada em hora padrão).

**Teste (`analysis/code/04_prf_clock_check.R`):** nos estados tratados, na
mesma janela de verão, tomei a parcela de acidentes que o policial anotou como
anoitecer ou noite, por minuto em relação ao pôr do sol padrão. Se a hora for
legal, a curva do período com horário de verão tem de estar uns 60 minutos à
direita da curva sem horário de verão.

| min. após pôr do sol padrão | sem HV (2019+) | com HV (até 2018) |
|--:|--:|--:|
| −60 | 45% | 11% |
| −30 | 79% | 27% |
| 0 | 97% | 51% |
| +30 | 99% | 82% |
| +60 | 98% | 95% |

O cruzamento de 50% está em −50 min sem HV e em 0 min com HV: um
deslocamento de ~50–60 min. **A PRF anota a hora legal; não é artefato.**

Sobra a pergunta substantiva: por que a última hora antes do pôr do sol, que
também ficou mais escura (os policiais já a anotam como anoitecer em 45–90% dos
casos), teve **menos** acidentes com vítima? Candidatos: o ofuscamento pelo sol
baixo, que antes caía nessa hora do relógio, saiu dela; ou o tráfego da volta
para casa se rearranjou. É algo para investigar, não para esconder.

## 6. Tendências paralelas (`analysis/code/05_pretrends.R`)

Correção feita antes: as mortes de transporte do SIM passaram a ser V01–V89
(antes eram V01–V99, com aquático e aéreo, 2,6% dos casos). Hora faltante entre
as mortes na via: 15–20%, e a diferença tripla nessa parcela é de 0,8 p.p.,
desprezível.

Hora que escureceu (bin 0) e hora anterior (bin −1), em log points (EP):

| desfecho | bin | Wald pré = 0 (p) | tendência pré, por temporada | base | com tendência linear | sem 2020/21–2021/22 |
|---|--:|--:|--:|--:|--:|--:|
| SIM, mortes na via | 0 | 0,54 | +0,8 (2,6) | **31,2 (9,3)** | 33,4 (22,9) | 33,2 (8,7) |
| PRF, mortes | 0 | 0,33 | +3,9 (3,3) | **55,6 (19,7)** | 18,7 (27,3) | 49,3 (25,0) |
| PRF, acidentes com vítima | 0 | <0,001 | +1,0 (0,9) | **21,3 (5,5)** | 9,5 (9,1) | 22,0 (7,1) |
| SIM, mortes na via | −1 | 0,01 | +1,7 (2,4) | 5,8 (10,0) | 0,4 (17,6) | −1,5 (13,3) |
| PRF, mortes | −1 | <0,001 | −0,6 (3,4) | −39,0 (18,1) | −32,4 (29,1) | −43,7 (29,3) |
| PRF, acidentes com vítima | −1 | 0,02 | −1,5 (0,9) | −22,1 (5,5) | −13,5 (7,9) | −25,7 (7,6) |

- **SIM: passa.** Pré-coeficientes conjuntamente nulos, tendência pré plana,
  e o efeito não muda com tendência linear (só o EP cresce) nem sem a COVID.
- **PRF: frágil.** Nos acidentes com vítima, o Wald rejeita (p < 0,001) e a
  tendência linear corta a estimativa à metade (21 → 9,5, n.s.). Nas mortes
  da PRF, a tendência corta de 56 para 19.
- **Atenção à tendência linear no ano todo:** com só 5 temporadas pós e um
  efeito que cresce ao longo delas, a tendência estimada também passa pelo pós
  e absorve parte do efeito. A alternativa mais limpa é extrapolar a tendência
  estimada só no pré. Conta de guardanapo (efeito − inclinação pré × 7,5
  temporadas de distância entre os centros dos períodos): SIM ≈ 25, PRF mortes
  ≈ 27, PRF com vítima ≈ 14. Fazer direito: estimador de imputação (Borusyak,
  Jaravel & Spiess) ou "honest DiD" (Rambachan & Roth).
- **A hora anterior (bin −1) falha nos três.** Ela não é placebo limpo: também
  mudou de luz (passou do meio da tarde para a última hora antes do pôr do sol).

## 7. Rodada de 08/10/2026 (tarde): SIM próprio, 2008/09–2023/24

**Mudanças:** SIM baixado direto do FTP do DATASUS (`build/05_download_sim.R`,
2008–2025; 2025 é preliminar e fica fora). O período passa a ser 2008/09–2023/24:
11 temporadas pré e 5 pós. Funções comuns em `analysis/code/00_utils.R`.

**Bug encontrado e corrigido:** na primeira versão do `make_panel` (00_utils.R),
o argumento tinha o mesmo nome da coluna `outcome`, e o data.table somava todos
os desfechos juntos. Isso apareceu como resultados idênticos entre desfechos e
foi corrigido antes de qualquer número ser lido. Os números abaixo são os
corretos.

**Hora que escureceu (bin 0), Poisson, EP por UF:**

| desfecho | efeito | p | Wald pré (p) | tendência pré | placebo no tempo |
|---|--:|--:|--:|--:|---|
| SIM, mortes na via (V01–V89) | **+34,3%** (29,5 lp, EP 9,0) | 0,001 | 0,18 | −0,5 (2,1) | real 0,30; falsos de −0,06 a 0,06 |
| PRF, mortes | +75,5% (56 lp, EP 21) | 0,007 | 0,44 | +3,3 (2,7) | real 0,56; falsos de 0,09 a 0,35 |
| PRF, acidentes com vítima | +25,8% (23 lp, EP 5,7) | <0,001 | <0,001 | +1,6 (0,7) | real 0,23; falsos de 0,00 a 0,13 |

- Com tendência linear no período inteiro: SIM 39,9 (20,7); PRF mortes 23,0
  (23,0); PRF com vítima 7,0 (8,2). Sem as temporadas da COVID: 31,7; 49,5; 23,6.
- Wild cluster bootstrap (Webb, teste com B = 999, análogo linear), SIM bin 0:
  **p = 0,008**. A rodada completa (B = 9.999, mais a aleatorização dos estados
  tratados e o teste de excesso de zeros) está no `07_inference.R`;
  resultados em `audit/inference.rds`.
- Hora faltante: diferença tripla de 0,7 p.p., desprezível.

**HonestDiD (`08_honestdid.R`), efeito médio pós, referência 2018/19:**

| desfecho | IC convencional | M = 0 (tendência linear extrapolada) | ruptura M | ruptura Mbar |
|---|---|---|--:|--:|
| SIM, mortes na via | [−33, 63] | [28, 99] | 0,02 | 0 |
| PRF, mortes | [−4, 132] | [33, 74] | 0,01 | 0 |
| PRF, acidentes com vítima | [8, 46] | [8, 28] | 0,075 | 0,25 |

Sob extrapolação linear, os três efeitos são positivos. Mas basta uma
curvatura pequena (1–2 lp/temporada²) para o SIM e as mortes da PRF incluírem
zero, e a versão de magnitude relativa rompe em zero. A causa é o ruído: com uma
hora por dia, cada coeficiente anual oscila ±15–30 lp. A referência numa única
temporada (2018/19, alta no SIM) também torna o efeito médio do event study
(14,8) menor que o agrupado (29,5).

**Janela mais larga (`09_wider_window.R`): não ajuda.** SIM: 29,5 → 21,4 → 16,1
lp de [0,60) a [0,120) e a [−60,120); o Wald pré piora (0,18 → 0,008 → <0,001);
o ruído pré cai pouco (16,5 → 13,6); a ruptura M continua em 0,01–0,02. Na PRF o
efeito se dilui (com vítima: 23 → 2). **O sinal está na hora exata; fica a janela [0,60).**

**Próximo passo para o ruído:** uma diferença quádrupla dentro do dia. Painel
UF × dia × hora relativa ao sol, com efeito fixo de UF × dia, que absorve todo
choque diário de tráfego do estado (chuva, feriado, volume); o tratamento passa
a ser bin 0 × tratado × janela × pós.

**Inferência sem assintótica de 23 clusters (`07_inference.R`, `audit/inference.rds`).**
Wild cluster restrito (Webb, B = 9.999) no análogo linear; aleatorização dos 11
estados tratados (999 sorteios) no Poisson; checagem de excesso de zeros.

| desfecho | hora | Poisson (lp) | WCR p | IC 95% WCR (% da base) | aleatorização p | zeros obs. / Poisson | dispersão |
|---|---|--:|--:|---|--:|---|--:|
| SIM, mortes na via | noite, bin 0 | 29,5 | **0,009** | [12, 82] | **0,015** | 88,2 / 87,6% | 1,16 |
| SIM, mortes na via | manhã, bin 0 | −3,2 | 0,61 | [−28, 14] | 0,83 | 92,0 / 91,5% | 1,23 |
| PRF, mortes | noite, bin 0 | 56,2 | **0,002** | [36, 144] | **0,017** | 92,3 / 91,6% | 1,26 |
| PRF, mortes | manhã, bin 0 | −15,0 | 0,019 | [−46, −5] | 0,45 | 93,8 / 92,7% | 1,57 |
| PRF, com vítima | noite, bin 0 | 22,9 | **0,001** | [12, 51] | **0,001** | 65,4 / 65,9% | 0,93 |
| PRF, com vítima | manhã, bin 0 | −15,3 | 0,053 | [−19, 0] | 0,060 | 77,3 / 77,6% | 0,94 |

- **A hora que escureceu passa nos dois testes que não dependem de 23 clusters,
  nos três desfechos.** A aleatorização é a mais exigente (pergunta se outros 11
  estados quaisquer dariam efeito tão grande): 15, 17 e 1 em 999.
- A manhã que ganhou luz: sinais negativos nos três; só a PRF chega perto
  (mortes: WCR p = 0,02, mas aleatorização p = 0,45).
- **Sem excesso de zeros:** a parcela de zeros observada bate com a implicada
  pelo Poisson em todos os casos (diferença < 1 p.p.), e a dispersão é 0,9–1,6.
  Confirma a decisão de não usar zero-inflated nem binomial negativo.

**Imputação (`06_imputation.R`, `audit/imputation.rds`).** Modelo ajustado só
nas observações não tratadas (FE de UF × janela, UF × temporada, semana,
dia da semana); contrafactual previsto para os dias de verão dos tratados após
2019. Bootstrap estratificado de estados, B = 299 (IC percentil).

| desfecho | hora | sem tendência | IC 95% | tendência pré extrapolada | IC 95% | excesso (5 temporadas) |
|---|---|--:|---|--:|---|--:|
| SIM, mortes na via | noite | **+31,8%** | [7, 54] | +37,9% | [−11, 103] | 170 (sem tend.) |
| SIM, mortes na via | manhã | −5,9% | [−24, 15] | +6,6% | [−36, 83] | |
| PRF, mortes | noite | **+63,0%** | [2, 158] | +25,6% | [−24, 108] | 113 |
| PRF, mortes | manhã | −21,6% | [−58, 13] | +58% | [−42, 246] | |
| PRF, com vítima | noite | **+24,4%** | [14, 39] | +9,6% | [−4, 29] | 548 |
| PRF, com vítima | manhã | **−14,5%** | [−29, −1] | +1,3% | [−28, 45] | |

- Sem tendência, a imputação repete o Poisson (SIM +32% contra +34%). O excesso
  no SIM é de **~34 mortes na via por verão** (170 em 5 temporadas), dentro da
  conta de guardanapo do §4.
- **Com a tendência pré aprendida só antes de 2019 e extrapolada:** no SIM o
  ponto **não cai** (38%), só o IC se abre — a tendência pré do SIM é plana, e
  extrapolá-la custa precisão, não efeito. Na PRF o ponto cai à metade ou mais
  (mortes 63 → 26; com vítima 24 → 10) e perde significância: é a mesma
  fragilidade do §6, agora pelo estimador que não deixa a tendência absorver o
  efeito. **O SIM continua sendo o resultado âncora; a PRF corrobora sem a
  tendência e fica ambígua com ela.**
- A manhã da PRF com vítima cai 14,5% sem tendência (IC exclui zero), em linha
  com a quádrupla (§8); com tendência, some.
- Por temporada (SIM, com tendência): 83, 55, 17, 11, 42%. O efeito existe em
  todas as cinco temporadas pós, maior na primeira.
- Execução: o bootstrap roda em paralelo (`DS_CORES`, 5 núcleos, 26 min) com
  tolerância do demeaning de 1e-4 nos sorteios (a estimativa pontual usa a
  padrão; a diferença no ATT é de 1e-5).

## 8. Diferença quádrupla dentro do dia (`10_within_day.R`): não reduz o ruído

**Desenho.** Painel UF × dia × hora relativa ao pôr (ou nascer) do sol padrão,
com FE de UF × dia, que absorve todo choque diário do estado, mais as versões
por hora dos FE da tripla (UF × hora × janela, UF × hora × temporada,
hora × data). Horas de referência, cuja luz não muda: −5 a −3 e +2 a +4 à noite;
−4 a −2 e +2 a +4 de manhã. As horas −2, −1, 0 e +1 (noite) e −1, 0, +1 (manhã)
têm coeficiente próprio. O coeficiente lê a mudança na parcela dos eventos do
estado-dia que cai naquela hora.

**Hora que escureceu (bin 0), log points (EP por UF):**

| desfecho | tripla (§7) | quádrupla | só ref. do dia | só ref. da noite |
|---|--:|--:|--:|--:|
| SIM, mortes na via | 29,5 (9,0) | 28,0 (12,4) | 25,5 (16,6) | 29,2 (12,4) |
| PRF, mortes | 56 (21) | 93 (31) | 102 (47) | 106 (29) |
| PRF, com vítima | 22,9 (5,7) | 31,4 (7,7) | 32,7 (8,2) | 30,4 (9,1) |

O efeito não depende de qual conjunto de horas serve de referência.

- **O EP não cai: sobe.** E o desvio-padrão dos coeficientes pré por temporada
  continua em ~20 lp no SIM (era 16,5). O ruído é de contagem: ~110 mortes por
  temporada naquela hora nos tratados dão ±10–15% só de Poisson, e isso nenhum
  FE tira. O FE de UF × dia ainda descarta os UF-dias sem evento (dois terços
  no SIM).
- **Wald pré rejeita** (estatística ~33–37 com 10 g.l., p ≈ 10⁻⁴ nos três). As
  médias pré ficam abaixo de zero (SIM −11; PRF mortes −12; com vítima −6 lp),
  ou seja, a referência 2018/19 é uma temporada alta. Com 23 clusters, o Wald
  robusto sobre 10 coeficientes tende a rejeitar demais; não ler sozinho.
- **HonestDiD (média pós):** ruptura M = 0,05 (SIM), 0,02 (PRF mortes),
  0,03 (com vítima); Mbar = 0, 0, 0,25. Igual ou pouco melhor que a tripla.
- **Coisas que a quádrupla mostra e valem guardar:**
  - **Hora +1** (a segunda após o pôr do sol padrão, que era crepúsculo com
    horário de verão e virou noite fechada) também sobe: SIM +17,5 (11,7),
    PRF mortes +37 (21), com vítima +15,8 (8,6). O efeito do escuro se espalha
    para a hora seguinte, como a física da luz manda.
  - **Hora −1 na PRF** continua negativa (−13,7, p = 0,05 nos com vítima), mesmo
    comparando dentro do mesmo estado-dia. O quebra-cabeça do §5 não é choque
    diário.
  - **Manhã, PRF com vítima, bin 0: −20,4 (9,7), p = 0,036.** A hora que ganhou
    luz perdeu acidentes, com o tamanho parecido com o ganho da noite (+31). É a
    peça que faltava para fechar a conta da realocação. No SIM a manhã é nula.
- **Avisos da rodada (conferidos em 08/10/2026):**
  - *Demeaning sem convergência:* só 2 dos 21 ajustes, ambos colunas de
    robustez "só referência da noite": SIM manhã e PRF mortes noite. Nenhum é a
    especificação principal nem o estudo de eventos. Reajustados com 30 mil
    iterações (o padrão é 10 mil), os coeficientes e o EP batem até a 3ª casa
    decimal em log points (PRF mortes bin 0: 106,038 nos dois; SIM manhã:
    11,519 nos dois). Inofensivo.
  - *HonestDiD (os outros 43):* "Solution may be inaccurate" do otimizador em
    todos os M da suavidade (SIM e PRF mortes); "CI is open" só em Mbar = 2;
    e um aviso de descontinuação do R. Teste de escala (o FLCI é equivariante:
    resolver com b × 100, V × 100², M × 100 e dividir por 100): limites iguais
    até 0,1 lp. Os limites e as rupturas são confiáveis; só o IC em Mbar = 2
    é mais largo que o reportado (bateu na grade). O `08_honestdid.R` deve
    emitir os mesmos avisos; não conferido, mas o teste de escala vale lá também.
- **Decisão:** a quádrupla vira robustez (e fonte da hora +1 e da manhã), não o
  desenho principal. O principal segue a tripla em [0, 60).
- Figura: `fig05_within_day_event_study` (refeita depois da correção do locale
  em `00_utils.R`; a primeira versão tinha "×" virando "..").
- Aleatorização da quádrupla: desligada por padrão (`DS_RI`), ~35 s por ajuste.

## Leitura

- **A favor:** primeiro estágio enorme e medido de forma independente;
  efeito concentrado exatamente na hora prevista, em duas fontes diferentes
  (SIM e PRF); pergunta com demanda de política (EUA e UE debatendo o regime
  permanente); dados todos públicos.
- **Contra / a resolver:** a queda na hora anterior ao pôr do sol (item 5, mecanismo em aberto); só 23 clusters, o que pede
  wild bootstrap ou permutação; COVID nas temporadas 2020/21–2021/22; o efeito
  no total do dia é zero, então o paper é sobre **realocação de risco para o
  escuro**, e a manhã precisa ser estimada com cuidado para fechar a conta.
- **Literatura:** varredura feita (passo 3) e referências (?) conferidas na
  fonte em 08/10/2026; ver `LITERATURE.md`. Nenhum trabalho usa a abolição de
  2019 para trânsito.
