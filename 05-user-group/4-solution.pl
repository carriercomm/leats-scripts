#!/usr/bin/perl

use strict;
use warnings;
use Sys::Virt;
use Term::ANSIColor;
use Net::OpenSSH;
use MIME::Base64;


my $Command="groupadd -g 8881 team1; 
useradd -u 766 daniel; 
(echo 'secretpassword123'; echo 'secretpassword123') | passwd daniel;";


sub ssh_connect() {
        open my $stderr_fh, '>', '/dev/null';
        my $ssh = Net::OpenSSH->new("server", key_path=>"/scripts/ssh-key/id_rsa", default_stderr_fh => $stderr_fh);
        $ssh->error and ( print "Couldn't establish SSH connection: ". $ssh->error);
        return $ssh;
}

       my $ssh=ssh_connect();
       my $output=$ssh->capture("$Command");
       print "output = $output";

