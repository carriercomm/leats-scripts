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
	if ($ARGV[0] eq "") {
		$UserName = <STDIN>;
		chomp($UserName);
	}
	else {
		$UserName=$ARGV[0];
		print "$UserName\n";
	}
}
print "\nPassword:  ";

my $PASS1;
my $PASS2;
if ($ARGV[1] eq "") {
	ReadMode('noecho');
	$PASS1=<STDIN>;
	chomp($PASS1);
	ReadMode('normal');
	print "\nPassword again:  ";
	ReadMode('noecho');
	$PASS2=$ARGV[1] |= <STDIN>;
	chomp($PASS2);
	ReadMode('restore');
}
else
{
	print "\nPassword again: \n";
	$PASS1=$ARGV[1];
	$PASS2=$ARGV[1];
}

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
		my $EXERCISE_CODE;
		if ($ARGV[2] eq "") {
			$EXERCISE_CODE=<STDIN>;
			chomp($EXERCISE_CODE);
		}
		else {
			$EXERCISE_CODE=$ARGV[2];
			print "$EXERCISE_CODE\n";
		}
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
		system("mkdir -p /ALTS/RESULTS/$UserName; chmod 700 /ALTS/RESULTS/$UserName");
		system("unlink /ALTS/RESULTS/ACTUAL 1>/dev/null 2>&1; ln -s /ALTS/RESULTS/$UserName /ALTS/RESULTS/ACTUAL");
		system("unlink /ALTS/Grade 1>/dev/null 2>&1; unlink /ALTS/Break 1>/dev/null 2>&1");		
		if ($EXERCISE ne "TEST")
		{		
			system("/ALTS/lib/Perl2SetUIDExecutable '/ALTS/lib/Results2Html /ALTS/RESULTS/ACTUAL/EXAM-$EXERCISE' '$CGI_HOME/Result';");
			system("chmod +s $CGI_HOME/Result");
			system("/ALTS/lib/Perl2SetUIDExecutable '/ALTS/EXAM/$EXERCISE --grade' '$CGI_HOME/Grade'");
			system("chmod +s $CGI_HOME/Grade");
			system("/ALTS/lib/Perl2SetUIDExecutable '/ALTS/EXAM/$EXERCISE --break' '$CGI_HOME/Break'");
			system("chmod +s $CGI_HOME/Break");
			system("unlink /ALTS/Grade 1>/dev/null 2>&1; ln -s $CGI_HOME/Grade /ALTS/Grade");
			system("unlink /ALTS/Break 1>/dev/null 2>&1; ln -s $CGI_HOME/Break /ALTS/Break");
			system("chmod 700 /ALTS/EXERCISES");
		}
		else
		{		
			system("chmod 755 /ALTS/EXERCISES");
		}	
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


exit 2;
