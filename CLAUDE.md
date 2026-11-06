# CLAUDE.md — o build, os dados e as armadilhas

Manual operacional do repositório **DaylightSaving**: o fim do horário de verão
no Brasil (Decreto 9.772/2019) e seu efeito sobre as mortes no trânsito. A pergunta e o desenho estão em
`horario_verao/CONTEXTO_PESQUISA.md`; a ordem do trabalho, em
`horario_verao/ROADMAP.md`.

Responda em **português**. **Comentários de código em inglês.** O manuscrito é
em inglês.

---

## 1. Geografia do projeto

```
DaylightSaving/                      (git — código, nunca dado)
  config/config.R                    DROPBOX_ROOT é a única edição por máquina
  build/manual/                      calendário legal digitado dos decretos (versionado)
  build/01_dst_calendar.R            manual/ → painéis UF × temporada e UF × dia
  build/02–12                        um passo por fonte (config/00_master_build.R roda tudo;
                                     10 = fronteiras do mapa)
  analysis/code/01–26                estimam e guardam audit/*.rds
  analysis/code/27, 28               figuras e tabelas, lidas só dos .rds
                                     (00_master_analysis.R roda 01–28)
  analysis/output/                   graphs/, tables/, maps/ (mapa do Brasil)
  dictionary/                        build_dictionary.R → data_dictionary.xlsx (PT/EN,
                                     todas as bases; para se uma coluna mudar sem descrição)
  latex/                             paper.tex (AEJ: Policy, anônimo), appendix.tex,
                                     title_page.tex, paper_wp.tex; texto em sections/;
                                     compila com latex/build.sh
  horario_verao/                     gestão: contexto, roadmap, tabela, fontes legais, skills

Dropbox/DaylightSaving/build/        (dado, nunca git)
  <fonte>/{input,output}/            prf sim pnct geo weather census
  calendar/output/                   dst_uf_season.parquet, dst_uf_day.parquet
  audit/
```

## 2. Regras

1. **Dado não entra no git.** A exceção é `build/manual/*.csv`: pequeno,
   digitado à mão dos decretos, e é a fonte do tratamento.
2. **O decreto vence o tzdata.** O tzdata da IANA é uma ótima compilação, mas
   erra pelo menos uma vez (MT em 1994/95). Qualquer mudança no calendário
   precisa citar o ato e o texto em `horario_verao/fontes_legais/`.
3. **A troca de relógio é à 00:00 local.** Um dia tem `dst = 1` quando
   `inicio <= data < fim`; o dia do fim já é horário normal.
4. **`TABELA_ESTADOS.md` é gerada.** Não editar à mão; rodar
   `Rscript build/01_dst_calendar.R`.
5. **Hora local, hora solar e UTC são coisas diferentes.** AC e o oeste do AM
   mudaram de fuso em 2008 e voltaram em 2013; o oeste do PA mudou em 2008 e
   ficou. Toda análise por hora precisa dizer em qual das três está.
6. **Só fica código que gera exibição.** Um script da análise existe porque uma
   figura ou tabela do paper lê o `.rds` dele. Comentários dizem o que o código
   faz e por quê, sem datas de mudança nem histórico (isso vai no ROADMAP).
7. **Nenhum caminho para outro projeto.** Todo dado é lido de `DROPBOX_ROOT`
   ou baixado para lá por um script do `build/`. Bruto sem download por
   script (hoje só o NetCDF do Xavier) fica no `input/` da fonte.

## 3. Período

Jul/2008 a jun/2024 (temporadas jul–jun; 2023/24 é a última com SIM definitivo): 11 com horário de verão, 5 sem. Volume e acidentes na tabela de volume vão até 2024/25. Detalhes em `horario_verao/CONTEXTO_PESQUISA.md`.

## 4. Calendário legal (o que já está conferido)

- 34 temporadas, de 1985/86 a 2018/19. 33 atos lidos no Planalto. Só o texto do
  Dec. 91.698/1985 não foi localizado (a abrangência nacional e o fim estão
  confirmados nos decretos 92.310 e 92.463 de 1986).
- 2008/09–2018/19 seguem a regra do Dec. 6.558/2008, conferida pelo script:
  3º domingo de outubro ao 3º domingo de fevereiro, uma semana depois se o fim
  cair no domingo de carnaval (aconteceu em 2012 e 2015); início no 1º domingo
  de novembro a partir de 2018 (Dec. 9.242/2017).
- Dentro da janela dos dados (2009+), o tratamento é o bloco fixo
  RS SC PR SP RJ ES MG GO MT MS DF, mais **BA em 2011/12** e **TO em 2012/13**.
- 2000/01 tem saídas no meio da temporada (PE e RR após 1 semana; o resto do NE
  após 2 semanas): `build/manual/hv_excecoes.csv`.
