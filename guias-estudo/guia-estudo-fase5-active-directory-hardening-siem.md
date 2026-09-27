# Guia de Estudo — Fase 5: Active Directory, Hardening de Rede e SIEM

## 1. O que foi esta fase, em 30 segundos

A fase mais longa e mais "cheia" do projeto até então: três blocos técnicos distintos, todos na mesma rede do lab — criar um domínio Active Directory do zero, reforçar o firewall/IDS do OPNsense, e instalar manualmente um SIEM (Wazuh) para finalmente ver os ataques das fases anteriores a partir do lado da defesa.

## 2. Active Directory: do zero ao domínio funcional

Recuperação de uma VM com rede errada (IP de casa em vez do lab), promoção do Windows Server a Controlador de Domínio (`lab.local`), DNS a apontar para si mesmo como comportamento correto e esperado (não um resíduo mal corrigido), criação de OUs próprias (`Lab` → `Utilizadores`/`Computadores`/`Servidores`) em vez de usar os contentores por defeito do Windows, e criação de um utilizador de teste. Repetiu-se três vezes ao longo da fase o mesmo padrão: colar um bloco de comandos PowerShell duas vezes, interpretando o sucesso silencioso da primeira execução como falha — lição de processo, não de conceito: quando um comando não devolve nada, isso normalmente significa sucesso, mas em caso de dúvida confirma-se sempre com um comando de leitura (`Get-*`).

## 3. GPO: a lição do âmbito (Utilizadores vs. Computadores)

O erro conceptual central da fase: uma GPO com uma definição de `Computer Configuration` (o aviso legal de login) foi inicialmente ligada à OU `Utilizadores` — e nunca teria produzido efeito nenhum, porque essa OU só contém contas de utilizador, não objetos computador. Âmbito de ligação (a OU onde a GPO está ligada) e secção da política (`Computer Configuration` vs. `User Configuration`) têm de estar alinhados. Corrigido (ligação movida para a OU `Computadores`), testado ao juntar o Windows 11 ao domínio, e confirmado visualmente: a caixa do aviso legal a aparecer mesmo no ecrã de login, antes de qualquer autenticação.

## 4. Account lockout: a defesa que fecha o círculo com a Fase 2

Política de bloqueio de conta configurada ao nível do domínio (5 tentativas falhadas → conta bloqueada 30 minutos) — ligação direta e explícita ao ataque de força bruta contra os logins do DVWA na Fase 2. Testada de propósito com passwords erradas repetidas a partir do Windows 11, com uma distinção importante: o aviso "a atrasar a próxima tentativa" no ecrã é só uma proteção cosmética do próprio Windows cliente; a confirmação real e definitiva do bloqueio foi sempre procurada na fonte de verdade — o Active Directory (`LockedOut: True`).

## 5. Hardening do OPNsense: egress filtering e as armadilhas da GUI

Regras de firewall "permitir rede interna + bloquear tudo o resto" aplicadas primeiro ao Servidor Vulnerável, depois alargadas ao Windows Server, Windows 11 e Ubuntu Desktop (o Kali ficou de fora, de propósito, por precisar de internet para atualizar ferramentas). Duas armadilhas reais e recorrentes: a ordem das regras (o OPNsense avalia de cima para baixo, primeira correspondência vence — uma regra de bloqueio colocada depois da regra "Default allow" nunca chega a ser avaliada), e um campo do formulário que parecia um simples campo de texto mas era na realidade uma caixa de etiquetas com o valor "any" pré-preenchido e escondido — a regra "correta" no ecrã de edição não correspondia ao que ficava realmente gravado, só visível confirmando na lista de regras.

## 6. Suricata: diagnosticar falhas silenciosas por linha de comandos

Um botão de "Download & Update Rules" que falhava sem qualquer mensagem de erro, ao longo de várias tentativas e hipóteses investigadas (falta de internet no OPNsense, DNS, um segundo adaptador de rede em falta). A causa real só ficou clara ao testar diretamente por linha de comandos (`fetch` na consola do OPNsense) — confirmando que a rede e o DNS funcionavam bem, e isolando o problema ao mecanismo da GUI. A causa final acabou por ser um passo de "Enable selected" em falta (selecionar os rulesets não é o mesmo que ativá-los), não nenhuma das hipóteses de rede inicialmente investigadas. Depois de ativado (1160 regras carregadas), um teste com `nmap` trouxe uma descoberta de rede importante: um IDS ligado só à interface do gateway não vê tráfego lateral entre duas máquinas na mesma sub-rede, porque esse tráfego nunca chega a passar pelo router.

## 7. Conflitos de IP: um padrão que se repetiu ao longo da fase

Pelo menos quatro casos de configuração de rede desalinhada da topologia documentada: o Kali com um IP antigo de casa ainda ativo lado a lado com o IP DHCP do lab; o Windows Server a ocupar, sem se dar por isso, o próprio IP fixo reservado ao Kali; e o DNS do cliente Windows 11 preso ao IP antigo do Controlador de Domínio depois de este ter mudado de endereço. Lição central, repetida em várias entradas: nunca assumir que a topologia escrita corresponde ao estado real de uma VM sem verificar diretamente — configurações manuais de fases anteriores podem divergir silenciosamente do que está documentado.

## 8. Wazuh: instalar não é o mesmo que ter cobertura

Stack completo instalado manualmente, sem Docker (Indexer, Manager, Filebeat, Dashboard), numa VM dedicada e isolada do alvo monitorizado — incluindo o episódio de reaproveitar uma VM "já usada" no registo do agente do Ubuntu Desktop, com três problemas sobrepostos e independentes (endereço de manager antigo residual, chave de enrollment de outro manager, e um bug conhecido do pacote `wazuh-agent` que deixa o campo do IP por substituir). O momento mais importante da fase: repetir o ataque FTP anónimo → web shell → RCE já usado nas Fases 2/4, desta vez com o Wazuh a vigiar — e descobrir que, por defeito, ele via a autenticação FTP mas não via nem o ficheiro malicioso escrito nem o comando executado. Só depois de afinar o FIM (adicionar a pasta de upload à vigilância em tempo real) é que a escrita do ficheiro passou a gerar alerta; a execução do comando em si ficou identificada como falha de cobertura a resolver numa fase futura (com `auditd`).

## 9. Estado de compreensão (honesto)

Consigo explicar cada bloco desta fase por palavras próprias, incluindo os momentos em que as coisas não correram como planeado à primeira: o âmbito errado da primeira GPO, as regras de firewall com "any" escondido, o botão do Suricata a falhar em silêncio, os conflitos de IP encontrados um a um, e sobretudo o resultado do teste final do Wazuh — que não foi "o SIEM funciona", mas sim "o SIEM, tal como veio instalado, tem pontos cegos reais, e só um teste contra um ataque conhecido os revela". Esta última lição é provavelmente a mais importante da fase: instalar uma ferramenta de deteção não é o mesmo que ter cobertura de deteção.

**Fase 5 do roteiro concluída** (Entradas #66–#86).
