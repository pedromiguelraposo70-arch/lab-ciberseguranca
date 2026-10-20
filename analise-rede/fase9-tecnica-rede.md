# Fase 9 — Técnica: segmentação, contenção e rede de visitantes (Entradas #118–#130)

## Nota antes de começar

É a fase que mais mexeu na rede desde a Fase 1: o lab deixou de ser um segmento plano. Só três momentos têm conteúdo de rede relevante — a segmentação e a contenção (9.7/9.8, #127), a rede de visitantes do ponto de vídeo 3 (#128) e a verificação do Suricata com a Kali na DMZ (9.9, #129). As restantes sessões (gMSA, regras Wazuh, `auditd`, saúde do DVWA, passwords, scanner) são de identidade, deteção ou configuração, sem papel da rede, e não têm ficha aqui.

## Ficha 1: Kali na DMZ, com menor privilégio (Sessão 9.7, Entrada #127)

**1. Configuração de rede atual:** a Kali passou do segmento "Ciber" (`192.168.10.0/24`) para o segmento "DMZ" (`192.168.50.0/24`), ligado à interface OPT1 (`em0`) do OPNsense, com IP `192.168.50.10` e gateway `192.168.50.254`. Regra única de passagem na OPT1 ("política B"): a Kali só alcança o Servidor Vulnerável (`192.168.10.101`); tudo o resto é bloqueado por omissão. A gestão do OPNsense passou para o Windows 11 (rede interna).

**2. Porque permitiu [o controlo]:** o tráfego da Kali para a rede interna passou a ser **obrigado** a atravessar o OPNsense — confirmado pelo `ttl=63` e pelas duas linhas no Live View (entrada pela OPT1, saída pela LAN). É isto que faltava na Fase 7 (#104), em que atacante e alvo estavam no mesmo segmento e a regra de bloqueio não tinha efeito. Encaminhamento comprovado nos dois sentidos: o OPNsense está ligado às duas redes e encaminha entre elas sem rotas adicionais; as respostas do Servidor chegam à Kali porque o gateway dele é o OPNsense (`192.168.10.254`). Provas: #127 (ping 3/3, `ttl=63`, Live View OPT1 → LAN), #128 (retestes) e #129 (FTP e scan, com o servidor a ver o IP real da Kali).

**3. O que seria diferente noutra configuração:** dentro de cada segmento continua tudo sem controlo. O Interno é plano (Windows 11, DC, Wazuh e Servidor Vulnerável falam diretamente entre si) e a DMZ é partilhada com uma unidade curricular (a Kali e o `vuln-srv-01` falam sem router no meio). Um atacante dentro do Interno não seria visto nem travado pelo OPNsense.

**4. Que defesa de rede o impediria (ou dificultaria):** separar também o Interno por função (servidores / postos de trabalho) e dar à Kali do lab um segmento próprio, fora da DMZ partilhada — planeado para a Fase 10. O A.8.22 fica "implementado (parcial)" precisamente por estes fluxos sem controlo.

## Ficha 2: contenção no gateway — bloquear não chega (Sessão 9.8, Entrada #127)

**1. Configuração de rede atual:** a mesma da Ficha 1, com uma regra temporária de bloqueio acima da regra de passagem.

**2. Porque permitiu [a contenção, em parte]:** como o tráfego já passa pelo router, a regra de bloqueio funcionou para as ligações novas. Mas o OPNsense é uma firewall com estado: uma ligação já aberta antes do bloqueio continuou a passar (297 pings em 297), porque segue a tabela de estados e não volta a ser avaliada pelas regras.

**3. O que seria diferente noutra configuração:** só depois de apagar os estados dessa ligação (*Diagnostics → States*) é que o tráfego parou. Com uma firewall sem estado, ou num produto que limpa os estados ao recarregar regras, o comportamento seria outro — por isso a conclusão vale para esta configuração, não para todas.

**4. Que defesa de rede o impediria (ou dificultaria):** conter = bloquear **e** cortar as sessões abertas, e capturar a evidência no momento (o playbook foi atualizado com estes dois passos).

## Ficha 3: rede de visitantes temporária (Ponto de vídeo 3, Entrada #128)

**1. Configuração de rede atual:** durante o teste, uma regra temporária na OPT1 deixava a Kali ir para "tudo menos" um alias com as 9 redes privadas e especiais (`NAO_INTERNET`, destino invertido). Depois, uma segunda regra mínima, só para o DNS no próprio OPNsense (`192.168.50.254`, UDP 53).

**2. Porque permitiu [internet sim, interno não]:** o NAT de saída do OPNsense já cobria a OPT1 (modo automático); bastava a regra. A internet por IP funcionou, a rede interna continuou bloqueada, mas os nomes falharam — o DNS é o próprio router, que estava dentro do alias "não internet". A causa foi confirmada pelo Live View (pedido à porta 53 bloqueado) e pela intervenção (com a regra de DNS, os nomes passaram a resolver).

**3. O que seria diferente noutra configuração:** com um alias só de redes privadas (RFC 1918), outros intervalos especiais ficariam acessíveis; com um resolvedor de DNS externo, não seria precisa a regra para o router, mas os visitantes deixariam de usar o DNS controlado da organização.

**4. Que defesa de rede o impediria (ou dificultaria):** numa rede de visitantes real, a regra tem de excluir todas as redes internas (incluindo a da própria firewall) e abrir só os serviços necessários, com o DNS tratado à parte. Tudo foi revertido no fim e provado igual ao estado inicial (regras, alias, contador de tabelas e retestes).

## Ficha 4: o Suricata vê o tráfego da Kali que sai pela LAN, mas o SIEM não o vê a ele (Sessão 9.9, Entrada #129)

**1. Configuração de rede atual:** o Suricata corre no OPNsense e escuta só a LAN (`em1`). A Kali está na DMZ (`em0`).

**2. Porque permitiu [a deteção]:** o tráfego permitido da Kali para o Servidor entra pela `em0` e **sai pela `em1`**, onde o Suricata escuta — um scan da Kali gerou alertas com origem `192.168.50.10` e interface LAN. Um sensor só vê o que passa por onde ele está.

**3. O que seria diferente noutra configuração:** ver tráfego que sai pela LAN não significa ver todo o tráfego da DMZ. Pela arquitetura (o sensor só escuta a `em1`), o tráfego que não passa por essa interface não deve ser visto por este Suricata: dentro da DMZ (Kali ↔ `vuln-srv-01`), dentro do Interno, e o que é bloqueado logo à entrada na OPT1 — **nenhum destes três casos foi testado**; é uma dedução, não uma prova. E os alertas que gera ficam no OPNsense: não há agente nem receção de syslog configurada no Wazuh, por isso não chegam ao SIEM (risco #10).

**4. Que defesa de rede o impediria (ou dificultaria):** pôr o sensor também nas outras interfaces (ou nos segmentos sem router) e enviar os seus alertas para o SIEM, com uma verificação contínua de que continuam a chegar — previsto para a Fase 10.

## Pontos de vídeo

Ponto de vídeo 3 (VLANs, Professor Messer) feito e documentado na #128. Prática de VLANs e trunks fica para o Packet Tracer (programa de redes), porque o lab não usa VLANs.

## Ligação à topologia base

`topologia-base.md` foi atualizada na #127 (Kali na DMZ, OPT1 partilhada com a unidade curricular). A limitação estrutural mais antiga do projeto — tráfego lateral invisível ao gateway — deixou de valer para o fluxo Kali → Interno, mas continua a valer dentro de cada segmento.
