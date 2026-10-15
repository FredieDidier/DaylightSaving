# PARECER — leitura como editor e parecerista

12/10/2026. Escrito por Claude a pedido do Fredie, depois da auditoria de código
dos scripts 18–21 (ROADMAP, mesma data). Tudo o que está aqui é sugestão; nada
foi estimado ainda, salvo onde indicado. Números de literatura vêm do
`LITERATURE.md` e valem com as ressalvas de lá.

## Situação (12/10/2026, fim do dia)

Todos os itens essenciais e os do "texto precisa antecipar" foram feitos no
mesmo dia (scripts 22–28, VIABILIDADE §19, EXPLICANDO §5.12, PAPER.md
"Objeções antecipadas"). Resumo do que mudou na leitura:
- o custo virou número: 54–137 mortes por verão, R$ 253–637 milhões pelo VSL
  de referência (R$ 43–108 milhões pelo custo do Ipea), reais de 2025;
- a iluminação pública (Censo 2022) aponta na direção prevista, sem precisão;
  não é o "achado de maior retorno" que o parecer esperava;
- quem morre: pedestre e, menos, motociclista; carro, nada; fim de semana mais
  que dia útil;
- Bahia: mostrar as seis comparações (decidido);
- México feito (`29`, `30`): a réplica se sustenta pela comparação dentro do
  dia nas unidades tratadas (mortes +55 lp, p = 0,001; pedestres +154); a
  tripla com os 6 controles é frágil. Uruguai descartado (sem região de
  controle, ~430 mortes por ano). Com a réplica, vale reconsiderar AEJ: Applied
  na frente (seção "Ranking").

## Segunda leitura (15/10/2026)

Pedido do Fredie: conferir se o parecer de 12/10 bastou ou se falta algo para
fortalecer o paper. Conferido item por item contra `latex/sections/` e o
apêndice.

**O que o parecer pedia está feito.** Os sete essenciais (custo, dose e chuva,
amontoamento, tirar um de fora e trocar o controle, quem morre, iluminação,
integridade do registro) e todos os itens do "texto precisa antecipar" estão no
paper. Faltavam dois, que dependiam de fonte:
- **Radares (feito em 15/10/2026).** Despachos do Presidente de 14/08/2019, DOU
  de 15/08/2019, Edição 157, Seção 1, p. 5 (texto em
  `fontes_legais/DOU_2019-08-15_despachos_radares.txt`): suspende os medidores
  de velocidade estáticos, móveis e portáteis da PRF. A retomada em 23/12/2019,
  depois da liminar de 11/12 mantida pelo TRF-1 em 18/12, vem da nota da PRF
  reproduzida pelo Poder360 (23/12/2019), não de ato oficial. Uma frase em
  "Trends and robustness": sem 2019/20, a PRF dá 65,0 (mortes) e 25,7 (com vítima), maiores.
- **SIM 2025.** O FTP do DATASUS (15/10/2026) tem os definitivos até 2024; 2025
  segue em `PRELIM`. A 6ª temporada pós espera o DATASUS.

**Três pontos novos, aceitos pelo Fredie e feitos no mesmo dia:**
1. **O resumo e a conclusão diziam mais do que a evidência.** "Abolition cost 54
   lives per summer, a lower bound" é limite inferior só em relação às mortes
   sem hora e no hospital; as sete horas somam 41 (41) e o dia todo −5 (66).
   Agora: "the hours whose light changed lost 54 lives per summer" (resumo, 100
   palavras) e o mesmo escopo na conclusão e na nota da Tab. 5.
2. **O controle no relógio de Brasília.** Com horário de verão, tudo o que é
   marcado pela hora de Brasília corria uma hora mais cedo no relógio do N/NE no
   verão; com a abolição, deixou de correr. Teste: a hora 0 contra horas do
   mesmo estado e dia cuja luz não mudou, em cada grupo sozinho (`09`, `15`;
   Tabela `tab_within_group` no apêndice). O tráfego da noite do controle não
   se moveu (veículos na hora 0: −0,2 lp, EP 0,7; tratados −5,4). As mortes na
   via na hora 0 do controle subiram em relação ao resto do dia (+19,7, EP 6,5),
   sem tendência pré e com qualquer conjunto de horas de referência; a PRF do
   controle caiu na mesma hora. Leitura: o que subiu não passou pelo tráfego e,
   se veio do relógio do controle, a tripla **subestima** o efeito; só nos
   tratados, a mesma comparação dá 47,2 (7,8). De manhã os dois grupos caem
   juntos (tratados −19,4; controle −23,5); só nos tratados, a manhã devolve
   menos de um terço da noite. Uma frase no corpo, o resto no apêndice.
