# Leonardo Monasterio: comentários e sugestões (16/10/2026)

O que ele mandou, item por item, e o que cada item vale para o paper.

**De onde vem:**
- dois PDFs comentados do `EXPLICANDO_O_PROJETO` na versão de 12/10/2026
  (`EXPLICANDO_O_PROJETO_comentadoLMM.pdf` e `..._lmm_2.pdf`). Os comentários
  são os mesmos nos dois; ele explica no áudio 1 que salvou duas versões num
  computador público do aeroporto. O texto extraído dos dois é idêntico. Os
  comentários estão "achatados" na página e não sobra nenhuma anotação legível
  por programa: o quadradinho amarelo da p. 1 é um ícone de nota sem texto
  recuperável (perguntar a ele se havia algo escrito);
- cinco áudios de WhatsApp de 16/10/2026, 3 min 47 s no total, transcritos com
  o Whisper (large-v3-turbo, conferido com o medium). A transcrição completa
  está no fim do arquivo.

O documento comentado é o de 12/10. Alguns números mudaram depois (ver item 13).

**Legenda de status:** ✔ feito · ◐ em parte · ✗ não feito · — não pede ação

**Decidido em 16/10/2026 (Fredie):** o custo (itens 2 e 3) fica para depois,
porque o Fredie vai conversar com o Leonardo; o resto que vale a pena foi
feito, e os opcionais foram decididos como um editor da AEJ: Policy decidiria.
O paper continua com 36 páginas (limite 45); o apêndice foi de 23 para 24.

---

## Resumo

| # | Sugestão | Status em 16/10 | Decisão |
|---|---|---|---|
| 1 | Entra como coautor | ✔ | feito, com o e-mail dele |
| 2 | Melhorar o cálculo do custo além do VSL (fica com ele) | ✗ | para depois (conversa com ele) |
| 3 | Usar a idade dos mortos no custo (anos de vida) | ✗ | para depois, junto com o 2 |
| 4 | Perfil dos mortos: sexo e idade, nas duas fontes | ✔ | Tabela B4 do apêndice e uma frase no corpo |
| 5 | Iluminação pública: satélite ou Censo | ✔ Censo | satélite não entra, nem no apêndice |
| 6 | Ofuscamento: rugosidade do relevo (*ruggedness*) | ✗ | não entra (o paper já não defende o ofuscamento) |
| 7 | Robustez sem os municípios litorâneos | ✔ | linha na Tabela B1 e meia frase no corpo |
| 8 | Separar a saída de fevereiro da abolição, no texto | ✔ | feito no corpo e no apêndice |
| 9 | "Instrumento de medida" confunde com fonte de variação | ✔ no paper | nada a fazer |
| 10 | Infarto (Toro, Tigre & Sampaio 2015) é deslocamento | ✔ | ele tem razão; o artigo volta à Seção V em meia linha |
| 11 | Ajustes de redação no EXPLICANDO | — | só no EXPLICANDO |
| 12 | Trechos grifados, sem comentário | — | — |
| 13 | Elogios e reações | — | — |

---

## 1. Coautoria

Ele aceitou ser coautor.

**Feito em 16/10/2026:**
- `latex/title_page.tex`: autores "Fredie Didier and Leonardo Monasterio", uma
  nota só com as afiliações, no formato do modelo da AEA. O agradecimento saiu;
- `latex/paper_wp.tex`: os dois autores, cada um com sua nota. O agradecimento
  do título saiu;
- texto em "we": as 23 ocorrências de "I" (resumo, corpo e apêndice) viraram
  "we"/"We". Não sobrou "I", "my" nem "me";
- `README.md`: "Authors", e "the authors" nas duas declarações de direitos;
- `paper.tex` e `appendix.tex` continuam anônimos.

- e-mail dele (leonardo.monasterio@idp.edu.br), passado pelo Fredie, na página
  de título e no working paper.

**Falta:**
- afiliação: escrevi "Instituto de Pesquisa Econômica Aplicada (Ipea) and IDP,
  Brazil", como aparece nas páginas do IDP e do Lemann Center. Ele confirma;
