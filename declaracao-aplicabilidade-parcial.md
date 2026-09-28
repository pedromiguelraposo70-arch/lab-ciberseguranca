# Declaração de Aplicabilidade (parcial) — Fase 8, Sessão 8.3

**Data:** 2026-09-28

## Objetivo

Não é a Declaração de Aplicabilidade completa (os 93 controlos do Anexo A da ISO/IEC 27001:2022) — seria desproporcionado para este lab. É uma seleção dos controlos diretamente ligados aos 7 riscos do `registo-riscos.xlsx` (Entrada #109), cada um marcado Aplicável/Não aplicável, com justificação, estado e ligação ao risco e à entrada do registo que prova.

## Tratamento de risco (ISO/IEC 27005) — decisão por risco

| # | Risco | Tratamento | Justificação |
|---|---|---|---|
| 1 | RCE via web shell (FTP anónimo + PHP) | **Mitigar** — já feito | Causa raiz corrigida (Entrada #104); risco desceu de Crítico a Médio |
| 2 | Kerberoasting / AS-REP Roasting (svc_sql, svc_legacy) | **Aceitar** | Decisão consciente de manter passwords fracas, para preservar a técnica como demonstração reproduzível (hardening-baseline, ponto 8); gMSA identificado como correção real fora de um lab |
| 3 | LLMNR/NBT-NS/mDNS poisoning | **Mitigar** — já feito | Desligado nas três camadas (Entrada #106); risco desceu de Alto a Baixo |
| 4 | Indisponibilidade não detetada (DVWA/Apache) | **Mitigar** — pendente | Corrigido pontualmente (Entrada #108), mas falta controlo preventivo/detetivo; candidato ao trilho técnico paralelo |
| 5 | Dados pessoais capturados em trânsito | **Aceitar** — por agora | Fora do âmbito imediato da Fase 8; revisitar numa futura sessão sobre encriptação de tráfego interno |
| 6 | VMs sem patch | **Aceitar** | Decisão consciente, para não enviesar os resultados das tarefas de ataque/deteção do lab (hardening-baseline, ponto 9) |
| 7 | Alerta enganador — falsa confiança de cobertura (Wazuh) | **Mitigar** — pendente | Falta regra nova para a técnica real de enumeração; mapa de cobertura já corrigido a refletir a lacuna |

## Controlos do Anexo A (ISO/IEC 27001:2022) — aplicabilidade

| Controlo | Nome | Aplicável | Estado | Risco(s) ligado(s) | Evidência |
|---|---|---|---|---|---|
| A.5.9 | Inventário de ativos de informação | Sim | ✅ Implementado | #4 | Entrada #108 (Sessão 8.1) |
| A.5.12 | Classificação da informação | Sim | ✅ Implementado | #4 | Entrada #108 — tabela CID |
| A.5.17 | Informação de autenticação | Sim | 🔴 Risco aceite | #2 | hardening-baseline pt.8 |
| A.8.5 | Autenticação segura | Sim | 🔴 Risco aceite | #2 | Fase 6 (Kerberoasting/AS-REP) |
| A.8.8 | Gestão de vulnerabilidades técnicas | Sim | 🔴 Risco aceite | #6 | hardening-baseline pt.9 |
| A.8.9 | Gestão de configuração | Sim | ✅ Implementado | #1 | Entrada #104 (FTP só-leitura, PHP desativado) |
| A.8.16 | Atividades de monitorização | Sim | 🟡 Parcial | #4, #7 | Entrada #108 (sem alerta próprio); Entrada #90 (alerta enganador) |
| A.8.20 | Segurança de redes | Sim | ✅ Implementado | #3 | Entrada #106 |
| A.8.22 | Segregação de redes | Não aplicável | — | — | Lab de VM único, sem segmentação de rede a este nível (ver limitação já documentada no mapa de cobertura MITRE ATT&CK) |
| A.8.24 | Uso de criptografia | Sim | 🔴 Risco aceite | #5 | Entrada #97 |
| A.8.28 | Codificação segura | Sim | ✅ Implementado (parcial) | #1 | Entrada #104 — execução de PHP desativada na pasta de upload |

**Legenda de estado:** ✅ Implementado (controlo aplicado e a funcionar) · 🟡 Parcial (existe, mas com lacuna conhecida) · 🔴 Risco aceite (decisão consciente de não implementar, ou ainda por implementar sem controlo compensatório).

## Nota metodológica

Esta declaração não substitui um exercício real de SoA (que cobriria os 93 controlos, aplicável ou não, para todo o âmbito da organização) — é um exercício dirigido pelos riscos já identificados, típico de uma primeira iteração de um SGSI pequeno, onde se começa pelo que já se sabe que é relevante e se expande depois. A expansão para os restantes controlos do Anexo A fica fora do âmbito da Fase 8.

## Domínios relacionados

ISO/IEC 27001:2022 cláusula 6.1.3 (tratamento de risco de segurança da informação) e o próprio conceito de Declaração de Aplicabilidade (cláusula 6.1.3 d); NIS2 art. 21.º (gestão de risco de cibersegurança).

## Próximos passos

Sessão 8.4 — políticas (controlo de acesso/passwords; registo/monitorização; gestão de vulnerabilidades/configuração segura), que dão corpo escrito aos controlos aqui marcados como aplicáveis.
