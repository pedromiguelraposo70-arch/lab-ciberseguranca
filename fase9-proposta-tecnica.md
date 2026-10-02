# Fase 9 (proposta) — Técnica: fechar o que a Fase 8 priorizou

A Fase 8 terminou com uma lista priorizada do que ficou por tratar (Entrada #117). Pela regra de alternância dos "Parâmetros do projeto" no roteiro, essa lista é o programa desta fase: a Fase 9 é de **tónica técnica**, fecha lacunas reais e **produz a prova** que a Fase 10 (GRC) vai reverificar quando reavaliar o risco residual.

**Analogia:** a Fase 8 foi a inspeção ao prédio, que deixou uma lista de reparações por ordem de urgência. A Fase 9 é a obra: fazer as reparações e guardar a prova de cada uma (fotografia, fatura, teste), para a próxima inspeção poder confirmar que ficaram bem feitas.

**Critério de escolha:** sempre a via mais didática, mesmo que dê mais trabalho e mais erros (decisão do Pedro, 2026-10-02). Profundidade antes de território novo: aprofundar a espinha técnica que já existe (identidade e acesso, hardening, deteção, gestão de vulnerabilidades).

**Tónica: técnica**, com a dose GRC no fim de cada sessão (que risco ou controlo mudou de estado) e no balanço 9.10. Blocos de ~1h, passo a passo, confirmação de cada resultado antes do passo seguinte. Snapshot antes de qualquer alteração.

**Só arranca** depois de: Fase 8 fechada (✅ commit `fabfc62`; README da raiz atualizado em `ca7f274`).

---

## 9.0 — Arrumar a casa

Pendentes da revisão de fim da Fase 8: descobrir qual das VMs Ubuntu é o Wazuh e o que é a `Debian 12.x`; ver o que ocupa o disco `/` do Mint (88%); limpar o `anonymous_enable` duplicado do vsftpd; snapshots das VMs que vão ser alteradas nesta fase.

**Prova:** inventário de VMs confirmado ao vivo (nome, disco, função).
**Domínios:** ISO 27001 A.5.9 (inventário), A.8.6 (capacidade), A.8.9 (configuração).

## 9.1 — Contas de serviço geridas (gMSA)

Criar uma conta de serviço nova como **gMSA** (a password é gerada e rodada pelo próprio domínio, longa e aleatória, e ninguém a conhece). Repetir contra ela o teste da Fase 6 e confirmar que a password não se consegue obter. As contas `svc_sql` e `svc_legacy` mantêm-se como estão, por decisão de aceitação já registada (risco #2, `hardening-baseline.md` ponto 8): a conta nova mostra a correção real ao lado da fraqueza deliberada.

**Prova:** o mesmo teste, com resultado oposto nas duas contas.
**Fecha:** risco #2 (demonstração da mitigação; o risco aceite mantém-se).
**Domínios:** ISO 27001 A.5.17, A.8.5.

> **🎬 Ponto de vídeo 1** — *depois de:* 9.1. *Tema:* contas de serviço no Active Directory (porque as passwords pensadas para pessoas não servem para máquinas). *O que testar nas VMs:* repetir a criação da gMSA com o método do vídeo e confirmar que o teste continua a falhar. *Candidatos a confirmar ao chegar lá:* Professor Messer (Security+), documentação oficial da Microsoft.

## 9.2 — Regra de deteção para a técnica real (alerta enganador)

Hoje a recolha do BloodHound dispara as regras de fábrica `92652`/`92657` por coincidência de mecanismo, com um nome errado (Entrada #90). Escrever uma regra Wazuh que reconheça a técnica pelo que ela é, seguindo a checklist `validar-regra-wazuh`. Se a deteção não for possível com os registos disponíveis, o resultado honesto é a lacuna escrita no mapa de cobertura, com a razão.

**Prova:** alerta com o nome certo, validado de ponta a ponta, ou a lacuna documentada.
**Fecha:** risco #7.
**Domínios:** ISO 27001 A.8.16.

## 9.3 — `auditd` com Wazuh: ver o que se executa no Servidor Vulnerável

Lacuna de deteção mais antiga do lab (Entradas #60 e #86): comandos executados no Servidor Vulnerável não deixam rasto no SIEM. Ativar o `auditd` com poucas regras bem escolhidas e encaminhá-las para o Wazuh. Atenção ao ruído: registar tudo é tão inútil como não registar nada.

**Prova:** um comando executado no servidor aparece no Wazuh, com utilizador e hora.
**Fecha:** lacuna de deteção das Fases 4-5 (trilho técnico paralelo, candidato 1).
**Domínios:** ISO 27001 A.8.15, A.8.16.

> **🎬 Ponto de vídeo 2** — *depois de:* 9.3. *Tema:* deteção em Linux (que eventos vale a pena registar e como evitar afogar o SIEM em ruído). *O que testar nas VMs:* acrescentar uma ou duas regras `auditd` sugeridas pelo vídeo e confirmar que o Wazuh as apanha. *Candidatos a confirmar ao chegar lá:* 13Cubed.

## 9.4 — Saúde do Apache/Docker: preventivo e detetivo

O DVWA esteve parado sem ninguém dar por isso (Entrada #108). Dois controlos: um **preventivo** (o contentor volta a arrancar sozinho depois de um encerramento não limpo) e um **detetivo** (um alerta quando o serviço cai). Liga-se ao script de verificação de saúde dos sensores (`scripts/README.md`, candidato da Fase 7), que pode nascer aqui.

**Prova:** derrubar o serviço de propósito e ver o alerta e a recuperação.
**Fecha:** risco #4.
**Domínios:** ISO 27001 A.8.16, A.5.30 (continuidade).

## 9.5 — Passwords antigas do domínio

A regra de 16 caracteres (corrigida na Entrada #115) só vale para passwords novas. O Active Directory não guarda o tamanho das passwords, só a data da última alteração: o levantamento mostra quem **pode** ter uma password curta (alterada antes de 29/09/2026), não quem a tem. Decidir o tratamento dessas contas (por exemplo, obrigar a mudar no próximo login) e escrever a decisão.

**Prova:** lista das contas afetadas e a decisão tomada para cada grupo.
**Fecha:** lacuna de controlo 4 (só passa a risco, ou fecha, depois do levantamento).
**Domínios:** ISO 27001 A.5.17.

## 9.6 — Scanner de vulnerabilidades

Medir o que hoje só se afirma ("as VMs não têm patches"). Escolha da ferramenta na própria sessão: o Greenbone/OpenVAS é o mais completo mas pesado em disco e memória (ligação ao risco #8); há opções mais leves. Correr só contra `192.168.10.0/24`.

**Prova:** relatório do primeiro scan, ligado aos riscos que confirma ou contradiz.
**Fecha:** lacuna de capacidade 5b; dá evidência nova ao risco #6 (que continua aceite).
**Domínios:** ISO 27001 A.8.8.

## 9.7 e 9.8 — Segmentação de rede (VLANs)

A Declaração de Aplicabilidade marca o A.8.22 (segregação de redes) como **"Não aplicável"**, porque o lab é um segmento único. Esse mesmo segmento único explica a falha de contenção da Entrada #104 (a regra no OPNsense não teve efeito porque atacante e alvo estavam na mesma rede). **9.7:** desenho (que máquinas vão para que segmento e porquê) e configuração no VMware e no OPNsense. **9.8:** prova: repetir a contenção da #104 e ver se agora funciona no OPNsense.

**Cuidado:** é a sessão que mexe na rede de que todas as outras dependem, por isso vem depois delas. Snapshots de todas as VMs antes, o que ocupa disco (risco #8: confirmar o espaço livre primeiro). Plano de regresso escrito antes de começar.

**Prova:** A.8.22 passa de "Não aplicável" a "Implementado", com a contenção a funcionar no gateway.
**Domínios:** ISO 27001 A.8.20, A.8.22.

> **🎬 Ponto de vídeo 3** — *depois de:* 9.8. *Tema:* segmentação de rede (VLANs e regras entre segmentos). *O que testar nas VMs:* comparar o desenho do vídeo com o nosso e testar uma regra entre segmentos que ele proponha. *Candidatos a confirmar ao chegar lá:* Professor Messer (Network+).

## 9.9 — Verificações pendentes

Reteste funcional da recusa de upload FTP e teste de ponta a ponta do Suricata até ao Wazuh (secção B da Entrada #117). Feitas depois das VLANs, já confirmam também que a rede nova não partiu a deteção.

**Prova:** duas confirmações ao vivo.
**Domínios:** ISO 27001 A.8.9, A.8.16.

## 9.10 — Balanço e prova para a Fase 10

Atualizar o `registo-riscos.xlsx` (riscos residuais), a `declaracao-aplicabilidade-parcial.md` (estados dos controlos), o mapa de cobertura MITRE, os READMEs (EN/PT) e escrever o guia de estudo da Fase 9. Fecha com a lista do que a Fase 10 (GRC) vai reverificar.

**Domínios:** transversal; ISO 27001 cláusula 10 (melhoria).

---

## O que fica fora, e porquê

- **NTLM relay:** é um ataque do mesmo tipo do Pass-the-Hash excluído na Fase 6 por ser demasiado intrusivo; a defesa (SMB signing) já foi reconfirmada na Sessão 7.5.
- **Riscos #5, #6 e #8:** aceites com justificação escrita (Entrada #117); a Fase 9 só lhes acrescenta evidência quando calha (o scanner no #6, o disco no #8).
- **Legion:** guardada como ideia para o futuro.
- **Questões jurídicas da Fase 8** (arts. 40.º a 44.º, 30 dias úteis, retalhista online): não são técnicas; ficam para confirmar no texto oficial ou no curso CNCS/Iscte.

## Notas

- **Data fixa fora da sequência:** por volta de **24/11/2026**, confirmar no Wazuh que o primeiro índice de agosto foi apagado pela política `retencao-90-dias` (Entrada #115).
- **Ordem pensada:** primeiro o que precisa da rede estável (9.1 a 9.6), depois a rede nova (9.7, 9.8), por fim as verificações que confirmam que nada se partiu (9.9).
- **Honestidade sobre limites:** se uma sessão não chegar à prova (por exemplo, uma regra de deteção impossível com os registos disponíveis), o resultado é a lacuna escrita, não uma prova forçada.
- Os comandos de cada sessão escrevem-se quando se chega a ela, como nas fases anteriores.
- Isto é uma **proposta**: ajusta a ordem, remove ou acrescenta blocos antes de começar.
