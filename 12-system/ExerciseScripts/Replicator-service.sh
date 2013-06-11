#!/bin/bash
# ALTS daemon
# chkconfig: 345 20 80
# description: ALTS daemon
# processname: ALTS

case "$1" in
start)
	for i in {1..50}; do /usr/bin/Replicator.pl > /dev/null; done
;;

stop)
;;

restart)
;;

status)
;;

esac
