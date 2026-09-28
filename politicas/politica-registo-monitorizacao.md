# Política de Registo e Monitorização

**Empresa:** micro-empresa fictícia, 6-8 colaboradores (âmbito definido na Sessão 8.0)
**Data de aprovação:** 2026-09-28
**Dono da política:** Administração de sistemas
**Revisão:** anual, ou após qualquer incidente relacionado com deteção

**Histórico de revisões:** 2026-09-28 — reescrita após revisão do Pedro, para refletir os recursos reais da empresa (uma só pessoa em administração de sistemas, sem SOC) em vez de assumir uma estrutura maior do que a que existe.

## Princípio orientador

Esta política assume, deliberadamente, que a empresa só tem **uma pessoa em administração de sistemas**, sem equipa de SOC, sem analista de segurança dedicado, e sem orçamento previsto para uma plataforma dedicada de monitorização. Cada regra abaixo foi pensada para o que essa pessoa consegue sustentar sozinha — e, antes de qualquer melhoria futura ser acrescentada a esta política, a pergunta a fazer é sempre: **o benefício justifica o esforço de manter isto, com os recursos que realmente existem?** Uma política que exige mais do que a empresa tem é uma política que não vai ser cumprida.

## 1. Objetivo

Garantir que atividade relevante nos sistemas da empresa fica registada, que os registos são revistos com um esforço realista, e que um alerta gerado corresponde de facto a uma deteção fiável — para que um incidente seja identificado o mais cedo possível, sem exigir recursos que a empresa não tem.

## 2. Âmbito

Aplica-se aos sistemas com capacidade de registo/deteção já implementada: agentes Wazuh (Controlador de Domínio, Servidor Vulnerável, Windows 11, Ubuntu Desktop) e Suricata (OPNsense). **Sempre que tecnicamente adequado, deve ser privilegiado o aproveitamento destas ferramentas antes da adoção de uma nova plataforma** — sem excluir a possibilidade de, no futuro, surgir uma necessidade que o Wazuh e o Suricata simplesmente não consigam resolver de forma adequada.

## 3. Regras

- **3.1 O que fica registado.** Eventos de autenticação (sucesso e falha), alterações a contas e permissões, e os eventos cobertos pelas regras próprias já criadas (Kerberoasting/AS-REP Roasting, RCE via web shell, enumeração de AD sem credenciais).

