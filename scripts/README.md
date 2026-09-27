# Scripts — índice

Scripts do laboratório reunidos aqui à medida que a revisão fase a fase (analise-rede/) avança. Critério: privilegiar scripts de verificação/defesa; um script só entra aqui se acrescentar compreensão (não é um arquivo de tudo o que já foi escrito no registo).

Cada script, quando entrar, tem: o que faz (linguagem simples), entradas do registo relacionadas, como correr, e a nota "só para uso no lab".

## Candidatos identificados até agora

- Fase 1: nenhum candidato óbvio (fase de montagem de ambiente).
- Fase 2: nenhum candidato óbvio — fase essencialmente aplicacional (DVWA), sem componente de rede/infraestrutura a verificar por script.
- Fase 3: script de verificação de handshake WireGuard (`wg show` + confirmação de tráfego cifrado via captura), relacionado com a Entrada #56 (visibilidade de metadados apesar da cifra) — útil como ponto de partida se o vídeo-ponto sobre debugging de handshake (Fase 3) avançar.
- Fase 4: script de verificação de serviços mal configurados (FTP anónimo, partilha Samba `guest ok`, `bind-address` de base de dados exposto) — um "checklist automatizado" que confirma, a partir do Kali, se cada um dos três problemas das Entradas #59/#64/#65 ainda está presente; útil tanto como ferramenta de verificação como para reutilizar no início da Fase 5, para confirmar que o hardening aplicado realmente fechou os três pontos.
- Fase 5: script de verificação de egress filtering (a partir de cada VM, tentar ligações de saída a destinos de teste na internet e confirmar que são bloqueadas) — relacionado com as Entradas #72/#80; útil para reverificar depois de qualquer alteração de rede.
- Fase 6: script de deteção de poisoning ativo (correr `tcpdump`/análise de tráfego a captar respostas LLMNR/NBT-NS/mDNS não solicitadas na rede) — relacionado com a Entrada #98; serviria tanto como ferramenta de verificação contínua do hardening aplicado como como base para o vídeo-ponto sobre NTLM relay já identificado na Fase 6.
- Fase 7: script de verificação de saúde dos sensores (confirmar, via shell — não só GUI/dashboard —, que os processos Wazuh/Suricata estão mesmo vivos e vinculados à interface correta) — relacionado diretamente com a lição central da Entrada #99 (a GUI mostrava "a correr" quando o motor estava morto); é o candidato mais forte de toda a revisão, por resolver diretamente um problema real já vivido no lab.

## Scripts

(nenhum ainda — por preencher à medida que a revisão avança)
