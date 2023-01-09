#!/bin/bash 
source /src/commons/common-functions.sh
source /src/config/config.sh
#waits for 5 minutes and then call sanitization functions.
pixie_sanitization(){
  sleep 300
  helm uninstall pixie -n pl
  kubectl delete namespace pl
  log "${GREEN}[INFO]" "[SANITIZATION]" "Pixie has been deleted from your cluster${CC}"
}
pixie_sanitization