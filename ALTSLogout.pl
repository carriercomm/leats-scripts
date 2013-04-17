#!/usr/bin/perl

use lib '/scripts/common_perl/';
use Framework qw(&cryptText2File &decryptFile $student_file);
use Term::ANSIColor;


my $fn; open($fn,">","$student_file"); print $fn ""; close($fn);

my $F=decryptFile("$student_file");
chomp($F);

        system("clear");
        my $L=20;
        print "="x$L."=========\n";
        print "   ALTS User Logout\n";
        print "="x$L."=========\n";


if ($F eq "")
{
	system("chmod 700 /ALTS/EXERCISES");
 	system("unlink /ALTS/RESULTS/ACTUAL 1>/dev/null 2>&1");
        system("unlink /ALTS/Grade 1>/dev/null 2>&1; unlink /ALTS/Break 1>/dev/null 2>&1; unlink /ALTS/Description 1>/dev/null 2>&1;unlink /ALTS/Hint 1>/dev/null 2>&1;");
	system("rm -rf /var/www/cgi-bin/Grade 2>/dev/null;rm -rf /var/www/cgi-bin/Break 2>/dev/null;rm -rf /var/www/cgi-bin/Description 2>/dev/null;rm -rf /var/www/cgi-bin/Result 2>/dev/null");
	print color 'bold green' and print "\n\n\tLogout Successful!\n\n\n"  and print color 'reset' and exit 0;
}
else
{
	print color 'bold red' and print "\n\n\n\tLogout Failed!\n\n\n"  and print color 'reset' and exit 1;
}

exit 0;
