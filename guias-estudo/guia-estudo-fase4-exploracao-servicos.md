# Guia de Estudo — Fase 4: Exploração de Rede e Serviços

## 1. O que foi esta fase, em 30 segundos

A Fase 3 foi sobre **proteger** tráfego (VPN). A Fase 4 foi o oposto: **atacar** serviços de rede, na mesma VM "Servidor Vulnerável" que já tinha o DVWA. Em vez de usar uma VM Metasploitable pronta, decidimos instalar e configurar mal, à mão, três serviços reais (FTP, Samba, base de dados) — porque configurar a falha nós próprios ensina mais do que explorar uma falha já pronta por outra pessoa.

## 2. A decisão mais importante da fase: manual vs. Docker

Já tínhamos o DVWA em Docker. Para a Fase 4, escolhemos **não** usar Docker — instalar os serviços diretamente no sistema operativo. Isto teve um custo real: mais trabalho, mais coisas para correrem mal (a porta 80 ocupada, permissões, etc.). Mas o ganho foi perceber a configuração "por dentro" — ficheiros de configuração reais, permissões de utilizadores reais, não uma caixa preta pronta a usar.

Achado lateral interessante: quando tentámos ligar o FTP anónimo ao servidor web do DVWA (para fazer uma cadeia de ataque), descobrimos que o container Docker do DVWA não tinha nenhuma pasta partilhada com o sistema operativo (`docker inspect` devolveu `Mounts: []`). Ou seja, nem nós, os administradores, conseguíamos alcançar diretamente o sistema de ficheiros do DVWA sem uma configuração explícita de volume. Tivemos de montar um Apache novo e independente para a demonstração.

## 3. A recuperação da VM e a rede "isolada de propósito"

Antes de começar, a VM não arrancava (`Cannot open the disk... Module 'Disk' power on failed`). Causa: ficheiros de bloqueio (`.lck`) órfãos de um encerramento anterior mal feito — confirmámos com `ps aux` que nada os estava realmente a usar, e removemos com `rm -rf`.

Depois, tentámos ligar por SSH à VM a partir do computador físico (o host) — e falhou, com "No route to host". Investigámos e descobrimos que a rede "Ciber" (onde vivem todas as VMs do lab) é uma rede do tipo **Private Network** do VMware — um tipo mais recente que isola a rede também do próprio host, ao contrário das redes "Custom" clássicas. Só o Kali, que já está dentro dessa rede, consegue interagir com as outras VMs. Isto não é um bug — é o mesmo princípio de segmentação de rede usado em ambientes reais para proteger segmentos sensíveis.

## 4. O padrão que se repetiu três vezes: acesso anónimo/fraco mal pensado

### FTP (`vsftpd`)
Instalámos a versão atual (`3.0.5`, sem qualquer backdoor) e ativámos `anonymous_enable=YES` + `anon_upload_enable=YES` — login sem password, com permissão de escrita. Confirmámos a partir do Kali: `ftp 192.168.10.101`, utilizador `anonymous`, e conseguimos enviar ficheiros sem qualquer credencial.

### Samba
Exatamente o mesmo padrão, noutro protocolo: uma partilha `[publico]` com `guest ok = yes` e `read only = no`. A partir do Kali, `smbclient -L //192.168.10.101/ -N` listou a partilha sem credenciais, e conseguimos enviar ficheiros com `put`.

### Base de dados (MariaDB)
Desta vez não foi "acesso anónimo", mas "credenciais fracas expostas": mudámos o `bind-address` de `127.0.0.1` (só local) para `0.0.0.0` (qualquer origem), e criámos um utilizador `dbadmin` com password `admin123` e privilégios totais, acessível de qualquer host (`'dbadmin'@'%'`).

**A lição central desta secção:** o erro nunca foi um "bug" de software — foi sempre uma decisão de configuração. E o mesmo tipo de erro (acesso sem restrição suficiente) repete-se em protocolos completamente diferentes. Reconhecer o padrão vale mais do que decorar o sintoma de um serviço específico.

## 5. A cadeia de ataque: quando duas falhas pequenas se tornam uma grande

O momento mais rico da fase: em vez de só provar que conseguíamos escrever no FTP, fomos mais longe — montámos um Apache a apontar para a mesma pasta do FTP anónimo, e testámos se um ficheiro `.php` enviado por FTP seria executado pelo servidor web.

