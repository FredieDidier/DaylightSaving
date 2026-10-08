# Primeira olhada nos dados — 08/10/2026

Script: `analysis/code/00_first_look.R` (SIM do build próprio, `build/05_download_sim.R`;
SINASC limpo do WorldCupHealth). Rodado de novo com o SIM próprio em 08/10/2026:
os números abaixo são os do `first_look_numbers.rds` vigente. Hora faltando no
SIM: 4,2–8,0% no controle e 2,8–6,8% nos tratados.
Figura: `analysis/output/graphs/fig00_first_look_hour_profile.png`.
Números: `Dropbox/DaylightSaving/build/audit/first_look_numbers.rds`.

## Desenho da olhada

- **Tratado:** RS SC PR SP RJ ES MG GO MT MS DF (horário de verão em todas as
  temporadas). **Controle:** N e NE sem BA e TO (uma temporada cada) e sem AC e
  AM (mudanças de fuso).
- **Janela:** 15/nov–14/fev, que esteve 100% sob horário de verão em todas as
  temporadas pré. **Fora de temporada:** abr–ago.
- **Pré:** 2009/10–2018/19. **Pós:** 2019/20–2023/24.
- **Estatística:** diferença tripla na participação de cada hora do relógio,
  ou seja (tratado, janela − fora) − (controle, janela − fora), calculada pré e
  pós. O que segue o sol deve se deslocar no pré e ficar parado no pós.

## O que saiu

1. **Hora preenchida.** O SIM tem 4–8% de hora faltando, caindo com o tempo e um
   pouco maior no controle. O SINASC tem menos de 0,5%. Dá para trabalhar com os dois.
2. **Nascimentos não seguem o sol.** O sinal é minúsculo (≤ 0,1 p.p. por hora)
   e não tem o formato de deslocamento, nem nos partos vaginais. No Brasil o
   parto é gerido pelo relógio do hospital (indução, escala). A validação que eu
   esperava dos partos **não funciona**. Por outro lado, o resultado já indica
   que o horário dos partos não é desfecho.
3. **Agressões: o sinal mais limpo.** No pré, a participação cai às 19–21h e
   sobe às 22–23h nos tratados durante o horário de verão. A violência noturna
   acompanha o escurecer, que chegava uma hora mais tarde no relógio. No pós, a
   curva fica plana. A correlação com um deslocamento puro de 1h é de 0,69 no
   pré e 0,41 no pós.
4. **Trânsito: luz no fim da tarde.** O vale às 18–20h existe nos dois
   períodos, porque o Sul e o Sudeste têm entardecer de verão mais tarde por
   causa da latitude, mas é **duas vezes mais fundo com horário de verão**:
   −2,2 p.p. às 19h no pré contra −1,1 no pós. É o canal de Smith e de Doleac &
   Sanders, e é a hora que o desenho precisa olhar.
5. **Infarto:** ruído, sem padrão.
6. **Nível total na janela, numa conta bruta de diferença tripla em log de
   óbitos por dia, pós − pré:** trânsito −0,7 log pts, agressão +2,2, infarto
   +0,8. **Praticamente zero**, sem erro-padrão ainda.

## Leitura

- O choque aparece nos dados: violência e trânsito mudam de hora quando o
  relógio muda. Isso funciona como **primeiro estágio**: o tratamento é real e
  mensurável.
- **Alerta para o paper:** se o total de mortes no verão não se move, a
  abolição só **realocou** mortes entre horas. A pergunta que pode render é
  mais estreita: **as horas que perderam luz (≈18–20h) ganharam mortes no
  trânsito, e quantas?** Em seguida, se isso é compensado pela manhã, que
  ganhou luz. Isso pede o painel UF × dia × hora com o pôr do sol de cada
  município, e não médias regionais.
- A latitude confunde o contraste regional (o Sul tem dia de verão mais longo).
  As fronteiras GO/MG × BA/TO e o pôr do sol calculado por município são o
  remédio.

## Próximo

- Baixar a PRF 2007–2025 (tem a variável fase do dia, que mede a luz direto no
  acidente).
- Painel UF × dia × hora com o horário do pôr e do nascer do sol (cálculo
  astronômico por município).
- Regressão com erro-padrão: diferença tripla por bloco de hora; inferência por
  UF (11 + 12 clusters, então wild bootstrap ou permutação de temporadas).
