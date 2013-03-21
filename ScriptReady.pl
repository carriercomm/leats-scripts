#!/usr/bin/perl


use lib '/scripts/common_perl/';
use Framework qw(&cryptText2File &decryptFile &getStudent);

use strict;
use warnings;


my $CGI_HOME="/var/www/cgi-bin";
my $ALTS_HOME="/leats-scripts";
my $ALTS_RESULTS="/ALTS/RESULTS/";


if ((scalar @ARGV) < 1)
{
        print "\n\nUsing of the script:\n";
        print "1. argument: Your scheckscript file\n";
        print "\t E.g ./ScriptReady /leats-scripts/02-physical_disk/1.pl \n\n";
        die;
}

my $student=Framework::getStudent();

print "Student= $student\n\n";

print "$ARGV[0] will be transformed...\n";

my $file =`readlink -f $ARGV[0]`;

#print "FILE: $file\n\n";

my @D = $file =~ m/\/leats-scripts\/(\d+[^\/]+)\/(.*).pl/g;

my $TN=$D[0];
my $NN=$D[1];

#print "Directory =$D[0]  | Topic number. $TN $NN\n\n";

#Create the binary
system ("pp -o $CGI_HOME/${TN}-$NN $file");

#Create the SETIUID binary for CGI
print "Creating $CGI_HOME/${TN}-$NN-grade..\n";
system ("perl $ALTS_HOME/Perl2SetUIDExecutable.pl '$CGI_HOME/${TN}-$NN --grade' $CGI_HOME/${TN}-$NN-grade");
system("chmod 4555 $CGI_HOME/${TN}-$NN-grade");

#Create the SETIUID binary for CGI
print "Creating $CGI_HOME/${TN}-$NN-break..\n";
system ("perl $ALTS_HOME/Perl2SetUIDExecutable.pl '$CGI_HOME/${TN}-$NN --break' $CGI_HOME/${TN}-$NN-break");
system("chmod 4555 $CGI_HOME/${TN}-$NN-break");


#Create the SETIUID binary for CGI
#rigruber-02-physical_disk-1
#print "Creating $CGI_HOME/${TN}-$NN-result..\n";
#system ("perl $ALTS_HOME/Results2Html.pl '$ALTS_RESULTS/$student-${TN}-$NN'");
#system("chmod 4555 $CGI_HOME/${TN}-$NN-result");
