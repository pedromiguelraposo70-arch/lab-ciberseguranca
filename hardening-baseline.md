# Baseline de Hardening Consolidado — Fase 7.5

**Data de início:** 2026-09-25

## Objetivo

Ponto 7.5 da Fase 7 (Blue Team: Deteção e Resposta) — juntar num só documento todas as defesas já implementadas e provadas ao longo do projeto, espalhadas pelo registo principal. É o conceito de um **CIS Benchmark** / baseline de segurança aplicado ao próprio laboratório: não é trabalho novo, é auditoria e consolidação do que já foi feito, revisitando cada defesa para confirmar que continua de facto aplicada (não só "ficou aplicada da vez que foi configurada").

## Checklist de defesas a consolidar

1. ✅ Egress filtering (OPNsense) — **confirmado e corrigido em 2026-09-25**
2. ✅ Política de bloqueio de conta (Active Directory) — **confirmado em 2026-09-25**
3. ✅ Aviso de login (GPO) — **confirmado em 2026-09-25**
4. ✅ Suricata (IDS de rede no OPNsense) — **confirmado em 2026-09-25**
5. ✅ Wazuh (SIEM/HIDS — agentes, regras próprias) — **confirmado em 2026-09-25**
6. ✅ LLMNR / NBT-NS / mDNS desligados (Entrada #98) — **reconfirmado em 2026-09-25**
7. ✅ SMB signing — **reconfirmado em 2026-09-25**
8. 🔴 Passwords fortes de contas de serviço / gMSA — **lacuna honesta, documentada em 2026-09-25**
9. ✅ Gestão de patches (decisão consciente) — **registado em 2026-09-25**

---

## 1. Egress filtering (OPNsense)

**Estado:** ✅ Confirmado e corrigido em 2026-09-25.

**O que é e onde foi implementado:** regras de saída (LAN → WAN) no OPNsense que bloqueiam, por defeito, o acesso à internet a partir das VMs do lab que não precisam dele — reduzindo o impacto se alguma for comprometida (impede exfiltração de dados e contacto com infraestrutura de comando e controlo externa). Implementado originalmente no Servidor Vulnerável (Entrada #72) e depois alargado às restantes VMs-alvo (Entrada #80).

**VMs cobertas — 4 no total, bloqueio de saída à internet confirmado:**
- Servidor Vulnerável
- Windows Server (Controlador de Domínio)
- Windows 11
- Ubuntu Desktop

O Kali Linux foi deliberadamente excluído (é a máquina atacante, precisa de internet para atualizar ferramentas).

**Exceção necessária — Windows Update (Windows Server e Windows 11):** as duas VMs Windows precisam de saída para os servidores da Microsoft para se manterem atualizadas, mesmo com o resto do tráfego de internet bloqueado. Exceção configurada para as portas **TCP 443 (HTTPS) e TCP 80 (HTTP)**.

**Porquê a porta 80 também é necessária (não só a 443):** a validação de um certificado HTTPS inclui confirmar que não foi revogado, via **CRL/OCSP** (ver entrada no glossário) — e esse pedido de validação é tipicamente feito por HTTP simples, não HTTPS. Com só a porta 443 aberta, o `Get-WindowsUpdate` no Windows Server ficava preso indefinidamente em "Connecting to Microsoft Update server...", sem listar atualizações nem devolver erro claro — causa raiz diagnosticada nas Entradas #87/#92.

**Verificação feita em 2026-09-25 (Sessão 7.5):** ao rever as regras de egress filtering para este documento, confirmado que as 4 VMs continuam corretamente bloqueadas. A exceção de Windows Update (porta 80) tinha de ser reposta — corrigida a regra do OPNsense e testada com sucesso no Windows Server: `Get-WindowsUpdate` listou 5 atualizações disponíveis, incluindo o cumulative update de setembro de 2026 (KB5122882) e uma atualização de segurança do Microsoft Defender, sem ficar preso em "Connecting to Microsoft Update server...".

**Lição consolidada:** nunca confirmar uma defesa de firewall só pelo "a regra existe" — confirmar sempre o efeito real, com um teste funcional do outro lado (neste caso, o próprio `Get-WindowsUpdate` a listar atualizações).

---

## 2. Política de bloqueio de conta (Active Directory)

**Estado:** ✅ Confirmado em 2026-09-25 (valores inalterados desde a configuração original).

**O que é e onde foi implementado:** definição, ao nível do domínio (`Default Domain Policy`, GPMC → `Computer Configuration` → `Policies` → `Windows Settings` → `Security Settings` → `Account Policies` → `Account Lockout Policy`), que bloqueia automaticamente uma conta depois de um número definido de tentativas de login falhadas seguidas — defesa direta contra ataques de força bruta, ligando à Fase 2 do projeto (módulo Brute Force do DVWA). Configurada e testada na prática na Entrada #74 (fecho do bloco de Active Directory da Fase 5), forçando o bloqueio real da conta `uteste`.

**Valores configurados — confirmados diretamente no GPMC em 2026-09-25, iguais aos da Entrada #74:**
- **Account lockout threshold:** 5 tentativas de login inválidas
- **Account lockout duration:** 30 minutos
- **Reset account lockout counter after:** 30 minutos

**Nota de âmbito importante (já registada na Entrada #92):** esta defesa protege contra força bruta *direta* de password (muitas tentativas contra a mesma conta), mas é completamente cega a Kerberoasting e AS-REP Roasting — esses ataques recuperam a password offline, depois de um único pedido legítimo de ticket Kerberos, sem gerar nenhuma tentativa de login falhada. As duas famílias de ataque exigem defesas diferentes e complementares (bloqueio de conta vs. passwords fortes de contas de serviço/gMSA — ver ponto 8 deste documento).

**Verificação feita em 2026-09-25 (Sessão 7.5):** valores lidos diretamente no GPMC (screenshot do painel "Account Lockout Policy") — sem repetir o teste de bloqueio real (já provado na Entrada #74, e forçar o bloqueio da conta `uteste` de novo não traria informação nova). Confirmado que a política continua aplicada tal como foi definida, sem qualquer desvio.

---

## 3. Aviso de login (GPO)

**Estado:** ✅ Confirmado em 2026-09-25 (valores inalterados desde a configuração original).

**O que é e onde foi implementado:** GPO `Aviso-Login-Utilizadores`, ligada à OU `Computadores` (dentro de `OU=Lab`), que define um aviso legal a apresentar antes do ecrã de login em qualquer computador do domínio dentro dessa OU — `Computer Configuration` → `Policies` → `Windows Settings` → `Security Settings` → `Local Policies` → `Security Options`, políticas "Interactive logon: Message title for users attempting to log on" e "Interactive logon: Message text for users attempting to log on". Configurada na Entrada #70 e confirmada em produção na Entrada #71, com o efeito visual real a aparecer no ecrã de arranque do Windows 11 (bloqueando o acesso ao login até se clicar "OK").

**Conteúdo confirmado diretamente na GPO em 2026-09-25:**
- **Título:** "Aviso Legal – Laboratório de Cibersegurança"
- **Texto:** começa por "Este sistema faz parte de um laboratório privado de cibersegurança..." (texto completo definido na Entrada #70, não alterado)

**Nota de âmbito importante (já registada na Entrada #70):** a GPO só produz efeito nos computadores cujo objeto AD esteja fisicamente dentro da OU `Computadores` — não afeta automaticamente o próprio Windows Server (Controlador de Domínio), que fica no contentor `Domain Controllers` por defeito, fora do âmbito desta GPO. O aviso confirmado em produção foi especificamente no Windows 11.

**Verificação feita em 2026-09-25 (Sessão 7.5):** GPO `Aviso-Login-Utilizadores` ainda ligada à OU `Computadores`, com título e texto ainda definidos (`Define this policy setting` / `Define this policy setting in the template` ambos ativos) — confirmado diretamente na GPMC, sem repetir o teste visual no Windows 11 (já provado na Entrada #71).

---

## 4. Suricata (IDS de rede no OPNsense)

**Estado:** ✅ Confirmado em 2026-09-25, por shell (não só pela GUI — ver motivo abaixo).

**O que é e onde foi implementado:** Suricata, incluído no sistema base do OPNsense (`Services → Intrusion Detection`), a inspecionar tráfego na interface **LAN** (dispositivo `em1`, `192.168.10.0/24`) com os rulesets ET open/scan e ET open/attack-response — **1160 regras carregadas** (Entrada #76). Ativado inicialmente na Entrada #75/#76, com prova de deteção real via scan nmap na Entrada #77.

**Porquê a verificação de hoje não confiou só na GUI:** a Entrada #99 (2026-09-20, Sessão 7.0) encontrou o motor **completamente parado** duas vezes, por causas distintas — primeiro ligado à interface errada (`em0`/OPT1 em vez de `em1`/LAN, apesar da GUI mostrar "LAN" selecionado), depois um crash total do processo (proteção do sistema contra reinícios em loop, "flapping") em que **a GUI continuou a mostrar "a correr" mesmo sem nenhum processo vivo** — só descoberto por SSH (`ps aux`). Por essa razão, e seguindo essa lição diretamente, a confirmação de hoje foi feita por shell, não pela interface.

**Verificação feita em 2026-09-25 (Sessão 7.5), via SSH:**
```
ps auxww | grep suricata
→ /usr/local/bin/suricata -D --pcap=em1 --pidfile /var/run/suricata.pid -c /usr/local/etc/suricata/suricata.yaml
```
Processo vivo, ligado à interface correta (`em1`, LAN). O campo `STARTED` mostra "Thu07" (arrancado ontem, quinta-feira, por volta das 07h) — ou seja, não esteve vivo de forma contínua desde a correção da Entrada #99 (2026-09-20); houve pelo menos um reinício entretanto (reinício da VM ou nova paragem/arranque do serviço, causa não investigada agora). Consistente com a instabilidade já documentada — não é motivo de alarme, mas reforça por que este ponto precisa de confirmação por shell, não só de "ficar como está desde a última vez".

**Limitação estrutural conhecida (não é falha de configuração):** tráfego entre VMs no mesmo segmento de rede (ex.: Kali → Servidor Vulnerável, ambos em `192.168.10.0/24` no mesmo switch virtual) nunca atravessa o OPNsense, logo nunca é visto pelo Suricata — só tráfego que tem o próprio OPNsense como origem/destino, ou que atravessa sub-redes diferentes, é inspecionado (Entrada #77). Documentado também no `mapa-cobertura-mitre-attack.md` (limitação #1).

**Lição consolidada:** para este serviço específico, já confirmado que "o ícone mostra a correr" não é prova suficiente — a única confirmação fiável é um processo vivo visto diretamente por shell, ou um alerta novo e real gerado por um teste de tráfego.

---

## 5. Wazuh (SIEM/HIDS — agentes, regras próprias)

**Estado:** ✅ Confirmado em 2026-09-25, por shell.

**O que é e onde foi implementado:** Wazuh Manager (192.168.10.30) a receber eventos de 4 agentes instalados nas VMs do lab (`servidor-vulneravel`, `ubuntu-wg`, `windows-server`, `windows11`), com Sysmon nas duas VMs Windows para telemetria adicional. Complementa o Suricata (ponto 4) exatamente na limitação que este tem — deteção baseada no host (HIDS), não só na rede, cobrindo por isso o tráfego lateral entre VMs do mesmo segmento que o Suricata nunca vê.

**Regras próprias — 4 no total, todas confirmadas intactas em `local_rules.xml`:**
- `100010` (nível 5) — Kerberos: pedido de TGT (evento 4768), genérica
- `100011` (nível 10) — Kerberoasting: TGS com cifra RC4 para conta de serviço (evento 4769), Sessão 6.7
- `100012` (nível 10) — AS-REP Roasting: TGT sem pré-autenticação (evento 4768, `preAuthType: 0`), Sessão 7.2 (Entrada #100)
- `100013` (nível 12, a mais alta do lab) — RCE via web shell: pedido HTTP com parâmetro `cmd=`/`exec=`/`command=`, Sessão 7.2 (Entrada #102)

**Estado dos agentes confirmado em 2026-09-25 (`agent_control -l`):**
- `servidor-vulneravel` — **Active**
- `windows-server` — **Active**
- `ubuntu-wg` — **Disconnected**
- `windows11` — **Disconnected**

**Os dois "Disconnected" não são uma falha do Wazuh** — confirmado com o Pedro que as VMs Windows 11 e Ubuntu Desktop estavam simplesmente desligadas nesta sessão (não é necessário, nem prático, ter as 8 VMs do lab todas ligadas de cada vez). Um agente Wazuh só consegue reportar-se com a máquina de pé; isto é o comportamento esperado, distinto da instabilidade real já documentada nas Entradas #87 e #99 (onde as VMs estavam ligadas e o agente mesmo assim não respondia).

**Verificação feita em 2026-09-25 (Sessão 7.5), por SSH na VM Wazuh:**
```
sudo grep -o 'rule id="1000[0-3][0-9]*"' /var/ossec/etc/rules/local_rules.xml
→ 100010, 100011, 100012, 100013 (todas presentes)

sudo /var/ossec/bin/agent_control -l
→ servidor-vulneravel: Active | windows-server: Active | ubuntu-wg: Disconnected (VM desligada) | windows11: Disconnected (VM desligada)
```

**Lição consolidada:** ao contrário do Suricata (ponto 4), onde "Disconnected"/processo morto era sinal real de falha, aqui a mesma palavra ("Disconnected") pode significar duas coisas completamente diferentes — máquina desligada (normal, sem ação necessária) ou agente com problema numa máquina ligada (falha real, ver Entradas #87/#99). Nunca assumir qual das duas é, sem confirmar primeiro se a VM está mesmo de pé.

---

## 6. LLMNR / NBT-NS / mDNS desligados

**Estado:** ✅ Reconfirmado em 2026-09-25 por teste ao vivo com o Responder (não só configuração lida) — a defesa mais crítica de re-testar desta forma, por fechar diretamente o ataque de captura de credenciais da Entrada #97.

**O que é e onde foi implementado (Entrada #98, 2026-09-17/18):** os três mecanismos de fallback de resolução de nomes do Windows 11 desligados, fechando o vetor de ataque do Responder (Entrada #97):
- **LLMNR** — por GPO `Hardening-Desligar-LLMNR`, ligada à OU `Lab \ Computadores`: `Computer Configuration → Policies → Administrative Templates → Network → DNS Client → "Turn off multicast name resolution" = Enabled`.
- **NBT-NS** — diretamente no adaptador do Windows 11 (não existe definição nativa de GPO neste ADMX do Server): `ncpa.cpl → adaptador Ethernet → Propriedades → IPv4 → Advanced → separador WINS → "Disable NetBIOS over TCP/IP"`.
- **mDNS** — registo do Windows 11, `EnableMDNS = 0` (DWORD) em `HKLM\SOFTWARE\Policies\Microsoft\Windows NT\DNSClient` (a mesma chave onde vive o `EnableMulticast` do LLMNR).

**Verificação feita em 2026-09-25 (Sessão 7.5) — teste ao vivo com o Responder, não só leitura de configuração:**
1. Windows 11 e Kali ligados de propósito para este teste (estavam desligados; decisão consciente de não encurtar o caminho, por a máquina ser diretamente relevante ao ponto em verificação).
2. No Kali: `sudo responder -I eth0`, confirmado "Listening for events..." (LLMNR/NBT-NS/MDNS/DNS todos `[ON]`) **antes** de qualquer tentativa no Windows 11.
3. No Windows 11, já com o Responder a ouvir: `Win+R` → `\testelab7` (nome novo, nunca antes usado nos testes deste lab — `testelab3`, `ficheiros`, `testelab4`, `testelab5` e `testelab6` já tinham sido usados).
4. **Resultado no Windows 11:** erro limpo — "O Windows não consegue aceder a \testelab7. Verifique a ortografia no nome." — sem nenhum ecrã de "Introduzir credenciais de rede".
5. **Resultado no Kali:** o terminal do Responder ficou parado em "Listening for events..." — **zero linhas `[LLMNR]`, `[NBT-NS]` ou `[MDNS]`** durante todo o teste.

Resultado idêntico ao da confirmação final da Entrada #98 (`\testelab6`, 2026-09-18) — os três canais continuam completamente silenciados, mais de uma semana depois, sem sinal de regressão.

**Nota de âmbito importante (já registada na Entrada #98):** esta defesa só está aplicada no **Windows 11** (o cliente vítima no cenário do Responder). O Windows Server (DC) não foi hardened da mesma forma — não fazia parte do cenário de ataque original, que visava um posto de trabalho comum, não o próprio controlador de domínio.

**Lição consolidada:** ao contrário dos pontos 1-5 (onde bastou ler configuração ou confirmar um processo vivo), esta defesa só se prova mesmo com um ataque real a decorrer — a configuração pode estar tecnicamente correta e ainda assim existir um canal residual não coberto (como o mDNS revelou originalmente na própria Entrada #98). Um teste de configuração sozinho não teria apanhado isso da primeira vez, e não apanharia uma eventual regressão futura.

---

## 7. SMB signing

**Estado:** ✅ Reconfirmado em 2026-09-25. Diferente de todos os pontos anteriores: não é uma defesa que o Pedro configurou ativamente — é uma verificação de que o Windows Server já vinha, por defeito, corretamente protegido.

**O que é e onde foi confirmado (Entrada #89, Sessão 6.1):** durante a enumeração do Active Directory sem credenciais (do ponto de vista de um atacante externo), o fingerprinting SMB (`netexec smb 192.168.10.1`) confirmou que o Windows Server já tinha a **assinatura SMB ativa** e o **SMBv1 desativado** — sem qualquer configuração manual do Pedro. Isto fecha o vetor de **NTLM relay**: sem assinatura SMB, um hash NTLM capturado (ex.: via LLMNR/NBT-NS poisoning, ponto 6 deste documento) pode ser reencaminhado em tempo real para autenticar noutra máquina, sem sequer precisar de o quebrar offline — com a assinatura ativa, esse reencaminhamento é recusado.

**Nota lateral já investigada e resolvida (Entrada #89):** o mesmo `netexec` reporta `Null Auth: True` (a sessão SMB nula é aceite) — à primeira vista parece uma exposição, mas testes diretos (`--shares`, `--rid-brute`) confirmaram `STATUS_ACCESS_DENIED` em ambos: a sessão é aceite, mas `RestrictAnonymous = 1` bloqueia qualquer listagem ou operação real a partir dela. "Sessão aceite" não é o mesmo que "acesso concedido" — lição já registada na própria Entrada #89, reconfirmada de novo na Entrada #101 (Sessão 7.2).

**Verificação feita em 2026-09-25 (Sessão 7.5), com o Kali já ligado:**
```
netexec smb 192.168.10.1
→ Windows Server 2022 Build 20348 x64 (name:WIN-54OBK8B48L5) (domain:lab.local)
  (signing:True) (SMBv1:None) (Null Auth:True)
```
`signing:True` confirmado, inalterado desde a Entrada #89. `Null Auth:True` continua presente mas, como já estabelecido, sem exposição real por trás (RestrictAnonymous ainda a bloquear).

**Lição consolidada:** este ponto é o inverso metodológico dos outros oito — aqui o risco não é "a configuração reverter", é **assumir que algo está protegido só porque nunca foi preciso configurá-lo**. Um valor "seguro por defeito" merece a mesma confirmação periódica que um valor configurado manualmente, porque um valor por defeito pode mudar silenciosamente (ex.: numa reinstalação, numa imagem base diferente, ou numa alteração de política herdada de outro sítio) sem que ninguém o tenha decidido.

---

## 8. Passwords fortes de contas de serviço / gMSA

**Estado:** 🔴 Lacuna real e conhecida, não uma defesa implementada — documentada com honestidade em 2026-09-25, seguindo a mesma convenção do mapa de cobertura MITRE ATT&CK (células vermelhas honestas valem tanto como as verdes).

**Situação atual:** as duas contas de serviço criadas no lab têm passwords fracas **de propósito**:
- `svc_sql` — password `Password123` (Entrada #91, Kerberoasting), quebrada em menos de um segundo por hashcat.
- `svc_legacy` — password `Welcome123` (Entrada #92, AS-REP Roasting), quebrada em ~2 segundos.

Nenhuma **gMSA** (group Managed Service Account — conta de serviço com password longa, aleatória e rotativa automaticamente pelo AD) foi implementada neste lab.

**Porque é que isto não foi corrigido:** exatamente pela mesma razão do ponto 9 (gestão de patches) — corrigir as passwords destas duas contas específicas quebraria a reprodutibilidade dos exercícios de Kerberoasting e AS-REP Roasting já documentados (Entradas #91 e #92), que dependem precisamente dessas passwords fracas para a demonstração funcionar. É uma decisão consciente, não um esquecimento — mas ao contrário do ponto 9 (onde o risco fica mitigado pelo isolamento da rede), aqui a exposição é interna ao próprio design do lab: qualquer conta autenticada do domínio consegue pedir um ticket de serviço para estas contas e tentar quebrar a password offline (Entrada #91), independentemente de egress filtering ou isolamento de rede — porque o ataque nunca sai do domínio.

**O que uma defesa real, num ambiente de produção, exigiria:**
- Passwords longas e aleatórias (idealmente geradas por um cofre de segredos), nunca memorizáveis.
- Preferencialmente, migração para **gMSA**, que elimina o problema por completo — a password é gerida e rodada automaticamente pelo AD, nunca é escrita ou memorizada por uma pessoa.
- Forçar **AES** em vez de RC4 nos tickets de serviço (reduz a velocidade de cracking offline mesmo que a password seja capturada).
- Auditoria periódica de contas com SPN e/ou `DoesNotRequirePreAuth` ativo (já referida nos pontos 6.3/6.4 do balanço defensivo da Entrada #98).

**Nota GRC:** isto é uma segunda aceitação de risco documentada neste projeto (a primeira é o ponto 9), pela mesma lógica: uma decisão consciente e justificada, escrita e assumida, vale mais — em maturidade de governança — do que uma correção silenciosa que apagaria a evidência do próprio ataque já demonstrado. Um leitor externo do repositório (ex.: um recrutador) vê aqui exatamente o que um exercício de risk acceptance real deveria mostrar: o risco identificado, a razão de não o corrigir agora, e o que corrigi-lo exigiria.

---

## 9. Gestão de patches (decisão consciente)

**Estado:** ✅ Decisão registada em 2026-09-25 — não é uma defesa "implementada" como as anteriores, é uma aceitação de risco documentada.

**Decisão:** as quatro VMs por trás do egress filtering (Servidor Vulnerável, Windows Server, Windows 11, Ubuntu Desktop) **não são atualizadas deliberadamente**. O Kali Linux é a exceção — é atualizado com regularidade, por necessidade prática: por ser uma distribuição rolling-release focada em ferramentas de ataque, 2-3 semanas sem atualizar acumulam facilmente centenas de pacotes pendentes. Esta é também a razão original por que o Kali foi excluído do egress filtering desde a Entrada #80 (precisa de saída livre para internet).

**Porquê não atualizar as outras quatro:**
- **Reprodutibilidade dos exercícios já documentados:** nenhum dos ataques feitos até agora (Kerberoasting, AS-REP Roasting, LLMNR/NBT-NS/mDNS poisoning, força bruta) depende de uma CVE específica corrigível por patch — dependem de comportamento de protocolo (Kerberos, LLMNR) e de configuração (passwords fracas em contas de serviço, `DoesNotRequirePreAuth`). Manter as VMs congeladas garante que o que já foi demonstrado continua reproduzível.
- **Custo operacional do reinício do Controlador de Domínio:** instalar atualizações no Windows Server pede reinício, e reiniciar o DC a meio de uma sessão de ~1h interromperia o exercício em curso (já adiado conscientemente na Entrada #92).

**Risco aceite e porque é considerado baixo neste contexto específico:** um sistema sem atualizações tem, em abstrato, mais vulnerabilidades conhecidas por corrigir — é a causa raiz de muitos incidentes reais (ex.: ransomware a explorar CVEs já corrigidos há meses em organizações sem gestão de patches). Aqui o risco fica mitigado pelo isolamento da rede: as quatro VMs estão atrás do egress filtering confirmado no ponto 1, sem exposição a tráfego de entrada vindo da internet pública — não há praticamente ninguém de fora capaz de alcançar essas vulnerabilidades para as explorar. As defesas já implementadas nos outros pontos deste documento (bloqueio de conta, LLMNR desligado, SMB signing, etc.) continuam a funcionar de forma independente do nível de patch.

**Nota GRC:** isto é, em si, um exemplo de **aceitação de risco (risk acceptance)** formal — uma organização real por vezes escolhe conscientemente não corrigir algo por uma razão operacional válida (aqui, continuidade dos exercícios e evitar um reinício disruptivo), documentando a decisão e o porquê, em vez de deixar o tema por tratar silenciosamente. É exatamente essa prática, aplicada ao próprio lab.

**Lição já aprendida que reforça esta decisão:** uma correção pontual já feita e confirmada (a exceção de porta 80 do ponto 1, corrigida pela primeira vez na Entrada #92) tinha revertido sozinha até 2026-09-25, sem ninguém a editar essa regra deliberadamente — a hipótese mais provável é uma reversão de snapshot da VM do OPNsense. Isto é independente da decisão de não atualizar (é sobre uma regra de firewall, não sobre patches), mas reforça o princípio geral: mesmo estados já verificados como corretos podem reverter sem aviso entre sessões, e só se descobre voltando a testar.

