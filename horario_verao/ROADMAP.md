# ROADMAP — DaylightSaving

## A ordem, e por quê

**Verificação primeiro, skills depois.** As duas skills do projeto (a do campo,
"economia do horário de verão", e a de gestão do projeto) guardam fatos: a lei,
os caminhos e números dos dados, o que a literatura já fez. Escritas antes,
congelam o que ainda não foi conferido, e depois é preciso reescrevê-las. A
varredura de literatura é a matéria-prima da skill de campo, e a primeira olhada
nos dados é a da skill de projeto.

| # | passo | estado |
|---|---|---|
| 1 | **Lei na fonte.** Decretos de 1985 a 2019 no Planalto; tabela UF × temporada | ✅ 08/10/2026 (33 de 34 atos conferidos; falta só o texto do Dec. 91.698/1985) |
| 2 | **Primeira olhada nos dados.** SIM e SINASC por hora, S/SE/CO contra N/NE, nov–fev, antes e depois de 2019. Baixar PRF 2007–2025 | ✅ 08/10/2026 — `PRIMEIRA_OLHADA.md` e `VIABILIDADE.md`. Hora da PRF conferida (é hora legal) |
| 3 | **Varredura de literatura.** Abolição e regime permanente; luz e trânsito; luz e crime; hora do parto; sono e saúde. Registrar em `LITERATURE.md` | ✅ 08/10/2026 — janela aberta; vizinho mais próximo: Franco, Toro, Sampaio & Sampaio (PRF, transições, 2007–2013) |
| 4 | **Skills.** `horario-verao-econ` (campo) e `paper-horario-verao` (projeto), em `horario_verao/skills/` e instaladas em `~/.claude/skills/` | ✅ 08/10/2026 |
| 5 | **PAPER.md.** Pergunta, desenho, exibições previstas, o que não entra | ✅ 09/10/2026 — `horario_verao/PAPER.md` (rascunho) |

## Estado

- **Manuscrito:** commit `4e6b8f1` (04/11/2026), com a revisão do Michael adotada. Paper
  com 39 páginas (texto até a 33), apêndice com 26, working paper com 67; 4 figuras e 7
  tabelas no corpo, 8 e 10 no apêndice. Alvo: AEJ: Economic Policy. **Ainda não submetido.**
