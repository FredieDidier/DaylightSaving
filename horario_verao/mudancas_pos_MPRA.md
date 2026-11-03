# Mudanças no paper e no apêndice desde a versão do MPRA

Versão de referência: a depositada no MPRA (MPRA 131638), commit `88e60cc` de
30/10/2026. Em 03/11/2026 o PDF do depósito foi trocado pelo do commit `6544124`
(02/11/2026), que já traz tudo o que está abaixo; mudanças posteriores contam a
partir de `6544124`. Abaixo está **cada trecho que mudou**, na ordem do paper, com o texto
da versão do MPRA ("Antes") e o texto atual ("Depois"), em inglês como no paper.
Trechos novos aparecem com "Antes: —". A lista foi tirada do diff, frase a frase,
de `abstract.tex`, `body.tex`, `appendix_body.tex`, `title_page.tex`,
`paper_wp.tex`, `preamble_aea.tex` e das tabelas geradas, entre `88e60cc` e o
commit atual. Comentários de procedência (`% …`), que não aparecem no PDF, ficaram
de fora.

Nenhuma estimativa pontual que já estava no paper mudou. As mudanças vieram de um
parecer simulado no padrão da AEJ: Policy (aceito em parte), de comentários sobre
as 62 mortes e de revisões do texto e das notas.

---

## Resumo (abstract)

**Antes:**
> The effect follows the local sun, not the clock, and the brighter mornings did
> not offset it: abolition added an estimated 62 deaths at the crash scene in
> each 92-day summer window, from mid-November to mid-February.

**Depois:**
> The effect follows the local sun, not the clock, and the brighter mornings
> showed no detectable decline in deaths. If hours whose light did not change
> were unaffected, abolition added 62 crash-scene deaths each summer,
> mid-November to mid-February.

**Por quê:** "did not offset it" falava do saldo do dia, que, sem hipótese, tem
EP 66 e não confirma nem descarta os 62. O que foi estimado é que a hora da manhã
não caiu de forma detectável; o 62 depende da hipótese das horas de dose zero, e
agora o resumo diz isso. O resumo tem 99 palavras.

## Introdução

### Parágrafo dos resultados da manhã e da contagem líquida

**Antes:**
> When every hour of the day is weighted by how much its light changed, and hours
> that remained in full daylight or full darkness are assumed unaffected,
> abolition added 62 road deaths per summer window, from November 15 to
> February 14 (standard error 12).

**Depois:**
> In the hour that turned dark, road deaths exceeded the counterfactual by 36 per
> summer window, an estimate that requires no assumption about the other hours of the
> day. A count for the whole day needs one. When every hour of the day is
> weighted by how much its light changed, and hours that remained in full
> daylight or full darkness are assumed unaffected, abolition added 62 road
> deaths per summer window, from November 15 to February 14 (standard error 12;
> permutation $p=0.001$).

**Por quê:** veio o comentário de que as 62 mortes dependem da hipótese de que as
horas de dose zero não mudaram. As 36 mortes da hora 0 não dependem dela, e o
parágrafo não as citava. Agora o leitor vê primeiro o número que não supõe nada
sobre as outras horas, e "A count for the whole day needs one" anuncia a hipótese
antes de usá-la. O p da permutação entra porque só a hora 0 tinha inferência
robusta a poucos clusters (23 estados), e o 62 é o número do resumo.

**Antes:**
> This is the count most directly supported by the observed summer window.
> Extended to the full DST season, the estimate is 74 deaths (standard error
> 14). These counts include only deaths at the crash scene with a recorded time;
> scaling them to deaths without a recorded time and to deaths off the road,
> most of them in hospitals, raises the summer-window count to between 77 and
> 157. Estimated over the whole day without assuming which hours were affected,
> the change is too imprecise (standard error 66) to confirm the count or rule
> it out. The brighter morning did not give these deaths back.

**Depois:**
> The count includes only deaths at the crash scene with a recorded time.
> Estimated over the whole day without assuming that hours whose light did not
> change were unaffected, the change is too imprecise to confirm the count or
> rule it out. A decline in deaths in the hours whose light did not change, large
> enough to cancel the count, could come from trips moving out of those hours,
> but the traffic counts show no such shift. They cannot exclude a smaller
> decline (Section~\ref{sec:offset}). In the model that weights each
> hour by its change in light, a given change in darkness has a larger effect on
> road deaths in the evening than in the morning (permutation $p=0.001$).

**Por quê:**
- O parágrafo tinha nove resultados seguidos (−3, 36, 62, 74, 77–157, EP 66,
  15 com EP 32, "três quartos", p da permutação), e quem lê pela primeira vez
  não sabia qual guardar. A introdução fica com a cadeia principal: 36 na hora 0,
  62 sob a hipótese das horas de dose zero, a ressalva de que o dia inteiro não
  confirma nem descarta, e o teste noite contra manhã. O 74 da temporada, o
  77–157 do escalonamento, o EP 66 e o 15 (32) do tráfego com os "três quartos"
  ficam na IV.H e na Seção V, onde já estavam com a explicação.
