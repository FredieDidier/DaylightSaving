# Viabilidade — 08/10/2026

> **Rodada vigente: §17 (09/10/2026, depois da auditoria de código).** As
> tabelas de §§2–14 são das rodadas anteriores. Os números da PRF ali estão
> 1–4 lp acima dos atuais; os do SIM, até 0,3 lp acima. Nenhuma conclusão mudou.

Pergunta: o projeto tem futuro? **Resposta provisória: sim, ancorada no SIM.** O alerta de registro
da hora (item 5) foi descartado; resta um quebra-cabeça de mecanismo.

Scripts, na ordem: `build/02_download_prf.R`, `build/03_clean_prf.R`,
`build/04_municipal_geo.R`, `analysis/code/01_viability.R`,
`01_sunset_design.R`, `02_switched_hour_event_study.R`.
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

**Teste (`analysis/code/03_prf_clock_check.R`):** nos estados tratados, na
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

## 6. Tendências paralelas (`analysis/code/04_pretrends.R`)

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
  **p = 0,008**. A rodada completa (B = 9.999, mais a permutação dos estados
  tratados e o teste de excesso de zeros) está no `06_inference.R`;
  resultados em `audit/inference.rds`.
- Hora faltante: diferença tripla de 0,7 p.p., desprezível.

**HonestDiD (`07_honestdid.R`), efeito médio pós, referência 2018/19:**

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

**Janela mais larga (`08_wider_window.R`): não ajuda.** SIM: 29,5 → 21,4 → 16,1
lp de [0,60) a [0,120) e a [−60,120); o Wald pré piora (0,18 → 0,008 → <0,001);
o ruído pré cai pouco (16,5 → 13,6); a ruptura M continua em 0,01–0,02. Na PRF o
efeito se dilui (com vítima: 23 → 2). **O sinal está na hora exata; fica a janela [0,60).**

**Próximo passo para o ruído:** uma diferença quádrupla dentro do dia. Painel
UF × dia × hora relativa ao sol, com efeito fixo de UF × dia, que absorve todo
choque diário de tráfego do estado (chuva, feriado, volume); o tratamento passa
a ser bin 0 × tratado × janela × pós.

**Inferência sem assintótica de 23 clusters (`06_inference.R`, `audit/inference.rds`).**
*Nome (decidido em 09/10/2026):* **permutation inference** (permutação dos
estados tratados), nunca "randomization inference". O horário de verão não foi
sorteado entre estados, e o calendário é fixo e comum a todos (não há datas a
permutar, como na Copa; no tempo só cabem os placebos de temporada do `03`). Nos
scripts e nos `.rds`, os nomes eram `ri_p`, `N_RI` e `DS_RI` até 12/10/2026; desde
então são `perm_p`, `perm_rank`, `n_perm`, `N_PERM` e `DS_PERM` (pedido do Fredie: "RI"
leria como randomization inference), e o p passou a ser (1 + nº)/(1 + N) (§19).
Wild cluster restrito (Webb, B = 9.999) no análogo linear; permutação dos 11
estados tratados (999 sorteios) no Poisson; checagem de excesso de zeros.

| desfecho | hora | Poisson (lp) | WCR p | IC 95% WCR (% da base) | permutação p | zeros obs. / Poisson | dispersão |
|---|---|--:|--:|---|--:|---|--:|
| SIM, mortes na via | noite, bin 0 | 29,5 | **0,009** | [12, 82] | **0,015** | 88,2 / 87,6% | 1,16 |
| SIM, mortes na via | manhã, bin 0 | −3,2 | 0,61 | [−28, 14] | 0,83 | 92,0 / 91,5% | 1,23 |
| PRF, mortes | noite, bin 0 | 56,2 | **0,002** | [36, 144] | **0,017** | 92,3 / 91,6% | 1,26 |
| PRF, mortes | manhã, bin 0 | −15,0 | 0,019 | [−46, −5] | 0,45 | 93,8 / 92,7% | 1,57 |
| PRF, com vítima | noite, bin 0 | 22,9 | **0,001** | [12, 51] | **0,001** | 65,4 / 65,9% | 0,93 |
| PRF, com vítima | manhã, bin 0 | −15,3 | 0,053 | [−19, 0] | 0,060 | 77,3 / 77,6% | 0,94 |

- **A hora que escureceu passa nos dois testes que não dependem de 23 clusters,
  nos três desfechos.** A permutação é a mais exigente (pergunta se outros 11
  estados quaisquer dariam efeito tão grande): 15, 17 e 1 em 999.
- A manhã que ganhou luz: sinais negativos nos três; só a PRF chega perto
  (mortes: WCR p = 0,02, mas permutação p = 0,45).
- **Sem excesso de zeros:** a parcela de zeros observada bate com a implicada
  pelo Poisson em todos os casos (diferença < 1 p.p.), e a dispersão é 0,9–1,6.
  Confirma a decisão de não usar zero-inflated nem binomial negativo.

**Imputação (`05_imputation.R`, `audit/imputation.rds`).** Modelo ajustado só
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

## 8. Diferença quádrupla dentro do dia (`09_within_day.R`): não reduz o ruído

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
    é mais largo que o reportado (bateu na grade). O `07_honestdid.R` deve
    emitir os mesmos avisos; não conferido, mas o teste de escala vale lá também.
- **Decisão:** a quádrupla vira robustez (e fonte da hora +1 e da manhã), não o
  desenho principal. O principal segue a tripla em [0, 60).
- Figura: `fig05_within_day_event_study` (refeita depois da correção do locale
  em `00_utils.R`; a primeira versão tinha "×" virando "..").
- Permutação da quádrupla: desligada por padrão (`DS_RI`), ~35 s por ajuste.

## 9. Agressões do SIM: tendência, não luz (`10_assault_trends.R`, 09/10/2026)

