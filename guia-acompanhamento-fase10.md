# Guia de acompanhamento — Fase 10, bloco 10.0

**Para quê:** acompanhar o trabalho, detetar omissões e propor alterações fundamentadas. Não substitui o registo, as políticas nem o registo de riscos: serve para verificar se estão coerentes entre si e com o que foi feito.
**Versão:** 26/10/2026 · atualiza-se no fim de cada sessão · revê-se no fecho do bloco 10.0.

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
| ☐ | Fecho do bloco 10.0 | `checklist-fecho-de-fase.md` aplicada ao bloco; revisão documental; aprovação do Pedro | C | R | P |

**Verificações específicas do fecho do bloco 10.0:**

- ☐ Entrada #135 e documentos afetados.
- ☐ Riscos #6, #8 e #9, segundo os critérios escritos e a evidência.
- ☐ Coerência do *egress filtering* com o `hardening-baseline.md` e a Declaração de Aplicabilidade.
- ☐ Regra temporária da Fase 7.4 e regras *Floating* e automáticas do OPNsense.
- ☐ Restantes categorias da checklist (glossário, README, mapa do projeto, MITRE ATT&CK, tabela de ataques, playbook, scripts).
- ☐ Registo das alterações efetuadas, das pendências e das categorias sem alterações justificadas.

**Pendências que não fecham com o bloco:**

| Estado | Pendência | Origem | Condição para ☑ |
|---|---|---|---|
| ☐ | Decidir o suporte das cópias independentes (R6) | #133, #134, #135 | Decisão escrita |
| ☐ | Criar, verificar e testar a reposição das cópias do DC e do Wazuh | Risco #8 (Alto) | Suporte decidido; cópias independentes do DC e do Wazuh criadas, verificadas e com teste de reposição registado. **Prioridade antes de avançar para a sessão 10.4**, salvo nova decisão deliberada e documentada |
| ☐ | Primeira aplicação documentada da R5 e da R3 | Risco #9 (Alto) | Medição e revisão da capacidade segundo a R5; quando houver uma operação de remoção ou consolidação, registo das sete verificações da R3 e das medições antes e depois. **Não remover nem consolidar snapshots só para cumprir a checklist** |
| ☐ | Pasta `Claude outputs/` | — | Decisão sobre manter ou apagar |
| ☐ | Rever a regra temporária da Fase 7.4 e decidir sobre a expiração ou remoção | #135 | Decisão escrita (gestão de alterações, A.8.32) |
| ☐ | Verificar as regras *Floating* e automáticas do OPNsense | #135 | Regras observadas e registadas |
| ☐ | Rever a coerência do *egress filtering* com os documentos de hardening e conformidade | #135 | Coerência confirmada ou correção aprovada |
| ☐ | Investigar os registos das atualizações automáticas do Wazuh | #135 | Registo consultado e resultado registado |

## 3. Perguntas de controlo (em cada sessão)

**Antes:** O objetivo está definido? Que documentos e sistemas são tocados? O que pode correr mal se se alterar alguma coisa? Qual é o critério para dar a tarefa por concluída?

**Durante:** Os valores foram medidos ou supostos? Há evidência verificável? Está escrito o que é facto e o que é dedução? Ficaram registadas as limitações?

**Riscos e decisões:** A classificação cita o critério v1 aplicado? O controlo está **aplicado** ou só **aprovado**? A aceitação respeita a decisão 6 (justificação, revisão, exceção)?

**Fecho:** O registo corresponde ao que aconteceu? Os documentos relacionados dizem o mesmo? Foi revisto antes do commit? O GitHub tem o último commit?

## 4. Notas e propostas do Pedro

As dúvidas, propostas de alteração e decisões do Pedro são apresentadas diretamente nas sessões; não ficam registadas neste documento.
