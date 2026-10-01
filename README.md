# Cybersecurity Home Lab — Learning Diary

*[🇵🇹 Versão em português](./README.pt.md)*

## Why this repository exists

I'm a beginner cybersecurity student. This repository isn't a finished product or a demonstration of expertise — it's an **honest record of how I'm learning**, building and using a home lab of virtual machines (VMware Workstation) to practice hands-on, safely.

Documenting everything, including what went wrong, is intentional. Most cybersecurity material found online shows only the final result — the attack that worked, the command that was right the first time. That's useful to copy, but it hides the most important part of learning: the mistakes, the dead ends, and the reasoning that gets you from "I don't know why this isn't working" to "oh, that's why."

## What you'll find here

- **[`registo-laboratorio-ciberseguranca.md`](./registo-laboratorio-ciberseguranca.md)** — the main log, entry by entry, of every exercise: objective, commands used, what was expected, what actually happened, how to defend against the attack in question, and — whenever applicable — **what went wrong or failed**. Also mapped, where relevant, to the certification domains I'm studying (Security+, CEH, ISO/IEC 27001, NIS2, CompTIA A+). Written in Portuguese — it's my native language, and honest, in-the-moment reflection comes easier in it.
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

### Timeline

| Phase | Period | What was learned |
|---|---|---|
| 1 — Building the lab | 2026-08-02 | Set up an isolated network and run the first exploit (SQL Injection) |
| 2 — Web exploitation (DVWA) | until 2026-08-17 | Every web flaw has its own defense — and weak defenses (blacklists) get bypassed |
| 3 — WireGuard VPN | until 2026-08-22 | Encryption hides the content, but not the metadata |
| 4 — Network services | 2026-08-22/23 | Misconfigured services (anonymous FTP, Samba, MariaDB) chain into full compromise |
| 5 — Windows Server, hardening and detection | 2026-08-24/25 | Having a detection tool installed is not the same as detecting the attack |
| 6 — Active Directory attacks | 2026-08-30 to 2026-09-18 | AD attacks exploit configuration, not software bugs — and, by default, the SIEM doesn't see them |
| 7 — Blue Team: detection, response and hardening | 2026-09-20 to 2026-09-25 | Detect, respond, harden — and put the remaining gaps in writing |
| 8 — GRC: risk, compliance and audit | 2026-09-27 to 2026-10-01 | A written policy is not a control: it only becomes one once you verify the system follows it — and accepting a risk is a decision you put in writing |

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

### Phase 6 — Active Directory attacks (completed, 2026-08-30 to 2026-09-18)
Closing the loop back to offense: attacking the Active Directory domain built in Phase 5, with Wazuh watching, to see firsthand what a SIEM catches by default and what it misses — then turning to defense.

- **Enumeration without credentials**, **BloodHound** (attack-path analysis), **Kerberoasting** and **AS-REP Roasting** — extracting crackable password hashes from Kerberos service tickets, cracked offline with hashcat.
- **Wazuh detection rules for Kerberos events** (4768/4769) — a custom correlation rule to flag Kerberoasting (RC4 ticket encryption instead of AES for a service ticket request), including a real debugging chase through a silent factory rule that was claiming the event before the custom rule could evaluate it.
- **LLMNR/NBT-NS poisoning with Responder** — capturing a real NTLMv2 hash from the Windows 11 client with no prior credentials, confirmed step by step in Wireshark (multicast fallback, hop limit 1, no authentication).
- **Defensive balance and hardening (closing session)** — mapping each attack to its concrete defense; LLMNR disabled via GPO, NBT-NS and mDNS disabled client-side (a documented ADMX limitation), proven with a fresh Responder capture showing zero poisoning across all three channels.

Pass-the-Hash and the optional DCSync/Golden Ticket persistence exercise were intentionally left out of hands-on practice — covered only at a conceptual level, a decision recorded in Entry #98 of the lab log and in `fase6-proposta-ad-attacks.md`. Consolidation guide at `guias-estudo/guia-estudo-fase6-active-directory.md`.

### Phase 7 — Blue Team: Detection and Response (completed, 2026-09-20 to 2026-09-25)
Turning the chair around: sitting fully as defender and looking back, systematically, at what the lab's detection actually catches. 100% defensive.