Agressões (X85–Y09), todos os locais, hora do óbito; mesmo modelo da tripla.
Aqui o "dia todo" inclui os óbitos sem hora (no §3 eles saíam), daí 2,4 em vez de 4,6.

| bloco | tripla (lp) | p | Wald pré (p) | tendência pré | tend. pré extrapolada | sem 2019/20 | DD só na janela | DD só fora |
|---|--:|--:|--:|--:|--:|--:|--:|--:|
| dia todo | 2,4 (1,7) | 0,17 | 0,001 | +0,2 | 0,8 | −0,5 | −21,5 | −24,1 |
| 0–8h | 0,4 (4,4) | 0,93 | 0,11 | +0,1 | −0,5 | −2,2 | −26,5 | −26,8 |
| 8–17h | 7,0 (2,6) | 0,007 | 0,025 | +0,1 | 6,5 | 2,3 | −6,1 | −12,7 |
| 17–20h | 15,2 (5,0) | 0,003 | <0,001 | +0,8 | 9,1 (p = 0,07) | 10,4 (6,0) | +1,8 | −14,0 |
| 20–24h | 1,9 (4,5) | 0,67 | 0,86 | −0,5 | 5,7 | 0,8 | −12,3 | −14,9 |

**Veredito: não há assinatura de luz.**
- O dia todo some sem a temporada 2019/20 (−0,5). No estudo de eventos, só
  2019/20 salta (+11,9 lp; +24 às 8–17h, +20 às 17–20h); as outras quatro
  temporadas pós ficam entre −5 e +1. Na série bruta, 2019/20 é o ano em que a
  janela de verão do controle (N/NE) despencou (razão janela/fora 0,57, contra
  0,62–0,71 nos outros anos).
- Às 8–17h, horas cuja luz não mudou, o "efeito" é parecido com o das 17–20h.
- Às 17–20h, os coeficientes pré oscilam em torno de −15 a −25 lp contra a
  referência 2018/19 (Wald p < 0,001): a referência é uma temporada alta, e a
  tripla compara o pós com um pré baixo, não com 2018/19. Na decomposição, a
  diferença dupla **dentro da janela** é nula (+1,8); a tripla positiva vem da
  entressafra dos tratados, que caiu (−14). A luz só age na janela.
- O desenho afiado do §4 (só óbito na via, hora que trocou de luz) já dava
  +13,8%, p = 0,39.
- **Decisão:** agressões ficam fora do paper como desfecho; no máximo um apêndice
  de "não encontramos", com esta tabela. Figura: `fig06_assault_event_study`.

## 10. A conta da realocação (`11_reallocation.R`, 09/10/2026)

Um modelo Poisson empilhado com as horas −2, −1, 0, +1 da noite e −1, 0, +1 da
manhã, todos os FE interagidos com a hora (coeficientes idênticos aos do 02,
conferido no script); a covariância conjunta por UF permite somar. Excesso =
observado − contrafactual, em eventos **por temporada**, nos tratados, na
janela de verão (5 temporadas pós). Método delta para o EP.

**Por hora (eventos por temporada):**

| hora | SIM mortes na via | PRF mortes | PRF com vítima |
|---|--:|--:|--:|
| noite −2 | −12 (10) | −1 (10) | **−99 (38)** |
| noite −1 | +8 (11) | **−17 (9)** | **−148 (40)** |
| noite 0 (escureceu) | **+36 (9)** | **+25 (7)** | **+115 (25)** |
| noite +1 (crepúsculo → noite) | +22 (13) | +8 (6) | +33 (30) |
| manhã −1 | +6 (10) | −8 (8) | −15 (30) |
| manhã 0 (clareou) | −3 (11) | −6 (8) | −57 (34) |
| manhã +1 | −14 (12) | −1 (9) | +32 (39) |

**Somas:**

| soma | SIM mortes na via | PRF mortes | PRF com vítima |
|---|--:|--:|--:|
| noite escura (0, +1) | **+58 (19)**, +26% | **+33 (10)**, +43% | **+147 (38)**, +16% |
| manhã clara (0) | −3 (11) | −6 (8) | −57 (34), p = 0,10 |
| líquido: noite 0, +1 e manhã 0 | **+55 (20)**, p = 0,01 | **+28 (14)**, p = 0,04 | **+90 (42)**, p = 0,03 |
| líquido: as sete horas | +43 (40), p = 0,29 | +1 (23) | −139 (96), p = 0,15 |
| dia todo (modelo à parte) | −2 (66) | −58 (45) | −70 (216) |

**Leitura:**
- **A manhã não paga a conta da noite.** Nas horas cuja luz mudou de fato
  (noite 0 e +1, manhã 0), o saldo é positivo nas três fontes: ~55 mortes na
  via por verão no SIM, ~28 mortes na PRF. A manhã que clareou ganha pouco
  (SIM −3; PRF −6 mortes, −57 acidentes com vítima).
- **"O total do dia não muda" precisa ser reescrito.** O EP do dia todo é de
  66 mortes por temporada no SIM, maior que o próprio efeito da noite (+58).
  O dia todo **não distingue** entre zero e o excesso da noite; ele é
  inconclusivo, não evidência de realocação pura. A frase certa: "o efeito
  está concentrado nas horas que escureceram; o total do dia é estimado com
  ruído demais para confirmar ou descartar o saldo".
- **As duas fontes contam histórias diferentes fora da hora escurecida.** No
  SIM, as horas vizinhas quase não se movem e o saldo das sete horas continua
  positivo (+43, n.s.). Na PRF, as duas horas antes do pôr do sol perdem tanto
  quanto a noite ganha (acidentes com vítima: −247 contra +147), e o saldo das
  sete horas é zero ou negativo. **A PRF parece realocação; o SIM parece
  excesso.** Candidatos: o tráfego das rodovias federais mudou de hora (a volta
  para casa ou a viagem de férias saiu do fim da tarde?), ou o ofuscamento pelo
  sol baixo saiu das horas −1/−2. As rodovias federais são uma fração
  pequena das mortes do SIM (que inclui as vias urbanas), então as duas
  leituras podem ser verdadeiras ao mesmo tempo. O fluxo do DNIT decide.
