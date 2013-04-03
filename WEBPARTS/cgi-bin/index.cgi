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
#my $result_file="/ALTS/RESULTS/ACTUAL/05-user-group-1";

################################################################################
######################## THE STUDENT IS LOGGED IN ##############################

my $F=decryptFile("$student_file");
#print "F= $F\n\n";

my @A = $F =~ m/<STUDENT>(.*)<\/STUDENT><ALTSPASSWORD>(.*)<\/ALTSPASSWORD>/;
my $USER = $A[0];
my $PW = $A[1];

if ($USER eq "") { print "Location: /cgi-bin/ALTSLogin.cgi\n\n"; exit 0; }



###############################################################################

print "Content-type: text/html\n\n";

print "<!DOCTYPE html PUBLIC \"-//W3C//DTD XHTML 1.0 Transitional//EN\" \"http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd\">
<html xmlns=\"http://www.w3.org/1999/xhtml\">
<head>
<meta http-equiv=\"Content-Type\" content=\"text/html; charset=UTF-8\">
<title>ALTS TEST Page</title>
";

print "<style type=\"text/css\">
<!--
body {
	margin-left: 20%;
	margin-top: 5%;
	margin-right: 20%;
	margin-bottom: 5%;
	text-align: right;
	background-color: #FFF;
}
.Table_simple {
	font-size: 18px;
	font-style: normal;
	text-align: left;
	background-color: #FFF;
}
.Table_student {
	font-size: 18px;
	text-align: left;
color: #FFF;
       background-color: #009;
}
.Table_Tag {
	font-size: 24px;
}
.Table_Tag {
	font-size: 18px;
color: #000;
       background-color: #DFDFDF;
       text-align: left;
}
.Table_student {
	font-size: 18px;
	text-align: center;
	background-color: #FFF;
color: #000;
       vertical-align: middle;
       font-weight: bold;
       font-family: Verdana, Geneva, sans-serif;
}
.Table_student_name {
	background-color: #FFF;
color: #000;
       font-size: 24px;
       font-weight: bold;
       font-style: italic;
       text-align: justify;
       vertical-align: middle;
}
.Result_picture {
	vertical-align: top;
	text-align: center;
}
body p {
	text-align: left;
	font-weight: bold;
}
.MainTABLE_nonbold {
	font-weight: normal;
	vertical-align: middle;
}
.Result-table {
	text-align: left;
}
.Exercise {
	margin-right: 20px;
	margin-left: 2px;
	text-align: center;
	font-weight: bold;
	font-size: 18px;
}
.Button_Description {
	text-align: center;
color: #BCBCBC;
}

a.btn {
display: block;
	 background-color: transparent;
	 background-repeat: no-repeat;
	 background-position: 0 0;
margin: 0 auto;
}

#btn_prev {
width: 30px;
height: 30px;
	background-image: url('/ALTSicons/Button_Previous.jpg');
}
#btn_prev:hover {
	background-position: -30px 0;
}

#btn_next {
width: 30px;
height: 30px;
	background-image: url('/ALTSicons/Button_Next.jpg');
}
#btn_next:hover {
	background-position: -30px 0;
}

#btn_grade {
width: 78px;
height: 78px;
	background-image: url('/ALTSicons/play_button.png');
}
#btn_grade:hover {
	background-position: -78px 0;
}

#btn_break {
width: 78px;
height: 78px;
	background-image: url('/ALTSicons/break_button.png');
}
#btn_break:hover {
	background-position: -78px 0;
}

#btn_details {
width: 78px;
height: 78px;
	background-image: url('/ALTSicons/Details-Button_wide.jpg');
}
#btn_details:hover {
	background-position: -78px 0;
}

#btn_dload {
width: 78px;
height: 78px;
	background-image: url('/ALTSicons/Download-Button.jpg');
}
#btn_dload:hover {
	background-position: -78px 0;
}
-->
</style><script language=\"javascript\" type=\"text/javascript\"> 
function hideDiv() { 
	if (document.getElementById) { 
		document.getElementById('Description').style.display = 'none'; 
		document.getElementById('DetailedDescription').style.display = 'none'; 
		document.getElementById('Line0').style.display = 'none'; 
		document.getElementById('Line1').style.display = 'none';  
	} 
} 
function showDiv() { 
	if (document.getElementById) 
	{ 
		if (document.getElementById('Description').style.display == 'none') 
		{
			document.getElementById('Description').style.display = 'block'; 
			document.getElementById('DetailedDescription').style.display = 'block'; 
			document.getElementById('Line0').style.display = 'block'; 
			document.getElementById('Line1').style.display = 'block'; 		
		}	
		else
		{
			hideDiv()
		}
	}
} 