- **Visibility baseline** — re-verified the full detection stack (Wazuh, Sysmon, Suricata); found and fixed a real Suricata misconfiguration (engine bound to the wrong network interface) plus a separate restart-loop failure invisible in the GUI, confirmed fixed with 27 fresh IDS alerts from a live scan.
- **MITRE ATT&CK detection coverage map** — audited all 19 attacks already performed hands-on, rating each as detected / partially detected / invisible against the current setup — an honest map of real detection debt, not just wins.
- **Closing priority gaps** — writing dedicated Wazuh rules for the gaps found above. First closed: AS-REP Roasting (Kerberos Pre-Authentication Type 0), validated end to end. Along the way, found and fixed a silent `wazuh-remoted` outage that had disconnected three agents unnoticed. Second gap turned out not to be a gap at all: a live-fired anonymous SMB logon event revealed it was already caught by a Wazuh factory rule (NTLM anonymous logon / possible pass-the-hash) that a purely static rule-file review had missed — corrected in the coverage map rather than writing a redundant rule. Third gap (anonymous FTP write + Apache = RCE via a PHP web shell) was real: the exploit request was decoded but fell into a generic zero-level rule, so a new rule flags the `cmd=`/`exec=`/`command=` pattern in the decoded URL — the highest-severity custom rule in the lab so far, since it confirms active code execution rather than an attempt.
- **Proactive threat hunting** — first hypothesis formulated before looking at any data (BloodHound, Entry #90), tested directly against the Wazuh Indexer API, bypassing the Dashboard. The hypothesis was partly wrong: an alert does fire (factory rules `92652`/`92657`), but it's a false positive by shared mechanism (NTLM Type 3 logon), not genuine technique detection — the coverage map was corrected to reflect this precisely (row 16 stays 🟡, now for the right reason).
- **Incident response — playbook + full simulation** — practiced the detect → triage → contain → eradicate → recover → lessons-learned cycle on a real lab incident (anonymous FTP + Apache = RCE via web shell). The first containment attempt (an OPNsense firewall rule) failed silently — attacker and target share the same L2 segment, so traffic never crosses the gateway — fixed with host-level containment (`iptables`). Eradication uncovered four web shells, not one; root cause fixed in two layers (anonymous FTP made read-only + PHP execution disabled in the upload folder). A reusable playbook was delivered at `playbook-resposta-incidentes.md`.
- **Consolidated hardening baseline** — gathered every defense in the project into one document (`hardening-baseline.md`), each one re-verified live, not just on paper: egress filtering fixed (a Windows Update exception had silently reverted between sessions), Suricata confirmed by shell (the GUI had already shown "running" with a dead process once before), Wazuh and LLMNR/NBT-NS/mDNS re-tested successfully, SMB signing reconfirmed. Two honest gaps documented as deliberate risk acceptance rather than oversight: the VMs behind egress filtering are never patched, and two service accounts keep weak passwords on purpose.

### Phase 8 — GRC: risk, compliance and audit (completed, 2026-09-27 to 2026-10-01)
Stepping out of the technical work and looking at the lab as a small organization: a fictional company (a micro-business of 6-8 employees running an order application) that gets the risk assessment, compliance work and audit a real organization would need. No new attacks: what is real is the technical evidence behind every risk.

- **Asset inventory and classification** — each VM tied to a fictional business function and rated for confidentiality, integrity and availability; the live check turned up a real finding (DVWA was down and nobody had noticed).
- **Evidence-backed risk register** — a probability-by-impact matrix (1-3), inherent and residual risk, every risk linked to the log entry that proves it. It started with 7 risks and closed with 8 (`registo-riscos.xlsx`).
- **Risk treatment and partial Statement of Applicability** — for each risk, a written decision to mitigate or accept, mapped to ISO/IEC 27001 controls (`declaracao-aplicabilidade-parcial.md`).
- **Three policies** — access control and passwords, logging and monitoring, vulnerability management and secure configuration (`politicas/` folder).
- **Live internal audit** — "the policy says X, does the lab do X?", across five items: four compliant and two non-compliant, both fixed (7-character passwords against the policy's 16; no 90-day retention applied to Wazuh logs). The retention fix failed the first time, was caught by a second independent check, and was proven on a brand-new index.
- **NIS2 and GDPR applied to real lab incidents** — the FTP-to-RCE incident (Entry #104) and the email captured in Entry #97, covering notification deadlines, applicability by company size and a new step in the incident-response playbook ("Phase 2b").
- **Review and Phase 9 programme** — a prioritized list of what remains, keeping risks, control gaps, technical checks and legal questions apart. An eighth risk (VMs with no backup) was assessed from facts and accepted in writing, and risk #5 was rewritten after its cited evidence turned out to prove something else. The lesson that weighed most was the intersection between the physical host and the VMs: disks, space and backups are the same.

Two gaps stay honestly on the record: the legal questions still to be confirmed in the official text (articles 40 to 44, how the 30 working days are counted, whether an online retailer is in scope) and the critical Kerberoasting/AS-REP risk, accepted on purpose as a demonstration.
