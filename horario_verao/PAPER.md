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
   literatura usa as transições (a semana da troca: Smith 2016; Franco et al.
   no Brasil). O debate de política é sobre o regime permanente (EUA, UE, o
   PL 397/2007 na Câmara), e um choque permanente não é uma transição: não há
   perda de sono, só a luz.
2. **O teste está na hora exata.** O tratamento é a hora do relógio
   [pôr do sol padrão, +60 min), calculada por município e dia. Blocos fixos
   de hora diluem o efeito (VIABILIDADE §3). O espelho de manhã serve de teste
   de sinal.
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
- Poisson PML, `y ~ tratado × janela × pós | UF×janela + UF×temporada + data`,
  painel UF × dia, EP por UF (23 clusters).
- Inferência que não depende de 23 clusters: wild cluster restrito (Webb) e
  permutação dos 11 estados tratados.

## Resultados (o que já sabemos)

| | SIM, mortes na via | PRF, mortes | PRF, com vítima |
|---|--:|--:|--:|
| primeiro estágio: escuro às 18–19h | | +33,7 p.p. (1,5) | |
| hora que escureceu (lp) | **29,5 (9,0)** | **56 (21)** | **22,9 (5,7)** |
| WCR p / permutação p | 0,009 / 0,015 | 0,002 / 0,017 | 0,001 / 0,001 |
| imputação, tendência pré extrapolada | +38% [−11, 103] | +26% [−24, 108] | +10% [−4, 29] |
| excesso por verão, noite 0 e +1 | **+58 (19)** | **+33 (10)** | **+147 (38)** |
| manhã que clareou, por verão | −3 (11) | −6 (8) | −57 (34) |
| dia todo, por verão | −2 (66) | −58 (45) | −70 (216) |

**A frase do paper:** a abolição trouxe ~55 mortes na via a mais por verão
nas horas que escureceram; a manhã que ganhou luz não compensa. O total do dia
é estimado com ruído demais para dizer se o saldo aparece nele. É um limite
inferior, porque exclui quem morre no hospital.

**Mecanismo: o pedestre** (VIABILIDADE §11). Na hora 0, as mortes de
pedestres sobem +79 lp no SIM e +173 lp na PRF; as dos demais, +18 e +28. O
pedestre é 12% da base e 44% do excesso no SIM. Resiste à tendência pré.

**A PRF corrobora com duas ressalvas:** (i) perde metade do efeito com a
tendência pré extrapolada; (ii) as horas antes do pôr do sol perdem tanto
quanto a noite ganha, o que nas rodovias federais parece realocação de hora
(VIABILIDADE §10).

## Exibições previstas

1. **Fig. 1**: o primeiro estágio. A parcela anotada como escuro pela PRF,
   por minuto relativo ao pôr do sol, com e sem horário de verão (04).
2. **Fig. 2** (`fig07_design`, feita): diagrama do desenho. Pôr do sol padrão e com horário de verão ao
   longo do ano numa cidade tratada; a hora que trocou de luz sombreada.
3. **Fig. 3**: efeito por hora relativa ao pôr e ao nascer do sol (fig02). O
   gráfico central: o pico na hora 0, e nada longe dela.
4. **Fig. 4**: estudo de eventos por temporada, hora 0 (fig03).
5. **Tabela 1** (`table1_descriptives`, feita): descritivas por grupo × janela × período.
6. **Tabela 2**: tripla na hora 0, três desfechos; EP por UF, WCR, permutação.
7. **Tabela 3**: a conta da realocação (12), com a divisão pedestre × resto (13).
8. **Tabela 4**: robustez. Tendência pré (imputação), sem COVID, janela mais
   larga, diferença quádrupla, hora faltante. HonestDiD no apêndice.
9. **Apêndice**: calendário legal (TABELA_ESTADOS), checagem do relógio da PRF,
   agressões (11) como nulo, quebra da e-DAT.

## O que não entra

- Nascimentos (os partos seguem o relógio do hospital) e agressões (sem
  assinatura de luz, VIABILIDADE §9).
- A contagem total da PRF (e-DAT).
- Fronteiras GO/MG × BA/TO e os liga-desliga de BA 2011/12 e TO 2012/13:
  ficam como extensão, se o parecerista pedir mais identificação.
- Zero-inflated e binomial negativo (sem excesso de zeros, §7).
- A frase "a abolição aumentou as mortes no trânsito" sem "nas horas que
  escureceram".

## Abertos antes de escrever

0. ~~Pedestre contra ocupante~~ feito (13): é o pedestre.
1. **Fluxo de tráfego (PNCT/DNIT, volume horário 2014–19 e 2021–25; VIABILIDADE §12)**: separar exposição de risco por viagem e
   explicar a queda nas horas −1/−2 da PRF.
2. ~~WCR e permutação para o pedestre~~ feito (15): passa nas três fontes.
3. Bootstrap da imputação para as somas da realocação (hoje por método delta,
   sem tendência).
4. Periódico-alvo: AEJ Applied ou AEJ Policy (Smith 2016 está na Applied);
   JHE ou JPubE como alternativa.
