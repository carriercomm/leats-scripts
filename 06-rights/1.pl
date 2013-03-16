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
our $version="v0.2";
our $topic="Rights";
our $problem="1";
our $description="Make sure that the following settings are set up
- Copy /etc/issue to /tmp as test
- Copy /etc/crontab to /tmp as test2
- User tihamer can write /tmp/test
- The owner of /tmp/test must be tihamer
- The group of /tmp/test must be group1
- Create a symlink to /etc/group with the name /tmp/testsymlink
- Create a directory /tmp/testdir
- The group of every newly created file in /tmp/testdir is group1
- Members of group1 can read and write /tmp/test
- Members of group1 can read, write and execute /tmp/test2
- SETUID has to be set on /tmp/test2
- STICKY must not be set on /tmp/test
- Other can't read, write or execute /tmp/test and /tmp/test2

";
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
use Exporter;
use POSIX qw/strftime/;
our $name=basename($0);
use lib '/scripts/common_perl/';
use Framework qw($verbose $topic $author $version $hint $problem $name $exercise_number $exercise_success $student_file $result_file &printS &cryptText2File &decryptFile);
use UserGroup qw($verbose &userExist &groupExist &getUserAttribute &checkUserAttribute &checkUserPassword &checkUserGroupMembership &checkUserSecondaryGroupMembership &checkUserPrimaryGroup &checkGroupNameAndID &checkUserChageAttribute &checkUserLocked &setupUser &setupGroup &delGroup &delUser &checkUserFilePermission &checkGroupFilePermission &checkOtherFilePermission &checkUserFileSpecialPermission &checkNewlyCreatedFilesAttributes );
use Disk qw(&fileEqual &checkOwner &checkGroup &checkType &checkSymlink &Delete &Move &Copy);
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

	my $T=$topic; $T =~ s/\s//g;
	$result_file="/ALTS/RESULTS/${T}-${problem}"; #Empty the result file
		my $fn; open($fn,">","$result_file"); close($fn);
	my $now = strftime "%Y/%d/%m %H:%M:%S", localtime;
	$exercise_number = 0;
	$exercise_success = 0;

	my $L=65;

	print "="x$L."=========\n";
	print "Student:\t$Student\n\n";
	print "Date:   \t$now\n";
	print "-"x$L."---------\n\n";
	print "$topic/$problem\n";
	print "\n$description\n\n";
	print "="x$L."=========\n\n";

	my $USERDATA=decryptFile("$student_file");
	cryptText2File("<ROOT>$USERDATA<DATE>$now</DATE><TOPIC>$topic</TOPIC><PROBLEM>$problem</PROBLEM><DESCRIPTION>$description</DESCRIPTION>","$result_file");


	printS("/etc/issue equals /tmp/test","$L");
	Framework::grade(fileEqual("/etc/issue","/tmp/test"));

	printS("/etc/crontab equals /tmp/test2","$L");
	Framework::grade(fileEqual("/etc/crontab","/tmp/test2"));

	printS("User tihamer can write /tmp/test","$L");
	Framework::grade(checkUserFilePermission("tihamer","/tmp/test","*w*"));

	printS("The owner of /tmp/test is tihamer","$L");
	Framework::grade(checkOwner("/tmp/test","tihamer"));

	printS("The group of /tmp/test is group1","$L");
	Framework::grade(checkGroup("/tmp/test","group1"));		

	printS("Symlink from /etc/group to /tmp/testsymlink","$L");
	Framework::grade(checkSymlink("/etc/group","/tmp/testsymlink"));

	printS("Directory /tmo/testdir exist","$L");
	Framework::grade(checkType("/tmp/testdir","directory"));

	printS("The group of every newly created file in this directory is group1","$L");
	Framework::grade(checkNewlyCreatedFilesAttributes("/tmp/testdir","group1","","","","",""));

	printS("Members of group1 can read and write /tmp/test","$L");
	Framework::grade(checkGroupFilePermission("group1","/tmp/test","rw*"));

	printS("Members of group1 can read, write and execute /tmp/test2","$L");
	Framework::grade(checkGroupFilePermission("group1","/tmp/test2","rwx"));

	printS("SETUID set on /tmp/test2","$L");
	Framework::grade(checkUserFileSpecialPermission("/tmp/test2","SETUID"));

	printS("STICKY not set on /tmp/test","$L");
	Framework::grade(checkUserFileSpecialPermission("/tmp/test","NO_STICKY"));	

	printS("Other can't read, write or execute both","$L");
	Framework::grade(checkOtherFilePermission("/tmp/test","---"),checkOtherFilePermission("/tmp/test2","---"));


	print "\n"."="x$L."=========\n";
	print "\n\tNumber of exercises: \t$exercise_number\n";
	print "\n\tSuccessful: \t\t$exercise_success\n";
	if ($exercise_number == $exercise_success) {
		cryptText2File("<TASKNUMBER>$exercise_number</TASKNUMBER><TASKSUCCESSFUL>$exercise_success</TASKSUCCESSFUL><FINALRESULT>PASSED</FINALRESULT></ROOT>","$result_file");
		print color 'bold green' and print "\n\n\tSuccessful grade.\n\n"  and print color 'reset' and exit 0;;
#Running Post
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

	setupGroup("group1","5678","tihamer");
	setupUser("tihamer","4999","tihamer","ftp","/home/tihamer","This is Tihamer","/bin/bash","true");
	Delete("/tmp/test","/tmp/test2","/tmp/testsymlink","/tmp/testdir");	
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
