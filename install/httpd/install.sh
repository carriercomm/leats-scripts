#!/bin/bash

#####
# Copy httpd config
dir=`dirname $0`
target="/etc/httpd/conf/httpd.conf"
rpm -qa |grep -q httpd-2
ret=$?
if [ $ret -eq 0 ]; then
	if [ -e $target ]; then
		cp -f "$dir/httpd.conf" $target
		ret=$?
		if [ $ret -eq 0 ] ; then
			service httpd restart >/dev/null 2>&1
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
