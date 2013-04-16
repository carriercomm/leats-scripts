#!/usr/bin/perl

use strict;
use warnings;
use Sys::Virt;
use Term::ANSIColor;
use Net::OpenSSH;
use MIME::Base64;


my $Command="(echo 'n'; echo 'p'; echo '1'; echo ''; echo '+100M'; echo 'w') | fdisk /dev/vdb; partx -va /dev/vdb; mkfs.ext3 /dev/vdb1; mkdir /mnt/das; e2label /dev/vdb1 test1-label; echo 'LABEL=test1-label       /mnt/das                ext3    defaults,rw,acl 0 0' >> /etc/fstab; mount -av; (echo 'n'; echo 'p'; echo '2'; echo ''; echo '+50M'; echo 't'; echo '2'; echo '82'; echo 'w') | fdisk /dev/vdb; partx -va /dev/vdb; mkswap /dev/vdb2;  swapon /dev/vdb2; echo '/dev/vdb2               swap                    swap    defaults        0 0' >> /etc/fstab; mount -va";


sub ssh_connect() {
        open my $stderr_fh, '>', '/dev/null';
        my $ssh = Net::OpenSSH->new("server", key_path=>"/ALTS/SECURITY/id_rsa", default_stderr_fh => $stderr_fh);
        $ssh->error and ( print "Couldn't establish SSH connection: ". $ssh->error);
        return $ssh;
}

       my $ssh=ssh_connect();
       my $output=$ssh->capture("$Command");
       print "output = $output";