- **Disclosure Statement** dele, em PDF separado (a AEA exige um por autor; ver
  `PAPER.md`, pendência 1);
- a declaração de uso de IA no formulário de submissão vale para os dois.

## 2. Custo: algo melhor do que o VSL (áudio 4)

**Para depois (16/10):** o Fredie vai conversar com ele antes.

> "eu topo a tua proposta de melhorar o cálculo do custo, vou ver como é que
> tem as novidades nesse cálculo do custo, se tem coisa melhor do que o valor
> estatístico da vida"

- **Hoje:** Seção V e apêndice de custo. VSL pela regra de referência de
  Robinson, Hammitt & O'Keeffe (2019), com a renda per capita de 2025 em PPC;
  custo social do Ipea (capital humano) como piso. 74 mortes por temporada,
  R$ 344 mi (`25_total_cost.R`, `total_cost.rds`).
- **Quem faz:** ele, pela proposta que você fez. Combinar o que ele traz: se
  for um VSL brasileiro (estimativas de preferência declarada) ou o valor por
  ano de vida, entra como linha nova na Tabela 7 (`tab_cost`) e numa frase da
  Seção V.
- **Página:** cabe na tabela que já existe; texto, 2 a 3 frases.

## 3. A idade dos mortos no custo (áudio 5)

**Para depois (16/10),** junto com o item 2. A idade dos mortos na hora 0 já
está no `road_users.rds` (item 4), e serve de ponto de partida.

> "você tem o perfil dos mortos? [...] o perfil etário deles [...] a idade só
> já quebra um galho [...] extrapolando, imaginando que os mortos sejam mais ou
> menos iguais, dá pra fazer uma estimativa com base nisso"

O áudio vem logo depois do áudio do custo ("É a mesma coisa"). A leitura mais
provável: contar anos de vida perdidos em vez de mortes, supondo que as mortes
a mais têm a idade dos mortos na mesma hora.

- **Dado:** o SIM tem a idade de todo óbito. Entre as mortes na via, falta em
  0,1% a 2,4%, conforme o tipo de usuário (`road_users.rds`, `coverage`).
- **Conta:** a idade dos mortos na hora 0 nos tratados, no verão, antes de 2019
  (ou a dos pedestres e a dos demais, ponderadas pela parte de cada um no
  excesso, 43% e 57%), cruzada com a tábua de mortalidade do IBGE (expectativa
  de vida por idade e sexo). Dá anos de vida perdidos por temporada e um valor
  por ano de vida (VSLY) tirado do mesmo VSL.
- **Ressalva:** a hipótese de que os mortos a mais têm a idade dos mortos de
  sempre. O pedestre é 43% do excesso e só 12% da base, então ponderar pelo
  excesso de cada grupo é melhor do que usar a idade média de todos.
- **Viável:** sim, com o que já está no Dropbox mais a tábua do IBGE (baixar
  por script no `build/`). Um script novo no fim de `25_total_cost.R` ou ao
  lado dele.
- **Página:** uma coluna ou linha na Tabela 7 e uma frase.

## 4. Perfil dos mortos: sexo e idade, nas duas fontes

O áudio 5 pergunta se temos o perfil dos mortos. **Decisão do Fredie
(16/10/2026): comparar sexo e idade no SIM e na PRF; raça fica de fora.**

**O que já existe (SIM):** `21_road_users.R` corta por idade e sexo só os
pedestres, hora 0:

| grupo | lp (EP) | mortes por verão, tratados, antes |
|---|---|---|
| pedestres de 15 a 64 anos | 91,1 (30,9) | 8,6 |
| pedestres de 0 a 14 | não estimável | 2,3 |
| pedestres de 65 ou mais | não estimável | 1,7 |
| pedestres homens | 67,8 (32,3) | 8,6 |
| pedestres mulheres | não estimável | 4,3 |

"Não estimável" = menos de 5 mortes por verão; a Tabela B3 do apêndice
(Panel B) imprime essas células com "--". O texto do apêndice cita os pedestres
de 15 a 64 anos. **Não existe** o corte de todos os usuários da via por sexo e
por faixa de idade.

