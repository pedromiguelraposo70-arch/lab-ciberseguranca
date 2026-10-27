# Topologia base do laboratório

Confirmada ao vivo, máquina a máquina, em 2026-09-26 (Entrada #106 do registo). **Atualizada em 2026-10-18 (Entrada #127, Sessões 9.7/9.8): Kali na DMZ.** Esta é a rede que serve de ponto de partida a todas as fichas desta pasta — cada ficha de fase assinala explicitamente quando a rede era diferente nesse momento do projeto.

## Virtualização e segmento

- **Virtualização:** VMware Workstation.
- **LAN Segment do VMware, `Ciber`:** comporta-se como um hub (sem aprendizagem de MAC) — todas as VMs ligadas a este segmento veem o tráfego umas das outras. Este é o facto de rede mais transversal do projeto: qualquer regra de firewall aplicada só no gateway (OPNsense) não tem efeito nenhum sobre tráfego entre duas VMs do mesmo segmento, porque esse tráfego nunca chega a passar pelo router (ver Entradas #77, #99, #104).

## Router / Firewall (OPNsense)

Três interfaces:

| Interface | IP | Rede |
|---|---|---|
| LAN (`em1`) | `192.168.10.254` | `192.168.10.0/24` — a rede do lab |
| OPT1 (`em0`) | `192.168.50.254` | `192.168.50.0/24` — segmento "DMZ" (LAN segment "DMZ" no VMware). Criado para os exercícios da UC01485; partilhado com o lab desde a 9.7 (Entrada #127) |
| WAN (`em2`) | `192.168.203.130` | saída para a internet via NAT do VMware |

## DHCP (ISC, no OPNsense)

Gama dinâmica `192.168.10.110`–`192.168.10.200` (estreitada em 2026-09-26, Entrada #106, para eliminar a sobreposição que existia com as reservas fixas), mais três reservas fixas por MAC.

## Máquinas

| Máquina | IP | Atribuição | Papel |
|---|---|---|---|
| Windows Server (`WIN-54OBK8B48L5`) | `192.168.10.1` | fixo, na VM | Controlador de Domínio `lab.local` |
| Kali Linux | `192.168.50.10` | fixo, na VM (`/etc/network/interfaces`) | Atacante — na DMZ desde a 9.7 (antes `192.168.10.10`, na `Ciber`) |
| Ubuntu Desktop (`ubuntu-wg`) | `192.168.10.20` | reserva DHCP | Servidor WireGuard (`wg0`, `10.10.10.1`) |
| Wazuh | `192.168.10.30` | fixo, na VM | SIEM/HIDS |
| Windows 11 (`DESKTOP-78KHHRF`) | `192.168.10.100` | reserva DHCP | Cliente de domínio, cliente WireGuard (`10.10.10.2`) |
| Servidor Vulnerável (`lab-seguranca`) | `192.168.10.101` | reserva DHCP | DVWA (Docker) + serviços mal configurados |

Todas as VMs têm uma única saída pelo OPNsense: `default via 192.168.10.254`, exceto a Kali (`default via 192.168.50.254`, OPT1).

**Fora do âmbito do lab:** o servidor `vuln-srv-01` (`192.168.50.51`), da UC01485, está na mesma rede DMZ que a Kali — os dois falam sem passar pelo OPNsense (limitação aceite; separação planeada para a Fase 10, Entrada #127). O Servidor Vulnerável teve, numa fase anterior, uma segunda placa de rede em NAT direto (referida na Entrada #72) que já não existe.

## Hardening aplicado à rede (estado atual)

- Egress filtering por VM (Fase 5): as quatro VMs com regras próprias no OPNsense (Servidor Vulnerável, DC, Windows 11 e Ubuntu Desktop) têm a saída para a internet bloqueada, com uma exceção: o DC e o Windows 11 têm saída para o Windows Update (TCP 443 e 80). Os restantes endereços da LAN — incluindo o Wazuh (`192.168.10.30`), que não tem regras próprias — ficam abrangidos pela regra "Default allow LAN to any" (IPv4 e IPv6), que permite saída para qualquer destino. Configuração observada na Entrada #135; conectividade efetiva não testada. *(Atualizado a 27/10/2026.)* A Kali, desde a 9.7, só tem internet por regra **temporária** na OPT1 (criada quando for preciso, com motivo e data, retirada a seguir).
- **Segmentação (9.7/9.8, Entrada #127):** Kali na DMZ (OPT1). Regra na OPT1 "9.7 - Kali (DMZ) -> Servidor Vulneravel (menor privilegio)": a Kali só alcança o Servidor Vulnerável (`192.168.10.101`); tudo o resto vindo da DMZ é bloqueado por omissão. O Interno (`Ciber`) continua plano.
- **Gestão do OPNsense:** a partir do Windows 11 (Interno), não da Kali.
- Controlador de Domínio protegido contra LLMNR/NBT-NS/mDNS poisoning nas três camadas (Entrada #106).
- DNS do Controlador de Domínio auto-referenciado corretamente (Entrada #106).
