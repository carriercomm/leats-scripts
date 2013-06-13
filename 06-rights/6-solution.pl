#!/usr/bin/perl

use strict;
use warnings;
use Sys::Virt;
use Term::ANSIColor;
use Net::OpenSSH;
use MIME::Base64;


my $Command="cp /etc/issue /tmp/test; cp /etc/crontab /tmp/test2; chown tihamer:group1 /tmp/test; ln -s /etc/group /tmp/testsymlink; mkdir /tmp/testdir; chgrp group1 /tmp/testdir; chmod g+s /tmp/testdir; chmod 770 /tmp/test; chmod 770 /tmp/test2; chgrp group1 /tmp/test2; chmod u+s /tmp/test2";


sub ssh_connect() {
        open my $stderr_fh, '>', '/dev/null';
        my $ssh = Net::OpenSSH->new("server", key_path=>"/ALTS/SECURITY/id_rsa", default_stderr_fh => $stderr_fh);
        $ssh->error and ( print "Couldn't establish SSH connection: ". $ssh->error);
        return $ssh;
}

       my $ssh=ssh_connect();
       my $output=$ssh->capture("$Command");
       print "output = $output";

