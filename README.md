# Laboratório de Cibersegurança — Diário de Aprendizagem

## Porque é que este repositório existe

Sou estudante iniciante de cibersegurança. Este repositório não é um produto acabado nem uma demonstração de competência — é o **registo honesto de como estou a aprender**, montando e usando um laboratório de máquinas virtuais em casa (VMware Workstation) para praticar de forma prática e segura.

A decisão de documentar tudo, incluindo o que correu mal, é intencional. A maior parte dos materiais de cibersegurança que se encontram online mostram o resultado final — o ataque que funcionou, o comando certo à primeira. Isso é útil para copiar, mas esconde a parte mais importante do processo de aprendizagem: os erros, os becos sem saída, e o raciocínio que leva de "não sei porque é que isto não funciona" a "ah, era isto".

## O que vais encontrar aqui

- **[`registo-laboratorio-ciberseguranca.md`](./registo-laboratorio-ciberseguranca.md)** — o registo principal, entrada a entrada, de cada exercício: objetivo, comandos usados, o que era esperado, o que aconteceu de facto, como nos podemos defender do ataque em causa, e — sempre que aplicável — **o que correu mal ou falhou**. Também mapeado, quando faz sentido, para os domínios de certificações em estudo (Security+, CEH, ISO/IEC 27001, NIS2, CompTIA A+).
- **`registo-laboratorio-ciberseguranca.pdf`** — a mesma informação, com os screenshots embutidos, para leitura fora do GitHub.
- **`screenshots/AAAA-MM-DD/`** — capturas de ecrã ilustrativas de cada dia de trabalho.
- **`guias-estudo/`** — documentos de consolidação por tema (analogias, raciocínio passo a passo, autoavaliação honesta de compreensão), separados do registo técnico.
- **[`glossario.md`](./glossario.md)** — termos técnicos explicados de forma simples, atualizado à medida que aparecem no registo.

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
- **Metasploit, Hydra, nmap, Wireshark/tcpdump** — ferramentas de ataque e análise usadas ao longo das fases: enumeração, força bruta, exploração de serviços e captura/análise de tráfego.
- **Git / GitHub** — controlo de versões e histórico do progresso, também como portefólio público de aprendizagem.

## O espírito deste repositório

- **Não é um produto final.** É atualizado sessão a sessão, à medida que os exercícios acontecem — não reescrito no final para parecer mais polido do que foi na realidade.
- **Erros ficam registados, não apagados.** Se um comando falhou, se uma configuração de rede se partiu a meio de um exercício, se um pressuposto estava errado — isso fica documentado tal como aconteceu, porque é aí que está a aprendizagem real.
- **Evolução visível ao longo do tempo.** As primeiras entradas vão parecer mais hesitantes ou mais básicas do que as últimas — é suposto ser assim. Comparar a Entrada #1 com uma entrada de daqui a alguns meses deve mostrar claramente o progresso.

## Estado atual

O projeto avança por **fases**. O detalhe completo de cada exercício (comandos, o que correu mal, defesas, mapeamento a certificações) está no [registo principal](./registo-laboratorio-ciberseguranca.md), entrada a entrada. Este resumo dá só a visão geral.

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

### Fase 5 — Windows Server, hardening e deteção (em curso, 2026-08-24/25)
A última fase antes da publicação, focada em construir e **defender** infraestrutura, não só atacá-la:

- **Active Directory** — Windows Server promovido a Controlador de Domínio (`lab.local`), com estrutura de OUs e conta de teste; **Windows 11 juntado ao domínio**.
- **Políticas de Grupo (GPO)** — aviso legal de login e **política de bloqueio de conta** (que liga diretamente ao Brute Force da Fase 2), ambas confirmadas em produção.
- **Hardening do OPNsense** — *egress filtering* aplicado a quatro VMs (só o Kali mantém acesso à internet), e **Suricata (IDS)** ativado com ~1160 regras, confirmado a detetar tráfego real de um scan.

**Em falta para fechar a Fase 5:** o bloco **Wazuh** (SIEM/HIDS — deteção baseada em host), reservado para uma sessão futura. Depois disso, o projeto fica pronto para publicação.
