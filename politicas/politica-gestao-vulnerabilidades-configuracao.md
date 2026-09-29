# Política de Gestão de Vulnerabilidades e Configuração Segura

**Empresa:** micro-empresa fictícia, 6-8 colaboradores, setor de retalho com vendas online (âmbito definido na Sessão 8.0, setor fixado em 2026-09-29 — ver Entrada #107, nota de 2026-09-29). Empresa e setor são fictícios, escolhidos para dar corpo a este exercício de aprendizagem — a metodologia desta política não está presa a este setor, e aplicar-se-ia, com ajustes de pormenor, a qualquer outra atividade.
**Data de aprovação:** 2026-09-28
**Dono da política:** Administração de sistemas
**Revisão:** anual, ou após qualquer incidente relacionado com uma vulnerabilidade ou configuração insegura, uma vulnerabilidade grave identificada, ou uma alteração significativa da infraestrutura.

**Histórico de revisões:** 2026-09-29 — acrescentadas 6 melhorias após revisão do Pedro: priorização por gravidade, periodicidade concreta do scanning, registo simples de vulnerabilidades/correções, reforço da revisão periódica de configuração, procedimento formal de exceção, e gatilhos adicionais de revisão da própria política.

## Princípio orientador

Tal como nas outras duas políticas desta fase, cada regra aqui é pensada para o que **uma só pessoa em administração de sistemas**, sem SOC nem necessidade atual de ferramentas comerciais dedicadas, consegue sustentar — e privilegia sempre que possível o que já está instalado, sem excluir a hipótese de uma ferramenta nova se um dia for mesmo necessária.

## 1. Objetivo

Reduzir o risco de um serviço mal configurado ou desatualizado ser usado como ponto de entrada — garantindo que os serviços expostos seguem uma configuração mínima segura, e que a decisão de aplicar (ou não aplicar) uma atualização de segurança é sempre explícita, nunca por omissão.

## 2. Âmbito

Aplica-se aos serviços com exposição de rede: FTP, Samba, MariaDB e Apache/DVWA no Servidor Vulnerável; sistema operativo e serviços de base nas restantes VMs (Controlador de Domínio, Windows 11, Ubuntu Desktop, OPNsense).

## 3. Regras

- **3.1 Configuração segura por omissão, revista periodicamente.** Nenhum serviço fica exposto com acesso anónimo de escrita ou execução de código habilitada por definição — qualquer exceção a esta regra é uma decisão explícita, documentada, nunca um esquecimento de configuração. *(Ligado ao risco #1 — FTP anónimo + PHP na pasta de upload, já corrigido.)* Serviços expostos, portas abertas, contas e permissões são revistos com a mesma periodicidade do scanning (regra 3.3) — uma configuração insegura pode criar uma vulnerabilidade mesmo com o software atualizado, e é uma verificação simples de acrescentar à mesma rotina trimestral.
- **3.2 Gestão de patches, com prazo definido.** Atualizações de segurança classificadas como **críticas pelo próprio fornecedor** (não uma escala própria a construir) são aplicadas dentro de 30 dias após disponibilizadas, sempre que tecnicamente viável e sem risco desproporcionado para a operação. Esta é a regra que se aplicaria numa organização real — o lab tem uma exceção formal a esta regra (ver secção 4), não uma substituição dela.
- **3.3 Deteção de vulnerabilidades, com periodicidade definida.** Sempre que tecnicamente adequado, usa-se uma ferramenta gratuita de scanning (ex. OpenVAS/Greenbone, já identificado como candidato na Sessão 8.1) para identificar vulnerabilidades conhecidas nos serviços expostos. Cadência: **trimestral**, e também depois de qualquer alteração importante na infraestrutura (nova VM, novo serviço exposto, mudança de rede) — suficiente para apanhar vulnerabilidades novas sem criar uma tarefa semanal impossível de manter para uma só pessoa. Não é obrigatório adquirir uma plataforma de gestão de vulnerabilidades dedicada.
- **3.4 Testar antes de aplicar.** Uma alteração de configuração ou uma atualização é testada antes de ser aplicada de forma definitiva — mesmo numa empresa pequena, sem ambiente de teste formal, isto pode ser tão simples como um snapshot da VM antes da alteração.
- **3.5 Inventário de configuração.** A configuração de cada serviço exposto está ligada ao inventário de ativos já existente (Sessão 8.1), para que uma alteração de configuração seja sempre rastreável a um ativo concreto.
- **3.6 Priorização por gravidade.** Vulnerabilidades classificadas como **críticas pelo scanner ou pelo fornecedor** (mesmo critério da regra 3.2, sem escala própria a inventar) são tratadas primeiro, seguidas das de gravidade elevada — as restantes ficam para trás desse trabalho, não porque não importem, mas porque uma só pessoa não consegue tratar tudo ao mesmo tempo. Mesma lógica de prioridade já usada na política de registo e monitorização (regra 3.2 dessa política), aplicada aqui às vulnerabilidades em vez de aos alertas.
- **3.7 Registo simples de vulnerabilidades e correções.** Cada vulnerabilidade encontrada (por scanning ou por qualquer outra via) fica registada com: sistema afetado, ação tomada, e data da correção. No contexto deste lab, o próprio `registo-laboratorio-ciberseguranca.md` já cumpre esta função — não se cria um ficheiro novo só para isto. Numa organização real sem esse registo técnico já em curso, uma tabela simples (folha de cálculo ou tíquete) seria suficiente; o formato importa menos do que o hábito de registar.
- **3.8 Procedimento de exceção.** Quando uma atualização ou correção não pode ser aplicada, isso é registado explicitamente: o motivo, o risco que fica por resolver, e — quando existir — uma medida alternativa de proteção. A secção 4 desta política (VMs sem patch) é o exemplo concreto deste procedimento em ação; qualquer exceção futura segue o mesmo formato, para que uma vulnerabilidade nunca fique simplesmente esquecida sem essa decisão ter sido tomada de forma consciente.

## 4. Exceção formal registada (risco aceite)

As VMs do laboratório mantêm-se, por decisão consciente, sem atualizações de patch aplicadas — em contradição direta com a regra 3.2. Esta exceção existe apenas no ambiente de laboratório, para não enviesar os resultados das tarefas de ataque/deteção do próprio projeto — **nunca seria aceitável numa organização real**, onde o prazo de 30 dias da regra 3.2 se aplicaria sem exceção. Risco aceite formalmente na Sessão 8.3 (`declaracao-aplicabilidade-parcial.md`, controlo A.8.8), com origem documentada em `hardening-baseline.md`, ponto 9.

## 5. Responsabilidades

- **Gerência:** autoriza o tempo/janela de indisponibilidade necessária para aplicar um patch crítico, quando esse patch implica interromper um serviço.
- **Administração de sistemas:** aplica os patches dentro do prazo definido (regra 3.2), corre o scanning de vulnerabilidades (regra 3.3), e testa alterações antes de as aplicar (regra 3.4).

## Ligação a riscos e evidência

Risco #1 do `registo-riscos.xlsx` (FTP+PHP → RCE, corrigido, Entrada #104) e risco #6 (VMs sem patch, risco aceite, `hardening-baseline.md` ponto 9).

**Domínios:** ISO/IEC 27001:2022 A.8.8 (gestão de vulnerabilidades técnicas), A.8.9 (gestão de configuração).
