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

## Retomar daqui (09/10/2026)

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

Próximos:
1. Fredie: afiliação e agradecimentos (`title_page.tex`, `paper_wp.tex`);
   ler o rascunho; decidir as pendências do `PAPER.md` (seção "Manuscrito").
2. Rodar a skill `manuscript-audit` no rascunho.
3. Conferir no DOU de 15/08/2019 o despacho dos radares antes de citá-lo.

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
| 08/10/2026 | Vale o decreto contra o tzdata | O tzdata põe MT no horário de verão de 1994/95; o Dec. 1.252/1994 o exclui |

## Pendências pequenas

- Achar o texto do Dec. 91.698/1985 (início da temporada 1985/86; hoje vem do
  tzdata). Irrelevante para a janela dos dados, mas fecha a tabela.
- `renv` ainda não foi iniciado.
