# Guia de Estudo — Fase 9: Técnica — Fechar o que a Fase 8 priorizou

## 1. O que foi esta fase, em 30 segundos

A Fase 8 terminou com uma lista priorizada do que ficou por tratar. A Fase 9 foi buscar essa lista e transformou-a num programa técnico. Foram onze sessões (9.0 a 9.10, com a 9.7 e a 9.8 registadas numa só entrada) e três pontos de vídeo, nas Entradas #118 a #130, com uma regra fixa: cada sessão tinha de acabar numa **prova ao vivo**, ou então na **lacuna escrita**, mas nunca numa prova forçada. A fase fechou com o balanço, onde a matriz de risco ganhou os primeiros critérios escritos, e esses critérios mudaram uma decisão já tomada.

## 2. Sessão 9.0 — Arrumar a casa

Antes de corrigir, confirmar o que existe. O inventário das VMs foi confirmado ao vivo: três VMs com nomes parecidos de "Ubuntu" foram identificadas, e duas foram marcadas como fora do lab. Também se limpou uma diretiva duplicada no FTP. Quando uma diretiva está repetida, vale a última, e a duplicação era uma fonte de conclusões erradas numa auditoria. Ficou uma regra: separar o que é cibersegurança do que é só saúde da máquina, como o disco do Mint.

## 3. Sessão 9.1 e ponto de vídeo 1 — Contas de serviço geridas (gMSA)

Demonstrou-se a mitigação do risco de Kerberoasting através de contas de serviço geridas (gMSA), **ao lado** da conta deliberadamente fraca, e não em vez dela. Repetiu-se o mesmo ataque contra as três contas:

- a `svc_sql` apareceu na lista e entregou um bilhete RC4, que se quebrou em menos de um segundo;
- as duas gMSA não apareceram na enumeração automática testada;
- pedido à mão, o bilhete de cada gMSA veio em AES-256, com uma password longa e aleatória gerida pelo domínio.

No ponto de vídeo 1, o método completo da Microsoft acrescentou um grupo próprio, só com a máquina que precisa da conta, o que é menor privilégio. Acrescentou também o teste e a instalação. O teste deu "False" à primeira, porque o bilhete Kerberos da máquina era anterior à entrada no grupo. Apagar os bilhetes resolveu, e é a mesma razão por que, numa empresa, se pede para "sair e voltar a entrar" depois de uma mudança de permissões.

**Analogia:** a gMSA não esconde o cofre: troca um segredo que se adivinha por um longo demais para adivinhar. (A quebra do bilhete AES-256 nunca foi tentada: a força vem da password gerida pelo domínio, não de um teste de quebra.)

## 4. Sessão 9.2 — Detetar a enumeração do Active Directory