</script></head>
<body onload=\"hideDiv()\" link=\"white\">


<table border=\"0\" cellpadding=\"0\" cellspacing=\"0\" width=\"772\">
  <tbody><tr>
    <td width=\"772\"><img src=\"/ALTSicons/ALTSLOGO.jpg\" alt=\"ALTSLOGO\" height=\"191\" width=\"770\"></td>
  </tr>
  <tr>
    <td></td>
  </tr>
      <tr>
    <td><hr align=\"left\" color=\"DFDFDF\" size=\"6\"></td>
  </tr>
  <tr>
    <td height=\"229\"><table border=\"0\" cellpadding=\"0\" cellspacing=\"0\" height=\"33\" width=\"100%\">
    </table>
      <table border=\"0\" cellpadding=\"0\" cellspacing=\"0\" height=\"232\" width=\"100%\">
        <thead><tr>
          <td rowspan=\"3\" height=\"176\" width=\"15%\">&nbsp;</td>
          <td rowspan=\"3\" width=\"39%\"><table border=\"0\" cellpadding=\"0\" cellspacing=\"0\" width=\"100%\">
            <tbody><tr>
              <td height=\"179\">
              <table border=\"0\" cellpadding=\"0\" cellspacing=\"0\" height=\"40\" width=\"100%\">
                  <tbody><tr class=\"Exercise\">
                    <td height=\"40\" width=\"13%\"><a id=\"btn_prev\" class=\"btn\" href=\"#\"></td>
     
";


###########################################################
##### STUDENT AND EXERCISE INFOS ###########################


my $Date = "---";

my @W = $result_file =~ m/\/ALTS\/RESULTS\/ACTUAL\/(.+)-(\d+)/sg;

my $Problem = "$W[1]";
my $Topic = "$W[0]";
my $Description="\n\nYou didn't do this exercise yet!\n\n";
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
	$Description="<p>$Description</p>";

	@T = $FN =~ m/<TASK>(.*)<\/TASK>/g;

#<TASKNUMBER>17</TASKNUMBER><TASKSUCCESSFUL>5</TASKSUCCESSFUL><FINALRESULT>FAILED</FINALRESULT>

	my @RES = $FN =~ m/<TASKNUMBER>(.*)<\/TASKNUMBER><TASKSUCCESSFUL>(.*)<\/TASKSUCCESSFUL><FINALRESULT>(.*)<\/FINALRESULT>/;

	$Tasknumber=$RES[0];
	$Tasksuccessful=$RES[1];
	$Finalresult=$RES[2];
}

###############################################################################

#<tr>
#<th colspan=\"7\" class=\"MainTABLE\" scope=\"row\">&nbsp;</th>
#</tr>
#

print "
<td class=\"Exercise\" width=\"73%\">$Topic $Problem</td>
<td width=\"14%\"><a id=\"btn_next\" class=\"btn\" href=\"#\"></td>
</tr>
</tbody></table>
<table border=\"0\" cellpadding=\"0\" cellspacing=\"0\" height=\"126\" width=\"100%\">
<tbody><tr>
<td colspan=\"4\" height=\"20\"><table border=\"0\" cellpadding=\"2\" cellspacing=\"4\" height=\"92\" width=\"100%\">
<tbody><tr>
<td colspan=\"3\"></td>
</tr>
<tr>
<td class=\"Table_Tag\" width=\"29%\">Student:</td>
<td width=\"6%\">&nbsp;</td>
<td class=\"Table_simple\" width=\"65%\">$USER</td>
</tr>
<tr>
<td class=\"Table_Tag\">Date:</td>
<td>&nbsp;</td>
<td class=\"Table_simple\">$Date</td>
</tr>
<tr>
<td class=\"Table_Tag\" height=\"24\">Result:</td>
<td>&nbsp;</td>
<td class=\"Table_simple\">$Tasksuccessful/$Tasknumber</td>
</tr>

