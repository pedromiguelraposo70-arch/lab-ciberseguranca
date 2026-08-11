# Glossário

Termos técnicos usados ao longo do registo, explicados de forma simples. Atualizado incrementalmente — sempre que aparece um termo novo numa entrada, acrescenta-se aqui.

**Cookie de sessão** — pequeno pedaço de dados guardado pelo browser que identifica uma sessão de utilizador autenticado num site.

**Comentário em SQL (`#`, `--`)** — marca que diz à base de dados para ignorar tudo o que vem a seguir na linha. Em SQL Injection usa-se para "cortar" o resto da query original (ex.: anular um `LIMIT 1`), deixando ativa só a parte injetada.

**Container (Docker)** — ambiente isolado e leve que empacota uma aplicação com tudo o que precisa para correr, sem depender do sistema à volta.

**DHCP** — protocolo que atribui automaticamente um endereço IP a um dispositivo quando este se liga a uma rede.

**HttpOnly (flag de cookie)** — definição que impede uma cookie de ser lida por JavaScript, protegendo contra roubo de sessão via XSS.

**Input baseado em sessão** — quando o valor submetido pelo utilizador é guardado na sessão (do lado do servidor) em vez de ser lido diretamente de cada pedido. No DVWA nível High, o ID é submetido numa janela separada e guardado na sessão, desacoplando o ponto de entrada do resultado — o que dificulta ataques automáticos.

**LAN Segment (VMware)** — rede virtual isolada dentro do VMware, que liga várias VMs entre si sem exposição à rede real.

**LIMIT (cláusula SQL)** — instrução que restringe o número de linhas devolvidas por uma query (ex.: `LIMIT 1` devolve só uma). No DVWA nível High serve de travão, contornado comentando-o com `#`.

**OWASP Top 10** — lista de referência das 10 categorias de vulnerabilidades mais críticas em aplicações web, mantida pela organização OWASP.

**Payload** — o conteúdo/texto enviado a uma aplicação para testar ou explorar o seu comportamento.

**Prepared statements / parameterized queries** — forma segura de construir queries SQL onde os dados do utilizador nunca são interpretados como código, só como valores.

**Reconhecimento (Reconnaissance)** — fase inicial de um teste de segurança, onde se recolhe informação sobre o alvo antes de qualquer tentativa de exploração.

**Restart policy** — configuração que define se/quando um container Docker deve reiniciar automaticamente.

**Stale state** — quando um sistema guarda a mesma informação em mais do que um sítio, e nem todos são atualizados ao mesmo tempo, causando comportamento inconsistente.

**Tautologia** — no contexto de SQL Injection, uma condição que é sempre verdadeira por estrutura (ex. `1=1`), independentemente dos dados reais.

**WAF (Web Application Firewall)** — camada de segurança que filtra pedidos a uma aplicação web à procura de padrões maliciosos conhecidos.
