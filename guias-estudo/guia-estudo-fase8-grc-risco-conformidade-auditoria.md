# Guia de Estudo — Fase 8: GRC — Risco, Conformidade e Auditoria

## 1. O que foi esta fase, em 30 segundos

As Fases 1 a 7 perguntaram "o que consegue um atacante fazer?" e "a defesa funciona?". A Fase 8 fez uma pergunta de outro tipo: se o lab fosse uma pequena empresa, o que lhe perguntaria um gestor, um auditor ou uma autoridade? Oito sessões (8.0 a 8.7, Entradas #107 a #117), sem ataques novos: o que é real é a evidência técnica por trás de cada decisão. O fio condutor é o mesmo das fases anteriores, agora aplicado a papéis e decisões: **o que está escrito tem de ser verificado, e o que é aceite tem de estar escrito.**

## 2. Sessão 8.0 — Dar um dono ao lab

Sem um dono, "impacto" não quer dizer nada: perder um servidor sem dono não custa nada a ninguém. Definiu-se uma empresa fictícia (micro-empresa de 6-8 colaboradores, com uma aplicação de encomendas) e ligou-se cada VM a uma função de negócio. Analogia: avaliar o risco de um prédio sem saber quem lá mora. O tamanho da empresa não é um pormenor: decide, por exemplo, se a NIS2 se aplica, enquanto o RGPD se aplica a qualquer tamanho que trate dados pessoais.

## 3. Sessão 8.1 — Inventário e classificação (CID)

Ninguém protege o que não sabe que tem. Cada ativo foi classificado em confidencialidade, integridade e disponibilidade (CID). A verificação ao vivo mostrou logo um achado real: o DVWA estava parado e ninguém tinha reparado. Perspetiva da empresa: um inventário desatualizado é a primeira coisa que uma auditoria apanha, e a causa de muitas surpresas depois de um incidente.

## 4. Sessão 8.2 — O registo de riscos

Um risco é uma ameaça a explorar uma vulnerabilidade de um ativo. Mede-se com probabilidade vezes impacto numa matriz 3×3, como um semáforo (Baixo, Médio, Alto, Crítico). Cada risco tem dois níveis: o **inerente** (sem controlos) e o **residual** (depois dos controlos que já existem), como conduzir sem cinto e com cinto. Os 7 riscos de partida foram sempre ligados a uma entrada do registo que os prova. A escala é simples de propósito: o objetivo é perceber o raciocínio, não fingir precisão.

## 5. Sessão 8.3 — Tratamento do risco e Declaração de Aplicabilidade

Para cada risco há quatro respostas legítimas: **mitigar**, **aceitar**, **transferir** ou **evitar**. Dois riscos foram mitigados (FTP com RCE; LLMNR), dois ficaram por mitigar (disponibilidade e alerta enganador) e três foram aceites com justificação escrita. A Declaração de Aplicabilidade parcial liga cada risco aos controlos da ISO/IEC 27001 (11 controlos), com estado e evidência. Ideia-chave: aceitar um risco não é falhar, falhar é aceitar sem saber e sem escrever porquê.

## 6. Sessão 8.4 — As três políticas

Controlo de acesso e passwords, registo e monitorização, gestão de vulnerabilidades e configuração segura. Uma política dá corpo escrito aos controlos: diz o que a organização se compromete a fazer. Durante a escrita descobriu-se uma lacuna no próprio âmbito: o setor da empresa nunca tinha sido definido, e isso mexia com o que é proporcional (por exemplo, regras de pagamentos).

## 7. Sessão 8.5 — Auditoria interna ao vivo (o centro da fase)

"A política diz X. O lab cumpre X?" Cinco itens, quatro conformes e dois **não conformes**: a política dizia passwords de 16 caracteres e o domínio aceitava 7; a política dizia retenção de logs de 90 dias e nenhuma política de retenção existia. Duas das três coisas verificadas estavam só no papel. A correção da retenção **falhou à primeira** (muito provavelmente por a sessão do browser ter expirado, sem mensagem de erro); só uma segunda verificação independente o mostrou, e a prova final veio de um índice novo que apanhou a política sozinho. Pelo caminho: o disco das VMs quase cheio parou uma VM, e o gestor de passwords guardou lixo por causa do clipboard da VM. Analogia: o regulamento do condomínio diz que o extintor é revisto todos os anos, e a auditoria é abrir o livro de revisões e ver se está assinado. Regra de método: só se conclui "não conforme" depois de excluir a hipótese contrária e de dizer o que não foi verificado.

## 8. Sessão 8.6 — NIS2 e RGPD em incidentes reais

Dois incidentes que já tinham acontecido no lab foram usados para perguntar o que a lei exigiria. O relógio da notificação não começa no ataque, começa quando a organização **toma conhecimento** do incidente. Na NIS2, um aviso inicial em 24 horas, uma atualização em 72 horas e um relatório final; no RGPD, notificar a CNPD em 72 horas, a não ser que seja improvável que a violação resulte em risco, e documentar sempre a decisão. O email do Windows 11 capturado na #97 é só **um fator** a pesar, não prova de violação. O resultado prático foi um passo novo no playbook de resposta a incidentes (a "Fase 2b"). Duas leituras ficam por confirmar no texto oficial: os artigos 40.º a 44.º e a contagem dos 30 dias úteis.

## 9. Sessão 8.7 — Balanço e programa da Fase 9

A lista do que ficou por tratar foi separada em quatro tipos de coisa, porque não são equivalentes: riscos, lacunas de controlo, verificações técnicas e questões jurídicas. Duas decisões em aberto fecharam-se com factos. O 8.º risco (VMs sem cópia de segurança): o Timeshift só copia o sistema do Mint e as VMs não têm cópia; sem espaço nos discos, foi **aceite por escrito**, com motivo e com momento de revisão. O risco #5 (dados pessoais em trânsito) foi **reformulado**, porque a sua evidência (#97) provava outra coisa: um envenenamento de nomes, não tráfego sem encriptação. A lição que mais pesou: o lab e o computador real partilham destino, porque discos, espaço e cópias são os mesmos. Numa microempresa isto é comum, e a diferença que a auditoria vê é a aceitação estar decidida e escrita, e não desconhecida.

## 10. Como nos podemos defender (resumo transversal)

- Uma política escrita não é um controlo: só passa a ser quando se verifica que o sistema a cumpre, com um segundo caminho independente.
- Aceitar um risco é legítimo se estiver escrito, com motivo, dono e momento de revisão. Um risco aceite sem registo é uma lacuna.
- A evidência tem de corresponder à afirmação: quando não corresponde, corrige-se a formulação do risco.
- Cópias de segurança só valem fora do que falha junto com o original (o duplicado das chaves não se guarda na mesma gaveta).
- Antes de notificar uma autoridade é preciso saber quando se tomou conhecimento e quem decide; esse registo escreve-se no momento.
- Separar riscos, lacunas, verificações e questões jurídicas torna uma lista defensável.

## 11. Estado de compreensão (honesto)

*Rascunho, para o Pedro corrigir com as suas palavras.* O fio condutor percebido foi o da política contra o controlo (8.5) e, acima de tudo, a intersecção entre o sistema físico e o virtual (8.7). Há partes onde a participação foi menor e a compreensão ainda está a assentar: os fundamentos jurídicos da NIS2 e do RGPD (8.6), que dependem de confirmação no texto oficial, e a matriz de risco quando há impacto relativo e absoluto (empresas de tamanhos diferentes). A parte que mais merece estudo antes da Fase 9: refazer à mão a classificação de dois riscos do registo, sem ajuda, e explicar porque o nível mudou.

**Fase 8 do roteiro concluída** (Entradas #107 a #117, incluindo o incidente #114, que não é da fase mas aconteceu durante ela).
