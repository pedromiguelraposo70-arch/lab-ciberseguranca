# Guia de acompanhamento — Fase 10, bloco 10.1

**Auditoria da escrita e reavaliação dos riscos.**

**Para quê:** acompanhar o bloco 10.1 e verificar se o registo, as políticas e o registo de riscos estão coerentes entre si e com o que foi feito.
**Versão:** 29/10/2026 · atualiza-se no fim de cada sessão.

**As regras de ouro gerais e as perguntas de controlo valem para toda a Fase 10 e estão no guia do bloco 10.0 (já impresso).** Esta folha tem só o que é próprio do 10.1.

**Regra transversal:** nenhuma sugestão do assistente substitui a decisão do Pedro, e nenhuma afirmação de sucesso substitui a evidência. ☑ = concluído **com evidência**, não apenas discutido.

## 1. Regras de ouro próprias do 10.1

- ☐ **Observar antes de testar:** a configuração regista-se primeiro; os testes de escrita só depois de a observação estar fechada e com uma pasta de destino segura identificada.
- ☐ **Separar configuração de funcionamento:** uma opção configurada (`anon_upload_enable=NO`, `write_enable=YES`) não demonstra o comportamento; "testado" ≠ "observado".
- ☐ **Nenhuma alteração durante a verificação:** não corrigir permissões nem configurações numa sessão de observação ou de teste; a correção é uma sessão própria.
- ☐ **Ficheiros de teste:** nome único, sem sobrescrever o que existe, e removidos no fim, com registo da remoção.
- ☐ **A VM da UC (`vuln-srv-01`) não se toca.**

## 2. Checklist do bloco 10.1

Executa: **C** = Claude (prepara rascunhos e apoia) · **P** = Pedro (executa e decide). Revê: **R** = Pedro, com apoio externo quando disponível. Aprova: sempre **P**.

| Estado | Sessão / passo | Evidência exigida | Executa | Revê | Aprova |
|---|---|---|---|---|---|
| ☑ | 10.1.1 — Medição da R5 no início da sessão; capacidade do `/home` tratada | Entrada #137 publicada (commit `f77fc43`) | P · C | R | P |
| ☑ | 10.1.2 — Inventário dos controlos de escrita no Servidor Vulnerável (só observação) | Entrada #138 publicada (commit `b69df7e`) | P · C | R | P |
| ☐ | 10.1.3 — Testes de funcionamento das três vias de escrita + decisão de desenho do Samba | Entrada publicada com o resultado de cada teste e a remoção dos ficheiros de teste | P · C | R | P |
| ☐ | Sessão de correção — permissões 777 e o que a investigação confirmar | Snapshot (R1) e espaço livre (R4) confirmados; prova antes/depois; Entrada publicada | P · C | R | P |
| ☐ | Reavaliação do risco #1 com os critérios v1 | `registo-riscos.xlsx` e Declaração atualizados, com o critério aplicado | P · C | R | P |
| ☐ | Fecho do bloco 10.1 | `checklist-fecho-de-fase.md` aplicada ao bloco; revisão documental; aprovação do Pedro | C | R | P |

## 3. Pendências próprias do 10.1

| Estado | Pendência | Origem | Condição para ☑ |
|---|---|---|---|
| ☐ | Três testes de funcionamento: upload anónimo por FTP (esperado falhar), gravação da `testftp` por FTP, gravação de convidado por Samba | #138 | Cada teste executado, resultado registado e ficheiro de teste removido |
| ☐ | Decidir se a partilha Samba `publico` deve permitir escrita de convidado (decisão de desenho) | #138 | Decisão escrita; só então a verificação 3 fica conforme ou não conforme |
| ☐ | Decidir se o confinamento das contas locais de FTP (chroot) é um requisito | #138 | Decisão escrita; só então a verificação 2 fica conforme ou não conforme |
| ☐ | Corrigir as permissões 777 de `/srv/ftp/upload` e `/srv/samba/publico` | #138 | Sessão de correção, depois dos testes, com R1 e R4; prova antes/depois |
| ☐ | Reavaliar o risco #1 com os critérios v1 | #138; proposta Fase 10 (decisão 2) | Feito depois dos testes e da decisão de desenho do Samba |

## 4. Pendências do 10.0 que transitam

Continuam no guia do bloco 10.0 (secção 2). As mais relevantes para o 10.1:

- Decidir o suporte das cópias (R6) — **prioridade antes do 10.4**; verificar o disco "TOSHIBA".
- Regra temporária da 7.4; 13 regras *Floating* automáticas do OPNsense.
- Registos das atualizações automáticas do Wazuh.
- Alinhar o texto do limiar da R5; clarificar se a R5 da #134 conta como primeira aplicação.
- Pasta `Claude outputs/`.

## 5. Notas e propostas do Pedro

As dúvidas, propostas e decisões do Pedro são apresentadas diretamente nas sessões; não ficam registadas neste documento.
