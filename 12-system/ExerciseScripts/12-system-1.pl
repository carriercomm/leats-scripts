#!/usr/bin/perl
use strict;

my $pid = fork();
print $pid,"\n";
if($pid) {
#exit the parent process
	exit(0);
}else {
#the child process
# set a new process group

	setpgrp;
	print "Daemon is running...";
	while(1) {
		sleep(30);
#	print ".";
	}
}
