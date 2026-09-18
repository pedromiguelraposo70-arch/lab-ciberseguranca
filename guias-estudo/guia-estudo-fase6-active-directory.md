# Guia de Estudo — Fase 6: Ataques ao Active Directory, com o Wazuh a vigiar

## 1. O que foi esta fase, em 30 segundos

Nas fases anteriores atacámos serviços isolados (web, FTP, Samba, base de dados). Na Fase 6 o alvo passou a ser o **Active Directory** — o sistema central que, numa rede Windows real, guarda todas as identidades e decide quem pode aceder a quê. Fizemos cinco ataques distintos contra o mesmo domínio (`lab.local`), sempre a partir do Kali, e em paralelo tentámos que o Wazuh os detetasse — o que revelou que "recolher o evento" e "detetar o ataque" são coisas muito diferentes. A fase fechou com uma sessão de balanço e hardening: para cada ataque feito, que defesa o teria travado, e a implementação de uma delas nas VMs.

## 2. A analogia para o Active Directory

Pensa no Active Directory como a receção e o livro de registo de um edifício de escritórios. A receção (o Domain Controller) sabe quem trabalha ali, que cartão de acesso cada pessoa tem, e que salas cada cartão abre. Um visitante à porta já consegue ver coisas sem se identificar — o nome do edifício, que anda lá gente, talvez o horário. Isso não é uma falha, é como um edifício funciona. O problema começa quando o livro de registo pode ser folheado por qualquer pessoa (enumeração sem credenciais), quando um cartão de limpeza mal configurado abre a sala do cofre (BloodHound a encontrar um caminho), ou quando alguém consegue arrancar a fechadura de uma sala inteira para experimentar chaves em casa, com calma, sem ninguém reparar (Kerberoasting/AS-REP Roasting — quebra offline).

## 3. Enumeração sem credenciais: o que é exposição por design (6.1, Entrada #89)

Antes de qualquer ataque, é preciso saber o que existe. Com `nmap` (varrimento das portas típicas do AD: 53, 88, 135, 139, 389, 445, 464, 636, 3268, 3269) e scripts NSE (`ldap-rootdse`, `smb-os-discovery`), confirmámos, sem qualquer credencial: o nome do domínio, o hostname do DC (`WIN-54OBK8B48L5`), a versão do Windows Server, e que o SMB signing estava ativo. Depois tentámos ir mais longe: bind LDAP anónimo (`ldapsearch`), listagem de partilhas/utilizadores SMB (`netexec`), RID cycling, e transferência de zona DNS (`dig axfr`) — todos recusados.

**A lição central:** há uma diferença fundamental entre informação que um protocolo expõe *por definição* (o nome do domínio, o DC) e uma falha de configuração real (deixar listar utilizadores sem autenticação). Confundir as duas leva a um relatório de pentest impreciso. E "sessão aceite" não é o mesmo que "acesso concedido" — só testar a operação em si confirma exposição real.

## 4. BloodHound: mapear caminhos de ataque sem inventar nada (6.2, Entrada #90)

Instalámos o BloodHound CE via Docker no Kali (três serviços: base de dados PostgreSQL, grafo Neo4j, e a aplicação), e usámos o coletor `bloodhound-python` com uma conta de utilizador normal (`uteste`) para recolher a estrutura do domínio: 2 computadores, 5 utilizadores, 52 grupos, 3 GPOs. Depois pedimos ao BloodHound para encontrar um caminho de `uteste` até `Domain Admins`.

Resultado: **"Path not found."** Não havia caminho. E isso é tão válido e informativo como encontrar um caminho — o BloodHound não serve só para mostrar problemas, serve também para comprovar, com dados e não com opinião, que uma configuração está correta.

**A lição central:** o BloodHound não cria o caminho de ataque. Ele mostra caminhos que a própria configuração do ambiente já permite. Defender-se dele não é "banir a ferramenta" — é fazer o trabalho de fundo (menor privilégio, sem cadeias tóxicas de permissões) que faz a ferramenta não encontrar nada.

## 5. Kerberoasting: o design do Kerberos usado contra si mesmo (6.3, Entrada #91)

Criámos uma conta de serviço (`svc_sql`) com um SPN associado (`MSSQLSvc/sql01.lab.local:1433`) — o padrão normal para qualquer serviço real num domínio. A partir do Kali, com a conta de utilizador comum `uteste` (sem qualquer privilégio especial), pedimos um ticket de serviço para essa conta (`impacket-GetUserSPNs`) e levámo-lo para quebra offline com `hashcat`. Numa password fraca (`Password123`), a quebra demorou menos de um segundo.

**A lição central, e a mais importante da fase:** qualquer conta autenticada do domínio pode pedir um ticket de serviço para qualquer conta com SPN — isto não é uma falha, é o funcionamento normal e por design do protocolo Kerberos. A vulnerabilidade nunca está em conseguir pedir o ticket; está inteiramente na força da password da conta de serviço. E como a quebra acontece offline, no computador do atacante, o ataque **não gera nenhuma tentativa de login falhada** — a política de bloqueio de conta da Fase 5 é completamente inútil aqui.

