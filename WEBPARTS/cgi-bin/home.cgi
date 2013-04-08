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

if (!(-f $student_file)) { print "<META HTTP-EQUIV=refresh CONTENT=\"0;URL=/cgi-bin/ALTSLogin.cgi\">\n"; exit 1; }
my $F = decryptFile("$student_file");
if (! (defined $F)) { print "<META HTTP-EQUIV=refresh CONTENT=\"0;URL=/cgi-bin/ALTSLogin.cgi\">\n"; exit 1; }

my @A = $F =~ m/<STUDENT>(.*)<\/STUDENT><ALTSPASSWORD>(.*)<\/ALTSPASSWORD>/;
my $USER = $A[0];
my $PW = $A[1];

if (!(defined $USER)) { print "<META HTTP-EQUIV=refresh CONTENT=\"0;URL=/cgi-bin/ALTSLogin.cgi\">\n"; exit 1; }

print "<!DOCTYPE html PUBLIC \"-//W3C//DTD XHTML 1.0 Transitional//EN\" \"http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd\">
<html xmlns=\"http://www.w3.org/1999/xhtml\"><head>
<meta http-equiv=\"Content-Type\" content=\"text/html;
charset=UTF-8\"><title>ALTS Main</title>";


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
	color: #666;
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
	padding: 2px 4px;
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
	width: 450px;
	color: #000;
	background-color: #fff;
	border: solid 2px #bbb;
	border-radius: 5px;
	padding: 5px;
	margin: 12px 0 0 6px;
	left: 0;
	
	visibility: hidden;
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
	  <table border=\"0\" cellpadding=\"0\" cellspacing=\"0\" height=\"33\" width=\"100%\">
		<tr><td style=\"text-align: right; color: #888\">
			<span style=\"float: left\">Choose a category from the list and then click on an excercise.</span>
			logged in as <b>rigruber</b> [<a href=\"#\">logout</a>]</td></tr>
	  </table>
      
	  <table cellpadding=\"0\" cellspacing=\"0\" style=\"width: 100%\"><tr>
		<td><a name=\"list\"></a>
			
			<!-- CATEGORY LISTING -->
		
			<ul id=\"catList\">
				<li class=\"success\"><!-- category name-->01-boot
					<div class=\"exList\">
						<a class=\"excercise success\" href=\"excercise_url\"><!-- excercise number -->1
							<div><!-- excercise description -->Lorem ipsum dolor sit amet, consectetuer adipiscing elit, sed diam nonummy nibh euismod tincidunt ut laoreet dolore magna 
							aliquam erat volutpat.</div>
						</a>
						<a class=\"excercise fail\" href=\"platty\">2
							<div>Ut wisi enim ad minim veniam, quis nostrud exerci tation ullamcorper suscipit lobortis nisl ut aliquip ex ea commodo consequat. Duis autem vel eum 
							iriure dolor in hendrerit in vulputate velit esse molestie consequat, vel illum dolore eu feugiat nulla facilisis at vero eros et accumsan et iusto odio 
							dignissim qui blandit praesent luptatum zzril delenit augue duis dolore te feugait nulla facilisi.</div>
						</a>
						<a class=\"excercise\">3</a>
						<a class=\"excercise\">4</a>
						<a class=\"excercise\">5</a>
						<a class=\"excercise\">6</a>
						<a class=\"excercise\">7</a>
						<a class=\"excercise\">8</a>
						<a class=\"excercise\">9</a>
						<a class=\"excercise\">10</a>
						<a class=\"excercise\">11</a>
						<a class=\"excercise\">12</a>
						<a class=\"excercise\">13</a>
						<a class=\"excercise\">14</a>
						<a class=\"excercise\">15</a>
						<a class=\"excercise\">16</a>
						<a class=\"excercise\">17</a>
						<a class=\"excercise\">18</a>
						<a class=\"excercise\">19</a>
						<a class=\"excercise\">21</a>
						<a class=\"excercise\">22</a>
						<a class=\"excercise\">23</a>
						<a class=\"excercise\">24</a>
					</div>
				</li>
				<li class=\"fail\">02-physical_disk
					<div class=\"exList\">
						<a class=\"excercise\">1</a>
						<a class=\"excercise\">2</a>
						<a class=\"excercise\">3</a>
					</div>
				</li>
				<li>03-lvm</li>
				<li>04-network</li>
				<li>05-user-group</li>
				<li>06-rights</li>
				<li>07-nfs</li>
				<li>08-autofs</li>
				<li>09-ldap</li>
				<li>10-samba</li>
				<li>11-ftp</li>
				<li>12-system</li>
				<li>13-log</li>
				<li>14-apache</li>
				<li>15-firewall</li>
				<li>16-selinux</li>
				<li>17-package</li>
				<li>18-scripting</li>
				<li>19-crontab</li>
				<li>20-squid</li>
				<li>21-mail</li>
			</ol>
		</td>
	  </tr></table>
	  
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


</body></html>";
