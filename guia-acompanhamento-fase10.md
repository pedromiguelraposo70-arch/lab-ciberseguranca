# Guia de acompanhamento — Fase 10 (guia geral)

**Para quê:** acompanhar o trabalho, detetar omissões e propor alterações fundamentadas. Não substitui o registo, as políticas nem o registo de riscos: serve para verificar se estão coerentes entre si e com o que foi feito.
**Versão:** 19/11/2026 (bloco 10.3, #155) · atualiza-se no fim de cada sessão.
**Blocos:** 10.0 — checklist na secção 2 (fechado, #136); 10.1 — guia próprio (fechado, #151); 10.2 — sem guia próprio, acompanhado no registo (#152, #153; fecho na #154); 10.3 — sem guia próprio, acompanhado no registo (#155; fecho com desvio fundamentado). As pendências da Fase 10 estão na tabela «Pendências que não fecham com o bloco».

**Regra transversal:** nenhuma sugestão do assistente substitui a decisão do Pedro, e nenhuma afirmação de sucesso substitui a evidência. ☑ = concluído **com evidência**, não apenas discutido. ☑ **Parcial** = a parte descrita está concluída com evidência; o que falta fica identificado na própria linha. `— Encerrada (condição extinta)` = ação não executada porque a condição que a originou deixou de se verificar; não equivale a conclusão da ação.

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
| ☑ | Primeira aplicação documentada da R5 e da R3 | Risco #9 (Alto); desvio da R5 na 10.0.5 (#136) | Medição e revisão da capacidade segundo a R5, **no início de uma sessão** (a medição de fecho de 27/10 não conta); quando houver uma operação de remoção ou consolidação, registo das sete verificações da R3 e das medições antes e depois. **Não remover nem consolidar snapshots só para cumprir a checklist** **Cumprida:** R5 no início de sessão (#137, #152, #153); R3 na remoção do *snapshot* temporário de 09/11, com as sete verificações e o espaço antes e depois (#154). |
| ☑ | Rever o risco #9 (gatilho da #134: «após a primeira aplicação documentada da R5 e da R3», disparado na #154) | #134; #154 | Revisão feita e registada no início do 10.3, com a medição R5 completa (três partições e VMs ligadas) dessa sessão **Feita na #155:** Alto (P3 × I2) mantido. |
| ☐ | Pasta `Claude outputs/` | — | Decisão sobre manter ou apagar |
| ☐ | Rever a regra temporária da Fase 7.4 e decidir sobre a expiração ou remoção | #135 | Decisão escrita sobre expiração ou remoção (a remoção não é obrigatória); eficácia da regra ainda por verificar (gestão de alterações, A.8.32) |
| ☑ **Parcial** | Inspecionar as 13 regras automáticas *Floating* do OPNsense (as automáticas da LAN foram vistas; não há *Floating* do utilizador) | #135, #136; #155 | Regras consultadas e resultado registado; impacto na avaliação da regra temporária documentado, se aplicável **Feita na #155** (secção 2.2, 11/11): nenhuma regra *Floating* manual; as 13 automáticas são as gerais do OPNsense. Impacto na regra temporária da 7.4: não avaliado; fica na pendência própria (linha acima). |
| ☑ | Rever a coerência do *egress filtering* com os documentos de hardening e conformidade | #135, #136 | Feito na #136 (secção 4): `topologia-base.md` e `hardening-baseline.md` corrigidos; Declaração mantida. Conectividade efetiva não testada |
| ☐ | Investigar os registos das atualizações automáticas do Wazuh | #135 | Registo consultado e resultado registado |
| ☐ | Alinhar o texto do limiar de 90% da R5 ("atingir" ou "ultrapassar"); registar, em cada medição, as VMs ligadas; perto do limiar, usar a medição exata em blocos | #136 | Texto da R5 revisto e aprovado |
| ☐ | Clarificar se a medição e a revisão da R5 registadas na #134 (26/10) contam como primeira aplicação da R5, e porquê | Estudo do bloco 10.0 (28/10) | Resposta escrita no início do 10.1; se for preciso, ajustar a pendência "Primeira aplicação documentada da R5 e da R3" |
| ☐ | Decidir o destino do Apache da porta 8080 no Servidor Vulnerável, como alteração autónoma | Adenda à #149 (Sessão 10.1) | Responsável: Pedro. Finalidade e dependências avaliadas; decisão justificada (manter, corrigir o acesso ou desligar) e executada com R1/R4, prova antes/depois e teste de não regressão. Até lá, o HTTP 403 é um efeito secundário conhecido e por resolver, não uma correção |
| ☐ | Reavaliar a conservação do snapshot `2026-11-04 antes da correção 10.1` do Servidor Vulnerável (R7) | #149; guia do 10.1 | Depois do fecho do 10.1: decisão de manter ou remover, com a R3 se for remover |
| — Encerrada (condição extinta) | Rever os snapshots e as retenções exigidos pela R5 no nível de ação (`/` e `/home` acima de 85%), e registar | #143; #151; #155 | Revisão feita e registada, sem remoções nesta revisão (qualquer remoção sujeita à R2, R3 e R4) **Encerrada sem execução:** a condição deixou de se verificar (`/` e `/home` abaixo de 85% desde 15/11; em 19/11: 82,48% e 82,58%). A revisão não foi realizada. Se alguma destas partições voltar a ultrapassar os 85%, a R5 volta a exigir a revisão (#155). |
| ☐ | Impor tecnicamente o mínimo de 16 caracteres (regra 3.2 da política de controlo de acesso) nos sistemas Linux do lab | #151 | Configuração aplicada e testada (uma password abaixo do mínimo recusada) |
| ☐ | Rever a política de controlo de acesso e passwords (gatilho: incidente relacionado com acesso — exposição de credenciais) | #146; #149; #151 | Revisão feita e registada, com as alterações aprovadas ou a decisão de não alterar |
| ☐ | Incluir o Apache da porta 8080 no inventário de ativos (regra 3.5 da política de vulnerabilidades e configuração) | #151 | Inventário atualizado, ligado ao destino decidido para o serviço |
| ☐ | Executar a fonte de tempo do domínio (decidida ao nível do desenho: DC → OPNsense → NTP externo) e esclarecer o comportamento dos relógios das VMs na retoma da suspensão | #143; #144; #147; #151 | Configuração aplicada segundo as condições da #144; verificação do DC e do Windows 11; registos do VMware consultados |
| ☐ | Tratar o risco #11: gerar e instalar um certificado novo no OPNsense, retirando o antigo de utilização (alteração técnica: R1 e R4) | #155; risco #11 (Alto, exceção temporária) | Certificado novo instalado e o antigo fora de utilização, com evidência. **Prazo: antes de avançar para o bloco 10.4 ou até 15/12/2026, o que ocorrer primeiro**; o adiamento do 10.4 não prolonga a exceção. Revisão antecipada se o AnyDesk ou o NoMachine aceitarem ligações externas, ou se as regras da WAN permitirem acesso relevante à página de gestão |
| ☐ | Reativar as cópias automáticas do Timeshift (sistema do anfitrião; não protege as VMs nem cumpre a R6) | #155; risco #9 (limitação do tratamento) | Cópias automáticas reativadas e primeira cópia concluída e listada. **Logo que as VMs da UC saiam da `/mnt/VMs`, e no máximo a 11/12/2026**, confirmando antes, com `df -BM` e a estimativa do Timeshift nesse momento, que há espaço para a primeira cópia (cerca de 36,8 GB a 16/11) sem deixar de cumprir a R4; se a 11/12/2026 a R4 não se cumprir com a primeira cópia, decide-se nessa data. Até lá, evitar atualizações e alterações ao anfitrião que não sejam essenciais |
| ☐ | Retirar as VMs da UC01486 (`vuln-srv-01` e `wazuh-uc01486`) da `/mnt/VMs` | #155; exceção temporária da política (secção 5) | VMs retiradas, com medição `df -BM` da `/mnt/VMs` antes e depois. **Até 11/12/2026**; a data não autoriza mantê-las se a partição se aproximar de um nível crítico |

## 3. Perguntas de controlo (em cada sessão)

**Antes:** Foi medida a ocupação dos discos com `df -h` (R5)? O objetivo está definido? Que documentos e sistemas são tocados? O que pode correr mal se se alterar alguma coisa? Qual é o critério para dar a tarefa por concluída?

**Durante:** Os valores foram medidos ou supostos? Há evidência verificável? Está escrito o que é facto e o que é dedução? Ficaram registadas as limitações?

**Riscos e decisões:** A classificação cita o critério v1 aplicado? O controlo está **aplicado** ou só **aprovado**? A aceitação respeita a decisão 6 (justificação, revisão, exceção)?

**Fecho:** O registo corresponde ao que aconteceu? Os documentos relacionados dizem o mesmo? Foi revisto antes do commit? O GitHub tem o último commit?

## 4. Notas e propostas do Pedro

As dúvidas, propostas de alteração e decisões do Pedro são apresentadas diretamente nas sessões; não ficam registadas neste documento.
