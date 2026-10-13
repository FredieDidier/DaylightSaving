# PAPER.md — o paper, em uma página e meia

Rascunho de 09/10/2026. Os números vêm de `audit/*.rds` e do `VIABILIDADE.md`
(§7–§10). Quando os dois divergirem, vale o `.rds`.

## Título de trabalho

*Darker Evenings: Road Deaths after Brazil Abolished Daylight Saving Time*

## A pergunta

Quando um país abandona o horário de verão de vez, a hora do relógio que era
clara no fim da tarde passa a ser escura. Quantas pessoas morrem a mais no
trânsito nessa hora, e a manhã que ganhou luz compensa?

## Contribuição

1. **A primeira estimativa do custo de abandonar** o horário de verão. A
   literatura de trânsito estima o efeito das transições (Smith 2016 nos EUA;
   Laliotis, Moscelli & Monastiriotis 2023 na Grécia) ou o de estar sob o
   horário de verão enquanto ele vigorava, com DiD entre períodos ou estados
   (Gillmore 2025 no Chile; Franco et al. no Brasil). Até a pergunta da
   abolição é respondida com transições (Depalo 2023, acidentes de trabalho na
   Itália). O debate de política é sobre o regime permanente (EUA, UE, o
   PL 397/2007 na Câmara), e aqui o regime de fato acabou: um choque
   permanente, sem a noite de sono perdida da troca, só a luz.
2. **A luz medida na hora certa, antes e depois do fim do regime.** Medir a
   hora em relação ao pôr do sol do lugar não é novo. Doleac & Sanders (2015),
   Toro (2016, homicídios no Brasil) e Mitre-Becerril (2026) fazem isso, nas
   transições e, no caso de Toro, também num DiD dos meses de horário de verão.
   O novo é usar essa hora numa comparação que não depende da troca: a hora do
   relógio [pôr do sol padrão, +60 min), calculada por município e por dia, na
   mesma janela do calendário em 11 temporadas com horário de verão e 5 sem.
   Blocos fixos de hora diluem o efeito (VIABILIDADE §3); a hora da manhã que
   ganhou luz serve de espelho e de teste de sinal.
3. **Duas fontes independentes** (registro de óbito e polícia rodoviária) e um
   primeiro estágio medido por terceiros (a fase do dia que o policial anota).

## Dados

- **SIM** 2008–2024 (FTP do DATASUS; 2025 é preliminar e fica fora): mortes de
  transporte terrestre (V01–V89) **ocorridas na via pública** (LOCOCOR = 4),
  com a hora do óbito. O óbito no hospital tem a hora da morte, não do acidente.
- **PRF** 2007–2025: mortes e acidentes com vítima nas rodovias federais, hora
  legal (conferida), fase do dia. `mortos` conta só o óbito no local do acidente (Anuários
  da PRF), o mesmo conceito das mortes na via do SIM. Nunca a contagem total: a e-DAT removeu os
  acidentes sem vítima de forma diferencial entre os grupos.
- Sede municipal (geobr) e equações da NOAA para o nascer e o pôr do sol em
  hora padrão.

