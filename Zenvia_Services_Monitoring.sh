#!/bin/bash

# *************************************************************************
# DESCRICAO: Script para monitoramento da Status Page do fornecedor ZENVIA
# VERSAO: 1.3
# AUTOR: Cristian Souza     
# DATA: 03/02/2025
# *************************************************************************

set +vx
# Array de nomes de variáveis
NOMES=("ZENVIA_CHAT_PORTAL-ADMIN"
       "ZENVIA_CHAT_CHAT-PORTAL"
       "ZENVIA_CHAT_CHAT-CORE"
       "ZENVIA_CHAT_CHAT-MICROSERVICES"
       "ZENVIA_CHAT_CHAT-API"
       "ZENVIA_BOTS_NLU-HEARTBEAT"
       "ZENVIA_BOTS_NLU-ALTU_COM"
       "ZENVIA_BOTS_NLU-ALTU-GATEWAY"
       "ZENVIA_BOTS_NLU-ALTUBOTS_COM"        
       "ZENVIA_BOTS_NLU-CONTROLE-INATIVIDADE"
       "ZENVIA_BOTS_NLU-GESTAO-BOTS-IA"
       "ZENVIA_BOT_WORKFLOW-INTERNAL-QUEUE"
       )

# Array de valores correspondentes às variáveis
VALORES=("0r7fsC3sMMDZXFejqRsDwLuLckWi4hBmhH7lrbwub-T351JuXe3PAmHLbWflDr-0" 
         "0r7fsC3sMMDZXFejqRsDwLuLckWi4hBmhH7lrbwub-RvMvteArEXXNeorb1IZ_lX"
         "0r7fsC3sMMDZXFejqRsDwLuLckWi4hBmhH7lrbwub-S95ke9PHwFo2lgPGQvUEO1"
         "0r7fsC3sMMDZXFejqRsDwLuLckWi4hBmhH7lrbwub-Q3vlFCILLvPldlH23WjSpd"
         "0r7fsC3sMMDZXFejqRsDwLuLckWi4hBmhH7lrbwub-Q5rjIrWyRu7e5siFJi5ODx"
         "0r7fsC3sMMDZXFejqRsDwLuLckWi4hBmhH7lrbwub-RmHxVJZ0y-IHTyY60dGkoH"
         "0r7fsC3sMMDZXFejqRsDwLuLckWi4hBmhH7lrbwub-Q9bz-abRslyvVu9cQYmjxk"
         "0r7fsC3sMMDZXFejqRsDwLuLckWi4hBmhH7lrbwub-QYgjMsoC4aasGgHTKetviI"
         "0r7fsC3sMMDZXFejqRsDwLuLckWi4hBmhH7lrbwub-Tm3ja7Sow6U3KNREl70i_K"
         "0r7fsC3sMMDZXFejqRsDwLuLckWi4hBmhH7lrbwub-RbZ2otm7bS-E1-uvoCVfjU"
         "0r7fsC3sMMDZXFejqRsDwLuLckWi4hBmhH7lrbwub-TkgDLECbuRcyBd8aia2g7b"
         "0r7fsC3sMMDZXFejqRsDwLuLckWi4hBmhH7lrbwub-RuLJw5e8O85D3juBvGOruP"
         )

# FUNCAO PARA APRESENTAR COMO DEVE SER UTILIZADO O SCRIPT
como_usar() {
  echo "Uso: $0 <NOME_DA_VARIAVEL>"
  echo "Exemplo: $0 ZENVIA_CHAT_PORTAL-ADMIN"
}

# VERIFICA SE O PRODUTO FOI INFORMADO
if [ $# -lt 1 ]; then
  echo "Erro: Nenhum produto foi informado."
  como_usar
  exit 1
fi

# VARIAVEL INFORMADA NA CHAMADA DO SCRIPT
VARIAVEL_INPUT=$1

# VARIAVEL PARA ARMAZENAR O VALOR CORRESPONDENTE A VARIAVEL INFORMADA
VALOR_ENCONTRADO=""

# Procurar o valor correspondente à variável fornecida
for i in "${!NOMES[@]}"; do
  if [ "${NOMES[$i]}" == "$VARIAVEL_INPUT" ]; then
    VALOR_ENCONTRADO="${VALORES[$i]}"
    break
  fi
done

# VERIFICA SE A VARIAVEL INFORMADA FOI ENCONTRADA NO ARRAY E REALIZA A CONSULTA NO STATUS PAGE ZENVIA
if [ -n "$VALOR_ENCONTRADO" ]; then
  URL="https://status.zenvia.com/component/$VALOR_ENCONTRADO"
  echo "URL a ser consultada: $URL"
  
# CONSULTA A PAGINA DA ZENVIA PARA CAPTURAR A DISPONIBILIDADE DO SERVIÇO
  STATUS=$(curl -s "$URL" | grep '<div data-i18n="incident.status.' | sed -n 's/.*data-i18n="\([^"]*\)".*/\1/p')
 
# HABILITE APENAS PARA TESTAR A FUNCIONALIDADE DO SCRIPT 
  ## STATUS="incident.status.6"  # Ao habilitar será possivel testar uma das 6 saidas de status dos serviços
  ## echo "STATUS = $STATUS"     # Ao habilitar é possivel ver o status capturado na variavel
  
  case "$STATUS" in
    "incident.status.1") echo "Operational" ;;            ## Ambiente Operacional
    "incident.status.2") echo "Informational" ;;          ## Ambiente Operacional - Alerta SEVERIDADE 2
    "incident.status.3") echo "Under Maintenance" ;;      ## Manutuação Programada - Alerta SEVERIDADE 3
    "incident.status.4") echo "Degraded Performance" ;;   ## Desempenho Degradado - Alerta SEVERIDADE 4
    "incident.status.5") echo "Partial Outage" ;;         ## Falha Parcial - Incidente SEVERIDADE 3
    "incident.status.6") echo "Major Outage" ;;           ## Indisponibilidade Total - Incidente SEVERIDADE 4
    *) echo "Status desconhecido" ;;
  esac
  # CONSULTA A STATUS PAGE DA ZENVIA PARA CAPTURAR O RESPONSE TIME DO SERVIÇO EM MILISSEGUNDOS
  curl -s "$URL" | grep "global.time.units.milliseconds" | sed -E 's/.*class="fs-lg mb-2">([0-9]+).*/\1/' 
else
  echo "A variável $VARIAVEL_INPUT não existe."
fi
