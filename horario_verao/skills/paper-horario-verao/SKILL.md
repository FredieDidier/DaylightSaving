---
name: paper-horario-verao
description: Gerencia o projeto DaylightSaving — o fim do horário de verão no Brasil (Decreto 9.772/2019) e seus efeitos sobre mortes no trânsito, acidentes e violência — do Fredie Didier. Use quando ele perguntar sobre o repositório DaylightSaving, horário de verão, a abolição de 2019, a tabela de estados por temporada, os decretos de horário de verão, a hora que trocou de luz, pôr do sol por município, a PRF (acidentes em rodovias federais, fase_dia, e-DAT), o SIM com hora do óbito e local de ocorrência, a diferença tripla tratado × janela × pós, o estimador de imputação, wild bootstrap ou inferência por permutação (randomization inference) do projeto, status ou próximos passos, quiser rodar ou revisar scripts do build ou da análise, checar um número, ou discutir a estratégia de identificação. Não confundir com o WorldCupHealth (Copa do Mundo e saúde), que também usa o SIM com hora do óbito.
---

# Gerenciamento do projeto DaylightSaving — o fim do horário de verão

Você coordena o **DaylightSaving**: o que a abolição do horário de verão
(Decreto 9.772, de 25/04/2019) fez com mortes no trânsito e acidentes no Brasil.
Autores: Fredie Didier e Leonardo Monasterio (coautor desde 16/10/2026; o que ele
sugeriu está em `horario_verao/monasterio.md`). Primeiro rascunho do manuscrito em `latex/` (13/10/2026),
alvo **AEJ: Economic Policy** (escolha, normas, divisão corpo/apêndice e
cortes em `horario_verao/PAPER.md`, seção "Manuscrito"). Para o conhecimento
do campo (literatura, desenhos, armadilhas), acione **`horario-verao-econ`**.

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
    prf_municipio_alias.csv   nomes da PRF que diferem do IBGE (auditoria 09/10/2026)
  build/01_dst_calendar.R   → painéis UF × temporada e UF × dia; gera TABELA_ESTADOS.md
  build/02_download_prf.R   PRF 2007–2025 (Google Drive da PRF)
  build/03_clean_prf.R      PRF harmonizada, um acidente por linha
  build/04_municipal_geo.R  sede municipal (geobr 2010; os 5 municípios de 2013 por
                            ponto no limite de 2020) + fuso padrão
  build/05_download_sim.R   SIM 2008–2025 do FTP do DATASUS
  build/06–07               PNCT (volume horário do DNIT): download e limpeza
  build/08–09               chuva (Xavier), iluminação (Censo)
  build/10–12               fronteiras do mapa; PRF por pessoa (sexo, idade dos mortos);
                            municípios defrontantes com o mar (IBGE)
  analysis/code/00_utils.R  grupos, janelas, sol, painel (fonte única)
  analysis/code/00_master_analysis.R  roda 01–28 em ordem (config/00_master_build.R faz o build)
  analysis/code/01…26       hora que trocou de luz (01, grava o arquivo de eventos)
                            → event study (02) → relógio da PRF (03) → tendências (04)
                            → imputação (05) → inferência (06) → HonestDiD (07)
                            → janela larga (08) → dentro do dia (09) → agressões (10)
                            → realocação (11) → pedestre (12) → números da Tabela 1 (13)
                            → inferência do pedestre (14) → volume do PNCT (15) → inferência do volume (16)
                            → Bahia 2011/12, checagem de sinal (17) → placebo das horas (18)
                            → amontoamento (19) → deixar um de fora (20) → usuários da via (21)
                            → integridade do registro (22) → dose de luz e chuva (23)
                            → iluminação pública (24) → custo (25)
                            → trocas de relógio antes de 2019 contra a abolição (26)
  analysis/code/27, 28      TODAS as figuras (27) e tabelas .tex (28), lidas só dos .rds
  latex/                    paper.tex (submissão, anônima, AEA.cls), appendix.tex,
                            title_page.tex, paper_wp.tex; texto em sections/;
                            ./build.sh compila tudo
  analysis/output/maps/     mapa do Brasil (27_figures.R; fronteiras do build/10)
  horario_verao/            CONTEXTO_PESQUISA, ROADMAP, TABELA_ESTADOS,
                            VIABILIDADE, PAPER, fontes_legais/, skills/

