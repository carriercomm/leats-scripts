#!/bin/bash

#####
# Copy bind config
dir=`dirname $0`
target="/etc/named.conf"
rpm -qa |grep -q bind-9
ret=$?
if [ $ret -eq 0 ]; then
	if [ -e $target ]; then
		cp -f "$dir/named.conf" $target
		ret=$?
		if [ $ret -eq 0 ] ; then
			service named restart >/dev/null 2>&1
			ret=$?
			if [ $ret -eq 0 ] ; then
				exit 0
			else
				exit 4
			fi
		else
			exit 3
		fi
	else 
		exit 2
	fi
else
	exit 1
fi