O alerta que existia tinha o nome errado (risco #7). Escreveu-se uma regra dedicada: mais de 200 leituras ao diretório em 30 segundos, pela mesma conta, geram um alerta de nível 10 com o nome certo. Foi validada com um **teste contrário**: no teste de administração normal realizado, a regra não disparou.

A regra não disparava à primeira. A causa estava numa regra de fábrica que a "abafava" antes de chegar à nova, e pendurar a regra no sítio certo da árvore resolveu.

**Ponto cego escrito:** uma enumeração **lenta** passa por baixo do limiar. No balanço, isso pesou na classificação do risco.

**Incidente pelo caminho:** o disco do anfitrião chegou a 100% e o VMware pausou as VMs. Foi a primeira ocorrência do que viria a ser o risco #9.

## 5. Sessão 9.3 e ponto de vídeo 2 — Ver o que acontece dentro do Linux

O `auditd` passou a registar, no Servidor Vulnerável, a execução dos comandos abrangidos pelas regras configuradas (os do servidor web, os de utilizadores com sessão e as alterações a contas), com a identidade, o programa, os argumentos e o momento. Ficam de fora os comandos internos da shell e o resultado do que foi executado. O Wazuh gera um alerta de nível alto só para os comandos do servidor web, que é onde aparece um ataque como o Command Injection. Um ataque real de Command Injection ao DVWA apareceu no Dashboard. A deteção vê a **execução** do comando, não o pedido web que a provocou.

No ponto de vídeo 2, a leitura do `/etc/shadow` por um programa que não é um autenticador passou a gerar alerta. O ruído foi **medido** (o `cron` e o próprio agente do Wazuh também leem o ficheiro) e excluído com critério, antes de se declarar a regra boa.

**Lição:** uma regra que dispara com tudo é tão inútil como uma que não dispara com nada.

## 6. Sessão 9.4 — A luz acesa não é a pessoa a trabalhar

O DVWA tinha estado parado sem ninguém saber (#108). Agora há dois controlos:

- **corretivo (recuperação automática):** o serviço é reiniciado sozinho à 2.ª falha seguida;
- **detetivo:** uma verificação a cada minuto, e um alerta no Wazuh quando falha.

Nenhum dos dois impede a falha; reduzem a duração e garantem que é vista. Por isso o risco #4 baixou pelo **impacto**, não pela probabilidade.

A mesma falha da #108 foi reproduzida e desta vez detetou-se, registou-se, recuperou-se e alertou-se.

**Limites:** a verificação corre **dentro** da própria VM, por isso, se a VM inteira cair, ninguém dá por isso. E o caminho de falha do Docker não foi testado.

## 7. Sessão 9.5 — Passwords antigas do domínio

Uma política nova só vale para as passwords definidas depois dela. O AD regista a data da última definição de cada password, mas essa data, só por si, não revela o tamanho. Cruzando-a com a data da política, sabe-se quem **pode** ter uma password curta.

As decisões foram tomadas por grupo:

- a conta humana de administração foi renovada e deixou de ter "nunca expira";
- as contas de serviço não se alteraram nesta sessão: forçar a mudança poderia interromper os serviços associados, e duas delas são mantidas fracas de propósito (risco #2). O caminho para elas é a gMSA.

**Perspetiva da empresa:** corrigir a política sem corrigir as passwords antigas deixa uma dívida silenciosa.

## 8. Sessão 9.6 — O primeiro scanner de vulnerabilidades

Passou-se do "afirmamos" ao "medimos". O scan do Servidor Vulnerável mostrou 7 portas abertas e confirmou a versão antiga do Apache. A parte mais valiosa foi aprender a separar o **sinal** (software desatualizado, superfície exposta a mais) do **ruído** (CVEs "presumidos" pela versão, nunca testados). Um scanner não autenticado observa os serviços expostos e infere vulnerabilidades a partir dos sinais disponíveis (a versão do Apache, por exemplo, foi lida no que o serviço anuncia de si); não confirma necessariamente a configuração interna nem a explorabilidade.

## 9. Sessões 9.7 e 9.8 — Segmentação e contenção no gateway

Na Fase 7, a regra de bloqueio no OPNsense não fez nada, porque o atacante e o alvo estavam na mesma rede e o tráfego nunca passava pelo router. A Kali passou para uma rede virtual separada da rede interna (DMZ), atrás do OPNsense, mas partilhada com uma unidade curricular, com **menor privilégio**: só chega ao Servidor Vulnerável. A gestão do router passou para o Windows 11.

Ao repetir a contenção, a regra passou a funcionar, mas uma ligação **já aberta** continuou a passar: 297 pings em 297. O OPNsense lembra-se das conversas em curso (tabela de estados). Por isso, **conter é bloquear e cortar** as sessões abertas.

**Analogia:** fechar a porta da rua não põe na rua quem já entrou.

Os documentos de uma UC mostraram depois que a DMZ tinha sido criada para essa UC e é partilhada com ela. A separação ficou decidida, **mas não está feita** (Fase 10).

## 10. Ponto de vídeo 3 — VLANs comparadas com o lab

O lab não usa VLANs: usa redes virtuais separadas do VMware, com uma interface do OPNsense por rede. O objetivo de segmentação é semelhante, mas o mecanismo e as garantias de isolamento dependem da configuração utilizada. No lab, a configuração atual foi testada: mudar o IP não tirou a Kali da DMZ.

A experiência do "crachá falso" provou que **mudar o IP não muda a sala**. Com um IP da rede interna, a Kali continuou na DMZ, ninguém respondeu, e o caminho pelo router, que funcionava, ficou estragado.

Depois testou-se uma "rede de visitantes" temporária: internet sim, rede interna não.

- A internet por IP funcionou, mas os **nomes** falharam, porque o DNS é o próprio router, que conta como "interno". A causa ficou confirmada: o pedido da Kali ao router na porta 53 aparecia bloqueado no Live View, e os nomes passaram a resolver assim que se acrescentou uma segunda regra, mínima, só para o DNS.
- Ficaram separadas três provas: a regra deixou passar (Live View), o serviço respondeu (`nslookup`) e o destino é alcançável (`ping`).
- No fim, tudo foi revertido e **provado** igual ao início.

## 11. Sessão 9.9 — Verificações pendentes

- **O envio anónimo por FTP foi reconfirmado como recusado (ao vivo, 2026-10-19).** Deu o mesmo `550` de dentro e de fora do servidor, o que mostra que a barreira está no serviço, não na rede. O disco confirmou que nada chegou.
- **O Suricata viu a Kali na DMZ (ao vivo, 2026-10-19).** O tráfego permitido sai pela placa onde ele escuta. Um sensor só vê o que passa por onde ele está.
- **A ligação Suricata → Wazuh afinal nunca existiu.** Não havia agente no OPNsense nem receção de syslog configurada no Wazuh (só a porta dos agentes), e o alerta do Suricata gerado no teste não apareceu nos registos do Wazuh desse dia. O pressuposto da #117 foi corrigido, e a integração passou para a Fase 10.

**A pesquisa que se encontrou a si própria:** o comando `sudo grep` ficou registado no Wazuh com o número procurado lá dentro, e a contagem seguinte "encontrou" esse rasto. Uma contagem não é uma prova, a linha é. **Quem investiga também deixa marcas.**

## 12. Sessão 9.10 — Balanço

O inventário da fase encontrou pendências esquecidas, como a política de snapshots, pedida em seis entradas (#120 a #125) e nunca definida, e um backup cujo apagamento não estava registado. O registo de riscos foi atualizado:

- um risco baixou: o #4, o DVWA parado;
- um foi mantido Médio: o #7, por causa da enumeração lenta;
- o risco #2 (a `svc_sql`, exposta a Kerberoasting por ter um SPN e uma password fraca; e a `svc_legacy`, exposta a AS-REP Roasting por não exigir pré-autenticação Kerberos e ter uma password fraca) ficou **Crítico, como exceção didática explícita**, com dono, datas e condição de revisão. Não se reduz um risco para recompensar trabalho; reduz-se quando a condição que o origina muda;
- entraram dois riscos novos: a capacidade de disco (Alto, porque já aconteceu) e os alertas de rede que não chegam ao SIEM (Médio, provisório).

**A descoberta metodológica:** a matriz tinha números mas não tinha **critérios escritos**. Ao escrevê-los e aplicá-los, um risco que íamos baixar ficou onde estava. Uma primeira versão de um critério foi rejeitada por subir artificialmente quase tudo, e foi revista. **Quando um critério dá resultados absurdos, revê-se o critério e não se forçam os riscos a caber nele.**

## 13. Como nos podemos defender (resumo transversal)

- **Uma correção demonstrada noutra conta não corrige a conta original.** O risco segue o ativo.
- **Toda a deteção tem um ponto cego,** e deve ficar escrito ao lado do alerta.
- **Conter é bloquear e cortar** as ligações já abertas.
- **Segmentar só controla o que é obrigado a passar pelo ponto de controlo,** e um sensor só vê o que passa por onde ele está.
- **Ter duas ferramentas não quer dizer que estejam ligadas.** É preciso provar a integração, e não só cada ferramenta.
- **Uma alteração temporária só está fechada quando se prova que o sistema voltou ao estado inicial.**
- **Um controlo provado uma vez não fica provado para sempre:** reverificar.
- **A classificação de um risco acompanha a evidência e critérios escritos,** e a incerteza documenta-se, não se esconde.

## 14. Estado de compreensão (honesto)

*Revisto e aprovado pelo Pedro a 2026-10-20.*

**Onde o raciocínio foi mais próprio:** a parte de GRC do balanço. A distinção entre gravidade, estado do risco e decisão de aceitar, a exigência de critérios escritos antes de classificar, e as correções à redação para não transformar uma prova limitada numa garantia.

**Onde a compreensão ainda está a assentar:** as redes. Isto foi dito pelo próprio Pedro no ponto de vídeo 3, e a previsão de que o Suricata não veria a Kali na DMZ mostrou-o. O raciocínio estava certo para outro caso (o tráfego que não passa pela placa onde o sensor está), e a aprendizagem veio de comparar a previsão com o resultado. As VLANs ficam para praticar no Packet Tracer.

**Momentos em que o cansaço pesou:** a gestão do router tentada a partir da Kali, um comando corrido na máquina errada, e um formulário guardado duas vezes. Foram todos apanhados antes de terem efeito, graças à verificação por screenshot entre "guardar" e "ativar".

**Fase 9 do roteiro concluída** (Entradas #118 a #130).
