#!/usr/bin/perl
use strict;

my $output = `ps -eo pcpu,pid,user,args | grep CStress.pl | grep -v grep`;
my @A = $output =~ m/(\S+)\s+.*/;
my $USEAGE = int($A[0]);
my $M=4000000;

while (1)
{
        my $output = `ps -eo pcpu,pid,user,args | grep CStress.pl | grep -v grep`;
        my @A = $output =~ m/(\S+)\s+.*/;
	$USEAGE = int($A[0]);

	if ($USEAGE<85)
	{
		$M=$M*1.001;
		my $j=0; $j++; $j *= 1.1 for (1..$M);
	}
	else
	{
		$M=$M/1.001;
	}
}
