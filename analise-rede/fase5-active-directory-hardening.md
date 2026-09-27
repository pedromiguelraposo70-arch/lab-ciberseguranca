# Fase 5 — Active Directory, hardening de rede e SIEM (Entradas #66–#86)

Aplicação do framework de 4 perguntas à Fase 5. Ao contrário da Fase 2, esta fase tem uma componente de rede muito forte e explícita — é aqui que o projeto passa de "explorar vulnerabilidades" para "aplicar defesas de rede a sério" pela primeira vez.

## Ficha: egress filtering no OPNsense (Entradas #72, #80)

**1. Configuração de rede atual:** regras de bloqueio de saída para a internet no OPNsense, aplicadas por interface/IP — primeiro só ao Servidor Vulnerável (#72), depois alargadas a Windows Server, Windows 11 e Ubuntu Desktop (#80).

**2. Porque é relevante:** é a primeira vez no projeto que uma regra de firewall é desenhada para limitar o *impacto* de uma máquina já comprometida (impedir exfiltração/C2 para fora do lab), em vez de tentar impedir o acesso inicial. Complementa, não substitui, o resto do hardening desta fase.

**3. O que seria diferente noutra configuração:** sem estas regras, qualquer VM comprometida no lab teria acesso de saída irrestrito — o que, num cenário real, permitiria exfiltração de dados ou ligação a infraestrutura de comando e controlo sem qualquer obstáculo.

**4. Que defesa de rede isto exemplifica:** princípio do menor privilégio aplicado ao tráfego de saída, não só de entrada — cada máquina só deve poder comunicar com o que precisa, nunca com "a internet toda" por omissão.

## Ficha: Suricata (IDS), conflito de IP e reservas DHCP estáticas (Entradas #75–#79)

**1. Configuração de rede atual:** IDS Suricata ativado no OPNsense (1160 regras), inicialmente com dificuldades de causa raiz não identificada (#75); confirmado funcional com nmap (#76-#77), mas essa mesma verificação revelou que o Kali estava a aparecer com IP dinâmico em vez do fixo esperado (#77), o que levou à descoberta de um conflito de IP entre Windows Server e Kali (#79), resolvido com reservas DHCP estáticas para reforçar os IPs fixos já definidos.

**2. Porque é relevante:** esta sequência é o melhor exemplo do projeto de como um teste de deteção (Suricata a ver tráfego) expôs um problema de rede completamente diferente (conflito de IP) que, sem essa verificação ativa, teria continuado invisível — o IDS só "confirmou funcionar" precisamente porque os dados que mostrou não bateram certo com o que era esperado.

**3. O que seria diferente noutra configuração:** com reservas DHCP estáticas desde o início (em vez de apenas IPs fixos configurados manualmente em cada VM), o conflito nunca teria acontecido — a causa raiz foi o servidor DHCP do OPNsense não saber que aqueles IPs já estavam "tomados" fora do seu controlo.

**4. Que defesa de rede o impediria:** reservas DHCP estáticas (aplicadas depois, como correção) e, complementarmente, um IDS ativo a sinalizar anomalias de IP/MAC — que é exactamente o que acabou por acontecer aqui, ainda que por acidente mais do que por deteção deliberada do problema.

## Ficha: SIEM Wazuh — cobertura real vs. assumida (Entrada #86)

**1. Configuração de rede/infraestrutura atual:** stack Wazuh completo instalado (Indexer + Manager + Filebeat + Dashboard) e agente registado no Windows 11, testado contra o mesmo cenário de ataque FTP→RCE já visto na Fase 4.

**2. Porque é relevante — nota de honestidade:** este não é, na origem, um problema de rede — é um gap de deteção ao nível do host (o Wazuh via a ligação FTP nos logs, mas não via a execução de comandos daí resultante). Fica registado aqui porque liga diretamente à Fase 4 (mesmo cenário de ataque) e porque a "rede" (que tráfego chega a que sensor) é parte da razão: o Wazuh via tráfego de rede via o FTP em si, mas a execução de comandos no host não gera tráfego de rede novo para o IDS/SIEM apanhar — é um evento local que precisaria de auditd ou de um agente com visibilidade a esse nível.

**3. O que seria diferente noutra configuração:** com auditd configurado a monitorizar execução de comandos e o Wazuh a ingerir esses logs (não só logs de rede/autenticação), a execução de comandos pós-FTP teria sido detetada, independentemente de gerar ou não tráfego de rede novo.

**4. Que defesa isto exemplifica:** a rede sozinha nunca é suficiente para deteção completa — visibilidade de rede (Suricata) e visibilidade de host (auditd + SIEM) cobrem ameaças diferentes; este é o exemplo mais claro do projeto de onde a rede, por si, tem um limite estrutural.

## Pontos de vídeo candidatos

- **Deteção de anomalias de IP/MAC em IDS** — um vídeo sobre regras Suricata para deteção de conflitos de IP ou ARP spoofing complementaria diretamente a Entrada #79, testável reproduzindo o cenário (voltar a atribuir o mesmo IP a duas VMs) e confirmando se o IDS o sinalizaria hoje.
- **auditd + integração SIEM** — já identificado como complemento nas Entradas #86 (aqui) e na análise da Fase 4 (mesmo cenário de ataque); um único vídeo sobre auditd + regras Wazuh personalizadas serve as duas fases.

## Nota GRC (retroativa)

Esta fase já tem o padrão "Nota GRC" a ser adicionado retroativamente às entradas relevantes do registo (#74, #80, #86), seguindo a Opção B decidida a 2026-09-27 — ao contrário das Fases 6-7, que já tinham este padrão de forma orgânica.