- **PNCT/DNIT** (volume horário das rodovias federais): 2014–jun/2019 e 2021+.
  **Nota de rodapé obrigatória** (pedido do Fredie, 09/10/2026), com fonte:
  > DNIT's continuous traffic counts lapsed between mid-2019 and 2021: the
  > contract for continuous counts ended in June 2019, values published for
  > the second half of 2019 are model-based, and no counts exist for 2020
  > (DNIT, Nota Técnica no. 001/2020/DE, 17 Nov 2020, p. 7: values for
  > July-December 2019 were estimated with a multifidelity Gaussian-process
  > model "since the last contract for PNCT continuous counts ended in June
  > 2019"). A new contract was tendered
  > in 2020 (DNIT, RDC Eletrônico no. 0207/2020-00, public session 8 Jul 2020,
  > process 50600.022817/2019-66) and signed on 30 Dec 2020 (lots 1-4) and
  > 13 Jan 2021 (lot 5; contracts 827-831/2020, Comprasnet Contratos). We drop every station-day from June 2019 to
  > December 2020, and flag as model-based any station-day whose daily total
  > repeats exactly on the same weekday one to four weeks apart (Appendix X).
  - Fontes, todas primárias: **Nota Técnica DNIT nº 001/2020/DE** (17/11/2020,
    p. 7; no portal do PNCT, Downloads > VMDa > 2019; trecho em
    `horario_verao/fontes_dados/pnct_nota_tecnica_vmda2019.txt`);
    [edital RDC 0207/2020](http://www1.dnit.gov.br/anexo/Edital/Edital_edital0207_20-00_1.pdf)
    (trecho em `horario_verao/fontes_dados/pnct_edital_rdc_0207_2020.txt`);
    contratos no Comprasnet (abaixo). As reproduções na imprensa
    ([SINDISAN, 14/12/2020](https://sindisan.com.br/plano-nacional-de-contagem-de-trafego-pnct-e-disponibilizado-pelo-dnit/))
    não precisam mais ser citadas.
  - ✅ Texto original do DNIT achado em 09/10/2026 (a Wayback do portal não
    tinha a nota; ela está na pasta de downloads do portal atual).
  - ✅ Contrato novo (Comprasnet Contratos, API pública, UG 393003, consultada
    em 09/10/2026): contratos 00827/2020 (Splice, lote 1: PR RS SC), 00828,
    00829 e 00830/2020 (Sitran, lotes 2, 3 e 4), assinados em 30/12/2020, e
    00831/2020 (Concremat, lote 5: suporte e gerenciamento), assinado em
    13/01/2021. As contagens recomeçam em 2021, o que bate com o dado.
  - **A prova que não depende de fonte:** o próprio dado. No posto DF BR-251
    km 17, zero repetições de total diário de jan a mai/2019 e 10–15 por mês a
    partir de 18/06/2019. Vira uma figura de apêndice (Appendix X).

## Desenho

- Tratado: RS SC PR SP RJ ES MG GO MT MS DF. Controle: N e NE sem BA, TO, AC e AM.
- Janela de verão: 15/nov–14/fev (100% dos dias sob horário de verão em toda
  temporada pré).
  **Explicar com clareza no texto (pedido do Fredie, 09/10/2026):** a janela
  não é a data do horário de verão, é a interseção de todas as temporadas pré.
  As datas legais variavam (3º domingo de out a 3º domingo de fev, adiado no
  carnaval em 2012 e 2015; 2018/19 começou em 04/11; fim mais cedo 15/02/2009).
  A mesma janela vale para todas as temporadas, antes e depois, então nenhum
  dia entra meio tratado e a variação de datas não contamina a estimativa.
  Candidata a uma frase na seção de desenho e a uma nota na Fig. 2. Fora: abr–ago. Temporadas 2008/09–2023/24: 11 pré e 5 pós.
- **Sono: entra no paper (pedido do Fredie, 09/10/2026).** Rascunhos em inglês:
  - *Parágrafo na seção de desenho (sono agudo):*
    > The design does not involve a clock transition. The summer window starts
    > on 15 November, at least 11 days after the latest DST start in the sample
    > (4 November 2018), and ends on 14 February, before the earliest DST end
    > (15 February 2009). The transition weeks, when the literature finds the
    > acute effects of lost sleep (Smith 2016; Gillmore 2025), are outside the
    > window, and abolition itself involves no lost night of sleep. What changed
    > for the rest of the summer was the clock time of sunset.
  - *Nota de rodapé (sono crônico, "social jetlag", Giuntella & Mazzonna 2019):*
    > A later clock sunset can also shorten sleep for the whole season. Three
    > facts rule this channel out as the source of our estimates. First, the
    > effect sits in the single hour whose light changed; hours far from dawn
    > and dusk, where a sleep effect would also show, do not move (Table X).
    > Second, it survives a state-by-day fixed effect, which absorbs any shift
    > common to all hours of a day. Third, it is concentrated among
    > pedestrians, the road users who depend most on being seen. Any chronic
    > sleep effect of abolition would, if anything, run against our estimates:
    > an earlier clock sunset should lengthen sleep.
  - Números do placebo e o "Table X": `18_placebo_hours.R`, VIABILIDADE §16.
    Conferir os 11 dias contra o calendário ao redigir.
- Poisson PML, `y ~ tratado × janela × pós | UF×janela + UF×temporada + data`,
  painel UF × dia, EP por UF (23 clusters).
- Inferência que não depende de 23 clusters: wild cluster restrito (Webb) e
  permutação dos 11 estados tratados.

## Resultados (o que já sabemos)

| | SIM, mortes na via | PRF, mortes | PRF, com vítima |
|---|--:|--:|--:|
| primeiro estágio: escuro às 18–19h | | +33,7 p.p. (1,5) | |
| hora que escureceu (lp) | **29,2 (9,0)** | **54 (20)** | **22,2 (5,6)** |
| WCR p / permutação p | 0,010 / 0,019 | 0,002 / 0,020 | 0,001 / 0,002 |
| imputação, tendência pré extrapolada | +38% [−11, 103] | +22% [−24, 97] | +8% [−5, 26] |
| excesso por verão, noite 0 e +1 | **+57 (19)** | **+34 (10)** | **+146 (39)** |
| manhã que clareou, por verão | −3 (11) | −4 (8) | −53 (33) |
| dia todo, por verão | −5 (66) | −58 (44) | −95 (215) |
| placebo: meio do dia / noite fechada (lp) | −4,5 (5,8) / −6,6 (5,6) | −17 (11) / −20 (12) | −1,9 (3,9) / −6,1 (2,9) |

Rodada de 09/10/2026, depois da correção do casamento de municípios da PRF
(auditoria de código; antes: SIM 29,5, PRF mortes 56, com vítima 22,9). As
contagens de excesso só incluem óbitos com hora registrada (15–20% das mortes
na via não têm hora).

**A frase do paper:** a abolição trouxe ~54 mortes na via a mais por verão
nas horas que escureceram; a manhã que ganhou luz não compensa. O total do dia
é estimado com ruído demais para dizer se o saldo aparece nele. É um limite
inferior, porque exclui quem morre no hospital e quem não tem hora do óbito
registrada.

**Mecanismo: o pedestre** (VIABILIDADE §11). Na hora 0, as mortes de
pedestres sobem +77 lp no SIM e +170 lp na PRF; as dos demais, +18 e +26. O
pedestre é 12% da base e 43% do excesso no SIM. Resiste à tendência pré (69 lp).

**A PRF corrobora com duas ressalvas:** (i) perde metade do efeito com a
tendência pré extrapolada; (ii) as horas antes do pôr do sol perdem tanto
quanto a noite ganha, o que nas rodovias federais parece realocação de hora
(VIABILIDADE §10).

## Exibições

Todas geradas a partir dos `audit/*.rds`, sem reestimar: figuras por
`analysis/code/28_figures.R` (`analysis/output/graphs/fig_*.pdf`), tabelas por
`analysis/code/29_tables.R` (`analysis/output/tables/tab_*.tex`, só o
`tabular`). Legendas e notas em rascunho, com a equação (1), em
`latex/exhibits.tex` (compila com `latexmk -pdf`). Nomes dos desfechos, em
toda figura, tabela e frase: *Road deaths* (SIM, óbito na via),
*Federal highway deaths* e *Federal highway injury crashes* (PRF). Nunca a
fonte entre parênteses.

Texto principal
1. **Fig. 1** `fig_design`: pôr e nascer do sol no relógio, São Paulo 2018/19,
   com e sem horário de verão; a hora que trocou de luz sombreada.
2. **Fig. 2** `fig_first_stage`: parcela dos acidentes da PRF anotada como
   anoitecer ou noite, por minuto desde o pôr do sol padrão (03).
3. **Fig. 3** `fig_hours_from_sunset`: efeito por hora relativa ao pôr e ao
   nascer do sol (01). O pico na hora 0, e nada longe dela.
4. **Fig. 4** `fig_event_study`: hora depois × hora antes do pôr do sol, por
   temporada (02).
5. **Tabela 1** `tab_descriptives`: eventos por verão, grupo × janela × período.
6. **Tabela 2** `tab_main`: hora que escureceu e hora que clareou; EP por UF,
   WCR, permutação, base por verão.
7. **Tabela 3** `tab_pedestrians`: pedestre × resto, diferença e parcelas (12, 14).
8. **Tabela 4** `tab_excess`: excesso por verão, noite, manhã e saldo (11).
9. **Tabela 5** `tab_traffic_volume`: volume do PNCT, acidentes e risco por
   veículo, hora a hora; p de permutação (15, 16).
10. **Tabela 6** `tab_robustness`: hora 0 com tendência, sem 2020–21, FE de
    UF × dia, duas horas, teste conjunto pré; imputação; placebo das horas
    sem mudança de luz (04, 05, 08, 09, 18).

Apêndice
- `fig_within_day` (09), `fig_honestdid` (07), `fig_assault` (10, nulo),
  `fig_bahia` (17, checagem de sinal; VIABILIDADE §15).
- Ainda sem exibição: calendário legal (TABELA_ESTADOS), checagem do relógio
  da PRF por temporada (03), quebra da e-DAT, repetição dos totais do PNCT.
- Aposentadas (09/10/2026): `fig00` (primeira olhada, com nascimentos) e
  `fig01` (blocos fixos 5–8h); os scripts saíram do repositório (estão no git).

## Objeções antecipadas e a resposta (parecer de 12/10/2026, `PARECER.md`)

- **O SIM é o resultado âncora; a PRF corrobora** (decisão de 09/10/2026, mantida).
  A PRF entra em todas as tabelas, mas o texto nunca se apoia nela sozinha: perde
  o efeito com a tendência extrapolada (acidentes com vítima 5,6 lp, EP 8,0) e
  cai na noite fechada (−6,1 lp, p = 0,04). Frase: "nada **sobe** nas horas de
  luz inalterada", nunca "nada se move".
- **Radares móveis.** O despacho presidencial de 15/08/2019 suspendeu os radares
  estáticos, móveis e portáteis nas rodovias federais; a PRF os recolheu em
  16/08 e retomou em 23/12/2019, depois da liminar da 1ª Vara Federal de
  Brasília (11/12) mantida pelo TRF-1 (18/12). Cobre metade da janela de
  2019/20, é nacional (o FE de data absorve) e só toca a PRF. Resposta: sem
  2019/20, PRF mortes 65,0 (20,7) e com vítima 25,7 (5,9) (`20_leave_out.R`).
  Fontes: Poder360, Migalhas, Jornal de Brasília (dez/2019); conferir o DOU de
  16/08/2019 antes de citar.
- **HonestDiD.** O alvo é a média pós contra 2018/19 (14,8 lp no SIM), não o β
  (29,2); a nota da figura já diz isso. Frase do VIABILIDADE §18.
- **Bahia.** As seis comparações aparecem sempre juntas (a figura já as mostra;
  a nota diz que só uma fica no extremo).
- **Entregas por moto e horários pós-COVID.** A tripla (janela × fora) absorve o
  que não é sazonal; a divisão por usuário responde: motociclistas +19,6 lp
  (10,9), menos que pedestres (+76,6) (`21_road_users.R`).
- **Amontoamento das horas.** 34,5% das horas do SIM na via são hora cheia. Mover a
  janela muda o efeito na direção que a física manda (mais tarde, mais escuro,
  maior); com outra fórmula solar, 29,8; sem :00 e :30, 16,7 (12,9) com menos da
  metade da amostra (`19_heaping.R`).

## Réplica no México (12/10/2026; EXPLICANDO §5.13)

Abolição de 30/10/2022 (Ley de los Husos Horarios, DOF 28/10/2022), exceto na
fronteira norte. ATUS (INEGI), 2016–2025. O desenho que se sustenta compara,
nas unidades que perderam o horário de verão, a hora após o pôr do sol com as
duas anteriores no mesmo dia: mortes no local +55 lp (17), pedestres +154 (66),
atropelamentos com vítima +23 (8). A tripla com os 6 controles dá o mesmo sinal
na hora 0 mas é frágil (hora −1 −126, movida pelos controles). Entra como
seção própria ou apêndice; muda a contribuição de "Brasil" para "duas
abolições".

## O lado da energia (para a conta de política; fontes em `fontes_dados/`)

- **MME, NT 5/2019** (a que embasou o Decreto 9.772; fonte primária): o
  horário de verão 2018/19 **aumentou** a carga em ~0,7% (2017/18: +0,4%, NT
  10/2017). Ou seja, quando foi abolido, a energia não pagava nada.
- **ONS, NT DPL 0093/2024** (a mais recente): com a ponta noturna da geração
  distribuída, a volta economizaria R$ 244–356 mi de combustível num verão e
  ~R$ 1,8 bi/ano de reserva de capacidade.
- **Vidas (`28`):** R$ 253–637 mi por verão pelo VSL de referência; R$ 43–108 mi
  pelo custo do Ipea.
- Os R$ 159,5 mi de 2016/17 são de imprensa (Agência Brasil; O Globo no
  clipping do MME de 16/12/2017). Não citar como fonte do MME.

## O que não entra

- Nascimentos (os partos seguem o relógio do hospital) e agressões (sem
  assinatura de luz, VIABILIDADE §9).
- A contagem total da PRF (e-DAT).
- Fronteiras GO/MG × BA/TO: sem poder (ROADMAP, 09/10/2026); ficam como
  extensão, se o parecerista pedir. O liga-desliga do TO (2012/13) também fica
  fora; o da BA entra no apêndice só como checagem de sinal.
- Zero-inflated e binomial negativo (sem excesso de zeros, §7).
- A frase "a abolição aumentou as mortes no trânsito" sem "nas horas que
  escureceram".

## Abertos antes de escrever

0. ~~Pedestre contra ocupante~~ feito (12): é o pedestre.
1. **Fluxo de tráfego (PNCT/DNIT, volume horário 2014–19 e 2021–25; VIABILIDADE §12)**: separar exposição de risco por viagem e
   explicar a queda nas horas −1/−2 da PRF.
2. ~~WCR e permutação para o pedestre~~ feito (14): passa nas três fontes.
3. Bootstrap da imputação para as somas da realocação (hoje por método delta,
   sem tendência).
4. Periódico-alvo: AEJ Applied ou AEJ Policy (Smith 2016 está na Applied);
   JHE ou JPubE como alternativa.
