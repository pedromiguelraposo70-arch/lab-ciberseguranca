# Fase 10 (proposta) — GRC: da prova pontual à prova repetível

> **Estado: [POR EXECUTAR]. Proposta aprovada pelo Pedro a 2026-10-23 (arquitetura e decisões 1 a 6). Ainda não arrancou: falta a pré-condição dos discos (10.0).**
> Construída a 2026-10-23 em quatro versões (as intermédias não foram guardadas), com três revisões: duas externas (outra ferramenta e colegas do Pedro) e a análise do Claude a cada uma.
> Fontes: `claude/ideias-fase10-rascunho.md` (19/10), lista para a Fase 10 da Entrada #130 (§7), decisões do Pedro de 22–23/10.

A Fase 9 fechou lacunas e deixou prova de cada correção — mas prova **pontual**: verificada uma vez, num dia. A Fase 10 faz a pergunta seguinte de uma auditoria: **os controlos continuam a funcionar, e como é que se sabe?**

**Fio condutor da fase — a cadeia completa:**

> identificar um risco → definir o controlo → testar se funciona → verificar se continua a funcionar → registar a evidência → reavaliar o risco residual

Cada bloco contribui para esta cadeia. Nenhum bloco é um projeto à parte.

**Analogia:** a Fase 9 foi a obra com fotografias de cada reparação. A Fase 10 é a lista de verificação de manutenção do prédio: o que se verifica, como, e o que fica escrito para provar que foi verificado. Pôr essa verificação a correr sozinha, de forma periódica, já seria monitorização contínua — e isso pode ficar para depois.

### Três níveis de maturidade de uma prova

| Nível | O que existe | No lab |
|---|---|---|
| 1. **Prova pontual** | um controlo foi testado num momento específico | o que a Fase 9 deixou |
| 2. **Verificação repetível** | um procedimento ou script volta a testar o controlo, com o mesmo método | **o objetivo desta fase** |
| 3. **Monitorização contínua** | cadência de verificação, deteção de falhas e de silêncio, registo dos resultados e tratamento dos alertas | parcial nesta fase (deteção de silêncio no 10.4); completa numa fase posterior |

A fase não tem de terminar no nível 3. Tem de dizer, para cada controlo, em que nível ficou — sem prometer mais do que demonstra.

**Pela regra de alternância do roteiro**, é uma fase de **tónica GRC**, com a técnica como prova.

## Princípios da fase

1. **GRC como objetivo, técnica como prova.** Cada bloco responde: **que risco reduz, que controlo prova, que evidência deixa.**
2. **Não automatizar um controlo que ainda não se sabe testar à mão. Não declarar um controlo eficaz sem evidência. Não confundir um resultado técnico com uma decisão de risco.**
3. **Testar o comportamento, não o estado.** Um serviço ativo não prova que produz alertas; uma regra de firewall não prova que o tráfego é bloqueado; permissões 777 não provam que um anónimo consegue escrever através do serviço (Fase 9: o envio foi recusado com `550`).
4. **Investigar → documentar → resolver → provar que continua** (regra do Pedro, 19/10). Investigação e correção em sessões separadas.
5. **Uma lacuna documentada vale tanto como uma correção.** Se uma integração não fica a funcionar, documenta-se a causa; não se declara concluída porque a configuração "parece certa".
6. **Linguagens por necessidade** (regra do Pedro, 23/10): só as que o nicho GRC pede, quando um bloco as pede. Nesta fase: **só Bash** (tabela abaixo).
7. **No fim de cada bloco, uma pergunta:** *o que sabemos agora sobre o risco que não sabíamos antes?* — e o que esse teste **não** prova (ex.: um envio anónimo recusado no FTP não prova que todas as vias de escrita estão fechadas).
8. **Duas verificações de documentação:** mini-verificação no fim de cada sessão (o que mudou, em que documento) e `checklist-fecho-de-fase.md` no balanço.
9. Blocos de ~1 h, passo a passo, confirmação de cada resultado antes do passo seguinte. Snapshot antes de qualquer alteração, dentro da política definida no 10.0.

