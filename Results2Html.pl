#!/usr/bin/perl

use lib '/scripts/common_perl/';
use Framework qw(&cryptText2File &decryptFile $student_file);

use strict;
use warnings;

if ((scalar @ARGV) < 1)
{
        print "\n\nUsing of the script:\n";
        print "1. argument: Your result file you want to convert to HTML\n";
        print "\t E.g ./Results2Html /ALTS/leats-scripts/ALTS/RESULTS/Physicaldiskmanagement-1 \n\n";
        die;
}

my $result_file = $ARGV[0];

############################################################
#### THE STUDENT LOGGED IN #################################

my $F=decryptFile("$student_file");
#print "F= $F\n\n";

my @A = $F =~ m/<STUDENT>(.*)<\/STUDENT><ALTSPASSWORD>(.*)<\/ALTSPASSWORD>/;
my $USER = $A[0];
my $PW = $A[1];

#print "\n\nUSER Authenticated: $USER | $PW \n\n";

###########################################################
#### STUDENT AND EXERCISE INFOS ###########################

my $FN=decryptFile("$result_file");

#print "RESULT=\n\n$FN\n\n";

my @R = $FN =~ m/<STUDENT>(.*)<\/STUDENT><ALTSPASSWORD>(.*)<\/ALTSPASSWORD>/;
my $Student = $R[0];
my $Password = $R[1];
#print "\nSTUDENT= $Student\n";
#print "Password= $Password\n";

if (($Student ne "$USER") || ( $Password ne $PW )) {
print "\n\n<br/><br/>The student, who is logged ($USER) in is not equals with the owner of the result ($Student).<br/>Or is it possible that the ALTS password isn't correct!<br/><br/>Please login with command ALTSLogin!\n"; 
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
my $Date = $D[0];

my @P = $FN =~ m/<PROBLEM>(.*)<\/PROBLEM>/;
my $Problem = $P[0];

my @TP = $FN =~ m/<TOPIC>(.*)<\/TOPIC>/;
my $Topic = $TP[0];

my @DES = $FN =~ m/<DESCRIPTION>(.*)<\/DESCRIPTION>/s;

my $Description=$DES[0];
$Description =~ s/\n/<\/td><\/tr><tr><td>/g;

#<TASKNUMBER>17</TASKNUMBER><TASKSUCCESSFUL>5</TASKSUCCESSFUL><FINALRESULT>FAILED</FINALRESULT>

my @RES = $FN =~ m/<TASKNUMBER>(.*)<\/TASKNUMBER><TASKSUCCESSFUL>(.*)<\/TASKSUCCESSFUL><FINALRESULT>(.*)<\/FINALRESULT>/;

my $Tasknumber=$RES[0];
my $Tasksuccessful=$RES[1];
my $Finalresult=$RES[2];

###########################################################
#### TASKS ################################################
$FN =~ s/<br\/>/\n/g;
my @T = $FN =~ m/<TASK>(.*)<\/TASK>/g;


print "<table>
<tr><td>$Student</td></tr>
<tr><td>$Topic $Problem</td></tr>
<tr><td>$Date</td></tr></tr>
</table><br/><br/>";


print "<table><tr><td>$Description</td></tr></table><br/><br/>";

print '<table border="1"><tr><th>Task</th><th>Result</th></tr>';

foreach my $Task (@T)
{
#	print "$Task\n";
	my @TT=$Task=~m/<TASKDESC>(.*)<\/TASKDESC><RESULT>(.*)<\/RESULT>/;
#	print "\nTASK: $TT[0]\n";
#	print "\nRESULT: $TT[1]\n\n";
	print "\n<tr><td>$TT[0]</td>";
	if (($TT[1]) eq "[ PASS ]") {
		print "<td align=\"center\" bgcolor=\"#00FF00\">DONE</td></tr>";
	}
	else 
	{
		print "<td align=\"center\" bgcolor=\"#FF0000\">FAILED</td></tr>";
	}
}

print '</table><br/>';

print "<table>
<tr><td>Tasks number<\/td><td>$Tasknumber<\/td><\/tr>
<tr><td>Tasks successful<\/td><td>$Tasksuccessful<\/td><\/tr>
<tr><td>FINAL RESULT<\/td><td>$Finalresult<\/td><\/tr>
<\/table>\n";

