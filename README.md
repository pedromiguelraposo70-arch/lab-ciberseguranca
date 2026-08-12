# Laboratório de Cibersegurança — Diário de Aprendizagem

## Porque é que este repositório existe

Sou estudante iniciante de cibersegurança. Este repositório não é um produto acabado nem uma demonstração de competência — é o **registo honesto de como estou a aprender**, montando e usando um laboratório de máquinas virtuais em casa (VMware Workstation) para praticar de forma prática e segura.

A decisão de documentar tudo, incluindo o que correu mal, é intencional. A maior parte dos materiais de cibersegurança que se encontram online mostram o resultado final — o ataque que funcionou, o comando certo à primeira. Isso é útil para copiar, mas esconde a parte mais importante do processo de aprendizagem: os erros, os becos sem saída, e o raciocínio que leva de "não sei porque é que isto não funciona" a "ah, era isto".

## O que vais encontrar aqui

- **[`registo-laboratorio-ciberseguranca.md`](./registo-laboratorio-ciberseguranca.md)** — o registo principal, entrada a entrada, de cada exercício: objetivo, comandos usados, o que era esperado, o que aconteceu de facto, como nos podemos defender do ataque em causa, e — sempre que aplicável — **o que correu mal ou falhou**. Também mapeado, quando faz sentido, para os domínios de certificações em estudo (Security+, CEH, ISO/IEC 27001, NIS2, CompTIA A+).
- **`registo-laboratorio-ciberseguranca.pdf`** — a mesma informação, com os screenshots embutidos, para leitura fora do GitHub.
- **`screenshots/AAAA-MM-DD/`** — capturas de ecrã ilustrativas de cada dia de trabalho.
- **`guias-estudo/`** — documentos de consolidação por tema (analogias, raciocínio passo a passo, autoavaliação honesta de compreensão), separados do registo técnico.
- **[`glossario.md`](./glossario.md)** — termos técnicos explicados de forma simples, atualizado à medida que aparecem no registo.

## Porquê estas ferramentas

- **VMware Workstation** — permite isolar completamente o laboratório da rede de casa, com várias máquinas a correr em simultâneo, sem risco para o sistema real.
- **OPNsense** — firewall/router open-source, usado para gerir a rede interna e a saída para a internet, e para praticar configuração de firewall a sério, não só como decoração de topologia.
- **Kali Linux** — distribuição padrão da indústria para testes de segurança, com ferramentas de pentest pré-instaladas, usada como a máquina atacante.
- **DVWA (Damn Vulnerable Web Application)** — aplicação web intencionalmente vulnerável, com níveis de dificuldade crescente, escolhida por ser didática e mapear diretamente para o OWASP Top 10.
- **Docker** — usado para instalar e gerir o DVWA de forma isolada e fácil de repor do zero, sem "sujar" o sistema do Servidor Vulnerável.
- **Git / GitHub** — controlo de versões e histórico do progresso, também como portefólio público de aprendizagem.

## O espírito deste repositório

- **Não é um produto final.** É atualizado sessão a sessão, à medida que os exercícios acontecem — não reescrito no final para parecer mais polido do que foi na realidade.
- **Erros ficam registados, não apagados.** Se um comando falhou, se uma configuração de rede se partiu a meio de um exercício, se um pressuposto estava errado — isso fica documentado tal como aconteceu, porque é aí que está a aprendizagem real.
- **Evolução visível ao longo do tempo.** As primeiras entradas vão parecer mais hesitantes ou mais básicas do que as últimas — é suposto ser assim. Comparar a Entrada #1 com uma entrada de daqui a alguns meses deve mostrar claramente o progresso.

## Estado atual

**Dia 1 concluído** (2026-08-02): laboratório montado (OPNsense + Kali + Servidor Vulnerável), DVWA instalado, primeiro exercício de exploração (SQL Injection, nível Low) realizado com sucesso.

**Dia 2 concluído** (2026-08-05/06): SQL Injection nível Medium confirmado com sucesso (payload `1 OR 1=1`, via `curl` direto ao servidor), após investigação de uma falha de configuração real (cookies `security` duplicadas com paths diferentes). Corrigida também a política de restart do container Docker do DVWA.

**Dia 3 concluído** (2026-08-11): SQL Injection nível High explorado com sucesso (payload `1' OR '1'='1' #`, com contorno do `LIMIT 1` através de comentário SQL, e input baseado em sessão numa janela separada). Consolidada a compreensão de que, no High, a defesa do código continua fraca — o que muda é a arquitetura da aplicação, não a robustez da proteção. Reforçada também a lição central da defesa: os *prepared statements* neutralizam o ataque independentemente do payload.

**Dia 4 concluído** (2026-08-12): SQL Injection nível Impossible — o mesmo payload do High foi submetido e **falhou** (resultado vazio), travado pelos *prepared statements*. Fecha-se assim o capítulo do SQL Injection (Low → Medium → High → Impossible), com a lição central de que os "níveis" são versões diferentes do código, não configurações: os prepared statements são uma prática de programação universal, não um "modo". Na mesma sessão, exploração completa do módulo seguinte do roteiro — **Command Injection**, do nível **Low** ao **Impossible**: injeção de comandos do sistema operativo (RCE) no campo de ping, revelando o utilizador `www-data` e que o alvo corre num container Docker. Os níveis Medium e High usam filtros *blacklist* que foram contornados em cada caso (`|`, `&`, e o `|` sem espaço no High), e o Impossible usa uma **whitelist** que recusa tudo o que não seja um IP válido — ilustrando ao vivo a fragilidade das blacklists face às whitelists. Consolidação do módulo em [`guias-estudo/guia-estudo-command-injection.md`](./guias-estudo/guia-estudo-command-injection.md).

Ainda na mesma sessão, exploração completa da variante **XSS Reflected** (Cross-Site Scripting), do nível **Low** ao **Impossible**: injeção de JavaScript no campo "What's your name?", com execução no browser e leitura da cookie de sessão (`PHPSESSID`) — demonstrando *session hijacking*. Os níveis Medium e High usam *blacklists* (apagar `<script>`) contornadas com `<img onerror>` (mostrando que o XSS não vive só de `<script>`), e o Impossible usa **output encoding**, que mostra o payload como texto sem o executar. Mudança de paradigma face aos módulos anteriores: a vítima passa a ser o **browser de outro utilizador**, não o servidor. Ligação direta ao HttpOnly (a cookie era legível por não ter essa flag, já detetado no nmap da Entrada #8).

Próximo passo: as variantes **XSS Stored** e **XSS DOM**.