- **Ressalva de sempre:** sem tendência. A PRF perde metade do efeito com a
  tendência pré extrapolada (§7); o SIM não.

## 11. Quem morre na hora que escureceu: pedestres (`12_mechanism.R`, 09/10/2026)

O 02 agora grava no arquivo de eventos também a divisão pedestre × resto
(SIM: V01–V09 × V10–V89; PRF: "Atropelamento de pessoa/pedestre" × o resto).
As estimativas antigas do 02 não mudaram (diferença máxima de 6e-16), e as
partes somam o total. Modelo empilhado como no 12; lp (EP por UF).

| hora | SIM pedestre | SIM resto | dif. (p) | PRF mortes, pedestre | PRF mortes, resto | dif. (p) | PRF com vítima, pedestre | resto | dif. (p) |
|---|--:|--:|--:|--:|--:|--:|--:|--:|--:|
| noite 0 | **78,6 (29)** | 18,0 (7,8) | 61 (0,03) | **173 (33)** | 28 (24) | 145 (<0,001) | **99,5 (21)** | 18,8 (5,5) | 81 (<0,001) |
| noite +1 | **61,1 (23)** | 5,5 (15) | 56 (0,09) | −24 (25) | 34 (18) | −58 (0,07) | −21,6 (14) | 9,9 (6,4) | −31 (0,02) |
| manhã 0 | −34 (36) | 0,4 (13) | n.s. | −95 (102) | −9,5 (22) | n.s. | −63 (70) | −13,2 (6,5) | n.s. |

- **O escuro age sobre o pedestre**, como manda a literatura (Sullivan &
  Flannagan; IIHS). No SIM, os pedestres são ~12% das mortes na via na hora 0
  antes de 2019 (12,8 por verão), mas respondem por ~44% do excesso
  (+15 de +33 por verão). Na série bruta, o número de pedestres mortos na hora 0,
  nos tratados e no verão, dobra (12,8 → 26,8 por temporada), enquanto cai no
  controle e na entressafra (Tabela 1).
- Ocupantes e motociclistas também sobem (SIM +18 lp, p = 0,02), menos.
- **Tendência pré, noite 0:** SIM pedestre: Wald pré p = 0,38, tendência
  +0,8 (4,7), com a tendência extrapolada **71 (29)**; SIM resto 27 (7,9). PRF
  pedestre: mortes 110 (33), com vítima 75 (21), mas o Wald pré rejeita nos
  acidentes com vítima (p < 0,001; o mesmo acontece com o resto). O efeito sobre
  o pedestre não é tendência.
- Na PRF, os pedestres da hora +1 caem: a hora +1 já era escura em boa parte
  dos dias com horário de verão nas rodovias (sem iluminação), então o "escuro"
  ali não é novo. Ler com cuidado.

**Inferência robusta (`14_inference_pedestrian.R`, `audit/inference_pedestrian.rds`).**
Noite, hora 0. WCR = wild cluster restrito (Webb, B = 9.999) no análogo linear;
permutação = 999 sorteios de 11 estados tratados, com o mesmo sorteio para os
dois membros do par, de modo que a diferença tem sua própria distribuição nula.

| desfecho | grupo | lp | EP por UF (p) | WCR p | permutação p |
|---|---|--:|--:|--:|--:|
| SIM mortes na via | pedestre | 78,6 | 0,007 | **0,007** | **0,029** |
| | resto | 18,0 | 0,021 | 0,016 | 0,052 |
| | diferença | 60,6 | 0,03 | | 0,068 |
| PRF mortes | pedestre | 173 | <0,001 | **<0,001** | **<0,001** |
| | resto | 28,3 | 0,24 | 0,07 | 0,22 |
| | diferença | 145 | <0,001 | | **0,002** |
| PRF com vítima | pedestre | 99,5 | <0,001 | **<0,001** | **<0,001** |
| | resto | 18,8 | <0,001 | 0,006 | 0,008 |
| | diferença | 80,7 | <0,001 | | **0,001** |

- O pedestre passa nos dois testes nas três fontes. A diferença entre pedestre e
  resto passa na permutação na PRF; no SIM fica em p = 0,07.
- Sem excesso de zeros nas contagens raras dos pedestres: os zeros observados
  e os implicados pelo Poisson diferem em menos de 0,3 p.p., e a dispersão
  fica em 0,9.

## 12. Fluxo de tráfego (DNIT): o dado existe (09/10/2026)

O portal de dados abertos do DNIT (servicos.dnit.gov.br/dadosabertos, API
CKAN) só tem o **VMDa**, o volume médio diário anual modelado por trecho
(2020–2022). Ele não serve para ver mudança de horário. O dado horário está no
**portal do PNCT** (servicos.dnit.gov.br/dadospnct), que tem uma API sem
documentação. Encontrei as rotas lendo o código da página:

- `GET /dadospnct-api/api/v1/coletaContinua?historico=true|false`: postos de
  contagem contínua (GeoJSON com UF, BR, km e coordenada). São 319 postos no
  histórico (2014–2019) e 380 no atual (2021+), em todas as UFs dos dois grupos
  (por exemplo, MG 58, RS 31, PR 28, SP 9; CE 8, PE 12, PA 9).
- `GET .../coletaContinua/anos`: os anos são 2014–2019 e 2021–2025. **Falta 2020.**
- `GET .../coletaContinua/posto/{id}/volume/{mensal|diario|horario}?ano&mes&dia`:
  JSON por posto, com volume por sentido.
- `GET .../coletaContinua/postocontagem/vh/csv?uf=&br=&ano=` (Accept:
  application/zip): **download em massa do volume horário de um ano**, em zip.
  O servidor não informa o tamanho antes do download.

