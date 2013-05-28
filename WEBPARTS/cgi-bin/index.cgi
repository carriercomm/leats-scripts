#!/usr/bin/perl
##
## CGI script to print out the relevant environment variables.
## It's just one big print statement, but note the use of the
## associative %ENV array to access the environment variables.
##
#use lib '/scripts/common_perl/';
#use Framework qw(&cryptText2File &decryptFile $student_file);

use strict;
use warnings;

#my $result_file="/ALTS/RESULTS/ACTUAL/02-physical_disk-1";
#my $result_file="/ALTS/RESULTS/ACTUAL/05-user-group-1";

print "Content-type: text/html\n\n";

print "
<!DOCTYPE html PUBLIC \"-//W3C//DTD XHTML 1.0 Transitional//EN\" \"http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd\">
<html xmlns=\"http://www.w3.org/1999/xhtml\"><head>
<meta http-equiv=\"Content-Type\" content=\"text/html; charset=UTF-8\">
<title>ALTS</title>";

if (-f "/var/www/cgi-bin/Result")
{
	system("/var/www/cgi-bin/Result 2>/dev/null");
}
else
{
	print "<META HTTP-EQUIV=refresh CONTENT=\"0;URL=/cgi-bin/ALTSLogin.cgi\">\n"; exit 1;
}

exit;