3. **México com as horas de referência do Brasil.** O painel D comparava a hora
   0 com as horas −1 e −2, que o próprio paper diz que mudaram de luz. Agora usa
   as horas −5 a −3 e +2 a +4, como o `09`, com −2, −1 e +1 em coeficiente
   próprio. Mortes no local 54,6 → 58,4 (17,6); pedestres 154,1 (65,6) → 142,8
   (37,8); atropelamentos com vítima 22,9 → 44,9 (7,6). A hora 0 é o pico nas
   quatro. Com o item 2, é o mesmo estimador nos dois países: 47 no Brasil, 58
   no México.

**Energia (decisão delegada pelo Fredie).** A frase não sai; estava errada e foi
reescrita. A NT 5/2019 do MME diz que o horário de verão *aumentou* a carga em
0,7%, logo a abolição economizou um pouco de energia (o texto dizia que as
mortes "não compraram economia nenhuma"). E, pela NT-ONS 0093/2024, a volta
economizaria combustível **e**, pelas nossas estimativas, vidas: não há troca
entre energia e vidas hoje, os dois lados apontam na mesma direção (o texto
dizia "trades energy against lives"). Acrescentada uma frase: nenhum dos dois
lados conta as duas trocas de relógio por ano que a abolição tirou, cujo custo
a literatura atribui ao sono (Smith 2016; Gillmore 2025), e que a janela exclui.

**Ainda aberto:** rodar a skill `manuscript-audit` completa antes de mandar o
paper a alguém (ROADMAP, "Próximos").

## Veredito de editor, em uma frase

Desenho limpo, primeiro estágio enorme e medido por terceiros, efeito na hora
certa e em nenhuma outra, duas fontes, inferência cuidadosa. No estado atual,
um editor de periódico geral diria: "bom paper de campo, efeito pequeno, total
do dia inconclusivo, e a hora relativa ao pôr do sol local já foi usada
(Doleac & Sanders 2015; Toro 2016)". O que falta é passar de "mais mortes numa
hora" para **"quanto custa abolir o horário de verão, para quem, e por quê"**.

## Essenciais — o parecerista vai pedir

1. **O custo total, com conta de bem-estar.**
   - Hoje: +54 mortes na via por verão, só óbitos com hora registrada; o dia
     todo tem EP 66.
   - Escalonar com hipótese explícita: mortes no hospital e os 15–20% sem
     hora, pela razão mortes totais / mortes na via por UF e ano. Reportar como
     faixa.
   - Monetizar (VSL, ou custo por morte do IPEA) e pôr ao lado da economia de
     energia do horário de verão (Raad et al. 2025). É o que transforma o paper
     em paper de política.

2. **Dose de escuridão (Wald).**
   - Forma reduzida ÷ primeiro estágio: 29,2 lp ÷ 34 p.p. dá o efeito do
     "escuro" por acidente, comparável a Sullivan & Flannagan (2002) e Woods et
     al. (2025).
   - Heterogeneidade por nebulosidade: em dia nublado a hora já era escura, o
     efeito deveria ser menor.

3. **Robustez ao amontoamento das horas (heaping).** Achado da auditoria:
   - 34,5% das horas do SIM na via caem em hora cheia, 23% em :30 e 90% em
     múltiplos de 5 minutos (PRF: 21%, 19% e 95%).
   - Uma fórmula solar diferente, que muda o pôr do sol em menos de 1 minuto,
     move a hora 0 do SIM de 29,2 para 29,8 lp e a BA na PRF de −21,4 para −23,0.
   - Pedir: limites das faixas deslocados em ±5, ±10 e ±15 min; excluir :00 e
     :30. Barato.

4. **Deixar um de fora e trocar o controle.**
   - Com 11 tratados e 12 controles, a tabela de tirar um estado por vez e uma
     temporada por vez é obrigatória.
   - Controle só NE, só N; sem as temporadas de La Niña (2020/21–2022/23).