## 6. AS-REP Roasting: a variante sem barreira de entrada (6.4, Entrada #92)

Semelhante ao Kerberoasting, mas mais perigoso em teoria: se uma conta tiver a pré-autenticação Kerberos desativada (um atributo que não vem ligado por defeito), consegue-se pedir e quebrar offline a password dessa conta **sem usar nenhuma credencial válida**, só o nome de uma conta candidata. Criámos a conta `svc_legacy` com esse atributo ativado deliberadamente, e a partir do Kali, sem login nenhum, pedimos o hash com `impacket-GetNPUsers` e quebrámo-lo com `hashcat`.

**A lição central:** o AS-REP Roasting tem barreira de entrada zero — nem sequer uma conta comprometida é necessária. Mas depende de uma pré-condição que, por defeito, está desligada em qualquer domínio moderno. A defesa mais eficaz não é detetar o ataque — é auditar periodicamente e garantir que zero contas têm essa flag ligada, tornando o ataque simplesmente impossível.

## 7. O lado do Wazuh: quando "recolhido" não é "detetado" (6.5–6.7 das sessões Wazuh, Entradas #93–#95)

Depois dos quatro ataques, fomos ver o que o Wazuh tinha realmente detetado — e a resposta, por defeito, foi **nada**. O evento do Kerberoasting (4769) chegava e era indexado, mas caía sempre numa regra genérica de "logon com sucesso" que não distingue tráfego de rotina de um ataque. O evento do AS-REP Roasting (4768) nem sequer tinha regra nenhuma associada em todo o ruleset de fábrica.

Escrevemos duas regras próprias no Wazuh (`local_rules.xml`): a `100010`, para sinalizar qualquer pedido 4768 (AS-REP Roasting só acontece se este evento existir para uma conta com a flag ligada); e a `100011`, mais afinada, para sinalizar um pedido 4769 especificamente com cifra RC4 (`ticketEncryptionType: 0x17`) em vez de AES — o sinal mais fiável de Kerberoasting, porque dispara logo no primeiro pedido, sem precisar de olhar para frequência.

O caminho até isto funcionar teve dois obstáculos reais e instrutivos:
- A regra `100010` parecia não aparecer no Dashboard — a causa real não era a regra, nem o Filebeat, nem a ligação Manager→Indexer (todas essas hipóteses foram investigadas e corrigidas por serem problemas reais, mas laterais); era simplesmente a **janela de tempo do Dashboard estar sempre demasiado curta** para o evento aparecer.
- A regra `100011` ficava completamente silenciosa — e intrigantemente, nem a regra genérica disparava para aquele evento específico. A causa: uma regra de fábrica, de **nível 0 (silenciosa)**, feita para outro fim (deteção de IPs de logon remoto), tinha uma expressão regular demasiado permissiva que "reclamava" o evento do ataque primeiro (por o IP do Kali vir em formato IPv6-mapeado, `::ffff:192.168.10.10`), impedindo qualquer regra-filha de sequer ser avaliada.

**A lição central:** "instalado" não é o mesmo que "a detetar" — é uma lacuna de comportamento, não de recolha. E quando uma regra parece não disparar sem motivo aparente, vale a pena procurar outras regras que partilhem o mesmo "pai", em particular regras de nível 0, que podem estar a "engolir" o evento antes de ele chegar à nossa. Ficou fixada, a partir daqui, uma checklist própria de validação: confirmar sintaxe → reiniciar → repetir o ataque → verificar em camadas (arquivo bruto → índice → Dashboard, janela alargada) → só então declarar "resolvido".

## 8. LLMNR/NBT-NS/mDNS: o Responder e o hardening que se seguiu (6.6, Entrada #97, e 6.9, Entrada #98)

Este foi o único ataque da fase dirigido à **vítima** (o Windows 11) em vez de diretamente ao Domain Controller. Quando um Windows não consegue resolver um nome por DNS normal, não desiste — pergunta em voz alta à rede local, por três canais diferentes: mDNS, depois NBT-NS, depois LLMNR. Com o `Responder` a correr no Kali em modo ativo, bastou o Windows 11 tentar aceder a um nome inexistente (`\\testelab3`) para o Responder responder "sou eu" a essas perguntas — e o Windows tentou autenticar-se automaticamente, entregando o hash NTLMv2 completo sem qualquer interação do utilizador.

**A lição central desta parte:** ao contrário de uma vulnerabilidade de software, isto é um comportamento de origem do Windows — só se desliga com uma política específica, e por isso continua a aparecer em empresas bem geridas, mesmo sem nenhum erro de configuração óbvio.

