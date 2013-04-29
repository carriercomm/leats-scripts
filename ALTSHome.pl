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

#print "Content-type: text/html\n\n";

sub exposeTopic($)
{
	my $Topic=$_[0];
	my $N=1;

	my $TriedExercises=0;
	my $SuccessfulExercises=0;
	my $FailedExercises=0;
	my $NumberExercises=0;

	my $HTML_EXERCISES="";

	while (-x "/var/www/cgi-bin/$Topic/$N-activator")
	{
		$NumberExercises++;
		#/ALTS/RESULTS/ACTUAL/02-physical_disk-1
		my $Description="";
		my $Result_file="/ALTS/RESULTS/ACTUAL/$Topic-$N";	
		my $excercise_url="/cgi-bin/activate.cgi?$Topic-$N";

		if (!(-f $Result_file)) {
			my $F;
			open($F,"<","/ALTS/EXERCISES/$Topic/$N-description.txt");
			my @D = <$F>;		
			close($F);
			$Description=join("<br>",@D);
			$HTML_EXERCISES.="	<a class=\"excercise\" href=\"$excercise_url\"><!-- excercise number -->$N
				<div><!-- excercise description --><b>$Topic/$N</b><br><br>$Description</div>
				</a>";
		}
		else
		{
			my $FN=decryptFile("$Result_file");
			my @RES = $FN =~ m/<DESCRIPTION>(.*)<\/DESCRIPTION>.*<FINALRESULT>(.*)<\/FINALRESULT>/s;
			$Description=$RES[0];
			$Description =~ s/\n/<br>/g;	
			my $Finalresult=$RES[1];
			if ($Finalresult eq "PASSED")
			{
				$HTML_EXERCISES.=" <a class=\"excercise success\" href=\"$excercise_url\"><!-- excercise number -->$N
					<div><!-- excercise description --><b>$Topic/$N</b><br><br>$Description</div>
					</a>";
				$TriedExercises++; $SuccessfulExercises++; 
			}
			elsif ($Finalresult eq "FAILED")
			{
				$HTML_EXERCISES.=" <a class=\"excercise fail\" href=\"$excercise_url\"><!-- excercise number -->$N
					<div><!-- excercise description --><b>$Topic/$N</b><br><br>$Description</div>
					</a>";
				$TriedExercises++; $FailedExercises++;
			}
			else
			{
				$HTML_EXERCISES.=" <a class=\"excercise\" href=\"$excercise_url\"><!-- excercise number -->$N
					<div><!-- excercise description --><b>$Topic/$N</b><br><br>$Description</div>
					</a>";
			}

		}
		$N=$N+1;
	}

	if ($TriedExercises>0)
	{	
#		if ($TriedExercises == $SuccessfulExercises)
		if ($NumberExercises == $SuccessfulExercises)
		{
			print"<li class=\"success\"><!-- category name-->$Topic";
		}	
		elsif ($FailedExercises == 0)
		{	
			print"<li class=\"inprogress\"><!-- category name-->$Topic";
		}
		else
		{
			print"<li class=\"fail\"><!-- category name-->$Topic";
		}
	}
	else
	{
		print"<li><!-- category name-->$Topic";
	}	


	print "<div class=\"exList\">$HTML_EXERCISES</div></li>";



}


if (!(-f $student_file)) { print "<META HTTP-EQUIV=refresh CONTENT=\"0;URL=/cgi-bin/ALTSLogin.cgi\">\n"; exit 1; }
my $F = decryptFile("$student_file");
if (! (defined $F)) { print "<META HTTP-EQUIV=refresh CONTENT=\"0;URL=/cgi-bin/ALTSLogin.cgi\">\n"; exit 1; }

my @A = $F =~ m/<STUDENT>(.*)<\/STUDENT><ALTSPASSWORD>(.*)<\/ALTSPASSWORD>/;
my $USER = $A[0];
my $PW = $A[1];

if (!(defined $USER)) { print "<META HTTP-EQUIV=refresh CONTENT=\"0;URL=/cgi-bin/ALTSLogin.cgi\">\n"; exit 1; }

