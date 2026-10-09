---
name: horario-verao-econ
description: Especialista em economia do horário de verão, da luz natural e do relógio — horário de verão e acidentes de trânsito, luz ambiente e crime, pôr do sol e sono, hora legal contra hora solar, fusos horários, regime permanente contra troca sazonal — no padrão de periódicos de alto impacto (AEJ Applied, AEJ Policy, ReStat, JPubE, JHE, JHR, JEEM, JDE, Journal of Economic Geography). Use sempre que o trabalho envolver horário de verão (DST), daylight saving time, abolição ou adoção de horário de verão, Sunshine Protection Act, troca de relógio, luz no fim da tarde, escuridão e acidentes, pedestres e luz, roubo e escuro, social jetlag, sunset time, fronteira de fuso horário, cálculo de nascer e pôr do sol (NOAA), regressão descontínua na transição do relógio, diferença tripla com hora do dia, ou microdados com hora do evento (SIM com hora do óbito, PRF com fase do dia, FARS, boletins de ocorrência). Acione também para avaliar a viabilidade de uma ideia sobre luz, relógio e comportamento, criticar um paper da área, preparar referee report, escolher periódico ou antecipar objeções de parecerista — mesmo que o usuário não diga "horário de verão" explicitamente.
---

# Economia do horário de verão, da luz e do relógio

Conhecimento do campo, não de um projeto. Para o estado do projeto brasileiro
(abolição de 2019), acione **`paper-horario-verao`**.

Responda em **português**. O manuscrito é em inglês. Comentários de código em
inglês.

> **Toda citação e todo número abaixo é ponto de partida, não fonte.** Antes de
> entrar num manuscrito, confira autor, ano, periódico, desenho e magnitude no
> original. Itens marcados **(?)** ainda não foram conferidos nem pelo resumo.
> A lista com o estado de conferência de cada um está em
> `references/leituras.md` e no `LITERATURE.md` do projeto.

---

## 1. A ideia que organiza o campo

O horário de verão não muda a quantidade de luz; muda **em que hora do relógio**
ela cai. Como escola, trabalho e trânsito seguem o relógio, o horário de verão
desloca as atividades em relação ao sol. Daí saem **três canais distintos**, e
todo paper precisa dizer qual deles identifica:

1. **Luz ambiente.** Uma hora a mais de luz no fim da tarde, uma a menos de
   manhã. Efeito concentrado nas horas cuja luz mudou. Tende a **realocar**
   eventos entre horas, não a criar.
2. **Sono na transição.** A troca de primavera tira uma hora de sono por alguns
   dias. Efeito curto, perto da data da troca, e pode **criar** eventos.
3. **Desalinhamento crônico (social jetlag).** O pôr do sol tarde no relógio
   reduz o sono de forma permanente. Efeito lento, que aparece em saúde,
   produtividade e capital humano.

Uma transição (RD na semana da troca) mistura 1 e 2. Um **regime** (abolição,
adoção permanente, fronteira de fuso) isola 1 e 3. Confundir os dois é a
objeção número um de parecerista.

## 2. As frentes da literatura

**(a) Luz e trânsito.**
- **Smith (2016, AEJ: Applied)**: mudança das datas em 2007 nos EUA; a transição
  mata mais de 30 pessoas por ano, pelo **sono**; a luz só realoca mortes dentro
  do dia.
- **Fritz et al. (2020, Current Biology)**: FARS, +6% de acidentes fatais na
  semana após a primavera; crítica de Martín-Olalla (2020) **(?)**.
- Pedestres: IIHS (Woods, Weast & Monfort 2024) **(?)**; Sullivan & Flannagan
  (2002); Coate & Markowitz (2004); Sood & Ghosh (2007) **(?)**. É a frente em
  que a luz domina.
- Brasil: **Franco, Toro, Sampaio & Sampaio** (preprint 2023, SSRN 2021), PRF
  2007–2013, RD na entrada do horário de verão e DiD entre estados: acidentes
  caem ~10–14%.
- México: Goodwin, Gonzalez & Fontenla (2024, Applied Economics) **(?)**; Salas
  Rodríguez & Hancevic **(?)**.

**(b) Luz e crime.**
- **Doleac & Sanders (2015, ReStat)**: roubo −7%, −27% na hora após o pôr do
  sol, sem deslocamento para outras horas.
- **Domínguez & Asahi (2022, J. Economic Geography)**: Chile, −30% de roubo com
  uma hora a mais de luz às 19–21h, efeito simétrico.
- **Tealde (2022, J. Population Economics)**: Montevidéu, −17% de roubo, maior
  onde a iluminação pública é fraca.
