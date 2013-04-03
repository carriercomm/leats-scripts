#!/usr/bin/perl

use strict;
use warnings;

my $E="";

if ((scalar @ARGV) == 0) { 
	print "Add exercise you want to activate (e.g. 05-user-group-1): ";
	$E=<STDIN>;
	chomp($E);
	print "";
}
else
{
	$E=$ARGV[0];
}

print "Activate $E...";

my @A = $E =~ m/(\d+-\D+)-(\d+)/;

if (($A[0] ne "") && ($A[1] ne ""))
{

	my $Topic=$A[0];
	my $Problem=$A[1];

	if (-f "/var/www/cgi-bin/$Topic/$Problem-activator") 
	{
		system("/var/www/cgi-bin/$Topic/$Problem-activator");
		exit 0;
	}
}
exit 1;



