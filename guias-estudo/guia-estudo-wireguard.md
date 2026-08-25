# Guia de Estudo — VPN WireGuard (Fase 3)

*Documento de consolidação da Fase 3 do laboratório — a primeira fase do lado defensivo/de rede, depois de duas fases só de exploração de vulnerabilidades web. Escrito para conseguir explicar isto a alguém sem ter o ecrã à frente. Inclui os obstáculos e enganos pelo caminho.*

---

## 1. O que é o WireGuard, em 30 segundos

Uma VPN — um túnel cifrado entre duas máquinas. Tudo o que passa dentro do túnel fica encriptado; quem intercetar os pacotes pelo caminho vê apenas ruído, mesmo sabendo exatamente o tipo de tráfego (ping, HTTP, etc.).

**Diferença face às VPNs comerciais (ex.: ProtonVPN):** o mecanismo criptográfico é o mesmo (a Proton, aliás, oferece o WireGuard como um dos protocolos disponíveis) — a diferença é o propósito. Uma VPN comercial liga-te a um servidor de terceiros para sair da tua rede de forma anónima/privada na internet pública. O que montámos aqui é uma ligação direta, ponto-a-ponto, entre duas máquinas que controlamos por completo, só para estudar o mecanismo — sem internet pública nem anonimato envolvidos.

**Autenticação por chaves, não passwords:** cada máquina tem um par de chaves (privada/pública), gerado com Curve25519. A chave privada nunca sai da máquina; a pública é dada ao outro lado. Isto é uma mudança de paradigma face aos módulos anteriores (DVWA), que giravam à volta de passwords e formulários — aqui a "credencial" é um par matemático.

---

## 2. Topologia usada no lab

- **Ubuntu Desktop** — servidor WireGuard, IP real `192.168.10.20` (fixo, reserva DHCP), IP virtual da VPN `10.10.10.1`
- **Windows 11** — cliente, IP real `192.168.10.100` (dinâmico), IP virtual da VPN `10.10.10.2`
- **Kali Linux** — fora do túnel, usado só para observar o tráfego de fora, `192.168.10.102`

A rede virtual da VPN (`10.10.10.0/24`) é completamente separada da rede física do lab (`192.168.10.0/24`) — cada máquina "dentro" do túnel tem uma segunda identidade, só válida ali.

---

## 3. Obstáculos de infraestrutura antes de começar (Entrada #55)

Antes do WireGuard em si, foi preciso desbloquear a rede:
- O gateway OPNsense estava configurado em `192.168.10.1`, não `192.168.10.254` como o roteiro sempre assumiu — corrigido diretamente na consola do OPNsense.
- Depois de corrigir o intervalo de DHCP dinâmico (`100`–`200`), o Ubuntu Desktop continuava a receber um IP antigo (`192.168.10.10`) por causa de uma **reserva estática escondida** no OPNsense (`Services → ISC DHCPv4 → [LAN]`, secção "Static Mappings", fora do sítio mais óbvio). Editada para `192.168.10.20`.

**Lição:** documentação (o roteiro) e realidade (a configuração viva) podem divergir silenciosamente — vale sempre a pena confirmar por observação direta.

---

## 4. Instalação e chaves do servidor (Entrada #52)

```
sudo apt install wireguard
sudo mkdir -p /etc/wireguard
wg genkey | sudo tee /etc/wireguard/privatekey
wg pubkey < /etc/wireguard/privatekey | sudo tee /etc/wireguard/publickey
```

**Falha de segurança apanhada no momento:** o ficheiro `privatekey` nasceu com permissões `644` (legível por qualquer utilizador do sistema) — corrigido para `600` antes de continuar. Mesmo padrão de falha já visto nos ficheiros de índice de módulos do kernel do VMware, na mesma sessão: confiar nas permissões por omissão de um ficheiro sensível é sempre um risco.

---

## 5. A app gráfica do Windows gera as chaves automaticamente

No Linux, gerar as chaves foi manual, em dois comandos separados (`wg genkey`, `wg pubkey`). Na app do WireGuard para Windows, ao escolher "Adicionar túnel vazio", o par de chaves é gerado e mostrado automaticamente — mesma operação criptográfica, só que a interface gráfica poupa os comandos manuais.

