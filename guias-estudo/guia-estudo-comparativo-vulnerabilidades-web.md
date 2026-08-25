# Guia de Estudo — Quadro Comparativo de Vulnerabilidades Web

*Documento de síntese transversal aos módulos do DVWA. Enquanto os outros guias aprofundam um tema, este junta-os e destaca o padrão que os une. Documento vivo — cresce à medida que se fecham módulos.*

*Foco central: **quem interpreta o input malicioso e onde o dano acontece.***

---

## Quadro comparativo

|  | **SQL Injection** | **Command Injection** | **XSS** |
|---|---|---|---|
| **O que é enganado** | A base de dados | O sistema operativo do servidor | O browser de outro utilizador |
| **Linguagem injetada** | SQL | Comandos de shell (bash, cmd) | HTML / JavaScript |
| **Onde executa** | No servidor (base de dados) | No servidor (sistema operativo) | No cliente (browser de quem vê a página) |
| **Quem é a vítima direta** | A aplicação / os dados | O servidor inteiro | Outros utilizadores da aplicação |
| **Impacto típico** | Roubo / alteração de dados | Controlo do servidor (shell, backdoor) | Roubo de sessão, phishing, ações em nome da vítima |
| **Exemplo de payload** | `' OR '1'='1` | `; whoami` | `<script>alert('hack')</script>` |

---

## A diferença mais importante para reter

**SQL Injection** e **Command Injection** acontecem no **servidor** — o ataque completa-se ali mesmo, sem precisar de mais ninguém envolvido.

**XSS** é diferente na estrutura toda: o payload fica guardado ou refletido na página, mas só "dispara" quando **outra pessoa (a vítima)** abre essa página no browser dela. Não se ataca o servidor — usa-se o servidor como **veículo** para atacar os utilizadores da aplicação. É por isso que o XSS tem 3 variantes (Reflected, Stored, DOM): a diferença entre elas é precisamente **como o payload chega até à vítima**.

---

## O fio condutor entre os três

Em todos os casos, a causa raiz é a mesma: **input do utilizador tratado como código, sem separação nem validação.** O que muda é só **quem interpreta** esse código — a base de dados, o sistema operativo, ou o browser de outra pessoa.

E as defesas espelham este fio condutor: em todos, a solução passa por **separar dado de código** e por **validar/tratar o input** — prepared statements no SQLi (o dado nunca vira SQL), whitelist no Command Injection (só se aceita o formato válido), e output encoding no XSS (o `<script>` é mostrado como texto, não executado).

---

## Nem todos os saltos de nível são iguais

Um padrão que se repetiu em SQL Injection, Command Injection e XSS: Medium e High são a **mesma categoria de falha** (uma blacklist, mais ou menos esperta), e passar de um para o outro é só um reforço do mesmo tipo de filtro — o método de ataque mantém-se, só precisa de um payload ligeiramente diferente.

