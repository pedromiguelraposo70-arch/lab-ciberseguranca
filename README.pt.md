# Laboratório de Cibersegurança — Diário de Aprendizagem

*[🇬🇧 English version](./README.md)*

## Porque é que este repositório existe

Sou estudante iniciante de cibersegurança. Este repositório não é um produto acabado nem uma demonstração de competência — é o **registo honesto de como estou a aprender**, montando e usando um laboratório de máquinas virtuais em casa (VMware Workstation) para praticar de forma prática e segura.

A decisão de documentar tudo, incluindo o que correu mal, é intencional. A maior parte dos materiais de cibersegurança que se encontram online mostram o resultado final — o ataque que funcionou, o comando certo à primeira. Isso é útil para copiar, mas esconde a parte mais importante do processo de aprendizagem: os erros, os becos sem saída, e o raciocínio que leva de "não sei porque é que isto não funciona" a "ah, era isto".

## O que vais encontrar aqui

- **[`registo-laboratorio-ciberseguranca.md`](./registo-laboratorio-ciberseguranca.md)** — o registo principal, entrada a entrada, de cada exercício: objetivo, comandos usados, o que era esperado, o que aconteceu de facto, como nos podemos defender do ataque em causa, e — sempre que aplicável — **o que correu mal ou falhou**. Também mapeado, quando faz sentido, para os domínios de certificações em estudo (Security+, CEH, ISO/IEC 27001, NIS2, CompTIA A+).
- **`screenshots/AAAA-MM-DD/`** — capturas de ecrã ilustrativas de cada dia de trabalho.
- **`guias-estudo/`** — documentos de consolidação por tema (analogias, raciocínio passo a passo, autoavaliação honesta de compreensão), separados do registo técnico.
- **[`glossario.md`](./glossario.md)** — termos técnicos explicados de forma simples, atualizado à medida que aparecem no registo.
- **[`mapa-cobertura-mitre-attack.md`](./mapa-cobertura-mitre-attack.md)**, **[`playbook-resposta-incidentes.md`](./playbook-resposta-incidentes.md)** e **[`hardening-baseline.md`](./hardening-baseline.md)** — os três entregáveis da Fase 7 (Blue Team): o que a deteção apanha realmente, como se responde a um incidente e as defesas do projeto reconfirmadas ao vivo.
- **[`tabela-resumo-ataques.xlsx`](./tabela-resumo-ataques.xlsx)** — folha de cálculo com os ataques feitos no lab: tipo, gravidade, deteção, defesa e domínio ISO/NIS2/RGPD.
- **[`registo-riscos.xlsx`](./registo-riscos.xlsx)**, **[`declaracao-aplicabilidade-parcial.md`](./declaracao-aplicabilidade-parcial.md)** e **`politicas/`** — os entregáveis da Fase 8 (GRC): o registo de riscos com evidência, a Declaração de Aplicabilidade parcial e as três políticas da empresa fictícia.
- **`analise-rede/`** e **`scripts/`** — a leitura de cada fase pela lente da rede (o que na configuração permitiu o ataque e que defesa o impediria), e o índice de scripts candidatos (ainda sem scripts).
- **`fase6-proposta-ad-attacks.md`**, **`fase7-proposta-blue-team.md`** e **`fase8-proposta-grc.md`** — os planos de cada fase, escritos antes de a fase começar.

## Porquê estas ferramentas

