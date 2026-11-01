# Mudanças no paper e no apêndice desde a versão do MPRA

Versão de referência: a depositada no MPRA (MPRA 131638), commit `88e60cc` de
30/10/2026. Origem das mudanças: um parecer simulado no padrão da AEJ: Policy,
avaliado criticamente e aceito em parte. Os trechos citados estão em inglês, como
no paper.

Resumo: nenhum estimado pontual mudou. Entram (i) inferência robusta para o
modelo de dose e para a contagem líquida de 62 mortes, (ii) um teste com o
tráfego do PNCT para o nulo de 24/12 a 15/01 e (iii) reescritas que separam o
que é identificado na hora da manhã do que depende da hipótese sobre o dia
inteiro.

---

## 1. Resumo (abstract)

**Antes:**
> The effect follows the local sun, not the clock, and the brighter mornings did
> not offset it: abolition added an estimated 62 deaths at the crash scene in
> each 92-day summer window, from mid-November to mid-February.

**Depois:**
> The effect follows the local sun, not the clock, and the brighter mornings
> showed no detectable decline in deaths. Abolition added an estimated 62 deaths
> at the crash scene in each 92-day summer window, from mid-November to
> mid-February.

O resto do resumo não mudou. São 99 palavras pelo contador do projeto (102 se
um sistema separar as palavras nos hífens).

**Por quê:** "offset" fala do saldo do dia. O que está identificado com força é
a hora da manhã que clareou (−3 log pts, EP 12) e a diferença entre manhã e
noite. O saldo sem hipótese adicional, estimado no dia inteiro, é −5 mortes com
EP 66, que não confirma nem descarta os 62. A frase antiga afirmava mais do que
o teste mostra, e um parecerista atento marcaria isso. Agora a frase da manhã
diz exatamente o que foi estimado, e o ponto final no lugar dos dois-pontos tira
a leitura de que o 62 decorre da manhã não ter compensado. A hipótese de que o
62 depende fica na introdução e na Seção IV.H.

## 2. Introdução, parágrafo dos resultados da manhã e da contagem líquida

**Antes:**
> This is the count most directly supported by the observed summer window. […]
> the change is too imprecise (standard error 66) to confirm the count or rule
> it out. The brighter morning did not give these deaths back.

**Depois:**
> […] from November 15 to February 14 (standard error 12; permutation
> $p=0.001$). This is the count most directly supported by the observed summer
> window. […] the change is too imprecise (standard error 66) to confirm the
> count or rule it out. In the model that weights each hour by its change in
> light, a given change in darkness has a larger effect on road deaths in the
> evening than in the morning (permutation $p=0.001$).

**Por quê:** a frase final antiga contradizia a anterior: o parágrafo dizia que
o dia inteiro é impreciso demais e logo fechava como se o dia inteiro tivesse
confirmado a ausência de compensação. Agora o parágrafo fecha com o teste que
de fato compara manhã e noite, a diferença entre os dois coeficientes do modelo
de dose, que é uma tripla diferença e passa na permutação. O p da permutação no
62 responde à pergunta previsível de por que a inferência robusta só aparecia
na hora 0.

