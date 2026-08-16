# Guia de Estudo — File Upload (Upload de Ficheiros sem Validação)

*Documento de consolidação do módulo File Upload do DVWA. Escrito para conseguir explicar isto a alguém sem ter o ecrã à frente. Inclui os acertos e enganos pelo caminho.*

---

## 1. O que é, em 30 segundos

Uma aplicação web permite o upload de ficheiros (ex.: fotos de perfil) mas **não verifica devidamente o que está a aceitar**. Se um atacante conseguir carregar um ficheiro executável (ex.: `.php`) para uma pasta que o servidor consegue **executar**, e depois visitar o URL desse ficheiro, o servidor corre o código como se fosse parte do site — dando **RCE (Remote Code Execution)** direto.

**Analogia (receção de encomendas):** imagina uma receção de um edifício cujo único trabalho é aceitar embrulhos e guardá-los num cacifo, sem verificar o conteúdo. Um atacante entrega um embrulho que, mal é aberto, liberta um controlo remoto sobre o próprio edifício. O cacifo é a pasta de uploads do servidor; o "embrulho perigoso" é uma **web shell** — um ficheiro `.php` com código malicioso, que dá controlo remoto assim que é aberto (executado).

**Ligação ao Command Injection:** o impacto final é o mesmo — RCE, correr comandos do sistema operativo à vontade. O que muda é o **canal de entrada**: no Command Injection é um campo de texto; aqui é um ficheiro carregado.

---

## 2. O mecanismo técnico

1. O servidor aceita o upload sem verificar o tipo real do ficheiro (só, talvez, olhar para o nome/extensão, se sequer isso).
2. O ficheiro fica guardado numa pasta acessível diretamente pelo browser (ex.: `hackable/uploads/`).
3. Se o ficheiro for `.php` (ou outra extensão executável no servidor), visitar o seu URL não "mostra o código como texto" — o servidor **executa** esse código.
4. Uma **web shell** simples explora um parâmetro do URL para correr comandos:
   ```php
   <?php system($_GET["cmd"]); ?>
   ```
   Visitar `http://alvo/uploads/shell.php?cmd=whoami` corre o comando `whoami` no servidor.

---

## 3. Progressão dos níveis

- **Low (feito — Entrada #37):** sem validação nenhuma. Upload de `shell.php` aceite sem restrições, guardado em `hackable/uploads/`, executado com sucesso (`www-data` confirmado via `?cmd=whoami`).
- **Medium/High/Impossible:** *(a fazer — a completar quando explorados.)*

---

## 4. Como nos podemos defender

- **Validação do tipo de ficheiro no servidor**, verificando o conteúdo real (não confiar só na extensão ou no cabeçalho MIME enviado pelo browser, que o atacante controla).
- **Whitelist de extensões permitidas** (ex.: só `.jpg`, `.png`, `.gif`), rejeitando tudo o resto.
- **Guardar ficheiros carregados fora da pasta acessível pelo browser**, ou configurar o servidor para nunca executar scripts nessa pasta.
- **Renomear os ficheiros ao guardá-los** (nomes aleatórios), dificultando adivinhar o URL.

---

## 5. Estado de compreensão (honesto)

**2026-08-16:**
- Que o problema não é "o upload em si" mas sim o servidor aceitar e depois **executar** um ficheiro perigoso: precisei de explicação direta — a intuição inicial ("o ficheiro seria intercetado/visto") estava errada.
- Ligação ao RCE do Command Injection (mesmo impacto, canal de entrada diferente): **Sim**, depois da explicação.
- Medium/High/Impossible: por fazer.
