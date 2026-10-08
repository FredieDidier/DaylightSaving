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
| 5 | **PAPER.md.** Pergunta, desenho, exibições previstas, o que não entra | ⬜ |

## Retomar daqui (08/10/2026, segunda sessão)

Feito nesta sessão:
- ✅ `inference.rds` lido e registrado (VIABILIDADE §7): a hora que escureceu passa
  no wild bootstrap e na aleatorização dos estados nos três desfechos.
- ✅ Diferença quádrupla dentro do dia (`10_within_day.R`, VIABILIDADE §8): **não
  reduz o ruído** (é ruído de contagem). Fica como robustez; mostra a hora +1
  subindo e a manhã da PRF caindo (−20 lp, p = 0,04).
- ✅ 00 e 01 já rodavam com o SIM próprio; textos atualizados (PRIMEIRA_OLHADA,
  VIABILIDADE §2–3). Novo: agressões (todos os locais) sobem no nível do dia.
- ✅ Referências (?) do `LITERATURE.md` conferidas; sobram 4 pequenas.
- ✅ Figuras: `00_utils.R` força LC_CTYPE UTF-8 (em locale C o "×" saía "..").
- ✅ 06 reescrito: bootstrap paralelo, 26 min em vez de 7–9 h.

Próximos:
1. ✅ Imputação lida (VIABILIDADE §7): SIM +32%, e +38% com a tendência pré
   extrapolada (IC largo); PRF cai à metade com a tendência.
2. ✅ Avisos do 10 conferidos: 2 de convergência (inofensivos, coeficientes
   iguais com 3× as iterações) e 43 do HonestDiD (limites estáveis ao teste de
   escala). VIABILIDADE §8.
3. Agressões do SIM: estudo de eventos por temporada do nível do dia (tendência
   diferencial S/SE/CO × N/NE?) antes de qualquer leitura.
4. Fechar a conta da realocação: noite (bins 0 e +1) contra manhã (bin 0), em
   mortes e acidentes por temporada, com o mesmo modelo.
5. Passo 5: PAPER.md.
6. Pendências da literatura: SSRN do Franco et al. (403), números do Toro et al.
   no artigo, autoria e números do relatório do IIHS, estudos de energia.

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
| 08/10/2026 | Vale o decreto contra o tzdata | O tzdata põe MT no horário de verão de 1994/95; o Dec. 1.252/1994 o exclui |

## Pendências pequenas

- Achar o texto do Dec. 91.698/1985 (início da temporada 1985/86; hoje vem do
  tzdata). Irrelevante para a janela dos dados, mas fecha a tabela.
- `renv` ainda não foi iniciado.
- Ver se o `muni_tz` do WorldCupHealth serve para dar o fuso por município.
