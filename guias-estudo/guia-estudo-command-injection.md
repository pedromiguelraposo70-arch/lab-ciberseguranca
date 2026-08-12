# Guia de Estudo — Command Injection (Low, Medium e High)

*Documento de consolidação do módulo Command Injection do DVWA, escrito para conseguir explicar isto a alguém sem ter o ecrã à frente. Inclui os acertos, os enganos e as intuições — certas e erradas — pelo caminho, porque o percurso do raciocínio também é aprendizagem.*

---

## 1. O que é Command Injection, em 30 segundos

Uma página web pega no que escreves e usa-o para construir um **comando do sistema operativo**, que depois executa na shell do servidor — sem verificar se aquilo é só um dado (um IP) ou se é, na prática, mais um comando.

**Analogia:** é como pedires a um assistente "faz ping a este endereço: ___". Normalmente escreves `127.0.0.1` e ele faz o ping. Mas se escreveres `127.0.0.1; apaga tudo`, e ele cumprir à letra sem questionar, faz o ping **e** a seguir apaga tudo.

Diferença face ao SQL Injection: no SQLi o input escapa para dentro de uma *query SQL* (rouba-se dados da base de dados). No Command Injection, o input escapa para a *shell do sistema operativo* — obtém-se **execução de comandos no servidor** (RCE, *Remote Code Execution*). É um degrau acima em impacto: deixa de ser só sobre dados e passa a ser sobre a máquina.

---

## 2. Tabela de operadores de shell (referência)

O que permite "encadear" um comando nosso ao comando legítimo são caracteres especiais da shell. Cada um tem um comportamento diferente — não é preciso decorar, basta perceber e consultar:

