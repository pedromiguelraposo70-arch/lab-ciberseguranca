# Fase 6 (proposta) — Ataques ao Active Directory, com o Wazuh a vigiar

Continuação natural da Fase 5: já tens um domínio real (`lab.local`), um cliente Windows 11 juntado a ele, e o Wazuh já a monitorizar o Servidor Vulnerável e o Ubuntu Desktop. Esta fase fecha o mesmo ciclo "quebrar → proteger" que já seguiste nas Fases 2→3 e 4→5, mas desta vez o alvo é o próprio Active Directory que construíste — e o Wazuh fica a testemunha, a dizer o que apanhou e o que não apanhou.

Pensada em blocos de ~1h, como o resto do projeto. Cada bloco fecha com "o que fica pendente" para retomares na sessão seguinte.

---

## 6.0 — Preparação: dar ao Wazuh olhos para ver isto (pré-requisito)

Sem isto, grande parte dos ataques desta fase vai ficar invisível ao teu SIEM — o que tira todo o valor pedagógico de "ver o que é detetado".

- Confirmar/fechar a pendência da Entrada #87 (agente Wazuh do Windows 11 em estado *Pending*).
- Registar o agente Wazuh no Windows Server (Controlador de Domínio), se ainda não estiver feito.
- Instalar o **Sysmon** (configuração pública tipo SwiftOnSecurity ou Olaf Hartong) no Windows Server e no Windows 11 — sem ele, o Windows Event Log sozinho vê muito pouco dos ataques a AD (Kerberoasting, DCSync, etc.).
- Confirmar no Wazuh Dashboard que os eventos de segurança do Windows (Security log) e do Sysmon estão mesmo a chegar.

**Domínios:** Security+ D4 (Operações — visibilidade, telemetria), CEH D3.

---

## 6.1 — Enumeração do AD sem credenciais (vista de atacante externo)

O que um atacante vê do domínio antes de ter qualquer conta válida: `nmap` com scripts LDAP/SMB dedicados, bind LDAP anónimo (se permitido), enumeração SMB com `netexec`/`crackmapexec` sem credenciais.

**Domínios:** CEH D2 (Reconhecimento e Scanning).

## 6.2 — Enumeração autenticada + BloodHound

Com uma conta de domínio de baixo privilégio (`uteste`, já existe), recolher dados do AD com um collector (SharpHound ou `bloodhound-python` a partir do Kali) e visualizar caminhos de ataque no BloodHound — "quem, na prática, consegue chegar a Domain Admin a partir daqui".

Esta é provavelmente a sessão mais valiosa para o teu perfil (compreender caminhos de ataque > dominar exploits individuais).

**Domínios:** CEH D3/D5, Security+ D3 (arquitetura, princípio do menor privilégio).

## 6.3 — Kerberoasting

Pedir tickets de serviço (TGS) para contas com SPN, extrair o hash, tentar quebrar offline (`hashcat`/`john`) com uma wordlist. Mostra por que passwords de contas de serviço têm de ser fortes/rotativas.

**Domínios:** CEH D3 (System Hacking), Security+ D2.

## 6.4 — AS-REP Roasting (se aplicável)

Contas sem pré-autenticação Kerberos obrigatória são vulneráveis a um ataque semelhante ao Kerberoasting, sem precisar de credenciais válidas. Se não houver nenhuma conta assim no domínio, criar uma de propósito para o exercício (documentando isso com honestidade, como sempre).

**Domínios:** CEH D3, Security+ D2.

## 6.5 — Ponto de situação: o que o Wazuh viu (e o que não viu)

Sessão dedicada, sem ataque novo: rever o Dashboard depois de 6.1–6.4, perceber lacunas de deteção por defeito (tal como na Entrada #86 com o FTP), e decidir se vale a pena adicionar regras Wazuh específicas (ex.: muitos pedidos de TGS num curto espaço de tempo = indicador de Kerberoasting, Event ID 4769).

**Domínios:** Security+ D4 (SIEM, deteção), NIS2/ISO 27001 (A.8.16).

## 6.6 — LLMNR/NBT-NS poisoning com Responder

Categoria de ataque diferente das anteriores (não precisa de nenhuma credencial prévia): capturar hashes NTLM na rede local por envenenamento de resolução de nomes. Bom contraste com o egress filtering já feito na Entrada #72 — mostra que a segmentação de saída não protege contra ataques *dentro* do mesmo segmento.

**Domínios:** CEH D6/D7 (Sniffing, ataques de rede), Security+ D3.

## 6.7 — Pass-the-Hash / movimento lateral

Usar um hash capturado/quebrado numa sessão anterior para autenticar noutra máquina sem saber a password em texto. Fecha a narrativa: roubo de credencial → movimento lateral.

**Domínios:** CEH D3, Security+ D3.

## 6.8 (opcional, mais avançado) — DCSync / Golden Ticket

Persistência e escalada ao nível do domínio inteiro. Mais avançado do que o resto da fase e mais próximo de perícia ofensiva pura — de acordo com a tua nota de orientação pessoal (perfil híbrido, não especialista técnico em pentest), esta sessão é **opcional**: só faz sentido se quiseres mesmo perceber o mecanismo ao detalhe, não é necessária para fechar a fase.

**Domínios:** CEH D3 (avançado).

## 6.9 — Balanço e hardening: fecha a fase

Para cada ataque feito (6.1–6.7), que defesa concreta o teria prevenido ou detetado mais cedo — e implementar pelo menos uma (ex.: Advanced Audit Policy para eventos Kerberos, remover SPNs desnecessários, política de password mais forte nas contas de serviço). Fecha a Fase 6 com o mesmo espírito da Fase 5: não só atacar, também corrigir.

**Domínios:** Security+ D3/D4, NIS2/ISO 27001.

---

## Notas

- Sequência pensada para seguir a ordem natural de um ataque real a AD (reconhecimento → credenciais → movimento lateral → persistência), não é obrigatório fazer tudo sem parar — cada bloco é uma sessão independente, como sempre.
- 6.5 é o ponto de charneira: sem ele, a fase fica só ofensiva e perde a alternância "quebrar → proteger" que dá sentido ao resto do projeto.
- Isto é uma proposta de rascunho — ajusta a ordem, remove ou acrescenta blocos antes de começarmos a primeira sessão.
