#!/usr/bin/perl

use strict;
use warnings;
use Sys::Virt;
use Term::ANSIColor;
use Net::OpenSSH;
use MIME::Base64;


my $Command="groupadd tadmins; 
useradd -g tadmins chuck; 
useradd -s /bin/sh clare;
(echo 'startABC'; echo 'startABC') | passwd chuck;";


sub ssh_connect() {
        open my $stderr_fh, '>', '/dev/null';
        my $ssh = Net::OpenSSH->new("server", key_path=>"/scripts/ssh-key/id_rsa", default_stderr_fh => $stderr_fh);
        $ssh->error and ( print "Couldn't establish SSH connection: ". $ssh->error);
        return $ssh;
}

       my $ssh=ssh_connect();
       my $output=$ssh->capture("$Command");
       print "output = $output";

