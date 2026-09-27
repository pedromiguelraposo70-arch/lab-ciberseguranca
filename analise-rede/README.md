# Análise de Rede — como a configuração de rede se cruza com cada fase

Esta pasta revê o laboratório inteiro (Fases 1 a 7) por um único ângulo: **a rede**. Não repete as entradas do registo — remete para elas — e não reescreve nada do que já foi documentado.

## Critério usado em cada ficha

Para cada ataque, ou grupo de entradas relacionadas, quatro perguntas:

1. **Configuração de rede atual** — como é que a rede estava desenhada nesse momento (segmento, IPs, firewall, DHCP).
2. **Porque permitiu o ataque** — que decisão de rede, especificamente, tornou o ataque possível.
3. **O que seria diferente noutra configuração** — se a rede estivesse desenhada de outra forma, o ataque seria impossível, mais difícil, ou apenas diferente?
4. **Que defesa de rede o impediria** — segmentação, firewall, VLAN, monitorização — qual seria a medida concreta.

**Honestidade:** quando um ataque é de aplicação (ex. as vulnerabilidades do DVWA na Fase 2) e a rede não teve um papel relevante nele, a ficha diz isso claramente, em vez de forçar uma ligação artificial.

## Pontos de vídeo

Onde fizer sentido, cada ficha lista também **pontos de vídeo candidatos** — lacunas ou temas dessa fase que podem ser aprofundados mais tarde com um vídeo externo e um teste nas VMs, como complemento fora da sequência principal do projeto. Não são compromissos, são candidatos.

## Índice

- [`topologia-base.md`](topologia-base.md) — a rede do lab tal como está confirmada ao vivo, ponto de partida para todas as fichas.
- [`fase1-construcao-lab.md`](fase1-construcao-lab.md) — Fase 1 (construção do lab e primeiro reconhecimento)
- [`fase2-exploracao-web.md`](fase2-exploracao-web.md) — Fase 2 (DVWA / exploração web)
- [`fase3-vpn-wireguard.md`](fase3-vpn-wireguard.md) — Fase 3 (VPN WireGuard)
- [`fase4-exploracao-servicos.md`](fase4-exploracao-servicos.md) — Fase 4 (serviços de rede mal configurados)
- [`fase5-active-directory-hardening.md`](fase5-active-directory-hardening.md) — Fase 5 (Active Directory e hardening)
- [`fase6-ataques-active-directory.md`](fase6-ataques-active-directory.md) — Fase 6 (ataques ao AD)
- [`fase7-blue-team.md`](fase7-blue-team.md) — Fase 7 (deteção e resposta)

**Estado (2026-09-27):** todas as 7 fases escritas. Fase completa: revisão fase a fase do Bloco B.
