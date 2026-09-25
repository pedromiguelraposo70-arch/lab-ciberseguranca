# Baseline de Hardening Consolidado — Fase 7.5

**Data de início:** 2026-09-25

## Objetivo

Ponto 7.5 da Fase 7 (Blue Team: Deteção e Resposta) — juntar num só documento todas as defesas já implementadas e provadas ao longo do projeto, espalhadas pelo registo principal. É o conceito de um **CIS Benchmark** / baseline de segurança aplicado ao próprio laboratório: não é trabalho novo, é auditoria e consolidação do que já foi feito, revisitando cada defesa para confirmar que continua de facto aplicada (não só "ficou aplicada da vez que foi configurada").

## Checklist de defesas a consolidar

1. ✅ Egress filtering (OPNsense) — **confirmado e corrigido em 2026-09-25**
2. ✅ Política de bloqueio de conta (Active Directory) — **confirmado em 2026-09-25**
3. ✅ Aviso de login (GPO) — **confirmado em 2026-09-25**
4. ⬜ Suricata (IDS de rede no OPNsense)
5. ⬜ Wazuh (SIEM/HIDS — agentes, regras próprias)
6. ⬜ LLMNR / NBT-NS / mDNS desligados (Entrada #98)
7. ⬜ SMB signing
8. ⬜ Passwords fortes de contas de serviço / gMSA
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

## 9. Gestão de patches (decisão consciente)

**Estado:** ✅ Decisão registada em 2026-09-25 — não é uma defesa "implementada" como as anteriores, é uma aceitação de risco documentada.

**Decisão:** as quatro VMs por trás do egress filtering (Servidor Vulnerável, Windows Server, Windows 11, Ubuntu Desktop) **não são atualizadas deliberadamente**. O Kali Linux é a exceção — é atualizado com regularidade, por necessidade prática: por ser uma distribuição rolling-release focada em ferramentas de ataque, 2-3 semanas sem atualizar acumulam facilmente centenas de pacotes pendentes. Esta é também a razão original por que o Kali foi excluído do egress filtering desde a Entrada #80 (precisa de saída livre para internet).

**Porquê não atualizar as outras quatro:**
- **Reprodutibilidade dos exercícios já documentados:** nenhum dos ataques feitos até agora (Kerberoasting, AS-REP Roasting, LLMNR/NBT-NS/mDNS poisoning, força bruta) depende de uma CVE específica corrigível por patch — dependem de comportamento de protocolo (Kerberos, LLMNR) e de configuração (passwords fracas em contas de serviço, `DoesNotRequirePreAuth`). Manter as VMs congeladas garante que o que já foi demonstrado continua reproduzível.
- **Custo operacional do reinício do Controlador de Domínio:** instalar atualizações no Windows Server pede reinício, e reiniciar o DC a meio de uma sessão de ~1h interromperia o exercício em curso (já adiado conscientemente na Entrada #92).

**Risco aceite e porque é considerado baixo neste contexto específico:** um sistema sem atualizações tem, em abstrato, mais vulnerabilidades conhecidas por corrigir — é a causa raiz de muitos incidentes reais (ex.: ransomware a explorar CVEs já corrigidos há meses em organizações sem gestão de patches). Aqui o risco fica mitigado pelo isolamento da rede: as quatro VMs estão atrás do egress filtering confirmado no ponto 1, sem exposição a tráfego de entrada vindo da internet pública — não há praticamente ninguém de fora capaz de alcançar essas vulnerabilidades para as explorar. As defesas já implementadas nos outros pontos deste documento (bloqueio de conta, LLMNR desligado, SMB signing, etc.) continuam a funcionar de forma independente do nível de patch.

**Nota GRC:** isto é, em si, um exemplo de **aceitação de risco (risk acceptance)** formal — uma organização real por vezes escolhe conscientemente não corrigir algo por uma razão operacional válida (aqui, continuidade dos exercícios e evitar um reinício disruptivo), documentando a decisão e o porquê, em vez de deixar o tema por tratar silenciosamente. É exatamente essa prática, aplicada ao próprio lab.

**Lição já aprendida que reforça esta decisão:** uma correção pontual já feita e confirmada (a exceção de porta 80 do ponto 1, corrigida pela primeira vez na Entrada #92) tinha revertido sozinha até 2026-09-25, sem ninguém a editar essa regra deliberadamente — a hipótese mais provável é uma reversão de snapshot da VM do OPNsense. Isto é independente da decisão de não atualizar (é sobre uma regra de firewall, não sobre patches), mas reforça o princípio geral: mesmo estados já verificados como corretos podem reverter sem aviso entre sessões, e só se descobre voltando a testar.

