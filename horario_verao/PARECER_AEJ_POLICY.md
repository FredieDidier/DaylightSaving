# Parecer interno: simulação de AEJ: Economic Policy

**Manuscrito:** "Darker Evenings: Road Deaths after Brazil Abolished Daylight
Saving Time" (`latex/paper.tex` + `latex/appendix.tex`, commit `70cb81c`).
**Data:** 15/10/2026. Escrito por Claude a pedido do Fredie, no papel de
parecerista e de editor da AEJ: Policy.

**Como ler.** É uma simulação: o que um parecerista exigente e o editor
provavelmente escreveriam. Não reestimei nenhum modelo. Os números vêm das
tabelas e figuras compiladas e dos caches em `audit/*.rds`. Duas contas são
minhas e estão marcadas: os horários do pôr do sol nas capitais (função
`sun_times` do projeto, aplicada às capitais; o paper usa as sedes municipais)
e as médias das temporadas pós em relação à média das pré (médias simples dos
coeficientes de `switched_hour_event_study.rds` e `within_day.rds`, sem erro
padrão).

Este parecer é independente do `PARECER.md` (12 e 15/10). O que aquele parecer
pediu e já está no paper (custo, dose, amontoamento, tirar um de fora, quem
morre, iluminação, integridade do registro, radares, relógio de Brasília) não
volta aqui, a não ser quando um parecerista insistiria.

---

## 1. Carta do editor (simulada)

> Dear Author,
>
> I have now received two reports on your manuscript. Both referees find the
> question timely and the design attractive: a permanent change of regime, an
> hour defined by the local sun, a first stage recorded by third parties, and
> two independent registers. Both also find the paper unusually candid about
> its limits.
>
> Their concerns converge on three points, which I share. First, the paper
> does not yet separate the change in light from the clock time at which the
> treated states' summer hour 0 falls. Second, the effect on road deaths is
> concentrated in the first two seasons after abolition, which matters for a
> paper whose policy number is a per-summer steady state. Third, the net
> number of deaths, the quantity a policymaker needs, rests on a set of hours
> chosen after the fact, while the whole-day estimate is uninformative.
>
> I am therefore inviting a major revision. A revision that does not answer
> these three points is unlikely to succeed.

**Decisão simulada: revise and resubmit, major.** O risco de rejeição na
primeira rodada é real e vem de M2 e M3 abaixo. Um parecerista cético pode
resumir o paper como "um aumento de 30 mortes por verão numa hora, concentrado
em duas temporadas atípicas, com efeito líquido no dia indeterminado". O paper
precisa tornar esse resumo insustentável.

---

## 2. Relatório do parecerista

### Resumo do paper

O Brasil aboliu o horário de verão em 2019. Para cada município e dia, o autor
calcula a hora do relógio depois do pôr do sol em hora padrão (a "hora 0"),
que era clara com horário de verão e é escura sem ele. Uma diferença tripla
(tratados × janela de verão × pós) em Poisson com efeitos fixos estado×janela,
estado×temporada e data dá +29,2 lp (34%) nas mortes na via na hora 0 (SIM,
11 tratados, 12 controles, 2008/09–2023/24), +54 lp nas mortes nas rodovias
federais e +22 lp nos acidentes com vítima (PRF). Pedestres respondem por 43%
do excesso. A hora da manhã que clareou não compensa (−3 lp, EP 12). O autor
soma 54 mortes por verão em três horas, avalia-as em R$ 253 milhões pelo VSL de
referência e repete o desenho na abolição mexicana de 2022.

### Avaliação geral

**O que funciona.** A pergunta é de política no sentido estrito: o Brasil
discute voltar com o horário de verão (ONS 2024) ou proibi-lo (PL aprovado em
comissão em 2025), e EUA e UE discutem regimes permanentes. O desenho é bom:
a hora 0 muda com o sol de cada lugar e data, o primeiro estágio está no
registro do policial (+23,6 p.p. de acidentes no escuro), a janela exclui as
semanas após as trocas, e não houve noite de transição. A inferência vai além
do EP agrupado (bootstrap selvagem, permutação sobre a estatística t). O texto
é limpo e diz com franqueza o que não sabe.

