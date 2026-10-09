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
- ✅ Agressões do SIM (`11_assault_trends.R`, VIABILIDADE §9): **tendência, não
  luz**. O dia todo some sem 2019/20; 8–17h sobe como 17–20h; dentro da janela a
  dupla é nula. Saem do paper.
- ✅ Conta da realocação (`12_reallocation.R`, VIABILIDADE §10): noite escura
  (0, +1) +58 mortes na via por verão (EP 19); manhã clara −3 (11); líquido +55
  (p = 0,01). O dia todo tem EP 66: é **inconclusivo**, não "zero". Na PRF, as
  horas −1/−2 perdem tanto quanto a noite ganha (realocação nas rodovias).
- ✅ Passo 5: `PAPER.md`.

- ✅ Pedestre × resto (`13_mechanism.R`, VIABILIDADE §11): o escuro age sobre o
  pedestre. SIM hora 0: pedestre +79 lp, resto +18; o pedestre é 12% da base e
  44% do excesso. Resiste à tendência pré (71 lp).
- ✅ Figura do desenho e Tabela 1 (`14_design_descriptives.R`).
- ✅ Revisão editorial das exibições (09/10/2026): todas as figuras em
  `20_figures.R` e todas as tabelas em `21_tables.R`, lidas dos `.rds`; nomes
  dos desfechos sem a fonte; sem rótulo de linha à direita; seis tabelas `.tex`;
  prévia com legendas e notas em `latex/exhibits.tex`.
- ✅ Inferência do pedestre (`15_inference_pedestrian.R`, VIABILIDADE §11): WCR e
  permutação passam nas três fontes (SIM pedestre: 0,007 e 0,029).
- ✅ DNIT (VIABILIDADE §12): o portal de dados abertos só tem VMDa anual; o
  volume **horário** por posto está na API do portal do PNCT, 2014–2019 e
  2021–2025, cerca de 320 postos. Download em massa por ano, em zip.
- ✅ SIM × PRF explicado (VIABILIDADE §13).
- 🗑 `horario_verao/skills/skills_daylightsaving.zip` apagado (cópia velha das pastas versionadas).

- ✅ PNCT baixado, limpo e analisado (`build/06–07`, `16_traffic_volume.R`,
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

Próximos:
1. Começar o manuscrito (introdução e desenho), em inglês. Entram: o texto do
   sono (PAPER.md), o placebo das horas (19) e a Bahia no apêndice (18).

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
| 08/10/2026 | Vale o decreto contra o tzdata | O tzdata põe MT no horário de verão de 1994/95; o Dec. 1.252/1994 o exclui |

## Pendências pequenas

- Achar o texto do Dec. 91.698/1985 (início da temporada 1985/86; hoje vem do
  tzdata). Irrelevante para a janela dos dados, mas fecha a tabela.
- `renv` ainda não foi iniciado.
- Ver se o `muni_tz` do WorldCupHealth serve para dar o fuso por município.
