#!/bin/bash
alvo=192.168.10.101
versao="V2"
agora=$(date +%s)
data=$(date -d @$agora '+%Y-%m-%d %H:%M:%S %Z')
origem=$(ip -4 -br a show eth0)
mkdir -p ~/auditorias
relatorio=~/auditorias/auditoria-$(date -d @$agora '+%Y%m%d-%H%M%S').txt
exec > >(tee "$relatorio") 2>&1
pid_tee=$!
echo "AUDITORIA DO LABORATÓRIO"
echo "Versão do script: $versao"
echo "Relatório gravado em: $relatorio"
echo "Data/hora: $data"
echo "Origem: $origem"
echo "Alvo: $alvo"
echo "Relógio: não verificado contra fonte externa"
echo
testar_ftp() {
resposta=$(printf "USER $1\r\nQUIT\r\n" | nc -w 5 $alvo ${2:-21})
if echo "$resposta" | grep -q '^530'; then echo PASS; return 0
elif echo "$resposta" | grep -qE '^(230|331)'; then echo FAIL; return 1
else echo UNKNOWN; return 2
fi
}

global=0; aprov=0; falh=0; inconc=0
atualizar_global() {
case $1 in 0) aprov=$((aprov+1)) ;; 1) falh=$((falh+1)) ;; 2) inconc=$((inconc+1)) ;; esac
if [ $1 -eq 1 ]; then global=1
elif [ $1 -eq 2 ] && [ $global -eq 0 ]; then global=2
fi
}
r=$(testar_ftp anonymous); c=$?; echo "[$r] FTP: utilizador anonymous recusado — USER anonymous por nc, porta 21"; atualizar_global $c
r=$(testar_ftp pedro); c=$?; echo "[$r] FTP: nome pedro recusado na fase USER — USER pedro por nc, porta 21"; atualizar_global $c
testar_samba() {
resposta=$(timeout 10 smbclient //$alvo/publico -N -c 'ls' 2>&1)
if echo "$resposta" | grep -q 'NT_STATUS_ACCESS_DENIED'; then echo PASS; return 0
elif echo "$resposta" | grep -q 'blocks available'; then echo FAIL; return 1
else echo UNKNOWN; return 2
fi
}
r=$(testar_samba); c=$?; echo "[$r] Samba: acesso sem credenciais recusado — smbclient -N à partilha publico"; atualizar_global $c
echo "--- Testes controlados (simulações; não são resultados reais) ---"
echo "[$(testar_ftp anonymous 2121)] Serviço indisponível — USER anonymous por nc, porta 2121 (sem serviço)"
inverter() {
case $1 in
PASS) echo FAIL ;;
FAIL) echo PASS ;;
*) echo $1 ;;
esac
}
echo "[$(inverter $(testar_ftp anonymous))] Expectativa invertida — resultado do FTP anonymous, invertido"
echo
echo "Resumo: testados $((aprov+falh+inconc)) / aprovados $aprov / falhados $falh / inconclusivos $inconc"
echo "Limitações:"
echo "- Resultados válidos só a partir da origem indicada (Kali na DMZ, através do OPNsense)."
echo "- Samba: acesso sem credenciais (smbclient -N); a identidade exata que o servidor vê não foi verificada."
echo "- A conta testftp não é testada (exigiria uma password)."
echo "- FTP anónimo: não se isola se a recusa vem da lista de permitidos ou do anonymous_enable=NO."
echo "- A inversão da expectativa testa a lógica do script, não uma falha real do serviço."
exec 1>&- 2>&-
wait $pid_tee
exit $global