**O que impede a aceitação hoje.** (i) A hora 0 dos tratados no verão ocupa uma
faixa do relógio que nenhuma outra célula ocupa, e o paper não separa luz de
hora do relógio (M1). (ii) O efeito no SIM está nas duas primeiras temporadas
pós, e o efeito na PRF cresce com o tempo, como uma tendência cresceria (M2).
(iii) O número de política (54 mortes) depende de uma escolha de horas feita
depois de olhar os dados e cobre 92 dias, não a temporada (M3). Os demais
pontos são sérios, mas consertáveis.

### Comentários principais

#### M1. Luz ou hora do relógio?

A defesa central do paper é: "a regional shock or trend would have to follow
the sunset of each municipality to produce the estimate" (Introdução). A frase
é afirmada, não testada. O que a diferença tripla compara, na prática:

| célula | início da hora 0 nas capitais (hora padrão) |
|---|---|
| tratados, verão (1º jan) | 18:19 (Cuiabá) a 19:29 (Porto Alegre) |
| controles, verão (1º jan) | 17:37 (Natal) a 18:37 (Porto Velho) |
| tratados, fora (15 jun) | 17:06 (Campo Grande) a 17:51 (Goiânia) |
| controles, fora (15 jun) | 17:09 (Recife) a 18:28 (Macapá) |

*(Conta minha: `sun_times` do projeto nas capitais.)*

Pelas medianas, a hora 0 dos tratados no verão começa uns 50 a 90 minutos mais
tarde no relógio do que nas outras três células. Qualquer mudança nacional pós-2019 no risco entre
18:30 e 20:30, relativa ao risco entre 17:00 e 18:30, carrega no β. Exemplos:
trabalho remoto encurtando o pico das 17–18h, entregas por aplicativo no jantar,
comércio fechando mais tarde. Nenhum dos efeitos fixos absorve isso: data é
comum a todas as horas, estado×janela e estado×temporada são proporcionais em
todas as horas, e o efeito fixo estado×dia compara com 14–16h e 21–23h.

O próprio desenho oferece a ferramenta: a variação do pôr do sol entre lugares
e datas. Ela existe: ~70 minutos entre as capitais tratadas, e superposição no verão entre
tratados a oeste (MT 18:19, MS 18:22, ES 18:25) e controles do Norte (PA
18:23, AP 18:31, RO 18:37).

Pedidos:
1. **Corrida entre as duas explicações.** Empilhar as horas e incluir, ao lado
   das faixas relativas ao pôr do sol × T×W×A, faixas de hora do relógio × W×A
   (nacionais). Se o efeito é luz, ele fica na faixa relativa ao sol e some na
   faixa do relógio.
2. **Placebo nos controles.** Para cada data, uma "pseudo hora 0" nos
   controles na faixa do relógio onde cai a hora 0 dos tratados naquela data.
   Ela não deveria subir.
3. Mostrar o perfil bruto das mortes por hora do relógio (tratados, verão, pré
   contra pós).

O paper já tem um indício contra a história do relógio: o efeito é maior nos
fins de semana e feriados (41,3) que nos dias úteis (16,1), o que não combina
com trabalho remoto. Mas combina com lazer e entregas no jantar, que também
caem nessa faixa. E o +19,7 lp dentro do dia nos controles (M4) é justamente o
tipo de deslocamento por hora do dia que a corrida acima testaria.

#### M2. O efeito está nas duas primeiras temporadas

Coeficientes da hora 0 por temporada, em relação à média das temporadas pré
*(conta minha, médias simples dos coeficientes, sem EP)*:

| | 2019/20 | 2020/21 | 2021/22 | 2022/23 | 2023/24 |
|---|---|---|---|---|---|
| SIM, tripla | +58,6 | +42,4 | +12,9 | +7,5 | +30,4 |
| SIM, estado×dia | +71,8 | +34,9 | +4,9 | +13,3 | +20,2 |
| PRF acidentes c/ vítima, tripla | +7,7 | +14,9 | +27,5 | +25,6 | +33,1 |

No SIM, as duas primeiras temporadas dão em média ~50 lp e as três últimas
~17 lp. Na PRF é o contrário: o efeito cresce, como a tendência pré (teste
conjunto p < 0,001) prevê. Se fosse só luz, as duas fontes deveriam ter a
mesma dinâmica.

As duas primeiras temporadas também são as atípicas. Em 2019/20 houve a
suspensão dos radares da PRF (ago–dez/2019). Ela afeta o SIM também, que inclui
as mortes nas rodovias federais. Em 2020/21 houve a pandemia. O texto informa
que a PRF sem 2019/20 sobe (65,0 e 25,7), mas não informa, na mesma frase, que
o SIM sem 2019/20 cai para 22,7 (9,8). Um parecerista vai ler isso como
seleção.

