# Glossário

Termos técnicos usados ao longo do registo, explicados de forma simples. Atualizado incrementalmente — sempre que aparece um termo novo numa entrada, acrescenta-se aqui (por ordem alfabética).

**Account Lockout Policy (Política de bloqueio de conta)** — conjunto de definições do Active Directory que bloqueia automaticamente uma conta de utilizador depois de um número definido de tentativas de login falhadas seguidas (no lab, 5 tentativas, com bloqueio de 30 minutos). Configurada na `Default Domain Policy` e testada na prática na Entrada #74, forçando o bloqueio da conta `uteste` — é uma das defesas mais diretas contra ataques de força bruta, ligando diretamente à Fase 2 do projeto.

**Active Directory (AD)** — serviço da Microsoft para gerir, de forma centralizada, os utilizadores, computadores e permissões de uma rede Windows. Organiza tudo num *domínio* (no lab, `lab.local`), gerido por um ou mais Controladores de Domínio. É a espinha dorsal da identidade na maioria das redes empresariais — e, por isso, um alvo central em ataques reais.

**AD DS (Active Directory Domain Services)** — o papel (role) do Windows Server que implementa o Active Directory. Instalado com `Install-WindowsFeature -Name AD-Domain-Services` (Entrada #67) antes de o servidor poder ser promovido a Controlador de Domínio com `Install-ADDSForest`.

**AES (Advanced Encryption Standard)** — no contexto Kerberos, o tipo de cifra mais recente e forte usado para proteger tickets (em contraste com o RC4-HMAC, mais antigo e mais fraco). Um domínio que ainda emite tickets em RC4-HMAC fica mais exposto a Kerberoasting, porque esse tipo de cifra é significativamente mais rápido de quebrar offline (Entrada #91).

**Agente (Wazuh)** — pequeno programa instalado em cada máquina monitorizada (`wazuh-agent`) que recolhe eventos localmente (logs, alterações de ficheiros, eventos do Sysmon, etc.) e os envia cifrados ao Wazuh Manager. Cada agente regista-se junto do manager através de um processo de *enrollment*, que gera uma chave única guardada em `client.keys` (ex.: `001 servidor-vulneravel`, `004 windows11`). Um agente "reaproveitado" de outra instalação pode trazer configuração e chaves antigas residuais, como se viu na Entrada #85.

**AS-REP Roasting** — ataque Kerberos que, ao contrário do Kerberoasting, não exige qualquer credencial de domínio válida: basta o nome de uma conta com a pré-autenticação desativada (`DoesNotRequirePreAuth`). O atacante pede diretamente a resposta inicial de autenticação (AS-REP) para essa conta, que vem cifrada com um hash derivado da sua password, e tenta quebrá-lo offline — tal como no Kerberoasting, sem gerar tentativas de login falhadas. Demonstrado na Entrada #92.

**Atributo de evento HTML (`onerror`, `onclick`, `onload`...)** — mecanismo do HTML que diz ao browser para executar código quando algo acontece (uma imagem falha a carregar, um elemento é clicado, a página termina de carregar, etc.). Usado em XSS para correr JavaScript sem precisar da tag `<script>` — ex.: `<img src=x onerror=alert('XSS')>` explora a falha de carregamento da imagem para disparar o código, contornando blacklists que só vigiam a palavra `<script>`.

**Base de dados** — sistema organizado para guardar, consultar e gerir dados de forma estruturada (ex: tabelas com linhas e colunas, como a tabela `users` do DVWA). Aplicações web normalmente comunicam com uma base de dados para guardar e recuperar informação (utilizadores, produtos, mensagens, etc.).

**Bind (LDAP)** — o processo de autenticação de um cliente junto de um servidor LDAP antes de poder consultar o diretório. Um "bind anónimo" tenta fazer isto sem credenciais; nos Windows Server modernos vem desativado por defeito, como se confirmou na Fase 6.1 do lab (`ldapsearch` recusado com "successful bind must be completed").

**Blacklist (lista negra)** — abordagem de segurança que tenta bloquear elementos *conhecidos como perigosos* (ex.: apagar os caracteres `;` e `&&` de um input). É frágil por natureza: é quase impossível listar tudo o que é perigoso, e basta esquecer um item para a defesa falhar — como se viu no Command Injection Medium do DVWA, que esqueceu o `|` e o `&`.

**BloodHound** — ferramenta que recolhe informação do Active Directory (via um *collector*, como o `bloodhound-python` ou o SharpHound) e desenha-a como um grafo de relações — que grupos, permissões e sessões ligam cada objeto a outro — para visualizar rapidamente caminhos de ataque possíveis até contas privilegiadas (ex.: Domain Admin), algo muito difícil de ver "à mão" com os comandos nativos do AD. Usa uma base de dados de grafos (Neo4j) para armazenar e consultar essas relações.

**Comentário em SQL (`#`, `--`)** — marca que diz à base de dados para ignorar tudo o que vem a seguir na linha. Em SQL Injection usa-se para "cortar" o resto da query original (ex.: anular um `LIMIT 1`), deixando ativa só a parte injetada.

**Container (Docker)** — ambiente isolado e leve que empacota uma aplicação com tudo o que precisa para correr, sem depender do sistema à volta.

**Controlador de Domínio (Domain Controller, DC)** — servidor Windows que corre o Active Directory e valida os inícios de sessão do domínio. Guarda a base de dados de contas e aplica as políticas de segurança (GPOs). Precisa de um IP estável e de ser o servidor de DNS dos clientes do domínio, para que estes o consigam localizar (mudar o IP de um DC sem atualizar o DNS dos clientes parte o domínio).

**Cookie de sessão** — pequeno pedaço de dados guardado pelo browser que identifica uma sessão de utilizador autenticado num site.

**CSRF (Cross-Site Request Forgery)** — falsificação de pedidos entre sites. Um atacante leva a vítima (já autenticada num site) a visitar outra página que, sem ela saber, desencadeia um pedido a esse site — aproveitando que o browser envia a cookie de sessão automaticamente em qualquer pedido, independentemente de qual página o desencadeou. Ao contrário do XSS, não há injeção de código nenhuma no site vulnerável.

**CSRF token** — valor secreto e único, gerado pelo servidor e incluído em cada formulário legítimo, verificado no momento de processar o pedido. É a defesa principal contra CSRF: um atacante que forje um pedido de fora do site não tem como incluir esse valor, pelo que o servidor recusa o pedido.

**Dashboard / Threat Hunting (Wazuh)** — interface web do Wazuh (`https://192.168.10.30` no lab), onde se veem os alertas gerados pelo manager, o estado dos agentes e estatísticas de segurança. A secção "Threat Hunting" é onde se pesquisam e filtram os alertas por agente, regra ou período de tempo — usada, por exemplo, na Entrada #86 para confirmar (ou não) a deteção de um ataque real.

**DHCP** — protocolo que atribui automaticamente um endereço IP a um dispositivo quando este se liga a uma rede.

**DNS forwarder** — servidor de DNS para o qual um servidor de DNS reencaminha os pedidos que não consegue resolver sozinho (por exemplo, nomes da internet). No lab, o Windows Server (Controlador de Domínio e servidor de DNS do domínio `lab.local`) usa o OPNsense (`192.168.10.254`) como forwarder, para conseguir resolver nomes fora do domínio sem deixar de ser autoritativo para `lab.local` (Entrada #68).

**Docker Compose** — ferramenta que define e orquestra vários containers Docker relacionados a partir de um único ficheiro `docker-compose.yml`. Usada no lab para levantar de uma vez a arquitetura oficial do BloodHound CE (PostgreSQL, Neo4j e a aplicação web), em vez de montar cada componente manualmente (Entrada #90).

**DoesNotRequirePreAuth (UF_DONT_REQUIRE_PREAUTH)** — atributo de uma conta do Active Directory que desativa a exigência de pré-autenticação Kerberos: normalmente, um cliente tem de provar que conhece a password (com um timestamp cifrado) antes do Controlador de Domínio responder; com este atributo ativo, essa prova deixa de ser exigida, tornando a conta vulnerável a AS-REP Roasting. Não vem ativo por defeito em nenhuma conta — confirmado vazio no domínio do lab antes de se criar a conta `svc_legacy` de propósito para o exercício (Entrada #92).

**DSRM (Directory Services Restore Mode)** — modo de manutenção especial do Active Directory, usado para recuperar um Controlador de Domínio em caso de falha grave. Ao promover o Windows Server a Controlador de Domínio (Entrada #67), é definida uma palavra-passe própria de DSRM, separada da password normal de administrador — uma credencial sensível, com o mesmo nível de cuidado que uma password de administrador.

**Egress filtering (filtragem de saída)** — regras de firewall que controlam o tráfego que *sai* de uma máquina ou rede, em vez do que entra. No lab, usado para impedir que VMs que não precisam de internet consigam sair para fora da rede interna — reduz o risco de exfiltração de dados ou de comunicação com um servidor de comando e controlo, mesmo que a máquina seja comprometida. Aplicação prática do princípio do menor privilégio à rede.

**Escape de caracteres (`mysqli_real_escape_string`)** — função que "neutraliza" caracteres especiais como aspas, para impedir que quebrem uma query SQL. Defesa parcial e frágil: falha se a query não usar aspas à volta do input (como se viu no nível Medium do DVWA).

**EventChannel** — formato de leitura de logs do Wazuh (`<log_format>eventchannel</log_format>`) usado para ler diretamente um canal de eventos do Windows (Event Log), em vez de um ficheiro de texto normal. No lab, usado para ligar o agente Wazuh ao canal `Microsoft-Windows-Sysmon/Operational`, onde o Sysmon escreve os seus eventos (Entradas #87-88).

**Falso positivo** — um alerta de segurança que aponta para uma atividade suspeita mas que, investigado, se revela benigno. Na Entrada #88, um alerta de nível 15 (o mais alto observado no lab) disparou por um ficheiro `.ps1` temporário criado automaticamente pelo próprio PowerShell — um comportamento legítimo do sistema, não um ataque. Lição central: o nível de um alerta não decide se é real, só a investigação da origem o faz.

**Filebeat** — componente do stack Wazuh responsável por transportar os alertas gerados pelo Wazuh Manager até ao Wazuh Indexer, de forma cifrada (TLS). Instalado e configurado com o módulo oficial `wazuh-filebeat` na Entrada #84, como uma "correia de transmissão" entre o motor de deteção e o motor de indexação/pesquisa.

**FIM (File Integrity Monitoring) / syscheck** — deteção de alterações a ficheiros e pastas (criação, modificação, remoção), feita no Wazuh pelo módulo `syscheck`. Por defeito só vigia pastas de sistema (`/etc`, `/bin`, etc.); a Entrada #86 mostrou que uma pasta de aplicação (`/srv/ftp/upload`) fica de fora até ser explicitamente adicionada ao `ossec.conf` — uma lição central sobre a diferença entre instalar uma ferramenta e ter cobertura real.

**Firewall (regra de)** — instrução que diz ao firewall o que fazer com um tipo de tráfego (deixar passar / *pass*, ou bloquear / *block*), com base na origem, destino, porta, etc. As regras são avaliadas **por ordem, de cima para baixo**, aplicando-se a primeira que corresponder — por isso a ordem das regras é tão importante como o conteúdo delas.

**Framework** — estrutura de código já pronta que fornece ferramentas, regras e organização base para construir uma aplicação, em vez de se escrever tudo do zero (ex: ligação à base de dados, gestão de formulários, autenticação). Muitos frameworks já incluem prepared statements "de série", mas isso não impede um programador de escrever queries manuais e inseguras dentro deles. Exemplos: Laravel, Django, Express, Spring. O DVWA não usa framework — é PHP "cru", escrito propositadamente sem essa camada, para expor o mecanismo das vulnerabilidades sem abstrações escondidas.

**FSMO (roles)** — cinco papéis especiais dentro de uma floresta/domínio do Active Directory (ex.: PDC Emulator, RID Master, Infrastructure Master) que só podem existir num único Controlador de Domínio de cada vez, para evitar conflitos em operações que não suportam múltiplas origens em simultâneo. No lab, como só existe um Controlador de Domínio, este detém automaticamente todas as FSMO roles (Entrada #67).

**gMSA (group Managed Service Account)** — tipo de conta de serviço do Active Directory cuja password é gerada automaticamente, longa e aleatória, e rodada periodicamente pelo próprio domínio, sem intervenção humana. É a defesa estrutural mais robusta contra o Kerberoasting (Entrada #91): torna impraticável quebrar offline uma password que ninguém escolheu e que muda sozinha.

**GPMC (Group Policy Management Console)** — consola gráfica (`gpmc.msc`) usada para gerir Políticas de Grupo no Active Directory: criar, ligar, editar e consultar GPOs. Ao contrário da criação e ligação de uma GPO (possíveis por PowerShell), editar o conteúdo propriamente dito de uma política faz-se sempre pela GPMC — não por ser uma limitação do lab, mas por ser a forma normal de o fazer também em ambientes profissionais (Entradas #69-70).

**GPO (Group Policy Object / Política de Grupo)** — mecanismo do Active Directory para aplicar automaticamente configurações e regras de segurança a conjuntos de utilizadores ou computadores de um domínio (ex.: um aviso de login, uma política de passwords, um bloqueio de conta). Uma GPO só afeta os objetos que estão dentro do âmbito (OU) onde está ligada.

**Handshake (WireGuard)** — troca inicial de mensagens em que os dois pontos de uma VPN se autenticam mutuamente (com as suas chaves) e estabelecem o túnel cifrado. Sem um handshake bem-sucedido, o túnel aparece "configurado" mas não passa tráfego — foi exatamente o sintoma diagnosticado na Fase 3.

**hashcat** — ferramenta de quebra de passwords/hashes por dicionário ou força bruta, usando a GPU/CPU para testar candidatos a grande velocidade. Usada no lab com o modo `-m 13100` (específico para tickets de Kerberoasting) para tentar recuperar, a partir do hash extraído, a password de uma conta de serviço (Entrada #91).

**HIDS (Host-based Intrusion Detection System)** — sistema de deteção de intrusões baseado no próprio host (ao contrário de um IDS de rede, que só vê tráfego), a analisar logs, ficheiros e eventos localmente em cada máquina. No lab, é o papel que o Wazuh desempenha, complementando exatamente a limitação identificada com o Suricata na Entrada #77: um IDS de rede não vê tráfego lateral entre máquinas da mesma sub-rede, mas um HIDS instalado em cada máquina sim.

**HttpOnly (flag de cookie)** — definição que impede uma cookie de ser lida por JavaScript, protegendo contra roubo de sessão via XSS.

**IDS (Sistema de Deteção de Intrusões)** — sistema que observa o tráfego de rede à procura de padrões suspeitos ou maliciosos (com base em *regras*/assinaturas) e **alerta** quando os encontra. No lab usa-se o **Suricata**, integrado no OPNsense. Nota importante: um IDS colocado no router só vê o tráfego que passa por esse router — tráfego lateral entre duas máquinas do mesmo segmento de rede pode ser-lhe invisível.

**impacket** — conjunto de ferramentas em Python que implementam diretamente os protocolos de rede do Windows (SMB, Kerberos, etc.), sem precisar de um cliente Windows. Usado no lab através do script `GetUserSPNs.py`, que automatiza o pedido de Tickets de Serviço (TGS) para contas com SPN — o mecanismo central do Kerberoasting (Entrada #91).

**Ingress Tool Transfer (MITRE T1105)** — técnica do MITRE ATT&CK que descreve a transferência de ferramentas ou ficheiros para uma máquina comprometida, normalmente feita pelo atacante para expandir o seu acesso. No lab, um alerta associado a esta técnica (regra 92213, "Executable file dropped in folder commonly used by malware") disparou por um ficheiro temporário criado pelo próprio PowerShell — um falso positivo que ilustra bem como a mesma assinatura pode cobrir comportamento malicioso e legítimo (Entrada #88).

**Input baseado em sessão** — quando o valor submetido pelo utilizador é guardado na sessão (do lado do servidor) em vez de ser lido diretamente de cada pedido. No DVWA nível High, o ID é submetido numa janela separada e guardado na sessão, desacoplando o ponto de entrada do resultado — o que dificulta ataques automáticos.

**Kerberoasting** — ataque que aproveita o facto de qualquer conta autenticada do domínio poder pedir um Ticket de Serviço (TGS) para qualquer conta com SPN registado. O ticket vem cifrado com um hash derivado da password dessa conta de serviço; o atacante extrai esse hash e tenta quebrá-lo offline, sem gerar qualquer tentativa de login falhada contra o domínio. Revela a password se ela for fraca ou estiver presente na wordlist usada. Demonstrado de ponta a ponta na Entrada #91.

**LAN Segment (VMware)** — rede virtual isolada dentro do VMware, que liga várias VMs entre si sem exposição à rede real.

**LIMIT (cláusula SQL)** — instrução que restringe o número de linhas devolvidas por uma query (ex.: `LIMIT 1` devolve só uma). No DVWA nível High serve de travão, contornado comentando-o com `#`.

**LVM (Logical Volume Manager)** — sistema de gestão de discos do Linux que permite agrupar espaço físico num "grupo de volumes" e distribuí-lo por "volumes lógicos" de forma flexível, sem estar preso às partições físicas tradicionais. Usado na instalação da VM Wazuh (Entrada #82); o instalador do Ubuntu Server, em modo "guiado", só atribuiu por defeito metade do disco ao volume lógico principal, sendo necessário editar manualmente o volume para usar o disco completo.

**Menor privilégio (princípio do)** — dar a cada conta ou processo apenas as permissões mínimas de que precisa. Aplicado à conta de base de dados de uma aplicação, limita o estrago que um ataque bem-sucedido pode causar.

**Metasploit (Framework)** — plataforma de *pentest* que reúne módulos prontos para explorar vulnerabilidades, fazer força bruta e pós-exploração. Usada no lab, por exemplo, para atacar de forma automatizada as credenciais de FTP e de base de dados do Servidor Vulnerável.

**MIME type / Content-Type** — informação que descreve o tipo de um ficheiro (ex.: `image/jpeg`, `application/x-php`), normalmente enviada pelo browser ao fazer upload. É controlada pelo atacante e pode ser falsificada, por isso não deve ser a única forma de validar um ficheiro no servidor.

**MITRE ATT&CK** — base de conhecimento pública que cataloga táticas e técnicas reais usadas por atacantes (ex.: T1105 — Ingress Tool Transfer), usada como referência comum para nomear e classificar comportamento malicioso detetado por ferramentas como o Wazuh. No lab, aparece a identificar o alerta de nível 15 investigado na Entrada #88.

**NAT (Network Address Translation)** — mecanismo que traduz endereços entre redes. No lab, a interface NAT da Ubuntu Server (`ens37`, gama 192.168.203.x) é a usada para administração/SSH a partir do host, separada da rede isolada "Ciber".

**Neo4j** — base de dados de grafos usada pelo BloodHound para armazenar as relações do Active Directory recolhidas (utilizadores, grupos, permissões, sessões), permitindo consultas de caminho (pathfinding) rápidas entre nós — algo lento e impraticável de fazer à mão com os comandos nativos do AD (Entrada #90).

**Nível de alerta / regra (Wazuh)** — cada alerta gerado pelo Wazuh corresponde a uma regra específica do seu ruleset, com um nível de severidade associado (de 0 a 15). O parâmetro `log_alert_level` do `ossec.conf` do manager define o nível mínimo a partir do qual um evento é mesmo registado como alerta. A Entrada #87 mostrou uma distinção importante: baixar este limiar não faz "nascer" alertas novos — só revela os que já existiam a níveis mais baixos; se não existe nenhuma regra que corresponda a um evento (ex.: um `whoami` genérico), esse evento nunca gera alerta, por mais baixo que o limiar seja.

**NTP (Network Time Protocol)** — protocolo que sincroniza o relógio de um sistema com uma fonte de tempo fiável. A Entrada #87 mostrou por que é crítico num SIEM: o Windows Server estava com um fuso horário errado (quase 8 horas de diferença), fazendo parecer que eventos reais "não estavam a ser detetados", quando na verdade estavam a ser registados fora da janela de tempo onde se procurava.

**ossec.conf** — ficheiro de configuração principal do Wazuh (herdado do projeto original OSSEC), presente tanto no manager como em cada agente. É nele que se definem, por exemplo, que pastas o `syscheck` vigia, que fontes de log são lidas (incluindo canais `eventchannel` como o do Sysmon) e o `log_alert_level` mínimo. Várias entradas da Fase 5/6 (#85-88) giram à volta de editar este ficheiro corretamente em cada máquina.

**OU (Organizational Unit / Unidade Organizacional)** — "pasta" dentro do Active Directory que agrupa objetos (utilizadores, computadores, servidores) para os organizar e para lhes aplicar GPOs de forma seletiva. Separar os objetos geridos em OUs próprias (em vez dos contentores por defeito) é a base para aplicar políticas sem afetar todo o domínio.

**Output encoding / escaping** — tratar o input do utilizador antes de o mostrar numa página, convertendo caracteres especiais (`<` → `&lt;`, `>` → `&gt;`, etc.) para o browser os apresentar como *texto* em vez de os executar como código. É a defesa principal contra XSS.

**OWASP Top 10** — lista de referência das 10 categorias de vulnerabilidades mais críticas em aplicações web, mantida pela organização OWASP.

**Payload** — o conteúdo/texto enviado a uma aplicação para testar ou explorar o seu comportamento.

**PHP** — linguagem de programação do lado do servidor, muito usada para construir sites dinâmicos (o DVWA é escrito em PHP). Quando um browser pede um ficheiro `.php` a um servidor com PHP instalado, o servidor não devolve o código como texto — executa-o primeiro, e só devolve o resultado. É esta característica que torna perigoso aceitar uploads de ficheiros `.php` sem verificação: o servidor trata-os como código a correr, não como um documento inofensivo.

**Prepared statements / parameterized queries** — forma segura de construir queries SQL onde os dados do utilizador nunca são interpretados como código, só como valores.

**RC4-HMAC** — tipo de cifra Kerberos mais antigo (etype 23), ainda suportado por compatibilidade em muitos domínios reais. Mais rápido de quebrar offline do que o AES, mais recente, o que o torna um alvo preferencial em Kerberoasting — foi o tipo de cifra encontrado no hash extraído na Entrada #91.

**RCE (Remote Code Execution)** — execução de código ou comandos arbitrários numa máquina remota através de uma vulnerabilidade. É o impacto máximo de falhas como o Command Injection, porque dá controlo sobre o sistema operativo do servidor, não apenas sobre os dados.

**Reconhecimento (Reconnaissance)** — fase inicial de um teste de segurança, onde se recolhe informação sobre o alvo antes de qualquer tentativa de exploração.

**Reserva estática de DHCP (static mapping)** — associação fixa entre o endereço físico (MAC) de uma máquina e um IP, definida no servidor DHCP. A máquina continua a receber o IP por DHCP, mas recebe *sempre o mesmo* — dá estabilidade sem ter de configurar o IP manualmente em cada máquina. Útil quando se querem escrever regras de firewall que dependem de um IP fixo.

**Restart policy** — configuração que define se/quando um container Docker deve reiniciar automaticamente.

**RestrictAnonymous** — definição do Windows que controla o que uma sessão nula SMB consegue ver: `0` (sem restrição, listas de utilizadores/partilhas visíveis), `1` (a sessão é aceite, mas a listagem é bloqueada — o que se confirmou no Windows Server do lab), `2` (a sessão nem sequer é aceite).

**RID cycling (RID brute-force)** — técnica de enumeração que, em vez de pedir a lista completa de utilizadores (bloqueada), testa sequencialmente os números internos (RIDs) associados às contas do domínio, usando uma sessão SMB nula para traduzir cada número numa possível conta existente.

**rockyou.txt** — wordlist de passwords muito usada em testes de quebra offline, construída a partir de uma fuga de dados real de 2009 (o site RockYou). Contém milhões de passwords realmente usadas por pessoas, eficaz contra padrões comuns — mas não contém nada gerado depois de 2009, como se confirmou na Entrada #91 (falha contra `Summer2026!`, sucesso contra `Password123`).

**RootDSE (LDAP)** — o "cartão de visita" público de um servidor LDAP: informação básica sobre o diretório (naming contexts, nível funcional, mecanismos de autenticação suportados) que qualquer cliente pode consultar sem se autenticar, por definição do protocolo — não é uma falha de configuração.

**Sessão nula / Null session (SMB)** — ligação SMB estabelecida sem credenciais válidas (utilizador e password vazios). Não implica acesso a nada por si só — o que essa sessão consegue ver depende do nível de `RestrictAnonymous` configurado no servidor: pode ir de acesso total (mal configurado) a zero informação (bem protegido), mesmo que a própria sessão seja aceite.

**Session hijacking (roubo de sessão)** — assumir a sessão autenticada de outro utilizador apropriando-se do seu identificador de sessão (ex.: a cookie `PHPSESSID`). Permite agir como a vítima sem saber a password. Uma das consequências mais graves do XSS, se a cookie de sessão for legível por JavaScript (ver HttpOnly).

**SharpHound** — o collector oficial do BloodHound, escrito em C#/.NET, normalmente corrido a partir de uma máquina Windows dentro do domínio. No lab, preferiu-se o `bloodhound-python` (a partir do Kali) na Sessão 6.2, para não deixar artefactos numa máquina Windows monitorizada pelo Sysmon/Wazuh.

**SIEM (Security Information and Event Management)** — sistema que centraliza, correlaciona e apresenta eventos de segurança vindos de várias fontes (agentes, logs, sensores), para facilitar a deteção e a resposta a incidentes. É o papel geral que o Wazuh desempenha no lab, complementando o IDS de rede (Suricata) com visibilidade dentro de cada host.

**Sink** — no contexto de DOM XSS, o ponto onde um dado é usado de forma que pode executar código (ex.: `document.write()`, `innerHTML`), sem o tratar primeiro. Se um dado controlado pelo atacante (a source) chega a um sink sem ser escapado, o XSS acontece — inteiramente no browser, sem o servidor alguma vez ver ou processar esse dado.

**SMB signing (assinatura SMB)** — mecanismo que assina criptograficamente cada mensagem SMB, permitindo detetar se foi alterada em trânsito. Defesa direta contra ataques de *relay* (um atacante a interceptar e retransmitir tráfego SMB para se autenticar como outra máquina).

**Snapshot (VMware)** — "fotografia" do estado de uma máquina virtual num dado momento, que permite reverter se algo correr mal. Tirado antes de cada exercício como ponto de retorno; convenção de nome com data e contexto (ex.: `2026-08-11_lab-estavel-base`).

**Source (fonte)** — no contexto de DOM XSS, o ponto onde um dado controlado pelo atacante entra na página do lado do cliente (ex.: o URL, lido via `document.location`). Não é perigoso por si só — só se tornar perigoso se chegar a um sink sem tratamento.

**SPN (Service Principal Name)** — identificador único que associa um serviço de rede (ex.: um SQL Server) a uma conta do Active Directory usada para o autenticar via Kerberos. Uma conta com SPN registado pode ser alvo de Kerberoasting, porque qualquer utilizador do domínio pode pedir um Ticket de Serviço para ela (Entrada #91).

**SQL (Structured Query Language)** — linguagem usada para comunicar com bases de dados relacionais: pedir dados (`SELECT`), inserir (`INSERT`), alterar (`UPDATE`) ou apagar (`DELETE`). É a linguagem que o SQL Injection explora, ao conseguir inserir comandos SQL não autorizados através de campos de input.

**Stale state** — quando um sistema guarda a mesma informação em mais do que um sítio, e nem todos são atualizados ao mesmo tempo, causando comportamento inconsistente.

**SwiftOnSecurity (configuração)** — ficheiro de configuração do Sysmon, mantido pela comunidade e amplamente usado por quem está a começar em deteção, por ter boa cobertura de eventos relevantes sem gerar ruído excessivo. Escolhido no lab (Entrada #87) em vez de configurações mais avançadas e modulares (ex.: Olaf Hartong), por ser mais adequado a um estágio inicial de aprendizagem.

**Sysmon (System Monitor)** — ferramenta gratuita da Sysinternals/Microsoft que regista, em detalhe, eventos do sistema Windows normalmente invisíveis aos logs padrão (criação de processos, linha de comandos completa, hashes de ficheiros, ligações de rede, etc.), escrevendo-os no canal `Microsoft-Windows-Sysmon/Operational`. Instalado no lab com a configuração da comunidade SwiftOnSecurity e ligado ao Wazuh via `eventchannel`, é a fonte de dados que tornou possível detetar, por exemplo, o `whoami /all` nas Entradas #87-88.

**Tautologia** — no contexto de SQL Injection, uma condição que é sempre verdadeira por estrutura (ex. `1=1`), independentemente dos dados reais.

**TGS (Ticket Granting Service / Ticket de Serviço)** — o ticket Kerberos que um cliente usa para se autenticar diretamente junto de um serviço específico, ao contrário do TGT (que só prova a identidade junto do Controlador de Domínio). É este ticket, cifrado com um hash derivado da password da conta de serviço, que é o alvo do Kerberoasting (Entrada #91).

**Triagem de alertas** — processo de investigar um alerta de segurança antes de reagir, para perceber se corresponde a uma ameaça real ou a um falso positivo — olhando à origem do evento (processo, utilizador, contexto), não apenas ao seu nível de severidade. Praticada na Entrada #88 ao investigar um alerta de nível 15 que se revelou benigno: um nível alto sinaliza que vale a pena olhar, não que o incidente é automaticamente real.

**Validação de input** — verificar que aquilo que o utilizador envia é do tipo e formato esperados (ex.: confirmar que um ID é mesmo um número inteiro) antes de o usar. Teria evitado o SQL Injection em todos os níveis.

**VPN (Virtual Private Network)** — túnel cifrado que liga dois pontos através de uma rede não confiável, protegendo o tráfego que passa por ele contra leitura ou adulteração. No lab, montada com WireGuard para perceber, na prática, a cifra de tráfego e a gestão de chaves.

**WAF (Web Application Firewall)** — camada de segurança que filtra pedidos a uma aplicação web à procura de padrões maliciosos conhecidos.

**Wazuh** — plataforma open-source de deteção que combina SIEM e HIDS, usada no lab para monitorizar as máquinas do laboratório a partir de uma VM dedicada (192.168.10.30). Instalada de forma manual/nativa (sem Docker) numa arquitetura "all-in-one", com quatro componentes: Wazuh Indexer, Wazuh Manager, Filebeat e Wazuh Dashboard (Entrada #84).

**Wazuh Indexer** — componente do stack Wazuh responsável por armazenar e indexar os alertas e eventos recebidos, baseado no motor OpenSearch. É o componente que permite depois pesquisar e filtrar alertas de forma rápida no Dashboard (Entrada #84).

**Wazuh Manager** — o "cérebro" do Wazuh: recebe os eventos enviados pelos agentes, analisa-os contra o seu conjunto de regras (ruleset) e decide quais geram alertas. É também quem gere o registo (enrollment) de novos agentes. Corre os seus próprios daemons (analysisd, remoted, syscheckd, modulesd, entre outros), confirmados a funcionar logo após a instalação na Entrada #84.

**Web shell** — ficheiro (normalmente `.php` ou equivalente) carregado para um servidor vulnerável, que permite ao atacante executar comandos do sistema operativo através de um parâmetro do URL (ex.: `?cmd=whoami`). É a técnica clássica para transformar uma falha de File Upload em RCE.

**Whitelist (lista branca)** — abordagem inversa da blacklist e mais robusta: em vez de bloquear o que é mau, só permite *exatamente o que é reconhecidamente seguro* (ex.: aceitar apenas dígitos e pontos de um IP válido, rejeitando tudo o resto). Não há como escapar, porque tudo o que não está expressamente permitido é recusado.

**WireGuard** — implementação de VPN moderna, simples e rápida, baseada na troca de chaves públicas/privadas. Escolhida no lab por ser fácil de configurar manualmente e de perceber passo a passo, ideal para aprender os conceitos de VPN sem a complexidade de soluções mais antigas.

**Wordlist / dicionário (ataque de)** — lista de passwords candidatas usada para tentar quebrar uma password, testando cada uma até encontrar uma correspondência exata (ou aplicando regras de mutação). Só encontra o que está literalmente na lista — não "adivinha" padrões novos, como mostrou a primeira tentativa falhada da Entrada #91.

**XSS (Cross-Site Scripting)** — vulnerabilidade em que uma aplicação web inclui input do utilizador numa página sem o tratar, permitindo injetar código (tipicamente JavaScript) que corre no browser de quem abre a página. Ao contrário do SQL Injection ou Command Injection, a vítima é outro utilizador, não o servidor. Variantes: Reflected (refletido de imediato, via URL), Stored (guardado no servidor) e DOM.
