# Fase 6 — Ataques ao Active Directory (Entradas #87–#98)

Aplicação do framework de 4 perguntas à Fase 6. Esta fase já tem "Nota GRC" a aparecer organicamente em várias entradas (não precisa da adenda retroativa da Opção B) — a análise aqui foca-se especificamente na perspetiva de rede.

## Ficha: enumeração de AD sem credenciais — vista de atacante externo (Entrada #89)

**1. Configuração de rede atual:** consultas LDAP anónimas, resolução DNS e pedidos SMB feitos a partir do Kali contra o Windows Server/DC, sem qualquer credencial válida.

**2. Porque permitiu o ataque:** parte da informação de um domínio Active Directory é, por desenho, alcançável sem autenticação (nome do domínio, existência do DC, versão) — não é uma falha de configuração de rede, é uma característica do protocolo. A rede plana do lab (Kali no mesmo segmento do DC, sem controlo de acesso à camada de rede) só remove qualquer atrito adicional a essa consulta.

**3. O que seria diferente noutra configuração:** com bind LDAP anónimo desativado, `RestrictAnonymous` reforçado e transferência de zona DNS bloqueada (medidas já confirmadas como bem configuradas neste lab, ver balanço da Entrada #98), a superfície exposta sem credenciais fica reduzida ao mínimo que o protocolo exige — mas nunca a zero.

**4. Que defesa de rede o impediria:** nenhuma, sozinha — o balanço da própria Fase 6 (Entrada #98) é explícito: a defesa real aqui é deteção (correlacionar a sequência de sondas no SIEM), não prevenção de rede, porque cada sonda isolada é indistinguível de tráfego legítimo.

## Ficha: LLMNR/NBT-NS/mDNS poisoning — o vetor mais puramente "de rede" da fase (Entradas #97-#98)

**1. Configuração de rede atual:** três mecanismos de fallback de resolução de nomes (LLMNR, NBT-NS, mDNS) ativos por omissão no Windows 11, todos multicast/broadcast confinados ao segmento local (`hop limit 1` — nunca atravessam o OPNsense mesmo sendo o gateway), sem qualquer autenticação na resposta.

**2. Porque permitiu o ataque:** um comportamento de origem do protocolo, não uma falha de configuração — quando o DNS não resolve um nome, o Windows "grita" para toda a rede local por um dos três canais, e aceita a primeira resposta sem verificar a identidade de quem respondeu. Qualquer máquina no mesmo segmento (aqui, o Kali) pode responder primeiro.

**3. O que seria diferente noutra configuração:** com os três fallbacks desligados desde o início (como ficou aplicado na Entrada #98), o Windows falha a resolução de forma limpa e silenciosa, em vez de expor um hash NTLMv2 utilizável offline ou por NTLM relay.

**4. Que defesa de rede o impediria:** exatamente a aplicada — desligar LLMNR (GPO), NBT-NS (por cliente, por limitação de ADMX neste Server) e mDNS (registo), reforçada em profundidade por SMB signing (contra NTLM relay) e passwords fortes. É o único ataque desta fase onde a defesa de rede/configuração é mais eficaz do que a deteção — o balanço da própria Entrada #98 classifica a deteção deste vetor como "fraca".

## Nota sobre Kerberoasting e AS-REP Roasting (Entradas #91-#92)

Estes dois ataques, apesar de viajarem pela rede (pedidos Kerberos, Eventos 4769/4768), não têm uma causa de rede — a quebra da password acontece sempre offline, fora de qualquer segmento observável. A defesa eficaz (gMSA, AES em vez de RC4, remover a flag de pré-autenticação desnecessária) é de gestão de identidade, não de rede; por isso não têm ficha própria aqui, ficam apenas referidos para não dar a falsa impressão de que foram esquecidos.

## Ligação à Fase 3 (Entrada #96)

A reposição do túnel WireGuard (VPN entre Ubuntu Desktop e Windows 11) nesta entrada é operacional, não uma nova descoberta de rede — a imagem de prova (Wireshark) reforça a mesma conclusão já registada na ficha da Fase 3 (tráfego cifrado, metadados ainda visíveis por causa do comportamento hub do segmento "Ciber").

## Pontos de vídeo candidatos

- **NTLM relay prático** — o hash NTLMv2 capturado na Entrada #97 foi só exibido, nunca reencaminhado; um vídeo sobre `ntlmrelayx` complementaria diretamente esta fase, testável no lab (relay do hash capturado para outra máquina Windows, em vez de só o mostrar).
- **SMB signing como defesa contra NTLM relay** — mencionado no balanço da Entrada #98 mas nunca verificado/configurado na prática; candidato natural a testar como complemento.