Há três leituras possíveis: adaptação, que é o que o argumento de evitação da
Introdução prevê; choques transitórios em 2019/20–2020/21; ou ruído. Elas têm
consequências diferentes para o número de política, que é um estado
estacionário por verão.

Pedidos:
1. β separado para 2019/20–2020/21 e para 2021/22–2023/24, com teste de
   igualdade; e uma versão com pós × tendência.
2. A temporada 2024/25 assim que o SIM 2025 for definitivo.
3. O custo por verão baseado no estado estacionário, ou dito explicitamente
   como média de um efeito que pode estar caindo.
4. **A exclusão da pandemia está mal recortada.** A temporada vai de julho a
   junho (`make_days` em `00_utils.R`), então o lockdown mais duro
   (abr–jun/2020) cai no fora de temporada de 2019/20, que a robustez "without
   the 2020/21 and 2021/22 seasons" mantém. A exclusão deveria ser por
   calendário (mar/2020–dez/2021). Um dado tranquiliza e deveria estar no
   texto: pela Tabela 1, a tripla vem do verão (diferença dupla de verão
   ≈ +34 lp; de fora ≈ +5 lp, que entra com sinal negativo), não de uma queda
   no fora de temporada. *(Conta minha, log das razões de contagens da
   Tabela 1.)*

#### M3. O número de política

O resumo e a conclusão dizem que a abolição custou 54 vidas por verão "in the
hours whose light changed". Quatro problemas:

1. **O conjunto de horas foi escolhido depois e é assimétrico.** Entram a hora 0
   da noite, a hora +1 da noite (crepúsculo → noite) e a hora 0 da manhã. Ficam
   de fora a hora −1 da manhã (noite → crepúsculo, o espelho da +1 da noite) e a
   hora −1 da noite, que o texto chama de "changed only in degree". O próprio
   paper é inconsistente: a Figura 3 marca como "Hour whose light changed" só a
   hora 0, e a Figura 4 e o painel B das tabelas do México e da iluminação
   (apêndice) chamam a hora −1 de "light unchanged".
2. **O efeito líquido não é identificado.** Sete horas: 41 (41). Dia inteiro:
   −5 (66). A AEJ: Policy vai perguntar quantas mortes por ano a escolha de
   regime custa, e hoje a resposta honesta é "não sabemos o sinal do total".
3. **"Por verão" quer dizer 92 dias.** A janela vai de 15/11 a 14/02. O
   horário de verão pela regra de 2017 durava ~105 dias, e pela de 2008, de
   ~126 a 133.
   Para o contrafactual "voltar com o horário de verão", a contagem por
   temporada fica 14% a 37% maior se o efeito diário for constante (não é,
   porque o pôr do sol muda com a data). Dizer isso, ou escalar.
4. **A dose vem do registro do policial**, que só existe para acidentes que
   aconteceram. Se o escuro gera acidentes, a parcela "escuro" sobe
   mecanicamente. O paper reconhece isso. A dose pode vir da astronomia.

Pedido: **um modelo de dose contínua.** Para cada minuto do dia, a mudança de
luz entre os regimes (por exemplo, minutos com o sol abaixo de −6°, ou a
mudança na elevação solar). O efeito entra linear na dose, e todas as horas
participam, com dose zero onde a luz não mudou. Isso dá um efeito líquido no
dia com estrutura, mais preciso que o dia inteiro sem restrição, e resolve a
escolha de horas por construção. É a linha de Bunnings & Schiele (2021), já
citados.

#### M4. O controle se mexe sozinho, e o México depende do estimador que falha nele

Dentro do dia, nos estados de controle, onde a luz não mudou (Tabela
`tab_within_group`):
- noite, mortes na via na hora 0: **+19,7 (6,5)**;
- manhã, mortes na via na hora 0: **−23,5 (9,6)**.

São dois movimentos significativos onde o desenho prevê zero. O paper atribui
isso à programação no horário de Brasília. É plausível, mas não foi testado, e
o tráfego da manhã nos controles subiu (+10,8, EP 4,0), o que essa história
não prevê com clareza. Consequências:
- A tripla (29) e a comparação só nos tratados (47) são um intervalo. O texto
  trata o 47 como sinal de que a tripla subestima. Um parecerista vai querer
  ver as duas tratadas simetricamente.
