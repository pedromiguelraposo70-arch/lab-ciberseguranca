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
| ☐ | 10.0.5 — Wazuh: verificar (sem aplicar) as atualizações e o reinício pendente | Saídas dos comandos; decisão e janela registadas | P · C | R | P |
| ☐ | 10.0.5 — Estado inicial do lab | VMs, serviços, agentes Wazuh e regras do OPNsense registados | P · C | R | P |
| ☐ | Fecho do bloco 10.0 | `checklist-fecho-de-fase.md` aplicada ao bloco; este guia revisto | C | R | P |

**Pendências que não fecham com o bloco:**

| Estado | Pendência | Origem | Condição para ☑ |
|---|---|---|---|
| ☐ | Decidir o suporte das cópias independentes (R6) | #133, #134 | Decisão escrita |
| ☐ | Criar, verificar e testar a reposição das cópias do DC e do Wazuh | Risco #8 (Alto) | Suporte decidido; cópias independentes do DC e do Wazuh criadas, verificadas e com teste de reposição registado. **Prioridade antes de avançar para a sessão 10.4**, salvo nova decisão deliberada e documentada |
| ☐ | Primeira aplicação documentada da R5 e da R3 | Risco #9 (Alto) | Medição e revisão da capacidade segundo a R5; quando houver uma operação de remoção ou consolidação, registo das sete verificações da R3 e das medições antes e depois. **Não remover nem consolidar snapshots só para cumprir a checklist** |
| ☐ | Pasta `Claude outputs/` | — | Decisão sobre manter ou apagar |

## 3. Perguntas de controlo (em cada sessão)

**Antes:** O objetivo está definido? Que documentos e sistemas são tocados? O que pode correr mal se se alterar alguma coisa? Qual é o critério para dar a tarefa por concluída?

**Durante:** Os valores foram medidos ou supostos? Há evidência verificável? Está escrito o que é facto e o que é dedução? Ficaram registadas as limitações?

**Riscos e decisões:** A classificação cita o critério v1 aplicado? O controlo está **aplicado** ou só **aprovado**? A aceitação respeita a decisão 6 (justificação, revisão, exceção)?

**Fecho:** O registo corresponde ao que aconteceu? Os documentos relacionados dizem o mesmo? Foi revisto antes do commit? O GitHub tem o último commit?

## 4. Notas e propostas do Pedro

Data: ________________

Dúvidas ou omissões detetadas:

______________________________________________________________________

______________________________________________________________________

Alterações que proponho, e porquê:

______________________________________________________________________

______________________________________________________________________

Decisões pendentes / próximos passos:

______________________________________________________________________