**Sobre a ISO 27001:** as referências (cláusula 9.1, A.8.16, A.8.9, A.8.22…) indicam o tema de cada bloco. O lab demonstra **práticas técnicas que apoiam** a implementação desses controlos; **não demonstra conformidade**, que depende também do contexto, do âmbito, dos critérios e da evidência organizacional.

## Critérios de resultado de cada verificação (PASS / FAIL / UNKNOWN)

> Não confundir com os **critérios de aceitação do risco** (10.0): estes dizem se um teste passou; aqueles dizem que nível de risco se pode aceitar.

Definidos **antes** de testar, para cada controlo:

| Resultado | Significa | Exemplo (ilustrativo) |
|---|---|---|
| **PASS** | o controlo foi testado pelo comportamento e cumpriu | envio anónimo recusado pelo serviço |
| **FAIL** | o controlo foi testado e não cumpriu | envio anónimo aceite |
| **UNKNOWN** | não foi possível testar, ou o resultado é inconclusivo | o serviço não responde (pode ser rede, permissões ou o próprio serviço) |

**Regra:** ausência de prova não é prova de falha. Sem resposta por razão desconhecida → UNKNOWN, nunca FAIL automático.

## Rastreabilidade GRC

Cada verificação liga sete elementos:

| Elemento | Pergunta |
|---|---|
| Risco | O que pode correr mal? |
| Controlo | O que deve impedir ou detetar o problema? |
| Teste | Como verifico que o controlo funciona? |
| Evidência | O que registo para demonstrar o resultado? |
| Frequência | Quando repito o teste? |
| Falha | Quem ou o quê deve ser avisado? |
| Decisão | O risco foi reduzido, aceite ou continua em aberto? |

**Onde vive:** dentro dos documentos que já existem — colunas ou folha nova no `registo-riscos.xlsx`, ligada à `declaracao-aplicabilidade-parcial.md`. **Não** num terceiro documento paralelo (a revisão geral de 20/10 mostrou como documentos paralelos se desalinham).

---

## 10.0 — Estabilidade e estado inicial (prioridade máxima)

É a condição de revisão escrita no risco #9 (Alto, P3 × I2): "revisão antes de iniciar a Fase 10". Já houve pausas das VMs por falta de espaço (#120).