- **3.2 Revisão por prioridade, não revisão total diária.** Usa-se a escala de severidade já existente do Wazuh (níveis 0-15), sem inventar nenhuma taxonomia nova:
  - **Nível ≥12 (Alto):** investigado no próprio dia.
  - **Nível 7-11 (Médio):** revisto semanalmente, em lote.
  - **Abaixo de 7 (Baixo):** não revisto individualmente — fica disponível como contexto, só consultado se for preciso investigar algo relacionado.
  Esta distinção existe precisamente porque uma só pessoa, a acumular outras funções, não tem tempo para tratar todos os alertas da mesma forma.

  **Porquê o corte em 12, e não 10 ou outro valor:** duas razões, não uma escolha arbitrária. Primeiro, é onde a própria classificação oficial do Wazuh separa as categorias — a partir do nível 12 ("High importance event"), os níveis sobem para padrões de ataque já reconhecidos ou correlacionados (13-14) até ao 15 ("severe attack, sem margem para falsos positivos"); os níveis 10-11 ainda pertencem à categoria anterior (erros de utilizador repetidos, avisos de integridade). Segundo, é o nível que o próprio lab já usa: a regra `100013` (RCE via web shell, Entrada #102) foi construída a nível 12, descrita como "o mais alto do laboratório", enquanto o Kerberoasting e o AS-REP Roasting (`100011`/`100012`) ficam a nível 10 — e não por acaso, são exatamente os dois riscos já aceites conscientemente (risco #2). Cortar em 10 obrigaria a tratar alertas de um risco já decidido com a mesma urgência de uma RCE ativa, todos os dias — dilui a atenção da única pessoa disponível.

- **3.3 Verificação periódica dos sensores.** O estado dos agentes/sensores (Wazuh, Suricata) é confirmado ativamente — por linha de comandos, não só pela consola gráfica — pelo menos uma vez por mês, e sempre depois de uma VM ter estado desligada. *(Lição da Fase 7: a consola pode mostrar "a correr" com o processo já morto — confirmado por shell, ver `hardening-baseline.md`, ponto 4.)*

- **3.4 Um alerta não é o mesmo que cobertura real.** Antes de assumir que uma técnica está detetada só porque uma regra dispara, confirma-se que a regra deteta o mecanismo certo, não apenas um padrão coincidente. *(Ver `mapa-cobertura-mitre-attack.md` e o conceito de "alerta enganador", Entrada #90.)* Uma regra nova ou alterada é sempre validada pela checklist já existente no projeto (`validar-regra-wazuh`) — método simples e já testado, sem criar um processo de validação novo.

- **3.5 Disponibilidade dos serviços — solução proporcional.** Onde não existir ainda deteção de um serviço em baixo, a primeira opção é aproveitar o Wazuh já instalado (ex. um script simples de verificação, ingerido como log próprio), não comprar ou instalar uma plataforma de monitorização dedicada (Nagios, Zabbix, Uptime Kuma, etc.). Já é o candidato nº2 do trilho técnico paralelo já identificado no `roteiro-projeto-laboratorio-ciberseguranca.md`.

- **3.6 Retenção de logs.** Adota-se, como valor inicial, uma retenção de 90 dias para logs de segurança, prorrogável apenas enquanto durar uma investigação ativa concreta. O valor baseia-se em dois fatores: a capacidade real de investigação da empresa (uma só pessoa, que tipicamente deteta e investiga um incidente em dias, não meses — 90 dias dá uma margem confortável sem acumular indefinidamente) e a capacidade de armazenamento do Wazuh Indexer, que **ainda não foi verificada tecnicamente** — o disco disponível e a retenção atualmente configurada ficam por confirmar numa sessão técnica futura, antes deste valor poder ser tratado como definitivo. Não há, para já, nenhum requisito legal que obrigue a um período maior — a aplicabilidade da NIS2 a esta empresa ainda está por confirmar (Sessão 8.6); esta regra é revista nessa altura se a conclusão for diferente.

- **3.7 Proteção dos logs — proporcional.** Acesso aos logs restrito à administração de sistemas. Sem armazenamento imutável dedicado (seria desproporcionado para o tamanho da empresa); a cópia de segurança dos logs fica incluída na rotina geral de backup, sem infraestrutura própria.

- **3.8 Dados pessoais nos logs (RGPD).** Os logs internos nunca são publicados tal como estão. Quando um log ou captura de ecrã é usado para fins de documentação ou publicação externa, os dados pessoais são ocultados antes de publicar — prática já seguida desde a Entrada #97.

- **3.9 Automatização antes de mais pessoas.** Para eventos de nível Alto (regra 3.2), prioriza-se um alerta automático (ex. notificação imediata) em vez de depender só da revisão manual — é mais realista automatizar uma tarefa concreta do que assumir que a empresa vai contratar mais alguém.

## 4. Lacunas reconhecidas (risco aceite/pendente)

- **Risco #4** (`registo-riscos.xlsx`): o Servidor Vulnerável não tem qualquer alerta de disponibilidade — a indisponibilidade do DVWA (Entrada #108) só foi descoberta por verificação manual. A solução prevista (regra 3.5) usa o Wazuh já existente, não uma ferramenta nova.
- **Risco #7**: as regras de fábrica do Wazuh que disparam para a técnica de enumeração do BloodHound fazem-no por coincidência de mecanismo (NTLM Type 3), não por deteção genuína — mapa de cobertura já corrigido (Entrada #90), regra nova ainda por criar e validar pela checklist da regra 3.4.

## 5. Responsabilidades

- **Gerência:** aprova a criação de uma regra de deteção nova quando um risco novo é identificado (mesma lógica de autorização/execução da política de controlo de acesso).
- **Administração de sistemas:** mantém os agentes ativos, revê alertas por prioridade (regra 3.2), confirma sensores por shell, propõe regras novas quando encontra uma lacuna, e testa-as pela checklist do projeto antes de as considerar fiáveis.

**Sobre segregação de funções (não é possível com uma só pessoa):** numa empresa com uma única pessoa em administração de sistemas, não existe forma de separar por completo quem administra, quem monitoriza e quem investiga — não há gente suficiente para isso. O controlo compensatório aqui não é segregação, é **rastreabilidade das ações administrativas**: as próprias ações da administração de sistemas (ex. alterações no AD) continuam a ficar registadas nos logs, o que dá uma base para investigar e questionar o que foi feito mesmo sem uma segunda pessoa a validar cada ação — sem se confundir isto com não-repúdio, que é uma garantia mais forte (normalmente exige prova criptográfica) e que um log, por si só, não oferece, porque alguém com acesso suficiente poderia alterá-lo.

## Ligação a riscos e evidência

Riscos #4 e #7 do `registo-riscos.xlsx`. Regras de deteção já implementadas: Kerberoasting/AS-REP Roasting, RCE via web shell, enumeração de AD (Fase 7). Lição de verificação por shell: `hardening-baseline.md`, ponto 4. Prática de ocultar dados pessoais: Entrada #97.

**Domínios:** ISO/IEC 27001:2022 A.8.15 (registo), A.8.16 (atividades de monitorização), A.5.7 (inteligência de ameaças, indiretamente); RGPD (dados pessoais em logs).
