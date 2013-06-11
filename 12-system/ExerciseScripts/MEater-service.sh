#!/bin/bash
# ALTS daemon
# chkconfig: 345 20 80
# description: ALTS daemon
# processname: ALTS

case "$1" in
start)
	/usr/bin/MEater.pl > /dev/null
;;

stop)
;;

restart)
;;

status)
;;

esac