system("rm -rf /ALTS/RESULTS/ACTUAL/AES/${USER}_results.tgz 2>/dev/null; tar -czf /ALTS/RESULTS/ACTUAL/AES/${USER}_results.tgz /ALTS/RESULTS/ACTUAL/*.alts.aes");


print "<!DOCTYPE html PUBLIC \"-//W3C//DTD XHTML 1.0 Transitional//EN\" \"http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd\">
<html xmlns=\"http://www.w3.org/1999/xhtml\"><head>
<meta http-equiv=\"Content-Type\" content=\"text/html;
charset=UTF-8\"><title>ALTS Home</title>";


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
a {
color: #444;
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
	text-align: center;
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

/* CATEGORY LISTING */

ul#catList {
	text-align: left;
	list-style-type: none;
width: 100%;
position: relative;
}

/* Categories */

ul#catList li {
width: 190px;
padding: 2px;
border: solid 1px #ddd;
	border-radius: 3px;
color: #667;
cursor: pointer;
	padding-left: 5px;
	margin-bottom: 2px;
overflow: hidden;
}
ul#catList li:hover {
	background-color: #eee;
}

ul#catList li.success {
color: #060;
       border-color: #0b0;
}
ul#catList li.success:hover {
	background-color: #efe;
}
ul#catList li.fail {
color: #600;
       border-color: #b00;
}
ul#catList li.fail:hover {
	background-color: #fee;
}
ul#catList li.inprogress {
color: #000;
       border-color: #000;
}
ul#catList li.inprogress:hover {
        background-color: #d9d9d9;
}


/* Excercises */

ul#catList div.exList {
display: inline-block;
position: absolute;
left: 250px;
width: 460px;
top: 0;

visibility: hidden;
}

ul#catList .excercise {
display: inline-block;
position: static;
padding: 6px 6px;
width: 25px;
text-align: center;
margin-bottom: 2px;
border: solid 1px #ccc;
border-radius: 3px;
color: #333;
background-color: #fff;
text-decoration: none;

       /* IE7 inline-block hack */
zoom: 1;
      *display: inline;
}
ul#catList .excercise:hover {
	background-color: #eee;
}

ul#catList .excercise.success {
color: #060;
       border-color: #0b0;
}
ul#catList .excercise.success:hover {
	background-color: #efe;
}
ul#catList .excercise.fail {
color: #600;
       border-color: #b00;
}
ul#catList .excercise.fail:hover {
	background-color: #fee;
}

ul#catList .excercise div {
position: absolute;
text-align: left;
width: 550px;
color: #000;
       background-color: #fff;
border: solid 2px #bbb;
	border-radius: 5px;
padding: 5px;
margin: 12px 0 0 6px;
left: 0;

visibility: hidden;
}

a.btn {
	display: block;
	background-color: transparent;
	background-repeat: no-repeat;
	background-position: 0 0;
	margin: 0 auto;
}


#btn_dload {
width: 78px;
height: 78px;
	background-image: url('/ALTSicons/Download-Button.jpg');
}

#btn_dload:hover {
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

#btn_reinstall {
width: 78px;
height: 78px;
	background-image: url('/ALTSicons/Reinstall-Button.jpg');
}
#btn_reinstall:hover {
	background-position: -78px 0;
}	

-->
</style>

<script type=\"text/javascript\"> 

displayedChilds = new Array();

function displayFirstChild(lmant) {
	childs = lmant.childNodes;
	for (j in childs) {
		if (childs[j].nodeType == 1) {
			childs[j].style.visibility = \"visible\";

			displayedChilds.unshift(childs[j]);
			break;
		}
	}
}

function getLast() {
	return displayedChilds[0];
}

function hideLast(level) {
	if (!level) level = displayedChilds.length;

	while (displayedChilds.length >= level) {
		lmant = displayedChilds.shift();
		lmant.style.visibility = \"hidden\";
	}
}

function hideAll() {
	hideLast(1);
}

