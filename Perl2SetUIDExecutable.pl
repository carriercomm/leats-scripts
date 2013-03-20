#!/usr/bin/perl


if ((scalar @ARGV) < 2)
{
	print "\n\nUsing the script is the following:\n";
	print "1. argument: Your command you want to run as root\n";
	print "2. argument: Where you want to place the binary\n";
	print "\t E.g ./Perl2SetUIDExecutable '/leats-scripts/02-physical_disk/1.pl --grade' /var/www/cgi-bin/02-1\n\n";
	die; 
}

my $TmpCPath="/tmp/myCompiler.c";

my $Command=$ARGV[0];
my $Binary=$ARGV[1];

my $fn;
open($fn,">","$TmpCPath");


print $fn "#include <stdio.h>
#include <stdlib.h>
#include <sys/types.h>
#include <unistd.h>

int main()
{
   setuid( 0 );
   system( \"$Command\" );
   return 0;
}";

system ("gcc $TmpCPath -o $Binary");

close($fn);
