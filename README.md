# Cybersecurity Home Lab — Learning Diary

*[🇵🇹 Versão em português](./README.pt.md)*

## Why this repository exists

I'm a beginner cybersecurity student. This repository isn't a finished product or a demonstration of expertise — it's an **honest record of how I'm learning**, building and using a home lab of virtual machines (VMware Workstation) to practice hands-on, safely.

Documenting everything, including what went wrong, is intentional. Most cybersecurity material found online shows only the final result — the attack that worked, the command that was right the first time. That's useful to copy, but it hides the most important part of learning: the mistakes, the dead ends, and the reasoning that gets you from "I don't know why this isn't working" to "oh, that's why."

## What you'll find here

- **[`registo-laboratorio-ciberseguranca.md`](./registo-laboratorio-ciberseguranca.md)** — the main log, entry by entry, of every exercise: objective, commands used, what was expected, what actually happened, how to defend against the attack in question, and — whenever applicable — **what went wrong or failed**. Also mapped, where relevant, to the certification domains I'm studying (Security+, CEH, ISO/IEC 27001, NIS2, CompTIA A+). Written in Portuguese — it's my native language, and honest, in-the-moment reflection comes easier in it.
- **`registo-laboratorio-ciberseguranca.pdf`** — the same content, with embedded screenshots, for reading outside GitHub.
- **`screenshots/YYYY-MM-DD/`** — illustrative screenshots from each day of work.
- **`guias-estudo/`** — topic-by-topic consolidation notes (analogies, step-by-step reasoning, honest self-assessment of understanding), kept separate from the technical log.
- **[`glossario.md`](./glossario.md)** — technical terms explained simply, updated as they appear in the log.

## Why these tools

- **VMware Workstation** — fully isolates the lab from the home network, with several machines running at once, no risk to the real system.
- **OPNsense** — open-source firewall/router (gateway at `192.168.10.254`), used to manage the internal network and internet egress, and to practice real firewall configuration: egress filtering rules, DHCP reservations, and IDS.
- **Kali Linux** — the industry-standard security testing distribution, with pentest tools pre-installed, used as the attacker machine.
- **DVWA (Damn Vulnerable Web Application)** — an intentionally vulnerable web app with increasing difficulty levels, chosen for being didactic and mapping directly to the OWASP Top 10.
- **Docker** — used to install and manage DVWA in an isolated way that's easy to reset, without "dirtying" the vulnerable server's underlying system.
- **Windows Server + Active Directory (AD DS)** — the lab's Domain Controller (`lab.local`), used to practice identity management, Group Policy (GPO), and hardening a Windows domain.
- **Windows 11 and Ubuntu Desktop** — client machines: Windows 11 joined to the `lab.local` domain, Ubuntu Desktop as the VPN server.
- **WireGuard** — a modern VPN, set up manually (Ubuntu Desktop as server, Windows 11 as client) to understand traffic encryption and tunneling hands-on.
- **Suricata (IDS)** — intrusion detection built into OPNsense, used to observe and alert on suspicious traffic on the lab network.
- **Wazuh** — open-source SIEM/HIDS platform, installed manually (no Docker) to monitor and correlate security events across the lab's machines.
- **Metasploit, Hydra, nmap, Wireshark/tcpdump** — attack and analysis tools used throughout: enumeration, brute force, service exploitation, and traffic capture/analysis.
- **Git / GitHub** — version control and progress history, and also a public learning portfolio.

## The spirit of this repository

- **Not a finished product.** Updated session by session, as the exercises happen — not rewritten at the end to look more polished than it actually was.
- **Mistakes stay in, not erased.** If a command failed, if a network configuration broke mid-exercise, if an assumption was wrong — it's documented exactly as it happened, because that's where the real learning is.
- **Visible progress over time.** The earliest entries will look more hesitant or more basic than the later ones — that's expected. Comparing Entry #1 to an entry a few months later should clearly show the progress.

## Current status

The project moves through **phases**. Full detail for every exercise (commands, what went wrong, defenses, certification mapping) is in the [main log](./registo-laboratorio-ciberseguranca.md), entry by entry. This section is just the overview.

