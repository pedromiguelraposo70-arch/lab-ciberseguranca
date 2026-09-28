# Política de Controlo de Acesso e Passwords

**Empresa:** micro-empresa fictícia, 6-8 colaboradores (âmbito definido na Sessão 8.0)
**Data de aprovação:** 2026-09-28
**Dono da política:** Administração de sistemas
**Revisão:** anual, ou após qualquer incidente relacionado com acesso

**Histórico de revisões:** 2026-09-28 — 3.2 revista de 12 para 16 caracteres mínimos; secção 5 revista para separar autorização (Gerência) de execução (administração de sistemas).

## 1. Objetivo

Garantir que o acesso aos sistemas da empresa é atribuído apenas a quem precisa dele para o seu trabalho, que cada acesso é autenticado de forma segura, e que as passwords seguem um padrão mínimo de robustez — reduzindo o risco de contas comprometidas serem usadas para aceder, alterar ou destruir informação.

## 2. Âmbito

Aplica-se a todas as contas de utilizador e contas de serviço nos sistemas da empresa: Controlador de Domínio, estações de trabalho, servidor da aplicação de encomendas, acesso remoto (VPN).

## 3. Regras

- **3.1 Contas individuais.** Cada colaborador tem uma conta própria, nunca partilhada. Contas genéricas ("admin", "user") não são permitidas para uso de pessoas.
- **3.2 Robustez mínima.** Password com um mínimo de **16 caracteres**, sem reutilização das últimas 5 passwords da mesma conta. *(Valor revisto de 12 para 16 caracteres em 2026-09-28, por decisão do Pedro — alinhado com a tendência atual, refletida por exemplo no NIST SP 800-63B e em CIS Benchmarks, de priorizar o comprimento da password sobre regras de complexidade forçada como mistura obrigatória de símbolos/maiúsculas.)*
- **3.3 Bloqueio de conta.** Após 5 tentativas de login falhadas, a conta bloqueia durante 30 minutos. *(Já implementado e confirmado via GPMC — ver `hardening-baseline.md`, ponto 2.)*
- **3.4 Contas de serviço.** Cada conta de serviço (usada por uma aplicação, não por uma pessoa) tem uma password própria, distinta de qualquer conta de utilizador, e é revista sempre que o serviço associado muda. Onde a plataforma o permitir, deve usar-se uma gMSA (conta de serviço gerida, com rotação automática de password) em vez de uma password fixa.
- **3.5 Menor privilégio.** Nenhuma conta tem mais permissões do que as estritamente necessárias à sua função.

## 4. Exceção formal registada (risco aceite)

As contas de serviço `svc_sql` e `svc_legacy` mantêm-se, por decisão consciente, com passwords que não cumprem a regra 3.2 (curtas/previsíveis) e sem gMSA. Esta exceção existe apenas no ambiente de laboratório, para preservar Kerberoasting e AS-REP Roasting como demonstrações reproduzíveis — **nunca seria aceitável numa organização real**. Risco aceite formalmente na Sessão 8.3 (`declaracao-aplicabilidade-parcial.md`, controlos A.5.17/A.8.5), com origem na Fase 6 e documentado em `hardening-baseline.md`, ponto 8.

## 5. Responsabilidades

- **Gerência (dono do negócio):** autoriza a criação de uma conta nova (quando um colaborador entra) e a sua desativação (quando sai ou muda de função). É quem dá a ordem — a administração de sistemas nunca cria nem desativa uma conta por iniciativa própria.
- **Administração de sistemas:** executa a criação/desativação de contas mediante autorização da Gerência, configura o bloqueio de conta, revê periodicamente as contas de serviço.
- **Colaboradores:** não partilham passwords, reportam de imediato qualquer suspeita de acesso não autorizado à sua conta.

## Ligação a riscos e evidência

Risco #2 do `registo-riscos.xlsx` (Kerberoasting/AS-REP Roasting) — prova em Fase 6 e `hardening-baseline.md` ponto 8. Regra 3.3 (bloqueio de conta) já implementada e confirmada ao vivo (hardening-baseline, ponto 2).

**Domínios:** ISO/IEC 27001:2022 A.5.15 (controlo de acesso), A.5.17 (informação de autenticação), A.8.5 (autenticação segura).
