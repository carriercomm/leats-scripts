#!/usr/bin/perl

use lib '/scripts/common_perl/';
use Framework qw(&cryptText2File &decryptFile $student_file);

use Term::ReadKey;
use Term::ANSIColor;

my $fn; open($fn,">","/ALTS/User.alts"); print $fn ""; close($fn);

my $UserName = "";
while ($UserName eq "")
{
	system("clear");
	my $L=20;
	print "="x$L."=========\n";
	print "   ALTS User Login\n";
	print "="x$L."=========\n\n";
	print "Username:  ";
	$UserName = <STDIN>;
	chomp($UserName);
}
print "\nPassword:  ";
ReadMode('noecho');
my $PASS1= <STDIN>;
chomp($PASS1);
ReadMode('normal');

print "\nPassword again:  ";
ReadMode('noecho');
my $PASS2= <STDIN>;
chomp($PASS2);
ReadMode('restore');

if ($PASS1 ne $PASS2) {
		print color 'bold red' and print "\n\n\n\tThe passwords are not the same. Please try it again!\n\n\n\t\t\tLogin Failed!\n\n\n"  and print color 'reset' and exit 1;		
}
else {
	cryptText2File("<STUDENT>$UserName</STUDENT><ALTSPASSWORD>$PASS1</ALTSPASSWORD>","$student_file");
	my $F=decryptFile("$student_file");
	if ($F =~ m/<STUDENT>$UserName<\/STUDENT><ALTSPASSWORD>$PASS1<\/ALTSPASSWORD>/)
{
	print color 'bold green' and print "\n\n\t\t\tLogin Successful!\n\n\n"  and print color 'reset' and exit 0;
}
else
{
print color 'bold red' and print "\n\n\n\t\t\tLogin Failed!\n\n\n"  and print color 'reset' and exit 1;
}
}


exit 0;