O **File Upload** quebrou este padrão (Entrada #39): o bypass do Medium (forjar o MIME type com um comando `curl`) deixa de funcionar por completo no High, que passa a verificar a extensão do ficheiro e o conteúdo real. Um compromisso completo do High parece exigir **encadear outra vulnerabilidade** (File Inclusion), não apenas mais esforço no mesmo tipo de ataque.

**Lição:** ao subir de nível, vale a pena perguntar não só "isto é mais difícil de contornar?", mas também "isto ainda é o mesmo tipo de ataque, ou preciso de mudar de estratégia por completo?". Nem sempre é "mais um degrau da mesma escada" — às vezes é preciso mudar de escada.

---

## Progressão Low → Impossible, por módulo, com analogia

Cada módulo tem a sua própria "história" de como a defesa evolui (ou não) entre níveis. Esta secção junta essa progressão, módulo a módulo, sempre com a mesma analogia a acompanhar os quatro níveis — para ver com mais clareza o que muda de facto em cada salto.

### SQL Injection — o empregado do arquivo

- **Low:** traz literalmente o que disseres, sem questionar nada (`' OR '1'='1`).
- **Medium:** deixa de aceitar pedidos com aspas — mas nem precisas de aspas se pedires só um número solto (`1 OR 1=1`).
- **High:** já te atende numa salinha separada e só mostra um resultado de cada vez — mas se disseres "e ignora o resto do que eu disser a seguir" (o comentário `#`), continuas a conseguir tudo.
- **Impossible:** deixa de "ouvir" o que disseres como instruções — o que disseres é sempre tratado como o conteúdo de um campo fixo (prepared statements), nunca como parte do pedido em si.

### Command Injection — o assistente do ping

- **Low:** cumpre à letra tudo o que escreveres a seguir ao endereço (`; whoami`).
- **Medium:** aprende a ignorar "e depois faz X" (`;`) e "só se resultar bem, faz X" (`&&`) — mas ainda obedece a "passa isto para aquilo" (`|`) e "faz ao mesmo tempo" (`&`).
- **High:** aprende mais uma frase proibida (`| ` com espaço) — mas continua a cair em `&` sozinho e no mesmo pipe sem espaço à volta (`|whoami`).
- **Impossible:** deixa de tentar adivinhar frases perigosas — só aceita algo com o formato exato de um IP, recusa tudo o resto.

### XSS (Reflected / Stored) — o mural de recados

- **Low:** aceita qualquer coisa escrita, e mostra-a tal como é escrita — incluindo instruções escondidas que "ativam" quando alguém olha para o mural (`<script>alert()</script>`).
- **Medium:** risca a palavra exata `"<script>"` — mas aceita a mesma instrução disfarçada de outra forma (`<img onerror=...>`).
- **High:** risca a palavra em qualquer combinação de maiúsculas/minúsculas — mas continua a não reconhecer a instrução disfarçada de outra etiqueta.
- **Impossible:** deixa de tentar ler o que está escrito como instruções — afixa tudo literalmente como texto, símbolo a símbolo, nunca como uma ordem a cumprir (output encoding).

*(DOM segue uma lógica diferente — o "mural" nem chega a passar pelo servidor, é escrito diretamente pelo próprio browser da vítima; ver guia dedicado.)*

### CSRF — o cartão de identificação automático

- **Low:** a porta abre-se sempre que o cartão está por perto, sem mais nenhuma verificação.
- **Medium:** comportamento igual ao Low para este ataque — só muda um pormenor do formulário (deixa de pedir a password atual), sem defesa nova relevante.
- **High:** o segurança passa a perguntar "de onde vens?" (cabeçalho Referer) — mas se não disseres nada (Referer ausente), deixa passar na mesma; só desconfia de quem diz vir do sítio errado, não de quem não diz nada.
- **Impossible:** a porta deixa de confiar só no cartão — exige também um código secreto gerado na hora (token anti-CSRF), só entregue a quem passou pela entrada principal em pessoa, e volta a pedir a password atual antes de aceitar a mudança.

### File Upload — a receção de encomendas

- **Low:** aceita qualquer embrulho, sem olhar para o conteúdo.
- **Medium:** olha para a etiqueta colada por fora ("Contém: imagem") — mas quem escreve a etiqueta é o próprio remetente, que pode mentir (MIME type forjado).
- **High:** abre o embrulho e verifica o que está mesmo lá dentro — já não confia na etiqueta. Mas um compromisso completo aqui exige entrar por outra porta (encadear com File Inclusion), não só melhorar o disfarce do embrulho.
- **Impossible:** verifica o conteúdo real **e** exige uma senha de entrega válida (token anti-CSRF) antes sequer de aceitar receber o embrulho.

### File Inclusion — o porteiro do crachá

- **Low:** deixa passar com qualquer crachá, sem olhar (`/etc/passwd` direto).
- **Medium:** recusa só quem tiver escrito literalmente "Convidado Externo" (`http://`) no crachá — mas aceita qualquer outro texto, incluindo "sou eu mesmo, moro na sala do fundo" (caminho local absoluto).
- **High:** só deixa passar crachás que **comecem** pela palavra "Convidado" (`file*`) — mas não confirma se o resto faz sentido, o que permite um crachá tipo "Convidado, teleporta-me à sala do fundo" (`file://`).
- **Impossible:** tem uma lista fixa e fechada com os únicos nomes de crachá que aceita — compara letra a letra, e recusa tudo o resto, por mais parecido que seja com um nome válido.

### Brute Force — o cadeado de números

- **Low:** testa-se código após código sem ninguém a impedir — mais cedo ou mais tarde abre.
- **Medium:** o cadeado passa a demorar 2 segundos entre cada tentativa — não impede, só torna tudo ~50x mais lento.
- **High:** exige um selo que muda a cada tentativa (token anti-CSRF) — obriga a ir buscar um selo novo antes de cada código, mas quem automatiza vai buscá-lo na mesma; e o selo nem foi feito para isto, é contra outro ataque (CSRF).
- **Impossible:** ao fim de 3 tentativas erradas, o cadeado tranca-se por completo — deixa de aceitar códigos, mesmo o certo. É a única defesa que ataca a raiz (o *número* de tentativas), não a *velocidade* nem a *forma* de cada uma.

*(Nota: o Brute Force é a única categoria do quadro que não explora falta de validação de input — explora falta de limitação do volume de tentativas. As defesas, por isso, também são de outra família: não é "tratar o input como texto", é "impedir que se façam muitas tentativas".)*

### O padrão que atravessa todos os módulos

Em quase todos, **Low → Medium → High é a mesma categoria de defesa** (uma blacklist, cada vez um pouco mais esperta), e o esforço do atacante só aumenta ligeiramente a cada nível — o método mantém-se. O salto para **Impossible** é sempre uma mudança de categoria, não mais um degrau: deixa de haver uma lista de coisas proibidas para escapar, e passa a haver uma definição fechada do que é permitido (whitelist exata, prepared statements, output encoding, tokens). É a mesma ideia com nomes diferentes consoante o que está a ser protegido — mas há duas exceções reais que quebram este padrão. A primeira, o **File Upload High/Impossible**, mostra que às vezes nem "mudar de categoria" chega: é preciso encadear outra vulnerabilidade por completo. A segunda, o **Brute Force**, mostra que nem todos os módulos são sequer sobre *validação de input* — este é sobre limitar o *volume* de tentativas, uma família de defesa completamente diferente (atraso, bloqueio de conta), onde "tratar o input como texto" não se aplica de todo.

---

*Módulos cobertos neste quadro: SQL Injection (Entradas #10–16), Command Injection (#17–20), XSS — Reflected/Stored/DOM (#21–32), CSRF (#33–36), File Upload — Low a Impossible (#37–40), File Inclusion — Low a Impossible (#41–44), encadeamento File Upload + File Inclusion — High comprometido, Impossible bloqueado (#45–46), Brute Force — Low a Impossible (#47–51). **Fase 2 do roteiro concluída.***