<tr>
<td class=\"Result_picture\" height=\"97\" colspan=\"3\"><table border=\"0\" cellpadding=\"0\" cellspacing=\"0\" height=\"42\" width=\"100%\">
<tbody><tr>
<td class=\"Button_Description\">&nbsp;</td>
<td class=\"Button_Description\">&nbsp;</td>
</tr>
<tr>
<td class=\"Button_Description\">DETAILS</td>
<td class=\"Button_Description\">DOWNLOAD</td>
</tr>
<tr>
<td width=\"49%\" style=\"text-align: center\"><a id=\"btn_details\" class=\"btn\" href=\"javascript:void(0)\" onclick=\"showDiv()\"></a></td>
<td width=\"51%\" style=\"text-align: center\"><a id=\"btn_dload\" class=\"btn\" href=\"#\"></a></td>
</tr>
</tbody></table></td>
</tr>
</tbody></table></td>
</tr>
</tbody></table>
<table border=\"0\" cellpadding=\"0\" cellspacing=\"3\" width=\"100%\">
</table>
</td>
</tr>
</tbody></table></td>
<td rowspan=\"3\" width=\"6%\">&nbsp;</td>
<td height=\"1\" width=\"20%\">&nbsp;</td>
<td rowspan=\"3\" width=\"20%\">&nbsp;</td>
</tr>
<tr>
";

if ($Tasksuccessful eq $Tasknumber) 
{
	print "<td class=\"Result_picture\" height=\"114\"><img src=\"/ALTSicons/EXAMPASSED.jpg\" alt=\"PASSED\" height=\"105\" width=\"152\"></td>";	
}
else
{
	print "<td class=\"Result_picture\" height=\"114\"><img src=\"/ALTSicons/EXAMFAILED.jpg\" alt=\"FAILED\" height=\"105\" width=\"152\"></td>";
}


print "
</tr>
<tr>
<td class=\"Result_picture\" height=\"97\"><table border=\"0\" cellpadding=\"0\" cellspacing=\"0\" height=\"42\" width=\"100%\">
<tbody><tr>
<td class=\"Button_Description\">&nbsp;</td>
<td class=\"Button_Description\">&nbsp;</td>
</tr>
<tr>
<td class=\"Button_Description\">BREAK/RESET</td>
<td class=\"Button_Description\">GRADE</td>
</tr>
<tr>
<td width=\"49%\"><a id=\"btn_break\" class=\"btn\" href=\"#\"></a></td>
<td width=\"51%\"><a id=\"btn_grade\" class=\"btn\" href=\"#\"></a></td>
</tr>
</tbody></table></td>
</tr>
</tbody></table>
</td>
</tr>
</thead>
<tbody id=\"details\">
<tr>
<td><div id=\"Line0\"><hr align=\"left\" color=\"DFDFDF\" size=\"3\"><hr align=\"left\" color=\"DFDFDF\" size=\"3\"></div></td>
</tr>
<tr>	
<td colspan=\"9\" scope=\"row\">
<div id=\"Description\">
$Description
</div>
</td>
</tr>
<tr>
<td><div id=\"Line1\"><hr align=\"left\" color=\"DFDFDF\" size=\"3\"><hr align=\"left\" color=\"DFDFDF\" size=\"3\"></div></td>
</tr> 
<tr>
<td>
<div id=\"DetailedDescription\">  
<table border=\"0\" cellpadding=\"0\" cellspacing=\"2\" width=\"100%\">
<tbody><tr>
<td width=\"11%\">&nbsp;</td>
";

################################################################################

if (-f $result_file) {


	foreach my $Task (@T)
	{
		my @TT=$Task=~m/<TASKDESC>(.*)<\/TASKDESC><RESULT>(.*)<\/RESULT>/;
		print "<tr><td>&nbsp;</td><td class=\"Result-table\"><span>$TT[0]</span></td>";
		if (($TT[1]) eq "[ PASS ]") {
			print "<td><img src=\"/ALTSicons/PASSED.jpg\" alt=\"PASSED\" height=\"34\" width=\"34\"></td><td>&nbsp;</td>";
		}
		else
		{
			print "<td><img src=\"/ALTSicons/FAILED.jpg\" alt=\"FAILED\" height=\"34\" width=\"34\"></td><td>&nbsp;</td>";
		}
		print "</tr>";
	}


	print " </tbody></table>
		</div>
		</td>
		</tr>
		</tbody>
		<tfoot>
		<tr>
		<td> </td>
		</tr>
		<tr><td><hr align=\"left\" color=\"DFDFDF\" size=\"6\"></td></tr>
		<tr>
		<td>&nbsp;</td>
		</tr>
		</tfoot></table>

		";



}

#system("/var/www/cgi-bin/Result 2>&1");
#system("/var/www/cgi-bin/02-physical_disk-1-grade");

print "</body>
</html>\n";

exit;
