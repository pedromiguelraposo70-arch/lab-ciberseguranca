# Guia de Estudo — Quadro Comparativo de Vulnerabilidades Web

*Documento de síntese transversal aos módulos do DVWA. Enquanto os outros guias aprofundam um tema, este junta-os e destaca o padrão que os une. Documento vivo — cresce à medida que se fecham módulos.*

*Foco central: **quem interpreta o input malicioso e onde o dano acontece.***

---

## Quadro comparativo

|  | **SQL Injection** | **Command Injection** | **XSS** |
|---|---|---|---|
| **O que é enganado** | A base de dados | O sistema operativo do servidor | O browser de outro utilizador |
| **Linguagem injetada** | SQL | Comandos de shell (bash, cmd) | HTML / JavaScript |
| **Onde executa** | No servidor (base de dados) | No servidor (sistema operativo) | No cliente (browser de quem vê a página) |
| **Quem é a vítima direta** | A aplicação / os dados | O servidor inteiro | Outros utilizadores da aplicação |
| **Impacto típico** | Roubo / alteração de dados | Controlo do servidor (shell, backdoor) | Roubo de sessão, phishing, ações em nome da vítima |
| **Exemplo de payload** | `' OR '1'='1` | `; whoami` | `<script>alert('hack')</script>` |

---

## A diferença mais importante para reter

**SQL Injection** e **Command Injection** acontecem no **servidor** — o ataque completa-se ali mesmo, sem precisar de mais ninguém envolvido.

**XSS** é diferente na estrutura toda: o payload fica guardado ou refletido na página, mas só "dispara" quando **outra pessoa (a vítima)** abre essa página no browser dela. Não se ataca o servidor — usa-se o servidor como **veículo** para atacar os utilizadores da aplicação. É por isso que o XSS tem 3 variantes (Reflected, Stored, DOM): a diferença entre elas é precisamente **como o payload chega até à vítima**.

---

## O fio condutor entre os três

Em todos os casos, a causa raiz é a mesma: **input do utilizador tratado como código, sem separação nem validação.** O que muda é só **quem interpreta** esse código — a base de dados, o sistema operativo, ou o browser de outra pessoa.

E as defesas espelham este fio condutor: em todos, a solução passa por **separar dado de código** e por **validar/tratar o input** — prepared statements no SQLi (o dado nunca vira SQL), whitelist no Command Injection (só se aceita o formato válido), e output encoding no XSS (o `<script>` é mostrado como texto, não executado).

---

## Nem todos os saltos de nível são iguais

Um padrão que se repetiu em SQL Injection, Command Injection e XSS: Medium e High são a **mesma categoria de falha** (uma blacklist, mais ou menos esperta), e passar de um para o outro é só um reforço do mesmo tipo de filtro — o método de ataque mantém-se, só precisa de um payload ligeiramente diferente.

O **File Upload** quebrou este padrão (Entrada #39): o bypass do Medium (forjar o MIME type com um comando `curl`) deixa de funcionar por completo no High, que passa a verificar a extensão do ficheiro e o conteúdo real. Um compromisso completo do High parece exigir **encadear outra vulnerabilidade** (File Inclusion), não apenas mais esforço no mesmo tipo de ataque.

**Lição:** ao subir de nível, vale a pena perguntar não só "isto é mais difícil de contornar?", mas também "isto ainda é o mesmo tipo de ataque, ou preciso de mudar de estratégia por completo?". Nem sempre é "mais um degrau da mesma escada" — às vezes é preciso mudar de escada.

---

*Módulos já cobertos neste quadro: SQL Injection (Entradas #10–16), Command Injection (#17–20), XSS — Reflected/Stored/DOM (#21–32), CSRF (#33–36), File Upload — Low a Impossible (#37–40, com High/Impossible pendentes de encadeamento com File Inclusion). A atualizar à medida que se avança no roteiro.*