- **VMware Workstation** — permite isolar completamente o laboratório da rede de casa, com várias máquinas a correr em simultâneo, sem risco para o sistema real.
- **OPNsense** — firewall/router open-source (gateway em `192.168.10.254`), usado para gerir a rede interna e a saída para a internet, e para praticar configuração de firewall a sério: regras de *egress filtering*, reservas DHCP e IDS.
- **Kali Linux** — distribuição padrão da indústria para testes de segurança, com ferramentas de pentest pré-instaladas, usada como a máquina atacante.
- **DVWA (Damn Vulnerable Web Application)** — aplicação web intencionalmente vulnerável, com níveis de dificuldade crescente, escolhida por ser didática e mapear diretamente para o OWASP Top 10.
- **Docker** — usado para instalar e gerir o DVWA de forma isolada e fácil de repor do zero, sem "sujar" o sistema do Servidor Vulnerável.
- **Windows Server + Active Directory (AD DS)** — Controlador de Domínio do laboratório (`lab.local`), usado para praticar gestão de identidade, Políticas de Grupo (GPO) e hardening de um domínio Windows.
- **Windows 11 e Ubuntu Desktop** — máquinas cliente do laboratório: o Windows 11 juntado ao domínio `lab.local`, o Ubuntu Desktop como servidor da VPN.
- **WireGuard** — VPN moderna, montada manualmente (Ubuntu Desktop como servidor, Windows 11 como cliente) para perceber, na prática, cifra de tráfego e túneis.
- **Suricata (IDS)** — sistema de deteção de intrusões integrado no OPNsense, usado para observar e alertar sobre tráfego suspeito na rede do lab.
- **Wazuh** — plataforma SIEM/HIDS open-source, instalada manualmente (sem Docker) para monitorizar e correlacionar eventos de segurança nas máquinas do laboratório.
- **Metasploit, Hydra, nmap, Wireshark/tcpdump** — ferramentas de ataque e análise usadas ao longo das fases: enumeração, força bruta, exploração de serviços e captura/análise de tráfego.
- **Git / GitHub** — controlo de versões e histórico do progresso, também como portefólio público de aprendizagem.

## O espírito deste repositório

- **Não é um produto final.** É atualizado sessão a sessão, à medida que os exercícios acontecem — não reescrito no final para parecer mais polido do que foi na realidade.
- **Erros ficam registados, não apagados.** Se um comando falhou, se uma configuração de rede se partiu a meio de um exercício, se um pressuposto estava errado — isso fica documentado tal como aconteceu, porque é aí que está a aprendizagem real.
- **Evolução visível ao longo do tempo.** As primeiras entradas vão parecer mais hesitantes ou mais básicas do que as últimas — é suposto ser assim. Comparar a Entrada #1 com uma entrada de daqui a alguns meses deve mostrar claramente o progresso.

## Estado atual

O projeto avança por **fases**. O detalhe completo de cada exercício (comandos, o que correu mal, defesas, mapeamento a certificações) está no [registo principal](./registo-laboratorio-ciberseguranca.md), entrada a entrada. Este resumo dá só a visão geral.

### Linha do tempo

| Fase | Período | O que ficou aprendido |
|---|---|---|
| 1 — Montagem do laboratório | 2026-08-02 | Montar uma rede isolada e fazer a primeira exploração (SQL Injection) |
| 2 — Exploração web (DVWA) | até 2026-08-17 | Cada falha web tem a sua defesa própria — e as defesas fracas (blacklists) contornam-se |
| 3 — VPN WireGuard | até 2026-08-22 | A cifra esconde o conteúdo, mas não os metadados |
| 4 — Serviços de rede | 2026-08-22/23 | Serviços mal configurados (FTP anónimo, Samba, MariaDB) encadeiam-se até ao comprometimento total |
| 5 — Windows Server, hardening e deteção | 2026-08-24/25 | Ter uma ferramenta de deteção instalada não é o mesmo que detetar o ataque |
| 6 — Ataques ao Active Directory | 2026-08-30 a 2026-09-18 | Os ataques ao AD exploram configuração, não falhas de software — e, por defeito, o SIEM não os vê |
| 7 — Blue Team: deteção, resposta e hardening | 2026-09-20 a 2026-09-25 | Detetar, responder e endurecer — e assumir por escrito as lacunas que ficam |
| 8 — GRC: risco, conformidade e auditoria | 2026-09-27 a 2026-10-01 | Uma política escrita não é um controlo: só o é quando se verifica que o sistema a cumpre — e aceitar um risco é uma decisão que se escreve |

### Fase 1 — Montagem do laboratório (2026-08-02)
Laboratório montado no VMware Workstation, numa rede interna isolada (`192.168.10.0/24`) atrás do OPNsense: Kali (atacante), Servidor Vulnerável e router/firewall. DVWA instalado em Docker no Servidor Vulnerável, e primeiro exercício de exploração (SQL Injection, nível Low) realizado com sucesso.

