# Revisão do Michael J. Challis (04/11/2026)

Revisão à mão, em PDF escaneado, da versão de 02/11/2026 (commit `6544124`, a do
MPRA 131638). Falante nativo de inglês; escreveu na capa que não é a melhor pessoa
para revisar porque não é forte em econometria aplicada, o que é justamente o
leitor de fora do subcampo. Decisão do Fredie: adotar, "porque se algumas coisas
não ficaram claras para ele, provavelmente não vão ficar para os leitores".

Nenhuma estimativa mudou. As tabelas foram regeneradas do cache (`28_tables.R`) e a
única diferença, conferida arquivo a arquivo, é `p-value` → `$p$-value`.

## Comentário por comentário

Página = do PDF que ele anotou. Comentários dele no inglês original.

| pág. | comentário | o que foi feito |
|---|---|---|
| capa | "I'm not really the best person to review this because I am not great with applied econometrics" | nada a fazer |
| 1 | "\Section{Introduction}" | Título numerado **só no working paper**. O guia da AER: "The introductory section should not receive a heading". Macro `\introsection`, definida em `paper_wp.tex` e vazia em `preamble_aea.tex`; as referências a seções renumeram sozinhas |
| 1 | vírgula de "In modern societies," riscada | retirada |
| 1 | "Does DST 'rely' on clocks. I think this could be made more clean" | reescrita: o que o horário de verão faz fisicamente |
| 1 | "confusing phrasing" (keep moving the clock) | "keep changing the clocks every year" |
| 1 | "Maybe combine all this into one sentence" (EUA, UE, México) | uma frase só, sem os ponto e vírgulas |
| 1 | "this is confusing. is it all states or just some?" | "the 11 states where 131 million of Brazil's 203 million people live" |
| 1 | frase do ONS riscada | cortada; o ONS entra com números no parágrafo do custo |
| 1 | "potentially" riscado | cortado |
| 1 | "make it 1.18 million and change 'about' to 'more than'" (leitura do garrancho) | "an estimated 1.19 million", o número da OMS, por decisão do Fredie: tira o "about" que ele marcou sem trocar a cifra da fonte |
| 2 | "I like the end of P2 but I find the transition from P1 to P2 abrupt" | P2 abre com "The clock rule a country chooses can affect road deaths because ..." |
| 2 | "This is a little hard to follow" (a hora que escureceu) | exemplo de São Paulo antes da regra geral; "We call it the hour that turned dark" |
| 2 | "??" (the evening hour did turn dark) | "These records confirm the change in light" |
| 4 | "This is a weird sentence" (A count for the whole day needs one) | "requires an assumption about those hours" |
| 4 | "What does this mean?" (and off the road) | "deaths with no recorded time and deaths that occurred off the road, mostly in hospitals" |
| 4 | "I like the comparison with electricity savings but it is out of place here" | MME foi para o 1º parágrafo (por que aboliram); o custo agora compara com os números do ONS, inclusive a capacidade, que é maior |
| 4 | "?" (The estimate over the whole window ...) | "The 29 log points are an average ..." |
| 4 | "why not just use 2025 USD then?" | **Pergunta, não instrução.** O dólar internacional fica (decisão de 20/10 com o Monasterio; o VSL é construído em PPC). A nota de rodapé agora responde à pergunta |
| 5 | "use a different word" (Even) | "also relies" |
| 5 | "why do you have citations in the part where you give your results?" | o trecho saiu; Woods, que o Fredie pediu para manter em 14/10, foi para a IV.F junto de Sullivan & Flannagan |
| 5 | "like this one" riscado | cortado |
| 6 | "If you are going to have this P then don't need the last part of the P on the effects of DST on road safety" | fecho do 1º parágrafo de literatura cortado; o que só ele dizia (comparação com as trocas; pedestres) foi para o parágrafo de contribuições. Pelo mesmo motivo saiu "This paper adds the road deaths of the regime itself" |
| 6 | "new word" / "Confusing sent." (states covered) | "Which states observed it changed often in the 1990s." |
| 6 | parênteses em volta de "a week later ... Carnival Sunday" | feito |
| 7 | "IDK if it is really necessary to give this much detail on why it was changed" | fica uma frase na I.A; 0,7%, ar-condicionado, solar e R$ foram para a Seção V, que já repetia a maior parte |
| 7 | "Remove" (DST adds no light to the day) | cortado |
| 9 | "I like Fig 2." | nada a fazer |
| 10 | "Is there correlation between the death records with no time of death and variables of interest?" | a resposta que estava um parágrafo depois veio para a mesma frase, com o número (0,4 p.p., EP 0,7). Ver abaixo |
| 10 | "who measure homicide with it" e "like that of Section 3" riscados | cortados |
| 10 | "?" (crashes without casualties) | reescrita em duas frases |
| 11 | "I might make each \Subsection{-} to a \Paragraph{-} on this Page" | as **cinco** subseções da Seção de dados viraram `\paragraph`, senão as curtas ficariam aninhadas em "Crashes on federal highways". A referência a `sec:counts` aponta para a seção |
| 13 ss. | "Equation not equation" | em todo o corpo e apêndice. O guia da AER não trata do assunto |
| 14 | "remind me what it is again" (X) | $X_{sdh}$ dito em palavras, com os símbolos entre parênteses |
| 15 ss. | "$p$", "$t$" | `$p$-value` e `$t$-statistic` em tudo, inclusive nas linhas das tabelas (`28_tables.R`) |
| 17 | "This should be removed" (costs precision, not effect) | cortado |
| 17 | "Rewrite this sentence" (federal highways, trend) | "falls from 22.2 to 5.6 ...; the imputation estimate falls from 23 to 8 percent" |
| 22 | "Don't start a P with this" (Table 4 reports Equation (2)) | abre pelo resultado. Mesmo defeito corrigido em três aberturas: Tabela 2 painéis A e B, Figura 3; e na tabela de volume, "We estimate" |
| 33 | "Don't reference a section in your conclusion" | a frase agora diz o resultado da comparação |

