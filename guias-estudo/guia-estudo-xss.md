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

---

## 3. Reflected (feito — Entradas #21 a #24)

O input viaja no URL (`?name=...`) e é "refletido" de volta na resposta, de imediato. Num ataque real, o atacante põe o payload num **link** e engana a vítima a clicar; o script corre na sessão dela.

Progressão dos níveis:
- **Low:** sem defesa. `<script>alert('XSS')</script>` executa. Com `<script>alert(document.cookie)</script>` foi possível **ler a cookie de sessão** (porque não tinha HttpOnly — já detetado no nmap da Entrada #8).
- **Medium:** blacklist que apaga a string `<script>`. Contornado com `<img src=x onerror=alert('XSS')>` — **o XSS não vive só de `<script>`**; há event handlers (`onerror`, `onclick`...) que correm JavaScript a partir de outras etiquetas.
- **High:** blacklist mais esperta (apanha "script" em qualquer combinação de maiúsculas/minúsculas), mas continua cega a outras etiquetas — o `<img onerror>` **ainda passa**.
- **Impossible:** **output encoding**. O input é mostrado como **texto** (`<` vira `&lt;`), nunca executado. Incontornável, porque trata tudo como texto por defeito.

---

## 4. Stored (feito Low — Entrada #25)

O payload é **guardado no servidor** (ex.: numa mensagem de livro de visitas) e devolvido a **todos** os visitantes, executando no browser de cada um, **a cada visita**.

Interface diferente do Reflected (livro de visitas com Name + Message + lista de mensagens) **de propósito**: imita os sítios reais onde o input é guardado e mostrado a outros — comentários, fóruns, avaliações, perfis. O Reflected imita sítios que ecoam o input de imediato (pesquisas, URLs).

- **Low:** `<script>alert('XSS')</script>` no campo Message fica guardado; na lista aparece com a mensagem **vazia** (script como código, invisível) e dispara a cada visita.
- **Medium:** blacklist igual à do Reflected Medium (apaga só a string `<script>`). O payload do Low fica neutralizado (sobra texto solto `alert('XSS')`, sem executar). Bypass igual ao do Reflected: `<img src=x onerror=alert('XSS')>` — não contém `<script>`, escapa ao filtro, fica guardado e dispara em todas as visitas. **Nota prática:** o campo Message tem um contador de caracteres em JavaScript que reflete o input no DOM em tempo real — pode disparar um popup *do lado do cliente* antes mesmo de guardar; não confundir com o resultado real do filtro do servidor (só se confirma após guardar e recarregar a página).
- **High:** blacklist case-insensitive (apanha "script" em qualquer combinação de maiúsculas/minúsculas, ex: `<ScRiPt>`), mas continua cega a `onerror` — o bypass do Medium (`<img src=x onerror=alert('XSS')>`) passa sem alterações. Mesmo padrão do Reflected High: reforçar a blacklist não resolve o problema de fundo.
- **Impossible:** *(a fazer — a completar quando explorado.)*

**Porque é o mais perigoso:** no Reflected é preciso enganar cada vítima uma a uma; no Stored injeta-se **uma vez** e a armadilha apanha todos os visitantes, automaticamente.

---

## 5. DOM *(conceptual — teoria a confirmar na prática)*

*Ainda não explorado. Descrição a validar quando fizer o exercício.*

O DOM-based XSS acontece **inteiramente no browser**: o JavaScript da própria página vai buscar dados a uma fonte que controla (ex.: a parte do URL a seguir a `#`, o `location.hash`, ou um parâmetro) e escreve-os na página (um "sink" como `innerHTML` ou `document.write`) **sem os tratar**. 

O detalhe que o torna especial: o payload **pode nunca ser enviado ao servidor** (por exemplo, o que vem depois de `#` no URL não chega ao servidor). Consequência: as defesas e os logs do lado do servidor **nem o veem** — é mais difícil de detetar. No DVWA, o exemplo típico é um seletor de idioma que lê um parâmetro do URL e o injeta na página via JavaScript.

*(Refinar esta secção após o exercício, com o payload real e os níveis.)*

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
- **DOM:** ainda **teoria** — por confirmar na prática. A rever esta secção depois do exercício.
- Criar payloads do zero: **em progresso** — dependo de decomposição peça a peça (ver nota metodológica no guia do SQL Injection). Objetivo de repetição.