**Por que falta 2020, e o que mais falta (09/10/2026).** Segundo uma nota do
DNIT de dez/2020, o último contrato das contagens contínuas terminou em
**junho de 2019**. O 2º semestre de 2019 foi estimado por modelo, e 2020 não
foi contado. Fonte: SINDISAN, 14/12/2020, que cita o DNIT; o texto do DNIT e o
número do novo contrato (2021) ainda não foram localizados. **O dado confirma:**
no posto DF BR-251 km 17, o 2º semestre de 2019 tem os 24 horários completos
todo dia, mas o total diário se repete exatamente no mesmo dia da semana poucas
semanas depois. São 10 a 15 repetições por mês a partir de 18/06/2019, contra
zero de janeiro a maio, e 87 dias são cópias hora a hora. Contagem real não
faz isso. **Consequências:**
- O `07_clean_pnct.R` marca um posto-dia como `imputed` quando o total
  diário repete o do mesmo dia da semana a 1–4 semanas de distância. O `16`
  descarta esses dias e todo o intervalo de jun/2019 a dez/2020.
- **O verão 2019/20, o primeiro sem horário de verão, não existe no PNCT**
  (nov–dez/2019 é modelado). O pós começa no verão 2021/22: a primeira contagem nova é de 06/05/2021 (auditoria de 09/10/2026; antes dizia jan–fev/2021).
- Para o paper: "DNIT's continuous-count contract lapsed between June 2019
  and 2021; the published 2019-H2 values are model-based and are excluded."

**Janelas de verão cobertas:** 2014/15–2018/19 (5 pré; a cobertura de 2014 começa no meio do
ano) e 2021/22–2024/25 (4 pós). Não há contagem em jan–fev/2021 (a primeira é de 06/05/2021). 2019/20 fica de fora (modelado).
**Desenho possível:** a mesma tripla no volume, por posto × dia × hora
relativa ao pôr do sol. Ela diz se o tráfego das horas −2 a +1 mudou de hora
nos tratados, e permite reescrever o efeito como risco por veículo.

## 13. Por que o SIM e a PRF diferem

Os dois não medem a mesma coisa:

| | SIM, mortes na via | PRF, mortes |
|---|---|---|
| onde | **todas as vias**: urbanas, estaduais, municipais e federais | só **rodovias federais**, a maioria fora das cidades |
| quem | óbito **na via pública** (LOCOCOR = 4); quem morre no hospital sai | **só óbito no local do acidente**: quem morre depois da remoção fica classificado pela lesão de antes do transporte (Anuários PRF 2019–2025, `fontes_dados/prf_definicao_mortos.txt`) |
| hora | hora do óbito, que para quem morre no local ≈ hora do acidente | hora do acidente, registrada pelo policial |
| base anual (tratados, verão, pré) | ~2.380 por temporada | ~1.170 por temporada |
| pedestre | 13,5% do dia (12% na hora 0) | 15% do dia (10% na hora 0) |

- **A sobreposição é parcial.** Uma morte no local numa rodovia federal pode
  estar nas duas bases. As mortes nas vias urbanas e estaduais, que são a maior
  parte do SIM, não aparecem na PRF.
- **No efeito da hora 0, as duas não divergem de fato.** 29,5 (9,0) contra
  56 (21) lp: a diferença de 27 lp tem EP ~23 (conta grosseira, sem a
  covariância), longe de significante. Nas duas o efeito se concentra no
  pedestre.
- **Elas divergem em três pontos, e nenhum é contradição:**
  1. *As horas antes do pôr do sol (−1 e −2).* Na PRF caem; no SIM, não. O
     tráfego das rodovias federais tem outra composição (viagens longas,
     caminhões, saída de férias e feriados). Se essas viagens mudaram de hora
     com o relógio, o risco nas rodovias só mudou de lugar. O PNCT (§12) responde.
  2. *A tendência.* Os acidentes com vítima da PRF têm tendência pré
     diferencial (Wald p < 0,001); o SIM, não. A e-DAT e a mudança do
     policiamento rodoviário a partir de 2015 são candidatos.
  3. *O saldo do dia.* No SIM a noite ganha e o resto quase não se mexe; na PRF
     a noite ganha o que o fim da tarde perde (§10).
- **Leitura:** o SIM mede o efeito sobre a população, e ali a luz cria
  mortes. A PRF mede um tipo específico de via, e ali parte do efeito é o
  tráfego mudando de hora. Ela corrobora o mecanismo (pedestre, escuro), não o
  tamanho do excesso.

**Definição de "mortos" na PRF (conferida em 09/10/2026).** Os Anuários da
PRF (2019, 2021, 2022, 2025) definem morto como a pessoa em óbito **no local do
acidente**. A de 2019 acrescenta: "A vítima que venha a morrer após a remoção
do sítio do acidente, será classificada de acordo com as lesões apresentadas
antes do transporte". Ou seja, **é o mesmo conceito do nosso SIM** (óbito na
via pública, LOCOCOR = 4). As duas bases medem a morte no local; a diferença
entre elas é só a rede (todas as vias × rodovias federais). Para 2007–2018 não
há Anuário com a definição, mas a série não mostra quebra:

| | 2007 | 2010 | 2014 | 2016 | 2018 | 2019 | 2021 | 2025 |
|---|--:|--:|--:|--:|--:|--:|--:|--:|
| mortes por acidente fatal | 1,24 | 1,22 | 1,22 | 1,20 | 1,17 | 1,16 | 1,16 | 1,16 |
| feridos graves por morte | 3,50 | 3,24 | 3,19 | 3,35 | 3,36 | 3,49 | 3,28 | 3,31 |

Uma mudança de definição só ameaçaria o desenho se fosse diferencial entre
grupos × janela × pós.

## 14. O tráfego mudou de hora (`15_traffic_volume.R`, 09/10/2026)