**O que a PRF tem (conferido em 16/10):** a base "Agrupados por pessoa" do
portal de dados abertos (2007–2026; a "Todas as causas e tipos de acidentes"
só começa em 2017) tem uma linha por pessoa envolvida, com `tipo_envolvido`
(condutor, passageiro, pedestre, ciclista, cavaleiro, testemunha),
`estado_fisico`, `idade` e `sexo`, mais o `id` do acidente, a hora e o
município. Baixei 2010 e 2024 para conferir:
- os mortos por pessoa batem exatamente com a soma de `mortos` do nosso
  `prf_accidents.parquet` (8.623 em 2010; 6.163 em 2024). É o mesmo conceito
  de óbito no local;
- idade faltante: 12,5% das pessoas em 2010 e ~0% em 2024; entre os mortos,
  10,9% e 0,1%. Sexo inválido ou ignorado: 3,5% em 2010 e 6,3% em 2024 (entre
  os mortos, 0,6% e 0,2%);
- cerca de 1 em cada 5 mortos é mulher (19,6% em 2010; 19,0% em 2024);
- **raça/cor: não existe** na PRF. No SIM existe (`RACACOR`), mas o build não
  guarda a variável. Fora, por decisão.

**Feito em 16/10/2026:**
1. `build/13_prf_persons.R` baixa e limpa a base por pessoa da PRF
   (2007–2025; ids em `build/manual/prf_person_files.csv`). Os mortos por
   pessoa batem com o `mortos` da base por acidente em todos os anos da amostra
   (a menos de 1 morte em 2011). Duas armadilhas que apareceram: em 2016 o sexo
   vem como M/F/I; e desde 2017 a idade desconhecida vem como 0 (5–6% dos
   mortos, contra 0,3% antes), então idade 0 vira desconhecida. Idade não
   registrada: 11,7% dos mortos antes de 2017 e 5,9% depois. Zips apagados.
2. `21_road_users.R` estima todos os usuários por sexo e por cinco faixas de
   idade (0–14, 15–29, 30–44, 45–59, 60+, escolhidas pelo tamanho das células),
   no SIM e nas mortes da PRF, hora 0. As linhas antigas do `.rds` não mudaram.
3. Tabela B4 do apêndice (`tab_sex_age`), um parágrafo no apêndice, uma frase
   em "Who dies" (IV.F) e uma frase na descrição da PRF (apêndice A).

| hora 0, lp (EP) | mortes na via | mortes PRF |
|---|--:|--:|
| homens | 33,8 (9,9) | 65,2 (20,7) |
| mulheres | 12,7 (22,2) | 5,8 (42,3) |
| 15–29 | 31,5 (13,1) | 89,4 (37,0) |
| 30–44 | 10,5 (16,7) | 59,9 (31,8) |
| 45–59 | 44,1 (19,2) | 64,3 (28,6) |
| 60+ | 59,9 (25,6) | não estimável |

**México:** não dá para repetir com o ATUS, cujo sexo e idade são do condutor
apontado como responsável, não dos mortos (ver VIABILIDADE §21).

**Como dizer:** os homens, ~4/5 dos mortos, sobem nas duas bases; para as
mulheres as estimativas são imprecisas demais para comparar (não escrever que
"não subiram"). Toda faixa a partir de 15 anos é positiva onde dá para estimar,
sem precisão para ordenar as faixas. Números em `VIABILIDADE.md` §21.

## 5. Iluminação pública: satélite ou Censo

- **p. 2 (vermelho):** "Street lights mudam o resultado?? Os dados de satélite
  permitem distinguir? (creio que não)".
