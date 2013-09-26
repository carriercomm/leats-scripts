#!/usr/bin/perl
# Changelog
# =======================================
# v1.0 Krisztian Banhidy initial release
#
#This file is part of Leats.
##
##Leats is free software: you can redistribute it and/or modify
##it under the terms of the GNU General Public License as published by
##the Free Software Foundation, either version 3 of the License, or
##(at your option) any later version.
##
##Leats is distributed in the hope that it will be useful,
##but WITHOUT ANY WARRANTY; without even the implied warranty of
##MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
##GNU General Public License for more details.
##
##You should have received a copy of the GNU General Public License
##along with Leats.  If not, see <http://www.gnu.org/licenses/>.
#############
#our $author='Krisztian Banhidy <krisztian@banhidy.hu>';
our $author='Richard Gruber <gruberrichard@gmail.com>';
our $version="v0.95";
our $topic="12-system";
our $problem="2";
our $description="LEVEL:        Beginner

There is only a few free bytes of memory left on the system.
Find the process, which use the memory and kill it.";

our $hint="Find the process and get the Process ID. (top)
Kill it. (kill)";
#
#
#
#############
our $verbose=0;
my $help=0;
my $break=0;
my $grade=0;
my $hint=0;
my $desc=0;
use strict;
use warnings;
use Getopt::Long;
use Term::ANSIColor;
use File::Basename;
use POSIX qw/strftime/;
our $name=basename($0);
use lib '/scripts/common_perl/';
use Framework qw($verbose $topic $author $version $hint $problem $name $exercise_number $exercise_success $student_file $result_file &printS &cryptText2File &decryptFile &EncryptResultFile $description &showdescription);
use System qw( &checkProcessIsRunning &checkProcessIsntRunning &CopyFromDesktop );
######
###Options
###
GetOptions("help|?|h" => \$help,
		"verbose|v" => \$verbose,
		"b|break" => \$break,
		"g|grade" => \$grade,
		"hint" => \$hint,
		"d|description" => \$desc,
	  );

#####
# Subs
#
sub break() {
	print "Break has been selected.\n";
	&pre(); #Reseting Server machine

        $verbose and print "Running pre section\n";

	System::CopyFromDesktop("/ALTS/ExerciseScripts/MEater.pl","/usr/bin/MEater.pl","755","root","root");
	System::CopyFromDesktop("/ALTS/ExerciseScripts/MEater-service.sh","/etc/init.d/ALTS","755","root","root");

        my $ssh=Framework::ssh_connect;
        my $output=$ssh->capture('ln -s /etc/init.d/ALTS /etc/rc3.d/S99ALTS; ln -s /etc/init.d/ALTS /etc/rc5.d/S99ALTS; /etc/init.d/ALTS start >/dev/null 2>&1 &');

	sleep 15;
        system("cp -p /ALTS/EXERCISES/$topic/$problem-grade /var/www/cgi-bin/Grade 1>/dev/null 2>&1; chmod 6555 /var/www/cgi-bin/Grade");

	$verbose and print "Pre complete breaking\n";	
	print "Your task: $description\n";
}

sub grade() {

	system("clear");
	print "Grade has been selected";
	my $Student = Framework::getStudent();

	system("clear");
	my $T=$topic; $T =~ s/\s//g;
	$result_file="/ALTS/RESULTS/${Student}/${T}-${problem}"; #Empty the result file

	my $fn; open($fn,">","$result_file"); close($fn);
	my $now = strftime "%Y/%m/%d %H:%M:%S", localtime;
	$exercise_number = 0;
	$exercise_success = 0;

	my $L=80;


	print "="x$L."=========\n";
	print "Student:\t$Student\n\n";
	print "Date:   \t$now\n";
	print "-"x$L."---------\n\n";
	print "$topic/$problem\n";
	print "\n$description\n\n";
	print "="x$L."=========\n\n";

	my $USERDATA=decryptFile("$student_file");
	cryptText2File("<ROOT>$USERDATA<DATE>$now</DATE><TOPIC>$topic</TOPIC><PROBLEM>$problem</PROBLEM><DESCRIPTION>$description</DESCRIPTION>","$result_file");


	printS("The script doesn't running anymore","$L");
	Framework::grade(System::checkProcessIsntRunning("MEater.pl"));


	print "\n"."="x$L."=========\n";
	print "\n\tNumber of exercises: \t$exercise_number\n";
	print "\n\tSuccessful: \t\t$exercise_success\n";
	if ($exercise_number == $exercise_success) {
		cryptText2File("<TASKNUMBER>$exercise_number</TASKNUMBER><TASKSUCCESSFUL>$exercise_success</TASKSUCCESSFUL><FINALRESULT>PASSED</FINALRESULT></ROOT>","$result_file");
		print color 'bold green' and print "\n\n\tSuccessful grade.\n\n"  and print color 'reset';
		&EncryptResultFile();
		&post();
		exit 0;
	}
	else
	{
		cryptText2File("<TASKNUMBER>$exercise_number</TASKNUMBER><TASKSUCCESSFUL>$exercise_success</TASKSUCCESSFUL><FINALRESULT>FAILED</FINALRESULT></ROOT>","$result_file");
		print color 'bold red' and print "\n\n\tUnsuccessful grade. Please try it again!\n\n"  and print color 'reset';
		&EncryptResultFile();
		exit 1;
	}



}

sub pre() {
### Prepare the machine 

	$verbose and print "Running pre section\n";
        $verbose and print "Reset server\n";
        system("/ALTS/RESET");
}

sub post() {
### Cleanup after succeful grade
}

#####
# Main
if ( $help ) {
	Framework::useage;
}

if ( $hint ) {
	Framework::hint;
}

if ( $desc ) {
        Framework::showdescription;
}


if ( $grade and $break ) {
	print "Break and grade cannot be requested at one time.\n";
	Framework::useage;
}

if ( $break ) {
	&break;
} elsif ( $grade ) {
	&grade;
} else {
	print "Nothing has been selected. Please select one option.\n";
	Framework::useage;
}
