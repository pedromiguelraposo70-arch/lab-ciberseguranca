# Fase 7 — Blue Team: deteção e resposta (Entradas #99–#105)

Aplicação do framework de 4 perguntas à Fase 7. Tal como a Fase 6, esta fase já tem "Nota GRC" a aparecer organicamente (não precisa da adenda retroativa da Opção B) — a análise aqui foca-se na perspetiva de rede.

## Ficha: Suricata preso à interface errada — um blind spot puramente de configuração de rede (Entrada #99)

**1. Configuração de rede atual:** o motor Suricata, apesar de a GUI mostrar a interface `LAN` selecionada, estava na prática a capturar pacotes do dispositivo `em0` (interface `OPT1`, `192.168.50.0/24`) em vez de `em1` (interface `LAN`, `192.168.10.0/24` — a rede real do lab).

**2. Porque causou o problema:** não é uma falha do IDS em si — é uma dessincronização entre o que a interface de configuração mostrava e o que o motor tinha efetivamente vinculado, possivelmente arrastada de uma configuração anterior nunca limpa. O resultado prático foi um IDS "a correr" mas cego a 100% do tráfego real do lab, sem qualquer aviso da GUI.

**3. O que seria diferente noutra configuração:** com a interface corretamente vinculada a `em1` desde o início, os alertas do Suricata teriam estado disponíveis (embora limitados pelo comportamento hub do segmento — ver Fase 1/3) durante toda a Fase 6, tornando possível correlacionar tráfego de rede com os eventos Wazuh já capturados nessa fase.

**4. Que defesa de rede isto exemplifica:** a necessidade de verificar sensores de deteção pela fonte primária (o processo vivo, via shell) e não só pela interface de gestão — o mesmo princípio de "instalar não é o mesmo que ter cobertura" já visto no Wazuh (Fase 5, Entrada #86), agora aplicado ao IDS de rede.

## Nota: limitação hub reconfirmada (Entrada #99, ponto 1)

O primeiro teste desta entrada (nmap contra o Servidor Vulnerável, mesma sub-rede do Kali) confirmou de novo, sem surpresa, a limitação já registada nas Entradas #77 e na ficha da Fase 1: tráfego entre duas VMs no mesmo segmento "Ciber" nunca atravessa o OPNsense, logo nunca é visto pelo Suricata — só o segundo teste (nmap contra o próprio OPNsense) e, mais tarde, o teste final pós-correção geraram alertas reais.

## Ligação à Fase 4 (Entrada #104 — resposta a incidentes)

O playbook de resposta a incidentes desta entrada reutiliza deliberadamente o cenário FTP anónimo + Apache = RCE já registado na Fase 4 (Entradas #59-#60) — incluindo, na simulação de contenção, a confirmação prática de que uma regra de firewall no OPNsense não teria efeito nenhum sobre o tráfego Kali→Servidor Vulnerável, por estarem no mesmo segmento (o mesmo facto de hub da rede "Ciber"). Ficha completa já na análise da Fase 4; não duplicada aqui.

## Pontos de vídeo candidatos

- **Suricata/Zeek — deteção de tráfego lateral dentro do mesmo segmento** — já que o comportamento hub do "Ciber" é a limitação estrutural mais recorrente do projeto, um vídeo sobre técnicas de deteção que não dependem de o tráfego atravessar um gateway (port mirroring, um sensor por segmento) seria o complemento mais diretamente ligado a esta descoberta.
- Candidato já referido na Fase 3: viabilidade de VLANs/segmentação adicional dentro do VMware Workstation, que resolveria a limitação na origem em vez de a contornar com mais sensores.
