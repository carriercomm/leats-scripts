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
our $author='Krisztian Banhidy <krisztian@banhidy.hu>
Richard Gruber <gruberrichard@gmail.com>';
#our $author='Richard Gruber <richard.gruber@it-services.hu>';
our $version="v0.5";
our $topic="02-physical_disk";
our $problem="1";
our $description="Additional disk has been added to your server. Initialize it, 
create a 100 MB (+-10%) ext3 partition on it and persistently mount it on /mnt/das.
Set the label of the filesystem to test1-label.
There must be \"rw\" and \"acl\" among the mount options
Increase Swap size with 50M (+-5%)\n";
our $hint="Find the device with fdisk, create a partition, \nthen create a filesystem and create entry in fstab\n";
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
#use Sys::Virt;
use lib '/scripts/common_perl/';
use Framework qw($verbose $topic $author $version $hint $problem $name $exercise_number $exercise_success $student_file $result_file &printS &cryptText2File &decryptFile &getStudent &EncryptResultFile &DecryptResultFile $description &showdescription);
use Disk qw($verbose $topic $author $version $hint $problem $name &checkMount &checkFilesystemType &checkPartitionSize &getFilerMountedFrom &getFilesystemParameter &checkFilesystemParameter &checkMountedWithUUID &checkMountedWithLABEL &checkMountOptions &checkSwapSize &RecreateVDisk );
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

	$verbose and print "Pre complete breaking\n";

#	RecreateVDisk("vdb","300","vdb");
	
#	$verbose and print "Reboot server";	

#	Framework::restart;
#	Framework::grade(Framework::timedconTo("60"));

#	my $ret=Disk::lv_create("vdb","200","vdb");
#	if ( $ret != 0 ) {
#		$verbose and print "Trying to repair.\n";
#		Disk::lv_remove("vdb");
#		Disk::lv_create("vdb","200","vdb");
#	} else {
#		print "Disk attached to server. Local disk is vdb\n";
#	}

	system("cp -p /ALTS/EXERCISES/$topic/$problem-grade /var/www/cgi-bin/Grade 1>/dev/null 2>&1; chmod 6555 /var/www/cgi-bin/Grade");

	print "Your task: $description\n";
}

sub grade() {
	system("clear");
	my $Student = Framework::getStudent();
	print "Grade has been selected.\n";
	print "rebooting server:";
###########
#kikommentelni!!!!
#
#	Framework::restart;
#	Framework::grade(Framework::timedconTo("60"));
## Checking if mounted
#

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

	


	printS("Checking mount:","$L");
	Framework::grade(checkMount("vdb","/mnt/das/"));

	printS("Checking filesystem type:","$L");
	Framework::grade(checkFilesystemType(&getFilerMountedFrom('/mnt/das'),"ext3"));

	printS("Checking size:","$L");
	Framework::grade(checkPartitionSize(&getFilerMountedFrom('/mnt/das'),"100","10"));

	printS("Checking Label is test1-label: ","$L");
	Framework::grade(checkFilesystemParameter(&getFilerMountedFrom('/mnt/das'),"LABEL","test1-label"));

	#printS("Checking mounted with UUID: ","$L");
	#Framework::grade(checkMountedWithUUID("/mnt/das"));

	printS("Checking mounted with LABEL: ","$L");
	Framework::grade(checkMountedWithLABEL("/mnt/das"));

	printS("Checking mounted with \"rw\" and \"acl\" options: ","$L");		
	Framework::grade(checkMountOptions("/mnt/das","rw,acl"));

	printS("Checking swap size increased with 50M: ","$L");
	Framework::grade(checkSwapSize("561","5"));





	print "\n"."="x$L."=========\n";
	print "\n\tNumber of exercises: \t$exercise_number\n";
	print "\n\tSuccessful: \t\t$exercise_success\n";
	if ($exercise_number == $exercise_success) {
		cryptText2File("<TASKNUMBER>$exercise_number</TASKNUMBER><TASKSUCCESSFUL>$exercise_success</TASKSUCCESSFUL><FINALRESULT>PASSED</FINALRESULT></ROOT>","$result_file");
		print color 'bold green' and print "\n\n\tSuccessful grade.\n\n"  and print color 'reset';
		&EncryptResultFile();
		exit 0;;
		#Running post
		&post();
	}
	else
	{
		cryptText2File("<TASKNUMBER>$exercise_number</TASKNUMBER><TASKSUCCESSFUL>$exercise_success</TASKSUCCESSFUL><FINALRESULT>FAILED</FINALRESULT></ROOT>","$result_file");
		&EncryptResultFile();
		print color 'bold red' and print "\n\n\tUnsuccessful grade. Please try it again!\n\n"  and print color 'reset';
		exit 1;
	}
}

sub pre() {
### Prepare the machine 
	$verbose and print "Running pre section\n";
	my $free=Disk::lvm_free;
	$verbose and print "Free space :$free\n";
	if ( $free > 1000 ) {
		$verbose and print "We have enough space to continue.\n";
	} else {
		print "Not enough space on server. We need to free up some space.";
		if ( Disk::lv_count ne 4 ) {
			print "You have " . Disk::lv_count . " lv-s on the server instead of 4. We should restore default settings.\n";
			Disk::base;
		} else {
			print "Count is ok. Dev should investigate problem.\n";
			exit 1;
		}
	}
}

sub post() {
### Cleanup after succeful grade
	$verbose and print "Successful grade doing some cleanup.\n";
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

if ( $desc ) {
	Framework::showdescription;
}

if ( $break ) {
	&break;
} elsif ( $grade ) {
	&grade;
} else {
	print "Nothing has been selected. Please select one option.\n";
	Framework::useage;
}