- A ressalva continua: a hipótese tem nome, o dia inteiro aparece como
  impreciso, e "cannot exclude a smaller decline" guarda o que os "três
  quartos" diziam, com o número na IV.H. A frase do tráfego é a que já estava
  aprovada ("A decline in deaths [...] no such shift"). Uma versão intermediária
  ("no shift of trips [...] that would cancel it, although they cannot exclude a
  partial offset") saiu na conferência com a skill de escrita: "that would
  cancel it" podia se ligar a "hours", o "it" voltava duas frases, e "partial
  offset" não dizia o que cai nem onde.
- "without assuming that hours whose light did not change were unaffected"
  continua por extenso, e não "without that assumption": a frase anterior agora
  é a das mortes com horário registrado, e "that assumption" poderia se ligar a
  ela.
- Saiu "This is the count most directly supported by the observed summer
  window": dizia de novo o que "per summer window, from November 15 to
  February 14" já diz.
- Saiu "The brighter morning did not give these deaths back": contradizia a
  frase anterior, porque o dia inteiro é impreciso demais para mostrar que a
  manhã não compensou.

### Parágrafo do custo (introdução)

**Antes:**
> […] rising to 287 million under the broadest scaling.

**Depois:**
> […] rising to 287 million when the count is scaled to deaths without a
> recorded time and off the road.

**Por quê:** "the broadest scaling" se apoiava no 77–157 do parágrafo anterior,
que saiu da introdução. A frase agora diz qual escalonamento dá o 287.

### Segunda contribuição

**Antes:**
> Second, because the hour that turned dark is set by the local sun, the design
> separates the effect of light from the effects of the clock and of sleep, and
> it shows that the light gained in the morning does not offset the light lost
> in the evening.

**Depois:**
> Second, because the hour that turned dark is set by the local sun, the design
> separates the effect of light from the effects of the clock and of sleep, and
> it shows that the evening hour that lost light became deadlier while the
> morning hour that gained light did not become detectably safer.

**Por quê:** "does not offset" fala do saldo do dia, que o paper não estima com
precisão (EP 66). A frase nova diz as duas coisas que o desenho identifica: a hora
da noite que perdeu luz ficou mais letal, e a hora da manhã que ganhou luz não
ficou detectavelmente mais segura.

## Seção IV.B — Deaths in the hour that turned dark

**Antes:**
> […] after it, observed deaths exceed the counterfactual by 36 per summer in
> that hour alone, before any offset elsewhere in the day.

**Depois:**
> […] after it, observed deaths exceed the counterfactual by 36 per summer window
> in that hour alone, before any offset elsewhere in the day
> (Table~\ref{tab:excess}, Panel B).

**Por quê:** as 36 mortes não tinham tabela; agora estão na linha "Hour after
sunset" da Tabela 6. "Per summer window", como no 62 da mesma tabela, deixa
claro que as duas contagens têm a mesma unidade (15/11 a 14/02).

## Seção IV.C — Trends and robustness

**Antes:**
> […] and leaving out the 279 coastal municipalities, the destinations of summer
> beach trips (36.3, 9.4; […]).

**Depois:**
> […] and leaving out the 279 coastal municipalities
> \citep{ibge2022defrontantes}, the destinations of summer beach trips (36.3,
> 9.4; […]).

**Por quê:** a fonte da lista dos municípios defrontantes só aparecia na nota da
Tabela B1.

### Arredondamento dos horários e janela deslocada

**Antes:**
> Shifting the hour 0 window by 5 to 15 minutes moves the estimate in the
> direction light predicts: it is larger when the window starts later and the
> hour is darker. Spreading each death recorded on the hour or half hour evenly
> over the 30 minutes around its recorded time gives 31.4 log points (9.5);
> dropping those deaths altogether leaves 16.7 (12.9), with less than half the
> sample (Online Appendix Figure~\ref{fig:window-shift}).

**Depois:**
> Shifting the hour 0 window by 5 to 15 minutes moves the estimate in the
> direction light predicts, but each shift also moves heaps of recorded times
> into or out of the window. Spreading each death recorded on the hour or half
> hour evenly over the 30 minutes around its recorded time gives 31.4 log points
> (9.5) in hour 0. With the times spread, the estimate rises at every step, from
> 15.8 (9.2) for a window that starts 15 minutes before standard-time sunset to
> 40.4 (9.2) for one that starts 15 minutes after it (Online Appendix
> Figure~\ref{fig:window-shift}). Dropping the deaths recorded on the hour or
> half hour altogether leaves 16.7 (12.9), with less than half the sample.

**Por quê:** um comentário levantou três leituras da janela deslocada. (1) A −15
o efeito cai para 14,6 (EP 11,3) e perde significância, o que pode ser lido como
dependência da definição. (2) "It is larger when the window starts later" é mais
forte que a sequência com os horários como registrados: 14,6; 23,9; 25,9; 29,2;
35,3; 46,7; 41,2, com pico em +10. (3) Deslocar a janela muda quais picos de
arredondamento (hora cheia, meia hora) entram nela, e o paper tratava o
arredondamento e o deslocamento separadamente. O `19_heaping.R` agora estima a
variante espalhada em cada deslocamento. Com os horários espalhados, a sequência
sobe em todos os passos nos três desfechos: mortes na via 15,8; 21,7; 26,9; 31,4;
35,8; 38,6; 40,4; mortes da PRF 21,0 a 72,3; acidentes com vítima 3,5 a 32,4.
O pico em +10 vinha do arredondamento. Nenhuma estimativa que já estava no paper
mudou; a Tabela B1 é a mesma.

**Acréscimo, Apêndice B.1 (depois da sequência espalhada):**
> Spreading smooths the counts across the window by construction, so the rise
> could partly come from the correction itself. Dropping the rounded times
> instead assumes nothing about where they fell, and the estimate still rises at
> every step for all three outcomes, from $-8.3$ (15.9) to 41.6 (10.6) for road
> deaths, with less than half the deaths.

**Por quê:** espalhar é uma suavização e pode, por si só, produzir uma subida
monotônica; um parecerista pode atribuir a sequência à correção. Excluir os
horários arredondados não supõe onde eles caíram. O `19_heaping.R` agora estima a
variante "drop" em cada deslocamento, não só na hora 0. Mortes na via: −8,3
(15,9); 4,2; 8,4; 16,7; 25,6; 36,1; 41,6 (10,6). Mortes da PRF: 18,4 a 87,0.
Acidentes com vítima: −3,4 a 28,6. Sobe em todos os passos nos três desfechos.
Fica só uma frase no apêndice, sem série nova na Fig. B1: a amostra tem menos da
metade das mortes e muda de composição, e o −8,3 sem o EP convidaria a uma
leitura errada. As linhas que já existiam no `heaping.rds` saíram idênticas
(diferença máxima de 2e-13); as tabelas e as figuras não mudaram. O dicionário
de dados não muda: ele documenta as bases do build, e nem este commit nem os dois
anteriores (a83f838, 466caae) tocam o build.

## Seção IV.D — Light, not the clock (Tabela 4)

### Tabela 4

**Antes:** uma linha de p-valor no Painel B:
> Evening equals morning, p-value & <0.001 & 0.035 & 0.715

**Depois:** três linhas novas no Painel A e duas no Painel B:
> Baseline: p-value, clustered by state & <0.001 & <0.001 & 0.131
> Baseline: p-value, permutation of treated states & 0.002 & 0.031 & 0.470
> Baseline: p-value, score wild bootstrap & <0.001 & 0.003 & 0.149
> Evening equals morning, p-value, clustered by state & <0.001 & 0.035 & 0.715
> Evening equals morning, p-value, permutation & 0.001 & 0.139 & 0.762

**Por quê:** com 23 clusters, o EP clusterizado pode rejeitar demais. O paper já
reportava permutação e score wild bootstrap para a hora 0 (Tabela 2), mas não para
o modelo de dose, que é o que separa a luz do relógio e de onde vem o 62. As
linhas novas seguem o formato da Tabela 2. A linha antiga "Evening equals
morning, p-value" ganhou "clustered by state" porque agora há dois p-valores para
o mesmo teste.

### Nota da Tabela 4

**Antes:** —

**Depois:**
> The permutation and score wild bootstrap p-values are computed for the
> baseline as in Table~\ref{tab:main}; in each permutation draw, the 11 states
> drawn as treated receive their own doses, and the test of equal evening and
> morning effects uses the t-statistic of their difference.

**Por quê:** no modelo de dose, o tratamento não é 0 ou 1, é a dose de cada
estado. Sem a nota, o leitor não saberia o que um estado sorteado como tratado
recebe na permutação; a resposta é a dose dele próprio, calculada pelo sol das
suas sedes. O teste de noite igual a manhã usa a estatística t da diferença pela
mesma razão da Tabela 2: os estados têm tamanhos muito diferentes.

### Texto

**Antes:**
> For the same change in darkness, the morning coefficient is $-6.4$ (14.7),
> which differs from the evening's ($p<0.001$).

**Depois:**
> For the same change in darkness, the morning coefficient is $-6.4$ (14.7),
> which differs from the evening's ($p<0.001$; permutation $p=0.001$). The
> baseline evening effect remains significant under the permutation test
> ($p=0.002$) and the score wild bootstrap ($p<0.001$).

**Por quê:** o texto passa a citar os p-valores robustos que a Tabela 4 agora
mostra. Quem desconfia do EP clusterizado com 23 clusters vê no próprio parágrafo
que o efeito da noite e a diferença entre noite e manhã resistem.

## Seção IV.F — Who dies

### Nota da Tabela 5

**Antes:**
> Inference as in Table~\ref{tab:main}; in each permutation draw both members of
> the pair receive the same set of treated states, […]

**Depois:**
> Inference as in Table~\ref{tab:main}, with the wild cluster bootstrap p-value
> from the linear model; in each permutation draw both members of the pair
> receive the same set of treated states, […]

**Por quê:** a linha do wild cluster bootstrap fica sob a estimativa Poisson, mas
vem do modelo linear, como na Tabela 2.

### Iluminação

**Antes:**
> When the municipalities of each state are split at the median share of
> households on unlit streets, the estimate is 42.5 log points (10.0) […]

**Depois:**
> When the municipalities of each state are split at the median share of
> households on block faces without street lighting \citep{ibge2023censo}, the
> estimate is 42.5 log points (10.0) […]

**Por quê:** a variável é municipal (domicílios em face de quadra sem
iluminação), não a luz da via do acidente.

## Seção IV.H — The morning hour does not offset the evening hour (Tabela 6)

### Título

**Antes:**
> The morning does not offset the evening

**Depois:**
> The morning hour does not offset the evening hour

**Por quê:** o título passa a falar das horas estimadas, não do saldo do dia.

### Tabela 6

**Antes:** —

**Depois:** no Painel A, abaixo da contagem líquida:
> p-value, clustered by state & <0.001 & 0.008 & 0.448
> p-value, permutation of treated states & 0.001 & 0.135 & 0.627

no Painel B, primeira linha:
> Hour after sunset & 36 (10) & 24 (7) & 112 (25)

e um Painel C novo:
> Panel C. Implied by the change in traffic alone, at an unchanged risk per vehicle
> Hours whose light did not change & 15 (32) & 7 (12) & 99 (157)
> Hours whose light changed & −4 (15) & −1 (6) & −16 (55)

As contagens do Painel C são por janela de verão, como as do Painel A.

**Por quê:**
- Os dois p-valores da contagem líquida: o 62 é o número do resumo e não tinha
  inferência robusta a poucos clusters. Como na Tabela 2, o clusterizado fica ao
  lado da permutação.
- "Hour after sunset" no Painel B: as 36 mortes da hora 0 são citadas na
  introdução e na Seção IV.B e não estavam em nenhuma tabela.
- Painel C, "Hours whose light did not change": é o teste da compensação por
  viagens que mudaram de hora, que responde ao comentário sobre a hipótese do 62.
- Painel C, "Hours whose light changed": mostra que o tráfego sozinho não explica
  o aumento nas horas que escureceram (−4, EP 15). O aumento veio do risco por
  viagem.

### Nota da Tabela 6

**Antes:** —

**Depois:**
> Panel C: observed events in each hour times $1 - e^{-v}$, where $v$ is the
> change in that hour's federal highway traffic (column 1 of Online Appendix
> Table~\ref{tab:volume}, every hour and the rest of the day in one model); the
> hours whose light changed are the two after sunset and the hour before and
> after sunrise.

