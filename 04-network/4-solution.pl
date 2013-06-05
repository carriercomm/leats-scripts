#!/usr/bin/perl

use strict;
use warnings;
use Sys::Virt;
use Term::ANSIColor;
use Net::OpenSSH;
use MIME::Base64;


my $Command="
cat /etc/sysconfig/network-scripts/ifcfg-eth1 | grep -v ONBOOT > /tmp/245441.txt; cat /tmp/245441.txt > /etc/sysconfig/network-scripts/ifcfg-eth1
echo 'IPADDR2=1.1.5.5
NETMASK2=255.255.0.0
ONBOOT='yes'
' >> /etc/sysconfig/network-scripts/ifcfg-eth1;
service network restart;";


sub ssh_connect() {
        open my $stderr_fh, '>', '/dev/null';
        my $ssh = Net::OpenSSH->new("server", key_path=>"/scripts/ssh-key/id_rsa", default_stderr_fh => $stderr_fh);
        $ssh->error and ( print "Couldn't establish SSH connection: ". $ssh->error);
        return $ssh;
}

       my $ssh=ssh_connect();
       my $output=$ssh->capture("$Command");
       print "output = $output";

