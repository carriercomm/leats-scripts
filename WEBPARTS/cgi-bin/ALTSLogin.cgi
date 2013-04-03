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

$ENV{'REQUEST_METHOD'} =~ tr/a-z/A-Z/;
if ($ENV{'REQUEST_METHOD'} eq "GET" )
{
print "Content-type: text/html\n\n";

	print "<!DOCTYPE html PUBLIC \"-//W3C//DTD XHTML 1.0 Transitional//EN\" \"http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd\">
		<html xmlns=\"http://www.w3.org/1999/xhtml\"><head>
		<meta http-equiv=\"Content-Type\" content=\"text/html; charset=UTF-8\">
		<title>ALTS Result</title>
		";

	print "<style type=\"text/css\">
		<!--
		body {
			margin-left: 15%;
			margin-right: 15%;
			margin-top: 4%;
			margin-bottom: 0%;
			font-family: Verdana, Geneva, sans-serif;
			font-size: 16px;
			text-align: left;
			font-style: normal;
			line-height: normal;
			font-weight: normal;
			font-variant: normal;
			text-transform: none;
			vertical-align: middle;
			white-space: normal;
		}
	-->
		</style></head>";


	print"
		<table border=\"0\" cellpadding=\"5\" cellspacing=\"5\">
		<tbody>
		<tr>
		<th colspan=\"7\" scope=\"row\"><img src=\"/ALTSicons/ALTSLOGO.jpg\"></th>
		</tr>
		";


###############################################################################
####################### THE STUDENT LOGGED IN #################################

	my $F=decryptFile("$student_file");
#print "F= $F\n\n";

	my @A = $F =~ m/<STUDENT>(.*)<\/STUDENT><ALTSPASSWORD>(.*)<\/ALTSPASSWORD>/;
	my $USER = $A[0];
	my $PW = $A[1];


	print "</tbody>
		</table>
		</th>";

	print ' <tr>
		<td>
		<form action="/cgi-bin/ALTSLogin.cgi" method="post">
		<table>
		<tr><td>Student name:<td/><td><input type="text" name="student" size="20" /></td></tr>
		<tr><td>Password:<td/><td><input type="password" name="pass" size="20" /></td></tr>
		<tr><td>Exercise ID:<td/><td><input type="text" name="exercise" size="20" /></td></tr>
		<tr><td></td><td/><td><input type="submit" name="submit" value="Login"/><td></tr>
		</table>
		</form>
		</td>
		</tr>';

	print "</body>
		</html>\n";



}
else
{
	print "Content-type: text/html\n\n";
	my $buffer;
	read(STDIN, $buffer, $ENV{'CONTENT_LENGTH'});
#print "BUFFER= $buffer";

	my @A=$buffer=~m/student=(.*)&pass=(.*)&exercise=(.*)&.*/;
	my $ret=system("(echo \"$A[0]\"; echo \"$A[1]\"; echo \"$A[1]\";echo \"$A[2]\") | /ALTS/ALTSLogin 1>/dev/null 2>&1");
	chomp($ret);


	if ($ret eq "0") { 
		print "LOGIN SUCCESSFUL! Redirect to Home Page...";
		print "<META HTTP-EQUIV=refresh CONTENT=\"0;URL=/cgi-bin/index.cgi\">\n";
	}
	else { 
		print "LOGIN UNSUCCESSFUL!"; 
	}
}
#system("/var/www/cgi-bin/Result 2>&1");
#system("/var/www/cgi-bin/02-physical_disk-1-grade");

exit;