- **No México, o resultado que sobra é o painel D**, a comparação dentro do
  dia, isto é, o estimador que nos controles brasileiros dá ±20 lp sem
  tratamento. A tripla mexicana tem a hora −1 em −126 lp e os acidentes com
  vítima na hora 0 em −0,8 (3,7). Este último número não aparece no texto.

Pedidos:
1. Rodar o painel D nas seis unidades mexicanas que mantiveram o relógio,
   como placebo (`27_mexico_within_day.R` já tem a estrutura).
2. Citar no texto os −0,8 da tripla mexicana para acidentes com vítima.
3. México sem 2020–2021: a pandemia caiu dentro da janela de verão mexicana
   (abr–out).
4. Documentar a cobertura do ATUS: municípios informantes por ano.
5. Suavizar "Mexico's 2022 abolition shows the same pattern" no resumo, ou
   fortalecer a evidência até que a frase se sustente.

#### M5. A PRF não sustenta o mecanismo que o texto pede dela

O paper diz que usa a PRF "for the first stage and the mechanism". O primeiro
estágio está bem. Já o mecanismo herda a tendência:
- **Risco por veículo** (+28,6 lp) = acidentes (22,2) − volume (−6,4). Com a
  tendência, os acidentes caem para 5,6 (8,0), e o risco por veículo para ~12
  (se o volume não mudar).
- **Contraste dos pedestres "sharper on federal highways"** (170 lp contra 26).
  É a mesma fonte com tendência.
- **O volume é identificado só pela troca de estações.** Nenhuma estação é
  contada antes e depois. O modelo tem efeito fixo de estação e uf×janela
  (`15_traffic_volume.R`, `FEV`), então o termo verão×pós compara a diferença
  sazonal das estações novas com a das antigas. Uma mudança de composição
  entre os contratos produz o resultado sozinha. Estação×janela não resolve,
  porque absorve o termo. O caminho é parear as estações dos dois contratos
  por rodovia e km.
- **Temporadas desalinhadas.** O volume usa 2014/15–2018/19 e 2021/22–2024/25,
  e os acidentes usam 2008/09–2023/24. A PRF vai até 2025, então dá para
  reestimar os acidentes nas temporadas do volume antes de subtrair.

Pedido: reportar o risco por veículo e o contraste dos pedestres com o
estimador robusto à tendência (imputação com tendência pré, ou estado×dia com
o event study ao lado). Se não sobreviverem, a PRF fica como primeiro estágio
e validação do relógio.

#### M6. Magnitude e comparações com a literatura

- O efeito implícito de uma hora totalmente escura é 124 lp (×3,4) para todas
  as mortes na via e 228 lp (×9,8) para as mortes na PRF. Para usuários que
  não são pedestres, isso é grande. O paper precisa de uma referência externa:
  razões de risco escuro/claro por tipo de usuário (Sullivan & Flannagan 2002)
  e o efeito do escuro em Bunnings & Schiele (2021).
- "The size of the effect is in line with earlier estimates" não se sustenta
  como está escrito. Coate & Markowitz (2004): −13% pedestres e −3% ocupantes
  nos períodos afetados. Aqui: +17% para todos os usuários em três horas, e
  pedestres +115% na hora 0. Ou se reconcilia (bases diferentes), ou se tira a
  frase.
- A comparação com as ~30 mortes por ano de Smith (2016) mistura sono (EUA,
  transição) com luz (Brasil, regime). Com bases de exposição diferentes, é
  retórica. Um parecerista pede para cortar.

#### M7. A contribuição prometida não é medida

A Introdução vende o regime contra as transições: as transições medem a luz
"before travel has adjusted", e o regime mede "once travel has adjusted". O
paper nunca mede a primeira coisa nos próprios dados. O pedido natural:
**estimar o efeito de curto prazo na troca de fevereiro** (fim do horário de
verão, 2009–2019), na hora 0, no SIM e na PRF. Ali a noite escurece de um dia
para o outro. O sono da troca de fevereiro é ganho, não perda, e afeta todas as
horas, então o desenho por hora o isola. Comparar com o efeito do regime:
- se o regime for menor, a adaptação está medida, e o argumento de evitação
  (Neidell 2009) deixa de ser decorativo;
- se for igual, o tráfego não se ajusta, o que também é um achado.

