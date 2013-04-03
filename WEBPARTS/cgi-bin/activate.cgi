#!/usr/bin/perl
##
## CGI script to print out the relevant environment variables.
## It's just one big print statement, but note the use of the
## associative %ENV array to access the environment variables.
##
use lib '/scripts/common_perl/';
use Framework qw(&cryptText2File &decryptFile $student_file);

use strict;
use warnings;

print "Content-type: text/html\n\n";

my $E=$ENV{'QUERY_STRING'};

my @A = $E =~ m/(\d+-\D+)-(\d+)/;
if (($A[0] ne "") && ($A[1] ne ""))
{
my $Topic=$A[0];
my $Problem=$A[1];
if (-f "/var/www/cgi-bin/$Topic/$Problem-activator")
{

system("(echo $Topic-$Problem) | /ALTS/activate 1>/dev/null 2>&1");
}
}
print "<META HTTP-EQUIV=refresh CONTENT=\"0;URL=/cgi-bin/index.cgi\">\n";

exit;