Não foi direto. Precisámos de resolver **duas** más configurações extra, uma a seguir à outra:
1. O Apache negava acesso à pasta por defeito (regra global só permite `/var/www/`) — resolvido com um bloco `<Directory>` explícito.
2. O `vsftpd` aplica, por defeito, um `umask` restritivo (`077`) aos uploads anónimos — os ficheiros ficavam com permissão `600`, ilegíveis pelo utilizador do Apache (`www-data`). Resolvido relaxando o `umask` (`anon_umask=022`).

Só depois destas duas correções é que o teste final funcionou: um `shell.php` (`<?php echo shell_exec($_GET["cmd"]); ?>`) enviado por FTP, executado via `curl "http://.../shell.php?cmd=whoami"`, devolveu `www-data` — execução de comandos arbitrários no servidor, sem qualquer credencial.

**Lição:** falhas de segurança reais raramente vêm de um único erro óbvio. Vêm de várias decisões pequenas, cada uma aparentemente inofensiva sozinha, que empilhadas abrem uma cadeia completa de exploração.

## 6. Quando uma vulnerabilidade "de livro" não se confirma: o Optionsbleed

Tentámos explorar uma vulnerabilidade real e conhecida (CVE-2017-9798, "Optionsbleed") no Apache antigo (`2.4.25`) que vem dentro do container do DVWA — uma fuga de memória que corrompe o cabeçalho HTTP `Allow` sob concorrência.

Encontrámos um sintoma parecido (o cabeçalho vinha com métodos duplicados: `OPTIONS,HEAD,HEAD,GET,HEAD,POST`), mas era **sempre exatamente igual**, mesmo com 50 pedidos verdadeiramente simultâneos. Isso é um bug relacionado mas diferente (Apache bug #61207), sem gravidade de segurança — não a fuga de memória real.

**Lição mais importante da fase, provavelmente:** ter a versão de software "vulnerável" não significa que o ataque específico funcione. A vulnerabilidade real depende de condições de configuração muito específicas (normalmente ficheiros `.htaccess` com diretivas contraditórias) que esta instalação em concreto não tinha. Documentar isto como um resultado negativo honesto — em vez de forçar uma conclusão de sucesso — é tão valioso quanto documentar um sucesso.

## 7. Metasploit: força bruta de credenciais, e os seus próprios bugs

Usámos dois módulos do Metasploit (`auxiliary/scanner/ftp/ftp_login` e `auxiliary/scanner/mysql/mysql_login`) para automatizar tentativas de login com listas pequenas de utilizadores/passwords plausíveis. Em ambos os casos, criámos antes um utilizador de teste com password fraca (nunca tentámos adivinhar passwords reais de sistema).

No FTP, funcionou perfeitamente à primeira. Na base de dados, o módulo teve um problema próprio: nunca chegou a testar o utilizador certo (`dbadmin`) da lista, por causa de uma incompatibilidade da biblioteca Ruby do Metasploit com o protocolo de autenticação desta versão do MariaDB. Corrigido testando diretamente com `USERNAME`/`PASSWORD` explícitos.

**Lição:** as ferramentas de segurança têm os seus próprios bugs e limites. Um resultado negativo ou incompleto de uma ferramenta não prova que o alvo está seguro — só prova que aquela tentativa específica falhou.

## 8. Como nos podemos defender (resumo transversal)

- Nunca ativar acesso anónimo de escrita (FTP, Samba) sem necessidade explícita e bem pensada.
- Nunca fazer coincidir pastas de upload com pastas servidas pela web — e desativar execução de código do lado do servidor em pastas de upload.
- Políticas de password fortes, bloqueio após tentativas falhadas, autenticação multifator onde possível.
- Bases de dados nunca expostas diretamente à rede sem necessidade — e sempre com TLS ativo quando o acesso remoto for mesmo preciso.
- Manter software atualizado continua a ser a defesa primária contra vulnerabilidades de versão — mas não é garantia de exploração automática, nem de proteção automática (defesa em profundidade continua a ser necessária).
- Segmentação de rede (como a rede "Ciber" isolada do host) limita quem consegue sequer tentar um ataque.

## 9. Estado de compreensão (honesto)

Consigo explicar cada entrada desta fase por palavras próprias, incluindo os momentos em que as coisas não correram como planeado à primeira (o timeout do FTP, o 403 do Apache, o erro do TLS no MySQL, o bug do Metasploit). A parte que ainda merece mais estudo, numa fase futura: perceber melhor *porque* é que bibliotecas como a do Metasploit falham desta forma tão específica (o detalhe do protocolo de autenticação do MySQL), em vez de só saber contornar o problema.

**Fase 4 do roteiro concluída** (Entradas #57–#65).