Dados: PNCT, `build/06–07`, 608 postos de contagem contínua, só posto-dias
completos e contados (sem jun/2019–dez/2020 e sem os dias marcados como
modelados). **Fonte primária da lacuna:** Nota Técnica DNIT nº 001/2020/DE,
17/11/2020, p. 7. Segundo ela, jul–dez/2019 foram estimados por *machine
learning* porque "o último edital vigente para realização das contagens
contínuas do PNCT se encerrou no mês de junho de 2019". Trecho em
`horario_verao/fontes_dados/`. Os contratos novos foram assinados em
30/12/2020 e 13/01/2021 (Comprasnet), e as contagens voltam em maio de 2021.

**Nenhum posto é contado antes e depois** (263 só antes, 338 só depois). Por
isso a sazonalidade fica na UF: `station + uf^window + uf^sy + date`. Como
robustez, 30 pares de postos que só mudaram de km na mesma BR, com FE de par.
Cobertura nos verões: tratados com 59–146 postos antes e 175–217 depois;
controle com 18–50 antes e 61–69 depois.

> **Correção (09/10/2026):** a contagem "263 só antes, 338 só depois" não se
> reproduz; o certo é **247 só antes e 315 só depois** nas 23 UFs do estudo
> (267 e 341 em todas as UFs). E "postos que só mudaram de km" diz mais do que
> se sabe: o critério dos 30 pares é um posto só-depois a até 2 km de um
> só-antes na mesma BR, provavelmente o mesmo ponto realocado. Nenhuma
> estimativa muda. Ver ROADMAP (auditoria de 09/10/2026).

**(a) Relógio.** O perfil do verão dos tratados (líquido da entressafra e do
controle) casa melhor sem defasagem (distância 0,23) do que com −1 ou +1 hora
(0,32 e 0,38). O PNCT anota hora legal, como a PRF.

**(b) Volume por hora relativa ao sol, tripla (lp, EP por UF):**

| hora | todos | leves | pesados | pares de postos |
|---|--:|--:|--:|--:|
| noite −2 | −1,3 (1,6) | −1,8 | +1,6 | −5,1 (1,3) |
| noite −1 | **−5,1 (1,3)** | −6,2 | −0,9 | −5,2 (2,2) |
| noite 0 | **−6,4 (2,2)** | −7,7 | −2,4 | −3,1 (3,1) |
| noite +1 | −6,4 (3,2) | −8,1 | 0,0 | −4,7 (2,9) |
| noite +2 | −6,3 (3,2) | −7,8 | −0,8 | −6,4 (2,7) |
| manhã 0 | **+11,7 (5,0)** | +10,2 | +17,3 | **+18,7 (5,1)** |
| manhã +1 | +4,5 (2,4) | +3,8 | +8,7 | +7,8 (4,3) |
| dia todo | +0,5 (2,0) | | | |

- **O tráfego seguiu a luz.** Sem horário de verão, a noite escura perdeu
  ~5–6% dos veículos, do fim da tarde até duas horas depois do pôr do sol,
  quase todos leves (carros e motos). A manhã que clareou ganhou ~12%
  (~19% nos pares), puxada pelos pesados (+17%). O total do dia não muda.
- **O risco por veículo na hora escura sobe mais que o risco total.**
  Acidentes com vítima menos volume: hora 0, **+29 lp (6,1)**; mortes, +63 lp
  (21). Quem ficou na estrada no escuro corre mais risco do que o total sugere.
- **A manhã fica mais segura por veículo:** acidentes com vítima −27 lp (9,9).
  Mais carros na hora clara e menos acidentes.
- **A queda da PRF na hora −1 só em parte é volume:** −22 lp de acidentes
  contra −5 lp de volume; por veículo, ainda −17 (5,5). O quebra-cabeça do §5
  encolhe, mas não fecha. O ofuscamento pelo sol baixo segue como candidato.
- **Limite:** o PNCT cobre só rodovias federais. Não fala do tráfego urbano,
  onde está boa parte das mortes de pedestres do SIM.
- **(c) Dentro do dia (corrigido):** a primeira versão não tinha hora de
  referência. Com o FE de posto × dia, somar uma constante a todos os
  coeficientes não muda nada, daí os EP de ~4.700 lp. Agora a referência é "o
  resto do dia" (as 13 horas fora das 11 estudadas), e o coeficiente lê a
  mudança da hora em relação ao resto do mesmo posto-dia:

  | hora | lp (EP) |
  |---|--:|
  | noite −3 | −1,7 (0,7) |
  | noite −2 | −3,9 (0,8) |
  | noite −1 | −7,7 (1,7) |
  | noite 0 | **−9,2 (2,1)** |
  | noite +1 | −9,4 (2,4) |
  | noite +2 | −9,5 (2,5) |
  | manhã −1 | +4,7 (5,0) |
  | manhã 0 | **+9,1 (4,4)** |
  | manhã +1 | +1,8 (1,6) |

  Comparando dentro do mesmo posto-dia, o deslocamento é até maior que no (b):
  a noite perde ~9% da sua parcela do dia, e a manhã que clareou ganha ~9%.
  A queda começa duas a três horas antes do pôr do sol e cresce até a noite.

**(d) Inferência robusta (`17_inference_volume.R`, `audit/inference_volume.rds`).**
WCR é o wild cluster restrito (Webb, B = 9.999) no análogo linear do volume.
A permutação usa 999 sorteios de 11 estados tratados, com o mesmo sorteio no
modelo de volume e no de acidentes com vítima da PRF, de modo que o risco por
veículo (acidentes menos volume) tem sua própria distribuição nula.