**Por quê:** diz como o Painel C é calculado (contagem observada vezes
$1 - e^{-v}$, isto é, risco por veículo constante), de onde vem $v$ e quais horas
contam como "cuja luz mudou", para que o painel possa ser reproduzido.

> The clustered p-value of the net count uses its delta-method standard error.
> The permutation p-value of the net count compares its ratio to its
> delta-method standard error with the same ratio in 999 draws of 11 treated
> states, each with its own doses. The net count is a nonlinear function of both
> coefficients, so it has no restricted model for the score wild bootstrap and no
> linear analogue for the wild cluster bootstrap of Table~\ref{tab:main}.

**Por quê:** diz como cada p-valor novo da Tabela 6 é calculado. A última frase
responde de antemão por que a contagem não tem os dois bootstraps da Tabela 2: ela
é função não linear de dois coeficientes, então não há modelo com a nula imposta
para o score bootstrap nem versão linear para o wild cluster bootstrap.

**Antes (fontes):**
> \citet{datasus2025sim}; \citet{prf2025dados}.

**Depois (fontes):**
> \citet{datasus2025sim}; \citet{prf2025dados}; \citet{dnit2025pnct}.

**Por quê:** o Painel C usa as contagens de tráfego do PNCT. A linha "Sources"
lista a fonte de todo dado usado na tabela.