No mesmo espírito: a Introdução diz que o dano observado é líquido da
evitação. Então a contagem de mortes é um limite inferior do custo de bem-estar
(viagens que mudaram de hora custam algo). A seção de custo deveria dizer isso.

Também falta situar o paper em relação a Franco et al. (2023), que usam a PRF
no Brasil com RD e diferença entre estados. Os números são compatíveis? Uma
frase basta.

### Comentários menores

1. **Rótulo da hora −1.** "Light unchanged" (legenda da Fig. 4; painel B das
   tabelas do México e da iluminação) contra "changed only in degree" (texto).
   Escolher um.
2. **Amontoamento.** Sem :00 e :30, o SIM cai para 16,7 (12,9), queda de 43% na
   estimativa pontual. Em vez de descartar, redistribuir cada morte em hora
   cheia ou meia hora uniformemente em ±15 min e reestimar.
3. **Controle só do Norte:** 15,7 (8,8), metade do 32,9 com o Nordeste. Merece
   uma frase no corpo, não só a tabela do apêndice.
4. **Event study normalizado pela média pré**, não por 2018/19, que foi uma
   temporada alta no SIM e baixa na hora −1 da PRF. De quebra, o alvo do
   HonestDiD passa a coincidir com β, o que o paper hoje precisa explicar à
   parte.
5. **Inferência no modelo principal.** O bootstrap selvagem roda no modelo
   linear, cujos efeitos são maiores (46% contra 34%). O score bootstrap de
   Kline & Santos (2012) se aplica direto ao Poisson.
6. **Permutação espacialmente coerente.** Sortear 11 de 23 estados mistura
   regiões, enquanto o tratamento é um bloco geográfico. Um placebo por blocos
   contíguos ou faixas de latitude é mais convincente; no mínimo, mostrar a
   distribuição.
7. **Intervalo para os 43%** da parcela dos pedestres no excesso (bootstrap).
8. **Carnaval e fim de ano.** O sábado–terça de carnaval cai inteiro dentro da
   janela em 2013, 2016, 2018 e 2024, e em parte em 2010, 2015 e 2021
   (cancelado), com intensidade diferente por estado. Mostrar que o efeito de
   fim de semana e feriado não vem daí.
9. **"Other road users" +55,8 (26,4)** com 27 mortes por verão: dizer o que tem
   dentro (V30–V39, V60–V89; quanto é V89, não especificado).
10. **Bahia.** A manhã falha nas três medidas. Como está, é evidência neutra a
    negativa. A decisão anterior foi mostrar as seis comparações; um
    parecerista provavelmente pede para virar nota de rodapé ou sair.
11. **Mortes por agressão.** A tripla entre 8h e 17h, horas sem mudança de
    luz, dá 7,0 (2,6), significativo. Isso mostra que o desenho produz efeitos
    pós-2019 onde não há luz. A seção levanta mais perguntas do que responde;
    considerar cortar.
12. **Coluna 3 do custo** (×2,05 para mortes fora da via): o sinal do viés é
    desconhecido (o pedestre atingido no escuro pode morrer mais na hora).
    Apresentar como ilustração. As lesões não fatais podem ser valoradas com o
    custo do Ipea por ferido.
13. **Validação da hora do SIM.** Parear as mortes na via em rodovia federal
    (SIM: data, município, idade, sexo) com as vítimas fatais da PRF (base por
    pessoa) para medir a defasagem entre a hora do acidente e a hora do óbito.
    Isso também explica a hora +1.
14. **Resumo.** "Per summer" precisa dizer que são 92 dias (ou ser escalado,
    M3); e "Mexico... shows the same pattern" (M4).

### Literatura a considerar (conferir antes de citar)

- Ferguson et al. (1995, *American Journal of Public Health*): simulação de
  horário de verão o ano todo e mortes de pedestres e ocupantes. É o ancestral
  da pergunta de regime, ao lado de Coate & Markowitz.
- Sexton & Beatty (2014, *JEBO*): resposta do uso do tempo ao horário de
  verão. É a evidência direta de evitação e ajuste de agenda que a Introdução
  invoca.
- Kline & Santos (2012, *Journal of Econometric Methods*): score bootstrap
  (menor 5).

Nenhuma das três foi conferida no original nesta leitura. Pela regra do
projeto, cada frase citada precisa ser checada contra o que o trabalho diz.

---

## 3. Triagem interna: o que fazer, em que ordem

