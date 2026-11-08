#!/bin/bash
alvo=192.168.10.101
data=$(date '+%Y-%m-%d %H:%M:%S %Z')
origem=$(ip -4 -br a show eth0)
echo "AUDITORIA DO LABORATÓRIO — script V1 (rascunho)"
echo "Data/hora: $data"
echo "Origem: $origem"
echo "Alvo: $alvo"
echo "Relógio: não verificado contra fonte externa"
echo
testar_ftp() {
resposta=$(printf "USER $1\r\nQUIT\r\n" | nc -w 5 $alvo ${2:-21})
if echo "$resposta" | grep -q '^530'; then echo PASS
elif echo "$resposta" | grep -qE '^(230|331)'; then echo FAIL
else echo UNKNOWN
fi
}

echo "FTP anonymous: $(testar_ftp anonymous)"
echo "FTP pedro: $(testar_ftp pedro)"
testar_samba() {
resposta=$(timeout 10 smbclient //$alvo/publico -N -c 'ls' 2>&1)
if echo "$resposta" | grep -q 'NT_STATUS_ACCESS_DENIED'; then echo PASS
elif echo "$resposta" | grep -q 'blocks available'; then echo FAIL
else echo UNKNOWN
fi
}
echo "Samba sem credenciais: $(testar_samba)"
echo "--- Testes controlados (simulações; não são resultados reais) ---"
echo "Serviço indisponível (porta 2121): $(testar_ftp anonymous 2121)"
inverter() {
case $1 in
PASS) echo FAIL ;;
FAIL) echo PASS ;;
*) echo $1 ;;
esac
}
echo "Expectativa invertida (FTP anonymous): $(inverter $(testar_ftp anonymous))"
echo
echo "Limitações:"
echo "- Resultados válidos só a partir da origem indicada (Kali na DMZ, através do OPNsense)."
echo "- Samba: acesso sem credenciais (smbclient -N); a identidade exata que o servidor vê não foi verificada."
echo "- A conta testftp não é testada (exigiria uma password)."
echo "- FTP anónimo: não se isola se a recusa vem da lista de permitidos ou do anonymous_enable=NO."
echo "- A inversão da expectativa testa a lógica do script, não uma falha real do serviço."
