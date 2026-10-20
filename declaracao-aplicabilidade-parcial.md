# Declaração de Aplicabilidade (parcial) — Fase 8, Sessão 8.3

**Data:** 2026-09-28 · **Atualizada:** 2026-10-20 (balanço 9.10 — riscos #9 e #10 acrescentados; critérios v1 da matriz no `registo-riscos.xlsx`)

## Objetivo

Não é a Declaração de Aplicabilidade completa (os 93 controlos do Anexo A da ISO/IEC 27001:2022) — seria desproporcionado para este lab. É uma seleção dos controlos diretamente ligados aos riscos do `registo-riscos.xlsx` (7 na Entrada #109; o 8.º foi acrescentado na Sessão 8.7), cada um marcado Aplicável/Não aplicável, com justificação, estado e ligação ao risco e à entrada do registo que prova.

## Tratamento de risco (ISO/IEC 27005) — decisão por risco

| # | Risco | Tratamento | Justificação |
|---|---|---|---|
| 1 | RCE via web shell (FTP anónimo + PHP) | **Mitigar** — já feito | Causa raiz corrigida (Entrada #104); risco desceu de Crítico a Médio Balanço 9.10: recusa reconfirmada a partir da DMZ (#129); fragilidade adicional — pasta `/srv/ftp/upload` a 777 — correção **planeada** para a Fase 10 (não é aceitação), com verificação de todos os caminhos de escrita anónima (incl. Samba, #64) |
| 2 | Kerberoasting / AS-REP Roasting (svc_sql, svc_legacy) | **Aceitar — exceção didática** (reconfirmada 2026-10-20) | Contas mantidas fracas de propósito para preservar as demonstrações (#91, #92); Crítico pela matriz, no contexto da organização fictícia. Aceitação específica do lab, não transponível para uma organização real sem avaliação formal e autoridade competente. Compensatórios detetivos (regras 100011/100010, não reverificados na Fase 9). Correção demonstrada noutras contas (gMSA, #119/#123). Revisão: quando a demonstração deixar de ser necessária ou no encerramento do lab. A reconfirmação não é validação técnica |
| 3 | LLMNR/NBT-NS/mDNS poisoning | **Mitigar** — já feito | Desligado nas três camadas (Entrada #106); risco desceu de Alto a Baixo |
| 4 | Indisponibilidade não detetada (DVWA/Apache) | **Mitigar** — feito (Sessão 9.4) | Controlo corretivo (recuperação automática) + detetivo provados com a mesma falha da #108 (#124); nenhum impede a falha — reduzem a duração e garantem que é vista; residual Baixo (P2 × I1). Limitações: caminho Docker não testado, healthcheck dentro da própria VM. Reverificar na Fase 10 |
| 5 | Dados pessoais dos clientes em trânsito sem encriptação (HTTP/FTP) | **Aceitar** (revisto na Sessão 8.7, 2026-10-01) | O lab não tem dados pessoais reais de clientes; numa organização real o tratamento seria HTTPS e SFTP/FTPS. A Entrada #97 deixou de ser evidência deste risco (mostra o envenenamento LLMNR do risco #3). Revisão se o lab passar a ter dados reais ou numa sessão sobre encriptação do tráfego interno |
| 6 | VMs sem patch | **Aceitar** | Decisão consciente, para não enviesar os resultados das tarefas de ataque/deteção do lab (hardening-baseline, ponto 9) |
| 7 | Alerta enganador — falsa confiança de cobertura (Wazuh) | **Mitigar** — parcial (Sessão 9.2) | Regra dedicada 100021 para a enumeração rápida (#120); a enumeração lenta continua a só produzir os alertas de fábrica enganadores — residual mantém-se Médio (provisório). Teste de enumeração lenta na Fase 10 |
| 8 | Perda das VMs sem cópia de segurança | **Aceitar** (acrescentado na Sessão 8.7, 2026-10-01) | Sem capacidade livre nos discos para copiar tudo (cerca de 70 GB livres em cada um); os discos servem também para o material da formação. Atenuante: a documentação está no GitHub e as VMs refazem-se. Revisão se for comprado um disco externo ou se um disco passar de 90% |
| 9 | Esgotamento da capacidade de disco (novo, balanço 9.10) | **Mitigar** — pendente | Alto (3×2): já aconteceu (#120, VMware pausou as VMs); sem política de snapshots nem limites. Política de snapshots, limites e verificação dos discos **antes** de iniciar a Fase 10 |
| 10 | Alertas de rede que não chegam ao SIEM (novo, balanço 9.10) | **Mitigar** — pendente | Médio provisório (2×2): a integração Suricata → Wazuh não existe (#129). Integração com verificação contínua na Fase 10; reclassificar se o Suricata detetar ataques à aplicação |

## Controlos do Anexo A (ISO/IEC 27001:2022) — aplicabilidade

| Controlo | Nome | Aplicável | Estado | Risco(s) ligado(s) | Evidência |
|---|---|---|---|---|---|
| A.5.9 | Inventário de ativos de informação | Sim | ✅ Implementado | #4 | Entrada #108 (Sessão 8.1) |
| A.5.12 | Classificação da informação | Sim | ✅ Implementado | #4 | Entrada #108 — tabela CID |
| A.5.17 | Informação de autenticação | Sim | 🟡 Parcial | #2 | **Contas humanas:** política de 16 caracteres (Fase 8); `Administrator` renovada e sem "nunca expira" (#125). **Contas de serviço:** `svc_sql`/`svc_legacy` em risco aceite (exceção didática, hardening-baseline pt.8); gMSA demonstrada noutras contas (#119/#123). Até 2026-10-20: 🔴 Risco aceite |
| A.8.5 | Autenticação segura | Sim | 🔴 Risco aceite | #2 | Fase 6 (Kerberoasting/AS-REP); exceção didática reconfirmada no balanço 9.10. gMSA (bilhete AES-256) demonstrada em contas novas (#119/#123), sem alterar `svc_sql`/`svc_legacy` |
| A.8.6 | Gestão da capacidade | Sim | 🔴 Sem controlo (tratamento planeado) | #9 | Entrada #120 (/home a 100%, VMware pausou as VMs); balanço 9.10 (df -h: / 90%, /home 89%, /mnt/VMs 80%). Mitigação antes de iniciar a Fase 10 |
| A.8.8 | Gestão de vulnerabilidades técnicas | Sim | 🔴 Risco aceite | #6 | hardening-baseline pt.9. Desde a 9.6 existe capacidade de identificar vulnerabilidades (scanner, #126); a correção (patches) continua aceite. A VM Wazuh também tem atualizações pendentes (#129) |
| A.8.9 | Gestão de configuração | Sim | 🟡 Parcial | #1 | Entrada #104 (FTP só-leitura, PHP desativado), reconfirmada na #129. **Lacunas:** pasta `/srv/ftp/upload` a 777; partilha Samba `publico` com escrita anónima criada na #64 e não reverificada; `write_enable=YES` para contas locais não testado. Até 2026-10-20: ✅ Implementado |
| A.8.13 | Cópias de segurança da informação | Sim | 🔴 Risco aceite | #8 | Entrada #115 (Timeshift só do sistema; VMs sem cópia); Sessão 8.7 |
| A.8.15 | Registo (logging) | Sim | 🟡 Parcial | #10 | Eventos do Windows (Fase 6) e `auditd` do Servidor Vulnerável (#121) recolhidos pelo Wazuh. **Lacuna:** registos do OPNsense/Suricata não centralizados (#129) |
| A.8.16 | Atividades de monitorização | Sim | 🟡 Parcial | #4, #7, #10 | **Implementado na Fase 9:** saúde do DVWA com alerta (#124), enumeração do AD (#120), execução de comandos via `auditd` (#121), leitura do `/etc/shadow` (#122). **Lacunas:** alertas do Suricata não chegam ao Wazuh (#129); enumeração lenta não coberta (#120). Antes: Entrada #108 (sem alerta próprio); Entrada #90 (alerta enganador) |
| A.8.20 | Segurança de redes | Sim | ✅ Implementado | #3 | Entrada #106 |
| A.8.22 | Segregação de redes | Sim | 🟡 Implementado (parcial) | — | Entrada #127 (Sessões 9.7/9.8; antes: "Não aplicável"). **Demonstrado:** Kali segregada na DMZ (OPT1, `192.168.50.0/24`); os fluxos Kali → Interno atravessam o OPNsense (`ttl=63`, Live View); bloqueio por omissão; menor privilégio (só o Servidor Vulnerável é alcançável); contenção no gateway, incluindo o corte de ligações abertas. **Não demonstrado / limitações:** tráfego dentro do Interno (segmento plano); tráfego dentro da DMZ, partilhada com a UC01485 (Kali ↔ `vuln-srv-01` sem router no meio). Separação planeada para a Fase 10 |
| A.8.24 | Uso de criptografia | Sim | 🔴 Risco aceite | #5 | Entradas #104 (FTP) e #108 (HTTP); revisto na Sessão 8.7 |
| A.8.28 | Codificação segura | Sim | ✅ Implementado (parcial) | #1 | Entrada #104 — execução de PHP desativada na pasta de upload |

**Legenda de estado:** ✅ Implementado (controlo aplicado e a funcionar) · 🟡 Parcial (existe, mas com lacuna conhecida) · 🔴 Risco aceite (decisão consciente de não implementar, ou ainda por implementar sem controlo compensatório).

## Nota metodológica

Esta declaração não substitui um exercício real de SoA (que cobriria os 93 controlos, aplicável ou não, para todo o âmbito da organização) — é um exercício dirigido pelos riscos já identificados, típico de uma primeira iteração de um SGSI pequeno, onde se começa pelo que já se sabe que é relevante e se expande depois. A expansão para os restantes controlos do Anexo A fica fora do âmbito da Fase 8.

## Domínios relacionados

ISO/IEC 27001:2022 cláusula 6.1.3 (tratamento de risco de segurança da informação) e o próprio conceito de Declaração de Aplicabilidade (cláusula 6.1.3 d); NIS2 art. 21.º (gestão de risco de cibersegurança).

## Próximos passos

Sessão 8.4 — políticas (controlo de acesso/passwords; registo/monitorização; gestão de vulnerabilidades/configuração segura), que dão corpo escrito aos controlos aqui marcados como aplicáveis.
