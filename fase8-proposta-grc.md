# Fase 8 (proposta) — GRC: Governança, Risco e Conformidade aplicados ao lab

As Fases 1-7 construíram o lado técnico por inteiro: atacar (web → serviços → Active Directory), detetar, caçar, responder a um incidente e consolidar o hardening. A Fase 8 muda de pergunta. Já não é "consigo fazer isto?" nem "consigo ver isto?" — é **"se este lab fosse uma organização a sério, que riscos corre, que regras devia seguir, cumpre-as, e o que teria de reportar a quem?"**

**Analogia:** até aqui o projeto instalou fechaduras, alarmes e câmaras numa casa, e testou-os a tentar arrombá-la. A GRC é a parte que decide *que* fechaduras valem o custo, escreve as regras da casa ("a porta das traseiras fica sempre trancada"), verifica de tempos a tempos se as regras são mesmo cumpridas, e sabe a quem ligar (e em quanto tempo) quando alguém entra.

**A vantagem única deste lab:** numa organização real, uma avaliação de risco começa com ameaças *hipotéticas*. Aqui, cada risco tem **prova** — uma entrada do registo onde o ataque foi mesmo feito, e muitas vezes onde a defesa também foi provada. Uma avaliação de risco suportada por evidência real é o artefacto de portefólio mais forte desta fase.

**Tónica: GRC** (com dose técnica no 8.1 e no 8.5), segundo a regra de alternância dos "Parâmetros do projeto" no roteiro. Fase **100% defensiva/documental**, com verificação ao vivo nas VMs sempre que uma regra escrita pode ser testada ("a política diz X; o lab cumpre X?"). Blocos de ~1h. Referencial principal: **ISO/IEC 27001:2022** (Anexo A), por coerência com as ~20 "Notas GRC" já escritas no registo. Complementos: **ISO/IEC 27005** (método de risco), **NIS2** e **RGPD**.

**Só arranca** depois de: Bloco A e Bloco B da revisão pós-Fase-7 fechados (✅ commits `7a6874b` e `f6cb8cb`).

---

## 8.0 — O lab como organização fictícia (âmbito)

Dar ao lab um "dono" fictício — uma pequena empresa inventada (nome neutro, sem imitar nenhuma empresa real) — para que as políticas e os riscos tenham contexto de negócio: o que faz, que dados trata, o que lhe custaria parar um dia. Definir o **âmbito**: que máquinas, serviços e dados entram na avaliação (as 7 VMs da `analise-rede/topologia-base.md`) e o que fica de fora.

**Porquê primeiro:** sem contexto de negócio, "impacto" não tem significado — é o mesmo princípio da secção "Consequência para a organização real" que já usamos nas entradas.
**Entregável:** secção de abertura do documento de risco (ver 8.2).
**Domínios:** ISO 27001 cláusula 4 (contexto e âmbito).

## 8.1 — Inventário e classificação de ativos

Listar os ativos (VMs, serviços, contas, dados) com dono, função e classificação **CID** (Confidencialidade, Integridade, Disponibilidade — alto/médio/baixo). Ex.: o Controlador de Domínio é crítico em integridade e disponibilidade; o Servidor Vulnerável guarda dados de teste sem valor.

