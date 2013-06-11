#!/bin/bash
# ALTS daemon
# chkconfig: 345 20 80
# description: ALTS daemon
# processname: ALTS

case "$1" in
start)
	/usr/bin/CZ.pl > /dev/null 2>&1 &
	/usr/bin/CZ.pl > /dev/null 2>&1 &
	/usr/bin/CZ.pl > /dev/null 2>&1 &
;;

stop)
;;

restart)
;;

status)
;;

esac
