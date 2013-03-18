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
our $version="v0.1";
our $topic="ALTS";
our $problem="ARSENAL";
our $description="You can use this as an arsenal for new exercises";
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
use strict;
use warnings;
use Getopt::Long;
use Term::ANSIColor;
use File::Basename;
use POSIX qw/strftime/;
our $name=basename($0);

our @ALTS_MODULES=("Disk");

#use Sys::Virt;
use lib '/scripts/common_perl/';
use Framework qw($verbose $topic $author $version $hint $problem $name $exercise_number $exercise_success $student_file $result_file &printS &cryptText2File &decryptFile &getStudent);
use Disk qw($verbose $topic $author $version $hint $problem $name &checkMount &checkFilesystemType &checkPartitionSize &getFilerMountedFrom &getFilesystemParameter &checkFilesystemParameter &checkMountedWithUUID &checkMountedWithLABEL &checkMountOptions &checkSwapSize &checkVGExist &getVGData &checkVGData &checkLVExist &getLVData &checkLVData &CreatePartition &fileEqual &checkOwner &checkGroup &checkType &checkSymlink &Delete &Move &Copy &checkSwapSize &RecreateVDisk );


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
	my $ret=Disk::lv_create("vdb","200","vdb");
	if ( $ret != 0 ) {
		$verbose and print "Trying to repair.\n";
		Disk::lv_remove("vdb");
		Disk::lv_create("vdb","200","vdb");
	} else {
		print "Disk attached to server. Local disk is vdb\n";
	}
	print "Your task: $description\n";
}

sub MODULE($)
{
	print color 'cyan';
#	print "="x20."\n${_[0]}\n"."="x20."\n";
	my $K=55;
	print "="x$K."\n$_[0]\n"."="x$K."\n";
	print color 'reset';
}

sub MMODULE($)
{
        print color 'cyan';
	my $Length=length($_[0]);
        print "\n"."-"x$Length."\n"."$_[0]\n"."-"x$Length."\n";
        print color 'reset';
}


