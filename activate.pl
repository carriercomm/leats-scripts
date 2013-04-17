#!/usr/bin/perl

use strict;
use warnings;

use Term::ANSIColor;

use lib '/scripts/common_perl/';
use Framework qw(&cryptText2File &decryptFile $student_file);

my $E="";

sub exposeTopic($)
{
	my $Topic=$_[0];
	my $N=1;

	my $TriedExercises=0;
	my $SuccessfulExercises=0;

	my $HTML_EXERCISES="";

	while (-x "/var/www/cgi-bin/$Topic/$N-activator")
	{

		my $Description="";
		my $Result_file="/ALTS/RESULTS/ACTUAL/$Topic-$N";

		if (!(-f $Result_file)) {
			my $F;
			open($F,"<","/ALTS/EXERCISES/$Topic/$N-description.txt");
			my @D = <$F>;
			close($F);
			$Description=join("\n",@D);
			if ( ($E eq "LIST ALL") || ($E eq "LIST UNTRIED") ) { print "\t\t$Topic-$N\n";}
		}
		else
		{
	my $FN=decryptFile("$Result_file");
	my $Finalresult="";
	if ((-f $Result_file)) {
		my @RES = $FN =~ m/<DESCRIPTION>(.*)<\/DESCRIPTION>.*<FINALRESULT>(.*)<\/FINALRESULT>/s;
		$Description=$RES[0];
		$Description =~ s/\n/<br>/g;
		$Finalresult=$RES[1];
	}
	if ($Finalresult eq "PASSED")
	{	
		if ( ($E eq "LIST ALL") || ($E eq "LIST PASSED") ) { print color 'green'; print colored "\t\t$Topic-$N\n";}
	}
	elsif ($Finalresult eq "FAILED")
	{
		if ( ($E eq "LIST ALL") || ($E eq "LIST FAILED") ) { print color 'red'; print colored "\t\t$Topic-$N\n";}
	}
	else
	{
		if ( ($E eq "LIST ALL") || ($E eq "LIST UNTRIED") ) { print "\t\t$Topic-$N\n";}
	}

		}
	$N=$N+1;
	}
}



if ((scalar @ARGV) == 0) { 

	while( ($E eq "")||($E eq "LIST ALL")||($E eq "LIST FAILED")||($E eq "LIST PASSED")||($E eq "LIST UNTRIED")  )
	{
		system("clear");
		print "";
		print "Which exercise do you want to activate?\n\n";
		print "\t<TOPIC>-<ID> \tE.g.:05-user-group-1\n";
		print "\n";
		print "\tLIST ALL: \tShows every available exercise\n";
		print "\tLIST PASSED: \tShows only the passed exercises\n";
		print "\tLIST FAILED: \tShows only the tried but failed exercises\n";
		print "\tLIST UNTRIED: \tShows only the exercises you didn't tried yet\n\n";
		print "\tEXIT: \t\tExit\n\n";

		if ($E eq "EXIT") { exit 2; }
		if ($E eq "LIST ALL") { print "LIST ALL Exercises\n------------------\n\n"; }
		if ($E eq "LIST FAILED") { print "LIST FAILED Exercises\n---------------------\n\n"; }
		if ($E eq "LIST PASSED") { print "LIST PASSED Exercises\n---------------------\n\n"; }
		if ($E eq "LIST UNTRIED") { print "LIST UNTRIED Exercises\n----------------------\n\n"; }
		if (($E eq "LIST ALL")||($E eq "LIST FAILED")||($E eq "LIST PASSED")||($E eq "LIST UNTRIED")) {

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

		}
		print "\nYour choice: ";
		$E=<STDIN>;
		chomp($E);
		print "";
	}
}
else
{
	$E=$ARGV[0];
}

print "Activate $E...\n";

if (my @A = $E =~ m/(\d+-\D+)-(\d+)/)
{

	if (($A[0] ne "") && ($A[1] ne ""))
	{

		my $Topic=$A[0];
		my $Problem=$A[1];

		if (-f "/var/www/cgi-bin/$Topic/$Problem-activator") 
		{
			system("/var/www/cgi-bin/$Topic/$Problem-activator");
			exit 0;
		}
	}
	else
	{
		print("The given exercise doesn't exist!\n\n"); exit 1;
	}
}
else
{
	print("The given exercise doesn't exist!\n\n"); exit 1;
}

exit 1;



