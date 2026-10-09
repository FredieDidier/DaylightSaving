---
name: paper-horario-verao
description: Gerencia o projeto DaylightSaving — o fim do horário de verão no Brasil (Decreto 9.772/2019) e seus efeitos sobre mortes no trânsito, acidentes e violência — do Fredie Didier. Use quando ele perguntar sobre o repositório DaylightSaving, horário de verão, a abolição de 2019, a tabela de estados por temporada, os decretos de horário de verão, a hora que trocou de luz, pôr do sol por município, a PRF (acidentes em rodovias federais, fase_dia, e-DAT), o SIM com hora do óbito e local de ocorrência, a diferença tripla tratado × janela × pós, o estimador de imputação, wild bootstrap ou inferência por permutação (randomization inference) do projeto, status ou próximos passos, quiser rodar ou revisar scripts do build ou da análise, checar um número, ou discutir a estratégia de identificação. Não confundir com o WorldCupHealth (Copa do Mundo e saúde), que também usa o SIM com hora do óbito.
---

# Gerenciamento do projeto DaylightSaving — o fim do horário de verão

Você coordena o **DaylightSaving**: o que a abolição do horário de verão
(Decreto 9.772, de 25/04/2019) fez com mortes no trânsito e acidentes no Brasil.
Autor: Fredie Didier. Ainda não há manuscrito. Para o conhecimento do campo
(literatura, desenhos, armadilhas), acione **`horario-verao-econ`**.

Responda em **português**. **Comentários de código em inglês.** O manuscrito,
quando existir, será em inglês.

**Commits e pushes são do Fredie.** Não faça commit; deixe as mudanças na
árvore de trabalho e diga quais arquivos mudaram. Ele sobe pelo GitHub Desktop
(não há `gh` nem chave SSH na máquina).

## Onde está cada coisa

```
~/Documents/GitHub/DaylightSaving/          (git: FredieDidier/DaylightSaving)
  CLAUDE.md                 manual do build e regras
  LITERATURE.md             posicionamento; ✔ conferido / (?) a conferir
  config/config.R           DROPBOX_ROOT é a única edição por máquina
  build/manual/             calendário legal digitado dos decretos (versionado)
    hv_temporadas.csv  hv_excecoes.csv  fusos_mudancas.csv  prf_files.csv
  build/01_dst_calendar.R   → painéis UF × temporada e UF × dia; gera TABELA_ESTADOS.md
  build/02_download_prf.R   PRF 2007–2025 (Google Drive da PRF)
  build/03_clean_prf.R      PRF harmonizada, um acidente por linha
  build/04_municipal_geo.R  sede municipal (geobr 2010) + fuso padrão
  build/05_download_sim.R   SIM 2008–2025 do FTP do DATASUS
  build/06–07               PNCT (volume horário do DNIT): download e limpeza
  analysis/code/00_utils.R  grupos, janelas, sol, painel (fonte única)
  analysis/code/00…17       primeira olhada → viabilidade → hora que trocou de luz
                            → event study → relógio da PRF → tendências
                            → imputação → inferência → … → agressões (11) → realocação (12)
                            → pedestre (13) → figura do desenho e Tabela 1 (14)
                            → inferência do pedestre (15) → volume do PNCT (16) → inferência do volume (17)
  horario_verao/            CONTEXTO_PESQUISA, ROADMAP, TABELA_ESTADOS,
                            PRIMEIRA_OLHADA, VIABILIDADE, PAPER, fontes_legais/, skills/

~/Library/CloudStorage/Dropbox/DaylightSaving/build/   (dado, nunca git)
  calendar/ prf/ geo/ sim/ audit/   (audit/ guarda os .rds com os números)
```

## O desenho, em uma tela

- **Tratado:** RS SC PR SP RJ ES MG GO MT MS DF (horário de verão em todas as
  temporadas de 2008/09 a 2018/19). **Controle:** N e NE sem BA, TO (uma
  temporada cada) e sem AC, AM (mudanças de fuso).
- **Temporada:** jul–jun, com o nome do ano de início. **Janela:** 15/nov–14/fev
  (sob horário de verão em 100% dos dias de toda temporada pré). **Fora:**
  abr–ago. **Período:** 2008/09–2023/24 no SIM (2025 ainda é preliminar), ou
  seja, 11 temporadas pré e 5 pós.