### Fase 2 — Exploração web com o DVWA (concluída)
Percurso completo pelos módulos do OWASP Top 10 no DVWA, cada um do nível **Low** ao **Impossible**, sempre com a mesma lógica: explorar a falha, perceber porque funciona, e identificar a defesa correta.

- **SQL Injection** — do bypass de login à leitura da base de dados; defesa: *prepared statements*.
- **Command Injection** — RCE no campo de ping; blacklists contornadas, whitelist como defesa robusta.
- **XSS** (Reflected, Stored e DOM) — injeção de JavaScript, roubo de cookie de sessão; defesa: *output encoding*.
- **CSRF** — mudança de password sem passar pelo formulário; defesa: tokens anti-CSRF.
- **File Upload** e **File Inclusion** — incluindo o **encadeamento** dos dois para RCE completo (web shell).
- **Brute Force** — ataque manual, com **Hydra**, e com bypass de token anti-CSRF e de *rate limiting*; fechado pelo nível Impossible, travado por uma **política de bloqueio de conta**.

Cada módulo tem um guia de consolidação em [`guias-estudo/`](./guias-estudo/).

### Fase 3 — VPN WireGuard (concluída, 2026-08-22)
VPN montada manualmente (linha de comandos, para perceber cada passo): **Ubuntu Desktop como servidor**, **Windows 11 como cliente**. Túnel estabelecido e — o objetivo didático central — **cifra do tráfego confirmada** por captura no Kali (Wireshark/tcpdump), mostrando que o conteúdo viaja encriptado.

### Fase 4 — Exploração de serviços de rede (concluída, 2026-08-22/23)
Saindo da aplicação web para os serviços do sistema operativo do Servidor Vulnerável (instalados manualmente, não em Docker, por opção didática):

- **vsftpd** com FTP anónimo mal configurado, encadeado com um **Apache** apontado à mesma pasta → **RCE** via web shell enviada por FTP.
- **Enumeração** formal com **nmap**; investigação do **Optionsbleed** (CVE-2017-9798) — documentada com honestidade, incluindo o facto de a vulnerabilidade principal **não** ter sido reproduzida.
- **Força bruta** a FTP e a **MariaDB** com o **Metasploit Framework**, e **Samba** com partilha anónima.

### Fase 5 — Windows Server, hardening e deteção (concluída, 2026-08-24/25)
A última fase antes da publicação, focada em construir **e defender** infraestrutura, não só atacá-la:

- **Active Directory** — Windows Server promovido a Controlador de Domínio (`lab.local`), com estrutura de OUs e conta de teste; **Windows 11 juntado ao domínio**.
- **Políticas de Grupo (GPO)** — aviso legal de login e **política de bloqueio de conta** (que liga diretamente ao Brute Force da Fase 2), ambas confirmadas em produção.
- **Hardening do OPNsense** — *egress filtering* aplicado às quatro VMs do lab exceto o Kali (que mantém acesso à internet como máquina atacante), e **Suricata (IDS)** ativado com ~1160 regras, confirmado a detetar tráfego real de scan.
- **Wazuh (SIEM/HIDS)** — VM dedicada montada de raiz, instalação manual completa da stack (Indexer, Manager, Filebeat, Dashboard), agentes registados nas máquinas do laboratório, e um teste real de deteção: reprodução de um ataque conhecido (FTP anónimo → RCE) com o Wazuh a vigiar, identificando — e depois corrigindo — uma lacuna real na configuração por defeito.

Com a Fase 5 fechada, o laboratório cobre atualmente ataques completos a aplicações web (DVWA), uma VPN segura construída de raiz, exploração de rede/serviços, administração de um domínio Windows, e duas camadas complementares de defesa — prevenção (firewall, *egress filtering*) e deteção (IDS de rede com Suricata, SIEM/HIDS com Wazuh).

### Fase 6 — Ataques ao Active Directory (concluída, 2026-08-30 a 2026-09-18)
Fecha o ciclo de volta à ofensiva: atacar o domínio Active Directory construído na Fase 5, com o Wazuh a vigiar, para perceber na prática o que um SIEM apanha por defeito e o que não apanha — e depois virar-se para a defesa.