| Caractere | Comportamento |
|-----------|---------------|
| `;` | Corre sempre o seguinte, independente do resultado do anterior |
| `&&` | Corre o seguinte só se o anterior teve sucesso |
| `\|\|` | Corre o seguinte só se o anterior falhou |
| `&` | Põe o anterior em segundo plano e corre o seguinte ao mesmo tempo |
| `\|` | Passa o *output* de um como *input* do outro (pipe) |
| `` ` `` / `$()` | Insere o *resultado* de um comando dentro de outro (command substitution) |

Isto explica diferenças de comportamento observadas na prática: com `;` e `&` vê-se o ping **e** o `www-data` (comandos independentes, ambos escrevem no ecrã); com `|` só se vê o `www-data`, porque o pipe canaliza a saída do ping para dentro do `whoami` (que a ignora), em vez de a mostrar.

---

## 3. Low — sem defesa

Payload: `127.0.0.1; whoami`

O `;` encadeia o `whoami` a seguir ao ping. O servidor corre os dois e mostra `www-data` (a conta de baixo privilégio com que o servidor web corre). Com `; hostname` descobriu-se ainda que o alvo é um **container Docker** (hostname = ID do container). Nenhuma filtragem — porta escancarada.

---

## 4. Medium — blacklist curta

O código passa a **apagar** caracteres do input. Bloqueia `;` e `&&`. Por isso o payload do Low deixou de funcionar (o `;` é removido).

Mas é uma **blacklist**, e esqueceu-se de outros operadores:
- `127.0.0.1 | whoami` → funciona (pipe)
- `127.0.0.1 & whoami` → funciona (segundo plano)

Defesa contornada por dois caminhos.

---

## 5. High — blacklist maior, mas ainda furada

O código melhora a blacklist: agora apanha o `| ` (pipe **seguido de espaço**), além de `;`, `&&`, e outros. O bypass `| whoami` do Medium deixa de funcionar.

Mas continua a ser blacklist, e continua furada:
- `127.0.0.1 & whoami` → **ainda funciona** (o `&` sozinho não foi bloqueado)
- `127.0.0.1|whoami` (pipe **sem espaço**) → **funciona** — o filtro procura `| ` (com espaço); tirando o espaço, a sequência que ele procura deixa de existir e o pipe passa

O detalhe do espaço é revelador: **um único espaço** é a diferença entre a defesa funcionar e falhar. O programador bloqueou `| ` mas esqueceu que `|whoami` (colado) faz o mesmo.

---

## 6. A lição central: blacklist vs whitelist

Uma **blacklist** (lista negra) tenta enumerar tudo o que é perigoso e bloqueá-lo. É uma corrida perdida: não basta pensar nos caracteres perigosos, é preciso pensar em todas as *variações* de como os escrever (com espaço, sem espaço, codificados, etc.). Cada caractere que o defensor adiciona, o atacante só tem de encontrar o próximo que ele esqueceu.

A **whitelist** (lista branca) faz o inverso e é a defesa correta: só permite *exatamente* o que é reconhecidamente seguro (ex.: aceitar apenas dígitos e pontos de um IP válido) e recusa tudo o resto. Aí não interessa quantas variações o atacante invente — se não está expressamente permitido, é recusado. É isto que o nível Impossible do módulo faz.

Outras defesas de reforço: nunca passar input do utilizador diretamente à shell (usar código/bibliotecas próprias), e menor privilégio (o servidor correr como `www-data`, não root, limita o estrago).

---

## 7. Deduções e raciocínio pelo caminho (certos e errados)

- **Low — intuição certa:** ao ver a caixa que pedia um IP, deduzi que podia ser um sítio para injetar um comando. Apontava para o mecanismo certo.
- **Low — confusão que virou compreensão:** fiquei baralhado porque não via a palavra "whoami" no output ("não existe whoami"). Percebi que um comando **não mostra o próprio nome, só o resultado** — `www-data` *é* a resposta do `whoami`.
- **Medium — previsão errada, corrigida:** previ que "não mudava nada, por analogia com o SQLi Medium". Ao testar e não ver o `www-data`, corrigi: afinal há filtragem. Lição: a analogia é um ponto de partida, não uma garantia.
- **Medium — dedução certa:** propus o `|` como alternativa e previ que, se passasse, o `www-data` teria de aparecer. Confirmou-se.
- **High — previsão certa:** previ "mais restrito, mas sempre haverá uma brecha (qual, não sei)". Confirmou-se: o High tapou o `| ` mas deixou o `&` e o `|` sem espaço.
- **High — erro de leitura, corrigido:** ao testar `& whoami`, li mal e pensei que tinha sido bloqueado; ao reconfirmar, vi que o `www-data` apareceu. Corrigi a observação antes de tirar conclusões.
- **Síntese:** ao pesquisar os operadores de shell, percebi que cada um tem um comportamento próprio — sem precisar de decorar, sabendo que posso consultar (ver tabela na secção 2).

---

## 8. Resumo para explicar a alguém em 60 segundos

> "Testei uma página que fazia ping a um IP que eu escrevia. Como ela metia o meu texto diretamente num comando do sistema, consegui, com caracteres como `;`, `|` e `&`, encadear comandos meus e executá-los no servidor — vi o utilizador (`www-data`) e até que o alvo era um container Docker. Nos níveis Medium e High tentaram defender-se apagando caracteres perigosos (uma blacklist), mas esqueceram-se sempre de algum (`|`, `&`, ou o `|` sem espaço) — porque é impossível listar tudo. A defesa correta é o inverso: uma whitelist que só aceita o formato de um IP válido e recusa tudo o resto."

---

## 9. Estado de compreensão (honesto)

**2026-08-12:**
- Explicar o que é Command Injection, porque é mais perigoso que o SQLi (RCE), e a diferença entre blacklist e whitelist: **Sim** — por palavras minhas.
- Perceber o comportamento dos operadores de shell e porque é que o output difere (`;`/`&` vs `|`): **Sim**.
- Fabricar/descobrir bypasses do zero sem ajuda: **Em progresso** — descobri o `|` sozinho no Medium; no High precisei de pista para o truque do espaço. Objetivo de repetição, não falha de compreensão.
- Nível **Impossible** explorado (Entrada #20): confirmado que a whitelist recusa todos os bypasses com o mesmo erro (`invalid IP`) — o resultado uniforme é a assinatura de uma whitelist face à blacklist. Módulo Command Injection completo.
