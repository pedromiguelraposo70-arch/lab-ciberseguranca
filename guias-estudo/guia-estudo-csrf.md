# Guia de Estudo — CSRF (Cross-Site Request Forgery)

*Documento de consolidação do módulo CSRF do DVWA. Escrito para conseguir explicar isto a alguém sem ter o ecrã à frente. Inclui os acertos e enganos pelo caminho.*

---

## 1. O que é CSRF, em 30 segundos

"Cross-Site Request Forgery" = **falsificação de pedidos entre sites**. Um atacante consegue que o **browser da vítima** envie um pedido a um site onde ela já está autenticada (ex.: o DVWA), **sem ela saber e sem clicar em nada explícito para esse fim**.

**A mudança de paradigma face ao SQLi/Command Injection/XSS:** não há injeção de código nenhuma. O atacante não precisa de inserir nada no site vulnerável — só precisa de levar a vítima a visitar **outra** página (nem precisa de estar no mesmo site), que contenha um mecanismo que desencadeia o pedido escondido.

**Analogia (cartão de identificação automático):** a cookie de sessão da vítima é como um cartão de identificação que ela traz sempre consigo, sem pensar, e que abre a porta de um banco (o site vulnerável) sempre que se aproxima da fechadura — automaticamente, sem confirmação. O atacante convence a vítima a entrar numa "sala escondida" (a página maliciosa) que tem um mecanismo que a empurra até essa porta sem ela perceber. Como o cartão está sempre com ela, a porta abre, e o atacante já preparou o que acontece a seguir (ex.: mudar o código de acesso).

---

## 2. O mecanismo técnico

- A **cookie de sessão** é enviada automaticamente pelo browser em qualquer pedido ao site correspondente, independentemente de qual página ou elemento desencadeou esse pedido. O servidor não distingue "ação consciente do utilizador" de "pedido forjado escondido".
- Uma tag `<img src="...">` é o veículo mais simples: o browser tenta descarregar o que está nesse endereço, automaticamente, assim que a página carrega — sem precisar de clique. Não interessa que a resposta não seja mesmo uma imagem; o pedido já foi feito.
- Se o pedido vulnerável usar **método GET** (parâmetros visíveis no URL, como no DVWA Low), um simples `<img>` já é suficiente. Pedidos por **POST** exigem mecanismos um pouco mais elaborados (ex.: um formulário escondido que se autossubmete via JavaScript), mas continuam a ser possíveis.

---

## 3. Progressão dos níveis

- **Low (feito — Entrada #33):** sem token, sem verificação da password atual. Pedido por GET. Bastou um `<img>` a apontar para o URL de mudança de password, com uma password nova escolhida pelo atacante, aberto localmente num ficheiro HTML (simulando a página maliciosa). Login bem-sucedido com a nova password confirmou o ataque.
- **Medium (Entrada #34):** formulário sem campo "Current password" (diferente do Low), mas o ataque via `<img>` continua a funcionar sem alterações. Aberto o ficheiro via `file://` (sem cabeçalho Referer significativo), o que sugere que o Medium não impõe uma defesa eficaz baseada em Referer (não confirmado ao detalhe, sem ver o código-fonte).
- **High (Entrada #35):** verificação do cabeçalho Referer (confirma se o pedido veio de dentro do próprio site). Bypass: abrir o ficheiro malicioso via `file://` não envia Referer nenhum, e essa ausência não é tratada como suspeita — a verificação só cobre "Referer errado", não "Referer ausente". Lição: uma defesa pode ter lógica correta no caso esperado e falhar num caso-limite não previsto.
- **Impossible (Entrada #36):** confirmado — **tokens anti-CSRF** (mensagem "CSRF token is incorrect" para pedidos sem token válido) e reintrodução da verificação da password atual (que o Medium/High tinham dispensado). Primeiro teste deu um resultado enganador ("funcionou"), por contaminação do ambiente — password antiga preenchida automaticamente pelo browser no campo "Current password". Corrigido repondo a base de dados do DVWA e limpando as passwords guardadas no Firefox. Com ambiente limpo, o ataque **falhou** como esperado. **Fecha o módulo CSRF** (Low → Impossible).

---

## 4. Diferença face ao XSS (fio condutor entre os dois)

| | **XSS** | **CSRF** |
|---|---|---|
| Há injeção de código? | Sim — JavaScript corre no browser da vítima, dentro do site vulnerável | Não — nenhum código é injetado no site vulnerável |
| Onde vive o ataque | Dentro do site vulnerável (payload refletido/guardado/no DOM) | Fora do site vulnerável — numa página qualquer que a vítima visite |
| O que é explorado | Falta de tratamento do input mostrado na página | O facto de a cookie de sessão ser enviada automaticamente em qualquer pedido |
| Consequência típica | Roubo de sessão, ações em nome da vítima, várias | Ações específicas em nome da vítima (aqui: mudar password) |

**Ponto em comum:** os dois exploram a confiança automática do browser — no XSS, a confiança do site em mostrar input sem o tratar; no CSRF, a confiança do servidor em qualquer pedido que chegue com a cookie certa, sem verificar a sua origem.

---

## 5. Como nos podemos defender

- **CSRF tokens (defesa principal):** um valor secreto e único, gerado pelo servidor, incluído em cada formulário legítimo e verificado no momento de processar o pedido. O atacante, ao forjar um pedido de fora, não tem como incluir esse valor — o servidor recusa o pedido.
- **Verificar sempre dados sensíveis adicionais** (ex.: a password atual) antes de aceitar uma mudança — reduz o impacto mesmo sem eliminar a causa raiz.
- **Atributo SameSite na cookie:** pode impedir o browser de enviar a cookie de sessão em pedidos que se originam de outros sítios.
- **Usar POST para ações que alteram dados**, em vez de GET — dificulta ataques simples via `<img>`, embora não resolva sozinho (ainda é possível com formulários escondidos autossubmissos).

---

## 6. Estado de compreensão (honesto)

**2026-08-15:**
- Mecanismo geral do CSRF e o papel do `<img>`: **Sim** — por palavras próprias, com a analogia do cartão de identificação/porta do banco. Precisei de mais do que uma explicação técnica direta; só ficou claro com a analogia concreta.
- Diferença face ao XSS (injeção de código vs. aproveitar sessão existente): **Sim**.
- CSRF tokens como defesa principal: **Sim**, confirmado na prática no Impossible.
- **Módulo completo (Low → Impossible):** Sim. Lição adicional, fora da técnica pura: a importância de validar resultados surpreendentes em vez de os aceitar — o primeiro teste do Impossible deu um falso positivo por contaminação do ambiente (password guardada no browser), só corrigido ao questionar o resultado.
