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
our $author='Richard Gruber <gruberrichard@gmail.com>';
#our $author='Richard Gruber <richard.gruber@it-services.hu>';
our $version="v0.5";
our $topic="02-physical_disk";
our $problem="4";
our $description="LEVEL:  Beginner

A disk has been attached (/dev/vdb).
- Create a 10M large ext2 partition on it. (vdb1)
- Mount it under /tmp/test1
- Create a 20M large ext3 partition on it. (vdb2)
- Mount it under /tmp/test2
- Create a 30M large ext3 partition on it. (vdb3)
- Mount it under /tmp/test3
- Create a 40M large ext4 partition on it. (vdb4)
- Mount it under /tmp/test4
- Create a 50M large ext4 partition on it. (vdb5)
- Mount it under /tmp/test5
";

our $hint="Create a partition on the disk. (fdisk)
Mind that you have to use extended partition, because
you can define only 4 primary partitions and now you need 5.
Create a filesystem on them. (mkfs)
Mount them. (mount)";

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
use Disk qw($verbose $topic $author $version $hint $problem $name &checkMount &checkFilesystemType &checkPartitionSize &getFilerMountedFrom &getFilesystemParameter &checkFilesystemParameter &checkMountedWithUUID &checkMountedWithLABEL &checkMountOptions &checkSwapSize &RecreateVDisk &CreatePartition &CreateDirectory &checkMountOptions &fileEqual );
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

	RecreateVDisk("vdb","300","vdb");
        sleep(2);

	system("cp -p /ALTS/EXERCISES/$topic/$problem-grade /var/www/cgi-bin/Grade 1>/dev/null 2>&1; chmod 6555 /var/www/cgi-bin/Grade");

	print "Your task: $description\n";
}

sub grade() {
	system("clear");
	my $Student = Framework::getStudent();
	print "Grade has been selected.\n";
	print "rebooting server:";

#	Framework::restart;
#	Framework::timedconTo("120");

## Checking if mounted

	system("clear");
	my $T=$topic; $T =~ s/\s//g;
	$result_file="/ALTS/RESULTS/${Student}/${T}-${problem}"; #Empty the result file
	my $fn; open($fn,">","$result_file"); close($fn);
	my $now = strftime "%Y/%m/%d %H:%M:%S", localtime;
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

	

	printS("Checking mount:","$L");
	Framework::grade(checkMount("vdb","/tmp/test1"));

	printS("Checking size of filesystem is 10M:","$L");
	Framework::grade(checkPartitionSize("/tmp/test1","10","10"));

 	printS("Checking type filesystem is ext2:","$L");
        Framework::grade(checkFilesystemType("/tmp/test1","ext2"));

#-------

        printS("Checking mount:","$L");
        Framework::grade(checkMount("vdb","/tmp/test2"));

        printS("Checking size of filesystem is 20M:","$L");
        Framework::grade(checkPartitionSize("/tmp/test2","20","10"));

        printS("Checking type filesystem is ext3:","$L");
        Framework::grade(checkFilesystemType("/tmp/test2","ext3"));

#------

        printS("Checking mount:","$L");
        Framework::grade(checkMount("vdb","/tmp/test3"));

        printS("Checking size of filesystem is 30M:","$L");
        Framework::grade(checkPartitionSize("/tmp/test3","30","10"));

        printS("Checking type filesystem is ext4:","$L");
        Framework::grade(checkFilesystemType("/tmp/test3","ext3"));

#------

        printS("Checking mount:","$L");
        Framework::grade(checkMount("vdb","/tmp/test4"));

        printS("Checking size of filesystem is 40M:","$L");
        Framework::grade(checkPartitionSize("/tmp/test4","40","10"));

        printS("Checking type filesystem is ext4:","$L");
        Framework::grade(checkFilesystemType("/tmp/test4","ext4"));

#------

        printS("Checking mount:","$L");
        Framework::grade(checkMount("vdb","/tmp/test5"));

        printS("Checking size of filesystem is 50M:","$L");
        Framework::grade(checkPartitionSize("/tmp/test5","50","10"));

        printS("Checking type filesystem is ext4:","$L");
        Framework::grade(checkFilesystemType("/tmp/test5","ext4"));

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
        $verbose and print "Reseting server machine...\n";
        system("/ALTS/RESET");

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