- **Áudio 2:** sugere luz noturna por satélite ("daria um charme"), mas nota
  que ela mistura a rua com as casas, que a cor da iluminação não é constante
  e que talvez fosse o caso de medir só na área urbana (a da Embrapa, "bem
  melhor do que a urbanização dita"). Conclui sozinho: "acho que é besteira
  porque, no fundo, você está pegando acidentes que não são em área urbana [...]
  besteira minha".
- **p. 15 (vermelho), ao lado da iluminação pelo Censo:** "isso deve ser melhor
  do que satélite mesmo".

**Status ✔:** o paper já corta pela iluminação da rua do Censo 2022 (Pesquisa
Urbanística do Entorno), com o Censo 2010 como robustez: 40,8 lp (10,3) na
metade mais escura contra 14,1 (15,6), p = 0,16 (`24_street_lighting.R`,
Tabela B6 do apêndice; uma frase em IV.F).

**Decisão (16/10): o satélite não entra, nem no apêndice.** Ele mesmo
descartou, e o Censo mede a coisa certa (poste na face da quadra), que o
satélite não separa das casas. Um parecerista que perguntar recebe essa
resposta na carta. Uma ressalva ao argumento dele: o "não é área urbana" vale
para a PRF. O SIM cobre as ruas das cidades, onde morre boa parte dos
pedestres; por isso o corte por iluminação usa o SIM.

## 6. Ofuscamento e rugosidade do relevo (p. 13 e áudio 3)

> "E a ruggedness. Em áreas muito acidentadas, não há ofuscamento. Isso pode
> ser usado como robustez." (p. 13, sobre a queda da hora −1 na PRF)
>
> "municípios mais acidentados, você não espera que tenha ofuscamento [...]
> é um dado fácil, que existe, já calculado" (áudio 3)

- **Contexto que mudou:** no EXPLICANDO de 12/10 a queda da hora −1 na PRF era
  "o quebra-cabeça aberto", com o ofuscamento como candidato. O paper de hoje
  mostra que essa queda começou em 2018/19, ainda com horário de verão (IV.C,
  Figura 4: "the fall in that hour predates abolition"), e não fala mais de
  ofuscamento. O teste dele vira checagem de um mecanismo que o paper já não
  defende.
- **Viável:** sim. Rugosidade (*terrain ruggedness index*) por município da
  grade de Nunn & Puga (2012) ou do SRTM; ou em volta de cada acidente, com as
  coordenadas da PRF (desde 2017). Cortar a hora −1 da PRF em municípios
  planos contra acidentados.
- **Extensão (minha):** o ofuscamento depende de dirigir em direção ao sol. A
  direção do trecho (leste-oeste contra norte-sul, pela malha do SNV/DNIT e o
  `sentido_via` da PRF) é um teste mais afiado que o relevo. Dá mais trabalho.
- **Decisão (16/10): não entra.** O ROADMAP já registrava, em 13/10, que o
  ofuscamento saiu do paper: a queda começa em 2018/19 e, sem horário de verão,
  o sol baixo cai *na* hora −1, o contrário do que o ofuscamento explicaria. Um
  teste de rugosidade checaria um mecanismo que o paper não defende, e um
  editor leria a linha nova como reabertura de uma questão fechada. Se um
  parecerista perguntar pela hora −1, a resposta é a pré-tendência.

## 7. Robustez sem os municípios litorâneos (p. 7 e áudio 4)

- **p. 7 (vermelho):** "Robustez: tirar cidades litorâneas", ao lado de "o
  litoral de SC e as estradas para o litoral enchem no verão".
- **Áudio 4:** "uma coisa que eu tinha pensado, mas [...] você já resolveu com
  a história dos municípios litorâneos e tudo mais [...] já está bem cuidado no
  paper".
- **Antes:** o efeito fixo de UF × janela absorve a diferença permanente
  entre verão e inverno de cada estado, turismo incluído (III.A, "tourism"),
  mas não havia teste sem o litoral.
- **Feito em 16/10 ✔:** `build/14_coastal_municipalities.R` (lista oficial
  do IBGE de 2022, 279 municípios; a Lagoa dos Patos, que o IBGE lista com
  código, sai) e uma amostra nova no `20_leave_out.R`. Sem o litoral: mortes
  na via 36,3 (9,4), PRF mortes 56,4 (22,9), acidentes com vítima 23,6 (6,9).
  O efeito sobe um pouco; o turismo de praia não o explica. Linha na Tabela B1
  e meia frase no corpo (IV.C), ao lado das outras amostras.
- **De quebra:** o rerun mostrou que a linha "sem Carnaval e festas de fim de
  ano" estava com cache velho: 30,8 (8,0), não (7,8). O resultado antigo tinha
  sido gravado com os feriados só até 2023, sem o Carnaval de 2024 (10 a
  14/02), que cai na janela de verão de 2023/24; o código já estava certo, mas
  o `20` não tinha sido rodado de novo. Texto corrigido no corpo e no apêndice.
- **Por que vale:** o turismo de verão no litoral pode ter mudado depois de
  2019 (a pandemia mexeu com isso), e isso o efeito fixo não absorve.
- **Viável:** muito fácil. Lista de municípios defrontantes com o mar do IBGE;
  tirar e reestimar SIM e PRF na hora 0. Uma linha na Tabela de sensibilidade
  do apêndice (Tabela B1).

## 8. Saída de fevereiro contra abolição (p. 3)

> "um ponto menor só para facilitar o entendimento: diferenciar entre saída do
> HV e sua abolição"

- **No paper:** quase sempre "abolition" para 2019 e "when DST ended each
  February" para a saída sazonal (IV.I). Dois pontos ainda misturam:
  "Decree 9,772 [...] ended DST in the whole country" (I.A) e "DST ended on
  17 February 2019 as scheduled" (I.B, que é a saída sazonal, correta, mas ao
  lado da abolição).