- Confirmar se `/`, `/home` e `/mnt/VMs` são sistemas de ficheiros em discos (ou partições) distintos, ou caminhos sobre o mesmo armazenamento — para não contar a mesma capacidade duas vezes (`lsblk`, `df`).
- Identificar o que ocupa o `/` e o `/mnt/VMs` do Mint. Não apagar nada sem saber o que é (decisão do Pedro, #130). **Limitação:** `df` e `du` são o ponto de partida, mas não explicam sozinhos todo o espaço ocupado por discos virtuais, snapshots e ficheiros abertos; medir também ao nível das pastas de cada VM.
- Medir distinguindo **utilização**, **espaço disponível** e **crescimento esperado**.
- **Definir a política de snapshots** (pedida em seis entradas seguidas, #120 a #125, nunca definida) e os **limites de utilização dos discos**. A política responde a cinco perguntas:
  1. Que alterações exigem snapshot prévio?
  2. Que VMs precisam de proteção, e em que condições?
  3. Quando é que um snapshot é removido?
  4. Que espaço livre mínimo é preciso antes de iniciar uma alteração (para a alteração e para a eventual recuperação)?
  5. Que dados exigem uma **cópia de segurança independente**?
- **Um snapshot VMware não é uma cópia de segurança:** vive no mesmo disco que a VM e consome espaço. Não se criam snapshots indiscriminadamente. Os riscos continuam separados: capacidade (#9) e cópias de segurança (#8).
- Voltar a medir os três discos e reavaliar o risco #9.
- **Registar os critérios de aceitação do risco** (decisão 6) no `registo-riscos.xlsx`, ao lado dos critérios v1, **antes de qualquer teste**. Os critérios v1 (#130) definem probabilidade e impacto, mas **não** definiam a aceitação — lacuna face à ISO 27001 (cláusula 6.1.2). Fixá-los antes de ver os resultados evita adaptar os critérios aos resultados.
- **Regra de recuperação** (vale para toda a fase): antes de qualquer alteração que possa interromper o lab, escrever **o estado a preservar**, **o mecanismo de recuperação** e **a condição que obriga a reverter**. Aplica-se sobretudo às atualizações do Wazuh, à criação da OPT2 e à integração Suricata → Wazuh.
- **Verificar, sem aplicar,** as 46 atualizações e o reinício pendente do Wazuh (#129, risco #6): a causa do reinício, o estado dos serviços, o espaço disponível e a capacidade de recuperação. Registar a decisão e a janela prevista. Aplicam-se **antes do 10.4** (decisão 4), para não mudar a base a meio da integração.
- Registar o estado inicial: VMs, serviços, agentes Wazuh, regras do OPNsense. É a referência para comparar no balanço.

**Resultado:** estado inicial documentado; política de snapshots, limites dos discos e critérios de aceitação do risco escritos.
**Ferramenta:** Linux (`df`, `du`, tamanho das pastas das VMs).
**Risco / controlo:** #9, #6 / A.8.6, A.8.8; cláusula 6.1.2 (critérios de aceitação).

## 10.1 — Auditoria da escrita e reavaliação dos riscos

**Sessão(ões) de investigação — observar, testar e documentar, sem alterar o servidor:**

- Inventário, ao vivo, das **vias de escrita** no Servidor Vulnerável, em quatro categorias separadas, testadas pelo **serviço** e não só pela configuração:
  1. **FTP anónimo:** um utilizador sem autenticação consegue escrever? (pasta `/srv/ftp/upload` a 777; envio recusado com `550` na #129);
  2. **FTP autenticado:** o que uma conta local consegue escrever, e se corresponde ao esperado — é aqui que entra o `write_enable` do vsftpd, que diz respeito às **contas locais**, não ao acesso anónimo (não testado);
  3. **Samba convidado:** o acesso sem credenciais à partilha `publico` permite mesmo escrever? (escrita conseguida na Fase 4, #64; **estado atual por verificar**);
  4. **Permissões do sistema de ficheiros:** que utilizadores e serviços conseguem escrever nas pastas relevantes.
- A separação importa: uma exposição a **anónimos** e permissões excessivas de **contas autenticadas** são riscos diferentes. Uma pasta a 777 não prova que o serviço permite a escrita; o `write_enable` não prova que o anónimo pode escrever.
- Confrontar com os critérios v1 os riscos que ainda não o foram: **#1, #2, #3, #5, #6 e #8**.
- Para cada um: risco inerente, controlos existentes (com evidência), risco residual, e decisão — tratar, aceitar ou investigar mais.

**Sessão de correção — separada da investigação:**

- A correção da pasta 777 já está decidida (#130: "correção planeada, não aceite"). Corrigir o que a investigação confirmar, retestar com prova antes/depois e reavaliar o risco #1 (decisão 2). Se a investigação revelar uma exposição inesperada, a prioridade pode mudar.

**Resultado:** registo de riscos atualizado, com o critério aplicado e a decisão justificada de cada risco.
**Ferramenta:** Linux; Excel (registo de riscos).
**Risco / controlo:** #1 / **A.8.3** (restrição do acesso à informação) como controlo principal, com A.5.15 (controlo de acesso) e A.8.9 (gestão da configuração) como apoio; reavaliação geral (cláusula 6.1). Hoje a Declaração de Aplicabilidade liga o risco #1 só ao A.8.9 — atualizá-la neste bloco, com a justificação.

## 10.2 — Primeiro script de auditoria

A "auditoria num comando" passa a ser a **ferramenta transversal da fase**: começa pequena e cresce à medida que o lab muda.

- Aprender o essencial de Bash: variáveis, condições, funções, códigos de saída.
- Verificar **só** controlos que já tenham testes manuais fiáveis.
- Gerar um relatório datado com PASS / FAIL / UNKNOWN.
- **Simular pelo menos uma falha controlada** e confirmar que o script a identifica (o teste do próprio teste).

**Três versões:**

| Versão | O que se aprende | O que demonstra |
|---|---|---|
| V1 | comandos, variáveis, condições, saída | estado de alguns serviços e agentes |
| V2 | funções, códigos de saída, registo de resultados | testes de controlo e relatório datado |
| V3 | verificação de eventos e de resultados de rede | verificação mais abrangente, dentro dos limites dos testes |

**A V1 está concluída quando** (não precisa de verificar todos os controlos da fase):

- executa alguns testes previamente validados à mão;
- produz um relatório datado e com a versão do script;
- distingue PASS, FAIL e UNKNOWN;
- deteta corretamente pelo menos uma falha controlada;
- nunca apresenta como aprovado um teste que não conseguiu executar;
- regista as limitações conhecidas.

A verificação de eventos, a segmentação e os testes de conectividade entram depois. Se uma delas não for tecnicamente viável durante a fase, fica documentada como lacuna — não impede a conclusão do script.

**Estrutura do relatório (ilustrativa):**

```
AUDITORIA DO LABORATÓRIO
Data/hora:
Versão do script:

[PASS]    <controlo> — método de teste
[FAIL]    <controlo> — método de teste
[UNKNOWN] <controlo> — porque não foi possível concluir

Resumo: testados / aprovados / falhados / inconclusivos
Limitações:
```

**Regras do script:** ausência de prova ≠ falha (UNKNOWN); testar o comportamento, não o estado; o relatório preserva a evidência (data, resultado, método, limitações), não só os semáforos.

**Resultado:** V1 funcional, com limitações documentadas e resultados reproduzíveis. Cópia versionada em `scripts/`.
**Ferramenta:** Bash.
**Domínio:** cláusula 9.1 (monitorização e medição).

## 10.3 — Segmento próprio para a Kali do lab

Tirar a Kali da DMZ partilhada com a unidade curricular (#127) e dar-lhe um segmento próprio (OPT2 no OPNsense).

**Desenhar antes de configurar.** A nova interface não se cria só para cumprir o plano. Antes, confirmar e escrever:

- que redes e interfaces estão hoje atribuídas a cada VM (adaptadores VMware e interfaces do OPNsense);
- que segmento fica dedicado à Kali e com que endereçamento;
- que comunicações são permitidas e quais são proibidas;
- como se vai demonstrar que o tráfego atravessa o OPNsense e que **não existe um caminho alternativo** involuntário.

**Depois, configurar e provar:**

- **Correr o script antes da mudança** (referência) e depois.
- Testar o tráfego autorizado, o bloqueado e o comportamento das sessões já abertas (lição da 9.8: a firewall com estado deixa continuar as ligações existentes).
- Critério de conclusão (#130): o tráfego entre segmentos passa pelo OPNsense e as regras dão o resultado esperado — provado com **vários indicadores**, não só um: testes de conectividade positivos e negativos, regras e registos do firewall (Live View), rotas, configuração dos adaptadores virtuais. O TTL é um indício útil, não prova suficiente por si só.
- Acrescentar ao script a verificação do isolamento, se for tecnicamente viável.

**Resultado:** segmentação provada por testes antes/depois; regras e exceções documentadas; `topologia-base.md` atualizada; fica resolvida a questão do adaptador da Kali (lab vs. UC).
**Satélite opcional:** Packet Tracer, para perceber segmentação/VLANs no papel de quem verifica.
**Controlo:** A.8.22.

**Porque antes do 10.4:** o sítio onde o Suricata escuta depende dos segmentos.

## 10.4 — Suricata → Wazuh e deteção de silêncio

Investigação e documentação da lacuna já feitas (#129). Agora: resolver, com a regra de recuperação do 10.0.

- **Primeiro:** aplicar as atualizações do Wazuh verificadas no 10.0, com recuperação definida e depois de confirmado o espaço (decisão 4). Confirmar que tudo funciona antes de começar a integração.

- Provar primeiro a chegada de eventos normais.
- Gerar tráfego de teste controlado e seguir o percurso até ao alerta no Wazuh (as três camadas).
- Investigar como detetar a **ausência** de eventos quando devia haver atividade (alerta de silêncio). **Atenção:** se o próprio fluxo parar, o Wazuh não consegue concluir sozinho que há uma falha só porque deixou de receber dados. O alerta de silêncio precisa de:
  - uma **janela de tempo** definida;
  - uma **fonte de atividade esperada** (algo que deveria gerar eventos de forma regular);
  - um **mecanismo de alerta independente**, que continue a funcionar durante a falha do envio.
- No teste de corte do envio, verificar duas coisas diferentes: se o silêncio é **detetado**, e se o sistema **recupera** depois de o envio ser reposto.
- Testar o que o Suricata deteta em ataques web — gatilho escrito para reclassificar o risco #10.
- Acrescentar ao script uma verificação da chegada de eventos, se houver um método fiável.

**Resultado:** percurso de deteção validado, **ou** lacunas concretas documentadas.
**Ferramenta:** JSON (alertas), regex e XML (regras e configuração do Wazuh), syslog — só o necessário.
**Risco / controlo:** #10 / A.8.16, A.8.15.

## 10.5 — Balanço e reavaliação final

- Consolidar as reverificações que a #130 deixou para esta fase. Cada uma pode ter **sessão própria, antes do balanço**, porque são tarefas técnicas diferentes; o 10.5 junta os resultados, não é o sítio para executar à pressa o que ficou pendente (decisão 3):
  - risco #2: regras 100011 (Kerberoasting) e 100010/100012 (AS-REP);
  - risco #4: o controlo da 9.4 e o caminho de falha do Docker;
  - risco #7: a enumeração lenta (e, eventualmente, corrigir a regra).
- Comparar com o estado inicial do 10.0.
- Atualizar riscos, evidências, limitações e decisões de tratamento.
- Distinguir controlos **funcionais**, **falhados** e **ainda não demonstrados**.
- Fecho pela `checklist-fecho-de-fase.md`; prioridades da Fase 11.

**Resultado:** balanço GRC apoiado por evidência técnica, sem apresentar hipóteses como resultados.

---

## Fora desta fase, e porquê

- **Benchmark CIS (Wazuh SCA ou Lynis):** desviaria do fio condutor; exige confirmar a aplicabilidade de cada critério e investigar os resultados, não só contar falhas. Candidato à Fase 11.
- **Python, Ansible ou outra plataforma:** nesta fase, um script Bash percebido linha a linha vale mais. Python entra quando o script crescer.
- **Execução periódica do script com alerta de falha:** é o que transforma a auditoria repetível em monitorização contínua. Fica para uma fase posterior (decisão 1), a menos que a versão manual esteja estável e haja tempo sem comprometer os objetivos principais.

**Opcional:** validar o certificado do OPNsense pela impressão digital mostrada na consola (#127, #129).

## Linguagens nesta fase

| Linguagem / formato | Entra em | Para quê |
|---|---|---|
| Linux / Bash | 10.0, 10.1, 10.2, 10.3 | verificar configurações, recolher evidência, script de auditoria |
| JSON, regex, XML | 10.4 | ler alertas; escrever e auditar regras do Wazuh |
| Excel | 10.1, 10.5 | registo de riscos e rastreabilidade |
| Python | — | depois desta fase, quando o script crescer |
| SQL | — | só quando um problema o pedir |
| PowerShell | — | em pausa; só se um ponto do AD o pedir |
| Ruby | — | fora (não serve o nicho GRC) |

## Datas fixas

- **~2026-11-24:** confirmar o apagamento do 1.º índice do Wazuh (retenção de 90 dias, #115). Verificação de retenção à parte dos blocos — não pode desaparecer no balanço.
- **~2027-01-15:** próximo scan de vulnerabilidades (cadência trimestral, #126) — provavelmente já depois da fase.

## Estimativa e posts

**6 a 8 semanas** como estimativa de planeamento, não como prazo (decisão 5), a ~1 h por sessão (6 blocos, com a aprendizagem de Bash pelo meio). Regra do Pedro: semanas de trabalho = **mínimo** de posts. A fila do LinkedIn tem 2 a 3 meses de avanço, por isso o ritmo de publicação não depende do ritmo da fase; o que não se faz é partir um resultado em dois para encher uma semana, nem anunciar uma correção ainda não validada.

Títulos provisórios (temas possíveis, não compromissos):

1. Antes de testar os controlos, confirmei se o laboratório estava estável.
2. Uma auditoria num comando: transformar testes em evidência.
3. Segmentar a Kali não basta: é preciso provar o isolamento.
4. Um detetor pode estar ativo e, mesmo assim, não produzir evidência útil.
5. O que mudou no risco residual depois de testar os controlos?

## Decisões tomadas (Pedro, 2026-10-23)

| # | Questão | Decisão |
|---|---|---|
| 1 | Tema | **Da prova pontual à prova repetível.** Execução periódica com aviso fica para uma fase posterior. Ficheiro: `fase10-proposta-grc-prova-repetivel.md` |
| 2 | Correção do risco #1 | Dentro do 10.1, numa sessão separada da investigação |
| 3 | Reverificações #2, #4, #7 | Cada teste com o tempo de que precisar, antes do balanço; o 10.5 consolida |
| 4 | Atualizações do Wazuh | Verificar no 10.0; aplicar no início do 10.4, com recuperação definida |
| 5 | Estimativa | 6 a 8 semanas, como planeamento, não como prazo |
| 6 | Critérios de aceitação do risco | Ver abaixo |

### Decisão 6 — Critérios de aceitação do risco no laboratório

> O responsável pelo laboratório (o Pedro) decide sobre a aceitação do risco residual, com base na evidência recolhida, no impacto potencial e na eficácia dos controlos existentes.
>
> - **Baixo:** pode ser aceite mediante registo.
> - **Médio:** exige justificação documentada e revisão definida (data ou condição).
> - **Alto ou Crítico:** exige tratamento, ou uma exceção temporária explicitamente justificada, delimitada e sujeita a revisão.
>
> A aceitação do risco não equivale à demonstração de que o controlo é eficaz, nem à eliminação do risco.

**Consequências para o registo atual (a confirmar no 10.1):**

- **Risco #2 (Crítico, exceção didática):** encaixa como exceção justificada, delimitada e sujeita a revisão — tem dono, datas (25/09 e 20/10/2026) e condição de revisão (fim da demonstração ou encerramento do lab).
- **Riscos #5, #6 e #8 (Médio, aceites):** confirmar que cada um tem justificação documentada **e** revisão definida; acrescentar o que faltar.
- **Risco #9 (Alto):** não pode ser aceite sem exceção; o tratamento é o próprio 10.0.

## Condições de arranque (bloqueio explícito)

- [x] Os 3 commits da revisão geral publicados no GitHub.
- [x] Estado do repositório confirmado depois da publicação: `main` remoto em `740f285` (verificado com `git ls-remote` a 2026-10-23).
- [ ] Documentação de referência sem alterações pendentes que devam entrar antes da Fase 10.
- [x] Esta proposta aprovada (Pedro, 2026-10-23).
- [ ] Confirmado que a pré-condição dos discos (10.0) pode começar sem pôr em risco as VMs e os dados.

A publicação dos commits e a avaliação dos discos são condições diferentes: uma assegura a base documental; a outra, a capacidade operacional para executar o trabalho.