sub EXERCISE($;$)
{
	print color 'yellow';
	print "\n${_[1]}\t\n";
	print color 'reset';

	print color 'bold white';
	print "${_[0]}\n\n\t";
	print color 'reset';
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
	$result_file="/ALTS/RESULTS/${T}-${problem}"; #Empty the result file
	my $fn; open($fn,">","$result_file"); close($fn);
	my $now = strftime "%Y/%m/%d %H:%M:%S", localtime;
	$exercise_number = 0;
	$exercise_success = 0;

	my $L=80;

	my $USERDATA=decryptFile("$student_file");
	cryptText2File("<ROOT>$USERDATA<DATE>$now</DATE><TOPIC>$topic</TOPIC><PROBLEM>$problem</PROBLEM><DESCRIPTION>$description</DESCRIPTION>","$result_file");	

#	if ("1" ~~ @ALTS_MODULES)
#	{
#		MODULE("Module 1: Boot");
#	}

	if ("Disk" ~~ @ALTS_MODULES)
	{	

MODULE("Disk.pm Module");


  MMODULE("LVM SPECIFIC (Disk.pm)");

                EXERCISE("Checking if VG exist",'checkVGExist("testVG")');
                printS("Checking volume group testVG exist:","$L");
                Framework::grade(checkVGExist("testVG"));

                EXERCISE("Checking if LV exist",'checkVGExist("testVG","testLV")');
                printS("Checking logical volume LV in volume group testVG exist:","$L");
                Framework::grade(checkLVExist("testVG","testLV"));
		
		#VGSize, PESize, PEFree, FreeSize

                EXERCISE("Checking VG's size in MB",'checkVGData("testVG","VGSize",96)');
                printS("Checking size of testVG is 96M:","$L");
                Framework::grade(checkVGData("testVG","VGSize",96));

                EXERCISE("Checking VG's PE size in MB",'checkVGData("testVG","PESize",4)');
                printS("Checking PE of testVG is 4M:","$L");
                Framework::grade(checkVGData("testVG","PESize",4));

                EXERCISE("Checking free PEs of VG",'checkVGData("testVG","PEFree",14)');
                printS("Checking free PEs of testVGi are 14:","$L");
                Framework::grade(checkVGData("testVG","PEFree",14));

                EXERCISE("Checking free space of VG in MB",'checkVGData("testVG","FreeSpace",56)');
                printS("Checking free space of testVG is 56M:","$L");
                Framework::grade(checkVGData("testVG","FreeSpace",56));

		# LVSize LVPESize
		
                EXERCISE("Checking size of LV in PEs",'checkLVData("testVG","testLV","LVPESize","10")');
                printS("Checking size of testVG-testLV1 is 10PE:","$L");
                Framework::grade(checkLVData("testVG","testLV","LVPESize","10"));

                EXERCISE("Checking size of LV in MB",'checkLVData("testVG","testLV","LVSize","40")');
                printS("Checking size of testVG-testLV1 is 40M:","$L");
                Framework::grade(checkLVData("testVG","testLV","LVSize","40"));
		

  MMODULE("MOUNT/DISK/FILESYSTEM (Disk.pm)");

		EXERCISE('Checking mount','checkMount("/dev/mapper/testVG-testLV","/tmp/test/")');
		printS("Checking mount:","$L");
		Framework::grade(checkMount("/dev/mapper/testVG-testLV","/tmp/test/"));

		EXERCISE('Checking filesystem type','checkFilesystemType("/tmp/test","ext3")');
		printS("Checking filesystem type:","$L");
		Framework::grade(checkFilesystemType('/tmp/test',"ext3"));

		EXERCISE('Checking partitions size in MB with margin','checkPartitionSize("/tmp/test","40","10")');
		printS("Checking /tmp/test partition size is 40M :","$L");
		Framework::grade(checkPartitionSize("/tmp/test","40","10"));

                EXERCISE("Checking LABEL",'checkFilesystemParameter(getFilerMountedFrom(\'/mnt/das\'),"LABEL","test1-label")');
                printS("Checking Label is test1-label: ","$L");
                Framework::grade(checkFilesystemParameter(&getFilerMountedFrom('/mnt/das'),"LABEL","test1-label"));

                EXERCISE("Checking UUID",'checkFilesystemParameter(getFilerMountedFrom(\'/mnt/das\'),"UUID","xxxxxxx")');
                printS("Checking UUID is xxxxxxx: ","$L");
                Framework::grade(checkFilesystemParameter(&getFilerMountedFrom('/mnt/das'),"UUID","xxxxxxx"));

                EXERCISE("Checking if the mounted disk is mounted with UUID",'checkMountedWithUUID("/mnt/das")');
                printS("Checking if mounted with UUID: ","$L");
                Framework::grade(checkMountedWithUUID("/mnt/das"));

                EXERCISE("Checking if the mounted disk is mounted with LABEL",'checkMountedWithLABEL("/mnt/das)"');
                printS("Checking if mounted with LABEL: ","$L");
                Framework::grade(checkMountedWithLABEL("/mnt/das"));

		EXERCISE("Checking mount options",'checkMountOptions("/mnt/das","rw,acl")');
                printS("Checking mounted with \"rw\" and \"acl\" options: ","$L");
                Framework::grade(checkMountOptions("/mnt/das","rw,acl"));


MMODULE("OTHER FILESYSTEM (Disk.pm)");

		EXERCISE("Checking if the two given files are the same",'fileEqual("/etc/passwd","/etc/passwd.old")');
		printS("Checking if /etc/passwd equals /etcpasswd.old: ","$L");
		Framework::grade(fileEqual("/etc/passwd","/etc/passwd.old"));

		EXERCISE("Check the owner of the given file",'checkOwner("/tmp/test","tihamer")');
       		printS("The owner of /tmp/test is tihamer","$L");
	        Framework::grade(checkOwner("/tmp/test","tihamer"));

		EXERCISE("Check the type of the given file",'checkType("/tmp/testdir","directory")');
	        printS("Directory /tmo/testdir exist and it's a directory","$L");
        	Framework::grade(checkType("/tmp/testdir","directory"));
	
                EXERCISE("Check the type of the given file",'checkType("/tmp/testfile","file")');
                printS("File /tmo/testfile exist and its type is file","$L");
                Framework::grade(checkType("/tmp/testdir","file"));

                EXERCISE("Check the type of the given file",'checkType("/tmp/testsymlink","symbolic link")');
                printS("File /tmo/testsymlink exist and it's a symbolic link","$L");
                Framework::grade(checkType("/tmp/testdir","file"));

		EXERCISE("Check symlink and the target of it",'checkSymlink("/tmp/testfile","/tmp/testsymlink")');
		printS("Check /tmp/testsymlink exist and its target is /tmp/testfile","$L");		
		Framework::grade(checkSymlink("/tmp/testfile","/tmp/testsymlink"));
		
		EXERCISE("Check SWAP size","checkSwapSize(\"561\",\"5\")");
                printS("Checking swap size increased with 50M: ","$L");
                Framework::grade(checkSwapSize("561","5"));


		#Recreate Disk
#		print "\n\nRecreate vdb disk...\n\n";
		
#		RecreateVDisk("vdb","300","vdb");

#		EXERCISE("Create a primary partition",'CreatePartition("/dev/vdb","1","+30M","lvm"');					
#	        CreatePartition("/dev/vdb","1","+40M","lvm");

#		EXERCISE("Create a primary partition",'CreatePartition("/dev/vdb","2","+50M","swap")');
#	        CreatePartition("/dev/vdb","2","+50M","swap");

#		EXERCISE("Create a primary partition",'CreatePartition("/dev/vdb","3","+25M","linux")');
 #       	CreatePartition("/dev/vdb","3","+25M","linux");

#               EXERCISE("",'');
#               printS("","$L");
#               Framework::grade();
		

	}



	print "\n"."="x$L."=========\n";
	print "\n\tNumber of exercises: \t$exercise_number\n";
	print "\n\tSuccessful: \t\t$exercise_success\n";
	if ($exercise_number == $exercise_success) {
		cryptText2File("<TASKNUMBER>$exercise_number</TASKNUMBER><TASKSUCCESSFUL>$exercise_success</TASKSUCCESSFUL><FINALRESULT>PASSED</FINALRESULT></ROOT>","$result_file");
		print color 'bold green' and print "\n\n\tSuccessful grade.\n\n"  and print color 'reset' and exit 0;;
#Running post
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

if ( $break ) {
	&break;
} elsif ( $grade ) {
	&grade;
} else {
	print "Nothing has been selected. Please select one option.\n";
	Framework::useage;
}
