#!/usr/bin/perl

use strict;
use warnings;
use Sys::Virt;
use Term::ANSIColor;
use Net::OpenSSH;
use MIME::Base64;


my $Command="sed 's/^hosts:.*\$/hosts:      files dns/g' /etc/nsswitch.conf > /tmp/test1232343.txt;  cat /tmp/test1232343.txt > /etc/nsswitch.conf; rm -rf /tmp/test1232343.txt;
echo 'nameserver 2.2.2.1' >> /etc/resolv.conf;
echo '1.1.1.1 test1machine' >> /etc/hosts;
cat /etc/sysconfig/network-scripts/ifcfg-eth1 | grep -v BOOTPROTO | grep -v ONBOOT > /tmp/245441.txt; cat /tmp/245441.txt > /etc/sysconfig/network-scripts/ifcfg-eth1
echo 'BOOTPROTO=static' >> /etc/sysconfig/network-scripts/ifcfg-eth1;
echo 'ONBOOT=yes' >> /etc/sysconfig/network-scripts/ifcfg-eth1;
echo 'IPADDR=1.1.1.88' >> /etc/sysconfig/network-scripts/ifcfg-eth1;
echo 'NETMASK=255.255.255.0' >> /etc/sysconfig/network-scripts/ifcfg-eth1;
echo 'IPADDR1=2.2.2.88' >> /etc/sysconfig/network-scripts/ifcfg-eth1;
echo 'NETMASK1=255.255.0.0' >> /etc/sysconfig/network-scripts/ifcfg-eth1;
service network restart;
route del default gw 1.1.1.1 eth0;
route add default gw 2.2.2.1 eth1;
route -n;
";


sub ssh_connect() {
        open my $stderr_fh, '>', '/dev/null';
        my $ssh = Net::OpenSSH->new("server", key_path=>"/scripts/ssh-key/id_rsa", default_stderr_fh => $stderr_fh);
        $ssh->error and ( print "Couldn't establish SSH connection: ". $ssh->error);
        return $ssh;
}

       my $ssh=ssh_connect();
       my $output=$ssh->capture("$Command");
       print "output = $output";