### Texto

**Antes:**
> Panel D of Table~\ref{tab:robustness} finds no detectable change at midday or
> at night, but with about 580 road deaths a summer in each, its confidence
> intervals also include a fall as large as the net count.

**Depois:**
> Panel D of Table~\ref{tab:robustness} finds no detectable change at midday or
> at night. Each of these blocks had only about 580 road deaths with a recorded
> time per summer window in the treated states before abolition, so their
> confidence intervals also include a fall as large as the net count.

**Por quê:** um comentário disse que não estava claro o que eram as 580 mortes.
São as mortes na via com hora registrada em cada bloco (meio-dia 585, noite 572)
por janela de verão, nos estados tratados antes da abolição (`placebo_hours.rds`).
"In each" não dizia a que "each" se referia; a frase agora nomeia os blocos e diz
que o número pequeno é a razão dos intervalos largos.

**Antes:**
> Abolition added 62 road deaths per summer window (standard error 12): 57 in
> the evening hours that grew darker, […]

**Depois:**
> Abolition added 62 road deaths per summer window (standard error 12;
> permutation $p=0.001$): 57 in the evening hours that grew darker, […]

**Por quê:** o texto passa a citar o p da permutação que a Tabela 6 agora mostra,
como já fazia com a hora 0.

**Antes:**
> On federal highways, the dose model implies 31 deaths (12) per summer; injury
> crashes, whose response to darkness is weaker, net 43 (57).

**Depois:**
> On federal highways, the dose model implies 31 deaths (12; permutation
> $p=0.135$) per summer; injury crashes, whose response to darkness is weaker,
> net 43 (57). An offset would require deaths to fall in the hours whose light
> did not change, the reallocation across hours that \citet{james2023let} finds
> in Australia. The most direct mechanism for such an offset
> would be trips moved out of the hours whose light did not change. In Panel C of Table~\ref{tab:excess}, we compute the
> deaths that the change in federal highway traffic would imply in each hour if
> the risk per vehicle had stayed the same. Traffic fell in the evening hours
> adjacent to hour 0 and changed by 2.6 log points (standard error 2.0) over the
> rest of the day. In the hours whose light did not change, the implied change
> is an increase of 15 road deaths per summer (standard error 32). Its 95
> percent confidence interval, from a decline of about 47 deaths to an increase
> of about 77, excludes a decline as large as the net count of 62 but not a
> partial offset of up to about three quarters of it. For federal highway deaths, which the stations cover, the implied change
> is 7 (12), compared with a net count of 31. In the hours whose light changed,
> the traffic alone would imply 4 fewer road deaths (standard error 15), so the
> increase in those hours came from a higher risk per trip, not from more trips.
> This calculation addresses only offsets that arise from changes in when people
> travel, not changes in the risk of a trip. Nor does it cover urban streets,
> where many pedestrian deaths occur, because the stations count only federal
> highways.

**Por quê:**
- "permutation $p=0.135$" nas mortes da PRF: o p da permutação está na tabela e
  não é significativo. Citar no texto só o da via pareceria seletivo.
- O parágrafo novo apresenta o Painel C. Diz o que uma compensação exigiria
  (mortes caindo nas horas cuja luz não mudou) e dá os números da via e da PRF
  (a PRF é a base que as estações cobrem). Usa a linha das horas que mudaram para
  mostrar que o aumento veio do risco por viagem. Termina com os dois limites do
  teste: só cobre mudança no horário das viagens, e só rodovias federais, não as
  vias urbanas, onde morre boa parte dos pedestres.
- O intervalo (−46,8 a 77,0) e a compensação parcial que ele não exclui: mesmo
  comentário da introdução. Aqui o texto dá os dois extremos, para o leitor ver
  de onde vêm os três quartos.