Aberturas com exibição que ficaram, porque ele leu e não marcou e dizem como ler a
exibição: Tabela 1, Figura 2 (painéis), Figura 4, Tabelas 3, 6 e 7.

## A pergunta sobre os óbitos sem hora

Conta avulsa no início; o último item depois entrou no pipeline:

- Em nível, sim, há correlação com o pedestre: 23,5% das mortes de pedestres na via
  não têm hora, contra 17,5% dos demais usuários. Os efeitos fixos absorvem nível.
- Com o tratamento, não: tripla diferença na parcela sem hora, 0,4 p.p. (EP 0,7) em
  todas as mortes (já na Tabela A1), 0,3 (0,7) nos demais usuários e 1,9 (1,6) nos
  pedestres, nenhuma significativa.
- Entre as mortes sem hora, a parcela de pedestres sobe 2,9 p.p. (EP 1,2; p = 0,03) nos tratados no verão depois da abolição; entre as com hora, não muda (−0,3, EP 0,8). **Agora no paper e na Tabela A1 (Painel B)**, a pedido do Fredie, via `22_record_integrity.R`. A leitura anterior ("as mortes sem hora também registram o aumento de pedestres") **não se sustenta**: no dia inteiro a parcela entre as com hora não sobe. O que se diz é só que um deslocamento de pedestres para os registros sem hora reduziria, e não aumentaria, as estimativas horárias.

## Antes e depois

Gerado da tabela de substituições aplicada ao texto. Fora desta lista: `equation` →
`Equation`, `p-value` → `$p$-value` e `t-statistic` → `$t$-statistic`, em todo lugar;
os títulos da seção de dados.