5. **Quem morre, além do pedestre.**
   - Por tipo de usuário: motociclista (V20–V29, a maior categoria no Brasil),
     ciclista (V10–V19), ocupante de automóvel.
   - Por idade e sexo do pedestre.
   - Dia útil contra fim de semana e feriado: a volta do trabalho cai em cima
     da hora 0, e esse é o teste de exposição.

6. **Iluminação pública.**
   - O Censo 2010 tem a iluminação pública no entorno de cada setor
     censitário. O efeito deveria ser maior onde a rua é escura (Tealde 2022).
   - Dá uma alavanca de política: iluminar a rua substitui o horário de verão.
   - Na minha leitura, a análise nova de maior retorno.

7. **Integridade dos registros por grupo × período × janela.**
   - Parcela de óbitos na via (LOCOCOR = 4) e parcela sem hora; a segunda já
     está em `audit/pretrends.rds`.
   - Motivo: a expansão do SAMU no N/NE muda onde as pessoas morrem.
   - Vira uma figura de apêndice.

## O texto precisa antecipar

- **A PRF é frágil.** Com tendência, os acidentes com vítima caem para
  5,6 lp (8,0). No placebo da noite fechada, a PRF cai: −6,1 lp, p = 0,04.
  Escrever "nada **sobe** nas horas de luz inalterada", nunca "nada se move".
- **Choque coincidente na PRF.** A suspensão dos radares móveis nas rodovias
  federais em ago/2019 cai em cima da abolição. É nacional (o FE de data
  absorve), mas o parecerista vai perguntar.
- **HonestDiD.** O intervalo original do SIM inclui zero porque o alvo é a
  média pós contra 2018/19 (14,8 lp), não o β da Tabela 2 (29,2 lp). A nota da
  figura já diz isso (auditoria de 12/10/2026), e o texto precisa ter a frase do
  VIABILIDADE §18.
- **Bahia.** Das 6 comparações, só uma é a mais extrema de 16 no sentido
  previsto (acidentes com vítima, noite). De manhã, SIM e PRF mortes ficam em
  3º de 16 de baixo para cima, o sentido contrário ao previsto. Mostrar as seis
  sempre, ou cortar. Mostrar só a melhor parece escolha a dedo.
- **Mudanças de hora de atividade pós-COVID e entregas por moto.** O pico de
  entregas no jantar coincide com a hora 0. A tripla (janela × fora) absorve o
  que não é sazonal, mas a divisão por motociclista (item 5) responde de vez.

## Para subir de patamar (opcional, custo alto)

- **México, abolição de out/2022.** Os municípios da fronteira mantiveram o
  horário de verão: controle embutido. O INEGI publica os acidentes urbanos
  (base ATUS) com hora, município e vítima pedestre, mas eu **não conferi** as
  variáveis. Uma segunda abolição replicando o resultado muda o paper de
  "Brasil" para "regime".
- **Uruguai (2015)**, se houver dado com hora.
- **SIM 2025 consolidado:** uma 6ª temporada pós.

## Ranking de periódicos (ordem de submissão)

1. **AEJ: Economic Policy.** Avaliação de uma reversão real de política, no
   meio de um debate vivo (Sunshine Protection Act, UE, PL 397/2007). Os itens
   1 e 6 acima são o que esse editor quer ver. Prefiro a Policy à Applied: na
   Applied pesam mais o "instrumento já usado" e o efeito total inconclusivo.
2. **Journal of Public Economics.** Prestígio semelhante; aceita avaliação de
   regulação com custo e benefício. As objeções tendem a repetir as da AEJ, por
   isso só depois de incorporar o parecer de lá.
3. **Journal of Health Economics.** Encaixe alto (mortalidade como desfecho;
   Giuntella & Mazzonna 2019 saíram lá). Maior chance de aceite: os pareceristas
   valorizam o óbito e o mecanismo do pedestre.

Rede de segurança: *Health Economics* (Gillmore 2025; Laliotis et al. 2023).
AEJ: Applied ou ReStat só com a replicação mexicana.

**Atualização (12/10/2026), com o México feito.** A réplica existe e tem a
mesma assinatura (hora que escureceu, pedestre), mas se apoia na comparação
dentro do dia, porque o grupo de controle mexicano é fino. Isso torna a AEJ:
Applied uma primeira tentativa defensável ("duas abolições, mesma
assinatura"). Minha ordem passa a ser: AEJ: Applied → AEJ: Economic Policy →
JHE, com o JPubE como alternativa ao JHE. ReStat continua um passo longo
demais.
