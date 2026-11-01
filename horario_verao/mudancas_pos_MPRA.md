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
> count or rule it out. Within the treated states alone, the decline in deaths
> in the morning hour that turned light offsets less than a third of the rise in
> the evening hour (Online Appendix Table B4).

**Por quê:** a frase final antiga contradizia a anterior: o parágrafo dizia que
o dia inteiro é impreciso demais e logo fechava como se o dia inteiro tivesse
confirmado a ausência de compensação. Agora o parágrafo fecha com a evidência
que de fato sustenta a comparação manhã-noite (já estava no apêndice: dentro dos
tratados, −19,4 log pts na manhã contra +47,2 na noite). O p da permutação
responde à pergunta previsível de por que a inferência robusta só aparecia na
hora 0.

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
  horas estimadas, não do saldo do dia.
- **Tabela 6**: duas linhas novas abaixo da contagem líquida, "p-value,
  clustered by state" (pelo EP do método delta: <0,001, 0,008, 0,448) e
  "p-value, permutation of treated states": 0,001 (mortes na via), 0,135 (mortes na PRF), 0,627
  (acidentes na PRF). A nota ganhou uma frase sobre o teste e outra dizendo por
  que só há permutação: a contagem é uma função não linear dos dois
  coeficientes, então não há modelo restrito para o score wild bootstrap nem
  análogo linear para o wild cluster bootstrap da Tabela 2.
- **Texto**: "(standard error 12)" virou "(standard error 12; permutation
  $p=0.001$)".

## 6. Seção 4 (transições e partes da janela) — o nulo de 24/12 a 15/01

**Antes:**
> These checks do not rule out holiday travel as an explanation, and the data do
> not say why no increase is detectable in those weeks.

**Depois:**
> Traffic on federal highways did not change differently in those weeks.
> Vehicles in hour 0 fell by about as much from December 24 to January 15 as in
> the school weeks, and neither trucks and buses in that hour nor the day's
> traffic differed between the two periods (Online Appendix Table B3). These checks do not rule out holiday travel on other roads as
> an explanation, and the data do not say why no increase is detectable in those
> weeks.

**Por quê:** o nulo de fim de ano era a parte mais solta do texto. A hipótese
óbvia (viagens de férias mudam o tráfego no início da noite) era testável com
dados que o paper já tem. O teste não a sustenta nas rodovias federais, e o
texto agora diz isso e limita a ressalva às outras vias.

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

---

## O que foi considerado e não entrou

- **Citar Jelnov (2027) como "forthcoming"**: não. O *Journal of Applied
  Economics* já atribuiu volume 30(1), que é o de 2027.
- **Teste de deslocamento numa janela intermediária de horas**: não. A janela de
  7 horas já tem EP 41, e uma intermediária dificilmente teria precisão para
  mudar a leitura.
- **Contagens das praças de pedágio da ANTT**: não. As praças ficam quase todas
  em estados tratados, então não servem para a tripla diferença.
- **"SIM menos PRF" como proxy de vias não federais**: não. As duas bases não
  casam óbito a óbito, e o SIM registra o local do óbito.
- **Temporada 2024/25**: fica para quando o SIM 2025 for definitivo; não é
  pré-requisito para submeter.
- **Divisão capital/região metropolitana no SIM**: opcional, para uma tabela de
  apêndice numa versão futura.
