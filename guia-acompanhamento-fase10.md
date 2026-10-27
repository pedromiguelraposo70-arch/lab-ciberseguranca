# Guia de acompanhamento — Fase 10, bloco 10.0

**Para quê:** acompanhar o trabalho, detetar omissões e propor alterações fundamentadas. Não substitui o registo, as políticas nem o registo de riscos: serve para verificar se estão coerentes entre si e com o que foi feito.
**Versão:** 27/10/2026 (fecho do bloco 10.0) · atualiza-se no fim de cada sessão.

**Regra transversal:** nenhuma sugestão do assistente substitui a decisão do Pedro, e nenhuma afirmação de sucesso substitui a evidência. ☑ = concluído **com evidência**, não apenas discutido.

## 1. Regras de ouro

- ☐ Medir e registar **antes** de decidir.
- ☐ Separar factos, deduções e o que está por verificar.
- ☐ Rever e aprovar **antes** de entrar no registo ou no git; confirmar no GitHub depois do Sync.
- ☐ Não remover nem consolidar snapshots sem as sete verificações (R3).
- ☐ Não declarar um controlo eficaz sem evidência.
- ☐ Registar decisões pendentes, quem decide e quando se revê.

## 2. Checklist do bloco 10.0

Executa: **C** = Claude (prepara rascunhos e presta apoio) · **P** = Pedro (executa as ações no sistema e toma as decisões). Revê: **R** = revisão por Pedro, com apoio externo quando disponível. Aprova: sempre **P**.

| Estado | Sessão / passo | Evidência exigida | Executa | Revê | Aprova |
|---|---|---|---|---|---|
| ☑ | 10.0.1 — Estrutura e ocupação dos discos | Entrada #131 publicada (com nota de atualização) | P (comandos) · C (registo) | R | P |
| ☑ | 10.0.2 — Tamanho das VMs e snapshots | Entrada #132 publicada | P · C | R | P |
| ☑ | 10.0.3 — Política de snapshots, cópias e capacidade | Política em `politicas/` + Entrada #133 publicadas | C (rascunho) | R | P |
| ☑ | 10.0.4 — Critérios de aceitação; riscos #8 e #9 | `registo-riscos.xlsx`, Declaração e Entrada #134 publicados | P · C | R | P |
| ☑ | Glossário — termos de GRC | `glossario.md` publicado (206 termos) | C | R | P |
| ☑ | 10.0.5 — Wazuh: verificar (sem aplicar) as atualizações e o reinício pendente | Entrada #135 publicada (commit `ac5aad1`) | P · C | R | P |
| ☑ | 10.0.5 — Estado inicial do lab | Entrada #135 publicada (commit `ac5aad1`) | P · C | R | P |
| ☑ | Fecho do bloco 10.0 | Entrada #136 e documentos do fecho publicados (commit `4b40029`, 27/10/2026) | C | R | P |

**Verificações específicas do fecho do bloco 10.0:**

- ☑ Entrada #135 e documentos afetados (#136, secções 1 e 4).
- ☑ Riscos #6, #8 e #9, segundo os critérios escritos e a evidência. Alterações apenas quando justificadas pela evidência e pelos critérios escritos; caso contrário, fundamentar a manutenção (#136, secção 2).
- ☑ Coerência do *egress filtering* com o `hardening-baseline.md` e a Declaração de Aplicabilidade (#136, secção 4).
- ☑ **Parcial:** regra temporária da Fase 7.4 e regras *Floating* e automáticas do OPNsense. Vistas as regras automáticas da LAN; não há regras *Floating* do utilizador; as 13 automáticas *Floating* ficam por inspecionar e a regra da 7.4 por decidir (#136, secção 5; pendências abaixo).
- ☑ Restantes categorias da checklist (glossário, README, mapa do projeto, MITRE ATT&CK, tabela de ataques, playbook, scripts) (#136, secção 6).
- ☑ Registo das alterações efetuadas, das pendências e das categorias sem alterações justificadas (#136, secções 6 a 8).

**Pendências que não fecham com o bloco:**

| Estado | Pendência | Origem | Condição para ☑ |
|---|---|---|---|
| ☐ | Decidir o suporte das cópias independentes (R6) | #133, #134, #135 | Decisão escrita |
| ☐ | Criar, verificar e testar a reposição das cópias do DC e do Wazuh | Risco #8 (Alto) | Suporte decidido; cópias independentes do DC e do Wazuh criadas, verificadas e com teste de reposição registado. **Prioridade antes de avançar para a sessão 10.4**, salvo nova decisão deliberada e documentada |
| ☐ | Primeira aplicação documentada da R5 e da R3 | Risco #9 (Alto); desvio da R5 na 10.0.5 (#136) | Medição e revisão da capacidade segundo a R5, **no início de uma sessão** (a medição de fecho de 27/10 não conta); quando houver uma operação de remoção ou consolidação, registo das sete verificações da R3 e das medições antes e depois. **Não remover nem consolidar snapshots só para cumprir a checklist** |
| ☐ | Pasta `Claude outputs/` | — | Decisão sobre manter ou apagar |
| ☐ | Rever a regra temporária da Fase 7.4 e decidir sobre a expiração ou remoção | #135 | Decisão escrita sobre expiração ou remoção (a remoção não é obrigatória); eficácia da regra ainda por verificar (gestão de alterações, A.8.32) |
| ☐ | Inspecionar as 13 regras automáticas *Floating* do OPNsense (as automáticas da LAN foram vistas; não há *Floating* do utilizador) | #135, #136 | Regras consultadas e resultado registado; impacto na avaliação da regra temporária documentado, se aplicável |
| ☑ | Rever a coerência do *egress filtering* com os documentos de hardening e conformidade | #135, #136 | Feito na #136 (secção 4): `topologia-base.md` e `hardening-baseline.md` corrigidos; Declaração mantida. Conectividade efetiva não testada |
| ☐ | Investigar os registos das atualizações automáticas do Wazuh | #135 | Registo consultado e resultado registado |
| ☐ | Alinhar o texto do limiar de 90% da R5 ("atingir" ou "ultrapassar"); registar, em cada medição, as VMs ligadas; perto do limiar, usar a medição exata em blocos | #136 | Texto da R5 revisto e aprovado |

## 3. Perguntas de controlo (em cada sessão)

**Antes:** Foi medida a ocupação dos discos com `df -h` (R5)? O objetivo está definido? Que documentos e sistemas são tocados? O que pode correr mal se se alterar alguma coisa? Qual é o critério para dar a tarefa por concluída?

**Durante:** Os valores foram medidos ou supostos? Há evidência verificável? Está escrito o que é facto e o que é dedução? Ficaram registadas as limitações?

**Riscos e decisões:** A classificação cita o critério v1 aplicado? O controlo está **aplicado** ou só **aprovado**? A aceitação respeita a decisão 6 (justificação, revisão, exceção)?

**Fecho:** O registo corresponde ao que aconteceu? Os documentos relacionados dizem o mesmo? Foi revisto antes do commit? O GitHub tem o último commit?

## 4. Notas e propostas do Pedro

As dúvidas, propostas de alteração e decisões do Pedro são apresentadas diretamente nas sessões; não ficam registadas neste documento.