Uma versão intermediária usava a Tabela B4 ("within the treated states alone,
the decline in deaths in the morning hour offsets less than a third of the rise
in the evening hour"). Saiu numa segunda revisão: a queda da manhã dentro dos
tratados (−19,4) é igual à dos controles (−23,5), então não é efeito da
abolição; a conta só valia em mortes, não em log pts (41%); e a introdução
mostraria uma queda na manhã que o resumo diz não ser detectável.

## 3. Introdução, segunda contribuição

**Antes:**
> and it shows that the light gained in the morning does not offset the light
> lost in the evening.

**Depois:**
> and it shows that the evening hour that lost light became deadlier while the
> morning hour that gained light did not become detectably safer.

**Por quê:** a mesma razão do item 1.

## 4. Seção 4 — Tabela 4 (dose) e texto

- **Tabela 4**: três linhas novas no Painel A ("Baseline: p-value, clustered
  by state", "Baseline: p-value, permutation of treated states" e "Baseline:
  p-value, score wild bootstrap"), como na Tabela 2, e uma no
  Painel B ("Evening equals morning, p-value, permutation"). A linha que já
  existia virou "Evening equals morning, p-value, clustered by state".
  Resultados: mortes na via, noite p=0,002 (permutação) e p<0,001 (score);
  noite ≠ manhã, p=0,001. Mortes na PRF: noite p=0,031 e 0,003, mas noite ≠
  manhã p=0,139.
- **Nota da Tabela 4**: uma frase explicando como a permutação e o bootstrap
  foram feitos (cada sorteio de 11 estados recebe as doses desses estados).
- **Texto**: "which differs from the evening's ($p<0.001$)" virou "($p<0.001$;
  permutation $p=0.001$). The baseline evening effect remains significant
  under the permutation test ($p=0.002$) and the score wild bootstrap
  ($p<0.001$)."

**Por quê:** com 23 clusters, o EP clusterizado pode rejeitar demais. O paper já
tratava isso na hora 0 (Tabela 2), mas não nos números da manchete (dose e
contagem líquida). Agora os três números centrais têm a mesma proteção.

## 5. Seção IV.H (4.8 na versão de working paper) — título, Tabela 6 e texto

- **Título**: "The Morning Does Not Offset the Evening" virou "The Morning Hour
  Does Not Offset the Evening Hour". **Por quê:** o título passa a falar das
  horas estimadas, não do saldo do dia. Na auditoria (§10) se cogitou "does not
  detectably offset"; o Fredie manteve o título sem "detectably".
- **Tabela 6**: duas linhas novas abaixo da contagem líquida, "p-value,
  clustered by state" (pelo EP do método delta: <0,001, 0,008, 0,448) e
  "p-value, permutation of treated states": 0,001 (mortes na via), 0,135 (mortes na PRF), 0,627
  (acidentes na PRF). A nota ganhou uma frase sobre o teste e outra dizendo por
  que não há os bootstraps da Tabela 2: a contagem é uma função não linear dos
  dois coeficientes, então não há modelo restrito para o score wild bootstrap
  nem análogo linear para o wild cluster bootstrap. (Um bootstrap-t sem impor a
  nula seria possível; a nota não diz que só a permutação se aplica.)
- **Texto**: "(standard error 12)" virou "(standard error 12; permutation
  $p=0.001$)". Nas mortes da PRF, "31 deaths (12)" virou "31 deaths (12;
  permutation $p=0.135$)". **Por quê:** o clusterizado dá 0,008 e a permutação
  0,135; depois de reportar a permutação na tabela, omiti-la no texto pareceria
  seletivo. Nenhum trecho afirma que noite ≠ manhã é significativa na PRF.

## 6. Seção 4 (transições e partes da janela) — o nulo de 24/12 a 15/01

**Antes:**
> These checks do not rule out holiday travel as an explanation, and the data do
> not say why no increase is detectable in those weeks.

**Depois:**
> Traffic on federal highways shows no detectable difference between the two
> periods. Vehicles in hour 0 fell by 7.4 log points from December 24 to
> January 15 and by 5.3 in the school weeks, a difference of 2.1 (standard error
> 2.4), and the same holds for trucks and
> buses in that hour and for the day's traffic (Online Appendix Table B3). These
> checks do not rule out holiday travel on other roads as an explanation, and
> the data do not say why no increase is detectable in those weeks.

**Por quê:** o nulo de fim de ano era a parte mais solta do texto. A hipótese
óbvia (viagens de férias mudam o tráfego no início da noite) era testável com
dados que o paper já tem. O teste não a sustenta nas rodovias federais, e o
texto agora diz isso e limita a ressalva às outras vias. "No detectable
difference", e não "did not change differently": a diferença de 2,1 (2,4) tem
intervalo de cerca de −2,6 a 6,8.

## 7. Apêndice — tabela e parágrafo novos

- **Nova Tabela B3** "Federal Highway Traffic in Parts of the Summer Window"
  (logo após a tabela das partes da janela; as tabelas seguintes do apêndice
  sobem um número, e a antiga B3 virou B4): a coluna 1 da tabela de volume,
  com efeitos separados por parte da janela, para veículos na hora 0, veículos
  pesados na hora 0 e veículos do dia inteiro.

  | | Hora 0, todos | Hora 0, pesados | Dia inteiro |
  |---|---|---|---|
  | 15/11–07/12 (aulas) | −5,3 (1,8) | −0,4 (2,4) | 0,7 (1,1) |
  | 24/12–15/01 | −7,4 (3,2) | −1,8 (4,6) | 1,2 (3,0) |
  | 16–31/01 (férias) | −5,2 (3,3) | −3,3 (4,2) | 1,2 (2,5) |
  | Aulas menos 24/12–15/01 | 2,1 (2,4) | 1,4 (3,0) | −0,4 (2,4) |

- **Novo parágrafo** que apresenta a tabela (o teste, os números e o limite: só
  rodovias federais).

**Por quê:** é o mesmo item 6, com o detalhe que cabe no apêndice.

