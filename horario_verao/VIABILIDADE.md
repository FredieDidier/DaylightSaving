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
| tratados | 47,0% | 82,8% |
| controle | 96,4% | 98,0% |

Diferença tripla: **+34 p.p. (EP 1,4)**. O tratamento é real, grande, e
medido por um terceiro que não sabe da pesquisa.

## 3. Blocos de hora no nível estadual: ruído

Com o relógio cortado em blocos fixos (17–20h etc.), as mortes de trânsito
sobem ao entardecer (SIM +9%, p = 0,04), mas o total do dia não se mexe, e o
estudo de eventos por temporada é ruidoso. Blocos fixos misturam a hora que
mudou de luz com horas que não mudaram.

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

**Pendente desta rodada:** `06_imputation.R` (imputação com e sem tendência
pré, bootstrap de estados, B = 299) e `07_inference.R` (wild bootstrap com
B = 9.999, aleatorização e excesso de zeros) estavam rodando ao pausar. Os
resultados ficam em `audit/imputation.rds` e `audit/inference.rds`.

## Leitura

- **A favor:** primeiro estágio enorme e medido de forma independente;
  efeito concentrado exatamente na hora prevista, em duas fontes diferentes
  (SIM e PRF); pergunta com demanda de política (EUA e UE debatendo o regime
  permanente); dados todos públicos.
- **Contra / a resolver:** a queda na hora anterior ao pôr do sol (item 5, mecanismo em aberto); só 23 clusters, o que pede
  wild bootstrap ou permutação; COVID nas temporadas 2020/21–2021/22; o efeito
  no total do dia é zero, então o paper é sobre **realocação de risco para o
  escuro**, e a manhã precisa ser estimada com cuidado para fechar a conta.
- **Ainda não feito:** a varredura de literatura (passo 3). O resultado só
  vale se ninguém tiver publicado exatamente isso.
