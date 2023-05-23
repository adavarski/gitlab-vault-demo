#!/bin/sh

case $1 in

  AWS_KEY)
    vault kv get -field=AWS_KEY local/esdata
    ;;

  AWS_PASS)
    vault kv get -field=AWS_PASS local/esdata
    ;;

  ENCR_KEY)
    vault kv get -field=ENCR_KEY local/esdata
    ;;

  SAT_ID)                               
    vault kv get -field=SAT_ID local/esdata       
    ;; 

  ALL)
    vault kv get -field=AWS_KEY local/esdata
    echo ""
    vault kv get -field=AWS_PASS local/esdata
    echo ""
    vault kv get -field=ENCR_KEY local/esdata
    echo ""
    vault kv get -field=SAT_ID local/esdata
    echo ""
    ;;
esac


