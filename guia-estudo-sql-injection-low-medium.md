
## Comparação com outras injeções (contexto)

| | SQL Injection | Command Injection | XSS |
|---|---|---|---|
| O que é enganado | A base de dados | O sistema operativo do servidor | O browser de outro utilizador |
| Linguagem injetada | SQL | Comandos de shell | HTML/JavaScript |
| Onde executa | No servidor (base de dados) | No servidor (sistema operativo) | No cliente (browser da vítima) |
| Quem é a vítima direta | A aplicação/dados | O servidor inteiro | Outros utilizadores da aplicação |
| Impacto típico | Roubo/alteração de dados | Controlo do servidor | Roubo de sessão, phishing |
| Exemplo de payload | `' OR '1'='1` | `; whoami` | `<script>alert('hack')</script>` |

**Fio condutor**: em todos os casos, a causa raiz é a mesma — input do utilizador tratado como código, sem separação nem validação. O que muda é *quem interpreta* esse código: base de dados, sistema operativo, ou browser de outra pessoa.

## Nota metodológica pessoal

Não tenho background de programação, por isso tenho dificuldade em ler payloads de forma global — "de repente" — e perceber o que fazem. A abordagem que funciona para mim é decompor o payload símbolo a símbolo (ou pedaço a pedaço), perguntando "o que é que **esta parte específica** faz?", em vez de tentar interpretar a linha toda de uma vez.

Isto foi validado com o exercício do "espaço em branco" (substituição literal de `$id` na query), que ajudou a perceber o mecanismo de `' OR '1'='1` passo a passo antes de perceber o efeito final.

Aplica-se a qualquer payload novo daqui para a frente (Command Injection, XSS, etc.) — pedir sempre decomposição estruturada antes de avançar para o significado global.