- **Enumeração sem credenciais**, **BloodHound** (análise de caminhos de ataque), **Kerberoasting** e **AS-REP Roasting** — extração de hashes de password a partir de tickets de serviço Kerberos, quebrados offline com hashcat.
- **Regras de deteção no Wazuh para eventos Kerberos** (4768/4769) — regra de correlação própria para identificar Kerberoasting (encriptação RC4 em vez de AES num pedido de ticket de serviço), incluindo uma investigação real a uma regra de fábrica silenciosa que estava a "reclamar" o evento antes da regra própria ter hipótese de o avaliar.
- **LLMNR/NBT-NS poisoning com Responder** — captura de um hash NTLMv2 real do cliente Windows 11, sem qualquer credencial prévia, confirmado passo a passo no Wireshark (fallback multicast, hop limit 1, sem autenticação).
- **Balanço defensivo e hardening (sessão de fecho)** — para cada ataque feito, a defesa concreta correspondente; LLMNR desligado por GPO, NBT-NS e mDNS desligados no cliente (limitação de ADMX documentada), provado com uma nova captura do Responder a mostrar zero envenenamento nos três canais.

O Pass-the-Hash e o exercício opcional de persistência com DCSync/Golden Ticket ficaram intencionalmente fora da prática hands-on — cobertos só ao nível conceptual, por decisão registada na Entrada #98 do registo e em `fase6-proposta-ad-attacks.md`. Guia de consolidação em `guias-estudo/guia-estudo-fase6-active-directory.md`.

### Fase 7 — Blue Team: Deteção e Resposta (concluída, 2026-09-20 a 2026-09-25)
Inverter a cadeira: sentar-me por inteiro como defensor e olhar para trás, de forma sistemática, sobre o que a deteção do laboratório apanha realmente. 100% defensiva.

