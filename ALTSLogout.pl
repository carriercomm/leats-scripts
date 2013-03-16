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
	print color 'bold green' and print "\n\n\tLogout Successful!\n\n\n"  and print color 'reset' and exit 0;
}
else
{
	print color 'bold red' and print "\n\n\n\tLogout Failed!\n\n\n"  and print color 'reset' and exit 1;
}

exit 0;
