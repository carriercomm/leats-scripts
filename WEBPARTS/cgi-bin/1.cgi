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

my $result_file="/ALTS/RESULTS/ACTUAL/02-physical_disk-1";

print "Content-type: text/html\n\n";

print "
<!DOCTYPE html PUBLIC \"-//W3C//DTD XHTML 1.0 Transitional//EN\" \"http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd\">
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
.MainTABLE {
        background-color: #0C5AA5;
}
.MainTABLE_simple {
        background-color: #C6D9FF;
        font-family: Verdana, Geneva, sans-serif;
        font-weight: normal;
        font-variant: normal;
        text-align: left;
}
.MainTABLE_nonbold {
        font-weight: normal;
        text-align: left;
}
body p {
        text-align: left;
        font-style: normal;
        line-height: normal;
        font-weight: normal;
        font-variant: normal;
}
.EmptyLine {
        letter-spacing: normal;
        word-spacing: normal;
        white-space: normal;
        border-top-style: none;
        border-top-color: #FFF;
        border-bottom-style: groove;
        border-bottom-color: #06C;
}
.Student {
        color: #0C5AA5;
}
.Student {
        color: #FFF;
        background-color: #0C5AA5;
        font-style: normal;
        line-height: normal;
        font-weight: normal;
        font-variant: normal;
        text-transform: none;
}
-->
</style></head>";

print"
    <table border=\"0\" cellpadding=\"5\" cellspacing=\"5\">
  <tbody><tr>
    <th colspan=\"7\" scope=\"row\"><img src=\"http://1.1.1.1/ALTSicons/ALTSLogo.jpg\"></th>
  </tr>

";


###############################################################################
####################### THE STUDENT LOGGED IN #################################

my $F=decryptFile("$student_file");
#print "F= $F\n\n";

my @A = $F =~ m/<STUDENT>(.*)<\/STUDENT><ALTSPASSWORD>(.*)<\/ALTSPASSWORD>/;
my $USER = $A[0];
my $PW = $A[1];

###########################################################
##### STUDENT AND EXERCISE INFOS ###########################


        my $Date = "---";

	my @W = $result_file =~ m/\/ALTS\/RESULTS\/ACTUAL\/(.+)-(\d+)/sg;

        my $Problem = "$W[1]";
        my $Topic = "$W[0]";
        my $Description="\n\n$USER hasn't done this exercise yet!\n\n";
        my $Tasknumber="--";
        my $Tasksuccessful="-";
	my $Finalresult="-";
	my @T=();


if (-f $result_file) { 

	my $FN=decryptFile("$result_file");

#print "RESULT=\n\n$FN\n\n";

	my @R = $FN =~ m/<STUDENT>(.*)<\/STUDENT><ALTSPASSWORD>(.*)<\/ALTSPASSWORD>/;
	my $Student = $R[0];
	my $Password = $R[1];
#print "\nSTUDENT= $Student\n";
#print "Password= $Password\n";

	if (($Student ne "$USER") || ( $Password ne $PW )) {
		print "\n\n<br/><br/>The student, who is logged ($USER) in is not equals with the owner of the result ($Student).<br/>Or is it possible that the ALTS password is incorrect!<br/><br/>Please login with command ALTSLogin!\n";
		exit 1;
	}

#<DATE>2013/03/21 12:18:13</DATE><TOPIC>Users and groups</TOPIC><PROBLEM>1</PROBLEM><DESCRIPTION>- create the following users: john, mary and thomas
#- create a group named tadmins with GID 885
#- john's UID is 2342, his home directory is /home/john.
#- mary's UID is 5556 and her default shell is /bin/bash.
#- thomas should not have access to any shell
#- the users john and mary are members of the group tadmins.
#- thomas should not be in the group tadmins.
#- change all users password to kuka002
#- john's account will expire on 2025-12-12</DESCRIPTION>


	my @D = $FN =~ m/<DATE>(.*)<\/DATE>/;
	$Date = $D[0];

	my @P = $FN =~ m/<PROBLEM>(.*)<\/PROBLEM>/;
	$Problem = $P[0];

	my @TP = $FN =~ m/<TOPIC>(.*)<\/TOPIC>/;
	$Topic = $TP[0];

	my @DES = $FN =~ m/<DESCRIPTION>(.*)<\/DESCRIPTION>/s;

	$Description=$DES[0];
	$Description =~ s/\n/<\/p><p>/g;
	$Description="<p>$Description";

	@T = $FN =~ m/<TASK>(.*)<\/TASK>/g;

#<TASKNUMBER>17</TASKNUMBER><TASKSUCCESSFUL>5</TASKSUCCESSFUL><FINALRESULT>FAILED</FINALRESULT>

	my @RES = $FN =~ m/<TASKNUMBER>(.*)<\/TASKNUMBER><TASKSUCCESSFUL>(.*)<\/TASKSUCCESSFUL><FINALRESULT>(.*)<\/FINALRESULT>/;

	$Tasknumber=$RES[0];
	$Tasksuccessful=$RES[1];
	$Finalresult=$RES[2];
}