| # | o quê | dado em mão? | custo | prioridade |
|---|---|---|---|---|
| M2.1 | β cedo × tarde; pós × tendência | sim (`02`, `09`) | horas | **1** |
| M2.4 | pandemia por calendário; decomposição verão/fora no texto | sim | horas | **1** |
| M4.1–3 | painel D nos controles mexicanos; México sem 2020–21; citar −0,8 | sim (`27`) | horas | **1** |
| M3.3 | dizer "92 dias" ou escalar à temporada | sim | horas | **1** |
| M1 | corrida sol × relógio; pseudo hora 0 nos controles | sim (hora do relógio nos microdados) | 1–2 dias | **1** |
| M3 | dose astronômica contínua; efeito líquido no dia | sim | 2–3 dias | 2 |
| M5 | risco por veículo robusto à tendência; temporadas alinhadas; estações pareadas | parcial (km das estações) | 1–3 dias | 2 |
| M7 | efeito de curto prazo na troca de fevereiro | sim | 1–2 dias | 2 |
| M6 | reescrever as comparações de magnitude | — | horas | 2 |
| menores 1, 3, 4, 7, 9, 14 | texto e rótulos | sim | horas | 3 |
| menores 2, 5, 6, 8, 13 | reestimações pontuais | sim | 1 dia | 3 |
| M2.2 | temporada 2024/25 | espera o SIM 2025 definitivo | — | quando sair |

**Minha leitura de risco.** M1 e M2 são os itens que podem mudar a
conclusão; o resto muda a apresentação. Se a corrida sol × relógio favorecer o
sol e o efeito no SIM se mantiver nas temporadas tardias, o paper fica muito
mais forte do que está. Se o efeito tardio cair para ~15 lp, a história muda
para "o choque inicial se dissipa com a adaptação". Isso também dá um paper de
política, desde que M7 meça a adaptação e o custo seja recalculado no estado
estacionário. Vale rodar M1 e M2 antes de mexer no texto.

**Periódico.** Nada aqui muda a ordem do `PARECER.md` (AEJ: Applied → AEJ:
Policy → JHE). M3 e M7 são exatamente o que a Policy cobra mais que a Applied:
um número líquido e a ligação com o argumento de bem-estar.

---

## 4. Resposta (15/10/2026, mesma sessão)

Tudo abaixo está no paper e no apêndice recompilados (paper 35 p., apêndice 23 p.,
build sem estouro de margem). Os números vêm dos `.rds` em `audit/`; scripts
entre parênteses. Nada foi commitado.

**M1. Luz ou relógio — resolvido, a favor da luz.**
- Modelo de dose de escuridão pelo sol (`23`, Tabela 4 do corpo, eq. 2): cada
  hora do relógio recebe a mudança de escuridão que a abolição trouxe (noite 1,
  crepúsculo civil 1/2, dia 0). Com efeito fixo de hora do relógio × data, uma
  hora da noite que vai de dia pleno a noite tem +47,7 lp (9,7) de mortes na via;
  só com efeito de data, 45,7 (6,3). Com um efeito livre para cada hora do relógio
  nos tratados após 2019 (identifica só pela diferença de pôr do sol entre
  tratados), 52,4 (18,3).
- Controle contado na hora do relógio da hora 0 dos tratados (`20`, Tabela 3,
  painel C): 32,9 (12,1).

**M2. Dinâmica — resolvido; o diagnóstico do parecer estava parcialmente errado.**
- A tripla dá 48,7 nas duas primeiras temporadas e 15,8 nas três últimas (`04`),
  mas a queda vem da perna do inverno, não do verão (figura nova B3,
  `fig_window_legs`). Só o verão: 39,3 e 31,2; tudo junto, 34,5 (13,4).
- Pandemia por calendário (sem mar/2020–fev/2022): 22,9 (9,1). O fora de
  temporada de 2019/20 inclui abr–jun/2020, o que inflava 2019/20.
- Texto: faixa honesta de 23 a 35 lp. Event study agora contra a média das
  temporadas com horário de verão (`02`, `09`); o HonestDiD segue contra 2018/19.
- SIM 2025 definitivo: ainda não saiu (pendente no ROADMAP).

**M3. Número de política — resolvido.**
- Contagem líquida pela dose, sem escolher horas (`23`, Tabela 6 painel A):
  63 (12) por janela de verão; 74 (14) por temporada inteira da regra de 2017
  (~108 dias). As somas de horas viraram checagem, incluindo a simétrica
  (−1 a +1 nas duas pontas: 53, EP 35).
