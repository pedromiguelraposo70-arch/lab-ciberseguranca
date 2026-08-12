# Glossário

Termos técnicos usados ao longo do registo, explicados de forma simples. Atualizado incrementalmente — sempre que aparece um termo novo numa entrada, acrescenta-se aqui (por ordem alfabética).

**Base de dados** — sistema organizado para guardar, consultar e gerir dados de forma estruturada (ex: tabelas com linhas e colunas, como a tabela `users` da DVWA). Aplicações web normalmente comunicam com uma base de dados para guardar e recuperar informação (utilizadores, produtos, mensagens, etc.).

**Blacklist (lista negra)** — abordagem de segurança que tenta bloquear elementos *conhecidos como perigosos* (ex.: apagar os caracteres `;` e `&&` de um input). É frágil por natureza: é quase impossível listar tudo o que é perigoso, e basta esquecer um item para a defesa falhar — como se viu no Command Injection Medium do DVWA, que esqueceu o `|` e o `&`.

**Comentário em SQL (`#`, `--`)** — marca que diz à base de dados para ignorar tudo o que vem a seguir na linha. Em SQL Injection usa-se para "cortar" o resto da query original (ex.: anular um `LIMIT 1`), deixando ativa só a parte injetada.

**Container (Docker)** — ambiente isolado e leve que empacota uma aplicação com tudo o que precisa para correr, sem depender do sistema à volta.

**Cookie de sessão** — pequeno pedaço de dados guardado pelo browser que identifica uma sessão de utilizador autenticado num site.

**DHCP** — protocolo que atribui automaticamente um endereço IP a um dispositivo quando este se liga a uma rede.

**Escape de caracteres (`mysqli_real_escape_string`)** — função que "neutraliza" caracteres especiais como aspas, para impedir que quebrem uma query SQL. Defesa parcial e frágil: falha se a query não usar aspas à volta do input (como se viu no nível Medium do DVWA).

**Framework** — estrutura de código já pronta que fornece ferramentas, regras e organização base para construir uma aplicação, em vez de se escrever tudo do zero (ex: ligação à base de dados, gestão de formulários, autenticação). Muitos frameworks já incluem prepared statements "de série", mas isso não impede um programador de escrever queries manuais e inseguras dentro deles. Exemplos: Laravel, Django, Express, Spring. A DVWA não usa framework — é PHP "cru", escrito propositadamente sem essa camada, para expor o mecanismo das vulnerabilidades sem abstrações escondidas.

**HttpOnly (flag de cookie)** — definição que impede uma cookie de ser lida por JavaScript, protegendo contra roubo de sessão via XSS.

**Input baseado em sessão** — quando o valor submetido pelo utilizador é guardado na sessão (do lado do servidor) em vez de ser lido diretamente de cada pedido. No DVWA nível High, o ID é submetido numa janela separada e guardado na sessão, desacoplando o ponto de entrada do resultado — o que dificulta ataques automáticos.

**LAN Segment (VMware)** — rede virtual isolada dentro do VMware, que liga várias VMs entre si sem exposição à rede real.

**LIMIT (cláusula SQL)** — instrução que restringe o número de linhas devolvidas por uma query (ex.: `LIMIT 1` devolve só uma). No DVWA nível High serve de travão, contornado comentando-o com `#`.

**Menor privilégio (princípio do)** — dar a cada conta ou processo apenas as permissões mínimas de que precisa. Aplicado à conta de base de dados de uma aplicação, limita o estrago que um ataque bem-sucedido pode causar.

**NAT (Network Address Translation)** — mecanismo que traduz endereços entre redes. No lab, a interface NAT da Ubuntu Server (`ens37`, gama 192.168.203.x) é a usada para administração/SSH a partir do host, separada da rede isolada "Ciber".

**OWASP Top 10** — lista de referência das 10 categorias de vulnerabilidades mais críticas em aplicações web, mantida pela organização OWASP.

**Payload** — o conteúdo/texto enviado a uma aplicação para testar ou explorar o seu comportamento.

**Prepared statements / parameterized queries** — forma segura de construir queries SQL onde os dados do utilizador nunca são interpretados como código, só como valores.

**RCE (Remote Code Execution)** — execução de código ou comandos arbitrários numa máquina remota através de uma vulnerabilidade. É o impacto máximo de falhas como o Command Injection, porque dá controlo sobre o sistema operativo do servidor, não apenas sobre os dados.

**Reconhecimento (Reconnaissance)** — fase inicial de um teste de segurança, onde se recolhe informação sobre o alvo antes de qualquer tentativa de exploração.

**Restart policy** — configuração que define se/quando um container Docker deve reiniciar automaticamente.

**Snapshot (VMware)** — "fotografia" do estado de uma máquina virtual num dado momento, que permite reverter se algo correr mal. Tirado antes de cada exercício como ponto de retorno; convenção de nome com data e contexto (ex.: `2026-08-11_lab-estavel-base`).

**SQL (Structured Query Language)** — linguagem usada para comunicar com bases de dados relacionais: pedir dados (`SELECT`), inserir (`INSERT`), alterar (`UPDATE`) ou apagar (`DELETE`). É a linguagem que o SQL Injection explora, ao conseguir inserir comandos SQL não autorizados através de campos de input.

**Stale state** — quando um sistema guarda a mesma informação em mais do que um sítio, e nem todos são atualizados ao mesmo tempo, causando comportamento inconsistente.

**Tautologia** — no contexto de SQL Injection, uma condição que é sempre verdadeira por estrutura (ex. `1=1`), independentemente dos dados reais.

**Validação de input** — verificar que aquilo que o utilizador envia é do tipo e formato esperados (ex.: confirmar que um ID é mesmo um número inteiro) antes de o usar. Teria evitado o SQL Injection em todos os níveis.

**WAF (Web Application Firewall)** — camada de segurança que filtra pedidos a uma aplicação web à procura de padrões maliciosos conhecidos.

**Whitelist (lista branca)** — abordagem inversa da blacklist e mais robusta: em vez de bloquear o que é mau, só permite *exatamente o que é reconhecidamente seguro* (ex.: aceitar apenas dígitos e pontos de um IP válido, rejeitando tudo o resto). Não há como escapar, porque tudo o que não está expressamente permitido é recusado.
