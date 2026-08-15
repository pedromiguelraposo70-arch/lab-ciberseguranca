# Guia de Estudo — XSS (Cross-Site Scripting)

*Documento de consolidação do módulo XSS do DVWA. Um guia por classe de vulnerabilidade — este cobre as três variantes (Reflected, Stored, DOM) e todos os níveis. Escrito para conseguir explicar isto a alguém sem ter o ecrã à frente. Inclui os acertos e enganos pelo caminho.*

---

## 1. O que é XSS, em 30 segundos

Uma aplicação web inclui o input do utilizador numa página **sem o tratar**, permitindo injetar código (tipicamente JavaScript) que corre no **browser de quem abre a página**.

**A mudança de paradigma:** no SQL Injection e no Command Injection, a vítima era o **servidor** (base de dados ou sistema operativo). No XSS, a vítima é **outro utilizador** — o servidor é apenas o veículo para lhe chegar o código. Um atacante pode roubar a cookie de sessão da vítima (*session hijacking*), redirecioná-la, agir em nome dela, etc.

**A causa raiz é a mesma de sempre:** input tratado como código, sem separação. O que muda é *quem interpreta* — aqui, o browser da vítima.

---

## 2. Quadro comparativo — Reflected vs Stored vs DOM

| | **Reflected** | **Stored** | **DOM** |
|---|---|---|---|
| **Onde vive o payload** | No pedido (URL); refletido de imediato, não é guardado | Guardado no servidor (base de dados) | Nunca é guardado; manipulado pelo JavaScript no próprio browser |
| **Como chega à vítima** | O atacante engana a vítima a clicar num link preparado | A vítima só tem de **visitar** a página — o payload já lá está | Um link/estado que o JavaScript da própria página processa |
| **Quem é a vítima** | Quem clicar no link | **Todos** os que visitam a página | Quem abrir o link/estado manipulado |
| **Passa pelo servidor?** | Sim (o servidor reflete-o na resposta) | Sim (guarda e devolve a todos) | **Pode não passar** — o payload é tratado só no browser |
| **Gravidade** | Média (precisa de engano por vítima) | **Alta** (uma injeção, muitas vítimas, persistente) | Variável; difícil de detetar do lado do servidor |

**A diferença essencial:** é **onde o payload vive** e **como chega à vítima**. Reflected = passageiro no URL; Stored = guardado no servidor para todos; DOM = processado no browser, muitas vezes sem o servidor sequer ver.

**Alcance e deteção, na prática:** Stored é geralmente o mais perigoso, porque atinge todos os visitantes automaticamente, sem esforço extra do atacante depois de o payload ficar gravado — um comentário malicioso infeta toda a gente que ler a página, indefinidamente. Reflected é mais limitado, porque depende de convencer a vítima a clicar num link específico (normalmente via phishing) — exige esforço ativo por cada vítima. DOM tem alcance parecido ao Reflected (também depende de um link/ação da vítima, na maioria dos casos), mas é mais difícil de detetar e defender, porque o payload **pode nunca passar pelo servidor** — ferramentas de segurança que analisam tráfego do servidor não o veem.

---

## 3. Reflected (feito — Entradas #21 a #24)

O input viaja no URL (`?name=...`) e é "refletido" de volta na resposta, de imediato. Num ataque real, o atacante põe o payload num **link** e engana a vítima a clicar; o script corre na sessão dela.

