#!/usr/bin/perl

use strict;
use warnings;
use Sys::Virt;
use Term::ANSIColor;
use Net::OpenSSH;
use MIME::Base64;


my $Command="umount  /dev/vdb1; (echo 'd'; echo 'n'; echo 'p'; echo '1'; echo ''; echo '+180M'; echo 'w') | fdisk /dev/vdb;partx -va /dev/vdb;e2fsck -f -y /dev/vdb1; resize2fs /dev/vdb1;echo '/dev/vdb1       /mnt/mulder                ext3    defaults,rw,acl 0 0' >> /etc/fstab; mount -av";

sub ssh_connect() {
        open my $stderr_fh, '>', '/dev/null';
        my $ssh = Net::OpenSSH->new("server", key_path=>"/ALTS/SECURITY/id_rsa", default_stderr_fh => $stderr_fh);
        $ssh->error and ( print "Couldn't establish SSH connection: ". $ssh->error);
        return $ssh;
}

       my $ssh=ssh_connect();
       my $output=$ssh->capture("$Command");
       print "output = $output";

