#!/usr/bin/perl

use strict;
use warnings;
use Sys::Virt;
use Term::ANSIColor;
use Net::OpenSSH;
use MIME::Base64;


my $Command="echo 'william' >> /etc/cron.deny; echo \"25 5 * * * /bin/echo 'crontab exam test'\" > /tmp/crontabtenpfile.txt; crontab -u tihamer /tmp/crontabtenpfile.txt; echo \"16 * * * * 'whoami'\" > /tmp/crontabtenpfile.txt; crontab -u rudolf /tmp/crontabtenpfile.txt; rm -rf /tmp/crontabtenpfile.txt;";


sub ssh_connect() {
        open my $stderr_fh, '>', '/dev/null';
        my $ssh = Net::OpenSSH->new("server", key_path=>"/ALTS/SECURITY/id_rsa", default_stderr_fh => $stderr_fh);
        $ssh->error and ( print "Couldn't establish SSH connection: ". $ssh->error);
        return $ssh;
}

       my $ssh=ssh_connect();
       my $output=$ssh->capture("$Command");
       print "output = $output";

