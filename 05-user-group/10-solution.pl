#!/usr/bin/perl

use strict;
use warnings;
use Sys::Virt;
use Term::ANSIColor;
use Net::OpenSSH;
use MIME::Base64;


my $Command="groupadd -g 789 tmpadmins;
useradd -e '2020-02-17' helen;
useradd -G tmpadmins paul;
useradd -g TMPgroup001 robert;
(echo '123paul'; echo '123paul') | passwd paul;
chage -W 12 helen;
chage -m 8 robert
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