## 8. Conclusão

**Primeiro parágrafo — antes:** "and the morning hour that gained light did not
compensate for it." **Depois:** "and the morning hour that gained light did not
become detectably safer."

**Última frase — antes:**
> Within these limits, darker evenings cost lives on the road that brighter
> mornings do not return, and a disproportionate share of those lives are
> pedestrians, whom street lighting and road design can protect when the clock
> does not.

**Depois:**
> Within these limits, the evening hour that lost its light became deadlier on
> the road, deaths in the morning hour that gained it did not detectably
> decline, and a disproportionate share of the lives lost are pedestrians, whom
> street lighting and road design can protect when the clock does not.

**Por quê:** a frase antiga afirmava algo sobre o dia todo ("do not return"). A
nova afirma o que o desenho identifica e mantém o fecho sobre pedestres.

## 9. Apêndice B.2 — a manhã dentro de cada grupo

**Antes:**
> Within the treated states alone, road deaths in the morning hour that turned
> light fell by 19.4 log points (9.6). Applied to the 107 and 110 deaths per
> summer the two hours had before abolition, that fall offsets less than a
> third of the evening rise.

**Depois:**
> Road deaths in that hour fell by 19.4 log points (9.6) in the treated states
> and by 23.5 (9.6) in the control states, so neither group alone isolates an
> effect of the light on the morning.

**Por quê:** é a mesma conta que saiu da introdução na segunda revisão (seção 2).
A queda da manhã nos tratados é igual à dos controles, então não é efeito da
abolição; o apêndice tinha ficado com a versão antiga.

---

## 10. Auditoria das mudanças pós-MPRA (31/10/2026)

Code audit do diff de código (`15`, `23`, `28`, `build/01`) e manuscript audit
do diff de texto, contra `light_dose.rds` e `traffic_volume.rds`.

- **Corrigido, crítico:** a nota `% light_dose.rds, inference.` tinha sido posta
  no meio da linha da Seção 4 (dose) e escondia do PDF duas frases que estavam na
  versão do MPRA: PRF no modelo de dose (79,5, EP 20,6; acidentes 13,6, EP 9,0) e
  pedestres (115,8, EP 29,7, contra 33,6, EP 11,9). A nota foi juntada à do fim da
  linha; as frases voltaram.
- **Corrigido:** no corpo, o tráfego das festas citava os dois níveis e dizia "no
  detectable difference" sem a linha da diferença; entrou "a difference of 2.1
  (standard error 2.4)".
- **Conferido, sem mudança:** os três p-valores novos da Tabela 4 e os dois da
  Tabela 6 batem com o `.rds` (os clusterizados foram recalculados à mão); a
  Tabela B3 de tráfego bate com `parts`; a permutação e o score bootstrap do `23`
  usam os efeitos fixos da especificação principal, 999 e 9.999 sorteios, como a
  Tabela 2 declara; dar dose a todos os estados não muda a dose dos tratados
  (pesos normalizados por estado), e nenhuma estimativa pontual da Tabela 4
  mudou; os efeitos fixos do modelo por parte no `15` repetem os do `20`; o
  resumo tem 99 palavras.
- **Não rodado:** a reprodução do `23` (999 permutações por desfecho). A
  semente é fixada antes dos sorteios, e o `mclapply` não consome números
  aleatórios.

## 11. Notas de tabelas e figuras (31/10/2026)

Revisão das 29 notas (17 tabelas e 12 figuras, paper e apêndice): cada frase da nota contra as linhas, colunas, legendas
e eixos do exibido, e cada número digitado na nota contra o `.rds` ou um
recálculo. Quatro correções, todas só de texto; nenhum número mudou.

- **`tab:road-users` (quem morre), nota.** Dizia "The last row of Panel C also drops
  the Saturday before Carnival…"; a última linha é "Pedestrians, weekends and
  holidays" (traços). Agora: "The row without Carnival and year-end in Panel C
  also drops…". As datas conferem com `holiday_days` (Páscoa −50 a −46; 24/12 a
  1/1).
- **`fig:assault`, nota.** Dizia "by season as in Figure
  [event-study]", mas a figura é contra 2018/19 (`ref = LAST_PRE` no `10`), e a
  do estudo de evento é contra a média das temporadas com horário de verão.
  Agora: "as in Figure [event-study], but relative to 2018/19", as palavras do eixo.
- **`tab:window-parts`, nota.** "57.6 and −12.7" são de mortes na via
  apenas (recalculados: 57,6 e −12,7; rodovias federais 67,7 e 28,8; acidentes
  28,4 e 27,0). Agora: "… are 57.6 and −12.7 for road deaths".
