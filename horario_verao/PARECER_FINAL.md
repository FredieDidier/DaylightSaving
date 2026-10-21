# Parecer final antes do working paper e da submissão

21/10/2026. Escrito por Claude a pedido do Fredie: só o essencial, nada que
já esteja em `PARECER.md` ou `PARECER_AEJ_POLICY.md`. Li o paper (36 p.) e o
apêndice (25 p.) compilados hoje, inteiros.

## Veredito

**Uma correção essencial. Nada além dela.**

O desenho, a inferência, o custo e a dinâmica estão respondidos. Conferi
contra os `.rds` os números que mudaram depois da auditoria de 16/10 (dose com
pesos pré-2019, pedestres na dose, 62/74/79, VSL, Ipea, conversão PPC, ONS
2 GW e R$ 1,8 bi → 0,7 bi) e a votação da Câmara dos EUA (308 a 117,
14/07/2026, roll call 238). Todos batem.

## A correção: o efeito não segue o calendário escolar

O paper divide a janela em semanas com aula (15/11–07/12) e férias
(24/12–15/01) e conclui que o efeito está nas aulas. Os outros 46 dos 92 dias
ficam num termo próprio que não aparece em lugar nenhum. Eles incluem o fim de
janeiro, que é férias em todas as redes estaduais tratadas, menos Goiás (as
outras voltam entre 1º e 26 de fevereiro; `fontes_dados/calendarios_escolares.md`).

Mesmo modelo do `20_leave_out.R`, com os dias "outros" abertos por data (mortes
na via, hora 0, lp, EP por UF):

| parte da janela | situação escolar nos tratados | efeito | sem GO | placebo pré-2019 |
|---|---|---|---|---|
| 15/11–07/12 | aula | 57,6 (12,6) | 60,5 (12,3) | −25,6 (23,1) |
| 08/12–23/12 | fim das aulas, misto | 12,7 (14,5) | 11,2 (15,5) | 42,2 (15,8) |
| 24/12–15/01 | férias, festas e pico de viagem | −12,7 (17,0) | −18,9 (17,4) | −9,6 (13,1) |
| **16/01–31/01** | **férias (exceto GO)** | **49,1 (15,6)** | **50,4 (16,7)** | −9,6 (24,6) |
| 01/02–14/02 | volta às aulas, misto | 31,0 (23,4) | 29,2 (23,6) | −19,4 (22,1) |

Fim de janeiro menos 24/12–15/01: 61,8 (18,6). Sem o Pará, 68,2 (19,2); sem o
litoral, 52,7 (18,9). (Script de conferência fora do repositório:
`/private/tmp/claude-501/-Users-fredie-Documents-GitHub-DaylightSaving/a02910f4-569b-4383-b161-fccaa38a7c09/scratchpad/split_other2.R`.)

As semanas de férias de fim de janeiro sobem tanto quanto as semanas com aula,
e a primeira quinzena de dezembro, ainda com aula na maior parte das redes,
quase não sobe. O que fica sem efeito é a quinzena de 24/12 a 15/01, o pico das
festas e das viagens de férias. A leitura "aula contra férias" não se sustenta.
Um parecerista que abrir os dias "outros" acha isso em uma regressão.

**O que continua de pé.** Os 62 e os 74 não mudam. A comparação com as trocas
de relógio também não: fora da quinzena de fim de ano o efeito da abolição fica
perto do das trocas (média dos quatro blocos acima, ponderada pelas mortes,
~39 lp contra 42,3). A conclusão de que não há sinal de adaptação depois de
cinco verões continua valendo. O que muda é a explicação para o efeito nulo
numa parte da janela.

**O que fazer.**
1. `20_leave_out.R` e a Tabela B1, Painel C: mostrar todas as partes da janela
   (as cinco acima) em vez de só aula, férias e a divisão das férias, com a
   linha sem Goiás para o fim de janeiro e o placebo.
2. Reescrever os trechos que atribuem a diferença à escola. Hoje o efeito nulo
   se localiza nas semanas de 24/12 a 15/01, não "nas férias escolares":
   - `body.tex:26` (introdução): "during the school break the change is not
     detectable";
   - `body.tex:313` (IV.I): "The gap over the whole window thus points to the
     school break rather than to an adjustment of travel" e "Neither the
     year-end festivities nor the beach trips account for the result during the
     break: the January weeks after the New Year show no rise". A segunda frase
     fica invertida: o nulo coincide com o período das festas e do pico de
     viagens, e o fim de janeiro, depois dele, sobe;
   - `body.tex:342` (conclusão): "it was concentrated in the school weeks of the
     summer";
   - `appendix_body.tex:112–114` e a nota da Tabela B1 (linha 103).
3. A Tabela B7 pode manter as linhas das semanas com aula: elas comparam a
   abolição com as trocas de relógio na mesma época do ano letivo, e isso
   continua válido. Muda só a frase que explica por que se compara ali
   (`body.tex:313`, `appendix_body.tex:276`).
4. Seção V (`body.tex:331`): o 79 pode ficar. Os dias extras, no começo de
   novembro e em meados de fevereiro, caem fora da quinzena de fim de ano. Basta
   que "fall while schools are in session, when the effect is larger" não
   apresente a escola como a causa.

**Feito em 21/10/2026, a pedido do Fredie:** itens 1 a 4 (`20_leave_out.R`, `28_tables.R`, `body.tex`, `appendix_body.tex`; ROADMAP). Paper, apêndice e working paper recompilados, sem aviso, com 36, 25 e 62 páginas.
