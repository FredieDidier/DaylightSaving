# PAPER.md — o paper, em uma página e meia

Aberto em 09/10/2026; as seções datadas são registro. Os números vigentes estão em
`analysis/output/tables/` e `audit/*.rds`; quando este arquivo divergir deles, valem eles.

## Manuscrito (primeiro rascunho em 13/10/2026)

**Arquivos (`latex/`)**, um texto só para as duas versões:
- `sections/abstract.tex`, `sections/body.tex` (introdução a conclusão, com as
  exibições do corpo), `sections/appendix_body.tex` (apêndice online);
  `references.bib` (toda entrada conferida, com a afirmação atribuída a cada
  obra anotada acima dela).
- `paper.tex`: submissão à AEJ: Economic Policy, **anônima** (revisão
  duplo-cega), template oficial da AEA (`AEA.cls`, `aea.bst`) em `reviewmode`,
  12 pt, espaçamento 1,5, margens de 1 polegada. 39 páginas (04/11/2026).
- `appendix.tex`: Online Appendix, anônimo, arquivo separado (26 páginas).
- `title_page.tex`: página de título exigida pela revista (autor, afiliação,
  agradecimentos).
- `paper_wp.tex`: versão working paper (autor, links, apêndice anexado; 67 páginas em 04/11/2026). O working paper foi submetido ao [SSRN 7701059](https://papers.ssrn.com/sol3/papers.cfm?abstract_id=7701059). O depósito anterior no MPRA (nº 131638) recebeu a versão do commit `88e60cc` em 30/10/2026, a do `6544124` em 03/11/2026 e depois a do `4e6b8f1` (04/11/2026); o que mudou está em `mudancas_pos_MPRA.md`.
- Compilar: `latex/build.sh` (o artigo e o apêndice citam rótulos um do outro
  pelo pacote `xr`, então cada um compila depois do outro).

**Periódico: AEJ: Economic Policy** (decidido com o Fredie, 13/10/2026).
Avaliação crítica, como editor:
- *Por que a Policy:* o objeto é a avaliação de uma reversão real de política
  (abolição), com conta de custo (VSL) contra o lado da energia, num debate
  vivo (Senado dos EUA 2022, Parlamento Europeu 2019, México 2022, PL 397/2007).
  É o que essa revista publica. Na Applied pesariam mais duas fraquezas: medir a
  hora pelo pôr do sol local não é novo (Doleac & Sanders; Bünnings & Schiele
  2021, ReStat) e o efeito no dia todo é inconclusivo.
- *Riscos que o editor vai ver:* (i) efeito pequeno em nível (36 mortes por
  verão na hora 0; 62 no dia, pela dose, supondo zero nas horas cuja luz não
  mudou); (ii) dia todo
  inconclusivo (EP 66); (iii) 23 clusters e 5 verões pós, dois na pandemia;
  (iv) PRF sensível à tendência; (v) o vizinho mais próximo em periódico top é
  Bünnings & Schiele (2021), que **simula** regimes a partir da variação de
  luz: a nossa diferença é observar a mudança de regime. O texto responde a
  cada um, mas nenhum desaparece.
- *Ordem, se não der:* JPubE ou JHE (como no `PARECER.md`).

**Normas da revista seguidas** (página de submissão e style guide da AEA,
lidas em 13/10/2026): PDF; resumo ≤ 100 palavras (99); JEL e palavras-chave;
título e resumo no topo da 1ª página; manuscrito e apêndice anônimos, autor só
na página de título; ≤ 45 páginas em 12 pt (39, com o texto até a pág. 33); seções em algarismos romanos,
introdução sem título; equações numeradas à esquerda; tabelas só com linhas
horizontais, sem asteriscos, EP entre parênteses, zero antes da vírgula
decimal, ≤ 9 colunas, painéis "Panel A"; notas de fonte depois das notas;
figuras vetoriais (PDF); referências Chicago autor-data (`aea.bst`), fontes de
dados na lista de referências; apêndice suplementar não editado pela revista.
Exigências que não estão no PDF: uma **declaração de conflitos (Disclosure
Statement)** por autor, em PDF separado; **declarar o uso de IA** na redação no
formulário de submissão; taxa de submissão; pacote de replicação só antes do
aceite (o repositório já está pronto para isso).

**Exibições, divididas como editor da AEJ: Policy leria** (13/10/2026; revisto
no mesmo dia). Corpo hoje: **11 exibições** (4 figuras, 7 tabelas; eram 10 em 13/10). Calibrado em
quatro artigos publicados na AEJ: Policy 2022–2025 (manuscritos aceitos no
PubMed Central; o PDF da AEA exige login): 8, 9, 9 e 12 exibições no corpo
(mediana 9); todos com mapa no início e tabela descritiva no corpo; texto
corrido de 8,4 a 13 mil palavras (o nosso, ~10,8 mil com as notas, em 06/11/2026) e introdução de 1,8 a
2,1 mil (a nossa, ~2,5 mil); notas com mediana de 90 a 105 palavras.

| corpo | por quê |
|---|---|
| Fig. 1 mapa do Brasil (`analysis/output/maps/fig_map_brazil`) | o leitor de fora precisa ver o bloco regional e as exclusões (BA, TO, AC, AM); mostra também a diferença de latitude, que é a objeção óbvia |
| Fig. 2 a hora que mudou de luz (`fig_light`): A, relógio do pôr e do nascer do sol em SP; B, primeiro estágio da PRF por minuto | define a hora e mostra que o tratamento existe e que a hora registrada é a legal (juntas desde 13/10/2026; antes `fig_design` e `fig_first_stage`) |
| Fig. 3 efeito por hora | a assinatura: pico na hora 0, nada longe |
| Fig. 4 estudo de eventos | tendências |
| Tab. 1 descritivas | a tripla "na mão" (dá 29 lp) |
| Tab. 2 principal | |
| Tab. 3 robustez e horas sem mudança de luz | tendência, imputação, sono |
| Tab. 4 escuridão como dose (`tab:dose`) | luz, não relógio |
| Tab. 5 pedestres | o mecanismo |
| Tab. 6 excesso por verão | a quantidade de política (62 por janela, pela dose) |
| Tab. 7 custo | a conta de política |

Apêndice online (18 exibições em 31/10/2026; rótulos do `appendix_body.tex`):
A. medição da hora do óbito (`tab:measurement`) e como as mortes são registradas
(`fig:records`); B. janela deslocada, deixar um de fora, sensibilidade de amostra,
partes da janela (`tab:window-parts`), tráfego nas partes da janela
(`tab:traffic-parts`), as duas pernas da tripla, FE de UF × dia, dentro do dia por
grupo (`tab:within-group`), HonestDiD, quem morre, sexo e idade, volume e risco por
veículo, iluminação, trocas de relógio antes de 2019 (`tab:transitions`), Bahia,
agressões. O México saiu em 20/10/2026 (ROADMAP).

**Não reintroduzir (navalha de Occam, 13/10/2026).** Cortes por mérito, não
por resultado incômodo.

| elemento | por quê |
|---|---|
| "ofuscamento pelo sol baixo" como explicação da queda da PRF na hora −1 | a física vai contra: sem horário de verão o sol baixo cai *na* hora −1, que deveria ter mais acidentes, não menos. E o estudo de eventos mostra a queda já em 2018/19, ainda com horário de verão (coeficientes da hora −1, acidentes com vítima, entre 25 e 55 lp nas temporadas 2008/09–2017/18 contra 2018/19; pós entre −5 e 15). O texto diz que a queda é anterior à abolição |
| 33,7 p.p. (primeiro estágio às 18–19h do relógio) | vinha do `01_viability`, apagado; o primeiro estágio do paper é o da hora 0 (+23,6 p.p., `light_dose.rds`) e a curva da Fig. 3 |
| números sem exibição: placebos no tempo do `02`, risco por veículo com os mesmos verões (≈ 25 lp), efeito por temporada da imputação | órfãos: nenhum quadro os imprime. O texto diz qualitativamente que volume e acidentes vêm de verões diferentes |
| Mitre-Becerril (2026), Fritz et al. (2020), Jagnani (2024), Sexton & Beatty (2014), Goodwin et al. em mais de um lugar | outros campos ou redundantes: Sullivan & Flannagan (2002), Woods et al. (2025) e Tyndall (2025) cobrem pedestre e luz; Giuntella & Mazzonna e Gibson & Shrader bastam para o sono |
| Toro, Tigre & Sampaio (2015), fora da lista de cortes | voltou em 16/10/2026 na Seção V (meia linha): no Brasil, a troca de outubro aumenta as mortes por infarto no dia seguinte, um custo de sono que a abolição tirou e que a conta não inclui. Citar como salto logo depois da troca, não como contagem anual (o artigo não testa deslocamento) |
| "a manhã tem menos gente na rua" como razão da assimetria | falso nos dados: a hora 0 da manhã tinha 107 mortes por verão antes, a da noite 110 |
| Becker (1965) no parágrafo teórico | decisão do Fredie (13/10/2026): "Não citaria Becker". A frase sobre reotimizar o dia em torno do sol fica sem citação; a coordenação vem de Hamermesh, Myers & Pocock (2008) |
| Peltzman (1975) | resultado contestado; trocado por Crandall & Graham (1984, *AER P&P*) e White (2004, *JLE*) para "o risco recai sobre pedestres e ciclistas". Decisão do Fredie, 14/10/2026 |
| "is therefore an empirical question" (2º parágrafo da introdução) | soa escrito por IA. No lugar: o que a evitação e a externalidade fazem, e o que nenhuma das duas diz. Pedido do Fredie, 14/10/2026 |
| "If people could re-time their activities freely, each household would re-optimize its day around the sun" | nenhum paper sustenta a frase (era raciocínio, e "each household" generaliza demais); Hamermesh et al. sustentam só a coordenação e o peso maior das pistas artificiais. Pedido do Fredie, 14/10/2026 |
| "economics says why a clock rule matters at all" | o texto não comenta a disciplina; o parágrafo abre pela coordenação dos horários. Pedido do Fredie, 14/10/2026 |
| tabelas de volume (PNCT) e do México (que depois saiu do paper) no corpo | 13 exibições era muito para a revista (mediana 9 nos artigos medidos); os números ficam no texto do corpo, as tabelas no apêndice. Decisão do Fredie, 13/10/2026 |
| "Part of the gap may reflect who is on the road" (IV.H, depois de Coate & Markowitz) | a fatia de pedestres e motociclistas (35%) como razão de o efeito superar a projeção dos EUA: nenhuma exibição testa. A comparação com Coate & Markowitz fica. Navalha de 02/11/2026, aprovada pelo Fredie |
| o mesmo número no corpo e no apêndice B.1 (sequência da janela deslocada, tráfego nas partes da janela, Nordeste/Norte, feriados, costeiros) | o corpo dá o número que o argumento usa e remete ao apêndice; o apêndice dá o detalhe que o corpo não dá. Navalha de 02/11/2026 (`mudancas_pos_MPRA.md`) |

**Revisão do Michael Challis (04/11/2026, `REVISAO_MICHAEL_2026-11-04.md`).** Leitor
nativo de fora do subcampo; adotada. Convenções que ficam: `Equation (1)` com
maiúscula; `$p$-value` e `$t$-statistic` como matemática, inclusive nas tabelas;
título "Introduction" só no working paper (macro `\introsection`; o guia da AER proíbe
na submissão); seção de dados com `\paragraph`; a introdução não usa "hour 0" (usa "the
hour that turned dark"). Não voltar: "DST relies on this", "did turn dark", "A count ...
needs one", "Even Depalo", "Extrapolating the trend costs precision, not effect",
citação de literatura na frase que dá o resultado, fecho "This paper ..." nos parágrafos
de literatura (o parágrafo de contribuições diz isso), detalhe do MME e do ONS na I.A (está
na Seção V), seção citada na conclusão. Comparação com a energia no custo: sempre com a
capacidade junto do combustível, que é maior.

**Revisão de escrita (15/10/2026).** O que não voltar a escrever, e por quê:
- "mostly pedestrians", "Pedestrians bear most of the increase": o pedestre é
  43% do excesso no SIM, não a maioria. Usar "disproportionately".
- "states that never had DST": o NE teve horário de verão em 1985/86 e
  2000/01. Os controles "had none in those summers" / "in the sample".
- "the weeks around clock changes": a janela inclui a semana antes do fim
  (15/02/2009); o sono está nas semanas *depois* da troca.
- a janela "is the set of days under DST in every season": é um subconjunto
  (começa 11 dias depois da última entrada).
- "switched hour", "darkened hour", "dark hour": um nome só, hour 0 ou the hour
  that turned dark.
- as horas vizinhas não são "placebos" nem "quiet": a +1 entra no excesso.
- Paralelismos aprovados (não são tique): Column 1/2/3 na Seção V e no
  apêndice; "Federal highway deaths count... / Federal highway injury crashes
  are..."; "In 2024... / In 2025..."; "With the 2022 Census... / With the 2010
  Census..."; "In the evening... / In the morning..." (Bahia); "They count... /
  They come from..." (conclusão).
- Decididos por mim, a pedido do Fredie ("decidido por vc na sua visão de
  especialista isento", 15/10/2026):
  - a linha "Two hours after sunset" da Tabela 3 **fica e é lida** na IV.C
    (21,2, mais baixa porque a segunda hora mudou menos): responde ao "por que
    uma hora só?" com dado, e o `08_wider_window.R` só existe por ela;
  - **SIM em hora legal, agora conferido** (`22_record_integrity.R`, item
    `clock` do `record_integrity.rds`): distância 7,8 sem deslocamento contra
    17,1 e 24,5 com uma hora. Frase no apêndice A, como a do PNCT;
  - manhã, Painel B: o texto cita o p = 0,031 do wild bootstrap nas mortes
    das rodovias federais, em vez de calar sobre ele;

**Pendências do manuscrito (para o Fredie):**
1. ~~Afiliação e agradecimentos~~ feitos (14/10/2026): IDP; e-mail fdidier@terra.com.br. Desde 16/10/2026 Leonardo Monasterio é coautor (Ipea e IDP, a confirmar com ele; leonardo.monasterio@idp.edu.br) e o agradecimento a ele saiu; o que ele sugeriu, e o que foi feito, está em `monasterio.md`. O custo (VSL alternativo, anos de vida pela idade dos mortos) fica para depois de o Fredie conversar com ele. Financiamento, conflitos e IRB **não** vão no rodapé: a AEA pede um PDF separado, "Disclosure Statement", por autor, que diga explicitamente quando não há nada a declarar (sem ele a submissão não é avaliada); a frase de IRB só é exigida para dados coletados de seres humanos (Disclosure Policy e Submission Guidelines da AEJ: Policy, lidas em 14/10/2026).
2. ~~Primeira pessoa~~ feita (16/10/2026): com o coautor, o texto passou de "I" para "we" (23 ocorrências, resumo, corpo e apêndice).
3. ~~`latex/exhibits.tex`~~ apagado (13/10/2026): legendas e notas vivem no manuscrito.
4. ~~Comparação de energia~~ decidida (15/10/2026, delegada pelo Fredie): fica,
   reescrita. O MME diz que o horário de verão aumentava a carga (a abolição
   economizou ~0,7%); pela NT-ONS 0093/2024 a volta economizaria combustível e
   vidas, então os dois lados apontam para o mesmo lado, sem troca. Mais uma
   frase: as trocas de relógio que a abolição tirou (sono) não entram na conta.
5. Skill `manuscript-audit`: rodada em 16/10 e 30/10/2026; rodar de novo antes de submeter (o texto mudou em 02 e 04/11).
6. **Pacote de replicação** (exigido antes do aceite; Data and Code
   Availability Policy da AEA, lida em 15/10/2026). O `README.md` segue o
   modelo dos Social Science Data Editors desde 15/10/2026, e
   `config/00_setup.R` instala os pacotes. Falta, no depósito:
   - **dado bruto**: a política pede o bruto no pacote. O de SIM, PRF e PNCT
     foi apagado depois da limpeza; rebaixar com 02, 05 e 06 e incluir, ou
     justificar no README;
   - **licenças**: escolher a do código e a dos dados derivados (`LICENSE.txt`);
     conferir os termos de redistribuição de SIM, PRF, PNCT e IBGE para
     marcar a segunda caixa do "Statement about Rights". O BR-DWGD não declara
     licença: fica fora;
   - **uma rodada limpa** do build e da análise, cronometrada, para trocar a
     estimativa de 2 a 3 horas (tirada dos horários dos caches) por um tempo
     medido;
   - o README vai em **PDF** na raiz do pacote.

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
   e Toro (2016, homicídios no Brasil) fazem isso, nas
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
  > repeats exactly on the same weekday one to four weeks apart.
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
    partir de 18/06/2019. A figura de apêndice prevista não foi feita: o paper descarta
    jun/2019–abr/2021 e diz por quê.

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
  - O "Table X" é o Painel D da Tabela 3 (`18_placebo_hours.R`). Os 11 dias foram
    conferidos contra o calendário.
- Poisson PML, `y ~ tratado × janela × pós | UF×janela + UF×temporada + data`,
  painel UF × dia, EP por UF (23 clusters).
- Inferência que não depende de 23 clusters: wild cluster restrito (Webb), score
  wild bootstrap no Poisson e permutação dos 11 estados tratados (estatística t).

## Resultados (retrato de 09/10/2026)

Os números vigentes estão nas Tabelas 2, 4 e 6 do paper e na skill
`paper-horario-verao`; esta tabela fica como registro da primeira rodada.

| | SIM, mortes na via | PRF, mortes | PRF, com vítima |
|---|--:|--:|--:|
| primeiro estágio: escuro às 18–19h | | +33,7 p.p. (1,5) | |
| hora que escureceu (lp) | **29,2 (9,0)** | **54 (20)** | **22,2 (5,6)** |
| WCR p / permutação p (t) | 0,010 / 0,018 | 0,002 / 0,014 | 0,001 / 0,007 |
| imputação, tendência pré extrapolada | +38% [−11, 103] | +22% [−24, 97] | +8% [−5, 26] |
| excesso por verão, noite 0 e +1 | **+57 (19)** | **+34 (10)** | **+146 (39)** |
| manhã que clareou, por verão | −3 (11) | −4 (8) | −53 (33) |
| dia todo, por verão | −5 (66) | −58 (44) | −95 (215) |
| placebo: meio do dia / noite fechada (lp) | −4,5 (5,8) / −6,6 (5,6) | −17 (11) / −20 (12) | −1,9 (3,9) / −6,1 (2,9) |

Rodada de 09/10/2026, depois da correção do casamento de municípios da PRF
(auditoria de código; antes: SIM 29,5, PRF mortes 56, com vítima 22,9). As
contagens de excesso só incluem óbitos com hora registrada (15–20% das mortes
na via não têm hora).

**A frase do paper (vigente):** a hora que escureceu teve 36 mortes na via a
mais por verão, sem hipótese sobre as outras horas; se as horas cuja luz não
mudou não foram afetadas, a abolição trouxe 62 por janela de verão (dose). A
manhã que clareou não ficou detectavelmente mais segura. O total do dia, sem a
hipótese, é estimado com ruído demais (EP 66) para confirmar ou descartar o 62. É um limite
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

Todas geradas a partir dos `audit/*.rds`, sem reestimar: figuras e mapas por
`analysis/code/27_figures.R` (`analysis/output/graphs/`, `analysis/output/maps/`),
tabelas por `analysis/code/28_tables.R` (`analysis/output/tables/tab_*.tex`, só o
`tabular`). Legendas e notas ficam em `latex/sections/`. A lista com o script e a
linha de cada exibição está no `README.md` ("List of tables and programs"). Nomes
dos desfechos, em toda figura, tabela e frase: *Road deaths* (SIM, óbito na via),
*Federal highway deaths* e *Federal highway injury crashes* (PRF). Nunca a fonte
entre parênteses.

Texto principal (4 figuras, 7 tabelas)
1. **Fig. 1** `fig_map_brazil`: estados tratados e de controle.
2. **Fig. 2** `fig_light`: a luz na hora que trocou; painel B, parcela dos
   acidentes da PRF anotada como anoitecer ou noite (03).
3. **Tabela 1** `tab_descriptives`: eventos por verão, grupo × janela × período (13).
4. **Tabela 2** `tab_main`: hora que escureceu e hora que clareou; EP por UF,
   WCR, score bootstrap, permutação (01, 06).
5. **Fig. 3** `fig_hours_from_sunset`: efeito por hora relativa ao pôr e ao
   nascer do sol (01).
6. **Fig. 4** `fig_event_study`: por temporada (02).
7. **Tabela 3** `tab_robustness`: tendência, imputação, sem pandemia, janela,
   placebo das horas (04, 05, 08, 09, 18, 20).
8. **Tabela 4** `tab_dose`: modelo de dose, noite e manhã, com permutação (23).
9. **Tabela 5** `tab_pedestrians`: pedestre × resto (12, 14).
10. **Tabela 6** `tab_excess`: excesso por verão; Painel A dose (62), B horas
    estimadas uma a uma (36 na hora 0), C mortes implicadas pelo tráfego (11, 23, 25).
11. **Tabela 7** `tab_cost`: escala e valor das mortes (25).

Apêndice online (8 figuras, 10 tabelas): A1 e Figura A1 (medida da hora do
óbito e registro; 19, 22); B1 a B9 e Figuras B1 a B7 (janela deslocada, deixar
um de fora, outras amostras, partes da janela, tráfego nas partes, pernas da
tripla, estado × dia, dentro de cada grupo, HonestDiD, usuários da via, sexo e
idade, volume do PNCT, iluminação, trocas de relógio, Bahia, agressões).

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
  Fontes: DOU de 15/08/2019, Ed. 157, S. 1, p. 5 (despachos de 14/08,
  conferido em 15/10/2026, `fontes_legais/`); retomada pela nota da PRF no
  Poder360 (23/12/2019). Citado no corpo desde 15/10/2026.
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

## Réplica no México (12/10/2026; EXPLICANDO §5.13) — fora do paper desde 20/10/2026, histórico

Abolição de 30/10/2022 (Ley de los Husos Horarios, DOF 28/10/2022), exceto na
fronteira norte. ATUS (INEGI), 2016–2025. O desenho que se sustenta compara,
nas unidades que perderam o horário de verão, a hora após o pôr do sol com as
duas anteriores no mesmo dia: mortes no local +55 lp (17), pedestres +154 (66),
atropelamentos com vítima +23 (8). A tripla com os 6 controles dá o mesmo sinal
na hora 0 mas é frágil (hora −1 −126, movida pelos controles). Não entra no paper
nem no apêndice (ROADMAP, decisão de 21/10/2026); código e dados foram apagados.

## O lado da energia (para a conta de política; fontes em `fontes_dados/`)

- **MME, NT 5/2019** (a que embasou o Decreto 9.772; fonte primária): o
  horário de verão 2018/19 **aumentou** a carga em ~0,7% (2017/18: +0,4%, NT
  10/2017). Ou seja, quando foi abolido, a energia não pagava nada.
- **ONS, NT DPL 0093/2024** (a mais recente): com a ponta noturna da geração
  distribuída, a volta economizaria R$ 244–356 mi de combustível num verão e
  ~R$ 1,8 bi/ano de reserva de capacidade (96–139 mi e ~0,7 bi em dólares
  internacionais de 2025, fator 2,55441).
- **Vidas (`25`, Tabela 7):** 114–287 mi de dólares internacionais de 2025 por janela de
  verão pelo VSL de referência; 19–49 mi pelo custo do Ipea.
- Os R$ 159,5 mi de 2016/17 são de imprensa (Agência Brasil; O Globo no
  clipping do MME de 16/12/2017). Não citar como fonte do MME.

## O que não entra

- Nascimentos (os partos seguem o relógio do hospital) e agressões como desfecho
  (sem assinatura de luz, VIABILIDADE §9; a Figura B7 só mostra isso).
- O México (seção acima).
- A contagem total da PRF (e-DAT).
- Fronteiras GO/MG × BA/TO: sem poder (ROADMAP, 09/10/2026); ficam como
  extensão, se o parecerista pedir. O liga-desliga do TO (2012/13) também fica
  fora; o da BA entra no apêndice só como checagem de sinal.
- Zero-inflated e binomial negativo (sem excesso de zeros, §7).
- A frase "a abolição aumentou as mortes no trânsito" sem "nas horas que
  escureceram".

## Abertos antes de escrever (todos fechados)

0. ~~Pedestre contra ocupante~~ feito (12): é o pedestre.
1. ~~Fluxo de tráfego (PNCT/DNIT)~~ feito (15, 16; Tabelas B3 e B7): separa exposição de risco por veículo; explica só parte da queda da hora −1 na PRF, que já começa antes da abolição.
2. ~~WCR e permutação para o pedestre~~ feito (14): passa nas três fontes.
3. ~~Bootstrap da imputação para as somas~~ substituído: a contagem de manchete vem da dose, com permutação (23; 31/10/2026).
4. ~~Periódico-alvo~~ decidido em 13/10/2026: AEJ: Economic Policy (seção "Manuscrito").
