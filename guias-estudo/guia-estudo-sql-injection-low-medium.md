# Guia de Estudo — SQL Injection (Low, Medium e High)

*Documento para consolidar o que foi aprendido no Dia 1, Dia 2 e Dia 3, escrito para conseguires explicar isto a alguém sem teres o ecrã à frente. Inclui os enganos pelo caminho — fazem parte da aprendizagem, não são para esconder.*

---

## 1. O que é SQL Injection, em 30 segundos

Um site "confia demais" no que escreves numa caixa de texto, e usa isso diretamente para construir uma pergunta à base de dados — sem verificar se é só um dado (um número de ID) ou se é, na prática, parte de um comando.

**Analogia:** imagina que dizes a um empregado de um arquivo: *"traz-me o dossier do cliente número [o que eu disser aqui]"*. Normalmente dizes "5", ele traz o dossier 5. Mas se disseres *"5, ou traz-me todos os dossiers"*, e ele cumprir literalmente, palavra a palavra, sem questionar — traz-te tudo.

---

## 2. O payload do Low: `%' OR '1'='1`

Query no Low:
```sql
WHERE user_id = '$id';
```

Substituindo pelo payload:
```sql
WHERE user_id = '%' OR '1'='1';
```

1. **`user_id = '%'`** — a aspa do teu texto fecha a aspa que já lá estava
2. **` OR `** — já fora da string, lido como operador lógico
3. **`'1'='1'`** — sempre verdadeiro, para qualquer linha

Resultado: condição sempre verdadeira para todas as linhas. Devolve os 5 utilizadores.

O `1` antes do OR é só preenchimento gramatical. O `1=1` é uma **tautologia** — o padrão X=X, sempre verdadeiro por estrutura.

---

## 3. Porque mudámos para Medium

No Low, nenhuma proteção. No Medium, a aplicação tenta proteger-se — a pergunta é se essa proteção aguenta.

---

## 4. O payload do Medium: `1 OR 1=1` (sem aspas)

Query no Medium:
```sql
WHERE user_id = $id;   -- sem aspas!
```

O `mysqli_real_escape_string()` só neutraliza aspas. Sem aspas na query, não há nada para essa função proteger. `1 OR 1=1` já é, por si só, uma condição booleana válida.

A vulnerabilidade de fundo é a mesma do Low: nunca se confirma que `$id` é mesmo um número.

---

## 5. O payload do High: `1' OR '1'='1' #`

No High, o input **volta a estar entre aspas** (como no Low), mas a query traz um obstáculo novo — um `LIMIT 1` que força um único resultado — e a caixa de input está numa **janela separada**, cujo valor é guardado na **sessão**.

Query no High:
```sql
WHERE user_id = '$id' LIMIT 1;
```

Substituindo pelo payload:
```sql
WHERE user_id = '1' OR '1'='1' #' LIMIT 1;
```

1. **`1'`** — fecha a aspa que o código abriu
2. **`OR '1'='1'`** — tautologia, verdadeira para todas as linhas
3. **`#`** — comenta tudo o que vem a seguir (` LIMIT 1;`), anulando o travão que limitava a 1 resultado

Sem o `#`, a condição faria match com todos os utilizadores, mas o `LIMIT 1` só mostraria um — e não verias a diferença. O comentário é o que torna o ataque visível.

**A diferença que importa:** no High, a proteção do *código* continua fraca. O que muda é a *arquitetura* — janela separada, estado na sessão, e o `LIMIT 1`. Isto dificulta sobretudo **ataques automáticos** (um script espera ler o resultado no mesmo sítio onde submete). Para um humano que entende o fluxo, continua trivialmente injetável.

**A dificuldade real desta fase não é perceber o ataque — é fabricar o payload do zero.** Ler `1' OR '1'='1' #` e entender cada peça é o marco que interessa agora; *descobrir sozinho* que era preciso comentar o `LIMIT 1` vem com repetição, e é cada vez mais assistido por ferramentas.

---

## 6. A investigação (os enganos que valeram a pena)

- **Cookies duplicadas com paths diferentes** causaram comportamento inconsistente — lição: "stale state", quando um sistema guarda a mesma info em mais de um sítio
- **"Resend" do Firefox** repete dados da submissão anterior, não os atuais
- **Edições de HTML via DevTools são temporárias** — perdem-se em qualquer recarregamento
- **`curl` direto ao servidor** é uma forma mais rigorosa de confirmar uma vulnerabilidade do que testar via browser

---

## 7. Resumo para explicar a alguém em 60 segundos

> "Testei se uma aplicação web protegia bem o acesso à sua base de dados. No nível mais fraco, uma aspa mal tratada permitiu alterar a pergunta feita à base de dados. No nível seguinte, a aplicação tentou bloquear aspas, mas fê-lo removendo-as da query em vez de validar o tipo de dado — o que abriu uma porta ainda mais simples. No terceiro nível (High), a defesa do código continuava fraca: bastou fechar a aspa e comentar o resto da query para contornar o limite de resultados. A lição de fundo é a mesma nos três: nunca se confirmou que o ID recebido era mesmo um número, e o input consegue passar de 'dado' a 'comando'."

---

## 8. Estado de compreensão (honesto)

**2026-08-06:**
Payload com aspas (Low): **Não**
Payload sem aspas (Medium): **Não**
*Fica registado sem suavizar — dia longo, com muita fricção técnica antes de chegar aqui.*

**2026-08-11 (após o exercício de High):**
Explicar a lógica dos três níveis (porque é que a caixa devolve 5 utilizadores em vez de 1) e a defesa, por palavras minhas: **Sim**
Fabricar o payload do zero (chegar sozinho ao `#` para matar o `LIMIT 1`): **Ainda não**
*Progresso real face a 06-08: o conceito assentou. A parte que falta é fluência técnica, que se ganha com repetição — não é falha de compreensão. Não confundir "não consigo inventar o payload sozinho" com "não percebi o ataque".*

## Comparação com outras injeções

Para o quadro comparativo entre SQL Injection, Command Injection e XSS — e o fio condutor comum a todos — ver o guia dedicado: [`guia-estudo-comparativo-vulnerabilidades-web.md`](guia-estudo-comparativo-vulnerabilidades-web.md).

## Nota metodológica pessoal

Não tenho background de programação, por isso tenho dificuldade em ler payloads de forma global — "de repente" — e perceber o que fazem. A abordagem que funciona para mim é decompor o payload símbolo a símbolo (ou pedaço a pedaço), perguntando "o que é que **esta parte específica** faz?", em vez de tentar interpretar a linha toda de uma vez.

Isto foi validado com o exercício do "espaço em branco" (substituição literal de `$id` na query), que ajudou a perceber o mecanismo de `' OR '1'='1` passo a passo antes de perceber o efeito final.

Aplica-se a qualquer payload novo daqui para a frente (Command Injection, XSS, etc.) — pedir sempre decomposição estruturada antes de avançar para o significado global.
