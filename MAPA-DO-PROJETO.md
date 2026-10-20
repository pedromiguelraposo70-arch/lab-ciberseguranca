# Mapa do Projeto — onde está cada coisa

**Para que serve:** é o ponto de entrada do repositório. Diz que documentos existem, para que serve cada um, quando foi atualizado pela última vez e se está em dia. Não substitui nenhum documento; aponta para eles.

**Estado em:** 2026-10-20 (fecho da Fase 9). **Regra:** este mapa atualiza-se no fecho de cada fase.

**Legenda:** ✅ em dia · 🟡 desatualizado ou incompleto (o que falta está indicado) · ⬜ não existe (a decidir se deve existir)

---

## 1. Por onde começar

| Quero... | Abro |
|---|---|
| a visão geral do projeto (EN / PT) | `README.md` / `README.pt.md` |
| o detalhe de qualquer exercício, comando ou decisão | `registo-laboratorio-ciberseguranca.md` (Entradas #1 a #130) |
| rever o que aprendi numa fase | `guias-estudo/` (tabela da secção 2) |
| saber onde está este próprio índice | aqui: `MAPA-DO-PROJETO.md` |

## 2. As fases e onde está cada uma

| Fase | Período | Entradas | Proposta | Guia de estudo | Análise de rede |
|---|---|---|---|---|---|
| 1 — Montagem do lab | 2026-08-02 | #1–#9 | — | ⬜ não existe | ✅ `fase1-construcao-lab.md` |
| 2 — Exploração web (DVWA) | até 2026-08-17 | #10–#51 | — | ✅ guias por tema (SQLi, XSS, CSRF, Command Injection, File Upload, File Inclusion, Brute Force) + `guia-estudo-comparativo-vulnerabilidades-web.md` | ✅ `fase2-exploracao-web.md` |
| 3 — VPN WireGuard | até 2026-08-22 | #52–#56 | — | ✅ `guia-estudo-wireguard.md` | ✅ `fase3-vpn-wireguard.md` |
| 4 — Serviços de rede | 2026-08-22/23 | #57–#65 | — | ✅ `guia-estudo-fase4-exploracao-servicos.md` | ✅ `fase4-exploracao-servicos.md` |
| 5 — Windows Server, hardening e SIEM | 2026-08-24/25 | #66–#86 | — | ✅ `guia-estudo-fase5-...md` | ✅ `fase5-active-directory-hardening.md` |
| 6 — Ataques ao AD | 2026-08-30 a 09-18 | #87–#98 | ✅ `fase6-proposta-ad-attacks.md` | ✅ `guia-estudo-fase6-active-directory.md` | ✅ `fase6-ataques-active-directory.md` |
| 7 — Blue Team | 2026-09-20 a 09-25 | #99–#106 | ✅ `fase7-proposta-blue-team.md` | ✅ `guia-estudo-fase7-...md` | 🟡 `fase7-blue-team.md` (o título diz #99–#105; a #106 também é do pós-Fase 7) |
| 8 — GRC | 2026-09-27 a 10-01 | #107–#117 | ✅ `fase8-proposta-grc.md` | ✅ `guia-estudo-fase8-...md` | ⬜ não existe (a decidir: a Fase 8 quase não mexeu na rede) |
| 9 — Técnica | 2026-10-06 a 10-20 | #118–#130 | ✅ `fase9-proposta-tecnica.md` | ✅ `guia-estudo-fase9-...md` | ⬜ não existe — **e a Fase 9 mudou a rede** (DMZ, política B, contenção) |

## 3. Documentos de defesa e de GRC

| Documento | Para que serve | Última atualização | Estado |
|---|---|---|---|
| `registo-riscos.xlsx` | Os 10 riscos, com probabilidade × impacto, inerente e residual, e os critérios v1 da matriz | 2026-10-20 | ✅ (6 riscos ainda não confrontados com os critérios v1 — Fase 10) |
| `declaracao-aplicabilidade-parcial.md` | Tratamento de cada risco e estado dos controlos ISO 27001 ligados a eles | 2026-10-20 | ✅ |
| `mapa-cobertura-mitre-attack.md` | Os 19 ataques feitos no lab: o que a deteção apanha (🟢🟡🔴) | 2026-10-20 | 🟡 cobre os 19 ataques da tabela; ataques e testes das Fases 7–9 por acrescentar |
| `hardening-baseline.md` | Todas as defesas do lab, cada uma verificada ao vivo | 2026-10-20 | 🟡 só os pontos 8 e 10 foram tocados na Fase 9; os restantes foram verificados na Fase 7 (2026-09-25) |
| `playbook-resposta-incidentes.md` | Como responder a um incidente (detetar → conter → erradicar → recuperar) | 2026-10-18 | ✅ |
| `politicas/` (3 políticas) | Controlo de acesso e passwords; registo e monitorização; vulnerabilidades e configuração | 2026-09-28/29 | 🟡 a confrontar com as decisões da Fase 9 (gMSA, critérios de risco, lacuna Suricata → Wazuh) |
| `tabela-resumo-ataques.xlsx` | Lista dos ataques feitos, com técnica e resultado | 2026-09-18 | 🟡 parada desde a Fase 6 |

## 4. Referência e apoio

| Documento | Para que serve | Última atualização | Estado |
|---|---|---|---|
| `glossario.md` | Os termos técnicos do lab, explicados em linguagem simples | 2026-10-18 | 🟡 faltam termos da Fase 9 (ex.: DMZ, VLAN, controlo corretivo, critérios de risco, scanner de vulnerabilidades, syslog) |
| `analise-rede/topologia-base.md` | A rede atual: máquinas, IPs, segmentos | 2026-10-18 | ✅ |
| `analise-rede/README.md` | O critério das fichas de análise de rede | 2026-09-27 | 🟡 diz "Fases 1 a 7" |
| `scripts/` | Scripts do lab (`dvwa-healthcheck.sh`) e lista de candidatos | 2026-10-14 | 🟡 a lista de candidatos é da Fase 7 |
| `screenshots/` | 158 imagens, por data | 2026-10-19 | ✅ todas referidas em algum documento; nenhuma referência partida |

## 5. O registo principal — secções transversais

O registo tem 130 entradas, sem números em falta. As secções que hoje são obrigatórias não existiam no início:

| Secção | Entradas sem ela (contagem automática, aproximada) | Estado |
|---|---|---|
| Consequência para a organização real / perspetiva da vítima | ~73, sobretudo das Fases 1 a 5 | 🟡 a decidir o critério (revisão R3) |
| English summary | ~96, sobretudo até à Fase 6 | 🟡 a decidir o critério (revisão R3) |

## 6. Fora do git (só no computador)

| Pasta / ficheiro | O que é |
|---|---|
| `roteiro-projeto-laboratorio-ciberseguranca.md` | Roteiro e parâmetros do projeto |
| `claude/` | Notas de trabalho, rascunhos e cópias de segurança das sessões |
| `posts linkedln /` | Posts do LinkedIn (o nome tem um erro e um espaço no fim) |
| `PlanoConteudoLinkedIn-atualizado.docx` | Plano de conteúdo do LinkedIn |
| `_to_delete/` | Ficheiros postos de lado para apagar (o ambiente de trabalho do Claude não pode apagar) |

## 7. Revisão em curso (antes da Fase 10)

R1 este mapa · R2 glossário · R3 secções transversais das entradas antigas · R4 guias, análise de rede, tabela de ataques e políticas · R5 checklist de fecho de fase · depois, a proposta da Fase 10.
