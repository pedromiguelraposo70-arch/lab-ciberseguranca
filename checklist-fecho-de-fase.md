# Checklist de fecho de fase

**Para que serve:** no fim de cada fase, garantir que todos os documentos do projeto refletem o que a fase mudou — para não voltar a acumular o atraso encontrado na revisão geral de 2026-10-20 (documentos parados desde a Fase 6, contagens desatualizadas, afirmações que a própria fase tinha desmentido).

**Quando:** na última sessão de cada fase (a sessão de balanço), antes do commit final. Cada linha fica ✅, ou com o motivo escrito para não se aplicar.

## 1. Documentos a rever

**Aplicabilidade dos documentos:** não é obrigatório alterar todos os documentos da checklist. É obrigatório avaliar cada categoria aplicável à fase e justificar a alteração efetuada ou a ausência de alteração.

| # | Documento | O que confirmar | Feito quando... |
|---|---|---|---|
| 1 | `registo-laboratorio-ciberseguranca.md` | Entrada de balanço da fase; cada entrada com Consequência para a organização, Domínios e English summary | a entrada de balanço lista o que mudou e o que passa para a fase seguinte |
| 2 | `guias-estudo/` | Guia da fase, com síntese "Consequência para a organização" e "Estado de compreensão" aprovado pelo Pedro | o guia existe e a §"Estado de compreensão" deixou de ser rascunho |
| 3 | `README.md` e `README.pt.md` | Linha na linha do tempo e secção da fase, nas duas línguas, com ligação ao guia | as duas versões dizem o mesmo |
| 4 | `MAPA-DO-PROJETO.md` | Data, estado (✅ 🟡 ⬜) e última atualização de cada documento | não há nenhum documento com data mais antiga do que a fase sem um motivo escrito |
| 5 | `glossario.md` | Termos novos da fase; termos antigos que a fase tornou falsos ou incompletos | cada termo técnico novo do registo tem entrada |
| 6 | `registo-riscos.xlsx` | Riscos novos, riscos que mudaram, aplicação dos critérios da matriz | cada alteração tem data, evidência e critério aplicado |
| 7 | `declaracao-aplicabilidade-parcial.md` | Tratamento de cada risco e estado dos controlos | coerente com o registo de riscos |
| 8 | `mapa-cobertura-mitre-attack.md` | Ataques ou testes novos; deteções que mudaram de estado | cada mudança de cor tem a entrada que a prova |
| 9 | `tabela-resumo-ataques.xlsx` | Ataques novos; coluna "Estado atual" (deteção e mitigação separadas) | coerente com o mapa MITRE |
| 10 | `hardening-baseline.md` | Defesas novas; defesas que a fase alterou; data da última verificação ao vivo | nenhuma defesa descrita como verificada sem a data dessa verificação |
| 11 | `analise-rede/` | Ficha da fase, se a fase mexeu na rede (se não mexeu, dizê-lo no README da pasta) | `topologia-base.md` corresponde à rede real |
| 12 | `politicas/` | Regras que a fase cumpriu, violou ou tornou desatualizadas | §"Lacunas reconhecidas" com o estado atual |
| 13 | `playbook-resposta-incidentes.md` | Lições de resposta da fase | — |
| 14 | `scripts/` | Scripts novos (com cópia versionada) e candidatos | — |
| 15 | Proposta da fase seguinte | Lista do que a fase seguinte reverifica | lista escrita na entrada de balanço |

## 2. Regras de escrita (aprendidas no fecho da Fase 9)

- **Não reescrever o histórico.** Uma entrada antiga errada corrige-se numa entrada nova (ou com uma nota "Atualização (revisão de AAAA-MM-DD)"), sem apagar o texto original.
- **Erros grosseiros corrigem-se logo; erros menores listam-se** e tratam-se depois (regra do Pedro, 2026-10-20).
- **Não dizer mais do que a prova mostra:** "testado" ≠ "garantido"; "verificado em [data]" ≠ "verificado hoje"; "não configurado" ≠ "não suportado"; uma contagem ≠ uma linha lida; dedução marcada como dedução.
- **Deteção e mitigação sempre separadas.**
- **O risco segue o ativo:** uma correção demonstrada noutra conta ou noutro sistema não baixa o risco original.
- **Classificar risco com os critérios escritos da matriz**, e escrever qual critério se aplicou.
- **Lab vs. organização real** (regra do Pedro, 2026-10-25, a partir da Fase 10): cada entrada tem uma secção curta com uma tabela — quem faz, como se faz, que evidência fica, no lab e numa organização, e porque é diferente — e uma frase sobre o que a diferença muda na conclusão. Cada diferença é **documentada**; só é **aproximada** da realidade quando isso se justifica (decisão escrita). O campo *Objetivo* diz sempre o porquê do método, não só o quê.
- **Antes de dizer "publicado", confirmar no GitHub** (o push às vezes não chega; confirmar que o `main` remoto tem o último commit).

## 3. Datas fixas a acompanhar

| Data | O quê | Origem |
|---|---|---|
| ~2026-11-24 | Confirmar o apagamento do 1.º índice do Wazuh (retenção de 90 dias) | Entrada #115 |
| ~2027-01-15 | Próximo scan de vulnerabilidades (cadência trimestral da política) | Entrada #126; política de vulnerabilidades, 3.3 |