- **`tab:pedestrians`, nota.** A linha "p-value, wild cluster bootstrap" fica
  sob a estimativa Poisson, mas vem do modelo linear (`14`, `boottest` sobre o
  `lm` demeaned), como na Tabela 2. Agora: "Inference as in Table 2, with the
  wild cluster bootstrap p-value from the linear model".

Conferido e certo: 85/10/5 por cento dos outros usuários (V87–V89 85,3; V60–V69
9,5); idade ausente 12 e 6 por cento (11,7 e 5,9); 85 por cento dos óbitos fora
da via em hospital (84,9, LOCOCOR 1); 30 pares de estações; 279 municípios
costeiros; PPP 2,554; "seven hours" de `tab:excess` (−2 a +1 no pôr do sol, −1 a +1
no nascer); legendas, painéis e lados (esquerda/direita, topo/base,
cinza/vermelho) de todas as figuras. Recompilado: 38 + 26 + 1 + 66 páginas, sem
Overfull/Underfull, sem referência indefinida; as quatro frases novas aparecem no
PDF.

## 12. Fontes das bases auxiliares (01/11/2026)

Só documentação; nenhuma estimativa, tabela ou interpretação mudou.

- **Corpo, IV.F (quem morre).** "share of households on unlit streets" virou
  "share of households on block faces without street lighting
  \citep{ibge2023censo}": a variável é municipal, a parcela dos domicílios em
  face de quadra sem iluminação, e não a luz da via do acidente.
- **Corpo, IV.C (robustez).** Os "279 coastal municipalities" ganharam
  `\citep{ibge2022defrontantes}`, antes só na nota da Tabela B1.
- **Apêndice A, nova subseção "Other sources" (`app:other`).** Chuva (célula
  BR-DWGD de 0,1° que contém a sede, a mais próxima com dado para sedes no mar,
  Noronha sem dado; ≥ 1 mm, ponderado pelas mortes antes da abolição);
  iluminação (Censo 2022, pesquisa do entorno nos setores selecionados,
  "não declarado" fora do denominador; Censo 2010, setores urbanos, poste na face
  ou na face oposta); os 279 defrontantes de 2022 sem a Lagoa dos Patos.
  Conferido em `build/08`, `09`, `12` e `analysis/code/23`, `24`. O arquivo de
  pessoas da PRF já estava descrito no A.3 e não foi repetido.
- **Apêndice B.5.** A frase da iluminação usa a mesma definição e remete ao A.

## 13. Figura 2b no período da amostra (01/11/2026)

O painel B de `fig:light` (parcela dos acidentes da PRF registrada como
anoitecer ou noite, tratados, janela de verão) usava as temporadas sem horário
de verão até 2024/25 (`03`, `sy %between% c(2008L, 2024L)`), uma a mais que a
amostra principal (2008/09 a 2023/24). Agora para em 2023/24; legenda "Without
DST, 2019/20–2023/24". Só a tabela de volume (PNCT) segue até 2024/25, de
propósito. O cruzamento de 50% na janela continua em 0 (com horário de verão)
contra −50 minutos (sem); nenhum número do texto vem desse `.rds`. Recompilado:
39 + 26 + 1 + 66 páginas.

## 14. Comentários sobre arredondamento e sobre as 62 mortes (01/11/2026)

Dois comentários recebidos. **Arredondamento** (sem horários redondos, 16,7
com erro-padrão de 12,9): sem mudança no paper. A queda vem só do SIM: as mortes
PRF sem :00/:30 dão 56,1 (26,8) e os acidentes 16,7 (6,4) (`heaping.rds`);
espalhar os horários redondos dá 31,4; e 16,7 não difere de 29,2, porque sobra
menos da metade da amostra.

**As 62 mortes dependem da hipótese de dose zero** (o dia inteiro dá −5 com
erro-padrão de 66, que não descarta a realocação de James, 2023). Três mudanças:

- **Mortes implicadas pelo tráfego** (`25`, seção 3; `tab:excess`, Painel C
  novo). Volume do `15` empilhado nas 11 horas de sol e no resto do dia
  (coeficientes iguais aos do `15`, covariância conjunta), aplicado às mortes
  observadas em cada hora, com risco por veículo constante. Horas cuja luz não
  mudou: na via +15 (31,6); PRF +7,2 (12,5); acidentes +99 (157). Horas cuja
  luz mudou: −4, −1, −16 (só no `.rds`; a linha saiu da tabela para a nota caber
  no `paper_wp`). O resto do dia mudou +2,6 no tráfego (erro-padrão de
  2,0), e as horas da noite vizinhas à hora 0 perderam. O intervalo de 95% na via
  ([−47, 77]) exclui uma queda de 62. Isso cobre só a compensação por viagens
  que mudaram de hora, e só nas rodovias federais. Texto novo no fim de
  `sec:offset` e uma frase na introdução.