- **A hora que trocou de luz:** [pôr do sol padrão, +60 min) do relógio, por
  município e dia (NOAA, sede municipal). Clara com horário de verão, escura
  sem. De manhã, o espelho: [nascer padrão, +60 min).
- **Estimação:** Poisson, `y ~ twp | uf^window + uf^sy + date`, EP por UF.
  Imputação com semana + dia da semana (06). Wild cluster bootstrap no análogo
  linear e permutação dos estados tratados (07; "permutation inference",
  nunca "randomization": o tratamento não foi sorteado).

## Regras que não se renegociam

1. **O decreto vence o tzdata.** O calendário só muda com o ato citado e o texto
   em `horario_verao/fontes_legais/`.
2. **SIM de trânsito por hora: só óbito na via pública (LOCOCOR = "4") e V01–V89.**
   O óbito no hospital tem a hora da morte, não do acidente.
3. **PRF: só mortes e acidentes com vítima.** `mortos` = óbito no local do
   acidente (Anuários PRF), mesmo conceito do SIM na via.
   A e-DAT (jun/2015, antes no
   S/SE/CE/DF) tirou da base os acidentes sem vítima, de forma diferencial
   entre os grupos.
4. **A hora da PRF é hora legal** (conferido em `04_prf_clock_check.R`: a curva
   de "escuro" se desloca ~55 min entre os regimes).
5. **SIM preliminar nunca entra** (`preliminary == TRUE`).
6. **A tabela `.rds` em `audit/` vence qualquer número escrito**, inclusive aqui
   e no VIABILIDADE.md.

## Onde o resultado está, e como dizer

Os números vigentes estão em `horario_verao/VIABILIDADE.md` (§7 é a rodada vigente) e em
`audit/*.rds`. O que se pode dizer hoje:

- O **primeiro estágio** é enorme e medido por terceiros: a parcela de
  acidentes que a PRF anota como escuro às 18–19h subiu ~34 p.p. nos tratados.
- **A hora que escureceu ganhou mortes de trânsito.** O SIM é o resultado
  âncora, porque passa nos testes de tendência; a PRF corrobora, mas é sensível
  à tendência.
- **Quem morre é o pedestre** (VIABILIDADE §11): hora 0, SIM +79 lp contra
  +18 do resto; 12% da base, 44% do excesso; resiste à tendência pré, ao WCR e à
  permutação (VIABILIDADE §11).
- **SIM × PRF** (VIABILIDADE §13): bases diferentes (todas as vias × rodovias
  federais); na hora 0 não divergem de fato; a PRF corrobora o mecanismo, não o
  tamanho do excesso.
- **O tráfego seguiu a luz** (PNCT, VIABILIDADE §14): noite −6% de veículos,
  manhã +12%; por veículo, a hora escura +29 lp nos acidentes com vítima
  (permutação p = 0,001; `17`). Nenhum
  posto é contado antes e depois; jul/2019–abr/2021 sem contagem (Nota Técnica
  DNIT 001/2020/DE).
- **A manhã não paga a conta da noite** (VIABILIDADE §10): noite escura
  (horas 0 e +1) +58 mortes na via por verão (EP 19), manhã clara −3 (11),
  líquido +55 (p = 0,01). O total do dia tem EP 66: é **inconclusivo**, não
  zero. Na PRF as horas antes do pôr do sol perdem o que a noite ganha.

**O que não se escreve:**
- que a abolição "aumentou as mortes no trânsito" sem dizer "nas horas que
  escureceram"; nem que o total do dia "não muda" (é só ruidoso demais);
- que a PRF "confirma" sem a ressalva da tendência;
- qualquer efeito sobre nascimentos (partos seguem o relógio do hospital) ou
  sobre agressões (tendência, não luz: VIABILIDADE §9).

## Abertos

- A **hora antes do pôr do sol** cai na PRF (e não no SIM). Mecanismo candidato:
  ofuscamento pelo sol baixo, tráfego que muda de hora.
- Fluxo de tráfego (sensores do DNIT) para separar exposição de risco por viagem.
- Conferir no original toda referência marcada (?) no LITERATURE.md.
- Status do projeto de lei de 2025 que proíbe o horário de verão.
