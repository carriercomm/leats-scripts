#!/usr/bin/perl

use strict;
use warnings;
use Sys::Virt;
use Term::ANSIColor;
use Net::OpenSSH;
use MIME::Base64;


my $Command="(echo 'd'; echo 'n'; echo 'p'; echo '1'; echo ''; echo '+120M'; echo 'w') | fdisk /dev/vdb;partx -va /dev/vdb; 
mkfs.ext4 /dev/vdb1; 
mkdir -p /mnt/test1; 
mount /dev/vdb1 /mnt/test1";

sub ssh_connect() {
        open my $stderr_fh, '>', '/dev/null';
        my $ssh = Net::OpenSSH->new("server", key_path=>"/ALTS/SECURITY/id_rsa", default_stderr_fh => $stderr_fh);
        $ssh->error and ( print "Couldn't establish SSH connection: ". $ssh->error);
        return $ssh;
}

       my $ssh=ssh_connect();
       my $output=$ssh->capture("$Command");
       print "output = $output";

