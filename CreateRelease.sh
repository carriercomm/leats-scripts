#!/bin/bash

echo "Creating Release.."
D=`date +%Y%m%d`;
echo "DATE: $D"

tar -czvf /ALTS_${D}.tgz /var/www/cgi-bin /var/www/html/ALTSicons /var/www/html/authorized_keys /etc/motd /etc/httpd/conf/httpd.conf /ALTS/activate /ALTS/ALTSLogin /ALTS/ALTSLogout /ALTS/EXERCISES /ALTS/lib /ALTS/REINSTALL /ALTS/RESET /ALTS/SECURITY/ALTSkey /ALTS/SECURITY/id_rsa /ALTS/Settings.alts /var/www/html/ks.cfg /var/www/html/index.html
