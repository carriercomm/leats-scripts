#!/usr/bin/perl

use strict;
use warnings;
use Sys::Virt;
use Term::ANSIColor;
use Net::OpenSSH;
use MIME::Base64;


my $Command="(echo 'n'; echo 'p'; echo '1'; echo ''; echo '+10M';echo 'n'; echo 'p'; echo '2'; echo ''; echo '+20M';echo 'n'; echo 'p'; echo '3'; echo ''; echo '+30M';echo 'n'; echo 'e'; echo ''; echo '';echo 'n'; echo ''; echo '+40M'; echo 'n'; echo ''; echo '+50M';echo 'w') | fdisk /dev/vdb; 
partx -va /dev/vdb;
mkfs.ext2 /dev/vdb1;
mkfs.ext3 /dev/vdb2;
mkfs.ext3 /dev/vdb3;
mkfs.ext4 /dev/vdb5;
mkfs.ext4 /dev/vdb6;
mkdir /tmp/test1; mkdir /tmp/test2; mkdir /tmp/test3; mkdir /tmp/test4; mkdir /tmp/test5;
mount /dev/vdb1 /tmp/test1;
mount /dev/vdb2 /tmp/test2;
mount /dev/vdb3 /tmp/test3;
mount /dev/vdb5 /tmp/test4;
mount /dev/vdb6 /tmp/test5;
";


sub ssh_connect() {
        open my $stderr_fh, '>', '/dev/null';
        my $ssh = Net::OpenSSH->new("server", key_path=>"/ALTS/SECURITY/id_rsa", default_stderr_fh => $stderr_fh);
        $ssh->error and ( print "Couldn't establish SSH connection: ". $ssh->error);
        return $ssh;
}

       my $ssh=ssh_connect();
       my $output=$ssh->capture("$Command");
       print "output = $output";

