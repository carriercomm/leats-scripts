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

###############################################################################
####################### THE STUDENT LOGGED IN #################################

	my $F=decryptFile("$student_file");
#print "F= $F\n\n";

	my @A = $F =~ m/<STUDENT>(.*)<\/STUDENT><ALTSPASSWORD>(.*)<\/ALTSPASSWORD>/;
	my $USER = $A[0];
	my $PW = $A[1];

	print "<!DOCTYPE html PUBLIC \"-//W3C//DTD XHTML 1.0 Transitional//EN\" \"http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd\">
		<html xmlns=\"http://www.w3.org/1999/xhtml\"><head>
		<meta http-equiv=\"Content-Type\" content=\"text/html; charset=UTF-8\">
		<title>ALTS Login</title>
		<style type=\"text/css\">
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

#btn_home {
width: 78px;
height: 78px;
	background-image: url('/ALTSicons/Home-Button.jpg');
}
#btn_home:hover {
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
    <td height=\"229\">
	  <table border=\"0\" cellpadding=\"0\" cellspacing=\"0\" height=\"33\" width=\"100%\">
		<tr><td style=\"text-align: right; color: #888\"></td></tr>
	  </table>
      <table border=\"0\" cellpadding=\"0\" cellspacing=\"0\" height=\"232\" width=\"100%\">
        <thead><tr>
          <td rowspan=\"3\" height=\"176\" width=\"15%\">&nbsp;</td>
          <td rowspan=\"3\" width=\"39%\"><table border=\"0\" cellpadding=\"0\" cellspacing=\"0\" width=\"100%\">
            <tbody><tr>
              <td height=\"179\">
				<table border=\"0\" cellpadding=\"0\" cellspacing=\"0\" height=\"40\" width=\"100%\">
                  <tbody><tr class=\"Exercise\">
                    <td height=\"40\" width=\"13%\"></td>
     
                    <td class=\"Exercise\" width=\"73%\">Login to ALTS</td>

                    <td width=\"14%\"></td>
                  </tr>
                </tbody></table>
				<table border=\"0\" cellpadding=\"0\" cellspacing=\"0\" height=\"126\" width=\"100%\">
				  <tbody><tr>
                  <td colspan=\"4\" height=\"20\">
				  
				  <form name=\"loginForm\" action=\"/cgi-bin/ALTSLogin.cgi\" method=\"POST\">
				  <table border=\"0\" cellpadding=\"2\" cellspacing=\"4\" height=\"92\" width=\"100%\">
                    <tbody>
                    <tr>
                      <td class=\"Table_Tag\" width=\"29%\">Name:</td>
                      <td width=\"6%\">&nbsp;</td>
                      <td class=\"Table_simple\" width=\"65%\"><input type=\"text\" name=\"student\" /></td>
                    </tr>
                    <tr>
                      <td class=\"Table_Tag\">Password:</td>
                      <td>&nbsp;</td>
                      <td class=\"Table_simple\"><input type=\"password\" name=\"pass\" /></td>
                    </tr>
                    <tr>
                      <td class=\"Table_Tag\" height=\"24\">Excercise&nbsp;ID:</td>
                      <td>&nbsp;</td>
                      <td class=\"Table_simple\"><input type=\"text\" name=\"exercise\" /></td>
                    </tr>
					<tr>
					  <td colspan=\"2\"></td>
					  <td class=\"Table_simple\"><input type=\"submit\" name=\"submit\" value=\"Login\" /></td>
					</tr>
					</tbody>
				  </table>
				  </form>
				  
				  </td>
				  </tr></tbody>
				</table>
			  </td>
			</tr></tbody>
		  </table></td>
          <td rowspan=\"3\" width=\"6%\">&nbsp;</td>
          <td height=\"1\" width=\"20%\">&nbsp;</td>
          <td rowspan=\"3\" width=\"20%\">&nbsp;</td>
        </tr>
        <tr>";

	if ($ENV{'QUERY_STRING'} eq "LoginFailed")
	{
		print "	<td class=\"Result_picture\" height=\"114\" style=\"vertical-align: bottom; color: #900\"><b>LOGIN FAILED</b></td>";
	}
	else {
		 print " <td class=\"Result_picture\" height=\"114\" style=\"vertical-align: bottom; color: #900\"><b></b></td>";
	}
        
print "</tr>
        <tr>
          <td class=\"Result_picture\" height=\"97\"></td>
        </tr>
    </tbody></table>
  </td>
  </tr>
  </thead>
  <tbody id=\"details\">
  <tr>
   <td></td>
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


</body></html>";


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
		print "<META HTTP-EQUIV=refresh CONTENT=\"0;URL=/cgi-bin/ALTSLogin.cgi?LoginFailed\">\n"; 
	}
}
#system("/var/www/cgi-bin/Result 2>&1");
#system("/var/www/cgi-bin/02-physical_disk-1-grade");

exit;
