#!/usr/bin/perl

use lib '/scripts/common_perl/';
use Framework qw(&cryptText2File &decryptText &decryptFile $student_file);

use Term::ReadKey;
use Term::ANSIColor;

#### If you want to let TestMode, then $TestModePossible=0;
my $TestModePossible=0;

my $CGI_HOME="/var/www/cgi-bin";

my $fn; open($fn,">","$student_file"); print $fn ""; close($fn);

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

my $EXERCISE;

if ($PASS1 ne $PASS2) {
	print color 'bold red';
 	print "\n\n\n\t\tThe passwords are not the same.\n\n\n\t\t\tLogin Failed!\n\n\n";
	print color 'reset';
	exit 1;		
}
else {

	print "\n\nExercise code: ";

	if (($PASS1 eq "test")&&($TestModePossible==0)) { 
		$EXERCISE="TEST"; 
		print color "yellow"; 
		print "TEST\n\nTEST Mode activated\n\n"; 
		print color 'reset'; }
	else{
		my $EXERCISE_CODE= <STDIN>;
		chomp($EXERCISE_CODE);
		$EXERCISE=decryptText("$EXERCISE_CODE","${$UserName}${$PASS1}");
#		print "\n\nEXERCISE= $EXERCISE_CODE || $EXERCISE\n\n";
		if ($EXERCISE!~m/\d+/) {
			print color 'bold red' and print "\n\n\n\tThe password or the exercise code isn't correct.\n\n\n\t\t\tLogin Failed!\n\n\n";
			print color 'reset'; 
			exit 1;	
		}
	}

	cryptText2File("<STUDENT>$UserName</STUDENT><ALTSPASSWORD>$PASS1</ALTSPASSWORD><EXERCISE>$EXERCISE</EXERCISE>","$student_file");
	my $F=decryptFile("$student_file");
	if ($F =~ m/<STUDENT>$UserName<\/STUDENT><ALTSPASSWORD>$PASS1<\/ALTSPASSWORD><EXERCISE>$EXERCISE<\/EXERCISE>/)
	{
		#/ALTS/RESULTS/rigruber-EXAM-1
		system("/ALTS/lib/Perl2SetUIDExecutable '/ALTS/lib/Results2Html /ALTS/RESULTS/$UserName-EXAM-$EXERCISE' '$CGI_HOME/Result';");
		system("chmod +s $CGI_HOME/Result");
		system("/ALTS/lib/Perl2SetUIDExecutable '/ALTS/EXAM/$EXERCISE --grade' '$CGI_HOME/Grade'");
		system("chmod +s $CGI_HOME/Grade");
		system("/ALTS/lib/Perl2SetUIDExecutable '/ALTS/EXAM/$EXERCISE --break' '$CGI_HOME/Break'");
		system("chmod +s $CGI_HOME/Break");
		system("ln -s $CGI_HOME/Grade /ALTS/Grade");
		system("ln -s $CGI_HOME/Break /ALTS/Break");

		print color 'bold green';
		print "\n\n\t\t\tLogin Successful!\n\n\n"; 
		print color 'reset';
		exit 0;
	}
	else
	{
		print color 'bold red';
		print "\n\n\n\t\t\tLogin Failed!\n\n\n";
		print color 'reset';
		exit 1;
	}
}


exit 0;