Na sessão de fecho (6.9), implementámos essa política nas VMs:
1. **LLMNR**, por GPO — "Turn off multicast name resolution" = Enabled, ligada à OU do computador (não do utilizador, porque é uma definição de *Computer Configuration*).
2. **NBT-NS**, diretamente no adaptador do Windows 11 — porque a definição nativa de GPO para isto não existe na versão de ADMX deste servidor (uma limitação real, documentada como tal, não escondida).
3. Confirmação: `EnableMulticast: 0` e `TcpipNetbiosOptions: 2`.

A primeira prova com o Responder trouxe uma descoberta valiosa: LLMNR e NBT-NS ficaram mesmo silenciados (zero linhas desses dois no log), mas o Windows 11 recuou para um **terceiro canal, o mDNS**, que ainda não tínhamos desligado. Corrigido com `EnableMDNS = 0` no registo. Uma segunda tentativa mostrou o comportamento esperado — um erro limpo de "não consegue aceder ao nome" em vez do pedido de credenciais — mas sem o Responder ativamente à escuta nesse momento (um problema operacional pontual, "porta já em uso" por uma instância anterior), pelo que a confirmação final por captura fica como pendência para a próxima sessão.

**A lição central desta parte:** a dupla LLMNR/NBT-NS é o hardening "clássico" que a maioria dos guias menciona, mas o Windows moderno tem um terceiro mecanismo de fallback (mDNS) que é fácil de esquecer — desligar dois de três canais não fecha o ataque.

**Perspetiva da vítima/organização:** este é tipicamente o primeiro elo de um ataque interno numa empresa real. Um hash capturado pode ser quebrado offline (se a password for fraca) ou reencaminhado em tempo real para autenticar noutra máquina sem sequer ser quebrado ("NTLM relay") — muitas vezes o ponto de partida de ataques de ransomware. É traiçoeiro precisamente por ser silencioso e não depender de nenhum erro "visível": os três protocolos vêm ligados de origem.

## 9. O que ficou fora por decisão própria: Pass-the-Hash e DCSync/Golden Ticket (6.7 e 6.8)

Duas técnicas mais avançadas do roteiro original — Pass-the-Hash (reutilizar um hash capturado para autenticar sem quebrar a password) e DCSync/Golden Ticket (fazer-se passar pelo próprio Domain Controller para extrair todas as credenciais do domínio de uma vez, e forjar acesso persistente) — **não foram executadas neste laboratório**, por decisão própria, dado tratarem-se das técnicas mais intrusivas do plano. Ficam cobertas apenas ao nível conceptual, incluindo as defesas correspondentes:

- **Pass-the-Hash:** mitiga-se com Credential Guard, desativar NTLM a favor de Kerberos, e não reutilizar a mesma password de administrador local em várias máquinas (LAPS).
- **DCSync/Golden Ticket:** mitiga-se restringindo a permissão de replicação de diretório a apenas os Domain Controllers, monitorizando o Evento 4662, e rodando periodicamente a password da conta `krbtgt`.

Esta decisão está registada no roteiro do projeto e não bloqueia o encerramento da fase — apenas define o âmbito prático do laboratório.

## 10. Como nos podemos defender (resumo transversal)

- Informação exposta por definição de protocolo (nome do domínio, DC) não se "desliga" — a defesa aí é deteção da sequência de reconhecimento, não prevenção.
- O BloodHound não é o problema — cadeias de permissões excessivas são. Auditar caminhos de privilégio regularmente, incluindo com o próprio BloodHound.
- Contra Kerberoasting e AS-REP Roasting, a prevenção pesa mais do que a deteção: passwords de serviço fortes/aleatórias (idealmente gMSA), AES em vez de RC4, e — no caso do AS-REP — garantir que nenhuma conta tem a pré-autenticação desativada sem necessidade real.
- Regras de deteção "de fábrica" de um SIEM não cobrem tudo — equipas maduras escrevem e testam regras próprias para o seu ambiente, e verificam sempre em camadas (não confiar só na interface).
- LLMNR, NBT-NS e mDNS são comportamentos de origem do Windows, não bugs — desligá-los é uma decisão ativa de hardening, e é preciso desligar os três, não só dois.
- SMB signing e passwords fortes continuam a ser reforço em profundidade mesmo depois de desligar os fallbacks de resolução de nomes.

## 11. Estado de compreensão (honesto)

Consigo explicar cada ataque desta fase e a defesa que lhe corresponde, incluindo os momentos em que a investigação (sobretudo no Wazuh) não foi direta — a janela de tempo do Dashboard, e a regra de nível 0 a "engolir" o evento. A parte que ainda merece mais estudo, numa fase futura: a confirmação final, por captura ativa do Responder, de que o mDNS está mesmo silenciado — ficou como pendência da última sessão, por um detalhe operacional (Responder preso numa porta), não por falha da defesa.

**Fase 6 do roteiro fechada do lado defensivo** (Entradas #87–#98). Pass-the-Hash (6.7) e DCSync/Golden Ticket (6.8) ficam fora do âmbito hands-on por decisão própria, cobertos só conceptualmente nesta fase.
