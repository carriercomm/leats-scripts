#!/usr/bin/perl


use lib '/scripts/common_perl/';
use Framework qw(&cryptText2File &decryptFile &getStudent);

use strict;
use warnings;

my $verbose=1;

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

$verbose && print "$ARGV[0] will be transformed...\n";

my $file =`readlink -f $ARGV[0]`;

#print "FILE: $file\n\n";

my @D = $file =~ m/\/leats-scripts\/(\d+[^\/]+)\/(.*).pl/g;

my $TN=$D[0];
my $NN=$D[1];

#print "Directory =$D[0]  | Topic number. $TN $NN\n\n";

$verbose && print "Creating directory /ALTS/EXERCISES/$TN\n";
system("mkdir -p /ALTS/EXERCISES/$TN; chmod 700 /ALTS/EXERCISES/$TN");
#Create the binaries
$verbose && print "Creating binary /ALTS/EXERCISES/$TN/$NN\n";
system ("pp -o /ALTS/EXERCISES/$TN/$NN $file");
$verbose && print "Creating Grade binary\n";
system ("perl /leats-scripts/Perl2SetUIDExecutable.pl '/ALTS/EXERCISES/$TN/$NN --grade' '/ALTS/EXERCISES/$TN/$NN-grade'");
$verbose && print "Creating Break binary\n";
system ("perl /leats-scripts/Perl2SetUIDExecutable.pl '/ALTS/EXERCISES/$TN/$NN --break' '/ALTS/EXERCISES/$TN/$NN-break'");
$verbose && print "Creating Result binary\n";
system ("perl /leats-scripts/Perl2SetUIDExecutable.pl '/ALTS/lib/Results2Html /ALTS/RESULTS/ACTUAL/$TN-$NN' '/ALTS/EXERCISES/$TN/$NN-result'");
$verbose && print "Creating Exercise activator\n";
system("mkdir $CGI_HOME/$TN/ 1>/dev/null 2>&1 ");
system ("perl /leats-scripts/Perl2SetUIDExecutable.pl 'cp /ALTS/EXERCISES/$TN/$NN-grade $CGI_HOME/Grade; cp /ALTS/EXERCISES/$TN/$NN-break $CGI_HOME/Break; cp  /ALTS/EXERCISES/$TN/$NN-result $CGI_HOME/Result;' '$CGI_HOME/$TN/$NN-activator'");
system ("chmod 6555 /ALTS/EXERCISES/$TN/$NN-grade; chmod 6555 /ALTS/EXERCISES/$TN/$NN-break; chmod 6555 /ALTS/EXERCISES/$TN/$NN-result;")


#Create the SETIUID binary for CGI
#print "Creating $CGI_HOME/${TN}-$NN-grade..\n";
#system ("perl $ALTS_HOME/Perl2SetUIDExecutable.pl '$CGI_HOME/${TN}-$NN --grade' $CGI_HOME/${TN}-$NN-grade");
#system("chmod 4555 $CGI_HOME/${TN}-$NN-grade");

#Create the SETIUID binary for CGI
#print "Creating $CGI_HOME/${TN}-$NN-break..\n";
#system ("perl $ALTS_HOME/Perl2SetUIDExecutable.pl '$CGI_HOME/${TN}-$NN --break' $CGI_HOME/${TN}-$NN-break");
#system("chmod 4555 $CGI_HOME/${TN}-$NN-break");


#Create the SETIUID binary for CGI
#rigruber-02-physical_disk-1
#print "Creating $CGI_HOME/${TN}-$NN-result..\n";
#system ("perl $ALTS_HOME/Results2Html.pl '$ALTS_RESULTS/$student-${TN}-$NN'");
#system("chmod 4555 $CGI_HOME/${TN}-$NN-result");