1. **Antes:** In modern societies, clocks set the hours at which people work and sleep \citep{hamermesh2008cues}. Daylight saving time (DST) relies on this to move an hour of light from the morning to the evening. Whether to keep moving the clock is an open question in many countries. In the United States, the Senate passed a bill making DST permanent in 2022 and the House of Representatives passed another in 2026, which awaits the Senate \citep{uscongress2022sunshine, uscongress2026sunshine}; the European Parliament voted in 2019 to end seasonal clock changes and allow each member state to choose a permanent time regime, a proposal still awaiting the Council \citep{europarl2019seasonal}; Mexico abolished DST in 2022 \citep{mexico2022ley}. Brazil, which had moved its clocks every summer since 1985, abolished DST in April 2019 \citep{brasil2019decreto}. Since then, from November to February, the sun has set an hour earlier on the clock in the states where 131 million Brazilians live \citep{ibge2023censo}. The national grid operator has since studied bringing it back \citep{ons2024nota}. While the debate,
   **Depois:** In modern societies clocks set the hours at which people work and sleep \citep{hamermesh2008cues}. Daylight saving time (DST) moves the clock forward by an hour in summer, which shifts an hour of daylight from the morning to the evening. Whether to keep changing the clocks every year is an open question in many countries. Mexico abolished DST in 2022, the European Parliament voted in 2019 to end seasonal clock changes, and the US Senate in 2022 and the House of Representatives in 2026 each passed a bill making DST permanent, although neither the European proposal nor the US bills have become law \citep{mexico2022ley, europarl2019seasonal, uscongress2022sunshine, uscongress2026sunshine}. Brazil, which had moved its clocks every summer since 1985, abolished DST in April 2019 \citep{brasil2019decreto}, after its Ministry of Mines and Energy concluded that DST no longer saved electricity \citep{mme2019nota}. By then DST applied only in the South, Southeast, and Center-West, the 11 states where 131 million of Brazil's 203 million people live \citep{ibge2023censo}. In those states the sun has since set an hour earlier on the clock from November to February. While the debate,

2. **Antes:** The stakes on the road are potentially large: crashes killed
   **Depois:** The stakes on the road are large: crashes killed

3. **Antes:** road traffic kills about 1.19 million people a year worldwide
   **Depois:** road traffic kills an estimated 1.19 million people a year worldwide

4. **Antes:** The choice between permanent time regimes matters because daily activities are coordinated:
   **Depois:** The clock rule a country chooses can affect road deaths because daily activities are coordinated:

5. **Antes:** This paper uses Brazil's abolition of DST to estimate how many deaths remain once travel has adjusted and whether brighter mornings offset those deaths. Because DST advanced the clock by one hour, each municipality has, on each summer day, one clock hour in the evening that went from daylight to darkness. It is the hour after sunset in standard time, which was the last hour of sunlight under DST and has been the first hour after sunset since abolition. We compute
   **Depois:** This paper uses Brazil's abolition of DST to estimate how many additional road deaths occur once travel patterns have adjusted to darker evenings, and whether brighter mornings offset those deaths. Abolition turned one hour of every summer evening from daylight to darkness. In S\~ao Paulo in mid-January, for example, the sun set at 7:58 p.m.\ on the clock under DST and now sets at 6:58 p.m., so the hour from 6:58 to 7:58 p.m.\ was the last hour of sunlight under DST and has been the first hour after sunset since abolition. We call it the hour that turned dark. It is the hour after sunset in standard time, the clock without DST, so it falls at a different clock time in each municipality and on each date. We compute

6. **Antes:** These records show that the evening hour did turn dark: after abolition, the share of crashes in that hour recorded as occurring at dusk or at night rose by 24 percentage points.
   **Depois:** These records confirm the change in light: in the hour that turned dark, the share of crashes that officers recorded as occurring at dusk or at night rose by 24 percentage points after abolition.

7. **Antes:** A count for the whole day needs one. When every hour
   **Depois:** A count for the whole day requires an assumption about those hours. When every hour

