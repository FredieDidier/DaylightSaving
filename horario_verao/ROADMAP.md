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
| 2 | **Primeira olhada nos dados.** SIM e SINASC por hora, S/SE/CO contra N/NE, nov–fev, antes e depois de 2019. Baixar PRF 2007–2025 | ⬜ |
| 3 | **Varredura de literatura.** Abolição e regime permanente; luz e trânsito; luz e crime; hora do parto; sono e saúde. Registrar em `LITERATURE.md` | ⬜ |
| 4 | **Skills.** `horario-verao-econ` (campo) e `paper-horario-verao` (projeto), em `horario_verao/skills/` e instaladas em `~/.claude/skills/` | ⬜ |
| 5 | **PAPER.md.** Pergunta, desenho, exibições previstas, o que não entra | ⬜ |

## Decisões tomadas

| data | decisão | motivo |
|---|---|---|
| 08/10/2026 | Núcleo de dados = SIM, SINASC, SIH, PRF | Nacionais, públicos, com hora (exceto o SIH). BO estadual fica fora: um estado só, sem controle |
| 08/10/2026 | Comentários de código em inglês | Pedido do Fredie |
| 08/10/2026 | Calendário legal versionado em `build/manual/` | É a fonte do tratamento; pequeno, digitado dos decretos |
| 08/10/2026 | Vale o decreto contra o tzdata | O tzdata põe MT no horário de verão de 1994/95; o Dec. 1.252/1994 o exclui |

## Pendências pequenas

- Achar o texto do Dec. 91.698/1985 (início da temporada 1985/86; hoje vem do
  tzdata). Irrelevante para a janela dos dados, mas fecha a tabela.
- `renv` ainda não foi iniciado.
- Ver se o `muni_tz` do WorldCupHealth serve para dar o fuso por município.