- Custo (`25`, Tabela 7) pela temporada inteira: 74 / 91 / 186 mortes;
  VSL de referência R$ 344 mi (EP 67), até R$ 868 mi na escala ampla. A conta do
  ONS (R$ 244–356 mi de combustível) também é por temporada.
- A razão de Wald pelo registro do policial saiu; a dose vem do sol.
- Rótulos da hora −1 unificados ("sun lower, not set").

**M4. Controle e México — resolvido, com resultado misto que o texto agora diz.**
- Placebo do estimador dentro do dia nas seis unidades mexicanas que mantiveram
  o relógio (`27`, Tabela C1 painel E): mortes −20,3 (26,8), mas acidentes +10,8
  (3,6) e atropelados +20,7 (5,4). O México sustenta mortes, não acidentes.
- −0,8 da tripla para acidentes citado no texto; sem 2020–21, mortes 59,8 (16,6);
  cobertura do ATUS no apêndice (municípios informantes ~1.270 → ~1.390).
- Resumo: "Deaths in the same hour also rose after Mexico's 2022 abolition."
- O mecanismo do relógio de Brasília continua sem teste direto (dito no texto
  como hipótese; o placebo mexicano mostra fenômeno parecido).

**M5. PRF e mecanismo — resolvido.**
- Acidentes reestimados nos mesmos verões das estações (`15`, `16`): hora 0
  +17,6 (7,5), sem tendência pré nesses verões (−2,8, EP 2,9); por veículo +24,0
  (permutação p = 0,005).
- Estações realocadas (30 pares) viram coluna da tabela: noite −3,1 (3,1),
  manhã +18,7 (5,1).
- Contraste dos pedestres com tendência extrapolada (`12`): PRF pedestres 103,9
  (34,3) contra 15,3 (23,5) dos demais.

**M6. Magnitude — resolvido.** "In line with" e a comparação com Smith (2016)
saíram. O texto diz que o efeito é maior que as projeções dos EUA e dá a
composição (pedestres + motociclistas = 35% das mortes da hora 0).

**M7. Contribuição — resolvido.** Script novo `28_transitions.R` (Tabela B6, seção
IV.H): efeito de uma noite mais escura nas três semanas após cada troca de
relógio, 42,3 (13,8) contra 29,2 da abolição; dentro do dia, 79,1 (14,2) contra
27,7 (12,4). A adaptação cortou o efeito de um a dois terços, sem eliminá-lo. O
custo da evitação entra no texto do custo como não valorado.

**Menores.**
1. Rótulos da hora −1: feito. 2. Amontoamento redistribuído: 31,4 (9,5) (`19`).
3. Só Norte (15,7) no corpo: feito. 4. Event study na média pré: feito.
5. Score bootstrap no Poisson (Kline & Santos 2012): p = 0,010 / 0,023 / 0,001
(`06`, Tabela 2). 6. Permutação espacial: não feita, com motivo no ROADMAP
(não há bloco placebo que não se sobreponha ao tratado; a dose com efeito livre
por hora responde à preocupação). 7. EP da parcela dos pedestres: 43,4 (10,3).
8. Carnaval e fim de ano: 30,8 (7,8); fim de semana sem eles 39,3 (16,2).
9. "Outros": 85% sem veículo especificado (V87–V89), na nota da Tabela B3.
10. Bahia: fica (decisão de 12/10). 11. Agressões: ficam, com a frase de que a
tripla acha efeitos onde a luz não mudou. 12. Coluna 3 do custo: direção do erro
dita; lesões não valoradas, com motivo. 13. Hora do atestado contra hora do
acidente (`22`): 37.875 pares, mediana 0 min, 59% na hora seguinte contra 4,7%
por acaso. 14. Resumo: feito (96 palavras).

**Literatura:** Ferguson et al. (1995), Sexton & Beatty (2014) e Kline & Santos
(2012) conferidos (resumo/Crossref) e citados.

**O que não verifiquei:** não rodei o pipeline inteiro de ponta a ponta (rodei
cada script alterado: 02, 04, 06, 09, 11, 12, 15, 16, 19, 20, 21, 22, 23, 25,
27, 28, 29, 30); os scripts não alterados não dependem das mudanças. A auditoria
completa (`manuscript-audit`) continua pendente.
