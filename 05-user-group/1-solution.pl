#!/usr/bin/perl

use strict;
use warnings;
use Sys::Virt;
use Term::ANSIColor;
use Net::OpenSSH;
use MIME::Base64;


my $Command="groupadd -g 885 tadmins;
useradd john;
useradd mary;
useradd thomas;
usermod -u 2342 john;
usermod -d /home/john john;
usermod -u 5556 mary;
usermod -a /bin/bash;
usermod -s /sbin/nologin thomas;
usermod -aG tadmins john;
usermod -aG tadmins mary;
(echo 'kuka002'; echo 'kuka002') | passwd john;
(echo 'kuka002'; echo 'kuka002') | passwd mary;
(echo 'kuka002'; echo 'kuka002') | passwd thomas;
chage -E '2025-12-12' john;
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