---

## 6. A falha de handshake e a lição sobre transcrição manual (Entradas #53–#54)

Depois de configurar os dois lados (servidor e cliente) com as chaves públicas corretas — confirmadas visualmente, carácter a carácter, três vezes — o handshake continuava a falhar, com o servidor a rejeitar sempre com `Invalid handshake initiation` (confirmado via `dmesg` com debug do módulo do kernel ativo).

Isolámos o problema por camadas antes de chegar aqui: rede física OK, firewall OK (porta `51820/udp` aberta), processo à escuta OK (`ss -ulnp`), pacote a chegar mesmo à placa de rede (confirmado por `tcpdump`), relógios sincronizados. Só o próprio conteúdo criptográfico do pacote estava a falhar — e três revisões manuais da chave, carácter a carácter, não encontraram o erro.

**A decisão certa foi mudar de método, não insistir nele:** gerámos um novo par de chaves diretamente no Ubuntu Desktop, construímos o ficheiro de configuração completo do cliente por variável de shell (sem nunca escrever a chave à mão), e transferimos esse ficheiro para o Windows através de um servidor web temporário (`python3 -m http.server`) na mesma rede. O Windows importou o ficheiro diretamente — sem qualquer transcrição manual — e o handshake funcionou à primeira.

**A causa exata do erro original nunca foi confirmada** — fica registado com honestidade como uma limitação da investigação, não como falha de compreensão do mecanismo (que está claro: quando um método de verificação manual repetido não encontra o erro que sabemos existir, a solução é eliminar essa fonte de erro, não repeti-la à espera de um resultado diferente).

---

## 7. Confirmação com o Kali: prova de cifra, não só de ligação (Entrada #56)

`ping` a funcionar prova só conectividade, não confidencialidade. A prova real: o Kali (de fora da conversa entre Ubuntu Desktop e Windows 11) capturou o tráfego UDP na porta `51820` e viu pacotes com tamanhos coerentes com um ping do Windows, mas **conteúdo em hexadecimal completamente ilegível** — nem o texto típico de um payload de ping (`abcdefghij...`) visível.

**Achado lateral:** o Kali conseguiu ver esse tráfego sem qualquer configuração de modo promíscuo — a rede virtual "Ciber" do VMware comporta-se como um hub (entrega a todos), não como um switch fechado. Isto é, por si só, uma lição de segmentação de rede: em produção, switches reais isolariam esse tráfego por omissão.

**Limitação que a VPN não resolve:** os metadados (quem fala com quem, quando, com que padrão de tamanho/timing) continuam visíveis mesmo com VPN — só o conteúdo fica protegido.

---

## 8. Como nos podemos defender / boas práticas confirmadas na prática

- Nunca confiar nas permissões por omissão de ficheiros sensíveis (chaves privadas) — confirmar sempre com `ls -la`.
- Transferir segredos criptográficos por canais automatizados em vez de transcrição manual — a mesma razão pela qual gestores de chaves SSH e cofres de segredos existem na indústria.
- Segmentação de rede real (switches, VLANs) continua a ser necessária mesmo com VPN — a cifra protege o conteúdo, não a visibilidade da comunicação em si.

---

## 9. Estado de compreensão (honesto)

**2026-08-22:**
- O que é uma VPN, o papel das chaves pública/privada, e a diferença face a uma VPN comercial: **Sim** — por palavras próprias, com a analogia da ProtonVPN que já uso.
- Diagnóstico em camadas (rede → firewall → processo → protocolo) para isolar uma falha: **Sim**, foi o raciocínio mais valioso desta fase.
- Causa exata da falha de handshake original: **Não confirmada** — contornada com sucesso, não diagnosticada ao detalhe. Registo honesto, não uma falha de compreensão do mecanismo em si.
- Diferença entre "a VPN liga" e "a VPN protege" (conteúdo cifrado vs metadados visíveis): **Sim**, confirmado na prática com a captura do Kali.

**Fase 3 do roteiro concluída** (Entradas #52–#56).
