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
our $topic="05-user-group";
our $problem="3";
our $description="- create the following users: john, mary and thomas
- create a group named tadmins with GID 885
- john's UID is 2342, his home directory is /home/john.
- mary's UID is 5556 and her default shell is /bin/bash.
- thomas should not have access to any shell
- the users john and mary are members of the group tadmins.
- thomas should not be in the group tadmins.
- change all users password to kuka002
- john's account will expire on 2025-12-12";
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
use UserGroup qw(userExist groupExist getUserAttribute checkUserAttribute checkUserPassword &checkUserGroupMembership &checkUserSecondaryGroupMembership &checkUserPrimaryGroup &checkGroupNameAndID &checkUserChageAttribute &checkUserLocked &delUser &delGroup &checkUserHasNoShellAccess );
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
	&pre();

        $verbose and print "Reset server\n";
        system("/ALTS/RESET");

        system("cp -p /ALTS/EXERCISES/$topic/$problem-grade /var/www/cgi-bin/Grade 1>/dev/null 2>&1; chmod 6555 /var/www/cgi-bin/Grade");

	$verbose and print "Pre complete breaking\n";	
	print "Your task: $description\n";
}

sub grade() {

	system("clear");
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



	printS("User mary exist","$L");
	Framework::grade(UserGroup::userExist("mary"));

	printS("User john exist","$L");
	Framework::grade(UserGroup::userExist("john"));

	printS("User thomas exist","$L");
	Framework::grade(UserGroup::userExist("thomas"));

	printS("Group tadmins exist","$L");
	Framework::grade(UserGroup::groupExist("tadmins"));

	printS("Group tadmins with GID 885","$L");
	Framework::grade(checkGroupNameAndID("tadmins","885"));

	printS("John's UID is 2342:","$L");
	Framework::grade(UserGroup::checkUserAttribute("john","UID","2342"));

	printS("john's home directory is /home/john:","$L");
	Framework::grade(UserGroup::checkUserAttribute("john","HOME","/home/john"));

	printS("Mary's UID is 5556","$L");
	Framework::grade(UserGroup::checkUserAttribute("mary","UID","5556"));

	printS("Mary's default shell is /bin/bash:","$L");
	Framework::grade(UserGroup::checkUserAttribute("mary","SHELL","/bin/bash"));

	printS("Thomas should not have access to any shell:","$L");
	Framework::grade(UserGroup::checkUserHasNoShellAccess("thomas"));

	printS("User john is in Group tadmins:","$L");
	Framework::grade(checkUserGroupMembership("john","tadmins"));	

	printS("User mary is in Group tadmins:","$L");
	Framework::grade(checkUserGroupMembership("mary","tadmins"));

	printS("User thomas isn't in Group tadmins:","$L");
	Framework::grade(userExist("thomas"),(!checkUserGroupMembership("thomas","tadmins")));

	printS("John's password is kuka002","$L");
	Framework::grade(checkUserPassword("john","kuka002"));

	printS("Mary's password is kuka002","$L");
	Framework::grade(checkUserPassword("mary","kuka002"));

	printS("Thomas's password is kuka002","$L");
	Framework::grade(checkUserPassword("thomas","kuka002"));

	printS("john's account will expire on 2025-12-12","$L");
	Framework::grade(checkUserChageAttribute("john","EXPIRE_DATE","2025-12-12"));


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
	delUser("mary","true");
	delUser("thomas","true");
	delUser("john","true");
	delGroup("tadmins");
	delGroup("mary");
	delGroup("thomas");
	delGroup("john");
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
