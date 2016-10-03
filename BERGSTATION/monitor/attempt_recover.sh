#!/bin/bash
#
# Get password and IP from a file outside repository control
echo "[$(date)] $(basename $0): Started"
echo "INFO: Loading sensitive pasword for router access"
set -e; source /var/www/.sensitive; set +e  

echo "SKIPPING: Restarting WLAN on router... Vigor router not present anymore"
##TODO: check output and search for matching string to detect if telnet session
## worked or not
#(sleep 1; echo $ROUTER_PW; echo "wl act off"; sleep 5; echo "wl act on"; sleep 2; echo exit; sleep 1)|telnet $ROUTER_IP
#RET=$?
#test "$RET" -ne 0 && echo "ERROR: return code from telnet=$RET"

echo "INFO: Restarting local socket daemon..."
/etc/init.d/wetterstation stop
sleep 2
/etc/init.d/wetterstation start
echo "[$(date)] $(basename $0): Finished"

