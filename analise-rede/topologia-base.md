# Topologia base do laboratório

Confirmada ao vivo, máquina a máquina, em 2026-09-26 (Entrada #106 do registo). Esta é a rede que serve de ponto de partida a todas as fichas desta pasta — cada ficha de fase assinala explicitamente quando a rede era diferente nesse momento do projeto.

## Virtualização e segmento

- **Virtualização:** VMware Workstation.
- **LAN Segment do VMware, `Ciber`:** comporta-se como um hub (sem aprendizagem de MAC) — todas as VMs ligadas a este segmento veem o tráfego umas das outras. Este é o facto de rede mais transversal do projeto: qualquer regra de firewall aplicada só no gateway (OPNsense) não tem efeito nenhum sobre tráfego entre duas VMs do mesmo segmento, porque esse tráfego nunca chega a passar pelo router (ver Entradas #77, #99, #104).

## Router / Firewall (OPNsense)

Três interfaces:

| Interface | IP | Rede |
|---|---|---|
| LAN (`em1`) | `192.168.10.254` | `192.168.10.0/24` — a rede do lab |
| OPT1 (`em0`) | `192.168.50.254` | `192.168.50.0/24` — segmento "DMZ" |
| WAN (`em2`) | `192.168.203.130` | saída para a internet via NAT do VMware |

## DHCP (ISC, no OPNsense)

Gama dinâmica `192.168.10.110`–`192.168.10.200` (estreitada em 2026-09-26, Entrada #106, para eliminar a sobreposição que existia com as reservas fixas), mais três reservas fixas por MAC.

## Máquinas

| Máquina | IP | Atribuição | Papel |
|---|---|---|---|
| Windows Server (`WIN-54OBK8B48L5`) | `192.168.10.1` | fixo, na VM | Controlador de Domínio `lab.local` |
| Kali Linux | `192.168.10.10` | fixo, na VM | Atacante |
| Ubuntu Desktop (`ubuntu-wg`) | `192.168.10.20` | reserva DHCP | Servidor WireGuard (`wg0`, `10.10.10.1`) |
| Wazuh | `192.168.10.30` | fixo, na VM | SIEM/HIDS |
| Windows 11 (`DESKTOP-78KHHRF`) | `192.168.10.100` | reserva DHCP | Cliente de domínio, cliente WireGuard (`10.10.10.2`) |
| Servidor Vulnerável (`lab-seguranca`) | `192.168.10.101` | reserva DHCP | DVWA (Docker) + serviços mal configurados |

Todas as VMs têm uma única saída: `default via 192.168.10.254` (o OPNsense). O Servidor Vulnerável teve, numa fase anterior, uma segunda placa de rede em NAT direto (referida na Entrada #72) que já não existe.

## Hardening aplicado à rede (estado atual)

- Egress filtering por VM (Fase 5): cada máquina, exceto o Kali, só tem acesso à rede interna, sem saída para a internet.
- Controlador de Domínio protegido contra LLMNR/NBT-NS/mDNS poisoning nas três camadas (Entrada #106).
- DNS do Controlador de Domínio auto-referenciado corretamente (Entrada #106).
