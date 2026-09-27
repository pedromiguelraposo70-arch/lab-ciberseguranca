# Fase 4 — Exploração de rede e serviços (Entradas #57–#65)

## Ficha: isolamento do host face à rede "Ciber" (Entrada #58)

**1. Configuração de rede atual:** a rede "Ciber" do VMware é do tipo *Private Network*, um tipo mais recente que isola a rede também do próprio computador físico (host) — só as VMs ligadas a ela, incluindo o Kali, conseguem interagir entre si.

**2. Porque é relevante:** ao contrário do resto desta fase (vulnerabilidades exploradas de dentro da rede), este é um facto de rede que **limita** o alcance de qualquer ataque a partir de fora — mesmo o computador físico onde tudo corre não consegue, por si só, tocar nas VMs do lab sem passar pelo Kali.

**3. O que seria diferente noutra configuração:** com uma rede "Custom" clássica do VMware (em vez de "Private Network"), o host teria acesso direto às VMs, o que quebraria a premissa de que o Kali é o único ponto de entrada simulado — mudaria o modelo de ameaça do próprio lab.

**4. Que defesa de rede isto exemplifica:** segmentação por desenho, aplicada mesmo ao nível da própria plataforma de virtualização — o mesmo princípio (isolar um segmento sensível até de quem o administra) que sustenta arquiteturas de rede zero-trust em ambientes reais.

## Ficha: serviços de rede com acesso anónimo/fraco (FTP, Samba, MariaDB — Entradas #59, #64, #65)

**1. Configuração de rede atual:** três serviços instalados manualmente (não Docker) no Servidor Vulnerável, cada um com uma variante do mesmo erro: `vsftpd` com `anonymous_enable=YES` + `anon_upload_enable=YES` (login e escrita sem credenciais); Samba com uma partilha `[publico]` `guest ok = yes` + `read only = no`; MariaDB com `bind-address` alterado de `127.0.0.1` para `0.0.0.0` e um utilizador `dbadmin`/`admin123` acessível de qualquer host (`'dbadmin'@'%'`).

**2. Porque permitiu o ataque:** em nenhum dos três casos há uma falha de software — é sempre uma decisão de configuração que remove a barreira de autenticação ou expõe o serviço além do necessário. A rede em si (Kali e alvo na mesma sub-rede, sem firewall nesta fase) só torna esse acesso possível de imediato, sem nenhum obstáculo a atravessar.

**3. O que seria diferente noutra configuração:** com o `bind-address` do MariaDB mantido em `127.0.0.1` (só acesso local), o Kali nunca conseguiria sequer tentar uma ligação de rede à base de dados, independentemente da força da password. Com uma regra de firewall a restringir o acesso FTP/Samba só a IPs de administração conhecidos, o acesso anónimo deixaria de ser alcançável a partir do Kali, mesmo estando ativado no serviço.

**4. Que defesa de rede o impediria:** este é o ponto de partida direto para o hardening que só chega na Fase 5 — egress/ingress filtering por IP e por porta no OPNsense. Antes da Fase 5, nada na rede limitava quem podia alcançar estes serviços; a defesa real (aplicada depois) é exatamente essa: nenhum destes serviços deveria estar acessível a partir de uma origem que não precisa de lá chegar.

## Ficha: a cadeia FTP anónimo + Apache = RCE (Entrada #60)

**1. Configuração de rede/infraestrutura atual:** um Apache autónomo montado a apontar para a mesma pasta usada pelo upload anónimo do FTP (`/srv/ftp/upload`), servido numa porta separada (8080) do DVWA (porta 80).

**2. Porque permitiu o ataque:** a decisão de fazer coincidir a pasta de upload (FTP) com uma pasta servida pela web (Apache) transforma duas falhas médias (upload sem autenticação + execução de PHP nessa pasta) numa única falha crítica (RCE completo). Isto repete-se, ao nível de rede, o mesmo padrão já visto na Fase 2 com o encadeamento File Upload + File Inclusion — só que aqui a "rede" (que pasta está exposta a quem) é literalmente o mecanismo do ataque.

**3. O que seria diferente noutra configuração:** com a pasta de upload do FTP fora da árvore servida pelo Apache (ou com execução de PHP desativada nessa pasta, como a Fase 7 acaba por corrigir na Entrada #104), o ficheiro `.php` enviado por FTP nunca seria executado — ficaria só um ficheiro inerte no disco.

**4. Que defesa de rede/infraestrutura o impediria:** separar fisicamente as pastas de upload das pastas servidas pela web, e desativar execução de código do lado do servidor em qualquer pasta de upload — exatamente a correção de causa raiz aplicada, quase dois meses depois, na Fase 7 (Entrada #104), quando este mesmo cenário é usado para praticar resposta a incidentes.

## Pontos de vídeo candidatos

- **Hardening de serviços de rede legados (FTP/Samba)** — um vídeo sobre alternativas modernas (SFTP em vez de FTP, autenticação Kerberos no Samba) complementaria diretamente esta fase, com teste de configuração nas VMs correspondentes.
- Ligação direta ao complemento já identificado na Fase 5 (auditd + Wazuh, Entrada #86) — o mesmo cenário de ataque desta fase (FTP → RCE) é o que fica sem deteção de execução de comandos; um vídeo sobre isso serve as duas fases ao mesmo tempo.
