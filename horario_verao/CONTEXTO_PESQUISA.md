# CONTEXTO DA PESQUISA — DaylightSaving

**Aberto em 08/10/2026.** Fredie Didier e Leonardo Monasterio. Este arquivo é a
pergunta e o desenho como foram pensados na abertura; o desenho que ficou está em
`PAPER.md`, o estado em `ROADMAP.md`. Working paper no MPRA desde 30/10/2026; alvo
AEJ: Economic Policy. Do desenho inicial abaixo, ficaram a diferença tripla e o
teste por hora (só trânsito); as fronteiras, o liga-desliga do TO, violência e
nascimentos saíram (PAPER.md, "O que não entra"), e a BA 2011/12 ficou como
checagem de sinal no apêndice.

## A pergunta

O que acontece com mortes no trânsito, violência, saúde e horário dos
nascimentos quando um país **abole de vez** o horário de verão?

O Brasil fez isso pelo **Decreto 9.772, de 25/04/2019**. A temporada 2019/20,
que começaria em 03/11/2019, não aconteceu. Desde então, de novembro a
fevereiro, o Sul, o Sudeste e o Centro-Oeste ficam com o sol uma hora mais cedo
no relógio: mais luz de manhã, menos luz no fim da tarde.

## Por que é uma boa pergunta

- A literatura estuda quase só a **transição**: a semana em que o relógio muda
  (Smith 2016, AEJ Applied, sobre acidentes fatais; Toro, Tigre & Sampaio 2015,
  Economics Letters, sobre infarto no Brasil; Doleac & Sanders 2015, ReStat,
  sobre roubo e luz no fim da tarde).
- O debate de política hoje é sobre o **regime permanente**: os EUA discutem o
  Sunshine Protection Act (horário de verão o ano todo), a UE discute acabar
  com a troca de relógio. Quase não há evidência causal sobre o que acontece
  quando um país grande *muda de regime*. O Brasil é esse caso.
- Varredura rápida em 08/10/2026: sobre a abolição de 2019 só achei trabalhos
  de **energia** (Estudos Econômicos/USP 2025; dissertação UFJF 2023). Nada
  sobre mortalidade, trânsito, violência ou nascimentos. A varredura completa
  ainda falta (ROADMAP, passo 3).

## Desenho

1. **Diferença tripla.** UFs que tinham horário de verão (S, SE, CO) contra UFs
   que nunca tiveram (N, NE), × meses da temporada (nov–fev) contra o resto do
   ano, × antes contra depois de 2019.
2. **Fronteiras.** Municípios de GO e MG contra BA e TO na mesma latitude e
   longitude: mesmo sol, relógio diferente até 2019, relógio igual depois.
3. **Liga-desliga isolados.** BA só teve horário de verão em 2011/12 e TO só em
   2012/13 (dentro da janela dos dados). Ver `TABELA_ESTADOS.md`.
4. **O mecanismo é a hora.** Se o canal é a luz, o efeito tem de aparecer no
   crepúsculo (≈18h–20h) e no amanhecer, e não ao meio-dia. É o mesmo tipo de
   teste por hora do paper da Copa.

## Período

**Jul/2008 a jun/2024**, em temporadas jul–jun: 11 temporadas com horário de verão (2008/09–2018/19) e 5 sem (2019/20–2023/24), porque 2023/24 é a última com SIM definitivo (decisão de 08/10/2026 no ROADMAP; o plano inicial ia até 2024/25). O PNCT e os acidentes da tabela de volume vão até 2024/25. Início = primeira temporada sob a regra fixa do Dec. 6.558/2008. Jan–fev/2025 de SIM e SINASC depende de 2025 estar consolidado (conferir no FTP); SIH e PRF podem ir até 2025/26. A temporada 2019/20 termina antes da COVID; 2020/21 e 2021/22 entram com e sem. Voltar a 2004/05 só como robustez.

## Dados (núcleo: todos públicos, nenhum precisa de LAI)

| fonte | o que dá | grão | acesso |
|---|---|---|---|
| **SIM** | óbitos com **hora do óbito** e causa (trânsito, agressão, infarto, suicídio) | indivíduo | FTP do DATASUS |
| **SINASC** | nascimentos com **hora do parto**, tipo de parto, idade gestacional | indivíduo | FTP do DATASUS |
| **SIH** | internações por dia (sem hora) | internação | FTP do DATASUS |
| **PRF** | acidentes em rodovias federais com **hora**, km, coordenada e **fase do dia** (amanhecer, pleno dia, anoitecer, plena noite) | acidente / pessoa | dados abertos da PRF (planilhas anuais) |

O WorldCupHealth já tem SIM e SINASC limpos com hora (2009–2024) no Dropbox
dele. Servem para a primeira olhada; o build deste projeto deve ser autônomo
para a replicação.

**Fora do núcleo:** boletins de ocorrência estaduais (ex.: SSP-SP). Dariam o
canal "roubo no escuro" de Doleac & Sanders, mas são de um estado só, que estava
inteiro no tratamento, então não há controle dentro da mesma fonte. Fica como
extensão, se algum dia valer a pena.

## Riscos já conhecidos

- **Só 6–7 temporadas depois de 2019, e a COVID cai em cima de 2020.** Mostrar
  tudo com e sem 2020–2021.
- **O tratado é um bloco regional** (S/SE/CO contra N/NE). Choques regionais no
  verão (chuva, férias, calor) viram ameaça. As fronteiras e o teste por hora
  existem para isso.
- **Fuso horário.** AC e o oeste do AM mudaram de fuso em 2008 e voltaram em
  2013; o oeste do PA mudou em 2008. Hora local ≠ hora solar ≠ UTC. Ver
  `build/manual/fusos_mudancas.csv`.
