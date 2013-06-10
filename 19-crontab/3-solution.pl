#!/usr/bin/perl

use strict;
use warnings;
use Sys::Virt;
use Term::ANSIColor;
use Net::OpenSSH;
use MIME::Base64;


my $Command="echo \"5 1 * * 1   /bin/date\" > /tmp/crontabtenpfile.txt; 
crontab -u victoria /tmp/crontabtenpfile.txt;
rm -rf /tmp/crontabtenpfile.txt;";


sub ssh_connect() {
        open my $stderr_fh, '>', '/dev/null';
        my $ssh = Net::OpenSSH->new("server", key_path=>"/ALTS/SECURITY/id_rsa", default_stderr_fh => $stderr_fh);
        $ssh->error and ( print "Couldn't establish SSH connection: ". $ssh->error);
        return $ssh;
}

       my $ssh=ssh_connect();
       my $output=$ssh->capture("$Command");
       print "output = $output";

