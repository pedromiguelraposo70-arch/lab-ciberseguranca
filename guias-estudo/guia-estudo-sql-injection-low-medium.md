# Guia de Estudo — SQL Injection (Low vs. Medium)

*Documento para consolidar o que foi aprendido no Dia 1 e Dia 2, escrito para conseguires explicar isto a alguém sem teres o ecrã à frente. Inclui os enganos pelo caminho — fazem parte da aprendizagem, não são para esconder.*

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

## 5. A investigação (os enganos que valeram a pena)

- **Cookies duplicadas com paths diferentes** causaram comportamento inconsistente — lição: "stale state", quando um sistema guarda a mesma info em mais de um sítio
- **"Resend" do Firefox** repete dados da submissão anterior, não os atuais
- **Edições de HTML via DevTools são temporárias** — perdem-se em qualquer recarregamento
- **`curl` direto ao servidor** é uma forma mais rigorosa de confirmar uma vulnerabilidade do que testar via browser

---

## 6. Resumo para explicar a alguém em 60 segundos

> "Testei se uma aplicação web protegia bem o acesso à sua base de dados. No nível mais fraco, uma aspa mal tratada permitiu alterar a pergunta feita à base de dados. No nível seguinte, a aplicação tentou bloquear aspas, mas fê-lo removendo-as da query em vez de validar o tipo de dado — o que abriu uma porta ainda mais simples. A lição de fundo: nunca se confirmou que o ID recebido era mesmo um número."

---

## 7. Estado de compreensão (honesto, 2026-08-06)

Payload com aspas (Low): **Não**
Payload sem aspas (Medium): **Não**

Fica registado sem suavizar — dia longo, com muita fricção técnica antes de chegar aqui. Rever este guia com calma antes da próxima sessão.
