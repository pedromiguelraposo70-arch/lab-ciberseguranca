# Fase 1 — Construção do lab e primeiro reconhecimento (Entradas #1–#9)

## Nota honesta antes de começar

A Fase 1 não é um ataque — é a construção do próprio laboratório (instalar Docker, montar o DVWA, confirmar o acesso). Só duas entradas (#1 e #8) têm mesmo conteúdo de rede relevante: os dois scans nmap, antes e depois de o DVWA estar no ar. O resto desta fase não tem uma história de "configuração de rede permitiu o ataque" para contar, porque ainda não havia ataque nenhum — e forçar essa ligação aqui seria inventar uma lição que a fase não tem. O que esta fase tem, de facto, é a primeira prova de como a rede isolada do lab se comporta quando vista de fora (do Kali).

## Ficha: reconhecimento de rede antes/depois do DVWA (Entradas #1, #8)

**1. Configuração de rede atual:** o Servidor Vulnerável está na mesma sub-rede `192.168.10.0/24` que o Kali, dentro do segmento `Ciber` do VMware — sem qualquer firewall ou segmentação entre os dois nesta fase (o egress filtering só chega na Fase 5). O Kali tem visibilidade total e sem restrições sobre todas as portas do alvo.

**2. Porque permitiu [a visibilidade]:** não há aqui um "ataque" no sentido de exploração — mas a *possibilidade* do reconhecimento (`nmap -sV -sC -p-` a todas as 65535 portas, sem ser bloqueado nem detetado por ninguém) só existe porque, nesta fase, não havia nenhum controlo de rede a limitar o que o Kali conseguia ver ou fazer. O scan da Entrada #1 encontrou só SSH; o da Entrada #8, já com o DVWA a correr, encontrou a porta 80 e o nmap já identificou sozinho, através de scripts NSE, o título da aplicação e uma cookie de sessão sem a flag `httponly` — tudo isto obtido de fora, sem credenciais, só por a rede não ter nenhuma barreira entre o atacante e o alvo.

**3. O que seria diferente noutra configuração:** com uma regra de firewall a restringir, desde o início, que só o tráfego necessário chegasse ao Servidor Vulnerável (por exemplo, só a porta que o exercício do momento precisasse, em vez de todas), o scan `-p-` continuaria a "ver" as portas fechadas, mas a superfície real de reconhecimento seria mais estreita. Isto não seria uma defesa contra um scan em si (scans não se impedem facilmente), mas reduziria o que um atacante aprende de graça antes de sequer tentar explorar algo.

**4. Que defesa de rede o impediria (ou dificultaria):** nada disto foi corrigido nesta fase, e propositadamente — o lab precisa de visibilidade total do Kali para os exercícios funcionarem. Mas em produção, a defesa correspondente seria: segmentação por função (nunca um servidor exposto na mesma rede plana que uma máquina de reconhecimento externo), firewall com regras explícitas de permitir por exceção (não "tudo aberto por defeito"), e um IDS a monitorizar scans de porta completos como o `-p-` usado aqui — o que só viria a existir no lab muito mais tarde, na Fase 7 (Suricata).

## Pontos de vídeo candidatos

Nenhum identificado para esta fase — é sobretudo montagem de ambiente, sem uma lacuna técnica específica que um vídeo complementasse. Fica em aberto para revisão futura, se surgir uma ideia concreta.

## Ligação à topologia base

O segmento `Ciber` (comportamento de hub, sem aprendizagem de MAC — ver `topologia-base.md`) já está presente desde esta primeira fase, embora a sua implicação mais importante (tráfego lateral invisível ao gateway) só se torne relevante e seja documentada muito mais tarde, nas Fases 4, 6 e 7.
