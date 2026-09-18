# Fase 7 (proposta) — Blue Team: Deteção e Resposta

O projeto subiu bem o lado do **ataque** (aplicações web → serviços de rede → Active Directory) e foi acrescentando **deteção** ataque a ataque (Suricata, Wazuh, regras próprias). A Fase 7 inverte a cadeira: sentas-te por inteiro como **defensor** e olhas para trás, de forma sistemática, sobre tudo o que fizeste — o que a tua deteção apanha, o que lhe escapa, e o que farias mesmo perante um incidente. Fecha o arco "quebrar → proteger" do projeto.

É uma fase **100% defensiva** (zero fricção com as salvaguardas dos modelos), pensada em blocos de ~1h como o resto, e alinhada com o perfil híbrido: compreender deteção e defesa, não aprofundar ataque ofensivo. Cobre sobretudo Security+ D4, NIS2 e ISO/IEC 27001.

**Só arranca depois de a Fase 6 fechar mesmo** — Entrada #98 provada por inteiro (o disparo final do Responder para o mDNS) e o guia de consolidação da Fase 6.

---

## 7.0 — Baseline de visibilidade (pré-requisito)

Inventariar e confirmar a stack de deteção antes de a avaliar: agentes Wazuh ativos em todas as VMs monitorizadas, Suricata no OPNsense, Sysmon no Windows Server e no Windows 11. Que fontes de log existem mesmo (Windows Security, Sysmon via `eventchannel`, Suricata, `syscheck`/FIM) e que relógios estão sincronizados (lição da Entrada #87). Curto — a maior parte já vem da Fase 6.0.

**Domínios:** Security+ D4 (Operações — visibilidade/telemetria); NIS2.

## 7.1 — Mapa de cobertura de deteção (MITRE ATT&CK) — o coração da fase

Pegar em cada ataque já feito na prática (as 19 linhas da `tabela-resumo-ataques.xlsx`) e, um a um, responder: **a minha deteção atual apanha isto?** Construir uma matriz de cobertura mapeada a técnicas MITRE ATT&CK, com três estados: **verde** (deteta com alerta), **amarelo** (o dado existe mas sem alerta dedicado), **vermelho** (invisível). As células vermelhas honestas valem tanto como as verdes — são o retrato real da "dívida de deteção" (lição da Entrada #93). É exatamente o que um SOC faz.

**Entregável:** um mapa de cobertura (ficheiro próprio, ex.: `.xlsx` como a tabela-resumo, ou markdown).
**Domínios:** Security+ D4; ISO 27001 A.8.15/A.8.16; NIS2.

## 7.2 — Fechar as lacunas prioritárias

Escolher 1-2 vermelhos/amarelos do 7.1 e escrever/afinar regras Wazuh para os fechar — reaproveitando o músculo das Sessões 6.6/6.7 e a skill `validar-regra-wazuh`. Candidatos naturais: detetar o próprio **Responder** (um host a responder a LLMNR/NBT-NS/mDNS que não devia), ou correlacionar a **sequência de reconhecimento** do 6.1. Documentar o percurso completo (hipóteses descartadas incluídas), como sempre.

**Domínios:** Security+ D4; NIS2.

## 7.3 — Threat hunting proativo

Sair do modo "esperar por alerta" e entrar no modo caçador: formular uma hipótese explícita (ex.: "se alguém fez Kerberoasting, veria 4769 com RC4 de uma conta não-máquina") e ir procurar no dado do Wazuh/Indexer, **mesmo sem alerta a disparar**. Praticar a mentalidade de hunting sobre os próprios ataques da Fase 6. Liga à lição da Entrada #93: todos os indicadores de saúde de um SIEM medem que ele *funciona*, não que *deteta o que interessa*.

**Domínios:** Security+ D4; CEH (perspetiva defensiva).

## 7.4 — Resposta a incidentes: playbook + simulação

Pegar num ataque concreto já feito (candidato forte: o **FTP anónimo → RCE** da Fase 4, ou o **Kerberoasting**) e correr o ciclo completo de resposta a incidentes: **detetar → triar → conter → erradicar → recuperar → lições aprendidas**. Escrever como um **playbook reutilizável** (documento próprio), com o Wazuh a vigiar a simulação.

**Domínios:** NIS2 (gestão e notificação de incidentes); ISO 27001 A.5.24-A.5.28; Security+ D4.

## 7.5 — Baseline de hardening consolidado

Juntar todas as defesas espalhadas pelo projeto num só documento — "o estado defendido do lab": egress filtering (OPNsense), política de bloqueio de conta (AD), aviso de login (GPO), Suricata, Wazuh, LLMNR/NBT-NS/mDNS desligados (Entrada #98), SMB signing, passwords fortes/gMSA. É o conceito de um **CIS Benchmark** / baseline de segurança aplicado ao teu próprio ambiente.

**Entregável:** um documento `hardening-baseline.md` (ou uma secção no README).
**Domínios:** ISO 27001 (controlos do Anexo A); Security+ D3/D4; CIS Benchmarks (conceito).

## 7.6 — Balanço e publicação — fecha o projeto

Mesmo espírito de fecho: o que a fase Blue Team mudou na maturidade defensiva do lab, e publicar o projeto completo no GitHub como um arco fechado (ataque → deteção → resposta → hardening). Ponte para o **Projeto 2 (GRC / Governança)**, se for essa a direção seguinte.

**Domínios:** transversal.

---

## Notas

- Fase **100% defensiva** — sem fricção com as salvaguardas de cibersegurança dos modelos.
- Dois artefactos de portefólio de alto valor para um lugar júnior de SOC/Blue Team: o **mapa de cobertura** (7.1) e o **playbook de resposta** (7.4).
- **Só arranca** depois de a Fase 6 fechar mesmo (Entrada #98 provada por inteiro + guia de consolidação da Fase 6).
- Isto é uma **proposta/rascunho** — ajusta a ordem, remove ou acrescenta blocos antes de começar, tal como fizeste com a Fase 6.
- Alinhada com o **perfil híbrido** (roteiro): foco em compreender deteção e defesa, não em aprofundar perícia ofensiva.
