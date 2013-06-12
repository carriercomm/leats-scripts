#!/usr/bin/perl

use strict;
use warnings;
use Sys::Virt;
use Term::ANSIColor;
use Net::OpenSSH;
use MIME::Base64;


my $Command="mkdir -p /mnt/dir1/dir2/dir3/dir4/;
mv /mnt/files/2.alert_catp.log /mnt/dir1/dir2/dir3/dir4/2.alert_catp.log;
chgrp group01 /mnt/dir1/dir2/dir3/dir4/2.alert_catp.log;
chown jesse /mnt/dir1/dir2/dir3/dir4/2.alert_catp.log;
chmod 460 /mnt/dir1/dir2/dir3/dir4/2.alert_catp.log;";


sub ssh_connect() {
        open my $stderr_fh, '>', '/dev/null';
        my $ssh = Net::OpenSSH->new("server", key_path=>"/ALTS/SECURITY/id_rsa", default_stderr_fh => $stderr_fh);
        $ssh->error and ( print "Couldn't establish SSH connection: ". $ssh->error);
        return $ssh;
}

       my $ssh=ssh_connect();
       my $output=$ssh->capture("$Command");
       print "output = $output";

