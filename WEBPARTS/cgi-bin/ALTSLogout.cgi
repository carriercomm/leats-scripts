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

	my $ret=system("/ALTS/ALTSLogout 1>/dev/null 2>&1");
	chomp($ret);


	if ($ret eq "0") { 
		print "LOGOUT SUCCESSFUL! Redirect to Login Page...";
		print "<META HTTP-EQUIV=refresh CONTENT=\"0;URL=/cgi-bin/ALTSLogin.cgi\">\n";
	}
	else { 
		print "LOGOUT UNSUCCESSFUL!"; 
	}

exit;
