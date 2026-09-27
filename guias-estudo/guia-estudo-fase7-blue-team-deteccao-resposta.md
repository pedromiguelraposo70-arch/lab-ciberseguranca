# Guia de Estudo — Fase 7: Blue Team — Deteção e Resposta

## 1. O que foi esta fase, em 30 segundos

Se as Fases 5-6 foram sobre construir e testar defesas, a Fase 7 foi sobre uma pergunta diferente: essas defesas estão mesmo a funcionar agora, e como é que se prova isso? Seis sessões (7.0 a 7.6), todas a girar à volta da mesma disciplina: nunca aceitar "está configurado" como resposta — só "está confirmado ao vivo" conta.

## 2. Sessão 7.0 — A deteção estava assumida viva, e não estava

Antes de avaliar a stack de deteção a sério, foi preciso primeiro confirmar que ela existia de facto. Dois agentes Wazuh apareciam desconectados (recuperaram sozinhos, mas só um refresh do Dashboard o revelou), e o Suricata estava completamente parado — com dois bugs reais e distintos por trás: primeiro, o motor agarrado à interface de rede errada (OPT1 em vez de LAN, apesar da GUI mostrar "LAN" selecionado); depois, mesmo corrigido, o processo "morria" sozinho de vez em quando (um padrão de proteção contra reinícios em loop) sem que a GUI refletisse isso — só visível por SSH, a correr `ps aux`.

## 3. Sessão 7.1 — O mapa de cobertura MITRE ATT&CK

Primeira auditoria sistemática do lab: os 19 ataques já feitos, técnica a técnica, confrontados com o que a deteção realmente apanha — com células vermelhas honestas em vez de um resumo só dos sucessos. Este mapa passa a ser o guião das sessões seguintes.

## 4. Sessão 7.2 — Fechar lacunas (e descobrir que o próprio mapa também erra)

Duas regras Wazuh novas e reais: `100012` para AS-REP Roasting (campo `preAuthType: 0` do evento 4768) e `100013` para RCE via web shell (nível 12, a mais severa do lab, porque confirma execução de comandos já a acontecer, não só uma tentativa). Mas a lição mais valiosa desta sessão foi ao contrário: uma terceira lacuna, dada como aberta no mapa, afinal já estava coberta por uma regra de fábrica do Wazuh que a análise estática original nunca tinha encontrado — corrigir o mapa, sem escrever código desnecessário, foi tão importante como escrever as regras novas.

## 5. Sessão 7.3 — Threat hunting proativo: quando um alerta dispara mas mente

A descoberta mais subtil da fase: consultando diretamente a API do Wazuh Indexer (sem depender do Dashboard nem de nenhuma regra), confirmou-se que a recolha do BloodHound gerava sim um alerta — mas classificado como "possível pass-the-hash" ou "possível RDP", nomes completamente errados para o que realmente aconteceu (enumeração do AD). Um alerta a disparar não significa a técnica identificada corretamente — é a diferença entre um analista júnior, que fecharia o caso ao ver o alerta, e um mais experiente, que pergunta se o nome faz sentido com o contexto real.

## 6. Sessão 7.4 — Resposta a incidentes: o ciclo completo, com uma falha real pelo caminho

Detetar → triar → conter → erradicar → recuperar → lições aprendidas, praticado sobre o ataque real de FTP anónimo → RCE. O momento mais valioso não foi nenhum passo que correu bem à primeira — foi a primeira tentativa de conteção (uma regra de firewall no OPNsense) ter falhado silenciosamente: Kali e o alvo partilham o mesmo segmento de rede, por isso o tráfego nunca chega a passar pelo gateway, e a regra "aplicada sem erro" não tinha efeito nenhum. Só o teste funcional (repetir o ataque) revelou isto. A conteção teve de descer ao nível do próprio host (`iptables`). Na erradicação, apareceram quatro web shells em vez de um — só por se ter olhado explicitamente para a pasta em vez de assumir.

## 7. Sessão 7.5 — Baseline de hardening consolidado: a deriva descoberta

Nove defesas espalhadas por quatro meses de registo, reunidas num só documento, sete reconfirmadas ao vivo — e uma correção real encontrada pelo caminho: uma exceção de firewall (porta 80 do egress filtering) tinha revertido sozinha desde a Entrada #92, sem que ninguém a tivesse mudado deliberadamente. Duas lacunas ficaram documentadas como risco aceite conscientemente, não como silêncio.

## 8. Como nos podemos defender (resumo transversal)

- Nunca assumir que uma stack de deteção está viva só porque foi instalada — confirmar com prova recente, não com memória.
- Um alerta a disparar não é o mesmo que a técnica correta identificada — verificar sempre se o nome do alerta faz sentido com o evento real.
- Um firewall de perímetro não protege tráfego dentro do mesmo segmento de rede — para isso é preciso segmentação real (VLANs) ou conteção ao nível do host.
- Cada fase de resposta a incidentes deve ser validada antes de avançar para a seguinte, nunca assumida como bem-sucedida só por não ter dado erro.
- Configurações de segurança revertem sozinhas ao longo do tempo, mesmo sem intervenção deliberada — só reverificação regular (não auditorias pontuais) apanha isto.

## 9. Estado de compreensão (honesto)

Consigo explicar cada sessão desta fase por palavras próprias, incluindo os três momentos em que algo dado como garantido afinal não estava (7.0, 7.3, 7.5) — esse é provavelmente o fio condutor mais importante da fase: a pergunta por defeito mudou de "está configurado?" para "está mesmo a funcionar, agora, e como se prova isso?". A parte que ainda merece mais estudo: aprofundar threat hunting proativo (7.3) como disciplina própria, para além deste primeiro exercício guiado por uma hipótese única.

**Fase 7 do roteiro concluída** (Entradas #99–#105).
