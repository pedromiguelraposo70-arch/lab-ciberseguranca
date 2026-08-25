# Guia de Estudo — File Inclusion (Inclusão de Ficheiros sem Validação)

*Documento de consolidação do módulo File Inclusion do DVWA. Escrito para conseguir explicar isto a alguém sem ter o ecrã à frente. Inclui os acertos e enganos pelo caminho. Módulo fechado (Low → Impossible).*

---

## 1. O que é, em 30 segundos

Uma aplicação web usa um parâmetro do URL para decidir que ficheiro incluir/mostrar (ex.: `page=include.php`), sem validar devidamente esse valor. Se o servidor não restringir isso, um atacante consegue apontar o parâmetro para outro ficheiro do próprio sistema — isso é **LFI (Local File Inclusion)** — ou, em servidores mais permissivos, até para um ficheiro alojado noutro sítio da rede — **RFI (Remote File Inclusion)**.

**Analogia (o porteiro que só olha para o nome no crachá):** imagina um porteiro que deixa entrar quem tiver um crachá que comece pela palavra "Convidado". Um atacante mostra um crachá que diz "Convidado — na verdade sou o gerente do prédio" e o porteiro, por só olhar ao início da frase, deixa passar. O crachá é o valor do parâmetro `page`; o porteiro é a validação (superficial) do servidor.

**Diferença face ao File Upload:** no File Upload, o atacante tinha de conseguir *colocar* um ficheiro perigoso no servidor primeiro. Aqui, não é preciso colocar nada — os ficheiros já lá estão (`/etc/passwd`, ficheiros de configuração, logs); o ataque é só sobre *conseguir apontar para eles*.

---

## 2. O mecanismo técnico

1. O servidor usa algo como `include($_GET['page']);` para decidir que conteúdo mostrar.
2. Sem validação, o valor de `page` pode ser qualquer caminho — relativo, absoluto, ou até um wrapper de protocolo do PHP (`file://`, `php://`, etc.).
3. Se o `include()` conseguir ler o ficheiro, o **conteúdo desse ficheiro é despejado na resposta** — e, neste DVWA, mesmo *antes* do HTML da página começar (`<!DOCTYPE html>`), porque o `include()` corre logo no início do script, antes de qualquer output ser gerado.

---

## 3. Progressão dos níveis

- **Low (feito — Entrada #41):** sem validação nenhuma.
  - Path traversal relativo (`../../../../etc/passwd`) **falhou** — não por defesa, mas porque a profundidade de pastas deste container Docker não corresponde ao número de `../` usado.
  - Caminho **absoluto** (`/etc/passwd`) funcionou de imediato. LFI confirmado.
  - **RFI verificado como impossível neste servidor**: `allow_url_include` está `Off` (Local e Master) na configuração do PHP — uma definição global do servidor, válida para todos os níveis de segurança, não só o Low.

- **Medium (feito — Entrada #42):** filtro típico do DVWA remove as strings `"http://"` e `"https://"` do valor de `page` — pensado para mitigar RFI, não LFI. O nosso caminho absoluto, sem esses prefixos, passou **sem qualquer alteração**. Resultado idêntico ao Low.

- **High (feito — Entrada #43):** verificação diferente e mais forte — `fnmatch("file*", $page)`, que só aceita valores cuja string comece literalmente por `"file"`. O caminho absoluto puro foi **bloqueado** (`ERROR: File not found!`). **Bypass encontrado:** o wrapper de stream do PHP `file://` também começa pela string `"file"` — `file:///etc/passwd` (três `/`) passa a mesma verificação de prefixo e devolve o ficheiro na mesma. High **comprometido por completo**.

- **Impossible (feito — Entrada #44):** deixa de usar verificação de prefixo e passa a uma **whitelist por igualdade exata** — só aceita valores literalmente iguais a `include.php`, `file1.php`, `file2.php` ou `file3.php`. O bypass `file:///etc/passwd`, que funcionava no High, foi **bloqueado** (`ERROR: File not found!`). Confirmado com um teste de controlo (`file1.php` continua a funcionar normalmente) que não é um bloqueio total do módulo — é seletivo. Módulo **fechado**.

---

## 4. Como nos podemos defender

- Nunca usar um parâmetro controlado pelo utilizador diretamente como caminho de ficheiro num `include()`/`require()`.
- **Whitelist por igualdade exata** dos valores permitidos (`in_array($page, ['file1.php','file2.php','file3.php'], true)`) — nunca verificação de prefixo/padrão (`fnmatch`, `strpos`), que pode ser enganada por wrappers de protocolo como `file://`.
- Resolver o caminho com `realpath()` e confirmar que fica dentro do diretório esperado, antes de incluir.
- Desativar `allow_url_include` no PHP (bloqueia RFI ao nível do motor, independentemente da aplicação) e restringir `open_basedir`.

---

## 5. Estado de compreensão (honesto)

**2026-08-17:**
- Diferença entre LFI e RFI, e porque é que o RFI depende de uma definição do PHP (`allow_url_include`) e não só do código da aplicação: **Sim**.
- Porque é que o traversal relativo falhou no Low sem ser uma defesa (é a estrutura de pastas do Docker, não um filtro): **Sim** — foi preciso confirmar via `curl` para não tirar conclusões erradas de um resultado ambíguo no browser.
- Porque é que o filtro do Medium (remover `"http://"`/`"https://"`) não afeta um caminho absoluto local: **Sim** — o filtro visa um vetor diferente (RFI), não o que estávamos a usar (LFI).
- Bypass do High via `file://` (confusão entre validação de prefixo de texto e o significado real do valor para o PHP): **Sim**, reconhecido como o mesmo princípio de falha já visto no MIME type do File Upload (Entrada #38) — validar a forma, não o significado.
- Nível Impossible (whitelist exata vs. verificação de prefixo do High): **Sim** — reforçado por testar, a par do payload, um valor legítimo (`file1.php`) para confirmar que a defesa é seletiva, não um bloqueio geral do módulo.

## 6. Encadeamento com File Upload (Entradas #45–#46)

O bypass `file://` do High não serve só para ler ficheiros do sistema — serve para **incluir e executar qualquer ficheiro que o atacante consiga colocar no servidor**. Combinado com o File Upload (Entrada #45): um ficheiro "polyglot" (imagem `.jpg` genuína, com payload PHP colado a seguir aos dados da imagem) passa a validação de upload do High, e a inclusão via `file://` executa o PHP escondido — RCE completo, sem nunca precisar de o ficheiro ser um `.php` "puro".

No **Impossible** (Entrada #46), o mesmo encadeamento **falha**: a whitelist exata só aceita `include.php`/`file1.php`/`file2.php`/`file3.php`, rejeitando o nome do ficheiro carregado — independentemente do que o File Upload aceitar. **Lição:** travar um elo forte de uma cadeia de ataque (aqui, o File Inclusion) neutraliza o conjunto, mesmo que outro elo (o File Upload) continue potencialmente fraco.

## 7. Balanço final

Low e Medium: LFI direto com caminho absoluto, sem qualquer esforço extra. High: comprometido via confusão de prefixo (`fnmatch("file*", ...)` engana-se com o wrapper `file://`). Impossible: resistiu por completo, com whitelist exata. RFI nunca foi possível em nenhum nível, por estar desligado ao nível do PHP (`allow_url_include=Off`), independentemente da aplicação — lição importante: nem toda a defesa observada é da aplicação, algumas são do ambiente.