| hora | volume (lp) | EP por UF p | WCR p | permutação p | acidentes PRF (lp), perm. p | por veículo (lp), perm. p |
|---|--:|--:|--:|--:|--:|--:|
| noite −1 | −5,1 | <0,001 | **0,003** | **0,014** | −22,0; <0,001 | **−17,0; 0,002** |
| noite 0 | −6,4 | 0,004 | 0,072 | 0,058 | +22,9; 0,002 | **+29,4; 0,001** |
| noite +1 | −6,4 | 0,047 | 0,333 | 0,100 | +6,5; 0,34 | +13,0; 0,054 |
| manhã 0 | +11,7 | 0,019 | **0,009** | **0,040** | −15,3; 0,062 | **−27,1; 0,001** |

- **O risco por veículo passa com folga na permutação** na hora que escureceu
  (+29 lp, p = 0,001), na que clareou (−27, p = 0,001) e na hora antes do pôr do
  sol (−17, p = 0,002).
- O volume é mais frágil com 23 clusters: na hora 0, o EP por UF dá p = 0,004,
  mas o WCR (0,07) e a permutação (0,06) ficam na fronteira. A hora −1 e a
  manhã 0 passam nos dois.
- A queda de volume na hora 0 é pequena perto da alta de acidentes, então a
  conclusão sobre o risco não depende de o volume ser significante.

## 15. A Bahia em 2011/12: checagem de sinal (`17_bahia_switch.R`, 09/10/2026)

A BA teve horário de verão numa única temporada da amostra (2011/12, Dec.
7.584/2011). Naquele verão, a hora que escurece com a abolição era clara na BA;
nas outras 15 temporadas, escura. Como é um estado e uma temporada, não há EP
que valha: para cada temporada s, `y ~ BA × janela × 1[sy = s]` com os FE da
tripla, BA mais os 12 controles, e a temporada 2011/12 ordenada entre as 16.
Os eventos da BA são montados como no 02 (inclusive os aliases da PRF). Figura
`fig08_bahia_switch`, números em `audit/bahia_switch.rds`.

- **Primeiro estágio claro:** na hora 0 da noite, no verão, a PRF anotou
  escuro em 67,8% dos acidentes na BA em 2011/12, contra 92–100% em todas as
  outras temporadas.
- **Noite, hora 0 (deveria cair em 2011/12):** acidentes com vítima da PRF
  −21 lp, **o menor das 16 temporadas** (59 acidentes; média das outras, 57);
  mortes na via do SIM −38 lp, 4ª menor de 16 (18 mortes contra 23,6); mortes
  da PRF +18, 11ª de 16 (14 mortes: ruído).
- **Manhã, hora 0 (deveria subir):** não aparece. SIM −58 (3ª menor), PRF
  mortes −88 (3ª menor), com vítima +12,5 (12ª de 16). Igual ao paper
  principal, onde a manhã é fraca.
- **Leitura:** apêndice, como checagem de sinal. O relógio mudou de fato na BA,
  e a noite clara teve, nas duas séries maiores, o pior ou um dos piores
  números da série. Com uma temporada só, a posição 1 de 16 equivale a p ≈ 0,06,
  e não deve ser lida como mais do que isso. TO (2012/13) fica de fora: 3 a 8
  mortes por verão na hora 0.

## 16. Placebo contra o sono: horas longe do crepúsculo (`18_placebo_hours.R`, 09/10/2026)

Mesma tripla do 02, em blocos cuja luz não mudou: meio do dia (3h ou mais
depois do nascer e 4h ou mais antes do pôr do sol padrão) e noite fechada (3h
ou mais depois do pôr do sol ou 3h ou mais antes do nascer). Um efeito de sono
crônico apareceria aí. lp (EP por UF):

| | hora 0 da noite | meio do dia | noite fechada |
|---|--:|--:|--:|
| SIM, mortes na via | **29,2 (9,0)** | −4,5 (5,8) | −6,6 (5,6) |
| PRF, mortes | **53,9 (20,3)** | −17,3 (11,2) | −19,8 (11,8), p = 0,09 |
| PRF, com vítima | **22,2 (5,6)** | −1,9 (3,9) | −6,1 (2,9), p = 0,04 |

Nenhum aumento nas horas cuja luz não mudou; os sinais são negativos, o
contrário do que um sono pior produziria (e, na PRF, em linha com o tráfego que
saiu da noite, §14). O efeito está só onde a luz mudou.

## 17. Rodada vigente, depois da auditoria de código (09/10/2026)

