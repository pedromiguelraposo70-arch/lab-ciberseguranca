# Playbook de Resposta a Incidentes — Web Shell / RCE via serviço mal configurado

**Estado:** Sessão 7.4 (Fase 7 — Blue Team). Construído a partir de um incidente real simulado no lab (Entrada #104), não escrito em teoria pura — cada fase tem uma checklist genérica reutilizável, seguida de como foi aplicada em concreto neste caso.

**Como usar este documento:** da próxima vez que houver um incidente a tratar a sério (real ou simulado) no laboratório, percorre as seis fases pela ordem (mais a Fase 2b, sempre que o incidente possa obrigar a notificar uma autoridade), usa as checklists genéricas como ponto de partida, e regista o que aconteceu de concreto tal como a secção "Aplicação — Entrada #104" faz aqui. Um playbook que nunca foi testado contra um caso real não vale nada — este já foi.

---

## Fase 1 — Detetar

**Checklist genérica:**
- Confirmar que existe mesmo um alerta/evento, não uma suposição.
- Registar o timestamp exato, a regra/fonte que gerou o alerta, e o nível de gravidade atribuído.
- Não assumir a causa só pelo nome da regra — isso é trabalho da Triagem, não da Deteção.

**Aplicação — Entrada #104 (2026-09-24):**
Alerta gerado pela regra Wazuh `100013` (nível 12, o mais alto do lab), ao repetir o pedido HTTP `GET /shell.php?cmd=whoami` a partir do Kali contra o Servidor Vulnerável. Confirmado no Dashboard (Threat Hunting → Events, filtro `agent.name: servidor-vulneravel and rule.id: 100013`): 1 hit, `Sep 24, 2026 @ 16:45:48`, MITRE `T1505.003` (Web Shell), tática **Persistence**.

---

## Fase 2 — Triar

**Checklist genérica:**
- Confirmar verdadeiro positivo (o alerta corresponde mesmo a atividade maliciosa, não é ruído).
- Identificar a origem exata (IP, utilizador, processo).
- Avaliar o âmbito: que sistemas/serviços estão envolvidos, há sinais de propagação.
- Cruzar a fonte primária (log em bruto) com o que o SIEM mostra — nunca confiar só no resumo processado.

**Aplicação — Entrada #104:**
Evento expandido no Dashboard confirmou `data.srcip: 192.168.10.10` (Kali), `data.url: /shell.php?cmd=whoami`, `full_log` com o pedido HTTP completo. Verificação cruzada: o `tail` do `/var/log/apache2/access.log` no próprio Servidor Vulnerável mostrou a mesma e única linha — confirma verdadeiro positivo, sem duplicação nem ambiguidade. Uma aparente inconsistência de tamanho de resposta (156 bytes no log vs. 9 bytes no `Content-Length` do `curl`) foi investigada e explicada (o `LogFormat` do Apache regista bytes totais incluindo cabeçalhos, não só o corpo) — não era um segundo pedido escondido. Âmbito: um único serviço (Apache na porta 8080, Servidor Vulnerável), sem indícios de movimento lateral nesta análise.

---

## Fase 2b — Avaliar obrigações de notificação e iniciar o relógio

*Acrescentada na Sessão 8.6 (Entrada #116), depois de se perceber que nenhuma das seis fases dizia quando e a quem notificar. Fazer logo a seguir a confirmar um verdadeiro positivo, em paralelo com a conteção, sem esperar pela investigação completa.*

**Checklist genérica:**
- Registar o **momento de conhecimento**: a hora exata em que o incidente foi confirmado. É daqui que contam os prazos, e não do início do ataque.
- **Decidir e escrever a decisão**, nos dois sentidos (quem decidiu, quando, com que fundamento): (a) é um incidente **significativo** (NIS2: perturbação operacional ou prejuízo financeiro graves, ou danos consideráveis a terceiros; basta que possa causar)? (b) é uma **violação de dados pessoais** (RGPD, artigo 4.º, n.º 12: acesso não autorizado a dados pessoais basta)?
- **Se a NIS2 se aplicar** (média empresa ou maior, em setor abrangido): notificar o **CNCS** pela plataforma **MyCiber**: alerta inicial em **24 h**; atualização em **72 h**; notificação do fim do impacto em **24 h** após o fim; relatório final em **30 dias úteis** (prazos segundo fontes secundárias; artigos a confirmar no texto oficial). As horas contam todos os dias, incluindo fins de semana.
- **Se houver dados pessoais:** avaliar o risco para as pessoas e notificar a **CNPD** até **72 h**, a menos que seja improvável que a violação resulte em risco; se o risco for elevado, avisar também os titulares (artigo 34.º). A informação pode ser dada por fases (artigo 33.º, n.º 4).
- **Registar sempre** os factos, os efeitos e as medidas de reparação, mesmo quando se decide não notificar (RGPD, artigo 33.º, n.º 5).
- O relatório final deve **referir as outras notificações feitas**.

**Aplicação — Entrada #116 (exercício hipotético sobre o incidente da Entrada #104):** a NIS2 não se aplicaria à empresa fictícia (microempresa), mas o incidente foi tratado como significativo por o servidor ser a "app + BD clientes", com execução remota de código e cerca de um mês de acesso sem deteção. Momento de conhecimento: alerta `100013` de 24/09, cerca das 16:45. Calendário: alerta inicial até 25/09 cerca das 16:45; atualização até 27/09 cerca das 16:45 (um domingo); fim do impacto depois de a causa estar corrigida e testada; relatório final cerca de 30 dias úteis depois. Como o servidor também tinha a base de dados de clientes, teria de se avaliar em paralelo a violação de dados pessoais (RGPD).

---

## Fase 3 — Conter

**Checklist genérica:**
- Parar o atacante de continuar a explorar, sem ainda apagar provas nem corrigir a causa raiz.
- Escolher entre conteção de rede (firewall/gateway) ou conteção no próprio host, consoante a topologia real.
- **Testar sempre que a conteção funcionou de facto** — não assumir que uma regra aplicada é uma regra eficaz.

**Aplicação — Entrada #104:**
Primeira tentativa: regra de bloqueio no OPNsense (Firewall → LAN), `Block` de `192.168.10.10` para `192.168.10.101`. **Falhou** — confirmado com um novo `curl` (ainda com `200 OK`) e depois com o Live View do OPNsense, que não mostrou nenhuma entrada de log para esse tráfego. Causa: o Kali e o Servidor Vulnerável estão no mesmo segmento L2 da VMware ("Ciber", um LAN Segment) e na mesma sub-rede `/24` — tráfego entre eles nunca atravessa o gateway, por isso uma regra na interface LAN do OPNsense não tem qualquer efeito. **Lição-chave para reutilizar:** uma regra de firewall de rede só protege tráfego que efetivamente passa pelo dispositivo — hosts no mesmo segmento/sub-rede comunicam diretamente entre si, sem verificação no meio.

Pivô: conteção ao nível do host, diretamente no Servidor Vulnerável — `sudo iptables -A INPUT -s 192.168.10.10 -p tcp --dport 8080 -j DROP`. Testado e confirmado: `curl` do Kali passou a dar timeout (`Ligação expirada`).

---

## Fase 4 — Erradicar

**Checklist genérica:**
- Antes de apagar qualquer artefacto, preservar evidência (hash, cópia).
- Nunca assumir que encontraste todos os artefactos maliciosos só por teres encontrado o óbvio — verificar sempre a pasta/sistema por inteiro.
- Corrigir a causa raiz, não só remover o sintoma — se o incidente resultou de mais do que uma falha empilhada, corrigir todas.

**Aplicação — Entrada #104:**
A pasta `/srv/ftp/upload/` continha **quatro** web shells, não um: `shell.php` (original, Entrada #60), `shell3.php`, `shell4.php`, `shell5.php`. Hashes SHA-256 confirmaram que `shell.php`, `shell4.php` e `shell5.php` são bit-a-bit o mesmo ficheiro reenviado em datas diferentes (22/08, 26/08, 19/09); `shell3.php` é uma variante distinta (`system()` em vez de `shell_exec()`). Todos preservados (cópia local) antes de apagados.

Causa raiz corrigida em duas camadas, refletindo a cadeia original de duas falhas empilhadas (Entrada #60):
1. **FTP anónimo de escrita desativado** — `anon_upload_enable=NO` e `anon_mkdir_write_enable=NO` em `/etc/vsftpd.conf`, serviço reiniciado. Leitura anónima mantida (não era o problema).
2. **Execução de PHP desativada na pasta de upload** — `php_admin_flag engine off` dentro do bloco `<Directory /srv/ftp/upload>` em `/etc/apache2/sites-available/000-default.conf`, defesa em profundidade (mesmo que a escrita anónima volte a ser mal configurada no futuro, um `.php` ali nunca mais seria executado).

---

## Fase 5 — Recuperar

**Checklist genérica:**
- Restaurar o serviço a um estado normal e utilizável.
- Confirmar que a correção resiste a um novo ataque real — não só que a conteção temporária continua ativa.
- Remover a conteção temporária quando a causa raiz já está corrigida (não fica lá para sempre sem motivo).

**Aplicação — Entrada #104:**
Regra `iptables` de conteção removida (`sudo iptables -D INPUT ...`), já não necessária com a causa raiz corrigida. Teste final, a partir do Kali, repetindo o ataque original do zero (login FTP anónimo + `put shell.php`): login aceite (leitura anónima continua a funcionar, como esperado), mas o upload devolveu `550 Permission denied`. **Confirma que a vulnerabilidade está mesmo corrigida na origem, não só temporariamente mascarada pelo bloqueio de IP.**

---

## Fase 6 — Lições aprendidas

**Checklist genérica:**
- O que correu bem, o que correu mal, o que faria diferente da próxima vez.
- Alguma lição é reutilizável fora deste incidente específico?

**Aplicação — Entrada #104:**
1. **Nunca assumir que uma regra de firewall de rede protege hosts no mesmo segmento L2** — testar sempre a eficácia real da conteção, com um novo pedido, antes de a dar como resolvida.
2. **Nunca assumir que encontraste todos os artefactos maliciosos só por teres encontrado o óbvio** — uma simples listagem da pasta revelou quatro web shells em vez de um.
3. **Uma cadeia de ataque com duas falhas empilhadas precisa de duas correções**, não uma — corrigir só o FTP, ou só a execução de PHP, teria deixado a outra metade da cadeia intacta.
4. Vale sempre a pena cruzar o log em bruto com o que o SIEM mostra antes de fechar a Triagem — apanhou-se e explicou-se uma aparente inconsistência que, não verificada, teria ficado como dúvida por resolver.
