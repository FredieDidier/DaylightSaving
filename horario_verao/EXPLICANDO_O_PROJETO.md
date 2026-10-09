# O projeto DaylightSaving, explicado do zero

Texto de estudo, 09/10/2026. Para quem nunca viu o projeto. Todos os números
foram conferidos nos `.rds` de `Dropbox/DaylightSaving/build/audit/` (a rodada
vigente, depois da auditoria de código). Quando este texto e um `.rds`
divergirem, vale o `.rds`.

Título de trabalho: ***Darker Evenings: Road Deaths after Brazil Abolished
Daylight Saving Time.***

---

## 0. O projeto em 30 segundos

Em abril de 2019 o Brasil acabou com o horário de verão. Desde então, de
novembro a fevereiro, o Sul, o Sudeste e o Centro-Oeste têm o pôr do sol uma
hora mais cedo no relógio. Uma hora do fim da tarde que antes era clara passou
a ser escura. Medimos o que aconteceu com as mortes no trânsito **exatamente
nessa hora**, calculada pelo pôr do sol de cada município em cada dia,
comparando os estados que tinham horário de verão com os que nunca tiveram,
o verão com o resto do ano, e antes com depois de 2019.

**O resultado:** na hora que escureceu, as mortes na via pública subiram cerca
de 34% (29 log points). O efeito aparece em duas bases independentes (atestados
de óbito do SIM e acidentes da Polícia Rodoviária Federal), se concentra nos
**pedestres** e não aparece em horas cuja luz não mudou. A manhã, que ganhou
luz, não compensa: o saldo é de mais ou menos **54 mortes a mais por verão**,
um limite inferior. O efeito sobre o total do dia é ruidoso demais para
concluir qualquer coisa.

---

## 1. A ideia e a motivação

### 1.1 O que aconteceu

- O Brasil teve horário de verão em todas as temporadas de 1985/86 a 2018/19.
  De 2008 em diante a regra era fixa (Dec. 6.558/2008): do 3º domingo de
  outubro ao 3º domingo de fevereiro, com adiamento de uma semana quando o fim
  caía no carnaval (2012 e 2015). A partir de 2018 o início passou para o
  1º domingo de novembro (Dec. 9.242/2017).
- Quem tinha: RS, SC, PR, SP, RJ, ES, MG, GO, MT, MS e DF, em todas as
  temporadas da nossa janela. A BA teve só em 2011/12, o TO só em 2012/13.
  O Norte e o Nordeste, nunca.
- **Decreto 9.772, de 25/04/2019:** acabou. A temporada 2019/20, que começaria
  em 03/11/2019, não aconteceu, e nenhuma depois dela.

### 1.2 O que o horário de verão faz, fisicamente

O horário de verão não cria luz. Ele adianta o relógio uma hora, e com isso
**move uma hora de luz da manhã para a tarde**. Com a abolição acontece o
inverso: a manhã ganha luz e o fim da tarde perde.

Exemplo concreto, São Paulo, 15 de janeiro (calculado com as equações da NOAA
que usamos no projeto):

| | pôr do sol no relógio | nascer do sol no relógio |
|---|---|---|
| com horário de verão (até 2018/19) | 19h58 | 6h32 |
| sem horário de verão (2019/20 em diante) | 18h58 | 5h32 |

Pense na hora do relógio **18h58–19h58**. Com horário de verão, o sol ainda
estava no céu: era a última hora de dia claro. Sem horário de verão, é a
primeira hora depois do pôr do sol: crepúsculo e depois escuro. As pessoas
continuam saindo do trabalho e voltando para casa nesse horário, porque a
vida segue o relógio, não o sol. Então, depois de 2019, mais gente passou a
circular no escuro.

De manhã acontece o espelho: a hora 5h32–6h32 era escura com horário de verão
e passou a ser clara.

### 1.3 Por que a pergunta importa

- **O debate de política é sobre o regime permanente, não sobre a troca.** Nos
  EUA, o Sunshine Protection Act quer horário de verão o ano todo; a União
  Europeia discute acabar com a troca de relógio; o México aboliu em 2022; o
  Uruguai, em 2015. No Brasil, o governo cogitou voltar com o horário de verão
  em 2024 (não voltou), e em setembro de 2025 a Comissão de Minas e Energia da
  Câmara aprovou um substitutivo ao **PL 397/2007** que **proíbe** o horário de
  verão (hoje aguarda relator na CCJC).
- **Mas quase toda a evidência causal vem das transições**, a semana em que o
  relógio muda. A transição mistura dois choques: a noite de sono perdida (ou
  ganha) e a mudança de luz. Ela diz muito sobre o custo de *trocar* o relógio e
  pouco sobre o custo de *viver* num regime ou no outro.
- **O Brasil é um caso raro:** um país grande que estava num regime e saiu dele
  de vez, com microdados públicos de mortes e acidentes **com a hora do
  evento**. É um choque permanente de luz sem nenhuma noite de sono perdida.

### 1.4 A pergunta, em uma frase

Quando um país abandona o horário de verão, quantas pessoas a mais morrem no
trânsito na hora do relógio que passou a ser escura, e a manhã que ganhou luz
compensa essas mortes?

---

## 2. A literatura e onde entramos

### 2.1 O que já se sabe

**Horário de verão e trânsito, quase tudo pelas transições:**

- **Smith (2016, AEJ: Applied)**, EUA 2002–2011: a entrada no horário de verão
  causa mais de 30 mortes por ano no trânsito. O canal é o **sono**. A luz, diz
  ele, só realoca mortes dentro do dia.
- **Gillmore (2025, Health Economics)**, Chile: separa os dois canais. Sono
  (+6% de acidentes na semana após a entrada) e luz (que reduz acidentes graves
  e fatais). Usa as datas que mudam de ano a ano.
- **Laliotis, Moscelli & Monastiriotis (2023, Health Economics)**, Grécia: RD
  nas transições, canal de luz nas faixas de hora afetadas.
- **Depalo (2023, Economic Modelling)**, Itália, acidentes de trabalho: o
  próprio título pergunta se o horário de verão deve ser abolido, mas a resposta
  vem das transições. Essa é exatamente a lacuna que ocupamos.
- **Woods, Weast & Monfort (2025, Journal of Safety Research, IIHS)**, EUA:
  nas semanas em torno da troca, a luz pesa sobretudo sobre **pedestres e
  ciclistas**. É o paralelo direto do nosso mecanismo.
