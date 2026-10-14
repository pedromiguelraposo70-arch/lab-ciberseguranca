#!/bin/bash
# dvwa-healthcheck.sh - Sessao 9.4: saude do DVWA (preventivo + detetivo)
# Vive no Servidor Vulneravel (lab-seguranca, 192.168.10.101).
# Corre de minuto a minuto (cron do root) e escreve em /var/log/dvwa-health.log.
# Estados: OK | FALHA-DVWA (tenta reiniciar) | AVISO-DOCKER (1a falha de comunicacao) |
#          FALHA-DOCKER (2 verificacoes sem comunicacao; recuperacao nao garantida) | RECUPERADO
LOG=/var/log/dvwa-health.log
FAILS=/run/dvwa-health.fails
DFAILS=/run/dvwa-health.docker-fails         # contador proprio do Docker
LASTR=/run/dvwa-health.last-restart
LIMITE_FALHAS=2
LIMITE_DOCKER=2                              # so declara FALHA-DOCKER a 2a verificacao consecutiva
RECUPERACAO=300
URL=http://localhost:80/
ts() { date '+%Y-%m-%d %H:%M:%S'; }
log() { echo "$(ts) $1" >> "$LOG"; }

CODE=$(curl -s -o /dev/null -w '%{http_code}' --max-time 5 "$URL")

if [ "$CODE" = "302" ]; then
    log "OK dvwa http=302"
    echo 0 > "$FAILS"
    echo 0 > "$DFAILS"
    exit 0
fi

# Nao esta OK. O Docker responde?
if ! docker inspect -f '{{.State.Running}}' dvwa >/dev/null 2>&1; then
    D=$(( $(cat "$DFAILS" 2>/dev/null || echo 0) + 1 ))
    echo "$D" > "$DFAILS"
    if [ "$D" -ge "$LIMITE_DOCKER" ]; then
        log "FALHA-DOCKER http=$CODE sem-comunicacao-docker-em-$D-verificacoes recuperacao-nao-garantida"
    else
        log "AVISO-DOCKER http=$CODE sem-comunicacao-docker-verificacao=$D aguarda-confirmacao"
    fi
    exit 0
fi

echo 0 > "$DFAILS"

# Docker vivo, DVWA mal: conta a falha
N=$(( $(cat "$FAILS" 2>/dev/null || echo 0) + 1 ))
echo "$N" > "$FAILS"
log "FALHA-DVWA http=$CODE falhas-seguidas=$N"

if [ "$N" -ge "$LIMITE_FALHAS" ]; then
    AGORA=$(date +%s)
    ULT=$(cat "$LASTR" 2>/dev/null || echo 0)
    if [ $(( AGORA - ULT )) -ge "$RECUPERACAO" ]; then
        log "RECUPERAR a reiniciar contentor dvwa (falhas=$N)"
        if docker restart dvwa >/dev/null 2>&1; then
            echo "$AGORA" > "$LASTR"
            log "RECUPERADO docker restart dvwa com sucesso"
            echo 0 > "$FAILS"
        else
            log "FALHA-RECUPERACAO docker restart dvwa falhou"
        fi
    else
        log "ESPERA periodo de recuperacao ativo, nao reinicia (faltam $(( RECUPERACAO - (AGORA-ULT) ))s)"
    fi
fi
exit 0
