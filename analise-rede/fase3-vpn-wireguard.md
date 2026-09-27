# Fase 3 — VPN WireGuard (Entradas #52–#56)

## Nota de enquadramento

Ao contrário das Fases 1-2, esta fase é sobre **defesa** de rede (cifrar tráfego), não sobre um ataque a explorar. O critério das quatro perguntas aplica-se de forma invertida aqui: não "que configuração permitiu o ataque", mas "que configuração de rede permite ver o que a VPN não esconde".

## Ficha: visibilidade do tráfego cifrado dentro do segmento "Ciber" (Entrada #56)

**1. Configuração de rede atual:** o segmento `Ciber` do VMware comporta-se como um hub — entrega o tráfego a todas as VMs ligadas, não só ao destinatário (comportamento já registado como facto central em `topologia-base.md`). O túnel WireGuard liga Ubuntu Desktop (`10.10.10.1`) e Windows 11 (`10.10.10.2`), com o Kali fora do túnel mas dentro do mesmo segmento físico.

**2. Porque permitiu a observação:** o comportamento de hub deixa o Kali capturar os pacotes UDP na porta `51820` sem qualquer configuração especial (nem modo promíscuo foi preciso) — só por estar ligado ao mesmo segmento. A VPN cifra o **conteúdo** desses pacotes (confirmado: hexadecimal ilegível, sem o padrão típico de um payload de ping), mas não esconde a sua **existência** — o Kali continua a ver tamanhos, timing, e os IPs reais de origem/destino.

**3. O que seria diferente noutra configuração:** com um switch real (não um hub simulado) a segmentar o tráfego por porta, o Kali deixaria de ver os pacotes do túnel de todo, mesmo sem quebrar a cifra — só veria tráfego destinado a ele próprio. A VPN continuaria a proteger o conteúdo da mesma forma; o que mudava era a visibilidade dos metadados (que já não seria "grátis" só por estar na mesma rede).

**4. Que defesa de rede o impediria:** segmentação real ao nível 2 (um switch com aprendizagem de MAC, ou VLANs) impediria a visibilidade lateral do tráfego, mesmo cifrado. Isto complementa a VPN, não a substitui — os metadados (quem fala com quem) continuam a ser um problema que só a cifra de conteúdo não resolve; a defesa correta contra visibilidade de metadados é isolamento de rede, não mais cifra.

## Ficha: divergência entre topologia documentada e configuração real (Entradas #52, #55)

**1. Configuração de rede atual:** antes de a VPN sequer arrancar, dois factos de rede estavam desalinhados com o que o roteiro documentava — o gateway do OPNsense estava em `192.168.10.1`, não `.254`; e o Ubuntu Desktop tinha uma reserva DHCP estática escondida (fora do sítio mais óbvio na interface do OPNsense) que continuava a atribuir-lhe um IP antigo (`192.168.10.10`), mesmo depois de o intervalo dinâmico ter sido corrigido.

**2. Porque bloqueou o trabalho:** não é um "ataque" — é o mesmo tipo de deriva silenciosa de configuração que reaparece várias vezes ao longo do projeto (ver também Entradas #78-79, #106). A lição de rede aqui é sobre confiar na documentação em vez de confirmar o estado real por observação direta.

**3. O que seria diferente:** com um processo de verificação de rede no início de cada sessão (o que o projeto só viria a adotar sistematicamente na Fase 7, sessão 7.0), esta divergência teria sido apanhada antes de gastar tempo a diagnosticar um problema que era, na origem, uma reserva DHCP esquecida.

**4. Que defesa/prática o impediria:** confirmação ao vivo do estado da rede como primeiro passo de qualquer sessão que dependa de IPs fixos — exatamente o hábito que a revisão pós-Fase-7 (Entrada #106) veio a formalizar.

## Pontos de vídeo candidatos

- **Segmentação de rede real (VLANs) vs. o hub simulado do lab** — um vídeo sobre VLANs e switches geridos, com um teste (se possível dentro das limitações do VMware) a confirmar que o Kali deixa de ver o tráfego do túnel. Pode não ser praticável no VMware Workstation sem hardware/software adicional — candidato a confirmar viabilidade antes de comprometer uma sessão a isto.
- **Diagnóstico de falhas de handshake criptográfico** — a causa exata da falha original (Entradas #53-54) nunca foi confirmada, só contornada. Um vídeo sobre debugging do WireGuard ao nível do kernel poderia fechar essa lacuna concreta.
