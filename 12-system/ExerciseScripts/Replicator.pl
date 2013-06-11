#!/usr/bin/perl
use strict;

my $pid = fork();
if($pid) {
#exit the parent process
	exit(0);
}else {
# the child process
# set a new process group

	setpgrp;
	while(1) {		
		my $S=10+int(rand(10));
		sleep($S);
		my $P=`ps -ef | grep Replicator.pl | grep -v grep | wc -l`;
		chomp($P);
		if ($P<50)
		{
			my $pid2 = fork();	
		}
	}
}