- **Fato separado da hipótese.** Na introdução: as 36 mortes a mais na própria
  hora 0 não supõem nada sobre as outras horas, mas a contagem do dia supõe.
  No resumo: "If hours whose light did not change were unaffected, abolition
  added 62 crash-scene deaths each summer" (99 palavras).
- **Valor no limite inferior** (`25`, `lower`). Modelo de dose: 38,8 mortes
  (71 milhões) na janela e 45,6 (83 milhões) na temporada. Três horas
  estimadas uma a uma: 14,9 (27 milhões). Na Seção 5, a economia de combustível
  (96 a 139 milhões) passa do valor da temporada no limite inferior; está dito.

Revisão com `applied-micro-paper-writing` sobre as linhas novas: modificador
solto no resumo ("Assuming ..., abolition" → "If ..."); "Panel C computes" →
"we compute"; frases encadeadas por dois-pontos separadas; "against a net count"
→ "compared with"; "most direct route" → "mechanism"; "its"/"it" com referente.
`manuscript-audit` sobre o diff: números conferidos com `total_cost.rds` e
`reallocation.rds` (36; 15,1 e 31,6; 7,2 e 12,5; 2,60 e 2,03; 38,8, 45,6 e 14,9;
70,9, 83,2 e 27,2 milhões). Dois verbos que o intervalo não sustentava foram
corrigidos ("slightly more deaths, not fewer" virou o aumento de 15 (32) com o
intervalo que exclui a queda; "rose slightly" virou "changed by 2.6 (2.0)"). Um
início repetido ("At ... At") foi desfeito. Um "Float too large" de 37pt na
`tab:excess` do `paper_wp`, criado por esta rodada, saiu encurtando a nota do
Painel C e tirando a linha das horas cuja luz mudou. Recompilado: 40 + 26 + 1 +
67 páginas; zero indefinidas, Overfull \hbox e floats grandes demais nos três
documentos; o fim de cada nota nova aparece no PDF; resumo com 99 palavras; das
17 tabelas, só `tab_excess.tex` mudou.

## O que foi considerado e não entrou

- **Citar Jelnov (2027) como "forthcoming"**: não. O *Journal of Applied
  Economics* já atribuiu volume 30(1), que é o de 2027.
- **Teste de deslocamento numa janela intermediária de horas**: não. A janela de
  7 horas já tem EP 41, e uma intermediária dificilmente teria precisão para
  mudar a leitura.
- **Contagens das praças de pedágio da ANTT**: não. As praças ficam quase todas
  em estados tratados, então não servem para a tripla diferença.
- **"SIM menos PRF" como proxy de vias não federais**: não. As duas bases não
  casam óbito a óbito, então a subtração por estado, dia e hora pode dar
  negativa e soma os erros das duas bases.
- **Temporada 2024/25**: fica para quando o SIM 2025 for definitivo; não é
  pré-requisito para submeter.
- **Divisão capital/região metropolitana no SIM**: opcional, para uma tabela de
  apêndice numa versão futura.
- **Decompor o 19,7 do controle (Tabela B4) e olhar a hora −1**: feito fora do
  paper (31/10/2026; conta avulsa com o modelo do `09` por grupo, sem
  `uf^bin^sy`, que a perna sozinha não comporta; a tripla reproduz o 19,7). Mortes
  na via no controle, hora 0: janela +11,1 (5,6), fora da temporada −9,5 (7,3).
  Hora −1: janela −11,1 (8,6), fora −18,6 (9,6), tripla +6,8 (10,9). Nos tratados,
  a hora 0 vem quase toda do verão (janela +41,5, fora −5,2). Leitura: na janela, o
  controle mostra a assinatura de deslocamento (−1 cai, 0 sobe), mas a hora −1 cai
  ainda mais fora do verão, quando Brasília não mudava nada para o controle; e
  metade do 19,7 é a hora 0 caindo fora da temporada. Não confirma nem descarta o
  canal dos horários de Brasília. Não entra no paper: o texto já diz "to the extent
  that", o viés possível é conservador, e pôr as pernas na Tabela B4 pediria
  mexer no `09`, no `15` (veículos) e no `28` por um resultado que não muda a
  frase.