- **Feito em 16/10 ✔:** "abolished" para o decreto de 2019 (I.A e apêndice
  A) e para a lei mexicana; "the clocks went back / went forward" para a troca
  sazonal (I.B e IV.I). Zero página.

## 9. "Instrumento de medida" (p. 3)

> "Como assim instrumento de medida? vc está dizendo a estratégia de
> identificação/fonte de exogeneidade"

Sobre a frase do EXPLICANDO "o instrumento de medida não é novo; o experimento
é". **No paper ✔:** não há "instrument"; a contribuição diz que os estudos de
luz e crime também medem a hora pela luz do lugar, e que o novo é a mudança de
regime, permanente e sem noite de sono perdida (introdução, segunda e terceira
literaturas). Se o EXPLICANDO for reaproveitado: "medir a hora pelo pôr do sol
do lugar não é novo; a fonte de variação, o fim do regime, é".

## 10. Infarto como deslocamento (p. 2)

> "mas é deslocamento, né? o sujeito adianta o infarto que teria mais cedo do
> que tarde, eu imagino"

Sobre Toro, Tigre & Sampaio (2015, *Economics Letters* 136: 1–4), lido na
versão da tese do Toro (UFPE, cap. 3) e no resumo publicado.

**O que o artigo faz:** regressão descontínua diária, SIM 2007–2012, log das
mortes por infarto agudo do miocárdio nos estados com horário de verão,
corrigido por dia da semana, estado e ano. O salto no primeiro dia depois da
entrada é de 7,1% a 8,5% (EP ~0,04; significante a 5% em dois dos três
seletores de banda). Nos estados sem horário de verão o salto é zero, na saída
de fevereiro também, nas semanas anteriores também, e câncer, infecções virais
e doenças parasitárias não se movem.

**Ele tem razão no ponto do deslocamento.** O desenho mede o salto logo depois
da troca e não testa se as mortes caem nas semanas seguintes. A conta de 196
mortes por ano do artigo supõe que o efeito dura 7 dias sem compensação
depois. Então o artigo mostra que a troca antecipa ou provoca infartos, mas
não separa as duas coisas, nem dá o saldo líquido. Citar só como "mais mortes
por infarto logo depois da troca", nunca como contagem anual.

**Para o nosso paper:** o problema não se repete. Morte no trânsito não é
antecipação de uma morte que viria de qualquer jeito (a idade mediana dos
mortos na hora 0 é 35 anos), e a pergunta análoga, se as mortes só mudaram
de hora, está em IV.H.