- "trips moved out of those hours": uma versão intermediária dizia "trips moved
  from the dark hour to those hours". Viagens que entram nas horas cuja luz não
  mudou aumentariam as mortes nelas, não diminuiriam; o mecanismo tinha o sinal
  errado e contradizia a introdução. Para as mortes caírem nessas horas, as
  viagens têm de sair delas.
- A frase do James (2023): a compensação que o parágrafo testa é o resultado
  publicado mais próximo contra a contagem do dia, e até aqui ele só aparecia na
  revisão de literatura. A introdução já descreve o resultado dele, então a
  IV.H só o nomeia como o caso testado ("the reallocation across hours that
  \citet{james2023let} finds in Australia"), sem recontá-lo; uma versão
  intermediária repetia o resultado inteiro. O resumo do artigo não atribui a
  realocação a viagens que mudaram de horário, então a citação fica na frase da
  realocação e não na do mecanismo.

**Antes:**
> Events per summer in the treated states after abolition minus those predicted
> without it; delta-method standard errors in parentheses.

**Depois:**
> Events per summer in the treated states after abolition minus those predicted
> without it; delta-method standard errors in parentheses, from coefficients with
> standard errors clustered by state.

**Por quê:** o erro-padrão do método delta vem da matriz de covariância dos coeficientes, que é agrupada por estado. Sem dizer isso, a nota deixava em aberto o agrupamento, que as outras tabelas declaram.

## Seção IV.I — Before and after travel adjusted

**Antes:**
> These checks do not rule out holiday travel as an explanation, and the data do
> not say why no increase is detectable in those weeks.

**Depois:**
> Traffic on federal highways shows no detectable difference between the two
> periods. Vehicles in hour 0 fell by 7.4 log points from December 24 to January
> 15 and by 5.3 in the school weeks, a difference of 2.1 (standard error 2.4),
> and the same holds for trucks and buses in that hour and for the day's traffic
> (Online Appendix Table~\ref{tab:traffic-parts}). These checks do not rule out
> holiday travel on other roads as an explanation, and the data do not say why
> no increase is detectable in those weeks.

**Por quê:** a hipótese das viagens de fim de ano era testável com o PNCT. O
teste não a sustenta nas rodovias federais, e a ressalva fica para as outras vias.

## Seção V — What Abolition Cost

### Nota da Tabela 7

**Antes:**
> Delta-method standard errors in parentheses.

**Depois:**
> Delta-method standard errors in parentheses, from coefficients with standard
> errors clustered by state.

**Por quê:** o erro-padrão do método delta vem da matriz de covariância dos coeficientes, que é agrupada por estado. Sem dizer isso, a nota deixava em aberto o agrupamento, que as outras tabelas declaram.

### Texto

**Antes:** —

**Depois:**
> If the summer-window count is set at the lower end of its 95 percent
> confidence interval, 39 deaths, the cost is 71 million. For the two evening
> hours and the morning hour estimated one at a time (Panel B of
> Table~\ref{tab:excess}), whose sum does not impose the dose model's weighting
> of hours, the lower end is 15 deaths, or 27 million.

**Por quê:** a conta de custo usava só a estimativa pontual de um número que
depende de uma hipótese e tem erro amostral. O limite inferior do intervalo de 95%
mostra o menor custo que o intervalo admite. A soma das duas horas da noite e da
hora da manhã, estimadas uma a uma, mostra o mesmo sem os pesos de luz do modelo
de dose. Uma versão intermediária dizia "the three hours" sem dizer quais nem onde
estão; agora a frase as nomeia e aponta para a linha da Tabela 6.

**Antes:**
> The fuel savings are of the same order as the value of the deaths of a DST
> season in column 1 of Table~\ref{tab:cost}.

**Depois:**
> The fuel savings are of the same order as the value of the deaths of a DST
> season in column 1 of Table~\ref{tab:cost}, and exceed the value at the lower
> end of its confidence interval, 83 million.

**Por quê:** no limite inferior, o valor das mortes de uma temporada (83 milhões)
fica abaixo da economia de combustível (96 a 139 milhões). Sem essa frase, o texto
deixaria a impressão de que o lado das mortes pesa sempre ao menos tanto quanto o
da energia.

## Conclusão

**Antes:**
> When Brazil stopped moving its clocks, the evening hour that lost its sunlight
> became deadlier on the road, disproportionately for pedestrians, and the
> morning hour that gained light did not compensate for it.

**Depois:**
> When Brazil stopped moving its clocks, the evening hour that lost its sunlight
> became deadlier on the road, disproportionately for pedestrians, and the
> morning hour that gained light did not become detectably safer.

**Por quê:** "did not compensate for it" é uma afirmação sobre o saldo do dia, que
sem hipótese tem EP 66. A frase nova diz o que foi estimado para a hora da manhã,
com as mesmas palavras da contribuição na introdução.

**Antes:**
> Within these limits, darker evenings cost lives on the road that brighter
> mornings do not return, and a disproportionate share of those lives are
> pedestrians, whom street lighting and road design can protect when the clock
> does not.

**Depois:**
> Within these limits, the evening hour that lost its light became deadlier on
> the road, deaths in the morning hour that gained it did not detectably
> decline, and a disproportionate share of the lives lost are pedestrians, whom
> street lighting and road design can protect when the clock does not.

**Por quê:** "lives on the road that brighter mornings do not return" também fala
do saldo do dia. A frase nova separa as duas horas, diz de cada uma o que foi
estimado e mantém o fecho sobre pedestres e iluminação.

---

## Apêndice A — Data and Measurement

### A.6 Other sources (subseção nova)

**Antes:** —

**Depois:**
> Rain comes from the BR-DWGD daily precipitation grid at 0.1 degree
> \citep{xavier2022new}. Each municipal seat takes the cell that contains it; a
> coastal seat whose cell lies over the sea takes the nearest cell with data,
> and Fernando de Noronha, outside the grid, has none. The rain share of a
> state-day (Panel B of Table~\ref{tab:sensitivity}) is the share of the state's
> municipalities, weighted by their road deaths before abolition, with at least
> 1 mm of rain at the seat that day. Street lighting in 2022 comes from the
> Census survey of the surroundings of households, which covers the tracts
> selected for it \citep{ibge2023censo}. The measure is the share of occupied
> private households on a block face without public lighting, out of those for
> which lighting was recorded as present or absent. In 2010 the Census recorded,
> for each block face with households, whether there was a light pole on that
> face or the one opposite \citep{ibge2011censo}; the 2010 measure is the same
> share in urban tracts. Table~\ref{tab:lighting} splits the municipalities of
> each state at the median of this share. The coastal municipalities are the 279
> that IBGE lists as facing the sea in 2022 \citep{ibge2022defrontantes}; the
> list also includes the Lagoa dos Patos, a lagoon coded like a municipality,
> which is left out.

**Por quê:** chuva, iluminação e litoral entravam nas estimativas sem a fonte e a
construção descritas.

## Apêndice B — Additional Results

### B.1 Other windows, samples, and clocks — Figura B1, nota e parágrafo

**Figura B1:** passa a ter três séries por deslocamento, "Times as recorded",
"Rounded times spread over 30 minutes" e "Without rounded times" (os mesmos
nomes das linhas da Tabela B1).

**Nota da Figura B1, Antes:**
> Each point is equation~(\ref{eq:main}) for a 60-minute window that starts the
> stated number of minutes after standard-time sunset; 0 is hour 0 of
> Table~\ref{tab:main}. 95 percent confidence intervals, standard errors
> clustered by state.

**Depois:**
> […] 0 is hour 0 of Table~\ref{tab:main}. Rounded times spread over 30
> minutes: each event recorded on the hour or half hour counts in the window in
> proportion to the part of the 30 minutes around its recorded time that falls
> inside it. Without rounded times: events recorded on the hour or half hour are
> dropped. 95 percent confidence intervals, standard errors clustered by state.

**Parágrafo, Antes:**
> Moving the window changes the estimate in the direction light predicts: a
> window that starts 15 minutes before standard-time sunset includes minutes
> that were light in both regimes and yields 14.6 log points for road deaths,
> and one that starts 15 minutes after it is darker throughout and gives 41.2
> (Figure~\ref{fig:window-shift}). Spreading the times recorded on the hour or
> half hour moves the estimate to 31.4 (9.5), and dropping them 16.7 (12.9),
> with less than half the deaths in hour 0 (Table~\ref{tab:measurement}).

**Depois:**
> Moving the window changes the estimate in the direction light predicts. A
> window that starts 15 minutes before standard-time sunset includes minutes
> that were light in both regimes and yields 14.6 log points for road deaths,
> and one that starts 15 minutes after it is darker throughout and gives 41.2
> (Figure~\ref{fig:window-shift}). With times as recorded, the estimate for road
> deaths does not rise at every step: it is 46.7 for a window that starts 10
> minutes after standard-time sunset, above the 41.2 at 15 minutes. Each shift
> also moves heaps of times recorded on the hour or half hour into or out of the
> window. When those times are spread evenly over the 30 minutes around them,
> the estimate rises at every step for all three outcomes, from 15.8 (9.2) to
> 40.4 (9.2) for road deaths. Spreading smooths the counts across the window by
> construction, so the rise could partly come from the correction itself.
> Dropping the rounded times instead assumes nothing about where they fell, and
> the estimate still rises at every step for all three outcomes, from $-8.3$
> (15.9) to 41.6 (10.6) for road deaths, with less than half the deaths. In hour
> 0 itself, spreading the rounded times moves the estimate to 31.4 (9.5), and
> dropping them gives 16.7 (12.9) (Table~\ref{tab:measurement}).

**Por quê:** o mesmo comentário da Seção IV.C. O apêndice mostra o pico em +10
com os horários como registrados, em vez de deixá-lo para o parecerista, e diz
que ele some quando o arredondamento é separado do deslocamento. A frase da
janela a −15 fica: ela já explica que esses minutos estavam claros nos dois
regimes, então um efeito menor ali é o que a luz prevê, e não sinal de que o
resultado depende da escolha da janela. Espalhar os horários redondos suaviza
a contagem por construção; descartá-los não supõe nada sobre onde caíram, e a
estimativa também sobe a cada passo nos três desfechos (mortes na via de −8,3
a 41,6), agora visível na Figura B1 em vez de só citada no texto.

### B.1 Other windows, samples, and clocks — nota da Tabela B2

**Antes:**
> […] in this model the two effects of Panel A, not repeated in Panel B, are
> 57.6 and $-12.7$.

**Depois:**
> […] in this model the two effects of Panel A, not repeated in Panel B, are
> 57.6 and $-12.7$ for road deaths.

**Por quê:** os dois números são só da coluna das mortes na via.

### B.1 — Tabela B3 e parágrafo (novos)

**Antes:** —

**Depois:** Tabela B3, "Federal Highway Traffic in Parts of the Summer Window"
(as tabelas seguintes do apêndice sobem um número):

| | Hour after sunset, all vehicles | Hour after sunset, heavy vehicles | Whole day, all vehicles |
|---|---|---|---|
| November 15 to December 7, school weeks | −5.3 (1.8) | −0.4 (2.4) | 0.7 (1.1) |
| December 24 to January 15 | −7.4 (3.2) | −1.8 (4.6) | 1.2 (3.0) |
| January 16 to 31, school break | −5.2 (3.3) | −3.3 (4.2) | 1.2 (2.5) |
| School weeks minus December 24 to January 15 | 2.1 (2.4) | 1.4 (3.0) | −0.4 (2.4) |

**Por quê:** a Seção IV.I cita a diferença de 2,1 (2,4) e diz que pesados e dia
inteiro também não mudam. A tabela é onde esses números estão.

Nota:
> Log points, standard errors clustered by state in parentheses. Column 1 of
> Table~\ref{tab:volume} (hourly vehicle counts at continuous counting stations,
> station fixed effects; summers 2014/15 to 2018/19 and 2021/22 to 2024/25), with
> the effect of abolition and the state-by-window effects allowed to differ
> across parts of the summer window, as in Table~\ref{tab:window-parts}; the
> remaining days of the window enter with an effect of their own, not shown.
> Column 2 counts trucks and buses only. Column 3 counts the vehicles of the
> whole station-day. Sources: \citet{dnit2025pnct}.

**Por quê:** diz de que modelo vêm os números (a coluna 1 da Tabela B7, com
efeitos por parte da janela, como na Tabela B2), o que cada coluna conta e a
fonte.

Parágrafo:
> If travel for the year-end holidays explained why no increase in deaths is
> detectable from December 24 to January 15, traffic in hour 0, or its mix,
> should have changed differently in those weeks. On federal highways, we find
> no detectable difference (Table~\ref{tab:traffic-parts}). After abolition,
> vehicles in hour 0 fell by 5.3 log points (1.8) in the school weeks and by 7.4
> (3.2) from December 24 to January 15, a difference of 2.1 (2.4). Trucks and
> buses in hour 0 and the vehicles of the whole day show no detectable
> difference either. The counts cover only federal highways, so travel on other
> roads remains a possible explanation.

**Por quê:** toda tabela do apêndice é apresentada no texto. O parágrafo diz que
hipótese a Tabela B3 testa (as viagens de fim de ano), o resultado e o limite (só
rodovias federais).

### B.2 State-by-day fixed effects and sensitivity to trends — a manhã em cada grupo

**Antes:**
> Within the treated states alone, road deaths in the morning hour that turned
> light fell by 19.4 log points (9.6). Applied to the 107 and 110 deaths per
> summer the two hours had before abolition, that fall offsets less than a third
> of the evening rise.

**Depois:**
> Road deaths in that hour fell by 19.4 log points (9.6) in the treated states
> and by 23.5 (9.6) in the control states, so neither group alone isolates an
> effect of the light on the morning.

**Por quê:** a queda da manhã nos tratados é igual à dos controles, então não é
efeito da abolição.

### B.3 Who dies — nota da Tabela B5

**Antes:**
> The last row of Panel C also drops the Saturday before Carnival to Ash
> Wednesday and December 24 to January 1.

**Depois:**
> The row without Carnival and year-end in Panel C also drops the Saturday
> before Carnival to Ash Wednesday and December 24 to January 1.

**Por quê:** a última linha do Painel C é outra ("Pedestrians, weekends and
holidays"); a nota apontava para a linha errada.

### B.5 Rain and street lighting

**Antes:**
> Table~\ref{tab:lighting} splits the municipalities of each state at the median
> share of households on unlit streets.

**Depois:**
> Table~\ref{tab:lighting} splits the municipalities of each state at the median
> share of households on block faces without street lighting
> (Appendix~\ref{app:other}).

**Por quê:** a mesma definição do corpo, com remissão ao A.6.

### B.9 Assault deaths — nota da Figura B7

**Antes:**
> Equation~(\ref{eq:main}) by season as in Figure~\ref{fig:event-study}, for the
> whole day and for 5 to 8 p.m.\ clock time.

**Depois:**
> Equation~(\ref{eq:main}) by season as in Figure~\ref{fig:event-study}, but
> relative to 2018/19, for the whole day and for 5 to 8 p.m.\ clock time.

**Por quê:** a figura das agressões é contra 2018/19; a do estudo de evento é
contra a média das temporadas com horário de verão.

---

### B.7 The clock changes before abolition — nota da Tabela B9

**Antes:**
> Both changes enter one model with every effect interacted with the change, so
> the average has a clustered standard error.

**Depois:**
> Both changes enter one model with every effect interacted with the change, so
> the average has a standard error clustered by state.

**Por quê:** "clustered" não dizia por onde; as demais tabelas dizem "by state".

## Figura 2, painel B

**Antes:** temporadas sem horário de verão até 2024/25; legenda "Without DST,
2019/20–2024/25".

**Depois:** até 2023/24, como a amostra principal; legenda "Without DST,
2019/20–2023/24".

**Por quê:** só a tabela de volume (PNCT) usa 2024/25. O cruzamento de 50% na
janela não muda (0 contra −50 minutos), e nenhum número do texto vem desse painel.

## Página de título e working paper

**Antes:**
> Monasterio: Instituto de Pesquisa Econ\^omica Aplicada (Ipea) and IDP, Brazil.

**Depois:**
> Monasterio: Instituto de Pesquisa Econ\^omica Aplicada (Ipea), Rio de Janeiro,
> RJ, Brazil, and Instituto Brasileiro de Ensino, Desenvolvimento e Pesquisa
> (IDP), Bras\'ilia, DF, Brazil.

(A mesma troca no `paper_wp.tex`.)

**Por quê:** a nota do Monasterio abreviava o IDP e não dava cidade. Agora segue o
formato da nota do Didier: instituição por extenso, cidade, estado e país.

Tipografia, sem mudança de texto:
- `\frenchspacing` em `preamble_aea.tex`, `title_page.tex` e `paper_wp.tex`, a
  pedido do Fredie: o TeX alarga por padrão o espaço depois do ponto final; agora
  ele é igual ao espaço entre palavras em todo o texto.
- `\raggedright` nas notas de autor de `title_page.tex` e `paper_wp.tex`: o
  e-mail, que não quebra, esticava a linha anterior.
- Só no `paper_wp.tex`: linhas das tabelas mais juntas (`\arraystretch` 0,88),
  para a Tabela 6 caber em 12 pt. O paper da submissão não muda.

Páginas: 40 (paper) + 26 (apêndice) + 1 (título) + 67 (working paper).

## Navalha de Occam (02/11/2026)

Corpo e apêndice lidos inteiros com a skill `occam-razor`, a pedido do Fredie
("aplica de 1-6 e decide se vc vai aplicar a 7. Vamos manter a 8"). Só saiu
prosa repetida; nenhuma exibição, especificação ou ressalva saiu, e nenhum número
mudou.

1. **IV.I:** saiu "Late January gives an estimate of about the same size." A
   mesma seção já diz isso ("the late-January school break shows about as large
   an effect").
2. **IV.I, tráfego nas partes da janela:** as duas frases com 7,4, 5,3 e 2,1 (2,4)
   viraram uma: "Federal highway traffic shows no detectable difference between
   the two periods, whether counted in hour 0, for trucks and buses alone, or over
   the whole day (Online Appendix Table B3)." Os números estão no apêndice B.1. A
   ressalva sobre viagens de férias em outras vias fica.
3. **IV.I, Pará:** "whose 2019 school year ran from March 2019 to January 2020
   \citep{para2018calendario}" virou "whose 2019 school year ran into January
   2020". A data e a fonte estão no apêndice B.1.
4. **IV.C, arredondamento:** a sequência 15,8 → 40,4 e a lista do que a Tabela A1
   reúne saíram do corpo (estão no apêndice B.1 e na Figura B1). Ficam o 31,4
   (9,5) com os horários espalhados, o **16,7 (12,9) sem os horários redondos**
   (ressalva de resultado frágil, não se corta), o fato de que mover a janela
   também muda quais picos entram nela, e que, com os horários espalhados ou
   excluídos, a estimativa sobe a cada passo de −15 a +15 minutos.
5. **Apêndice B.1:** saíram Nordeste/Norte como controle, feriados e municípios
   costeiros, que o corpo já dá com os mesmos números (IV.C). Ficam o deixar um
   de fora, que nomeia os estados e as temporadas (São Paulo, Minas Gerais,
   2019/20, 2022/23), e La Niña, que só está no apêndice. Para a Tabela B1
   continuar lida, a frase do Nordeste/Norte no corpo ganhou "(Online Appendix
   Table B1)".
6. **IV.H:** saiu "Part of the gap may reflect who is on the road: before
   abolition, pedestrians and motorcyclists were 35 percent of road deaths…".
   Era um mecanismo para a diferença em relação a Coate & Markowitz que nenhuma
   exibição testa. A comparação com Coate & Markowitz fica, porque é o benchmark.

**Considerado e mantido:**
- **Introdução §34**, a frase "This paper adds the road deaths of the regime
  itself": fica. Os três parágrafos de literatura (§30, §32, §34) terminam todos
  dizendo o que o paper acrescenta àquela literatura; o §36 resume. Tirar só uma
  dessas frases quebraria o paralelo para ganhar nove palavras.
- **Conclusão**, a oração sobre o Natal e o fim de janeiro: fica, por decisão do
  Fredie. Ela qualifica a frase sobre o efeito depois que as viagens se ajustaram.
- **Seção V, as 79 mortes:** respondem à objeção de que a média dos 74 inclui as
  semanas do Natal, onde não há efeito detectável.
- **Introdução §28**, a frase "This holds both when…": é a qualificação do
  intra-dia.
- Ficam também, porque são ressalvas: a dose zero não quer dizer luz inalterada,
  "too imprecise to confirm or rule out", "cannot exclude a smaller decline", os
  limites inferiores do custo (15 mortes, 27 milhões) e os horários de Brasília
  no controle.

Páginas, medidas no `build.sh` antes e depois dos cortes: paper 40 → 39,
apêndice 27 → 26, working paper 67 → 66. Nenhuma referência indefinida.

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
  casam óbito a óbito, então a subtração por estado, dia e hora pode dar
  negativa e soma os erros das duas bases.
- **Temporada 2024/25**: fica para quando o SIM 2025 for definitivo; não é
  pré-requisito para submeter.
- **Divisão capital/região metropolitana no SIM**: opcional, para uma tabela de
  apêndice numa versão futura.
- **Na introdução, a manhã dentro dos tratados** ("within the treated states
  alone, the decline in deaths in the morning hour offsets less than a third of
  the rise in the evening hour"): entrou numa versão intermediária e saiu antes
  do commit atual, pela mesma razão do B.2.
- **"does not detectably offset" no título da IV.H**: o Fredie manteve o título
  sem "detectably".
- **Arredondamento das horas** (sem horários redondos, 16,7 com EP 12,9): sem
  mudança no paper. A queda vem só do SIM: as mortes da PRF sem :00/:30 dão 56,1
  (26,8) e os acidentes 16,7 (6,4) (`heaping.rds`); espalhar os horários redondos
  dá 31,4; e 16,7 não difere de 29,2, porque sobra menos da metade da amostra.
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
