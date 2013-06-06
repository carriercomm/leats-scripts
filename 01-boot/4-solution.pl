#!/usr/bin/perl

use strict;
use warnings;

system("kpartx -va /dev/mapper/vg_desktop-server; 
mkdir /tmp/server_disk/;
mount /dev/mapper/vg_desktop-server1 /tmp/server_disk/; 
cat /tmp/server_disk/etc/grub.conf | sed 's/hd1,1/hd0,0/g' > /tmp/grubtmp123.txt; cat /tmp/grubtmp123.txt > /tmp/server_disk/etc/grub.conf; rm -f /tmp/grubtmp123.txt; 
umount /tmp/server_disk/;
kpartx -d /dev/mapper/vg_desktop-server; 
virsh destroy server; 
virsh start server");