**Verificação ao vivo:** confirmar que o inventário bate com o que existe mesmo (lição recorrente do projeto: documentação ≠ realidade, Entradas #55, #99, #106).
**Opcional (dose técnica):** correr um scanner de vulnerabilidades (tipo OpenVAS/Greenbone) contra o lab a partir do Kali — ferramenta nova, dentro da espinha técnica (gestão de vulnerabilidades), cujos resultados alimentam diretamente o 8.2.
**Domínios:** ISO 27001 A.5.9 (inventário de ativos), A.5.12 (classificação).

## 8.2 — Avaliação de risco suportada por evidência — o coração da fase

Para cada ataque real do lab (as 19 linhas da `tabela-resumo-ataques.xlsx` + os achados da `analise-rede/`), registar: ativo afetado, ameaça, vulnerabilidade, **probabilidade × impacto** (escala simples 1-3 ou 1-5), nível de risco, e a **entrada do registo que o prova**. Distinguir risco *inerente* (antes da defesa) de risco *residual* (depois da defesa já aplicada e provada).

**Entregável:** registo de riscos (`registo-riscos.xlsx`, no mesmo estilo da tabela-resumo — é o formato que se usa em GRC na prática).
**Domínios:** ISO 27001 cláusula 6.1.2; ISO/IEC 27005.

> **🎬 Ponto de vídeo 1** — *depois de:* 8.2 fechado. *Tema:* metodologias de avaliação de risco (ISO 27005 / matriz probabilidade × impacto) — confirmar se a escala e o método que usámos batem com a prática real. *O que testar:* reclassificar 2-3 riscos do registo com o método do vídeo e comparar resultados (não é teste em VM, é teste do próprio método — honesto sobre isso). *Candidatos a confirmar ao chegar lá:* "Getting Started with GRC in Cybersecurity"; curso gratuito CNCS/Iscte (NAU) "Cibersegurança para Executivos: Planeamento, Risco e Conformidade" (módulo de risco).

## 8.3 — Tratamento de risco e Declaração de Aplicabilidade (parcial)

Para cada risco: **mitigar, aceitar, transferir ou evitar** — e porquê. Formalizar aqui as duas aceitações de risco já assumidas na Fase 7 (`hardening-baseline.md` pontos 8 e 9: passwords fracas de `svc_sql`/`svc_legacy` mantidas de propósito; VMs não atualizadas) com dono, justificação e data de revisão — é exatamente assim que uma organização documenta um risco aceite.
**Declaração de Aplicabilidade parcial:** só os controlos do Anexo A que o lab já toca (cerca de 20, já citados nas Notas GRC — ex. A.8.28, A.8.16, A.8.9, A.8.20), cada um com "aplicado / parcial / não aplicado" e a evidência.

**Domínios:** ISO 27001 cláusula 6.1.3, Anexo A.

## 8.4 — Políticas: escrever as regras da casa

Escrever 2-3 políticas curtas (1 página cada), escritas como numa PME real, ligadas a riscos do 8.2:
- **Controlo de acesso e passwords** (liga a Brute Force, Kerberoasting, bloqueio de conta).
- **Registo e monitorização** (liga a Wazuh/Suricata e às lacunas de deteção da Fase 7).
- **Gestão de vulnerabilidades e configuração segura** (liga a FTP/Samba/MariaDB mal configurados e à decisão sobre patches).

**Entregável:** pasta ou ficheiro de políticas (decidir na altura, sem criar estrutura antes de haver conteúdo).
**Domínios:** ISO 27001 A.5.1 (políticas), A.5.15, A.8.5, A.8.8, A.8.15-A.8.16.

## 8.5 — Auditoria interna ao vivo: "a política diz X — o lab cumpre X?"

Pegar em cada frase verificável das políticas do 8.4 e testá-la **nas VMs**, com evidência (comando + resultado + screenshot): ex. "a conta bloqueia ao fim de 5 tentativas" → teste real no AD; "todos os servidores enviam logs para o SIEM" → `agent_control -l` no Wazuh; "nenhum serviço aceita login anónimo" → teste FTP/Samba a partir do Kali. Cada falha é uma **não-conformidade**, registada com ação corretiva — mesmo que a correção fique para depois.

**Porquê importa:** é o ângulo "testar nas VMs" da GRC — e a lição do projeto inteiro (configurações derivam em silêncio) aplicada de forma formal.
**Domínios:** ISO 27001 cláusula 9.2 (auditoria interna), 10.2 (não-conformidade e ação corretiva).

> **🎬 Ponto de vídeo 2** — *depois de:* 8.5 fechado. *Tema:* como se conduz uma auditoria interna / recolha de evidência para ISO 27001. *O que testar nas VMs:* repetir 2 verificações do 8.5 com a técnica de recolha de evidência do vídeo e ver se a evidência que guardámos seria aceite por um auditor. *Candidatos a confirmar ao chegar lá:* "GRC Analyst Masterclass"; Professor Messer (Security+ D5 — governança, auditoria).

## 8.6 — NIS2 e RGPD aplicados a incidentes reais do lab

Duas perguntas concretas, cada uma sobre um incidente que já aconteceu no lab:
- **NIS2:** "se a organização fictícia fosse uma entidade abrangida pela NIS2, o incidente da Entrada #104 (FTP → RCE) obrigava a notificar? A quem, e em que prazos?" (aviso inicial em 24h, notificação em 72h, relatório final em 1 mês — artigo 23.º; confirmar na altura a transposição portuguesa).
- **RGPD:** a Entrada #97 capturou um **dado pessoal real** (o email da conta Microsoft). Numa organização, isso seria uma violação de dados pessoais? Teria de ir à CNPD em 72h (artigo 33.º)? E o cuidado de tapar o email antes de publicar — que princípio do RGPD aplica?

**Perspetiva da organização:** o que custaria *não* notificar a tempo (coimas, reputação) — mesmo espírito das secções "Consequência para a organização real".
**Domínios:** NIS2 art. 21.º e 23.º; RGPD art. 33.º-34.º; ISO 27001 A.5.24-A.5.28, A.5.34.

> **🎬 Ponto de vídeo 3** — *depois de:* 8.6 fechado. *Tema:* NIS2 na prática em Portugal (quem está abrangido, prazos de notificação). *O que testar:* rever a resposta ao incidente da Entrada #104 (`playbook-resposta-incidentes.md`) e acrescentar o passo de notificação que faltar. *Candidatos a confirmar ao chegar lá:* curso gratuito CNCS/Iscte (NAU) "Cibersegurança para Executivos: Preparação para a NIS2".

## 8.7 — Balanço, publicação e programa da Fase 9

Fecha com o **entregável que liga à fase seguinte**: uma lista priorizada por risco de tudo o que ficou por tratar — não-conformidades do 8.5, riscos a mitigar do 8.3, lacunas do NIS2/RGPD do 8.6. Essa lista é o programa da **Fase 9 (tónica técnica)**. Candidatos já previsíveis: gestão de vulnerabilidades com scanner, `auditd` + Wazuh para deteção de execução de comandos, gMSA nas contas de serviço, patching controlado.

Depois: o que a fase GRC mudou na forma de olhar para o lab; atualizar READMEs (EN/PT) e a linha do tempo; guia de estudo da Fase 8 (mesmo formato dos anteriores). Ligação natural ao percurso de certificação GRC já explorado (GRCP como ponto de entrada), sem acrescentar formações novas.

**Domínios:** transversal.

---

## Trilho técnico paralelo (durante a Fase 8)

Para a parte técnica não parar enquanto a tónica é GRC — sem ser por impulso. Candidatos já identificados na revisão pós-Fase-7, por ordem de prioridade (a primeira dá mais valor à espinha técnica):

1. **`auditd` + Wazuh** — deteção de execução de comandos (lacuna das Entradas #60/#86, Fases 4-5).
2. **Script de verificação de saúde dos sensores** — Wazuh/Suricata vivos e na interface certa, via shell (lição da Entrada #99; candidato mais forte da `scripts/README.md`).
3. **SMB signing + NTLM relay** — verificar na prática a defesa referida na Entrada #98 (Fase 6).
4. **Suricata/Zeek para tráfego dentro do mesmo segmento** e **VLANs no VMware** — a limitação estrutural "hub" do segmento "Ciber" (Fases 3 e 7).

**Regra de entrada:** um complemento por semana no máximo, nos 1-2 dias reservados; cabe numa sessão (~1h); snapshot antes; entrada normal no registo marcada "Complemento". Se um complemento mostrar que um risco do 8.2 estava mal classificado, atualiza-se o registo de riscos — é a ligação entre os dois trilhos.

## Notas

- **Três artefactos de portefólio de alto valor** para um lugar júnior de GRC/risco: o **registo de riscos com evidência** (8.2), a **Declaração de Aplicabilidade parcial** (8.3) e o **relatório de auditoria interna com não-conformidades reais** (8.5).
- **Ficheiros novos na raiz**, como os da Fase 7 (`mapa-cobertura-mitre-attack.md`, `playbook-resposta-incidentes.md`, `hardening-baseline.md`) — coerente com a decisão de não criar uma pasta GRC paralela. Exceção possível: as políticas (8.4), se forem 3 ficheiros, podem justificar uma pasta — decidir só quando existirem.
- **Pontos de vídeo:** 3, desenhados dentro do plano (regra de 2026-09-27). Os candidatos são propostas; confirmam-se ao chegar a cada ponto. Os complementos já identificados para as Fases 1-7 (`analise-rede/`) podem correr em paralelo.
- **Escalas simples de propósito:** probabilidade × impacto em 1-3 ou 1-5, não metodologias quantitativas (euros, ALE) — o objetivo é perceber o raciocínio, não fingir precisão.
- **Honestidade sobre limites:** a organização é fictícia; os valores de impacto são estimativas didáticas. O que é real é a evidência técnica de cada risco.
- Isto é uma **proposta/rascunho** — ajusta a ordem, remove ou acrescenta blocos antes de começar, tal como nas Fases 6 e 7.