###############################################################################

print "
<tr>
<th colspan=\"7\" class=\"MainTABLE\" scope=\"row\">&nbsp;</th>
</tr>
<tr>
<th colspan=\"7\" scope=\"row\">&nbsp;</th>
</tr>
<tr>
<th width=\"61\">&nbsp;</th>
<th width=\"56\">&nbsp;</th>
<th width=\"300\">
<table align=\"left\" border=\"0\" cellspacing=\"5\">
<tbody>
<tr>
<td class=\"Student\">Student</td>
<td class=\"MainTABLE_nonbold\" width=\"193\">$USER</td>
</tr>
<tr>
<td class=\"MainTABLE_nonbold\">&nbsp;</td>
<td class=\"MainTABLE_nonbold\">&nbsp;</td>
</tr>
<tr>
<td class=\"MainTABLE_simple\">Exercise</td>
<td class=\"MainTABLE_nonbold\">$Topic $Problem</td>
</tr>
<tr>
<td class=\"MainTABLE_simple\">Date</td>
<td class=\"MainTABLE_nonbold\">$Date</td>
</tr>
<tr>
<td class=\"MainTABLE_simple\">Result</td>
<td class=\"MainTABLE_nonbold\">$Tasksuccessful/$Tasknumber</td>
</tr>
</tbody>
</table></th>";

if ($Tasksuccessful eq $Tasknumber) 
{
	print "    <th width=\"286\"><img src=\"http://1.1.1.1/ALTSicons/EXAMPASSED.jpg\" alt=\"PASSED\" height=\"106\" width=\"184\"></th>";	
}
else
{
	print "    <th width=\"286\"><img src=\"http://1.1.1.1/ALTSicons/EXAMFAILED.jpg\" alt=\"FAILED\" height=\"106\" width=\"184\"></th>";
}


print "
<th width=\"18\"><p>&nbsp;</p></th>
<th width=\"4\"></th>
</tr>";


###############################################################################

print "
<tr>
<th colspan=\"7\" class=\"EmptyLine\" scope=\"row\" height=\"36\"></th>
</tr>";

#  __________________________________________________________________________

print "
<tr>
<th colspan=\"7\" scope=\"row\">
$Description
</th>
</tr>";


#  ____________________________________________________________________________
#  ____________________________________________________________________________

print"
<tr>
<th colspan=\"7\" class=\"EmptyLine\" scope=\"row\"></th>
</tr>
<tr>
<th colspan=\"7\" class=\"EmptyLine\" scope=\"row\"></th>
</tr>
";


################################################################################

if (-f $result_file) {

print "
<tr><th scope=\"row\" width=\"61\"></th>
<th scope=\"row\" width=\"56\">&nbsp;</th>
<th colspan=\"2\" scope=\"row\" height=\"34\"> <br><table border=\"0\" cellpadding=\"0\" cellspacing=\"0\" height=\"212\" width=\"503\">
<tbody>";

foreach my $Task (@T)
{
	my @TT=$Task=~m/<TASKDESC>(.*)<\/TASKDESC><RESULT>(.*)<\/RESULT>/;
#       print "\nTASK: $TT[0]\n";
#       print "\nRESULT: $TT[1]\n\n";
#       print "\n<tr><td>$TT[0]</td>";
	print "<td class=\"MainTABLE_nonbold\">$TT[0]</td>";
	if (($TT[1]) eq "[ PASS ]") {
		print "<td><img src=\"http://1.1.1.1/ALTSicons/PASSED.jpg\" alt=\"OK\" height=\"34\" width=\"34\"></td>";
	}
	else
	{
		print "<td><img src=\"http://1.1.1.1/ALTSicons/FAILED.jpg\" alt=\"NOTOK\" height=\"34\" width=\"34\"></td>";
	}
	print "</tr>";
}


print "</tbody></table></th>
</tr>
<tr>
<th colspan=\"7\" scope=\"row\" height=\"36\">&nbsp;</th>
</tr>
<tr>
<th colspan=\"7\" class=\"MainTABLE\" scope=\"row\">&nbsp;</th>
</tr>
</tbody></table>
";



}

#system("/var/www/cgi-bin/Result 2>&1");
#system("/var/www/cgi-bin/02-physical_disk-1-grade");

print "</body>
</html>\n";

exit;