**Correção:** a PRF casava o município só pelo nome e perdia ~0,4% dos
acidentes: renomeados (Embu das Artes, Paraty, Serra Caiada…), variantes de
grafia (Piçarras, São Miguel d'Oeste, Açu, Itapajé…) e os 5 municípios de 2013,
sem sede em 2010. Agora há `build/manual/prf_municipio_alias.csv`, e o
`04_municipal_geo.R` inclui os municípios de 2013. Casamento: 99,7% → 100%. O
SIM ganha os óbitos desses 5 municípios (≤ 13 por ano). Refeitos 02–10 e
12–17; o volume do PNCT ficou idêntico, como devia.

| | antes | depois |
|---|--:|--:|
| SIM, hora 0 (lp) | 29,5 (9,0) | **29,2 (9,0)** |
| PRF mortes, hora 0 | 56,2 (20,8) | **53,9 (20,3)** |
| PRF com vítima, hora 0 | 22,9 (5,7) | **22,2 (5,6)** |
| WCR p / permutação p, SIM | 0,009 / 0,015 | 0,010 / 0,018 |
| WCR p / permutação p, PRF mortes | 0,002 / 0,017 | 0,002 / 0,019 |
| imputação com tendência, PRF mortes | +26% [−24, 108] | +22% [−24, 97] |
| imputação com tendência, com vítima | +10% [−4, 29] | +8% [−5, 26] |
| imputação sem tendência, PRF mortes | +63% [2, 158] | +59% [1, 149] |
| excesso noite 0, +1 (SIM / PRF mortes / com vítima) | 58 / 33 / 147 | 57 / 34 / 146 |
| líquido noite 0, +1 e manhã 0, SIM | 55 (20), p = 0,006 | 54 (20), p = 0,007 |
| manhã clara, com vítima | −57 (34), p = 0,10 | −53 (33), p = 0,11 |
| pedestre, hora 0, SIM / PRF mortes | 78,6 / 173 | 76,6 / 170 |
| pedestre, % do excesso no SIM | 43,7 | 43,4 |
| pedestre, permutação p, SIM | 0,029 | 0,035 |
| risco por veículo, hora 0 (com vítima) | +29,4, p = 0,001 | +28,6, p = 0,001 |
| risco por veículo, hora +1 | +13,0, p = 0,054 | +13,3, p = 0,044 |
| quádrupla, hora 0 (SIM / PRF mortes / com vítima) | 28,0 / 93 / 31,4 | 27,7 / 90 / 31,1 |
| HonestDiD, ruptura M | 0,02 / 0,01 / 0,075 | igual |

Duas mudanças de lado de limiar, ambas pequenas: a manhã clara nos acidentes
com vítima passa de p = 0,096 para 0,11, e o risco por veículo na hora +1 passa
de 0,054 para 0,044. Nenhuma frase do PAPER.md dependia delas.

## 18. HonestDiD com temporadas em pares: testado e descartado (09/10/2026)

Pergunta: o breakdown baixo do HonestDiD (§ do `07_honestdid.R`) vem do ruído
de cada temporada? Teste: o mesmo Poisson da hora 0 da noite, com o estudo de
eventos em pares de temporadas. Referência 2017/18 + 2018/19; pré: 2008/09
sozinha, 09–10, 11–12, 13–14, 15–16; pós: 19–20, 21–22, 2023/24 sozinha; alvo
= média simples dos três grupos pós. Grades iguais às do 08. Rodado fora do
repositório (script de rascunho), nada salvo em `audit/`.

| hora 0 | média pós (lp) | IC original | IC, M = 0 | breakdown M | breakdown M̄ | Wald pré p |
|---|--:|---|---|--:|--:|--:|
| SIM, mortes na via | 33,4 | [−5, 72] | [4, 86] | 0,01 | 0 | 0,72 |
| PRF, mortes | 43,0 | [−4, 90] | [−9, 62] | 0 | 0 | 0,74 |
| PRF, com vítima | 23,4 | [9, 38] | [−9, 18] | 0 | 0,5 | <0,001 |

Coeficientes pré (lp): SIM 29, 1, 6, −7, 13; PRF mortes −22, −22, −30, −2, −2;
PRF com vítima −18, 0, −8, 1, 13.

Contra a versão anual (breakdown M 0,02 / 0,01 / 0,075; M̄ 0 / 0 / 0,25), **o
breakdown não melhora.** O que melhora é a média pós do SIM (14,8 → 33,4 lp,
perto dos 29,2 do modelo principal): parte da estranheza vinha da referência
numa temporada só.

**Leitura.**
- **SIM:** não há tendência (Wald 0,72, coeficientes sem inclinação). O IC
  original já inclui zero, por isso M̄ = 0: nem sem violação nenhuma o
  intervalo exclui zero. É falta de precisão do estudo de eventos (referência
  curta, EP da média pós ~20 lp), não violação. O modelo principal compara com
  a média das 11 temporadas pré e tem EP 9.
- **PRF:** os pares deixam a subida pré visível (mortes −22 → −2; com vítima
  Wald p < 0,001). A fragilidade da PRF à tendência é real, como na imputação.

**Decisão:** não adotar os pares (não muda a conclusão e pareceria escolha
feita depois de ver o resultado). Fica a versão anual no apêndice
(`fig_honestdid`), com a frase: no SIM o HonestDiD não detecta tendência, mostra
que o estudo de eventos não tem precisão para descartar violações pequenas; a
identificação vem do contraste dentro do dia (hora 0 contra as vizinhas, manhã
como espelho, pedestre). Não refazer este teste.

## 19. Rodada do parecer (12/10/2026): auditoria 18–21, permutação, itens essenciais

**Auditoria (skill code-audit, scripts 18–21).** 18 e 19 reimplementados do zero
a partir do SIM e da PRF brutos: idênticos. 20 e 21 reproduzem byte a byte.
Corrigidos: rótulo "All seven hours above" (só 5 das 7 horas apareciam), nota do
HonestDiD (o alvo é a média pós contra 2018/19, não o β), en dash literal no 20.

**Permutação.** O p passou a (1 + nº de sorteios ≥ |b|)/(1 + 999), em uma função
única (`perm_pvalue`, `00_utils.R`); colunas renomeadas para `perm_p`, `perm_rank`,
`n_perm`, variável `DS_PERM` (antes `ri_*`). 07, 15, 17 e 10 rodados de novo: as
posições reproduziram exatamente; cada p subiu 0,001.

| | antes | depois |
|---|--:|--:|
| permutação p, hora 0: SIM / PRF mortes / com vítima | 0,018 / 0,019 / 0,001 | 0,019 / 0,020 / 0,002 |
| pedestre, permutação p: SIM / PRF mortes / com vítima | 0,035 / 0,001 / 0,000 | 0,036 / 0,002 / 0,001 |
| por veículo, permutação p, hora 0 / manhã 0 | 0,001 / 0,002 | 0,002 / 0,003 |

**Bahia.** Primeiro estágio com a definição do 04 (escuro entre pleno dia,
anoitecer e noite): 2012/13 91,8 → 93,3%; 2015/16 96,6 → 98,3%; 2017/18 96,7 →
98,3%; 2011/12 igual (67,8%).

**Itens essenciais (scripts 22–28; números em EXPLICANDO §5.12):**
- amontoamento e relógio solar (`22`): algoritmo completo da NOAA 29,8 (9,1);
  sem :00 e :30 16,7 (12,9); janela −15 / +15 min: 14,6 / 41,2;
- tirar um de fora (`23`): SIM entre 24,3 e 34,1 (estados), 22,7 e 35,2
  (temporadas); controle só NE 32,9; só N 15,7 (8,8); sem La Niña 43,5;
- quem morre (`24`): pedestre 76,6; motociclista 19,6 (p = 0,07); carro −0,2;
  fim de semana 41,3 contra dia útil 16,1;
- integridade (`25`): parcela na via +0,4 p.p. (0,75), parcela sem hora +0,4
  p.p. (0,65);
- dose (`26`): primeiro estágio na hora 0 +23,6 p.p. (2,0); hora toda escura
  ~124 lp [42, 197]; com chuva como controle 29,1;
- iluminação (`27`): Censo 2022 40,8 contra 14,1 (p = 0,16); Censo 2010 34,7
  contra 26,0 (p = 0,76);
- custo (`28`, reais de 2025): 54 / 67 / 137 mortes por verão; VSL de
  referência R$ 253 / 311 / 637 mi; Ipea R$ 43 / 53 / 108 mi. Conferido por
  código independente (`scratchpad/verify_cost.R` da sessão): idêntico.

**Fontes novas, lidas no original (trechos em `fontes_dados/`):** Ipea/PRF
2015 e Ipea 2016 (R$ 433.286,69 por morto, dez/2014); ONS NT DPL 0093/2024 e
0107/2021; IPCA (SIDRA 1737); Banco Mundial WDI (2025, atualização de
08/10/2026); Censo 2022 (SIDRA 9839); Lei mexicana de husos horarios (DOF
28/10/2022, `fontes_legais/MX_LHHEUM_2022.txt`).

**México (`29`, `30`; EXPLICANDO §5.13).** Lei de 2022 (DOF), ATUS 2016–2025
(INEGI, hora legal conferida pelo perfil horário), 34 unidades (28 tratadas, 6
controles; Chihuahua fora). Tripla com controles, hora 0: mortes +81 (20), WCR
p = 0,012, permutação p = 0,011 (t, 13/10/2026); pedestres +237 (62), 0,048 / 0,029; acidentes
com vítima −1 (4). Mas a hora −1 dá −126 (41): o controle é fino (1–3 mortes
por ano na hora −1 fora do verão depois de 2023), e nas tratadas a hora −1
ficou parada (88 → 98 mortes por ano). Dentro do dia, só tratadas (hora 0
contra as duas anteriores, FE de unidade × dia): mortes +55 (17), p = 0,001;
pedestres +154 (66), p = 0,02; acidentes com vítima +12 (3); atropelamentos +23
(8). **A réplica vale pelo desenho dentro do dia.** Uruguai descartado.

**Energia, fontes primárias (12/10/2026):** MME NT 5/2019 (+0,7% de carga em
2018/19; recomendou suspender); ONS NT 0107/2021 (sem economia); ONS NT
0093/2024 (R$ 244–356 mi de combustível por verão; ~R$ 1,8 bi/ano de
capacidade). Os R$ 159,5 mi de 2016/17 são de imprensa e não serão citados.

## 20. Permutação na estatística t (13/10/2026)

Pedido do Fredie, seguindo MacKinnon e Webb (2020, J. Econometrics): com
clusters heterogêneos (os estados diferem muito de tamanho), o teste no
coeficiente pode falhar e o teste no t costuma ir melhor. Cada sorteio agora
guarda coeficiente/EP por UF (por unidade no México); diferenças (pedestre −
resto, acidentes − volume) usam (b1 − b2)/√(EP1² + EP2²). Funções `fit_bs`,
`t_stat`, `t_diff` em `00_utils.R`; 06, 14, 16 e 26 rodados de novo (999
sorteios, ~1 h no total); 09 (permutação opcional, fora do paper) também
passou a t. WCR e pontos não mudam.

| | coeficiente | t |
|---|--:|--:|
| hora 0: SIM / PRF mortes / com vítima | 0,019 / 0,020 / 0,002 | 0,018 / 0,014 / 0,007 |
| manhã 0: SIM / PRF mortes / com vítima | 0,826 / 0,560 / 0,070 | 0,829 / 0,579 / 0,128 |
| pedestre, SIM: pedestre / resto / diferença | 0,036 / 0,059 / 0,080 | 0,041 / 0,042 / 0,075 |
| pedestre, PRF mortes: diferença | 0,003 | 0,001 |
| pedestre, PRF com vítima: resto / diferença | 0,010 / 0,002 | 0,024 / 0,001 |
| volume: hora 0 / hora −1 / manhã 0 | 0,059 / 0,015 / 0,041 | 0,069 / 0,025 / 0,159 |
| com vítima por veículo: hora 0 / manhã 0 | 0,002 / 0,003 | 0,002 / 0,009 |
| México, hora 0: mortes / pedestres / atropelamentos | 0,021 / 0,024 / 0,23 | 0,011 / 0,029 / 0,076 |

Nenhuma conclusão do paper muda. A alta do volume na manhã que clareou deixa
de passar na permutação (0,159); o texto já reportava o p.

## Leitura

- **A favor:** primeiro estágio enorme e medido de forma independente;
  efeito concentrado exatamente na hora prevista, em duas fontes diferentes
  (SIM e PRF); pergunta com demanda de política (EUA e UE debatendo o regime
  permanente); dados todos públicos.
- **Contra / a resolver:** a queda na hora anterior ao pôr do sol (item 5, mecanismo em aberto); só 23 clusters, o que pede
  wild bootstrap ou permutação; COVID nas temporadas 2020/21–2021/22; o efeito
  no total do dia é **inconclusivo** (EP 66 mortes por verão no SIM; antes
  esta linha dizia "zero", corrigido em 12/10/2026), então o paper é sobre o
  risco que foi para o escuro, e a manhã precisa ser estimada com cuidado para
  fechar a conta.
- **Literatura:** varredura feita (passo 3) e referências (?) conferidas na
  fonte em 08/10/2026; ver `LITERATURE.md`. Nenhum trabalho usa a abolição de
  2019 para trânsito.