~/Library/CloudStorage/Dropbox/DaylightSaving/build/   (dado, nunca git)
  calendar/ prf/ geo/ sim/ pnct/ weather/ census/ audit/   (audit/ guarda os .rds)
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
  Imputação com semana + dia da semana (05). Wild cluster bootstrap no análogo
  linear e permutação dos estados tratados (06; "permutation inference",
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
4. **A hora da PRF é hora legal** (conferido em `03_prf_clock_check.R`: a curva
   de "escuro" se desloca ~55 min entre os regimes).
5. **SIM preliminar nunca entra** (`preliminary == TRUE`).
6. **A tabela `.rds` em `audit/` vence qualquer número escrito**, inclusive aqui
   e no VIABILIDADE.md.
7. **Município da PRF: nome + `build/manual/prf_municipio_alias.csv`.** Sem a
   tabela, ~0,4% dos acidentes caíam (auditoria de 09/10/2026). Nome novo que
   não casar entra na tabela, conferido contra as coordenadas da própria PRF.
8. **Contagens de excesso (mortes por verão) só incluem óbitos com hora
   registrada** (15–20% das mortes na via não têm hora). São limite inferior
   também por isso; o "dia todo" do 12 e da Tabela 1 é "com hora válida".

## Onde o resultado está, e como dizer

Os números vigentes estão em `horario_verao/VIABILIDADE.md` (§17 é a rodada vigente,
depois da auditoria de 09/10/2026; a tabela-resumo está no PAPER.md) e em
`audit/*.rds`. O que se pode dizer hoje:

- O **primeiro estágio** é enorme e medido por terceiros: a parcela de
  acidentes que a PRF anota como crepúsculo ou noite na hora 0 subiu 23,6 p.p.
  (EP 2,0) nos tratados (`23`, `light_dose.rds`).
- **A hora que escureceu ganhou mortes de trânsito.** O SIM é o resultado
  âncora, porque passa nos testes de tendência; a PRF corrobora, mas é sensível
  à tendência.
- **A hora que escureceu:** SIM 29,2 lp (EP 9,0), PRF mortes 54 (20), com
  vítima 22,2 (5,6); WCR e permutação passam nas três.
- **Quem morre é o pedestre** (VIABILIDADE §11, §17): hora 0, SIM +77 lp contra
  +18 do resto; 12% da base, 43% do excesso; resiste à tendência pré, ao WCR e à
  permutação (VIABILIDADE §11).
- **SIM × PRF** (VIABILIDADE §13): bases diferentes (todas as vias × rodovias
  federais); na hora 0 não divergem de fato; a PRF corrobora o mecanismo, não o
  tamanho do excesso.
- **O tráfego seguiu a luz** (PNCT, VIABILIDADE §14): noite −6% de veículos,
  manhã +12%; por veículo, a hora escura +24,0 lp (7,8) nos acidentes com vítima,
  nos verões das estações (permutação p = 0,005; `15`, `16`). Nenhum
  posto é contado antes e depois; jul/2019–abr/2021 sem contagem (Nota Técnica
  DNIT 001/2020/DE).
- **A manhã não paga a conta da noite** (VIABILIDADE §10): noite escura
  (horas 0 e +1) +57 mortes na via por verão (EP 19), manhã clara −3 (11),
  líquido +54 (p = 0,007). O total do dia tem EP 66: é **inconclusivo**, não
  zero. Na PRF as horas antes do pôr do sol perdem o que a noite ganha.

**Sono (entra no paper; rascunhos em inglês no PAPER.md):** a janela exclui as
semanas da troca e a abolição não tem noite de sono perdida; o sono crônico se
descarta pela hora única, pelo FE de UF × dia, pelo pedestre e pelo placebo das
horas de luz inalterada (`19`, VIABILIDADE §16: nada sobe no meio do dia nem na
noite fechada).

**Contribuição, dita com cuidado:** medir a hora pelo pôr do sol local **não é
novo** (Doleac & Sanders; Toro 2016 com homicídios no Brasil; Mitre-Becerril
2026). O novo é o fim do regime (sem sono, só luz), o trânsito com óbito na via e
a mesma janela do calendário em 11 temporadas com e 5 sem. Franco et al., Toro e
Cortes et al. estudam o horário de verão enquanto ele existia; nenhum estuda o fim.

**Rodada do parecer (12/10/2026, VIABILIDADE §19, EXPLICANDO §5.12):**
amontoamento das horas (34,5% em hora cheia; a estimativa resiste a mover a
janela e trocar a fórmula solar), tirar um de fora (SIM 24–35), quem morre
(pedestre 77, moto 20, carro 0; fim de semana > dia útil), registro sem
mudança, dose (hora toda escura ~124 lp), iluminação (Censo 2022: 42,5 contra 10,9, p = 0,10 desde 18/10;
sem precisão), custo em reais de 2025 (54/67/137 mortes por verão;
VSL R$ 253/311/637 mi; Ipea R$ 43/53/108 mi). Parecer e ranking de periódicos
em `PARECER.md`: AEJ Applied → AEJ Policy → JHE (depois do México). **México** (`29`, `30`): a réplica
vale pelo desenho dentro do dia (horas de referência do `09`, desde 15/10/2026: mortes +58, pedestres +143; o mesmo estimador só nos tratados do Brasil dá +47); a tripla com 6
controles é frágil. Energia: MME NT 5/2019 (+0,7% de carga), ONS 2024; os R$
159,5 mi de 2016/17 (imprensa) não se citam.

**Rodada do parecer simulado da AEJ: Policy (15/10/2026, `PARECER_AEJ_POLICY.md`):**
- **Luz, não relógio** (`23`, Tabela 4 do paper): dose de escuridão pelo sol (noite 1,
  crepúsculo civil 1/2) por hora do relógio, com EF hora do relógio × data. Hora da
  noite de dia pleno a noite: mortes na via +47,7 lp (9,7); com efeito livre por hora
  do relógio nos tratados pós (só a diferença de pôr do sol entre tratados identifica)
  +52,4 (18,3); manhã −6,4 (14,7). Controle contado na hora do relógio da hora 0 dos
  tratados (`20`): 32,9 (12,1).
- **Contagem líquida sem escolher horas** (dose): 62 (12) por janela de verão, 74 (14)
  por temporada inteira da regra de 2017; escalas 91 e 186; VSL R$ 344 mi por temporada
  (R$ 867 mi na escala ampla). A soma de três horas (54, EP 20) virou checagem.
- **Dinâmica** (`04`, Figura B3): a tripla dá 48,7 nas duas primeiras temporadas e 15,8
  nas três últimas, mas isso vem da perna do inverno (o fora de temporada de 2019/20
  inclui abr–jun/2020). Só o verão: 39,3 e 31,2. Sem mar/2020–fev/2022: 22,9 (9,1).
  Faixa honesta: 22,9 a 34,5 lp (23 a 34 arredondado).
- **Trocas de relógio** (`26`): efeito de uma noite mais escura nas 3 semanas após cada
  troca, 42,3 (13,8) contra 29,2 da abolição; dentro do dia, 79,1 contra 27,7. Num
  modelo empilhado (covariância das amostras sobrepostas), abolição menos trocas:
  −13,1 (12,5), p = 0,29, na comparação entre estados; −51,4 (18,3), p = 0,005,
  dentro do dia. **Mas as trocas caem em período letivo e a janela é quase toda
  férias** (18/10/2026): contra a abolição só nas semanas com aula, as trocas não se
  distinguem (15,8, EP 18,0; dentro do dia −22,2, EP 20,9). Não escrever que o efeito
  "caiu dois terços" nem que as pessoas "se ajustaram"; o que se diz é que, na mesma
  época do ano letivo, o efeito cinco verões depois é próximo do efeito logo após a
  troca (sem descartar queda moderada).
- **Aula contra férias** (`20`, Tabela B1; datas em `00_utils.R::school_part()`,
  fontes em `horario_verao/fontes_dados/calendarios_escolares.md`): aula 15/11–07/12,
  férias 24/12–15/01, 2020/21 fora. Mortes na via, hora 0: aula 58,1 (12,6), férias
  −12,3 (16,8). No paper (Tabela B1, painel D): férias de 24/12–01/01 5,8 (28,7) e de
  02–15/01 −27,9 (19,0) (não são as festas); diferença aula − férias sem litoral 66,6
  (22,1), sem Pará 73,7 (21,3) (o Pará, controle, tem ano letivo de março a janeiro);
  placebo pré-2019 −15,9 (26,2). Fora do paper, por falta de células: pedestres por
  parte (~3 mortes por verão em cada); a diferença vem dos demais usuários. Contagem
  da temporada com o efeito das semanas com aula nos dias extras: 79 em vez de 74
  (`light_dose.rds`, `season_net_term`); o paper diz que 74 é conservador.
- **Pesos municipais** (dose, chuva, relógio dos tratados, iluminação): mortes antes
  de 2019 (`seat_weights()`, 18/10/2026). Janela de verão: 62 mortes (era 63).
- **México com placebo** (`27`, Tabela C1 painel E): nas unidades que mantiveram o
  relógio, o mesmo estimador dá mortes −20 (27), mas acidentes +10,8 e atropelados
  +20,7. O México sustenta mortes, não acidentes.
- **Volume** (`15`, `16`): acidentes reestimados nos verões das estações; hora 0 +17,6,
  por veículo +24,0 (permutação p = 0,005), sem tendência pré nesses verões.
- Score bootstrap no Poisson (`06`): p = 0,010 / 0,023 / 0,001.

**Rodada do Monasterio de 20/10/2026 (PDF anotado + 9 áudios; ROADMAP):**
- **México saiu do paper** (código 10/11 do build e 26/27 da análise apagados; scripts
  renumerados: build 10 mapa, 11 PRF por pessoa, 12 litoral; análise 26 trocas,
  27 figuras, 28 tabelas). Os dados do México foram apagados do Dropbox (21/10). Ignorar
  a seção México abaixo, que é histórico.
- **Número de manchete: 62 por janela de verão** (dose; supõe zero nas horas cuja luz
  não mudou). 74 por temporada é extensão (coeficientes da janela aplicados fora dela).
  Resumo e conclusão citam 62; Tabela 7 valora a janela (Painel B) e a temporada só na
  referência (Painel C).
- **Custo em dólares internacionais de 2025 (PPC)**: janela 114 mi (EP 22), 287 na
  escala ampla, até 571 nas regras alternativas; Ipea 19–49; temporada 135. ONS
  convertido no mesmo fator (2,55441): combustível 96–139 mi, capacidade ~0,7 bi.
- **Tabela A1 (`tab_measurement`)**: validação da hora do óbito (pares SIM↔PRF 59,2 vs
  4,7; tripla nas parcelas na via e sem hora; amontoamento; janelas ±5/10/15 min;
  espalhar/retirar :00 e :30; Meeus). Saiu o Painel A da Tabela B1 (painéis relettrados).
- MME NT 5/2019: o aumento de carga é "possivelmente" por mudança de hábitos de uso dos
  equipamentos (ar-condicionado de madrugada); não escrever "household" como fato.
- "Casualties" para mortos e feridos nos acidentes da PRF.

**Rodada do Leonardo Monasterio (16/10/2026, `monasterio.md`, VIABILIDADE §21):**
sexo e idade dos mortos nas duas bases (Tabela B4; PRF por pessoa no `build/11`,
idade 0 da PRF = desconhecida desde 2017): homens, ~4/5 dos mortos, SIM 33,8
(9,9), PRF 65,2 (20,7); mulheres imprecisas demais para comparar (não dizer
"não subiram"); idades a partir de 15 positivas, sem ordenação. Sem os 279
municípios do litoral (`build/12`, Tabela B1): 36,3 (9,4). "Abolished" para
2019, "the clocks went back/forward" para a troca sazonal. Fora: rugosidade
(ofuscamento já saiu em 13/10) e luz por satélite. Custo com ele, para depois.

**Apêndice:** Bahia 2011/12 como checagem de sinal (`18`, VIABILIDADE §15):
primeiro estágio claro (PRF anota escuro em 68% contra 93–100%); na noite, os
acidentes com vítima têm o menor valor de 16 temporadas; a manhã não aparece.
Uma temporada só: p ≈ 0,06, nada além disso.

**Fora, decidido:** fronteira estadual (sem poder: ~1 morte por temporada na
hora 0 a até 100 km da divisa); liga-desliga do TO; agressões; nascimentos.

**O que não se escreve:**
- que a abolição "aumentou as mortes no trânsito" sem dizer "nas horas que
  escureceram"; nem que o total do dia "não muda" (é só ruidoso demais);
- que a PRF "confirma" sem a ressalva da tendência;
- que o México replica os acidentes (o placebo nas unidades que mantiveram o relógio
  sobe quase o mesmo); só mortes;
- qualquer efeito sobre nascimentos (partos seguem o relógio do hospital) ou
  sobre agressões (tendência, não luz: VIABILIDADE §9).

## Abertos

- A **hora antes do pôr do sol** cai na PRF (e não no SIM). Mecanismo candidato:
  ofuscamento pelo sol baixo, tráfego que muda de hora.
- Ler o texto completo de Gillmore (2025) e Depalo (2023) antes de citar números
  além do resumo.
- Status do projeto de lei de 2025 que proíbe o horário de verão.
- Controle no relógio de Brasília (15/10/2026, `tab_within_group`): o tráfego da
  noite do controle não se moveu; as mortes na via na hora 0 do controle subiram
  (+19,7) em relação ao resto do dia. O placebo mexicano mostra o mesmo tipo de
  subida em acidentes onde nada mudou; o mecanismo segue sem teste direto.
- SIM 2025 definitivo: 6ª temporada pós.