**Decisão (16/10): o artigo volta ao paper, na Seção V**, em meia linha: as
duas trocas por ano que a abolição tirou têm um custo de sono que a nossa conta
não inclui, e no Brasil esse custo aparece em mais mortes por infarto. Isso
mostra o lado da conta que favorece a abolição. Não entra na seção das
trocas (IV.I): lá a frase é sobre o sono agir em todas as horas do dia, e um
salto diário de infarto não sustenta isso.

## 11. Redação do EXPLICANDO

Só valem se o EXPLICANDO for reaproveitado; o paper não tem esses trechos.
- §1.2: riscou "fisicamente" no título "O que o horário de verão faz,
  fisicamente".
- §4.5: "tradução esquisita" em "é pouco para a assintótica confiar". No paper:
  "cluster-robust inference can over-reject".
- §5.4: "entendi o que vc quer dizer, mas seria melhor 'covid não muda os
  efeitos'", sobre "COVID não muda nada". O paper de hoje diz outra coisa, e
  diz certo: sem mar/2020–fev/2022 a estimativa é 22,9, e a faixa vai de 22,9 a
  34,5 conforme o tratamento da pandemia (IV.C).
- §5.3: um "?" ao lado de "Esse é o principal quebra-cabeça aberto" (a hora −1
  na PRF). Respondido no paper: a queda é anterior à abolição (ver item 6).
- p. 11: uma caixa de texto vazia ("Texto"), sobra do editor de PDF.

## 12. Trechos que ele grifou sem comentar

- §0: "calculada pelo pôr do sol de cada município em cada dia, comparando os
  estados que tinham horário de verão com os que nunca tiveram, o verão com o
  resto do ano, e antes com depois de 2019" (o desenho em uma frase).
- §1.3: "A transição mistura dois choques: a noite de sono perdida (ou ganha) e
  a mudança de luz. Ela diz muito sobre o custo de trocar o relógio e pouco
  sobre o custo de viver num regime ou no outro." (está no segundo parágrafo da
  introdução).
- §2.1, Gillmore (2025): "Sono (+6% de acidentes na semana após a entrada) e
  luz (que reduz acidentes graves e fatais). Usa as datas que mudam de ano a
  ano." (citado na introdução, como o estudo mais próximo nas transições).
- §5.9: "ofuscamento pelo sol baixo" (ver item 6).

## 13. Elogios e reações

- PNCT separando exposição de risco: "muito bom".
- Primeiro estágio: "Caramba! que efeito imenso". O número que ele viu (+33,7
  p.p., às 18–19h do relógio) é da versão de 12/10. O paper usa a hora 0 e dá
  +23,6 p.p. (EP 2,0); a nota é a mesma, o tamanho mudou com a definição.
- Áudio 4: "gostei muito da coisa de explicar que não é só[no?], achei muito
  crível mesmo". Os dois modelos ouvem "não é só"; pela conversa, deve ser
  "não é sono" (a Seção 6 do EXPLICANDO, IV.E no paper).
- Áudio 4: "um paper super interessante, [...] o esforço de diferenciar da
  literatura, eu achei muito bom, [...] ficou muito caprichado".
- Áudio 1: "eu gostei muito [...] tem uns comentários pontuais e mais uma
  sugestão de dados" (o satélite do item 5, ou a rugosidade do item 6).

---

## Páginas

A AEJ: Policy aceita até 45 páginas em 12 pt (`PAPER.md`). Depois desta rodada
(16/10/2026) o `paper.pdf` continua com 36 e o apêndice, que não conta, foi de
23 para 24 (Tabela B4 nova).

| item | corpo | apêndice |
|---|---|---|
| 4, sexo e idade | 1 frase em IV.F | Tabela B4, um parágrafo, uma frase em A |
| 7, litoral | meia frase em IV.C | uma linha na Tabela B1 e na nota |
| 8, saída × abolição | 0 (troca de palavras) | 0 |
| 2 e 3, custo (para depois) | linha ou coluna na Tabela 7, 2–3 frases | as entradas, no apêndice de custo |