- **Baseline de visibilidade** — reverificada a stack de deteção completa (Wazuh, Sysmon, Suricata); encontrado e corrigido um erro real de configuração do Suricata (motor ligado à interface de rede errada), mais uma falha distinta de reinícios em loop invisível na interface gráfica, confirmada a correção com 27 alertas de IDS reais.
- **Mapa de cobertura de deteção MITRE ATT&CK** — auditados os 19 ataques já feitos na prática, classificando cada um como detetado / parcialmente detetado / invisível — um mapa honesto da dívida de deteção real, não só dos sucessos.
- **Fechar lacunas prioritárias** — a escrever regras Wazuh dedicadas para as lacunas encontradas. Primeira fechada: AS-REP Roasting (Pre-Authentication Type 0 do Kerberos), validada de ponta a ponta. Pelo caminho, encontrada e corrigida uma falha silenciosa do `wazuh-remoted` que tinha desconectado três agentes sem ninguém reparar. A segunda lacuna afinal não era uma lacuna: um evento real de logon SMB anónimo revelou que já estava coberta por uma regra de fábrica do Wazuh (logon NTLM anónimo / possível pass-the-hash) que uma leitura só estática do ficheiro de regras tinha deixado passar — corrigido no mapa de cobertura em vez de se escrever uma regra redundante. A terceira lacuna (escrita FTP anónima + Apache = RCE via web shell PHP) era real: o pedido de exploração era descodificado mas caía numa regra genérica de nível zero, por isso foi escrita uma regra nova que sinaliza o padrão `cmd=`/`exec=`/`command=` no URL descodificado — a regra própria de maior severidade do laboratório até agora, por confirmar execução de código já a acontecer, não só uma tentativa.
- **Threat hunting proativo** — primeira hipótese formulada antes de olhar para os dados (BloodHound, Entrada #90), testada diretamente na API do Wazuh Indexer, sem depender do Dashboard. A hipótese estava parcialmente errada: existe alerta (regras de fábrica `92652`/`92657`), mas é um falso positivo por coincidência de mecanismo (NTLM Type 3), não deteção genuína da técnica — mapa de cobertura corrigido para refletir isto com precisão (linha 16 mantida 🟡, agora com a razão certa).
- **Resposta a incidentes — playbook + simulação completa** — ciclo detetar → triar → conter → erradicar → recuperar → lições aprendidas sobre um incidente real do lab (FTP anónimo + Apache = RCE via web shell). A primeira tentativa de conteção (regra de firewall no OPNsense) falhou silenciosamente — atacante e alvo no mesmo segmento L2, tráfego nunca atravessa o gateway — corrigida com conteção ao nível do host (`iptables`). Erradicação revelou quatro web shells, não um; causa raiz corrigida em duas camadas (FTP anónimo só leitura + PHP desativado na pasta de upload). Playbook reutilizável entregue em `playbook-resposta-incidentes.md`.
- **Baseline de hardening consolidado** — reunidas num só documento (`hardening-baseline.md`) todas as defesas do projeto, com cada uma reconfirmada ao vivo, não só documentalmente: egress filtering corrigido (exceção de Windows Update revertida sozinha entre sessões), Suricata confirmado por shell (a GUI já mostrou "a correr" com o processo morto), Wazuh e LLMNR/NBT-NS/mDNS retestados com sucesso, SMB signing reconfirmado. Duas lacunas honestas documentadas como aceitação de risco consciente, não esquecimento: VMs por trás do egress filtering nunca atualizadas, e duas contas de serviço com passwords fracas mantidas de propósito.

### Fase 8 — GRC: risco, conformidade e auditoria (concluída, 2026-09-27 a 2026-10-01)
Sair da técnica e olhar para o lab como uma pequena organização: uma empresa fictícia (micro-empresa de 6-8 colaboradores, com uma aplicação de encomendas) a quem se faz a avaliação de risco, a conformidade e a auditoria que uma organização real teria de fazer. Sem ataques novos: o que é real é a evidência técnica de cada risco.

- **Inventário e classificação de ativos** — cada VM ligada a uma função de negócio fictícia e classificada em confidencialidade, integridade e disponibilidade; a verificação ao vivo encontrou um achado real (o DVWA estava parado sem ninguém dar por isso).
- **Registo de riscos com evidência** — matriz de probabilidade por impacto (1-3), risco inerente e residual, cada risco ligado à entrada do registo que o prova. Começou com 7 riscos e fechou com 8 (`registo-riscos.xlsx`).
- **Tratamento de risco e Declaração de Aplicabilidade parcial** — para cada risco, a decisão de mitigar ou aceitar, com justificação escrita, ligada aos controlos da ISO/IEC 27001 (`declaracao-aplicabilidade-parcial.md`).
- **Três políticas** — controlo de acesso e passwords, registo e monitorização, gestão de vulnerabilidades e configuração segura (pasta `politicas/`).
- **Auditoria interna ao vivo** — "a política diz X, o lab cumpre X?", em cinco itens: quatro conformes e dois não conformes, ambos corrigidos (passwords de 7 caracteres contra os 16 da política; nenhuma retenção de 90 dias aplicada nos logs do Wazuh). A correção da retenção falhou à primeira, foi detetada por uma segunda verificação independente e ficou provada num índice novo.
- **NIS2 e RGPD aplicados a incidentes reais do lab** — o incidente FTP para RCE (Entrada #104) e o email capturado na Entrada #97, com prazos de notificação, aplicabilidade por tamanho e um passo novo no playbook de resposta a incidentes (a "Fase 2b").
- **Balanço e programa da Fase 9** — lista priorizada do que ficou por tratar, separando riscos, lacunas de controlo, verificações técnicas e questões jurídicas. Um oitavo risco (VMs sem cópia de segurança) foi avaliado com factos e aceite de forma escrita, e o risco #5 foi reformulado depois de se descobrir que a sua evidência provava outra coisa. A lição que mais pesou foi a intersecção entre a máquina física e as VMs: discos, espaço e cópias são os mesmos.

Duas lacunas ficam honestas no registo: as questões jurídicas por confirmar no texto oficial (arts. 40.º a 44.º, contagem dos 30 dias úteis, aplicabilidade a um retalhista online) e o risco crítico do Kerberoasting/AS-REP, aceite de propósito como demonstração.

Guia de consolidação em `guias-estudo/guia-estudo-fase8-grc-risco-conformidade-auditoria.md`.
