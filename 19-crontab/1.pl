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
our $author='Richard Gruber <richard.gruber@it-services.hu>';
our $version="v0.95";
our $topic="19-crontab";
our $problem="1";
our $description="- User william's crontab has to be denied
- User john has to run \"/bin/echo 'crontab exam test'\" every day at 5:25
- User rudolf has to run \"whoami\" in every hours 16th minute";
our $hint="";
#
#
#
#############
our $verbose=0;
my $help=0;
my $break=0;
my $grade=0;
my $hint=0;
use strict;
use warnings;
use Getopt::Long;
use Term::ANSIColor;
use File::Basename;
use POSIX qw/strftime/;
our $name=basename($0);
use lib '/scripts/common_perl/';
use Framework qw($verbose $topic $author $version $hint $problem $name $exercise_number $exercise_success $student_file $result_file &printS &cryptText2File &decryptFile);
use UserGroup qw( &checkUserCrontabDenied &setupGroup &setupUser &delUser &delGroup &checkUserCrontab );
######
###Options
###
GetOptions("help|?|h" => \$help,
		"verbose|v" => \$verbose,
		"b|break" => \$break,
		"g|grade" => \$grade,
		"hint" => \$hint,
	  );

#####
# Subs
#
sub break() {
	print "Break has been selected.\n";
	&pre();

	$verbose and print "Pre complete breaking\n";	
	print "Your task: $description\n";
}

sub grade() {

	system("clear");
	my $Student = Framework::getStudent();

	system("clear");
	my $T=$topic; $T =~ s/\s//g;
	$result_file="/ALTS/RESULTS/${T}/${problem}"; #Empty the result file
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



	printS("william's crontab is denied","$L");
	Framework::grade(UserGroup::checkUserCrontabDenied("william"));

	printS("tihamer run \"/bin/echo 'crontab exam test'\" every day at 5:25","$L");
	Framework::grade(checkUserCrontab("tihamer","25","5","*","*","*","/bin/echo 'crontab exam test'"));

	printS("rudolf run \"whoami\" in every hours 16th minute","$L");
	Framework::grade(checkUserCrontab("rudolf","16","*","*","*","*","whoami"));


	print "\n"."="x$L."=========\n";
	print "\n\tNumber of exercises: \t$exercise_number\n";
	print "\n\tSuccessful: \t\t$exercise_success\n";
	if ($exercise_number == $exercise_success) {
		cryptText2File("<TASKNUMBER>$exercise_number</TASKNUMBER><TASKSUCCESSFUL>$exercise_success</TASKSUCCESSFUL><FINALRESULT>PASSED</FINALRESULT></ROOT>","$result_file");
		print color 'bold green' and print "\n\n\tSuccessful grade.\n\n"  and print color 'reset' and exit 0;
		&post();
	}
	else
	{
		cryptText2File("<TASKNUMBER>$exercise_number</TASKNUMBER><TASKSUCCESSFUL>$exercise_success</TASKSUCCESSFUL><FINALRESULT>FAILED</FINALRESULT></ROOT>","$result_file");
		print color 'bold red' and print "\n\n\tUnsuccessful grade. Please try it again!\n\n"  and print color 'reset' and exit 1;
	}



}

sub pre() {
### Prepare the machine 
	$verbose and print "Running pre section\n";
	$verbose and print "Delete user william..\n";
	delUser("william","true");
  	$verbose and print "Delete user tihamer..\n";
        delUser("tihamer","true");
        $verbose and print "Delete user rudolf..\n";
        delUser("rudolf","true");
	$verbose and print "Delete group william..\n";
        delGroup("william");
	$verbose and print "Delete group tihamer..\n";
        delGroup("tihamer");
	$verbose and print "Create user william..\n";
	setupUser("william","3446","","","","","/bin/bash","true");
	$verbose and print "Create user tihamer..\n";
	setupUser("tihamer","4999","tihamer","ftp","/home/tihamer","This is Tihamer","/bin/bash","true");
	$verbose and print "Create user rudolf..\n";
	setupUser("rudolf","7929","","","","","/bin/bash","true");
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
