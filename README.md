# Laboratório de Cibersegurança — Diário de Aprendizagem

## Porque é que este repositório existe

Sou estudante iniciante de cibersegurança. Este repositório não é um produto acabado nem uma demonstração de competência — é o **registo honesto de como estou a aprender**, montando e usando um laboratório de máquinas virtuais em casa (VMware Workstation) para praticar de forma prática e segura.

A decisão de documentar tudo, incluindo o que correu mal, é intencional. A maior parte dos materiais de cibersegurança que se encontram online mostram o resultado final — o ataque que funcionou, o comando certo à primeira. Isso é útil para copiar, mas esconde a parte mais importante do processo de aprendizagem: os erros, os becos sem saída, e o raciocínio que leva de "não sei porque é que isto não funciona" a "ah, era isto".

## O que vais encontrar aqui

- **[`registo-laboratorio-ciberseguranca.md`](./registo-laboratorio-ciberseguranca.md)** — o registo principal, entrada a entrada, de cada exercício: objetivo, comandos usados, o que era esperado, o que aconteceu de facto, como nos podemos defender do ataque em causa, e — sempre que aplicável — **o que correu mal ou falhou**. Também mapeado, quando faz sentido, para os domínios de certificações em estudo (Security+, CEH, ISO/IEC 27001, NIS2, CompTIA A+).
- **`registo-laboratorio-ciberseguranca.pdf`** — a mesma informação, com os screenshots embutidos, para leitura fora do GitHub.
- **`screenshots/AAAA-MM-DD/`** — capturas de ecrã ilustrativas de cada dia de trabalho.
- **`guias-estudo/`** — documentos de consolidação por tema (analogias, raciocínio passo a passo, autoavaliação honesta de compreensão), separados do registo técnico.

## O espírito deste repositório

- **Não é um produto final.** É atualizado sessão a sessão, à medida que os exercícios acontecem — não reescrito no final para parecer mais polido do que foi na realidade.
- **Erros ficam registados, não apagados.** Se um comando falhou, se uma configuração de rede se partiu a meio de um exercício, se um pressuposto estava errado — isso fica documentado tal como aconteceu, porque é aí que está a aprendizagem real.
- **Evolução visível ao longo do tempo.** As primeiras entradas vão parecer mais hesitantes ou mais básicas do que as últimas — é suposto ser assim. Comparar a Entrada #1 com uma entrada de daqui a alguns meses deve mostrar claramente o progresso.

## Estado atual

**Dia 1 concluído** (2026-08-02): laboratório montado (OPNsense + Kali + Servidor Vulnerável), DVWA instalado, primeiro exercício de exploração (SQL Injection, nível Low) realizado com sucesso.

**Dia 2 concluído** (2026-08-05/06): SQL Injection nível Medium confirmado com sucesso (payload `1 OR 1=1`, via `curl` direto ao servidor), após investigação de uma falha de configuração real (cookies `security` duplicadas com paths diferentes). Corrigida também a política de restart do container Docker do DVWA.

Próximo passo: SQL Injection nível High e Impossible, para comparar as defesas introduzidas.
