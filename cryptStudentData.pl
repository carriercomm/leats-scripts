#!/usr/bin/perl


#
# ARG1: User ID
#

use lib '/scripts/common_perl/';
use Framework qw(&cryptText2File);

if ((scalar @ARGV) < 2) { print "\n\nYou type no user name or password!\n\n"; die; }
else {	
	my $fn; open($fn,">","/ALTS/User.alts"); print $fn "";
	cryptText2File("<STUDENT>$ARGV[0]</STUDENT><SECRETUSERID>blu3_sky_1234</SECRETUSERID>","/ALTS/User.alts"); 

     }

exit 0;