- Clássicos sobre luz e pedestre: **Sullivan & Flannagan (2002)** (pedestre
  com até ~7 vezes mais risco no escuro), **Coate & Markowitz (2004)**, **Sood
  & Ghosh (2007)**, **Uttley & Fotios (2017)**.

**Horário de verão no Brasil:**

- **Franco, Toro, Sampaio & Sampaio** (SSRN WP e preprint SciELO, sem versão
  publicada): o **vizinho mais próximo**. Mesma base (PRF), 2007–2012/13, RD na
  entrada do horário de verão e DiD entre estados. Acidentes caem 10–14% nos
  estados que adotavam.
- **Toro (tese UFPE, 2016)** e **Toro, Tigre & Sampaio (WP "Daylight Saving
  Lives")**: homicídios caem no horário de verão, concentrados no começo da
  noite. A hora já é medida **em relação ao pôr do sol de cada município**.
- **Toro, Tigre & Sampaio (2015, Economics Letters)**: infarto +7,4% a +8,5% no
  primeiro dia após a entrada (canal de sono).
- Cortes, Fochezatto & Jacinto (2021, RS, homicídios, sem efeito); Lins &
  Menezes (2020, suicídio no RS).
- **Sobre a abolição de 2019, só há estudos de energia** (Raad et al. 2025 em
  Estudos Econômicos; Souza 2023, dissertação UFJF; Soares et al. 2024).
  Nenhum sobre trânsito, mortalidade ou violência.

**Luz e crime (a ideia de medir a hora pelo sol vem daqui):**

- **Doleac & Sanders (2015, ReStat)**: roubo −27% na hora depois do pôr do sol
  quando ela fica clara.
- **Mitre-Becerril (2026, Criminology)**, Domínguez & Asahi (2022, JEG),
  Tealde (2022, JPopE).
- **Carreno Najera (2026, tese, Royal Holloway)**: usa a abolição mexicana de
  2022, mas para crime. É o único uso de uma abolição que achamos.

**Sono e relógio (para a discussão do canal):** Giuntella & Mazzonna (2019,
JHE), Gibson & Shrader (2018, ReStat), Jagnani (2022, ReStat), Jin & Ziebarth
(2020, JEBO).

### 2.2 A contribuição, dita com cuidado

**O que NÃO é novo:** medir a hora em relação ao pôr do sol local. Doleac &
Sanders, Toro e Mitre-Becerril já fazem isso. Se alguém perguntar "isso já não
foi feito?", a resposta honesta é: o instrumento de medida não é novo; o
experimento é.

**O que é novo:**

1. **A primeira estimativa do custo de abandonar o horário de verão.** Franco
   et al., Toro e Cortes estudam o horário de verão *enquanto ele existia*.
   Ninguém estudou o fim. E o fim é um choque **permanente e só de luz**: não
   há noite de sono perdida.
2. **A luz medida na hora exata, numa comparação que não depende da troca.**
   A hora do relógio [pôr do sol padrão, +60 min), calculada por município e
   por dia, na **mesma janela do calendário** em 11 temporadas com horário de
   verão e 5 sem. A hora da manhã que ganhou luz serve de espelho.
3. **Duas fontes independentes e um primeiro estágio medido por terceiros.**
   Atestado de óbito (SIM) e polícia rodoviária (PRF), mais a "fase do dia" que
   o policial anota, que mostra que a hora escureceu de fato.

**A frase-resumo da contribuição:** a primeira estimativa do custo em vidas de
abandonar o horário de verão, identificada na hora exata em que o relógio
tirou a luz, em duas fontes independentes, num país que está decidindo agora se
volta atrás.

### 2.3 Comparação explícita com o vizinho mais próximo

| | Franco et al. | este projeto |
|---|---|---|
| variação | entrada no horário de verão (RD) + DiD entre estados | **abolição permanente** (2019) |
| dados | PRF 2007–2012/13, acidentes | SIM (mortes em **todas** as vias) + PRF, 2008/09–2023/24 |
| hora | hora do relógio | **hora que trocou de luz**, pelo pôr do sol de cada município e dia |
| pergunta | vale adotar? | **quanto custa abandonar?** |

---

## 3. Os dados

Todos públicos. Nenhum precisou de Lei de Acesso à Informação.

### 3.1 SIM — Sistema de Informações sobre Mortalidade (DATASUS)

- Atestados de óbito individuais, baixados direto do FTP do DATASUS
  (`build/05_download_sim.R`), 2008–2024. **2025 é preliminar e fica fora.**
- O que usamos: **mortes por acidente de transporte terrestre (CID-10 V01–V89)
  ocorridas na via pública (LOCOCOR = 4)**, com a **hora do óbito**.
- **Por que só na via pública?** Quem morre no hospital tem a hora da morte, que
  pode ser horas ou dias depois do acidente. Só quem morre no local tem hora do
  óbito ≈ hora do acidente. É o ponto mais importante do SIM: sem esse filtro, a
  análise por hora não faz sentido.
- Pedestre = V01–V09; o resto (ocupantes, motociclistas, ciclistas) = V10–V89.
- **Hora faltante:** 15–20% das mortes na via não têm hora. A diferença tripla
  nessa parcela é de menos de 1 p.p., então a falta não é diferencial. Mas as
  contagens de excesso só incluem mortes com hora, o que as torna um limite
  inferior.
- Tamanho: nos estados tratados, no verão, antes de 2019, ~2.380 mortes na via
  por temporada (com hora); ~110 delas na hora que depois escureceu.

### 3.2 PRF — acidentes nas rodovias federais

- Planilhas anuais de dados abertos, 2007–2025, 2,19 milhões de acidentes
  (`build/02–03`). Hora, município, km, coordenadas (desde 2017) e a **fase do
  dia** anotada pelo policial (pleno dia, amanhecer, anoitecer, plena noite).
- Usamos só **mortes** e **acidentes com vítima**. **Nunca a contagem total.**
  Motivo: a **e-DAT** (declaração de acidente pela internet, nacional desde
  junho de 2015, mas antes já em vigor no S, SE, CE e DF) tirou da base os
  acidentes sem vítima, e isso aconteceu mais cedo justamente no grupo tratado.
  Os acidentes sem vítima caíram de 120 mil em 2011 para 11 mil em 2019; os com
  vítima e os fatais ficaram estáveis.
- **"Mortos" na PRF = óbito no local do acidente** (definição dos Anuários da
  PRF). É o mesmo conceito do nosso SIM na via. A diferença entre as bases é a
  rede: o SIM cobre todas as vias; a PRF, só as rodovias federais.
- **A hora da PRF é hora legal** (a do relógio). Conferimos (`04_prf_clock_check.R`,
  seção 5.1 abaixo).
- Município casado com o IBGE pelo nome mais uma tabela de grafias
  (`build/manual/prf_municipio_alias.csv`): 100% casados depois da auditoria de
  09/10/2026 (antes, 99,7%).

### 3.3 PNCT/DNIT — volume de tráfego por hora

- Contagens contínuas de veículos por posto e hora nas rodovias federais,
  baixadas da API do portal do PNCT (`build/06–07`). 608 postos.
- Serve para separar **exposição** (quantos carros na estrada) de **risco**
  (acidentes por carro).
- **Duas limitações sérias:**
  - **Lacuna de jun/2019 a abr/2021.** O contrato de contagem acabou em junho
    de 2019; o 2º semestre de 2019 publicado é **estimado por modelo** e 2020 não
    foi contado (fonte primária: Nota Técnica DNIT nº 001/2020/DE, p. 7; contratos
    novos assinados em 30/12/2020 e 13/01/2021). Descartamos esse intervalo e
    marcamos como modelados os dias cujo total se repete exatamente no mesmo dia
    da semana. O verão 2019/20 não existe no PNCT.
  - **Nenhum posto é contado antes e depois** (nas 23 UFs do estudo, 247 só
    antes e 315 só depois): o contrato novo de 2020 trocou todos os
    equipamentos, com códigos e posições novos. Por isso não há efeito fixo de
    posto que atravesse a abolição; a comparação antes × depois é entre
    estados (tratado × controle), como no resto do paper. Como robustez, 30
    pares: um posto só-depois a até 2 km de um só-antes na mesma BR,
    provavelmente o mesmo ponto realocado, com efeitos fixos do par.

### 3.4 Sol e geografia

- Sede de cada município (geobr, malha de 2010; os 5 municípios criados em 2013
  entram por ponto na malha de 2020) e fuso padrão (`build/04_municipal_geo.R`).
- Nascer e pôr do sol em **hora padrão**, por município e dia, pelas equações da
  NOAA (`sun_times()` em `analysis/code/00_utils.R`).
- Cuidado com fusos: AC e o oeste do AM mudaram de fuso em 2008 e voltaram em
  2013; o oeste do PA mudou em 2008 e ficou. Hora local, hora solar e UTC são
  coisas diferentes. Por isso AC e AM saem do controle.

### 3.5 O calendário legal

- Digitado à mão dos decretos (`build/manual/hv_temporadas.csv`), 34 temporadas
  de 1985/86 a 2018/19, 33 atos lidos no Planalto.
- **O decreto vence o tzdata da IANA**, que erra pelo menos uma vez (põe o MT no
  horário de verão de 1994/95; o Dec. 1.252/1994 o exclui).
- `build/01_dst_calendar.R` gera os painéis UF × temporada e UF × dia e a
  `TABELA_ESTADOS.md`.

---

## 4. A estratégia empírica, em detalhe

### 4.1 Grupos

- **Tratados (11):** RS, SC, PR, SP, RJ, ES, MG, GO, MT, MS, DF. Tinham horário
  de verão em todas as temporadas de 2008/09 a 2018/19.
- **Controle (12):** RO, RR, PA, AP, MA, PI, CE, RN, PB, PE, AL, SE. Nunca
  tiveram.
- **Fora:** BA e TO (cada um teve horário de verão numa única temporada, então
  não são controle limpo) e AC e AM (mudaram de fuso no meio do período).
- Total: **23 unidades da federação = 23 clusters.**

### 4.2 Temporadas, janela e período

- **Temporada** vai de julho a junho e leva o nome do ano de início (2018/19 =
  jul/2018 a jun/2019).
- **Período:** 2008/09 a 2023/24 = **11 temporadas com horário de verão e 5
  sem.** Começa em 2008/09 porque é a primeira sob a regra fixa do Dec.
  6.558/2008; termina em 2023/24 porque o SIM de 2025 ainda é preliminar.
- **Janela de verão: 15/nov a 14/fev.** Esse é um ponto que precisa ser
  explicado com clareza: **a janela não é a data do horário de verão.** É a
  interseção de todas as temporadas pré, ou seja, o conjunto de dias que estava
  sob horário de verão em **100% dos anos** antes de 2019. As datas legais
  variavam (o início mais tardio foi 04/11/2018; o fim mais cedo, 15/02/2009).
  Usando a mesma janela fixa em todos os anos, antes e depois, nenhum dia entra
  "meio tratado" e a variação das datas não contamina a estimativa.
- **Bônus da janela:** ela começa pelo menos 11 dias depois da entrada mais
  tardia e acaba antes da saída mais cedo. Ou seja, **as semanas da transição,
  onde mora o efeito do sono, ficam de fora.**
- **Fora da janela ("entressafra"):** abril a agosto, meses em que nunca houve
  horário de verão. Os meses intermediários (set–out e nov até dia 14, fev–mar)
  ficam fora da análise.

### 4.3 A hora que trocou de luz (o coração do desenho)

Para cada município e cada dia, calculamos o pôr do sol em hora padrão. A
**hora 0 da noite** é o intervalo do relógio **[pôr do sol padrão, pôr do sol
padrão + 60 min)**.

- Nos **tratados, antes de 2019, na janela**: o relógio estava adiantado, então
  essa hora do relógio era a última hora **antes** do pôr do sol de verdade.
  **Clara.**
- Nos **tratados, depois de 2019**: é a primeira hora **depois** do pôr do sol.
  **Escura** (crepúsculo e depois noite).
- Nos **controles**: nunca mudou. É sempre a primeira hora depois do pôr do sol.
- **Na entressafra**: nunca mudou em lugar nenhum.

Cada evento (morte ou acidente) é classificado pela hora do relógio em relação
ao pôr do sol do seu município naquele dia, e somamos por UF e dia. Também
definimos as horas vizinhas (−3, −2, −1, +1, +2) e a **hora 0 da manhã**
([nascer do sol padrão, +60 min)), que é o espelho: era escura com horário de
verão e ficou clara.

**Por que não usar blocos fixos de hora (tipo 17h–20h)?** Porque o pôr do sol
varia muito ao longo do país e do verão (de ~17h30 a ~19h30 no relógio padrão).
Um bloco fixo mistura a hora que mudou de luz com horas que não mudaram, e o
efeito se dilui. Na primeira olhada isso apareceu claramente: no bloco 17–20h,
o SIM dava +6,5% (p = 0,17). Com a hora afiada, +34% (p = 0,001). Janelas mais
largas também diluem: [0, 60) dá 29 lp; [0, 120) dá 21; [−60, 120) dá 16, e a
tendência pré piora. **O sinal está na hora exata.**

Isso tem uma vantagem forte de identificação: a teoria (luz) diz **exatamente
em que hora** o efeito tem de aparecer, e em que horas não pode aparecer. Um
choque qualquer (economia, fiscalização, COVID) não teria motivo para escolher
justamente a hora que trocou de luz em cada município e dia.

### 4.4 A diferença tripla

Três diferenças:

1. **Tratado × controle** (S/SE/CO contra N/NE);
2. **Janela × entressafra** (nov–fev contra abr–ago);
3. **Pós × pré** (de 2019/20 em diante contra até 2018/19).

**A conta na mão, com os dados brutos** (Tabela 1, mortes na via do SIM, hora 0
da noite, média por temporada):

| | janela, pré | janela, pós | entressafra, pré | entressafra, pós |
|---|--:|--:|--:|--:|
| tratados | 109,9 | 140,8 | 361,7 | 313,4 |
| controle | 101,2 | 91,8 | 176,8 | 144,6 |

- Tratados: na janela, +25 log points (109,9 → 140,8); na entressafra, −14
  (361,7 → 313,4). Diferença: **+39 lp.**
- Controle: na janela, −10; na entressafra, −20. Diferença: **+10 lp.**
- Tripla: 39 − 10 = **+29 lp.** A regressão dá 29,2. A tabela bruta já conta a
  história.

Repare o que cada diferença limpa: as mortes caíram em geral depois de 2019
(entressafra dos tratados e controle caem); a comparação com a entressafra
limpa o que mudou no estado o ano todo; a comparação com o controle limpa o que
mudou no verão em todo lugar.

**O modelo:** Poisson (pseudo-máxima verossimilhança), painel UF × dia:

  E[y_{s,d}] = exp( β · Tratado_s × Janela_d × Pós_d + α_{s × janela} + γ_{s × temporada} + δ_d )

em que y é o número de mortes (ou acidentes) na hora 0 do estado s no dia d.
Em código: `fepois(y ~ twp | uf^window + uf^sy + date, cluster = ~uf)`.

Os efeitos fixos:

- **UF × janela.** Aqui "janela" é uma variável de **dois valores**, e só
  dois: **verão** (15/nov a 14/fev) e **entressafra** (1º/abr a 31/ago). Os
  dias fora das duas (set a 14/nov, 15/fev a mar) nem entram no painel. Então
  são dois efeitos fixos por estado (46 no total), **os mesmos nas 16
  temporadas**: o nível típico de SP no verão, o nível típico de SP na
  entressafra, e assim por diante.

  O que ele absorve é a **diferença permanente entre verão e entressafra de
  cada estado**, tudo o que faz o verão de um estado ser sistematicamente
  diferente do inverno dele, ano após ano:
  - turismo e férias: o litoral de SC e as estradas para o litoral enchem no
    verão; as férias escolares caem na janela;
  - clima: no Sul o verão tem dia longo e seco; no litoral do Nordeste a
    chuva cai em abr–jul, ou seja, na entressafra;
  - a própria hora 0: o pôr do sol de verão cai mais tarde no relógio que o de
    inverno, então a hora 0 do verão é uma hora de outro tráfego (19h contra
    17h30, por exemplo). Esse nível diferente fica no α, desde que seja o
    mesmo todo ano.

  O que ele **não** absorve: uma diferença verão − entressafra que **muda com
  o tempo** e muda diferente nos tratados e no controle. Essa é justamente a
  hipótese de identificação (tendências paralelas da diferença verão −
  entressafra), testada no estudo de eventos e na imputação.
- **UF × temporada:** cada estado-ano tem seu próprio nível, comum à janela e à
  entressafra. Absorve tudo o que muda no estado ao longo do tempo: frota,
  fiscalização, Lei Seca, crise, a COVID num estado específico.
- **Data:** cada dia do calendário tem seu nível, comum a todos os estados.
  Absorve Natal, Réveillon, carnaval, feriados nacionais, choques nacionais.

O que sobra para identificar β é: dentro do estado, quanto o verão se afastou
da entressafra depois de 2019 em relação a antes, nos tratados contra os
controles.

**Por que Poisson?** As contagens são pequenas e cheias de zeros (88% dos
UF-dias têm zero morte na hora 0). O Poisson PML só precisa que a média esteja
certa, não que os dados sejam Poisson, e lida bem com zeros. Conferimos que não
há excesso de zeros: a parcela de zeros observada bate com a implicada pelo
modelo em menos de 1 p.p., e a dispersão fica entre 0,9 e 1,6. Por isso não
usamos binomial negativa nem zero-inflated.

**Como ler o coeficiente:** β vem em **log points (lp)**: 100 × β. Para virar
porcentagem: 100 × (e^β − 1). 29,2 lp ≈ +34%; 53,9 lp ≈ +71%; 22,2 lp ≈ +25%.

**Excesso em número de mortes:** observado menos contrafactual (o que o modelo
prevê com β = 0), nos tratados, na janela, depois de 2019, dividido pelas 5
temporadas. EP pelo método delta.

### 4.5 Inferência com 23 clusters

O erro-padrão é agrupado por UF, mas 23 clusters (11 tratados) é pouco para a
assintótica confiar. Por isso há dois testes que não dependem dela:

1. **Wild cluster bootstrap restrito (WCR)**, pesos de Webb, B = 9.999, no
   análogo linear do modelo. É o padrão para poucos clusters (Cameron, Gelbach &
   Miller; MacKinnon & Webb). **Atenção:** ele testa o modelo linear (MQO em
   níveis), não o Poisson. Por isso a Tabela 2 imprime a estimativa linear (em %
   da base) ao lado do p do WCR. Na noite os dois modelos concordam; na manhã
   da PRF (mortes) não: Poisson −11 lp (p = 0,58; permutação 0,56), linear
   −23% (WCR p = 0,031). O MQO com EP por UF comum já dá 0,032, então não é
   problema do bootstrap; o modelo linear pesa as variações absolutas, onde
   os estados grandes (MG) dominam. Nenhum estado sozinho explica a
   diferença (tirando um por vez: linear −20 a −28%, Poisson −5 a −18 lp).
2. **Inferência por permutação:** sorteamos 999 vezes quais 11 dos 23 estados
   são "tratados", reestimamos, e vemos em que posição o efeito verdadeiro cai.
   O p-valor é a fração de sorteios com efeito tão grande quanto o real.

**Nome:** "permutation inference", **nunca** "randomization inference". O
horário de verão não foi sorteado entre estados, e o calendário é fixo; o teste
pergunta só se outros 11 estados quaisquer dariam um efeito tão grande.

### 4.6 As ameaças e como cada uma é tratada

| ameaça | teste |
|---|---|
| tendências diferentes entre S/SE/CO e N/NE | estudo de eventos por temporada; teste de Wald dos coeficientes pré; tendência linear; **estimador de imputação** (Borusyak, Jaravel & Spiess) com a tendência pré extrapolada; **HonestDiD** (Rambachan & Roth) |
| choques regionais no verão (chuva, férias, calor) | a hora afiada (um choque regional não escolhe a hora do pôr do sol de cada município); **diferença quádrupla** com efeito fixo de UF × dia, que absorve qualquer choque diário do estado |
| COVID (2020/21 e 2021/22) | reestimar sem essas temporadas |
| sono, e não luz | a janela exclui as transições e a abolição não tem noite perdida; **placebo nas horas cuja luz não mudou** (meio do dia e noite fechada) |
| a hora registrada não ser a hora legal | checagem com a fase do dia da PRF; o PNCT também anota hora legal |
| artefato de uma fonte só | duas bases independentes (SIM e PRF) |
| tráfego que muda de hora, não risco | volume do PNCT; risco por veículo |
| poucos clusters | WCR e permutação |

---

## 5. Os resultados, na ordem em que a história se conta

### 5.1 Primeiro estágio: a hora realmente escureceu

A PRF anota a fase do dia de cada acidente. Às 18–19h do relógio, na janela de
verão, a parcela anotada como anoitecer ou plena noite:

| | antes de 2019 | depois de 2019 |
|---|--:|--:|
| tratados | 47,2% | 82,8% |
| controle | 96,3% | 98,0% |

Diferença tripla: **+33,7 p.p. (EP 1,5).** O tratamento é real, enorme e
medido por alguém (o policial) que não sabe da pesquisa.

**A PRF anota hora legal** (`04_prf_clock_check.R`): nos tratados, a curva da
parcela "escuro" por minuto em relação ao pôr do sol padrão cruza 50% em
**−50 min sem horário de verão e em 0 min com horário de verão**. Um
deslocamento de ~50–60 min, que é o que se espera se a hora anotada for a do
relógio. O mesmo vale para o PNCT (o perfil horário casa sem defasagem).

### 5.2 O efeito principal: a hora que escureceu ganhou mortes

| | SIM, mortes na via | PRF, mortes | PRF, acidentes com vítima |
|---|--:|--:|--:|
| hora 0 da noite, lp (EP por UF) | **29,2 (9,0)** | **53,9 (20,3)** | **22,2 (5,6)** |
| em % | +34% | +71% | +25% |
| p (EP por UF) | 0,001 | 0,008 | <0,001 |
| permutação p | 0,018 (18 de 999) | 0,019 | 0,001 |
| modelo linear, % da base | +46% | +88% | +30% |
| modelo linear, WCR p | 0,010 | 0,002 | 0,001 |
| base: tratados, janela, pré, por temporada | 110 | 47 | 571 |

A hora que escureceu passa nos três testes, nas três medidas.

### 5.3 O perfil por hora: o pico está onde a teoria manda

Coeficiente da tripla em cada hora relativa ao pôr (e ao nascer) do sol, lp:

| hora | SIM mortes | PRF mortes | PRF com vítima |
|---|--:|--:|--:|
| noite −3 | +2,5 | −10,8 | −9,2 |
| noite −2 | −10,2 | −1,2 | −13,4 |
| noite −1 | +6,9 | **−40,6** | **−22,3** |
| **noite 0 (escureceu)** | **+29,2** | **+53,9** | **+22,2** |
| noite +1 (crepúsculo virou noite) | +16,4 | +18,7 | +6,9 |
| noite +2 | −8,4 | −11,7 | −5,2 |
| manhã 0 (clareou) | −3,3 | −11,3 | −14,2 (p = 0,09) |

- No SIM, o pico é limpo: hora 0 sobe, a +1 sobe menos (faz sentido: ela passou
  de crepúsculo para noite fechada), e o resto não se mexe.
- Na PRF, a hora −1 (a última antes do pôr do sol) **cai** quase tanto quanto a
  hora 0 sobe. Esse é o principal quebra-cabeça aberto (seção 5.9).
- A manhã que clareou tem sinais negativos, mas pequenos e não significantes.

**Placebo nas horas cuja luz não mudou** (`19_placebo_hours.R`):

| | hora 0 da noite | meio do dia | noite fechada |
|---|--:|--:|--:|
| SIM, mortes na via | **29,2 (9,0)** | −4,5 (5,8) | −6,6 (5,6) |
| PRF, mortes | **53,9 (20,3)** | −17,3 (11,2) | −19,8 (11,8) |
| PRF, com vítima | **22,2 (5,6)** | −1,9 (3,9) | −6,1 (2,9) |

Nada sobe onde a luz não mudou. Os sinais são até negativos (na PRF, em linha
com o tráfego que saiu da noite, seção 5.7).

### 5.4 Robustez: tendência, COVID, ruído

**Tendências pré (estudo de eventos, `05_pretrends.R`), hora 0:**

| | Wald pré = 0 (p) | tendência pré por temporada (lp) | base | com tendência linear | sem COVID |
|---|--:|--:|--:|--:|--:|
| SIM, mortes na via | 0,18 | −0,5 (2,1) | 29,2 | 39,9 (20,7) | 31,1 (8,8) |
| PRF, mortes | 0,37 | +3,4 (2,6) | 53,9 | 19,8 (21,7) | 47,1 (25,2) |
| PRF, com vítima | <0,001 | +1,7 (0,7) | 22,2 | 5,6 (8,0) | 22,9 (7,1) |

**Imputação** (`06_imputation.R`): ajusta o modelo só nas observações não
tratadas, prevê o contrafactual dos tratados depois de 2019 (bootstrap de
estados, B = 299):

| | sem tendência | IC 95% | tendência pré extrapolada | IC 95% |
|---|--:|---|--:|---|
| SIM, mortes na via | +31% | [7, 54] | **+38%** | [−11, 103] |
| PRF, mortes | +59% | [1, 149] | +22% | [−24, 97] |
| PRF, com vítima | +23% | [13, 38] | +8% | [−5, 26] |

**Leitura (decorar isto):**

- **O SIM é o resultado âncora.** Tendência pré plana, Wald não rejeita, e com a
  tendência extrapolada o ponto não cai (até sobe). Extrapolar a tendência custa
  precisão, não efeito.
- **A PRF corrobora, mas é sensível à tendência.** Nos acidentes com vítima o
  Wald rejeita e a tendência corta o efeito à metade ou mais. A e-DAT e
  mudanças no policiamento rodoviário a partir de 2015 são candidatos.
- **COVID não muda nada:** sem 2020/21 e 2021/22, os efeitos ficam iguais.
- **O efeito aparece nas cinco temporadas pós** (imputação com tendência, SIM:
  84, 55, 18, 10 e 41%), maior na primeira.

**HonestDiD** (`08_honestdid.R`): sob extrapolação linear da tendência, os três
efeitos são positivos. Mas o "breakdown" é baixo (M ≈ 0,02 no SIM): basta uma
curvatura pequena na tendência para o intervalo incluir zero. A causa é o ruído:
com uma hora por dia e ~110 mortes por temporada, cada coeficiente anual oscila
±15–30 lp. **É uma fraqueza real e deve ser dita assim**, não escondida.

**Diferença quádrupla** (`10_within_day.R`): painel UF × dia × hora relativa ao
sol, com efeito fixo de **UF × dia**, que absorve qualquer choque diário do
estado (chuva, feriado, volume). Hora 0: SIM 27,7; PRF mortes 90; com vítima
31,1. O efeito não depende de qual conjunto de horas serve de referência. O EP
não cai (o ruído é de contagem, não de choque diário), então fica como
robustez, não como desenho principal.

### 5.5 Quem morre: o pedestre

(`13_mechanism.R`, `15_inference_pedestrian.R`), hora 0 da noite, lp:

| | pedestre | resto | diferença |
|---|--:|--:|--:|
| SIM, mortes na via | **76,6** (≈ +115%) | 17,9 | 58,7 |
| WCR p / permutação p | 0,008 / 0,035 | 0,017 / 0,058 | — / 0,079 |
| PRF, mortes | **170** | 25,7 | 144 |
| permutação p | 0,001 | 0,26 | 0,002 |
| PRF, com vítima | **98,6** | 18,1 | 80,6 |
| permutação p | <0,001 | 0,009 | 0,001 |

- No SIM, o pedestre é **12% das mortes na hora 0 antes de 2019, mas 43% do
  excesso.** Na série bruta, o número de pedestres mortos na via na hora 0, nos
  tratados, no verão, **dobra** (12,8 → 26,8 por temporada), enquanto cai no
  controle e na entressafra.
- **Não é tendência:** pedestre no SIM, Wald pré p = 0,37, tendência pré
  +0,8 (4,7), com a tendência extrapolada **69 lp (30)**.
- Ocupantes e motociclistas também sobem (SIM +18 lp, p = 0,02), menos.
- É o que a física e a literatura mandam: o pedestre é quem mais depende de ser
  visto (Sullivan & Flannagan; Woods et al./IIHS). Isso também é o argumento
  mais forte contra o canal do sono: um motorista com sono bate em qualquer
  coisa, não preferencialmente em pedestres.

### 5.6 A conta: a manhã não paga a noite

(`12_reallocation.R`): modelo empilhado com as horas −2 a +1 da noite e −1 a
+1 da manhã, covariância conjunta para poder somar. Excesso por verão, nos
tratados, na janela, depois de 2019:

| soma | SIM, mortes na via | PRF, mortes | PRF, com vítima |
|---|--:|--:|--:|
| noite escura (horas 0 e +1) | **+57 (19)**, +25% | **+34 (10)**, +43% | **+146 (39)**, +16% |
| manhã que clareou (hora 0) | −3 (11) | −4 (8) | −53 (33), p = 0,11 |
| **líquido: noite 0, +1 e manhã 0** | **+54 (20), p = 0,007** | +29 (14), p = 0,03 | +93 (43), p = 0,03 |
| dia todo (modelo à parte) | −5 (66) | −58 (44) | −95 (215) |

**Como dizer:**

- Nas horas cuja luz mudou de fato, o saldo é positivo nas três fontes:
  **~54 mortes a mais na via por verão** no SIM.
- **O total do dia é inconclusivo, não zero.** O EP do dia todo (66 mortes por
  verão) é maior que o próprio efeito da noite. O dia todo não distingue entre
  zero e o excesso da noite. A frase certa: "o efeito está concentrado nas horas
  que escureceram; o total do dia é estimado com ruído demais para confirmar ou
  descartar o saldo".
- **É um limite inferior por três motivos:** exclui quem morre no hospital,
  exclui quem morre na via sem hora registrada (15–20%), e não conta feridos.

### 5.7 O tráfego seguiu a luz (PNCT)

(`16_traffic_volume.R`, `17_inference_volume.R`), tripla no volume de veículos
por hora relativa ao sol, lp:

| hora | volume | por veículo (acidentes com vítima − volume) | permutação p (por veículo) |
|---|--:|--:|--:|
| noite −1 | −5,1 | −17,2 | 0,001 |
| **noite 0** | **−6,4** | **+28,6** | **0,001** |
| noite +1 | −6,4 | +13,3 | 0,044 |
| **manhã 0** | **+11,7** | **−26,0** | **0,002** |
| dia todo | +0,5 (2,0) | | |

- **As pessoas responderam à luz:** sem horário de verão, a noite escura perdeu
  ~5–6% dos veículos (quase todos leves: carros e motos), e a manhã que clareou
  ganhou ~12% (puxada pelos pesados, +17%). O total do dia não muda.
- **O risco por veículo na hora escura sobe ainda mais** (+29 lp) que o número
  de acidentes (+22): menos gente na estrada no escuro, e quem ficou corre mais
  risco. A manhã fica mais segura por veículo.
- Ressalvas: o PNCT só cobre rodovias federais (não fala do tráfego urbano, onde
  morre boa parte dos pedestres do SIM); nenhum posto é contado antes e depois;
  e, com os mesmos verões nas duas fontes, o risco por veículo dá ~+25 em vez de
  +29 (auditoria; a conclusão fica).

### 5.8 Por que o SIM e a PRF diferem (e por que não é contradição)

| | SIM, mortes na via | PRF, mortes |
|---|---|---|
| onde | todas as vias (urbanas, estaduais, federais) | só rodovias federais |
| quem | óbito na via pública | óbito no local do acidente |
| base (tratados, verão, pré, dia todo) | ~2.380 por temporada | ~1.180 por temporada |

- Na hora 0, os efeitos **não divergem de fato**: 29 contra 54 lp, diferença com
  EP de ~23. Nas duas, o efeito se concentra no pedestre.
- Divergem em três pontos: (i) as horas antes do pôr do sol caem na PRF e não no
  SIM; (ii) a PRF tem tendência pré, o SIM não; (iii) no SIM a noite ganha e o
  resto quase não se mexe, na PRF a noite ganha o que o fim da tarde perde.
- **Leitura:** o SIM mede o efeito sobre a população, e ali a luz cria mortes. A
  PRF mede um tipo específico de via, onde parte do efeito é o tráfego mudando de
  hora. **A PRF corrobora o mecanismo (escuro, pedestre), não o tamanho do
  excesso.**

### 5.9 O quebra-cabeça aberto: a hora antes do pôr do sol na PRF

Na PRF, a hora −1 cai (acidentes com vítima −22 lp, mortes −41). Não é erro de
registro de hora (seção 5.1) nem choque diário (persiste na quádrupla). O volume
explica só uma parte (−5 lp de veículos; por veículo, ainda −17). Candidato
principal: **ofuscamento pelo sol baixo**. Com horário de verão, o sol baixo no
horizonte (que cega o motorista) caía nessa hora do relógio, de maior tráfego;
sem horário de verão, saiu dela. Está em aberto e deve ser apresentado como
aberto.

### 5.10 Apêndice: a Bahia em 2011/12

A BA teve horário de verão só em 2011/12 (Dec. 7.584/2011). Naquele verão, a
hora que depois escureceu nos tratados era **clara** na BA. Ou seja, o efeito
deveria aparecer com o sinal invertido.

- Primeiro estágio claro: a PRF anotou escuro em 68% dos acidentes na hora 0 da
  BA em 2011/12, contra 92–100% em todas as outras temporadas.
- Acidentes com vítima na hora 0: **o menor valor das 16 temporadas** (−21 lp).
  Mortes na via do SIM: 4º menor de 16.
- A manhã não aparece (igual ao resultado principal).
- Com uma temporada e um estado, a posição 1 de 16 equivale a p ≈ 0,06. É
  checagem de sinal, nada além disso.

### 5.11 O que ficou de fora, e por quê

- **Agressões (homicídios):** sem assinatura de luz. O efeito vem todo da
  temporada 2019/20 e aparece também às 8–17h, horas cuja luz não mudou; dentro
  da janela, a dupla é nula. É tendência da violência, não luz. Saiu do paper.
- **Hora dos nascimentos:** partos seguem o relógio do hospital (cesáreas
  agendadas, plantões), não o sol. Saiu.
- **Fronteira estadual (GO/MG × BA/TO):** sem poder estatístico. Na hora 0, no
  verão, há ~1 morte por temporada do lado tratado a até 100 km da divisa.
- **Liga-desliga do TO (2012/13):** 3 a 8 mortes por verão na hora 0. Sem poder.
- **Contagem total da PRF:** contaminada pela e-DAT.

---

## 6. O canal do sono (vai ser perguntado)

A literatura de transição acha efeitos de sono (Smith 2016). Por que aqui é luz?

1. **Sono agudo:** a janela começa 11+ dias depois da entrada mais tardia e
   termina antes da saída mais cedo. As semanas de transição estão fora. E a
   abolição em si não tem noite de sono perdida.
2. **Sono crônico ("social jetlag", Giuntella & Mazzonna 2019):** um pôr do sol
   mais tarde no relógio poderia encurtar o sono no verão inteiro. Três fatos
   descartam isso como fonte das estimativas:
   - o efeito está numa única hora; as horas longe do crepúsculo, onde um
     efeito de sono também apareceria, não se mexem (placebo, seção 5.3);
   - o efeito sobrevive ao efeito fixo de UF × dia (quádrupla), que absorve
     qualquer mudança comum a todas as horas do dia;
   - o efeito se concentra no pedestre, quem mais depende de ser visto.
3. E o sinal estaria ao contrário: sem horário de verão, o pôr do sol é mais
   cedo no relógio, o que deveria **alongar** o sono, não encurtar.

---

## 7. Limitações (dizer antes que perguntem)

- **Só 5 temporadas pós e 23 clusters.** Daí o WCR e a permutação.
- **O tratamento é um bloco regional.** A hora afiada, a quádrupla e o placebo
  existem para isso, mas não se pode escapar totalmente.
- **HonestDiD frágil:** uma curvatura pequena na tendência leva o intervalo a
  incluir zero. É ruído de contagem numa hora por dia.
- **A PRF tem tendência pré** nos acidentes com vítima.
- **O total do dia é inconclusivo.**
- **Limite inferior:** sem mortes no hospital, sem mortes sem hora, sem feridos.
- **O volume de tráfego só existe para rodovias federais,** sem posto contado
  antes e depois, e sem o verão 2019/20.
- **A manhã é fraca:** o efeito espelho aparece com sinal certo, mas pequeno e
  não significante no SIM.
- **A hora −1 da PRF é um quebra-cabeça aberto.**

---

## 8. Perguntas que vão te fazer, e as respostas

**"Isso não é só o Sul/Sudeste ficando diferente do Norte/Nordeste?"**
Se fosse, apareceria no dia inteiro ou em várias horas. O efeito está
exatamente na hora que trocou de luz, calculada por município e dia; o meio do
dia e a noite fechada não se mexem; e ele sobrevive a um efeito fixo de estado
× dia. Um choque regional não sabe a que horas o sol se põe em cada cidade.

**"E a COVID?"**
Sem 2020/21 e 2021/22, o efeito no SIM fica em 31 lp (contra 29). Além disso, o
efeito fixo de UF × temporada absorve a COVID de cada estado, e o de data
absorve a COVID nacional.

**"A hora do óbito é a hora do acidente?"**
Só para quem morre no local. Por isso usamos só óbitos na via pública. Quem
morre no hospital sai.

**"Quantas vidas?"**
Cerca de **54 mortes a mais por verão** nas horas que escureceram, líquidas da
manhã (EP 20). É limite inferior: sem as mortes no hospital e sem as mortes sem
hora registrada.

**"Então a abolição aumentou as mortes no trânsito?"**
Aumentou as mortes **nas horas que escureceram**. Sobre o dia inteiro, o dado é
ruidoso demais para dizer (EP de 66 mortes por verão). Nunca dizer que "o total
do dia não muda": ele é inconclusivo.

**"Por que Poisson e não MQO ou binomial negativa?"**
Contagens pequenas e com muitos zeros. O Poisson PML só exige a média certa.
Testamos: não há excesso de zeros e a dispersão é próxima de 1.

**"23 clusters não é pouco?"**
É. Por isso o wild cluster bootstrap restrito (no modelo linear) e a
permutação dos estados tratados (no próprio Poisson). A hora que escureceu
passa nos dois, nas três medidas.

**"Por que a janela é 15/nov–14/fev?"**
É o conjunto de dias que esteve sob horário de verão em todas as temporadas
pré. Mesma janela antes e depois, nenhum dia meio tratado, e as semanas da
transição ficam fora.

**"Por que excluir BA, TO, AC e AM?"**
BA e TO tiveram horário de verão numa temporada cada, então não são controle
limpo (a BA vira checagem de sinal no apêndice). AC e AM mudaram de fuso no
período.

**"O que é novo em relação ao Toro e ao Franco et al.?"**
Eles estudam o horário de verão enquanto existia, sobretudo pela entrada (que
mistura sono e luz). Nós estudamos o fim: um choque permanente, só de luz, em 11
temporadas com e 5 sem. E o trânsito com óbito na via, em todas as vias, não só
nas rodovias federais. Medir a hora pelo pôr do sol local não é a novidade.

**"A PRF confirma?"**
Corrobora, com ressalva: sem tendência, o efeito é grande e passa em tudo; com a
tendência pré extrapolada, cai à metade. A PRF confirma o mecanismo (escuro,
pedestre), não o tamanho.

**"Não pode ser o sono?"**
Ver seção 6: a janela exclui as transições, as horas sem mudança de luz não se
mexem, o efeito sobrevive ao FE de UF × dia, e é o pedestre que morre.

**"As pessoas não se adaptaram?"**
Em parte, sim: o tráfego da noite escura caiu ~6% e o da manhã subiu ~12%. Mesmo
assim, o risco por veículo no escuro subiu. E o efeito aparece nas cinco
temporadas pós, maior na primeira.

**"Por que não a fronteira entre estados?"**
Sem poder: ~1 morte por temporada na hora 0 a até 100 km da divisa.

**"Qual o periódico?"**
AEJ: Applied ou AEJ: Policy (Smith 2016 está na Applied); JHE ou JPubE como
alternativa.

---

## 9. Glossário rápido

- **lp (log points):** 100 × coeficiente do Poisson. 29 lp ≈ +34%.
- **Hora 0 da noite:** [pôr do sol padrão, +60 min) no relógio, por município e
  dia. A hora que era clara com horário de verão e ficou escura sem ele.
- **Hora 0 da manhã:** [nascer do sol padrão, +60 min). Era escura, ficou clara.
- **Janela:** 15/nov–14/fev. **Entressafra:** abr–ago.
- **Temporada:** jul–jun; 2018/19 é a última com horário de verão.
- **Diferença tripla:** tratado × janela × pós.
- **Diferença quádrupla:** a tripla × hora, com efeito fixo de UF × dia.
- **WCR:** wild cluster bootstrap restrito (Webb).
- **Permutação:** sorteio de quais 11 estados são tratados.
- **Imputação:** estimador de Borusyak, Jaravel & Spiess; ajusta o modelo nos não
  tratados e prevê o contrafactual.
- **HonestDiD:** Rambachan & Roth; quanto a tendência pode se desviar da
  extrapolação linear antes de o efeito perder significância.
- **LOCOCOR = 4:** local de ocorrência do óbito na via pública (SIM).
- **e-DAT:** declaração eletrônica de acidente sem vítima da PRF.
- **PNCT:** Plano Nacional de Contagem de Tráfego (DNIT).

---

## 10. Onde está cada coisa

| o quê | onde |
|---|---|
| calendário legal | `build/manual/hv_temporadas.csv`, `build/01_dst_calendar.R`, `horario_verao/TABELA_ESTADOS.md` |
| funções comuns (grupos, janela, sol, painel) | `analysis/code/00_utils.R` |
| desenho principal (perfil por hora) | `02_sunset_design.R` → `audit/sunset_design.rds` |
| estudo de eventos | `03`, `05` |
| checagem do relógio da PRF | `04` |
| imputação / inferência / HonestDiD | `06` / `07` / `08` |
| quádrupla | `10` |
| agressões (nulo) | `11` |
| realocação / pedestre | `12` / `13`, `15` |
| números da Tabela 1 | `14` → `audit/table1.rds` |
| todas as figuras / todas as tabelas | `20_figures.R` → `graphs/fig_*` / `21_tables.R` → `tables/tab_*.tex` (leem só os `.rds`) |
| legendas e notas em rascunho | `latex/exhibits.tex` |
| volume do PNCT | `16`, `17` |
| Bahia / placebo de horas | `18` / `19` |
| números | `Dropbox/DaylightSaving/build/audit/*.rds` |
| histórico das rodadas | `horario_verao/VIABILIDADE.md` (§17 é a vigente) |
| plano do paper | `horario_verao/PAPER.md` |