function addHandlers() {
	LIs = document.getElementById(\"catList\").childNodes;
	for (i in LIs) {
		if (LIs[i].nodeName == \"LI\") {
			LIs[i].onclick = function(e) {
				lmant = e ? e.target : event.srcElement;
				if (lmant.nodeName == \"LI\" ) {
					hideAll();
				displayFirstChild(e ? e.target : event.srcElement);
				window.location = \"#list\";
			}
			};

		DIVs = LIs[i].getElementsByTagName(\"A\");
		for (j in DIVs) {
			if (DIVs[j].className && DIVs[j].className.indexOf(\"excercise\") >= 0) {
				DIVs[j].onmouseover = function(e) {
					displayFirstChild(e ? e.target : event.srcElement);
				}
			DIVs[j].onmouseout = function(e) {
				hideLast(2);
			}
		}
		}
	}
	}
}

</script></head>



<body onload=\"addHandlers()\" link=\"white\">

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
<td height=\"229\">
<table border=\"0\" cellpadding=\"0\" cellspacing=\"0\" height=\"33\" width=\"100%\">";

if (($ENV{'QUERY_STRING'} ne "REINSTALL") && ($ENV{'QUERY_STRING'} ne "RESET"))
{


print "
<tr><td style=\"text-align: right; color: #888\">
<span style=\"float: left\">Choose a category from the list and then click on an excercise.</span>
logged in as <b>$USER</b> [<a href=\"/cgi-bin/ALTSLogout.cgi\">logout</a>]</td></tr>
</table>

<table cellpadding=\"0\" cellspacing=\"0\" style=\"width: 100%\"><tr>
<td><a name=\"list\"></a>

<!-- CATEGORY LISTING -->

<ul id=\"catList\">";

exposeTopic("01-boot");
exposeTopic("02-physical_disk");
exposeTopic("03-lvm");
exposeTopic("04-network");
exposeTopic("05-user-group");
exposeTopic("06-rights");
exposeTopic("07-nfs");
exposeTopic("08-autofs");
exposeTopic("09-ldap");
exposeTopic("10-samba");
exposeTopic("11-ftp");
exposeTopic("12-system");
exposeTopic("13-log");
exposeTopic("14-apache");
exposeTopic("15-firewall");
exposeTopic("16-selinux");
exposeTopic("17-package");
exposeTopic("18-scripting");
exposeTopic("19-crontab");
exposeTopic("20-squid");
exposeTopic("21-mail");

print "
</ol>
</td>
</tr>
<tr>

<table style=\"margin:auto\" border=\"0\" cellpadding=\"0\" cellspacing=\"0\" width=\"340\">
<tr>
   <td class=\"Button_Description\">DOWNLOAD<br/>ALL RESULTS</td>
   <td width=\"70\">&nbsp</td>
   <td class=\"Button_Description\">RESET</td>
   <td class=\"Button_Description\">REINSTALL</td>
</tr>
<tr align=\"center\">
	<td style=\"text-align: center\"><a id=\"btn_dload\" class=\"btn\" href=\"http://localhost:8080/results/rigruber_results.tgz\"></a></td>
	<td>&nbsp</td>
	<td style=\"text-align: center\"><a id=\"btn_break\" class=\"btn\" href=\"?RESET\"></a></td>
	<td style=\"text-align: center\"><a id=\"btn_reinstall\" class=\"btn\" href=\"?REINSTALL\"></a></td>
</tr>
</table>

</tr>
</table>

</td>
</tr>
<tr>
<td> </td>
</tr>
<tr><td><hr align=\"left\" color=\"DFDFDF\" size=\"6\"></td></tr>
<tr>
<td>&nbsp;</td>
</tr>
</tbody></table>
";

}

if ($ENV{'QUERY_STRING'} eq "RESET")
{

	print "<br/><br/><p>Reset is in progress, this may take a few minutes..</p><p>Please be patient...</p>";
        system("/ALTS/RESET 1>/dev/null 2>&1");
	print "<META HTTP-EQUIV=refresh CONTENT=\"0;URL=/cgi-bin/home.cgi\">\n";
}

if ($ENV{'QUERY_STRING'} eq "REINSTALL")
{

	print "<br/><br/><p>Reinstall is in progress, this may take 10-15 minutes..</p><p>Please be patient...</p>";
        system("/ALTS/REINSTALL 1>/dev/null 2>&1");
	print "<META HTTP-EQUIV=refresh CONTENT=\"0;URL=/cgi-bin/home.cgi\">\n";
}


print "</body></html>";