### Phase 1 — Building the lab (2026-08-02)
Lab built in VMware Workstation, on an isolated internal network (`192.168.10.0/24`) behind OPNsense: Kali (attacker), Vulnerable Server, and the router/firewall. DVWA installed via Docker on the Vulnerable Server, and the first exploitation exercise (SQL Injection, Low) completed successfully.

### Phase 2 — Web exploitation with DVWA (completed)
A full pass through the OWASP Top 10 modules in DVWA, each one from **Low** to **Impossible**, always with the same logic: exploit the flaw, understand why it works, and identify the correct defense.

- **SQL Injection** — from login bypass to reading the database; defense: prepared statements.
- **Command Injection** — RCE via the ping field; blacklists bypassed, whitelist as the robust defense.
- **XSS** (Reflected, Stored, and DOM) — JavaScript injection, session cookie theft; defense: output encoding.
- **CSRF** — password change without ever touching the real form; defense: anti-CSRF tokens.
- **File Upload** and **File Inclusion** — including **chaining** the two together for full RCE (web shell).
- **Brute Force** — manual attack, then with **Hydra**, plus a bypass of both the anti-CSRF token and rate limiting; closed out by the Impossible level, stopped by an **account lockout policy**.

Each module has a consolidation guide in [`guias-estudo/`](./guias-estudo/).

### Phase 3 — WireGuard VPN (completed, 2026-08-22)
VPN set up by hand, command-line, to understand every step: **Ubuntu Desktop as the server**, **Windows 11 as the client**. Tunnel established, and — the core teaching goal — **traffic encryption confirmed** by capturing packets on Kali (Wireshark/tcpdump), showing the content travels encrypted.

### Phase 4 — Network and service exploitation (completed, 2026-08-22/23)
Moving from the web application down to the operating system services of the Vulnerable Server (installed manually, not in Docker, by deliberate choice):

- **vsftpd** with misconfigured anonymous write access, chained with a misconfigured **Apache** pointed at the same folder → full **RCE** via a PHP web shell uploaded over FTP.
- Formal **enumeration** with **nmap**; an honest investigation of **Optionsbleed** (CVE-2017-9798) — a related bug confirmed, but the main vulnerability **not** reproduced in practice.
- **Brute force** against FTP and **MariaDB** credentials with the **Metasploit Framework**, and an anonymous **Samba** share.

### Phase 5 — Windows Server, hardening and detection (completed, 2026-08-24/25)
The final phase before publication, focused on building **and defending** infrastructure, not just attacking it:

- **Active Directory** — Windows Server promoted to Domain Controller (`lab.local`), with an OU structure and a test account; **Windows 11 joined the domain**.
- **Group Policy (GPO)** — a legal login banner and an **account lockout policy** (tying directly back to the Brute Force module in Phase 2), both confirmed working in practice.
- **OPNsense hardening** — egress filtering applied across all four lab VMs except Kali (which keeps internet access as the attacker machine), and **Suricata (IDS)** enabled with ~1160 rules, confirmed detecting real scan traffic.
- **Wazuh (SIEM/HIDS)** — a dedicated VM built from scratch, full manual install of the stack (Indexer, Manager, Filebeat, Dashboard), agents registered across the lab's machines, and a real detection test: replaying a known attack (anonymous FTP → RCE) with Wazuh watching, finding — and then fixing — a real coverage gap in the default configuration.

With Phase 5 closed, the lab currently covers full web-application offense (DVWA), a self-built secure VPN, network/service exploitation, Windows domain administration, and two complementary layers of defense — prevention (firewall, egress filtering) and detection (network IDS with Suricata, SIEM/HIDS with Wazuh).

### Phase 6 — Active Directory attacks (planned)
The next phase closes the loop back to offense: attacking the Active Directory domain built in Phase 5 — enumeration, Kerberoasting, BloodHound-driven attack-path analysis, lateral movement — while Wazuh watches, to see firsthand what a SIEM catches by default and what it misses.