8. **Antes:** \footnote{An international dollar has the purchasing power that a US dollar has in the United States.} rising to 287 million when the count is scaled to deaths without a recorded time and off the road. On the other side of the ledger, the Ministry of Mines and Energy had concluded before abolition that DST no longer saved electricity, possibly because patterns of electricity consumption had changed, particularly through increased late-night air-conditioning demand \citep{mme2019nota}.
   **Depois:** \footnote{An international dollar buys in Brazil what a US dollar buys in the United States. We do not use US dollars because reais are converted at the purchasing-power-parity rate, the basis for adjusting the value of a statistical life to Brazil's income, not at the market exchange rate.} rising to 287 million when the count is scaled up to include deaths with no recorded time and deaths that occurred off the road, mostly in hospitals. Over a whole DST season the cost is 135 million. For comparison, the national grid operator projects that reinstating DST would save 96 to 139 million international dollars in thermal-generation fuel in one summer, and about 0.7 billion a year in payments for reserve capacity \citep{ons2024nota}.

9. **Antes:** The estimate over the whole window, however, averages weeks in which the effect differs. Abolition raised road deaths in hour 0 by 58 log points
   **Depois:** The 29 log points are an average over the whole summer window, however, and the effect differs across its weeks. Abolition raised road deaths in the hour that turned dark by 58 log points

10. **Antes:** This holds both when hour 0 is compared across states and when
   **Depois:** This holds both when the hour that turned dark is compared across states and when

11. **Antes:** Even \citet{depalo2023should}, who explicitly asks whether DST should be abolished, relies on clock transitions
   **Depois:** \citet{depalo2023should}, who explicitly asks whether DST should be abolished, also relies on clock transitions

12. **Antes:** This paper observes a national change of regime, neither simulated nor temporary, over five seasons and with a first stage recorded by third parties, and compares it with the same change of light at the clock changes, before travel adjusted. It also locates the deaths in the evening hour and among pedestrians, the road users whose crash risk is most sensitive to ambient light \citep{sullivan2002role, woods2025daylight}, even to the brightness of the moon \citep{tyndall2025road}.
   **Depois:** (cortado)

13. **Antes:** These studies, like this one, look for
   **Depois:** These studies look for

14. **Antes:** This paper adds the road deaths of the regime itself.
   **Depois:** (cortado)

15. **Antes:** or from simulations. Second,
   **Depois:** or from simulations, and it compares them with the same change of light at the clock changes, before travel adjusted. Second,

16. **Antes:** the evening hour that lost light became deadlier while the morning hour that gained light did not become detectably safer. Third,
   **Depois:** the evening hour that lost light became deadlier, disproportionately for pedestrians, while the morning hour that gained light did not become detectably safer. Third,

17. **Antes:** The states covered changed often in the 1990s; from 2008 a standing decree fixed both the dates and the states \citep{brasil2008decreto}.
   **Depois:** Which states observed it changed often in the 1990s. From 2008, a standing decree fixed both the dates and the states \citep{brasil2008decreto}.

18. **Antes:** back on the third Sunday of February, a week later when that Sunday was Carnival Sunday. DST applied
   **Depois:** back on the third Sunday of February (a week later when that Sunday was Carnival Sunday). DST applied

19. **Antes:** By the ministry's estimate, the 2018/19 season had raised electricity load by about 0.7 percent: savings on evening lighting were outweighed by higher consumption late at night, which the note attributed tentatively to air-conditioning. In 2024 the national grid operator estimated that reinstating DST would lower the evening peak, which distributed solar generation has made the binding constraint on the system, and save 96 to 139 million international dollars (R\$244 to 356 million) in thermal-generation fuel in one summer \citep{ons2024nota}.
   **Depois:** (cortado)

20. **Antes:** DST adds no light to the day; it moves the clock. Panel A of
   **Depois:** Panel A of

21. **Antes:** at new stations (Section~\ref{sec:counts})
   **Depois:** at new stations (Section~\ref{sec:data})

22. **Antes:** In the treated states, an average
   **Depois:** Abolition had no detectable effect on the share of road deaths without a clock time: the triple-difference estimate is 0.4 percentage points (standard error 0.7; Online Appendix Figure~\ref{fig:records} and Table~\ref{tab:measurement}). In the treated states, an average

23. **Antes:** \citep[for example,][who measure homicide with it]{dixcarneiro2018economic}
   **Depois:** \citep[for example,][]{dixcarneiro2018economic}

24. **Antes:** In a triple difference like that of Section~\ref{sec:design}, neither the share of land-transport deaths that occur on the road (half of them) nor the share of road deaths without a clock time moves with abolition (Online
   **Depois:** In a triple difference, the share of land-transport deaths that occur on the road (half of them) does not move with abolition either (Online

25. **Antes:** Crashes without casualties are not used: an online self-report gradually replaced on-scene police response for them, at different dates in different states, which breaks that series differently in the two groups.
   **Depois:** We do not use crashes without casualties. For these crashes, an online report filed by those involved gradually replaced on-scene police response, and this happened at different dates in different states, so their recorded number is not comparable over time between the treated and control states.

26. **Antes:** where $X_{sdh} = T_s W_d A_d D_{sdh}$, on a panel of states, days, and the 24 clock hours. Clock hours
   **Depois:** where $X_{sdh} = T_s W_d A_d D_{sdh}$ equals the dose $D_{sdh}$ in the treated states ($T_s$), on days in the summer window ($W_d$), in seasons after abolition ($A_d$), and zero otherwise. The panel has one row per state, day, and clock hour. Clock hours

27. **Antes:** Panel A of Table~\ref{tab:main} reports the main estimates. In the hour that turned dark, road deaths rose by 29.2 log points (standard error 9.0), or 34 percent. Federal
   **Depois:** In the hour that turned dark, road deaths rose by 29.2 log points (standard error 9.0), or 34 percent (Table~\ref{tab:main}, Panel A). Federal

28. **Antes:** Panel B reports the morning hour, which turned light. All three estimates are negative:
   **Depois:** In the morning hour, which turned light, all three estimates are negative (Panel B):

29. **Antes:** Figure~\ref{fig:hours} estimates equation~(\ref{eq:main}) hour by hour around sunset and sunrise. In all three outcomes the estimate peaks at hour 0.
   **Depois:** When Equation~(\ref{eq:main}) is estimated hour by hour around sunset and sunrise, the estimate peaks at hour 0 in all three outcomes (Figure~\ref{fig:hours}).

30. **Antes:** Table~\ref{tab:dose} reports equation~(\ref{eq:dose}). With an effect for every clock hour on every date, an evening clock hour that goes from full daylight to night has 47.7 log points (9.7) more road deaths.
   **Depois:** An evening clock hour that goes from full daylight to night has 47.7 log points (9.7) more road deaths when the model includes an effect for every clock hour on every date (Equation~(\ref{eq:dose}) and Table~\ref{tab:dose}).

31. **Antes:** Drivers adapted to the new light. Online Appendix Table~\ref{tab:volume} estimates equation~(\ref{eq:main}) on hourly vehicle counts at federal highway stations.
   **Depois:** Drivers adapted to the new light. We estimate Equation~(\ref{eq:main}) on hourly vehicle counts at federal highway stations (Online Appendix Table~\ref{tab:volume}).

32. **Antes:** compared with 31 percent (7 to 54) without the trend. Extrapolating the trend costs precision, not effect. On federal highways the trend matters: with it, injury crashes rise by 5.6 log points (8.0) and by 8 percent ($-5$ to 26) in the imputation. We therefore
   **Depois:** compared with 31 percent (7 to 54) without the trend. The federal highway estimates are more sensitive to the trend. With the linear trend, the estimate for injury crashes falls from 22.2 to 5.6 log points (8.0); with the extrapolated trend, the imputation estimate falls from 23 to 8 percent ($-5$ to 26). We therefore

33. **Antes:** around the clock changes \citep{sullivan2002role}; pedestrian deaths at night
   **Depois:** around the clock changes \citep{sullivan2002role, woods2025daylight}; pedestrian deaths at night

34. **Antes:** estimated that DST had raised electricity load by about 0.7 percent \citep{mme2019nota}; on that estimate, abolition saved a little electricity at the price of the deaths in the darkened evenings. For today's system, the grid operator estimates that reinstating DST would save 96 to 139 million international dollars in thermal-generation fuel in one summer and, by lowering the evening peak by about 2 GW, about 0.7 billion a year in payments for reserve capacity \citep{ons2024nota}.
   **Depois:** estimated that DST had raised electricity load by about 0.7 percent in 2018/19: savings on evening lighting were outweighed by higher consumption late at night, which the note attributed tentatively to air-conditioning \citep{mme2019nota}. On that estimate, abolition saved a little electricity at the price of the deaths in the darkened evenings. For today's system, the national grid operator estimates that reinstating DST would save 96 to 139 million international dollars (R\$244 to 356 million) in thermal-generation fuel in one summer. It would also lower the evening peak, which distributed solar generation has made the binding constraint on the system, by about 2 GW, saving about 0.7 billion a year in payments for reserve capacity \citep{ons2024nota}.

35. **Antes:** maintaining year-round standard time. Section~\ref{sec:cost} compares the estimated mortality costs with the projected energy consequences. The estimates are less
   **Depois:** maintaining year-round standard time. At the reference value of a statistical life, the crash-scene deaths with a recorded time in a DST season are worth about as much as the fuel savings the national grid operator projects from reinstating DST, and less than the projected savings in reserve capacity. The estimates are less