Sobram ~9 páginas para o custo e para o que vier dos pareceristas.

---

## Transcrição dos áudios

Whisper large-v3-turbo (mlx), conferido com o medium (faster-whisper).
Pontuação e quebras são do modelo; [?] marca o que nenhum dos dois ouve com
clareza.

**Áudio 1 — 16:13:34 (31 s)**
Olá Fred, tudo bem? Eu mandei aí para o teu e-mail, tá? Não estranha não, que
tem duas versões, mas é a princípio a mesma coisa, tá? Que eu estou usando na
sala VIP aqui do aeroporto, então estou usando aquele computador, tem uns Mac
públicos aqui, como usei no Preview, então salvei nas duas versões. Eu gostei
muito, claro que você sabe disso, tem uns comentários pontuais e mais uma
sugestão de dados mesmo, algumas coisas que eu estou pensando aqui, tá?

**Áudio 2 — 16:15:20 (70 s)**
Uma coisa que eu acho que melhoraria o paper, ou sei lá, daria um charme, eu
não sei o quanto que ainda se usa isso, que é usar os dados de satélite de
iluminação. Claro que vai pegar as duas coisas misturadas, vai pegar a rua com
as casas. Eu não sei se alguém já tentou filtrar, distinguir essas coisas,
[?] por causa da cor de cada uma, da cor da iluminação, que não é constante,
mas eu não sei se não valeria usar, porque o jeito que você está usando é
legal, mas também pode ser questionável. Fazer uma medida, talvez, iluminação
por área urbana, porque área urbana é urbana mesmo, do município, porque...
Bom, não sei. Não, acho que não faz sentido não. Bom, para a gente passar isso
mais adiante, tá? Porque precisa primeiro a área urbana, que é aquela coisa que
a Embrapa calcula, né, que é bem melhor do que a urbanização dita geralmente,
mas acho que é besteira porque, no fundo, você está pegando acidentes que não
são em área urbana, né? Então, besteira minha.

**Áudio 3 — 16:17:07 (25 s)**
O outro ponto é o seguinte, é coisa do ofuscamento, né, que eu achei um puzzle
super legal e eu pensei um jeito de tentar explorar isso, que é olhar para os
dados de ruggedness dos municípios, né, ou seja, municípios mais acidentados,
você não espera que [não?] tenha ofuscamento, né. Então eu acho que isso é um
dado fácil, que existe, já calculado e tudo mais.

**Áudio 4 — 16:18:27 (58 s)**
Eu gostei muito da coisa de explicar que não é só[no?], achei muito crível
mesmo, achei bem bacana. E é isso, cara, eu topo a tua proposta de melhorar o
cálculo do custo, vou ver como é que tem as novidades nesse cálculo do custo,
se tem coisa melhor do que o valor estatístico da vida, esse tipo de coisa, e
eu topo então isso. Não, acho que é... Ah, uma coisa que eu tinha pensado, mas
eu acho que você já resolveu com a história dos municípios litorâneos e tudo
mais, mas deixa, acho que isso aí já está bem cuidado no paper, tá? Valeu,
cara, eu acho que é isso, é um paper super interessante, mesmo, e até o esforço
de diferenciar da literatura, eu achei muito bom, assim, né, ficou muito
caprichado. Valeu, abraço.

**Áudio 5 — 16:22:31 (43 s)**
Opa, desculpa me escrever aqui que eu tô agora no celular. É a mesma coisa:
você tem o perfil dos mortos? Você tem, né? Você não tem só acidente, você tem
o perfil etário deles, né? Porque eu acho que isso é um refinamento, meio que
um exagero talvez, mas pode ser uma boa, né? Nem que seja a idade só já quebra
um galho, né? Extrapolando, imaginando que os mortos sejam mais ou menos
iguais, né? Dá pra fazer uma estimativa com base nisso. Vou pensar melhor, né?
Deve ter outras coisas, mas eu queria saber mais ou menos o que que tem, tá?
Valeu, abraço.