- **Working paper:** submetido ao [SSRN 7701059](https://papers.ssrn.com/sol3/papers.cfm?abstract_id=7701059).

Próximos:
1. `manuscript-audit` antes de submeter (a última é de 30/10; o texto mudou em 02 e 04/11).
2. Pacote de replicação (`PAPER.md`, pendência 6): rodada limpa cronometrada, licenças, bruto.
3. Formulário da revista: declarações de conflito por autor e uso de IA (`PAPER.md`, normas).
4. SIM 2025 definitivo: 6ª temporada pós (opcional; não é pré-requisito para submeter).

## Histórico das rodadas (09 a 30/10/2026, com a numeração de scripts da época)

Feito nesta sessão:
- ✅ Agressões do SIM (`10_assault_trends.R`, VIABILIDADE §9): **tendência, não
  luz**. O dia todo some sem 2019/20; 8–17h sobe como 17–20h; dentro da janela a
  dupla é nula. Saem do paper.
- ✅ Conta da realocação (`11_reallocation.R`, VIABILIDADE §10): noite escura
  (0, +1) +58 mortes na via por verão (EP 19); manhã clara −3 (11); líquido +55
  (p = 0,01). O dia todo tem EP 66: é **inconclusivo**, não "zero". Na PRF, as
  horas −1/−2 perdem tanto quanto a noite ganha (realocação nas rodovias).
- ✅ Passo 5: `PAPER.md`.

- ✅ Pedestre × resto (`12_mechanism.R`, VIABILIDADE §11): o escuro age sobre o
  pedestre. SIM hora 0: pedestre +79 lp, resto +18; o pedestre é 12% da base e
  44% do excesso. Resiste à tendência pré (71 lp).
- ✅ Figura do desenho e Tabela 1 (`13_design_descriptives.R`).
- ✅ Revisão editorial das exibições (09/10/2026): todas as figuras em
  `28_figures.R` e todas as tabelas em `29_tables.R`, lidas dos `.rds`; nomes
  dos desfechos sem a fonte; sem rótulo de linha à direita; seis tabelas `.tex`;
  prévia com legendas e notas em `latex/exhibits.tex`.
- ✅ Inferência do pedestre (`14_inference_pedestrian.R`, VIABILIDADE §11): WCR e
  permutação passam nas três fontes (SIM pedestre: 0,007 e 0,029).
- ✅ DNIT (VIABILIDADE §12): o portal de dados abertos só tem VMDa anual; o
  volume **horário** por posto está na API do portal do PNCT, 2014–2019 e
  2021–2025, cerca de 320 postos. Download em massa por ano, em zip.
- ✅ SIM × PRF explicado (VIABILIDADE §13).
- 🗑 `horario_verao/skills/skills_daylightsaving.zip` apagado (cópia velha das pastas versionadas).

- ✅ PNCT baixado, limpo e analisado (`build/06–07`, `15_traffic_volume.R`,
  VIABILIDADE §14): o tráfego seguiu a luz, com noite −6% e manhã +12%. O risco
  por veículo na hora escura sobe ainda mais (+29 lp). Brutos apagados.
- ✅ Lacuna de 2019–2020 provada com fonte primária (Nota Técnica DNIT
  001/2020/DE) mais edital e contratos; nota de rodapé no PAPER.md.

- ✅ Dentro do dia corrigido (faltava hora de referência; agora "o resto do dia").
- ✅ Inferência do volume (`17_inference_volume.R`): o risco por veículo passa na
  permutação (hora escura +29 lp, p = 0,001; manhã −27, p = 0,001).

- ✅ `mortos` da PRF = só óbito no local (Anuários 2019–2025); mesmo conceito do
  SIM na via. Série sem quebra 2007–2025 (VIABILIDADE §13).

- ✅ Literatura (09/10/2026): SSRN do Franco et al., IIHS (Woods, Weast & Monfort
  2025, JSR), Sullivan & Flannagan (vol. e págs.), quatro estudos de energia.
  Toro et al. conferido nos prints do Fredie: infarto +7,4–8,5% no primeiro dia
  após a entrada. Nenhuma (?) aberta.

- 🔍 **Auditoria de código (09/10/2026, skill code-audit).** 26 scripts lidos
  inteiros. Número principal reimplementado do zero a partir do SIM bruto:
  29,4838 lp (EP 8,9783), idêntico. Todos os números do `PAPER.md` batem com os
  `.rds`. Achados:
  1. PRF: ~0,4% dos acidentes caem no casamento por nome de município (Embu
     das Artes, Paraty, Piçarras, São Miguel d'Oeste, Açu, Itapajé, municípios
     de 2013…). ✅ **Corrigido e refeito (02–17) em 09/10/2026**, com
     `build/manual/prf_municipio_alias.csv` e os municípios de 2013 no 04.
     PRF mortes hora 0: 56,2 → 53,9 lp; com vítima 22,9 → 22,2; SIM 29,5 →
     29,2. Antes/depois em VIABILIDADE §17.
  2. As contagens de excesso (+58, +55 por verão) só incluem óbitos com hora
     registrada (~15–20% das mortes na via não têm hora): limite inferior também
     por isso. O "dia todo" do 12 e da Tabela 1 é "com hora válida".
  3. Risco por veículo: com os mesmos verões do PNCT (2014/15–2018/19 e
     2021/22–2024/25), acidentes com vítima na hora 0 = 18,5 (7,7) em vez de
     22,9; por veículo ≈ +25 lp em vez de +29. A conclusão fica.
  4. Tabela 1 CSV: cabeçalho "V1,V2" corrigido e refeito (tex idêntico).
  5. VIABILIDADE §4 e §6 trazem tabelas de rodadas antigas (36,6%, 31,2…), sem
     aviso; §12 dizia que havia contagem em jan–fev/2021 (corrigido: começa em
     06/05/2021). Comentário do 16: "32 relocated stations" (são 30 pares) e
     "263/338" (não reproduzido: 247/315 nas 23 UFs, 267/341 em todas).

- 🔍 **Auditoria de código 18–21 (12/10/2026, skill code-audit).** 18, 19, 20,
  21 e `00_utils.R` lidos inteiros; rótulos e notas conferidos contra os
  geradores (02, 04, 05, 06, 07, 08, 10, 11, 12, 13, 15). 18 e 19
  reimplementados do zero a partir do SIM e da PRF brutos: idênticos (SIM hora 0
  29,1936 (9,0363); meio do dia −4,5216; noite −6,6258; BA 2011/12 −38,17 /
  −57,73 / −21,40, posto 1 de 16). 20 e 21 reproduzem byte a byte (tex e png).
  Corrigido: rótulo "All seven hours above" da tab_excess (só 5 das 7 horas
  aparecem acima); nota do HonestDiD (alvo é contra 2018/19, não o β da
  Tabela 2); en dash literal no 20 (agora `–`; PNGs idênticos).
  Decidido pelo Fredie e feito no mesmo dia: p de permutação = (1 + nº ≥)/(1 +
  999), colunas `perm_*` (nada de "ri"); primeiro estágio da BA com a
  definição do 04. Ver VIABILIDADE §19.
  Achado de pesquisa: 34,5% das horas do SIM na via são hora cheia e 90% são
  múltiplo de 5; trocar a fórmula solar (diferença < 1 min) move a hora 0 de
  29,2 para 29,8. Pede robustez ao amontoamento (heaping).

- 🔍 **Auditoria de código 22–30 e builds 08–11 (12/10/2026, skill code-audit).**
  Todos lidos inteiros; conferidos contra os dados: datas do Xavier (UTC, sem
  deslocamento; 5.569 sedes × 6.209 dias), iluminação 2022/2010 (nacional 2,1% e
  3,6% sem luz; correlação 0,40), ATUS (100% dos municípios casados, hora em
  todos os registros), números digitados nos cabeçalhos de 22, 24, 29 e 30.
  `27` reproduzido por código próprio: idêntico. Nenhum número de exibição mudou.
  Corrigido: (1) `29`, o teste do relógio incluía os 22 municípios da fronteira
  (controles, 130.790 acidentes); só tratadas dá 0,68 contra 6,95 e 10,13 (era
  0,66/6,86/10,03), conclusão igual; (2) `24`, 20 de novembro é feriado nacional
  desde 2024 (Lei 14.759/2023) e era dia útil; resultados idênticos (nenhuma
  morte na hora 0 nesse dia que mudasse o painel); (3) `27`, o cabeçalho dizia
  que todo estado tem duas metades com as mesmas mortes: o DF fica inteiro na
  metade escura e AP/RR quase; tirar o DF ou usar o ponto médio move ≤ 8 lp e
  nenhuma diferença chega a p < 0,15. Nota da `tab_street_lighting` agora diz
  isso. 24 e 29 rodados de novo; `road_users.rds` e `mexico.rds` idênticos
  exceto `clock_check`; tabelas e PNGs idênticos byte a byte.
  Decidido pelo Fredie (12/10/2026): a regra do 27 fica como está, com a nota.
  EXPLICANDO ganhou as seções 3.6–3.9 (chuva Xavier, Censos 2022/2010, ATUS e
  INEGI, parâmetros do custo), que faltavam.

- ✅ **Parecer de editor (12/10/2026, `PARECER.md`)** e todos os itens essenciais
  feitos: scripts 22–28 (amontoamento, tirar um de fora, quem morre,
  integridade do registro, dose e chuva, iluminação com o Censo 2022, custo em
  reais de 2025 com VSL e Ipea), builds 08 (chuva Xavier) e 09 (iluminação).
  Tabelas novas: `tab_sensitivity`, `tab_road_users`, `tab_light_dose`,
  `tab_street_lighting`, `tab_cost`; figuras `fig_window_shift`, `fig_leave_out`,
  `fig_record_integrity`. Periódico-alvo: AEJ Applied → AEJ Policy → JHE (com o México; PARECER.md).
- ✅ **México (extensão):** ATUS 1997–2025 (INEGI, ago/2026) e lei no DOF;
  builds 10 (coordenadas das cabeceiras) e 11 (ATUS); `26_mexico.R` (tripla com
  controles, frágil: só 6 controles) e `27_mexico_within_day.R` (só tratadas,
  hora 0 contra as duas anteriores: mortes +55, p = 0,001; pedestres +154).
  Tabela `tab_mexico`, figura `fig_mexico_event_study`. EXPLICANDO §5.13.
- ✅ EXPLICANDO também em PDF (`horario_verao/EXPLICANDO_O_PROJETO.pdf`, pandoc +
  xelatex, fonte STIXGeneral).

- ✅ **Primeiro rascunho do manuscrito (13/10/2026)**, em inglês, para a AEJ:
  Economic Policy: `latex/paper.tex` (submissão anônima, template da AEA),
  `appendix.tex`, `title_page.tex` e `paper_wp.tex` (working paper), texto
  único em `latex/sections/`; compila com `latex/build.sh`. Escolha do
  periódico, normas, divisão corpo/apêndice e cortes em `PAPER.md` (seção
  "Manuscrito"). Literatura reconferida no Crossref e no resumo ou texto de
  cada obra (`LITERATURE.md`, "Conferência de 13/10/2026").
- ✅ **Mapas (13/10/2026)**, pedido do Fredie: `build/12_map_boundaries.R`
  (IBGE via geobr; GADM 4.1 para o México) e a seção de mapas do
  `28_figures.R`, que grava em `analysis/output/maps/` (`fig_map_brazil` no
  corpo, `fig_map_mexico` no apêndice). Paleta de 3 cores (o validador da
  skill dataviz reprova 4 cores num coroplético). A lista dos municípios da
  fronteira mexicana passou do `26` para o `00_utils.R` (`MX_BORDER`,
  `MX_CONTROL_STATES`); unidades conferidas idênticas às do `mexico.rds`.

- ✅ **Revisão do rascunho com o Fredie (13/10/2026):** resumo reescrito (uma
  comparação só: a mudança na hora que escureceu contra a mesma mudança nos
  estados sem horário de verão); citação do Censo 2022 nos 131 milhões; 2º
  parágrafo da introdução com o argumento econômico (coordenação, evitação,
  externalidade; sem Becker); parágrafo de magnitude no fim da Seção IV;
  corpo com 10 exibições (`fig_light` junta relógio e primeiro estágio; volume
  e México no apêndice), calibrado em quatro artigos publicados da AEJ: Policy;
  README com requisitos e o passo do LaTeX; `latex/exhibits.tex` apagado.
- ✅ **14/10/2026:** frase de escala no fim do 1º parágrafo (37.150 mortes no
  trânsito no Brasil em 2024, 15% pedestres, do SIM via
  `audit/national_road_deaths.rds`; 1,19 milhão no mundo, OMS); 2º parágrafo
  reescrito sem "economics says" e sem a frase do "re-time freely"; Peltzman
  trocado por Crandall & Graham (1984) e White (2004); 1º parágrafo corrigido
  para "work and sleep" (o que Hamermesh et al. estudam).

- ✅ **Segunda leitura do parecer (15/10/2026, `PARECER.md`, "Segunda
  leitura").** Radares citados pelo DOU de 15/08/2019 (Ed. 157, S. 1, p. 5;
  texto em `fontes_legais/`) e pela nota da PRF de 23/12/2019 (Poder360).
  Resumo e conclusão: os 54 são "nas horas cuja luz mudou". Controle no relógio
  de Brasília: `09` e `15` ganharam a comparação dentro do dia em cada grupo
  sozinho (`by_group`), tabela nova `tab_within_group` no apêndice; tráfego do
  controle parado na noite, mortes do controle sobem (+19,7), só tratados 47,2.
  México (`27`) com as horas de referência do `09`: mortes 58,4 (17,6),
  pedestres 142,8 (37,8). Parágrafo da energia corrigido (o MME diz que o
  horário de verão aumentava a carga; hoje energia e vidas apontam para o mesmo
  lado). SIM 2025 ainda preliminar no FTP.

- ✅ **Parecer simulado da AEJ: Policy (15/10/2026, `PARECER_AEJ_POLICY.md`) e
  resposta a todos os itens** (detalhe item por item na seção "Resposta" daquele
  arquivo). Novo: modelo de dose de escuridão pelo sol com EF hora do relógio ×
  data (`23`, Tabela 4 do corpo; a razão de Wald do registro do policial saiu);
  controle contado na hora do relógio dos tratados e sem carnaval/fim de ano
  (`20`); pandemia recortada por calendário, cedo × tarde e só o verão (`04`,
  figura nova `fig_window_legs`); event study contra a média das temporadas com
  horário de verão (`02`, `09`); trocas de relógio antes de 2019 contra a
  abolição (`28_transitions.R`, novo; `tab_transitions`); score bootstrap no
  Poisson (`06`); parcela dos pedestres com EP (`12`); amontoamento redistribuído
  (`19`); composição de "outros" (`21`); hora do atestado contra hora do acidente
  da PRF (`22`); volume e risco por veículo nos mesmos verões (`15`, `16`) e
  estações realocadas na tabela; contagem e custo pela dose, por temporada
  inteira (`25`); México com placebo nas unidades que mantiveram o relógio,
  sem 2020–21 e cobertura do ATUS (`27`). Figuras e tabelas renumeradas:
  `29_figures.R`, `30_tables.R`. Referências novas conferidas: Ferguson et al.
  (1995), Sexton & Beatty (2014), Kline & Santos (2012).

- ✅ **Auditoria do manuscrito (16/10/2026, skill `manuscript-audit`).** Números
  de cada parágrafo contra as tabelas que ele cita e, os que só existem em
  cache, contra os `.rds` (lidos de novo, não da prosa); aritmética derivada;
  afirmações qualitativas contra todas as exibições que as testam; citações
  novas na fonte; varreduras de prosa (duas vezes); tipografia medida no PDF.
  **Corrigido (antes → depois):** "no other hour moves much" → a 2ª hora antes
  do nascer do sol, escura nos dois regimes, sobe 26,4 (13,5) no SIM
  (`sunset_design.rds`), dito no texto; introdução e "case for a causal
  reading" restritos a meio-dia e noite (Painel D); "which Panel D supports"
  (premissa da contagem líquida) → o Painel D não detecta mudança, mas com ~580
  mortes por verão em cada bloco seus intervalos comportam uma queda do tamanho
  da contagem líquida (pontos: −26 e −37 mortes); zeros "within one percentage
  point" → 1,1 (PRF mortes, manhã: 93,76 contra 92,71); estações realocadas
  "less than 2 km" → "at most 2 km" (um par a 2,0 km; o código usa ≤ 2);
  "Other road users" +55,8 (26,4), que a prosa omitia, agora no corpo e no
  apêndice ("car occupants do not change" → próximo de zero e impreciso);
  faixa "23 a 35" → 22,9 a 34,5 no corpo e 23 a 34 na conclusão (34,499 é 34,
  como na introdução); resumo "each summer" → "per DST season" (74 é a
  temporada; "per summer" no paper é a janela, 63); Bahia "92 a 100" → 93 a 100
  (mínimo 92,6); "almost two hours" → "about two hours" (116–133 min nos
  municípios da amostra); "Panel C" ambíguo → "Panel C of Table 3", e Tabela 3
  citada no parágrafo da pandemia; "modelled", "centred" → grafia americana;
  dois "therefore" seguidos no México; "Column 2 multiplies it" → "column 1";
  cabeçalho do `body.tex` com os nomes antigos dos scripts (28/29 → 29/30).
  **Tipografia:** toda URL das referências saía "sidra. ibge. gov. br"
  (máquina de escrever itálica dentro do `{\em}` do `aea.bst`) → `\urlstyle{same}`
  no `preamble_aea.tex` e no `paper_wp.tex`; `tab_mexico` "1605.3" → "1,605.3"
  (`f1` com separador; as outras 13 tabelas saíram idênticas byte a byte).
  **Portadores fora do paper:** CLAUDE.md e CONTEXTO diziam jun/2025 e 6
  temporadas sem (o paper usa 2023/24 e 5); a skill do projeto dizia primeiro
  estágio "~34 p.p." (é 23,6) e risco por veículo "+29 (28,6), p = 0,002" (é
  24,0 (7,8), p = 0,005); corrigidos, com a cópia instalada sincronizada.
  LITERATURE.md ganhou o registro de Ferguson et al. (1995), Sexton & Beatty
  (2014) e Kline & Santos (2012), conferidos na fonte.
  **Conferido e sem mudança:** todos os números de Tabelas 1–7 e B1–C1 citados
  na prosa; os de cache (missing_hour 15,4–20,1; heaping 34,5/23,0/89,9;
  primeiro estágio 23,6 (2,01) e 73,6; dose de pedestres 115,8 (29,6) e demais
  33,7 (11,9); tendência extrapolada da PRF 103,9 (34,3) e 15,3 (23,5);
  janela deslocada 14,6 e 41,2; tirar um fora 24,3 SP / 34,1 MG / 22,7 2019/20 /
  35,2 2022/23; HonestDiD 14,8, [28, 99], M = 0,02; agressões; pares 37.875,
  59,2 e 4,7; relógio 7,85/17,1/24,5 e 0,23/0,32/0,38; cobertura do ATUS;
  Bahia, posições 4, 11 e 1 à noite, 3, 3 e 12 de manhã); custo e VSL refeitos à mão (1.825.618; R$ 4,66 mi;
  790.113; 74 × 1,231 × 2,047 = 186); painel 23 × 245 × 16 = 90.160; somas do
  excesso (57,3 + 5,2 = 62,5); p da permutação = (17 + 1)/1000; estudo de
  eventos ("as cinco acima da média, as duas primeiras mais"); pernas do
  inverno e do verão; calendário (11 dias, 15/02/2009, 04/11/2018); resumo 97
  palavras; anonimização (PDF e metadados sem nome); numeração das exibições
  na ordem das páginas; nenhuma legenda depois das referências; rótulos das
  figuras dentro das faixas.
  **Figura B2** (`fig_leave_out`) excedia a página em 16 pt no apêndice e 9 pt
  no working paper: redesenhada com 7,95 pol. em vez de 8,2 (decisão do Fredie;
  a letra não muda), sem aviso nos dois. As outras 13 figuras saíram idênticas
  pixel a pixel (só a data do PDF mudava) e ficaram como estavam.
  **Deixado como está, com motivo:** frases longas encadeadas que são
  enumerações (Painel C, coluna 3 do custo, México Painel A); "about 108 days"
  (92 + 15,8); "p = 0,04" da noite (0,036 do cache).

- ✅ **Trocas de relógio contra a abolição, com linha de diferença (16/10/2026).**
  "Between a third and two thirds smaller" comparava a olho. O `28` ganhou um
  modelo que empilha o painel da abolição (o do `01` na hora 0, o do `09`
  dentro do dia) com as duas trocas, todo efeito fixo interagido com o
  experimento e cluster por estado no conjunto, porque as amostras se sobrepõem
  (as semanas antes da troca de fevereiro caem na janela de verão). Cada
  coeficiente iguala o ajuste separado (maior diferença 2,9e-6, afirmado no
  script). Abolição menos trocas: mortes na via −13,1 (12,5), p = 0,29, no
  Painel A e −51,4 (18,3), p = 0,005, no B; PRF mortes −67,4 (27,3) e
  −50,0 (100,3); acidentes com vítima 1,6 (8,7) e 0,9 (10,7). Linhas novas na
  Tabela B6. Texto (introdução, V.H, conclusão, apêndice): só a comparação
  dentro do dia separa os dois; ali o efeito caiu cerca de dois terços
  (27,7/79,1), sem sumir; a do Painel A não se distingue de zero. As demais
  células do `transitions.rds` mudaram no máximo 0,0004 lp (ruído numérico do
  `fepois`), sem mudar nada impresso.
- ✅ **Tabela B1 no working paper**: nota encurtada em uma linha (as linhas do
  Painel B que os rótulos já dizem; o "1.6 minutes", que o corpo dá). Nenhum
  float excede a página em nenhum documento. Paper mantido em 35 páginas
  (frases novas compensadas na seção do México e nos limites da conclusão).
- ✅ **Auditoria do manuscrito (30/10/2026, skill `manuscript-audit`),** sobre
  tudo o que mudou desde a de 16/10 (30 commits: México fora, manchete 62,
  Tabela A1, dólares internacionais, partes da janela, citações novas e as
  duas rodadas de texto do Monastério). Números de cada parágrafo contra as
  tabelas que ele cita; os que só existem em cache, contra os `.rds` relidos.
  **Corrigido (antes → depois):** dois trechos da Seção V estavam fora do PDF
  desde 21/10 (`f85663f`): um comentário de proveniência inserido no meio da
  linha (`% total_cost.rds…`, `% ONS reais…`) transformou em comentário todo o
  texto depois dele. Sumiram "Two costs are not valued…" (lesões não fatais; o
  custo de quem mudou o horário da viagem) e a ressalva de que os números do
  ONS vêm de outro método, junto com a frase das duas trocas de relógio por ano
  e do infarto (Toro et al. 2015), que voltara à Seção V a pedido do Leonardo
  em 16/10. Comentários movidos para linha própria; o texto voltou ao PDF (que
  continua com 37 páginas). "All estimates remain significant" (antecedente
  "three" cortado na rodada do Monastério; lido como todas as estimativas do
  paper, e as da manhã não são) → "Each estimate remains significant". Dois
  "therefore" no parágrafo da tendência → "Panel B instead uses". Os 10
  "against" comparativos que sobravam no texto principal → "compared with",
  "and", "relative to" ou "instead of" (sobram 14 no total, todos técnicos:
  temporada de referência, conferência contra fonte). Linhas da Tabela B7
  "Municipalities with darker/better-lit streets" → "Above/Below the median
  (darker/better-lit streets)", como no texto desde 29/10 (`28_tables.R`; as
  outras 15 tabelas saíram idênticas byte a byte).
  **Conferido e sem mudança:** todo número decimal da prosa contra a tabela
  citada ou o cache: dose dos pedestres 115,8 (29,7) e demais 33,6 (11,9);
  tendência da PRF 103,9 (34,3) e 15,3 (23,5); tirar um fora 24,3/34,1 e
  22,7/35,2; heaping 34,5/23,0/90 e 21,3/19,4/95,2; registro 0,4 (0,75);
  relógio 7,8/17,1/24,5 e 0,23/0,32/0,38; HonestDiD 14,8, [28, 99], M = 0,02;
  pernas da janela 39,3/31,2 e 36,9/18,7; agressões 2,4/−0,5/7,0/15,2;
  Bahia (−21,4, posições 1, 4 e 11; 68 contra 93–100); horas vizinhas 16,4,
  26,4, −22,3; noite da PRF −6,1 (p = 0,04); tráfego 17,6 (7,5) e 24,0
  (p = 0,005); três horas 54 (20), 17%, p = 0,007; custo (2.933/2.382 =
  1,231; 6.003/2.933 = 2,047; 114, 135, 287 mi; VSL 1,8 mi = R$ 4,66 mi);
  locais de óbito fora da via 84,9/9,7/3,5/1,5/0,4 e "85% sem veículo"
  recontados do SIM; 57,6 e −12,7 do 2º modelo das partes da janela
  reestimados (só existiam no console); draws 299, 999 e 9.999 no código.
  O `total_cost.rds` (21/10 08:16) é anterior ao `light_dose.rds` (14:48), mas
  bate com ele (62,5 e 73,8). Citações novas na fonte: James (2023), Jelnov
  (2027, JAE 30, online 09/10/2026; resumo no OpenAlex) e Osborne-Christenson
  (2022) conferem; a frase dos calendários ("every treated state but Goiás")
  se apoia no levantamento de `calendarios_escolares.md`. Quantificadores
  ("every age group from 15", "every outcome" da chuva, "robust to excluding
  any single state or season": todo p < 0,05) conferem. Build: 0 indefinidos,
  0 overfull horizontais, 0 floats grandes demais nos três documentos; resumo
  com 97 palavras; exibições em ordem de página; toda nota chega inteira ao PDF.
  Dois "yields" num parágrafo do apêndice e dois "relative to" no de V.I,
  criados pelas trocas de 29/10, → "moves the estimate to" e "in the
  comparison with hours of the same day".
  **Deixado como está:** três frases longas e encadeadas (a do Senado
  americano, a dos efeitos de hora × data, a lista do Painel C); "yields"
  (12) e "relative to" (18) espalhados; dois "relative to" seguem juntos onde
  a construção é paralela (introdução: luz relativa ao relógio; notas da
  tripla diferença: tratados relativo a controles, depois relativo a antes);
  no working paper o apêndice vem depois das referências, por desenho.

## Decisões tomadas

| data | decisão | motivo |
|---|---|---|
| 08/10/2026 | Núcleo de dados = SIM, SINASC, SIH, PRF | Nacionais, públicos, com hora (exceto o SIH). BO estadual fica fora: um estado só, sem controle |
| 08/10/2026 | Comentários de código em inglês | Pedido do Fredie |
| 08/10/2026 | Calendário legal versionado em `build/manual/` | É a fonte do tratamento; pequeno, digitado dos decretos |
| 08/10/2026 | Desenho principal = hora que trocou de luz (pôr do sol padrão por município) | Blocos fixos de hora diluem o efeito; o teste afiado acerta exatamente a hora prevista |
| 08/10/2026 | PRF: só mortes e acidentes com vítima | Quebra de série na contagem total entre 2014 e 2018 |
| 08/10/2026 | SIM de trânsito por hora: só óbito na via pública | Óbito no hospital tem a hora da morte, não do acidente |
| 08/10/2026 | Horário do parto sai da lista de desfechos | Partos seguem o relógio do hospital, não o sol |
| 08/10/2026 | SIM próprio do FTP; período 2008/09–2023/24 | 2008/09 entra; 2025 é preliminar |
| 08/10/2026 | Janela fica em [pôr do sol, +60) | Janelas mais largas diluem o efeito e pioram a pré-tendência |
| 08/10/2026 | Sem zero-inflated nem binomial negativo | Poisson PML só exige a média certa; zeros vêm de eventos raros, não de zeros estruturais |
| 08/10/2026 | Diferença quádrupla (FE de UF × dia) fica como robustez | EP não cai; o ruído é de contagem, não de choque diário |
| 08/10/2026 | Bootstrap do 06 em paralelo (`DS_CORES`), sorteios feitos antes | Serial levaria 7–9 h; o resultado não depende do nº de núcleos |
| 09/10/2026 | Bruto grande sai do Dropbox depois de limpo e conferido | Pedido do Fredie, para poupar espaço. Os scripts de download (02, 05, 06) baixam de novo. Apagados: `prf/input` (67 MB). A apagar: `pnct/input` (~300 MB), depois do `07_clean_pnct.R` |
| 09/10/2026 | "Permutation inference", não "randomization inference" | O tratamento (bloco S/SE/CO) não foi sorteado e o calendário é fixo; o teste permuta quais 11 estados são tratados. Mesma decisão do WorldCupHealth (lá, "calendar-permutation") |
| 09/10/2026 | Pedestre vira o mecanismo central do paper | Efeito 4× maior que no resto, nas duas fontes, robusto à tendência |
| 09/10/2026 | Agressões saem dos desfechos | Sem assinatura de luz: efeito vem de 2019/20 e aparece em horas cuja luz não mudou (VIABILIDADE §9) |
| 09/10/2026 | O total do dia é "inconclusivo", não "zero" | EP do dia todo (66 mortes/verão no SIM) maior que o efeito da noite (+58) |
| 09/10/2026 | Fronteira estadual (GO/MG/MT × BA/TO/RO) fica fora do desenho principal | Sem poder: na hora que escureceu, no verão, há ~1 morte na via por temporada do lado tratado a até 100 km da divisa e ~10 a até 300 km; ~2–27 acidentes com vítima da PRF; 0–4 postos do PNCT a até 100 km. Serve no máximo como robustez de faixa larga com FE de par × dia |
| 13/10/2026 | Só fica o código que gera exibição; análise renumerada | Saíram `00_first_look` (nascimentos, SINASC), `01_viability` (blocos fixos de hora) e `17_inference_volume` (nenhuma exibição usava); SINASC apagado do Dropbox. Antigo → novo: 02–16 → 01–15, 18 → 16, 19 → 17, 22–30 → 18–26, 20 → 27 (figuras), 21 → 28 (tabelas). Entradas antigas deste arquivo usam a numeração antiga. Scripts mestres: `config/00_master_build.R`, `analysis/code/00_master_analysis.R` |
| 13/10/2026 | Inferência do volume volta, agora na Tabela 5 | `16_inference_volume.R`: p de permutação (999) nas 5 colunas e nas 7 horas da `tab_traffic_volume`, entre colchetes; mesma atribuição falsa para volume, acidentes e mortes, então o "por veículo" tem distribuição própria. Saiu o bootstrap selvagem (nenhuma tabela usava). Renumeração: 16–28 → 17–29 (figuras 28, tabelas 29) |
| 13/10/2026 | Rótulos internos da `fig_leave_out` maiores | Estados e temporadas de ~6 pt para ~8 pt, mais escuros; altura da figura 7,6 → 8,2 pol. Pedido do Fredie |
| 13/10/2026 | Nenhum dado lido de outro projeto | Reprodutível em qualquer máquina só com o Dropbox do DaylightSaving. Fuso por município virou regra no `04` (saída idêntica); Censo 2010 guarda só as 8 colunas usadas; o NetCDF do Xavier (sem download por script) fica em `weather/input/` |
| 13/10/2026 | Periódico-alvo: AEJ: Economic Policy | Pedido do Fredie, conferido criticamente (PAPER.md, "Manuscrito"): avaliação de reversão de política com conta de custo; na Applied pesariam o instrumento já usado e o dia todo inconclusivo |
| 13/10/2026 | A queda da PRF na hora −1 é anterior à abolição; "ofuscamento" sai | O estudo de eventos mostra a queda já em 2018/19; e sem horário de verão o sol baixo cai *na* hora −1, o contrário do que o ofuscamento explicaria |
| 13/10/2026 | Mapas em `analysis/output/maps/`, desenhados no `28_figures.R` | Pedido do Fredie; fronteiras baixadas pelo `build/12_map_boundaries.R` |
| 13/10/2026 | Permutação compara a estatística t, não o coeficiente | Pedido do Fredie; MacKinnon e Webb (2020): com clusters heterogêneos o teste no coeficiente pode falhar. Diferenças divididas por √(EP1² + EP2²). Números em VIABILIDADE §20 |
| 15/10/2026 | Contagem do custo pelo modelo de dose, por temporada inteira (regra de 2017) | Não escolhe horas depois de ver os dados; a temporada é a unidade da decisão (voltar com o horário de verão devolve a temporada toda) e é a base da conta do ONS. A soma de três horas (54) fica como checagem na Tabela 6 |
| 15/10/2026 | Event study contra a média das temporadas com horário de verão | É a comparação que o β faz; 2018/19 sozinha era uma temporada alta no SIM. O HonestDiD continua contra 2018/19 (o método pede uma temporada de referência) |
| 15/10/2026 | Bahia e agressões ficam no apêndice | Transparência: a Bahia é checagem de sinal (decisão de 12/10); agressões mostram que a tripla acha efeitos onde a luz não mudou, e o texto agora diz isso |
| 15/10/2026 | Sem permutação "espacial" | Todo bloco contíguo de 11 entre os 23 estados se sobrepõe ao bloco tratado, então não há conjunto placebo limpo; a dose com efeito livre por hora do relógio responde à preocupação de fundo (identifica pela diferença de pôr do sol dentro dos tratados) |
| 15/10/2026 | Auditoria do código do commit do parecer (1d9e9d8): nenhum número muda | Lidos todos os trechos novos de 00_utils, 02, 04, 06, 09, 11, 12, 15, 16, 19–23, 25, 27, 28, 29, 30. Reimplementação independente (sol, escuridão, calendário e painel próprios) reproduz a dose exata (θe 0,47746, EP 0,09716; θm −0,0640; líquido 62,506; N 1.456.474) e as trocas de relógio (54,646; −29,924; média 42,285, EP 13,834). Corrigidos só textos: "só entre estados" → entre estados e datas (dose com hora livre, `23` e paper); "from one before to one after" (horas −1 a +1); nota da Fig. B3 ("aproximadamente"); README (5 núcleos; `DS_BOOT` só no 05). O −5,1 (1,3) repetido na tabela de volume é coincidência de arredondamento (−5,108 contra −5,059) |
| 15/10/2026 | Não cortar páginas para sair de 35 | Limite da revista é 45. O texto termina na pág. 29 e as referências vão da 30 à 35 (a 35 com 11 linhas); sem a quebra antes das referências continua 35 (medido). Chegar a 34 exigiria tirar ~4 referências ou ~440 palavras de texto que respondem ao parecer; encolher as quatro figuras de página inteira para dividirem página com texto apertaria os três painéis de cada uma |
| 16/10/2026 | Leonardo Monasterio entra como coautor; o texto passa de "I" para "we" | Aceitou; o agradecimento a ele saiu. Comentários e decisões em `monasterio.md` |
| 16/10/2026 | Sexo e idade dos mortos nas duas bases (Tabela B4), raça fora | Pedido do Fredie, a partir da pergunta do Leonardo. PRF por pessoa no `build/13`; idade 0 da PRF é desconhecida (código de faltante desde 2017). Zips brutos apagados depois de conferidos (~200 MB) |
| 16/10/2026 | Robustez sem os 279 municípios do litoral (Tabela B1) | Sugestão do Leonardo: o FE de UF × janela absorve o turismo de sempre, não uma mudança depois de 2019. Lista oficial do IBGE no `build/14` |
| 16/10/2026 | Sem teste de rugosidade do relevo para o ofuscamento | O paper já não atribui a queda da hora −1 na PRF ao ofuscamento (decisão de 13/10): a queda começa antes da abolição. O teste checaria um mecanismo que o paper não defende |
| 16/10/2026 | Sem luz noturna por satélite, nem no apêndice | O Censo mede o poste na face da quadra; o satélite mistura rua e casas. O próprio Leonardo descartou |
| 16/10/2026 | Custo (VSL alternativo, anos de vida pela idade dos mortos) fica para depois | O Fredie vai conversar com o Leonardo, que se ofereceu para essa parte |
| 18/10/2026 | Pesos municipais (dose, chuva, relógio dos tratados, iluminação) só com mortes antes de 2019 | Peso tirado do desfecho não deve usar o período tratado. `seat_weights()` em `00_utils.R`. Dose igual na 1ª casa; janela 63 → 62; controle no relógio 32,9 → 33,3; iluminação 2022: 42,5 contra 10,9, p = 0,10 |
| 18/10/2026 | Semanas com aula (15/11–07/12) contra férias (24/12–15/01) na janela; 2020/21 fora das duas | As trocas de relógio caem em período letivo e a janela é quase toda férias. Datas conferidas nos calendários das redes estaduais (`fontes_dados/calendarios_escolares.md`). Mortes na via: aula 58,1 (12,6), férias −12,3 (16,8). Contra a abolição nas semanas de aula, as trocas não se distinguem (15,8, EP 18,0; dentro do dia −22,2, EP 20,9): sai o "dois terços menor por ajuste". Painel D da Tabela B1: Natal/Ano-Novo 5,8, janeiro −27,9, sem litoral e sem Pará a diferença fica, placebo pré-2019 −15,9 (26,2). Seção V: com o efeito das semanas com aula nos dias extras, a temporada daria 79, então 74 é conservador |
| 21/10/2026 | México sai do paper, do apêndice e do código; scripts renumerados | Pedido do Monasterio (áudio e mensagem de 20/10), aceito pelo Fredie: a parte era breve, com controle fraco, e abria um flanco num paper que vale pela profundidade no Brasil. Apagados `build/10_mexico_geo`, `11_mexico_atus`, `analysis/26_mexico`, `27_mexico_within_day`, a Tabela C1 e as Figuras C1–C2. Build: 12→10 (só fronteiras do Brasil), 13→11, 14→12. Análise: 28→26, 29→27, 30→28. Dados do México (206 MB) e os caches mexico*.rds apagados do Dropbox em 21/10, a pedido do Fredie. O México segue citado só como contexto de política e literatura (Goodwin et al.) |
| 21/10/2026 | Manchete do custo = 62 mortes por janela de verão; 74 por temporada vira extensão | Comentário 1 do parecer: os 74 aplicam coeficientes da janela a dias fora dela e vêm do modelo de dose, que impõe zero nas horas cuja luz não mudou. Resumo e conclusão citam 62 e dizem a hipótese; a Tabela 7 valora a janela (Painel B, quatro regras) e a temporada só na regra de referência (Painel C) |
| 21/10/2026 | Valores em dólares internacionais de 2025 (PPC), não em reais | Pedido do Monasterio. É a unidade do próprio VSL (Robinson et al.); reais e ONS convertidos pelo fator PPC de 2025 (2,55441). Janela: 114 mi (22); escala ampla 287; temporada 135 |
| 21/10/2026 | Tabela A1 de validação da medida na frente do apêndice | Comentário 2 do parecer: pares SIM↔PRF, tripla nas parcelas na via e sem hora, amontoamento, janela ±5/10/15 min, :00/:30 espalhados ou retirados, Meeus. As linhas de hora e sol saíram da Tabela B1 (painéis renomeados A–C) |
| 21/10/2026 | Correções de texto do Monasterio (PDF de 20/10) | Frases marcadas com R reescritas (trocas de relógio, horas vizinhas, "we therefore take the size", semanas com aula, Depalo); parágrafo de contribuição depois das três literaturas; "casualties"; última frase da 2.3 cortada e "there were no counts in 2020"; MME: "possivelmente" mudança de hábitos de uso, não "household" como fato. Mantidos: título, parágrafo-índice (ele não gosta, mas deixou ao Fredie), Figura 2 |
| 21/10/2026 | Hipótese da contagem líquida = "hours with no change in the modeled darkness dose" (4.8, Seção 5, limites); "hours that stayed in daylight or stayed in night" na introdução e na conclusão | Sugestão de revisor aceita pelo Fredie: dose zero não é luz igual (a hora antes do pôr do sol ficou de dia, com sol mais baixo). Dólar internacional definido como a unidade com o poder de compra de um dólar nos EUA, não "US dollars at PPP" |
| 21/10/2026 | Janela aberta por data; sai a leitura "aula contra férias" | Parecer final (`PARECER_FINAL.md`): os dias "outros" incluíam o fim de janeiro, férias em todo tratado menos GO, com mortes na via +49,1 (15,6), sem GO 50,4, placebo −0,1; 08–23/12 12,7; 01–14/02 31,0. O nulo é só de 24/12 a 15/01. `20` troca a divisão 24/12–01/01 e 02–15/01 pela abertura dos outros dias; Painel C da Tabela B1 refeito; introdução, IV.I, V, conclusão e apêndice (B1, B7) reescritos. 62/74/79 e Tabela B7 sem mudança. Nome: 24/12–15/01 é "Christmas to mid-January" no texto e só datas na tabela; "year-end holidays" continua reservado a 24/12–01/01 (linha de Carnaval e fim de ano) |
| 21/10/2026 | Partes da janela viram a Tabela B2 (`tab_window_parts`); as B seguintes renumeram | A B1 com as linhas novas passava da margem de baixo. Notas da B8 (trocas de relógio) e espaçamento da B8 e da A1 apertados (`arraystretch` 0,9): no working paper as duas invadiam o rodapé (a A1 já no commit anterior). Nenhuma página passa da área de texto nos três PDFs |
| 21/10/2026 | Parecer externo sobre a rodada aceito em parte | "Absent" → "not detectable" (IV.I, apêndice, conclusão); viagens de férias não descartadas pelo teste do litoral; "points mainly to" na adaptação; 79 descrito como conta de sensibilidade (janela com efeito por parte + dias extras com o das aulas, `23`); Pará com o calendário de 2019; notas da B2 e da B8 reescritas (a B8 volta a dizer que o empilhamento preserva os coeficientes, conferido no `26`). Mantido "oceanfront" (decisão do Fredie). Recusado: frase dizendo que a divisão por data é exploratória (decisão do Fredie) |
| 21/10/2026 | O 79 entra na Tabela 6 com EP (14) | `23` calcula o EP pelo método delta (`season_net_term_se`); linha "effect by part of the window" abaixo dos 74; Seção V reescrita com o texto do Fredie (o que os 74 supõem, por que o efeito de 15/11–07/12, o limite em meados de fevereiro) |
| 21/10/2026 | Toda exibição do apêndice citada no corpo | Figuras B4 (estado × dia por temporada), B6 (Bahia) e B7 (agressões) só eram citadas no apêndice, embora o resumo do apêndice diga que ele traz os resultados "cited in the paper". Uma frase para cada: IV.C, seção de amostra e IV.E. Figura 3: eixo da manhã de −2 a +2 (a hora −3 da manhã nunca foi estimada) |
| 22/10/2026 | Revisão de escrita do Monastério (lista + PDF anotado) incorporada | Decalques: "on the hour", "respond to", "adjusted to ... prices using the IPCA", "transcribed/compiled by hand", "adjusted to Brazil's income level", "rely on road deaths for the magnitude", "may reflect", "was Carnival Sunday"; modificadores soltos (intro, 4.8, conclusão); "Three forces"; frase-ponte energia → trânsito no 1º parágrafo; "The morning does not give the deaths back" vai para o fim do parágrafo e o VSL abre parágrafo próprio; "rooftop" → "distributed"; "Traffic counts" → "Traffic flow" (2.3 e A.4); "the split by road user" explicado (pedestres contra demais); "condition" da PRF = estado físico. "oceanfront" → "coastal" em todo o texto e tabelas (revoga a decisão de 21/10, a pedido do Fredie). Convenções AEA: vírgula serial, datas mês-dia, "registry". Resumo: "states that kept standard time" (a sugestão "never had DST" seria falsa: o NE teve DST nos anos 1980/90). "static" → "stationary", não "fixed" (radar fixo é outro equipamento). Tabela A1: "Rounded times ..." para caber na largura. Figura 2 painel B: título e eixo sem "recorded at dusk". Nenhum número mudou |
| 08/10/2026 | Vale o decreto contra o tzdata | O tzdata põe MT no horário de verão de 1994/95; o Dec. 1.252/1994 o exclui |
| 31/10/2026 | Parecer simulado (Claude, AEJ: Policy) sobre a versão do MPRA, aceito em parte | **Feito:** (1) permutação (999) e score wild bootstrap no modelo de dose e permutação na contagem líquida (`23`, `inference`): mortes na via, noite p=0,002 (score <0,001), noite≠manhã p=0,001, **62 com p=0,001**; PRF mortes noite p=0,031, mas noite≠manhã e líquido p≈0,14; linhas novas nas Tabelas 4 e 6. (2) Resumo reescrito (98 palavras): "brighter mornings did not offset it" → a hora que clareou não caiu de forma detectável, e o 62 condicionado à hipótese das horas de dose zero; mesma troca na intro, nas contribuições, no título da 4.8 e na conclusão; intro traz o "menos de um terço" de dentro dos tratados (Tab. B within-group). (3) Nulo de 24/12–15/01: tráfego PNCT por parte da janela (`15`, `parts`; nova Tabela B `tab:traffic-parts`): hora 0 cai igual nas aulas e nas festas (dif. 2,1, EP 2,4), pesados e dia inteiro idem — viagem de fim de ano nas rodovias federais não explica. **Segunda revisão (mesmo dia):** o "menos de um terço" da intro (Tab. B4) saiu, porque a queda da manhã nos tratados (−19,4) é igual à dos controles (−23,5); entrou a diferença noite ≠ manhã do modelo de dose (permutação p=0,001); 31 mortes da PRF com permutação p=0,135 no texto; "no detectable difference" no tráfego das festas; nota da Tabela 6 sem dizer que só a permutação se aplica. **Recusado:** Jelnov como "forthcoming" (J. Appl. Econ. já deu vol. 30, 2027); teste de deslocamento em janela intermediária (7 horas já dá EP 41); pedágios ANTT (quase só em estados tratados); "SIM menos PRF" (bases não casam óbito a óbito). **Adiado:** temporada 2024/25 quando o SIM 2025 for definitivo (não é pré-requisito para submeter); divisão capital/RM no SIM (apêndice, opcional) |
| 31/10/2026 | Controle no relógio de Brasília: decomposição e hora −1 (fora do paper); manhã do apêndice B.2 | O 19,7 do controle (Tab. B4) já é tripla janela × fora × pós. Pernas, mortes na via, hora 0: janela +11,1 (5,6), fora −9,5 (7,3); hora −1: janela −11,1 (8,6), fora −18,6 (9,6), tripla +6,8 (10,9). Assinatura de deslocamento na janela, mas a hora −1 cai mais fora do verão: o canal não se confirma nem se descarta; o texto ("to the extent that") fica. Trocas antes de 2019 no controle e noites de jogo: sem poder, não feitos. No apêndice B.2 saiu o "less than a third" da manhã (mesma razão da introdução no b2b4009); entrou a queda nos dois grupos (−19,4 e −23,5). Detalhe em `mudancas_pos_MPRA.md` |
| 31/10/2026 | Code audit e manuscript audit das mudanças pós-MPRA | Código (`15`, `23`, `28`, `build/01`): sem erro; tabelas batem com os `.rds`. Texto: a nota `% light_dose.rds, inference.` no meio da linha escondia do PDF as frases da PRF e dos pedestres no modelo de dose (Seção 4); corrigido. Tráfego das festas no corpo ganhou a diferença 2,1 (2,4). Título da 4.8 mantido sem "detectably" (decisão do Fredie). Detalhe em `mudancas_pos_MPRA.md` §10 |
| 01/11/2026 | Figura 2b restrita ao período da amostra | Painel B de `fig:light` ia até 2024/25; agora 2019/20–2023/24, como a amostra principal (só a tabela de volume usa 2024/25). Cruzamento de 50% inalterado (0 contra −50 min); nenhum número do texto muda. Detalhe em `mudancas_pos_MPRA.md` §13 |
| 01/11/2026 | Comentários: arredondamento e as 62 mortes | Arredondamento sem mudança (PRF sem :00/:30: 56,1 e 16,7; espalhar dá 31,4). Para as 62 mortes: Painel C novo em `tab:excess` (mortes que o tráfego implica com risco por veículo constante; horas cuja luz não mudou +15 (32) na via, +7 (12) PRF); introdução e resumo separam as 36 da hora 0 (sem hipótese) da contagem do dia (com hipótese); custo no limite inferior de 95% (71, 83 e 27 milhões). Detalhe em `mudancas_pos_MPRA.md` §14 |
| 31/10–01/11/2026 | Notas das exibições, fontes auxiliares, tipografia e documentação | Quatro notas corrigidas só no texto (`tab:road-users`, `fig:assault`, `tab:window-parts`, `tab:pedestrians`; §11). Fontes de chuva, iluminação e litoral no corpo e no novo Apêndice A "Other sources" (§12). Tabela 6 ganhou "Hour after sunset" (36) e "Hours whose light changed" (−4); `\frenchspacing` e notas de autor à esquerda. `README.md`, `PAPER.md`, a skill do projeto e `mudancas_pos_MPRA.md` postos em dia com o paper (scripts 27/28, 10 tabelas no apêndice, resumo com a condicional). Detalhe em `mudancas_pos_MPRA.md` §11–14 |
| 01/11/2026 | Agrupamento dos erros-padrão em toda nota de tabela | Tabelas 6 e 7 diziam só "delta-method": agora "from coefficients with standard errors clustered by state"; Tabela B9 (transições) dizia "clustered" sem dizer por quê, agora "by state". As demais notas já diziam, ou remetiam à Tabela 2. Detalhe em `mudancas_pos_MPRA.md` |
| 03/11/2026 | PDF do MPRA 131638 trocado pela versão atual | O depósito, ainda em revisão no MPRA, passou a ter o paper do commit `6544124` (02/11/2026) no lugar do de `88e60cc` (30/10/2026); mesmo número e mesmo link. A capa do MPRA mostra a data do formulário do depósito (30/10), não a do PDF. `mudancas_pos_MPRA.md` registra o que mudou entre as duas versões |
| 04/11/2026 | Revisão do Michael J. Challis adotada | Leitor nativo, à mão, sobre `6544124`: introdução e dados mais claros, sem estimativa nova. `REVISAO_MICHAEL_2026-11-04.md` traz comentário por comentário. Skills de escrita e navalha atualizadas. O Fredie trocou o PDF do MPRA por esta versão. |
| 24/11/2026 | Rodada do Monasterio (4 áudios + PDF anotado da versão de 04/11) | Cortes que ele marcou, eletricidade reduzida a uma frase no custo, "effect of darkness", 65% da população no resumo (Censo 2022), Franco et al. com comparação própria, iluminação com parágrafo próprio. Nenhuma estimativa mudou; submissão de 40 para 39 páginas. Item a item, com o que ficou em aberto, em `REVISAO_MONASTERIO_2026-11-24.md`. |

## Pendências pequenas

- Achar o texto do Dec. 91.698/1985 (início da temporada 1985/86; hoje vem do
  tzdata). Irrelevante para a janela dos dados, mas fecha a tabela.
- `renv` ainda não foi iniciado.
- Se o SIM 2024/25 definitivo sair antes da submissão: rodar tudo de novo (o `season_range()` pega a temporada sozinho). Opcional: divisão capital/RM do município de ocorrência (`CODMUNOCOR`) como tabela de apêndice.
