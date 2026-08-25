# Guia de Estudo — Brute Force (Ataque de Força Bruta a Autenticação)

*Documento de consolidação do módulo Brute Force do DVWA. Escrito para conseguir explicar isto a alguém sem ter o ecrã à frente. Inclui os acertos e enganos pelo caminho. Módulo fechado (Low → Impossible) — encerra a Fase 2.*

---

## 1. O que é, em 30 segundos

Adivinhar uma password por **tentativa e erro em massa** — testar muitas combinações até acertar. Ao contrário de todos os módulos anteriores, aqui **não há uma falha de código a explorar** (nenhuma injeção, nenhum filtro para contornar). A vulnerabilidade é a **ausência de travões** ao número de tentativas: sem bloqueio de conta, sem limite de taxa, sem CAPTCHA, testar passwords uma a uma é trivial e imparável.

**Analogia (o cadeado de números):** é como testar códigos de um cadeado, um a um. Se o cadeado não tiver limite de tentativas nem alarme, mais cedo ou mais tarde acertas — só depende de quanto tempo tens. As defesas contra isto não tornam o cadeado "mais difícil de abrir"; tornam *impraticável testar tantos códigos* (bloqueiam-no ao fim de X tentativas, ou obrigam a esperar entre cada uma).

**A diferença essencial face aos outros módulos:** SQLi, Command Injection, XSS, CSRF, File Upload e File Inclusion exploram todos uma falta de **validação** de um input. O Brute Force explora uma falta de **limitação de volume** (rate limiting / account lockout). É uma categoria de vulnerabilidade nova.

---

## 2. Como distinguir sucesso de falha (a base de qualquer automação)

Antes de automatizar, é preciso saber ler o resultado de cada tentativa:
- **Falha:** `Username and/or password incorrect.`
- **Sucesso:** `Welcome to the password protected area <username>`

Toda a automação (ciclo bash, Hydra, script) assenta em procurar uma destas frases na resposta.

---

## 3. Progressão dos níveis

- **Low (Entradas #47–#48):** sem qualquer defesa. Todas as tentativas processadas instantaneamente.
  - **Manual (bash):** um ciclo `for` + `curl` percorre a wordlist e acerta em `password` em segundos.
  - **Hydra (ferramenta profissional):** mesma password encontrada. Sintaxe do módulo `http-get-form`: `url:params:condição`, com o `^PASS^` a marcar onde injetar cada tentativa. **Lição de sintaxe que custou várias tentativas:** a **condição de falha tem de ser o último campo**; parâmetros opcionais (cabeçalho `H=Cookie...`) vêm *antes* dela; `:` dentro de valores escapa-se com `\:`. Consultar `hydra -U http-get-form` resolve.

- **Medium (Entrada #49):** **atraso artificial** de ~2 segundos (`sleep(2)`) a cada tentativa falhada. Medido: falha no Medium = `2,013s` vs. no Low = `0,040s` (~50× mais lento). O ataque continua a funcionar, só fica lento — defesa por **encarecimento**, não por bloqueio. Contornável com paralelismo/muitos IPs.

- **High (Entrada #50):** **token anti-CSRF** (`user_token`) que **muda a cada carregamento da página**. Um ataque ingénuo falha (token velho é rejeitado). Contornado com um **script de dois passos** por tentativa: (1) buscar o token fresco da página, (2) submeter o login com esse token — e a resposta já traz o próximo token. **Ponto conceptual importante:** o token anti-CSRF foi desenhado contra **CSRF**, não contra brute force; só o atrapalha por acidente (obriga a um pedido extra), não o impede.

- **Impossible (Entrada #51):** **bloqueio de conta** após 3 tentativas falhadas. Demonstração: com a password correta em 5º lugar na wordlist (após 4 falhas), o ataque **falhou** — a conta bloqueou à 3ª falha, e as tentativas seguintes foram rejeitadas mesmo estando certas. Além disso, usa **prepared statements** no login (anti-SQLi). É a **única defesa que ataca a raiz** do brute force: o *volume* de tentativas.

---

## 4. As defesas, por categoria (o essencial a reter)

| Nível | Defesa | Categoria | Trava o ataque? |
|---|---|---|---|
| Low | nenhuma | — | Não |
| Medium | atraso de 2s por falha | encarecer cada tentativa | Não — só abranda |
| High | token anti-CSRF | dificultar a automação (por acidente) | Não — contornável |
| Impossible | bloqueio de conta (+ prepared statements) | impedir o volume de tentativas | **Sim** |

**Defesa completa no mundo real:** bloqueio/rate limiting por conta e IP + CAPTCHA após N falhas + MFA + políticas de password fortes. Nenhuma sozinha basta; combinam-se em profundidade.

**Cuidado (efeito colateral):** o bloqueio de conta abre a porta a um **DoS** — um atacante pode trancar a conta de uma vítima legítima de propósito, com 3 falhas. Mitiga-se com desbloqueio temporizado ou bloqueio por IP.

---

## 5. Estado de compreensão (honesto)

**2026-08-17:**
- Que o Brute Force é uma categoria diferente dos módulos anteriores (falta de limitação de volume, não falta de validação de input): **Sim**.
- Automação manual (ciclo `for` + `curl`) e leitura da condição de sucesso/falha: **Sim**.
- Sintaxe do Hydra (`http-get-form`, ordem dos campos, escaping): **Sim** — depois de sofrer com ela e consultar `hydra -U`. Lição de método: perante erro de sintaxe repetido, ir à documentação da ferramenta em vez de adivinhar.
- Medium como defesa por atraso (encarecer, não impedir), confirmado por medição de tempo: **Sim**.
- High: token anti-CSRF que roda a cada pedido, e o script de dois passos para o contornar; e que essa defesa não foi feita contra brute force: **Sim**.
- Impossible: bloqueio de conta como a defesa que ataca a raiz (o volume), demonstrado com a password certa a falhar por lockout; e o efeito colateral de DoS: **Sim**. Fecha o módulo.

## 6. Ligação aos outros módulos

Ver o quadro transversal e as analogias por nível no guia dedicado: [`guia-estudo-comparativo-vulnerabilidades-web.md`](guia-estudo-comparativo-vulnerabilidades-web.md).
