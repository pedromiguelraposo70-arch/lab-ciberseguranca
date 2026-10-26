# Política de Snapshots, Cópias de Segurança e Capacidade

**Âmbito:** o laboratório (o anfitrião Linux Mint e as VMs do lab). Não abrange a VM da unidade curricular (`vuln-srv-01`) — ver secção 5.
**Data de aprovação:** 2026-10-26 (Sessão 10.0.3, Entrada #133), regra a regra, pelo Pedro.
**Dono da política:** o Pedro, como responsável pelo laboratório.
**Revisão:** no fecho da Fase 10, ou depois da primeira operação de limpeza de snapshots, ou se um limite da R5 for ultrapassado.
**Estado:** em vigor. **R6 por executar** — o suporte das cópias independentes ainda não foi decidido, e **não se afirma que exista uma cópia independente**.
**Base:** Entradas #131 e #132 (medições de 25/10/2026) e proposta da Fase 10 (bloco 10.0).

## 1. Objetivo

Garantir que o lab **se consegue recuperar** depois de uma alteração ou de uma falha, sem que os mecanismos de recuperação encham os discos.

## 2. Definições

- **Snapshot:** estado de uma VM num determinado momento, que permite regressar a esse estado. **Não é uma cópia de segurança.** No lab, os ficheiros de snapshot observados estão na mesma pasta (e no mesmo disco) da VM (#132); noutras configurações podem estar noutro local de armazenamento.
- **Cópia de segurança independente:** cópia guardada **noutro suporte** (ex.: disco externo), que sobrevive à perda do disco original.
- **RPO:** quanto trabalho se aceita perder. **RTO:** quanto tempo se aceita demorar a recuperar.

## 3. O que não se pressupõe

- **[POR VERIFICAR]** Que existam cópias independentes das VMs.
- **[POR VERIFICAR]** Que as cadeias de snapshots estejam válidas.
- **[POR VERIFICAR]** Que remover ou consolidar um snapshot liberte uma dada quantidade de espaço.

## 4. Regras

**R1 — Snapshot antes de uma alteração com risco.**
- *O quê:* tirar um snapshot da VM antes de uma alteração que possa impedir o seu funcionamento (configuração de serviços, rede, contas, atualizações).
- *Quando:* sempre que a alteração não se desfaça facilmente à mão.
- *Evidência:* nome do snapshot com a data e a sessão; registo na entrada da sessão.
- *Por verificar:* espaço livre na partição da VM antes de o tirar (R4).
- *Nota:* o snapshot é um ponto de regresso, não uma cópia de segurança independente; a recuperação depende da integridade dos ficheiros e da cadeia de discos.

**R2 — Nenhuma remoção só por idade ou tamanho.**
- *O quê:* um snapshot **não** se remove nem se consolida apenas por ser antigo ou ocupar muito espaço.
- *Quando:* sempre.
- *Evidência:* a decisão de remover ou consolidar identifica as verificações da R3 e regista a justificação da decisão.
- *Nota:* a idade e o tamanho podem motivar uma análise, mas nunca justificam, por si só, a remoção.

**R3 — Verificação documentada antes de remover ou consolidar.**
- *O quê:* executar e registar as sete verificações por VM (Entrada #132, secção 8, ponto 2): `.vmsd`, inventário sem truncar, discos existentes, coerência da cadeia, estado da VM, espaço livre, mecanismo de recuperação.
- *Quando:* antes de cada remoção ou consolidação, uma VM de cada vez.
- *Evidência:* resultado de cada verificação na entrada da sessão; medição do espaço antes e depois.
- *Por verificar:* o resultado de cada operação só se conhece depois de a fazer.

**R4 — Espaço mínimo antes de alterar.** [valores provisórios, aprovados pelo Pedro; não testados]
- *O quê:* não iniciar uma alteração, snapshot ou consolidação se a partição da VM ficar abaixo de um mínimo livre.
- *Referência provisória (consolidação):* o tamanho dos discos diferenciais a consolidar, mais 10% da partição.
- *Limitação:* valor não testado; o tamanho dos diferenciais não garante, por si só, o espaço necessário para a consolidação.
- *Referência provisória (snapshot ou alteração):* manter pelo menos 10% da capacidade total da partição livre. Valor não testado. É um **mínimo**, não uma garantia: se a operação exigir mais espaço, avaliar essa necessidade antes de avançar.
- *Regra:* não iniciar a operação se o espaço livre não for suficiente ou se a necessidade de espaço não puder ser estimada com confiança.
- *Evidência:* `df -h` da partição, antes da operação.

**R5 — Limites dos discos.** [valores provisórios, aprovados pelo Pedro; não testados]
- *O quê:* três níveis por partição (`/`, `/home`, `/mnt/VMs`):
  - **80%** — aviso: registar e acompanhar;
  - **85%** — ação: rever a situação (snapshots e retenções) e registar. **Não** implica remover nada automaticamente: qualquer remoção continua sujeita à R2, à R3 e à R4;
  - **90%** — gatilho já escrito do risco #8 (`/home`, `/mnt/VMs`): reavaliar os riscos #8 e #9.
- *Quando:* medição no início de cada sessão do lab, com o mesmo método (`df -h`).
- *Evidência:* os valores medidos, na entrada da sessão.
- *Estado à entrada em vigor:* a 25/10 (#131), `/` a 88% e `/home` a 89% já estão acima do nível de ação: exigem revisão e registo na próxima sessão.

**R6 — Cópia independente das VMs críticas.** [aprovada pelo Pedro; POR EXECUTAR — depende da decisão sobre o suporte]
- *O quê:* manter pelo menos uma cópia independente das VMs críticas, fora do computador.
- *VMs críticas (primeira versão):* DC (Windows Server 2022) e Wazuh.
- *Objetivos provisórios, não testados:* **RPO de uma semana** (perda de dados máxima aceitável) e **RTO de um dia** (tempo máximo previsto para recuperar o serviço).
- *Como:* VM desligada; copiar a pasta inteira; verificar a cópia.
- *Evidência:* data da cópia, local, tamanho, e um **teste de reposição** periódico.
- *Nota:* copiar a pasta com a VM desligada e verificar a cópia é um procedimento inicial; só o teste de reposição permite avaliar se a recuperação funciona de facto.
- *Por verificar:* se já existe alguma cópia (não se afirma que exista); o suporte (depende da decisão sobre o disco externo).

**R7 — Ciclo de vida do snapshot.**
- *O quê:* depois de a alteração estar validada, decidir se o snapshot se mantém ou se remove (com a R3). A decisão fica escrita.
- *Quando:* na sessão em que a alteração é validada, ou na seguinte.
- *Evidência:* registo da decisão e do motivo.

## 5. Exceções

- Um snapshot pode manter-se além do previsto se for o **único ponto de recuperação** de uma VM sem cópia independente. Fica escrito o motivo e uma data-limite de reavaliação; a exceção não se torna permanente por omissão.
- A VM da UC (`vuln-srv-01`) fica **fora** desta política: só se toca nela sem prejudicar a UC.

## 6. Decisões (Pedro, 2026-10-26)

| Decisão | Resultado |
|---|---|
| VMs críticas (R6) | DC (Windows Server 2022) e Wazuh |
| RPO / RTO (R6) | Uma semana / um dia — provisórios, não testados |
| Espaço mínimo (R4) | Consolidação: diferenciais + 10% da partição; snapshot ou alteração: pelo menos 10% da capacidade total da partição livre — provisórios, não testados |
| Limites dos discos (R5) | 80% / 85% / 90% — provisórios |
| **Suporte das cópias independentes (R6)** | **Por decidir** (disco externo ou outro) |
