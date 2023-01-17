#!/bin/bash 
source /src/commons/common-functions.sh
source /src/config/config.sh
#waits for 5 minutes and then call rollback functions.
pixie_rollback(){
  helm uninstall pixie -n pl
  kubectl delete namespace pl
  log "${GREEN}[INFO]" "[ROLLBACK]" "Pixie has been deleted from your cluster${CC}"
}
pixie_rollback
