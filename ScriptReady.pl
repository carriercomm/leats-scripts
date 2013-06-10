#!/usr/bin/perl


use lib '/scripts/common_perl/';
use Framework qw(&cryptText2File &decryptFile &getStudent);

use strict;
use warnings;

my $verbose=1;

my $CGI_HOME="/var/www/cgi-bin";
my $ALTS_HOME="/leats-scripts";
my $ALTS_RESULTS="/ALTS/RESULTS/";

my @files;

if ((scalar @ARGV) < 1)
{
        print "\n\nUsing of the script:\n";
        print "1. argument: Your scheckscript file\n";
        print "\t E.g ./ScriptReady /leats-scripts/02-physical_disk/1.pl or ./ScriptReady ALL (if you want to do it for every sources)\n";
        die;
}

if ($ARGV[0] eq "ALL" )
{
	@files=("/leats-scripts/01-boot/1.pl",
		"/leats-scripts/01-boot/2.pl",
		"/leats-scripts/01-boot/3.pl",
		"/leats-scripts/01-boot/4.pl",
		"/leats-scripts/02-physical_disk/1.pl",
		"/leats-scripts/02-physical_disk/2.pl",
		"/leats-scripts/02-physical_disk/3.pl",
		"/leats-scripts/02-physical_disk/4.pl",
		"/leats-scripts/02-physical_disk/5.pl",
		"/leats-scripts/02-physical_disk/6.pl",
		"/leats-scripts/02-physical_disk/7.pl",
		"/leats-scripts/02-physical_disk/8.pl",
		"/leats-scripts/03-lvm/1.pl",
		"/leats-scripts/04-network/1.pl",
		"/leats-scripts/04-network/2.pl",
		"/leats-scripts/04-network/3.pl",
		"/leats-scripts/04-network/4.pl",
		"/leats-scripts/04-network/5.pl",
		"/leats-scripts/05-user-group/1.pl",
		"/leats-scripts/05-user-group/2.pl",
		"/leats-scripts/05-user-group/3.pl",
		"/leats-scripts/05-user-group/4.pl",
		"/leats-scripts/05-user-group/5.pl",
		"/leats-scripts/05-user-group/6.pl",
		"/leats-scripts/05-user-group/7.pl",
		"/leats-scripts/05-user-group/8.pl",
		"/leats-scripts/05-user-group/9.pl",
		"/leats-scripts/05-user-group/10.pl",
		"/leats-scripts/05-user-group/11.pl",
		"/leats-scripts/06-rights/1.pl",
		"/leats-scripts/17-package/1.pl",
                "/leats-scripts/17-package/2.pl",
		"/leats-scripts/17-package/3.pl",
		"/leats-scripts/17-package/4.pl",
		"/leats-scripts/17-package/5.pl",
		"/leats-scripts/17-package/6.pl",
		"/leats-scripts/17-package/7.pl",
		"/leats-scripts/17-package/8.pl",
		"/leats-scripts/18-scripting/1.pl",
		"/leats-scripts/18-scripting/2.pl",
		"/leats-scripts/18-scripting/3.pl",
		"/leats-scripts/19-crontab/1.pl",
		"/leats-scripts/19-crontab/2.pl",
		"/leats-scripts/19-crontab/3.pl",
		"/leats-scripts/19-crontab/4.pl",
		"/leats-scripts/19-crontab/5.pl",);
}
else
{
	 @files=@ARGV;
}



foreach my $SourceFile (@files)
{
$verbose && print "\n$SourceFile will be transformed...\n";
my $file =`readlink -f $SourceFile`;

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
$verbose && print "Creating Description binary\n";
system ("perl /leats-scripts/Perl2SetUIDExecutable.pl '/ALTS/EXERCISES/$TN/$NN --description' '/ALTS/EXERCISES/$TN/$NN-description'");
$verbose && print "Creating Result binary\n";
system ("perl /leats-scripts/Perl2SetUIDExecutable.pl '/ALTS/EXERCISES/$TN/$NN --hint' '/ALTS/EXERCISES/$TN/$NN-hint'");
$verbose && print "Creating Hint binary\n";


system("/ALTS/EXERCISES/$TN/$NN --description > /ALTS/EXERCISES/$TN/$NN-description.txt");

system ("perl /leats-scripts/Perl2SetUIDExecutable.pl '/ALTS/lib/Results2Html /ALTS/RESULTS/ACTUAL/$TN-$NN' '/ALTS/EXERCISES/$TN/$NN-result' 2>/dev/null");
$verbose && print "Setup permissions\n";
system ("chmod 6555 /ALTS/EXERCISES/$TN/$NN-grade; chmod 6555 /ALTS/EXERCISES/$TN/$NN-break; chmod 6555 /ALTS/EXERCISES/$TN/$NN-result; chmod 6555 /ALTS/EXERCISES/$TN/$NN-description");

system("/ALTS/EXERCISES/$TN/$NN --description > /ALTS/EXERCISES/$TN/$NN-description.txt; chmod 0400 /ALTS/EXERCISES/$TN/$NN-description.txt");

$verbose && print "Creating Exercise activator\n";
system("mkdir $CGI_HOME/$TN/ 1>/dev/null 2>&1 ");
system ("perl /leats-scripts/Perl2SetUIDExecutable.pl 'unlink $CGI_HOME/Grade 1>/dev/null 2>&1; [ `/ALTS/lib/GetALTSParameter.pl GradeOnlyAfterBreak` != 0 ] && cp -p /ALTS/EXERCISES/$TN/$NN-grade $CGI_HOME/Grade 1>/dev/null 2>&1; chmod 6555 $CGI_HOME/Grade 2>/dev/null;cp -p /ALTS/EXERCISES/$TN/$NN-hint $CGI_HOME/Hint 1>/dev/null 2>&1; chmod 6555 $CGI_HOME/Hint 1>/dev/null 2>&1; cp -p /ALTS/EXERCISES/$TN/$NN-break $CGI_HOME/Break 1>/dev/null 2>&1; chmod 6555 $CGI_HOME/Break 1>/dev/null 2>&1; cp -p  /ALTS/EXERCISES/$TN/$NN-result $CGI_HOME/Result 1>/dev/null 2>&1; chmod 6555 $CGI_HOME/Result1>/dev/null 2>&1; cp -p /ALTS/EXERCISES/$TN/$NN-description $CGI_HOME/Description 1>/dev/null 2>&1; chmod 6555 $CGI_HOME/Description 1>/dev/null 2>&1; unlink /ALTS/Hint 1>/dev/null 2>&1; unlink /ALTS/Grade 1>/dev/null 2>&1; unlink /ALTS/Break 1>/dev/null 2>&1; unlink /ALTS/Description 1>/dev/null 2>&1; ln -s /var/www/cgi-bin/Grade /ALTS/Grade 1>/dev/null 2>&1; ln -s /var/www/cgi-bin/Break /ALTS/Break 1>/dev/null 2>&1; ln -s /var/www/cgi-bin/Description /ALTS/Description 1>/dev/null 2>&1; ln -s /var/www/cgi-bin/Hint /ALTS/Hint 1>/dev/null 2>&1;' '$CGI_HOME/$TN/$NN-activator'");
}

system("rm -rf /tmp/par*");

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
