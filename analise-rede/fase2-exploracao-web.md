# Fase 2 — Exploração web / DVWA (Entradas #10–#51)

## Nota honesta antes de começar

Esta é a maior fase do lab (42 entradas) e a que menos tem a ver com rede. Todos os módulos do DVWA — SQL Injection, Command Injection, XSS, CSRF, File Upload, File Inclusion, Brute Force — são vulnerabilidades de **aplicação**: a rede coloca o Kali e o Servidor Vulnerável na mesma sub-rede, sem qualquer barreira entre eles, mas isso é constante ao longo de toda a fase e nunca é o que determina se um ataque específico funciona ou falha — quem determina isso é sempre a validação (ou falta dela) dentro do próprio DVWA. Forçar uma "história de rede" em cada um destes módulos seria inventar uma lição que a fase não tem. Esta ficha diz isto com clareza, em vez de a contornar.

## O que a rede contribui, de facto, nesta fase

**1. Configuração de rede atual:** Kali e Servidor Vulnerável na mesma sub-rede `192.168.10.0/24`, sem firewall nem segmentação entre eles (o egress filtering só chega na Fase 5). Acesso HTTP direto e sem restrições à porta 80.

**2. Porque permitiu os ataques:** não permitiu — a ausência de barreiras de rede é uma pré-condição neutra (o Kali "vê" o DVWA), mas o sucesso de cada ataque depende inteiramente da aplicação, não da rede. É o mesmo princípio já registado na Entrada #77 (Fase 5), só que aplicado ao contrário: aqui não há tráfego "lateral" a esconder-se de ninguém, porque não há nenhum controlo de rede a tentar impedir nada nesta fase.

**3. O que seria diferente noutra configuração:** com o egress filtering já em vigor (como a partir da Fase 5) ou com uma regra a restringir o acesso HTTP só à origem esperada, os módulos de exploração continuariam a funcionar exatamente da mesma forma — porque o ataque nunca dependeu de acesso irrestrito à rede, dependeu de o DVWA aceitar input malicioso.

**4. Que defesa de rede o impediria:** nenhuma, diretamente — a defesa certa para esta fase inteira é ao nível da aplicação (prepared statements, whitelisting, output encoding, tokens anti-CSRF), não da rede. A única exceção parcial é o Brute Force: rate limiting ou bloqueio de IP ao nível do firewall/WAF seria uma camada de defesa adicional válida, mas o lab mostra (Entrada #51) que a defesa que realmente resolve o problema é o bloqueio de conta, uma medida de identidade, não de rede.

## Ligação para a frente

Duas coisas desta fase só ganham a sua importância de rede muito mais tarde:

- O **encadeamento File Upload + File Inclusion** (Entradas #45-46) — RCE completo por combinar duas falhas de aplicação médias — é estruturalmente o mesmo padrão que a Fase 4 repete com FTP anónimo + Apache, desta vez fora do DVWA. A lição sobre "falhas pequenas empilhadas" nasce aqui, mas só a Fase 4 lhe dá uma componente de rede real (a pasta de upload servida pelo mesmo Apache).
- O **Brute Force** (Entradas #47-51) só recebe a sua defesa real (bloqueio de conta ao nível do domínio) na Fase 5 — ver a "Nota GRC" acrescentada à Entrada #51 do registo.

## Pontos de vídeo candidatos

Nenhum ligado especificamente à rede desta fase — os módulos DVWA já têm o seu próprio guia de estudo comparativo (`guias-estudo/guia-estudo-comparativo-vulnerabilidades-web.md`), que cobre a progressão Low→Impossible de cada um com profundidade suficiente. Um complemento eventual, se fizer sentido mais tarde, seria sobre WAFs (Web Application Firewalls) como camada de defesa de rede complementar a estas vulnerabilidades de aplicação — não identificado como prioritário agora.