Progressão dos níveis:
- **Low:** sem defesa. `<script>alert('XSS')</script>` executa. Com `<script>alert(document.cookie)</script>` foi possível **ler a cookie de sessão** (porque não tinha HttpOnly — já detetado no nmap da Entrada #8).
- **Medium:** blacklist que apaga a string `<script>`. Contornado com `<img src=x onerror=alert('XSS')>` — **o XSS não vive só de `<script>`**; há event handlers (`onerror`, `onclick`...) que correm JavaScript a partir de outras etiquetas.
- **High:** blacklist mais esperta (apanha "script" em qualquer combinação de maiúsculas/minúsculas), mas continua cega a outras etiquetas — o `<img onerror>` **ainda passa**.
- **Impossible:** **output encoding**. O input é mostrado como **texto** (`<` vira `&lt;`), nunca executado. Incontornável, porque trata tudo como texto por defeito.

---

## 4. Stored (feito — Entradas #25 a #28)

O payload é **guardado no servidor** (ex.: numa mensagem de livro de visitas) e devolvido a **todos** os visitantes, executando no browser de cada um, **a cada visita**.

Interface diferente do Reflected (livro de visitas com Name + Message + lista de mensagens) **de propósito**: imita os sítios reais onde o input é guardado e mostrado a outros — comentários, fóruns, avaliações, perfis. O Reflected imita sítios que ecoam o input de imediato (pesquisas, URLs).

- **Low:** `<script>alert('XSS')</script>` no campo Message fica guardado; na lista aparece com a mensagem **vazia** (script como código, invisível) e dispara a cada visita.
- **Medium:** blacklist igual à do Reflected Medium (apaga só a string `<script>`). O payload do Low fica neutralizado (sobra texto solto `alert('XSS')`, sem executar). Bypass igual ao do Reflected: `<img src=x onerror=alert('XSS')>` — não contém `<script>`, escapa ao filtro, fica guardado e dispara em todas as visitas. **Nota prática:** o campo Message tem um contador de caracteres em JavaScript que reflete o input no DOM em tempo real — pode disparar um popup *do lado do cliente* antes mesmo de guardar; não confundir com o resultado real do filtro do servidor (só se confirma após guardar e recarregar a página).
- **High:** blacklist case-insensitive (apanha "script" em qualquer combinação de maiúsculas/minúsculas, ex: `<ScRiPt>`), mas continua cega a `onerror` — o bypass do Medium (`<img src=x onerror=alert('XSS')>`) passa sem alterações. Mesmo padrão do Reflected High: reforçar a blacklist não resolve o problema de fundo.
- **Impossible:** output encoding, igual ao Reflected — o payload é mostrado sempre como texto (`<` → `&lt;`, `>` → `&gt;`), nunca executado. **Detalhe importante:** o encoding acontece **no momento de mostrar**, não altera o que está guardado na base de dados — por isso até payloads antigos, guardados em níveis mais fracos, passam a aparecer como texto inofensivo assim que vistos através do código Impossible.

**Porque é o mais perigoso:** no Reflected é preciso enganar cada vítima uma a uma; no Stored injeta-se **uma vez** e a armadilha apanha todos os visitantes, automaticamente.

**Padrão confirmado entre variantes:** Reflected e Stored seguem exatamente a mesma progressão de defesas nível a nível (Low sem defesa, Medium blacklist simples, High blacklist case-insensitive, Impossible output encoding). A variante determina *onde* o payload vive e *quem* atinge; não determina *como* a aplicação se defende — o problema de fundo (input tratado como código) e a correção (tratá-lo sempre como texto na saída) são os mesmos nos dois casos.

**Low/Medium/High vs. Impossible — uma distinção conceptual:** os três primeiros níveis são a mesma categoria de falha (blacklist), com o esforço necessário do atacante a variar consoante o filtro é mais ou menos esperto. O Impossible não é "mais difícil de contornar" — é uma mudança de categoria: deixa de haver lista para escapar, porque a transformação (encoding) se aplica sempre, seja qual for a forma do ataque. Distingue "quão difícil é o ataque" (função do atacante) de "é estruturalmente possível, sim ou não" (função da arquitetura).

---

## 5. DOM (feito Low — Entrada #29)

O DOM-based XSS acontece **inteiramente no browser**: o JavaScript da própria página lê um dado que o atacante controla (a **source** — ex.: o URL) e escreve-o na página sem o tratar, num ponto onde isso pode executar código (o **sink** — ex.: `document.write()`, `innerHTML`). O servidor devolve sempre a mesma página HTML estática, faça-se o pedido que se fizer — quem processa e executa o payload é só o browser.

No DVWA, o módulo é um seletor de idioma. O parâmetro `default` no URL (`?default=English`) é lido pelo JavaScript e usado para montar a lista de opções do dropdown. Isto é a source. A escrita desse valor na página, sem tratamento, é o sink.

- **Low:** sem defesa nenhuma. `http://.../xss_d/?default=<script>alert('XSS')</script>` dispara o popup ao carregar a página. O dropdown fica vazio (o payload não é um idioma válido), mas o script já correu antes disso.
- **Medium (parcial — Entrada #30):** `<script>` bloqueado por redirecionamento do servidor (filtro geral do DVWA, aplicado a vários módulos). `<img src=x onerror=...>` não é redirecionado, mas também não dispara — hipótese (não confirmada) é que o valor é escrito dentro de uma tag `<option>`, que só aceita texto, descartando elementos aninhados como `<img>`. Tentativa de fechar a tag primeiro (`</option><img...>`) também não disparou. Mecanismo exato por confirmar (ver Entrada #30 para o processo de investigação e a distinção entre "View Source" e o DOM real via Inspetor/Consola).
- **High (Entrada #31):** comporta-se exatamente como o Medium (mesmo redirecionamento para `<script>`/`<ScRiPt>`, mesma falha do `<img onerror>`). Diferente do padrão dos outros módulos, onde o High trazia sempre uma melhoria sobre o Medium — aqui não há diferença observável entre os dois níveis.
- **Impossible (Entrada #32):** o valor do URL nunca é decodificado de volta — fica como texto codificado (`%3Cscript%3E...`), opaco e inofensivo. Via diferente do output encoding do Reflected/Stored (que escapa `<` para `&lt;`), mas mesmo princípio de fundo: nunca deixar o valor do atacante ser interpretado como código. Fecha o módulo XSS DOM e, com ele, o XSS por completo (Reflected + Stored + DOM, todos Low → Impossible).

**Detalhe confirmado na prática:** neste módulo do DVWA o payload viaja no URL como parâmetro normal (`?default=`), não como `#` (`location.hash`) — ao contrário do que a teoria inicial deste guia previa. A distinção essencial mantém-se de qualquer forma: seja `?parametro=` ou `#hash`, o que importa é que o **servidor nunca examina nem reflete o valor** — o processamento é inteiramente feito pelo JavaScript do lado do cliente. Isto explica também porque é mais difícil de detetar: ferramentas que analisam tráfego/logs do servidor não veem o payload ser interpretado como código, porque essa interpretação nunca chega ao servidor.

---

## 6. Como nos podemos defender (as três)

- **Output encoding / escaping (defesa principal):** escapar o input ao mostrá-lo, para o browser o tratar como texto. No Reflected/Stored é feito no servidor ao gerar a página; no DOM tem de ser feito **no próprio JavaScript** (usar APIs seguras como `textContent` em vez de `innerHTML`).
- **Content Security Policy (CSP):** restringe que scripts o browser pode executar.
- **HttpOnly** na cookie de sessão: impede o JavaScript de a ler, mitigando o roubo de sessão mesmo que um XSS exista.
- **Validação/sanitização de input** como reforço.

---

## 7. Estado de compreensão (honesto)

**2026-08-15:**
- Diferença entre Reflected e Stored (onde vive o payload, quem dispara, quantas vezes), e porque é que o Stored é o mais perigoso: **Sim** — por palavras minhas.
- Que o XSS não vive só de `<script>` (event handlers como `onerror`): **Sim**.
- Output encoding como defesa correta vs blacklist: **Sim**.
- **DOM (Low), confirmado na prática:** diferença entre Reflected e DOM (ambos usam o URL, mas em Reflected o servidor reflete o valor, e em DOM o JavaScript do browser é que o lê e escreve, sem o servidor alguma vez o processar), e o conceito de source/sink: **Sim** — por palavras próprias. Corrigi pelo caminho uma previsão errada (achei inicialmente que o Low "não ia disparar", inversão da lógica correta).
- **DOM Medium/High:** confirmado que Medium e High se comportam de forma idêntica neste DVWA (sem a progressão habitual). O mecanismo exato da falha do `<img onerror>` ficou como hipótese razoável, não confirmada ao detalhe (limitação honesta, por dificuldades com o DevTools).
- **DOM Impossible:** confirmado — não decodificar o valor original como defesa. **Módulo XSS completo** (Reflected + Stored + DOM, Low → Impossible).
- Criar payloads do zero: **em progresso** — dependo de decomposição peça a peça (ver nota metodológica no guia do SQL Injection). Objetivo de repetição.