- Brasil: Cortes, Fochezatto & Jacinto (Análise Econômica), homicídio no RS, sem
  efeito.

**(c) Relógio, sono e capital humano.**
- **Giuntella & Mazzonna (2019, JHE)**: fronteiras de fuso nos EUA.
- **Gibson & Shrader (2018, ReStat)**: sono e salário.
- **Jagnani (2022, ReStat)**: fuso único na Índia, sono infantil e escolaridade.
- Jin & Ziebarth: transições e internações **(?)**.

**(d) Saúde na transição.**
- **Toro, Tigre & Sampaio (2015, Economics Letters)**: infarto no Brasil, RD.
- Lins & Menezes (WP IEPS 2020): suicídio no RS **(?)**.
- Metanálises de infarto: Manfredini et al. (2019) **(?)**.

## 3. Desenhos e quando cada um serve

| desenho | identifica | cuidado |
|---|---|---|
| RD na data da troca | luz + sono, curto prazo | não fala do regime; dia da semana; feriados próximos |
| DiD entre regiões com e sem horário de verão | regime | as regiões diferem em latitude, logo em duração do dia |
| **hora que trocou de luz** (pôr/nascer do sol por lugar e dia) | luz, pura | hora do evento tem de ser a do incidente, não a do registro |
| fronteira de fuso | desalinhamento crônico | selecção residencial; mercados que cruzam a fronteira |
| abolição ou adoção permanente | regime, com pré e pós longos | poucos períodos pós; choques no mesmo período (COVID) |

**A hora que trocou de luz.** Para cada lugar e dia, calcule o pôr do sol em
hora **padrão** (equações da NOAA; ~10 linhas de código, conferir contra uma
tabela oficial). A hora do relógio [pôr padrão, +60 min) é clara com horário de
verão e escura sem ele; as vizinhas não mudam. É o placebo embutido mais forte
que o campo tem: o efeito tem de aparecer **numa hora** e não nas outras.

## 4. Armadilhas recorrentes

- **Hora do registro ≠ hora do incidente.** No SIM, óbito no hospital tem a hora
  da morte; só a morte na via pública (LOCOCOR = 4) tem a hora do acidente.
- **Hora legal ou hora padrão?** Confira se a base anota a hora com ou sem
  horário de verão. Teste: a curva de "escuro" anotada contra o pôr do sol
  calculado tem de se deslocar ~60 min entre os regimes.
- **Latitude.** No verão, o dia é mais longo no Sul. Uma comparação por hora fixa
  do relógio entre Sul e Norte confunde duração do dia com horário de verão.
- **Fuso.** Hora local, hora solar e UTC. No Brasil: AC e oeste do AM mudaram de
  fuso em 2008 e voltaram em 2013; o oeste do PA mudou em 2008.
- **Realocação contra criação.** A luz tende a mover eventos entre horas.
  Estime o dia inteiro e as horas vizinhas, e diga quanto do efeito na hora
  escura volta como queda em outra hora.
- **Quebras de registro.** Na PRF, a e-DAT (jun/2015, antes disso no S/SE/CE/DF)
  tirou os acidentes sem vítima da base. Nunca use contagem total.
- **Poucos clusters.** Estados são poucos. Use wild cluster bootstrap e
  inferência por permutação dos estados tratados, não só EP agrupado. Chame de
  "permutation inference", não "randomization inference": o horário de verão
  não foi sorteado entre estados, e o calendário é fixo, então não há datas a
  permutar (só placebos de temporada).
- **Tendência linear no período inteiro** absorve efeitos que crescem com o
  tempo. Prefira estimar a tendência só no pré e extrapolar (imputação, Borusyak,
  Jaravel & Spiess) ou "honest DiD" (Rambachan & Roth).

## 5. O que o parecerista vai perguntar

1. É luz ou é sono? (Mostre que o efeito está na hora que escureceu e não nos
   dias da troca.)
2. O total muda ou só a hora? (Smith 2016 diz que a luz realoca.)
3. Por que essa janela do ano e essas horas? (Fixe antes; mostre todas as horas.)
4. Tendência pré e COVID.
5. Exposição: o efeito é por mais tráfego no escuro ou por mais risco por viagem?
   (Fluxo do DNIT, se houver.)
6. Validade externa para o debate dos EUA e da UE (latitude, urbanização).

## 6. Onde publicar

AEJ: Applied e AEJ: Policy (pergunta de política com desenho limpo); ReStat
(onde estão Doleac & Sanders, Gibson & Shrader e Jagnani); JPubE; JHE (se o
desfecho principal for saúde); J. Economic Geography (luz e espaço); JDE (se o
gancho for país em desenvolvimento).
