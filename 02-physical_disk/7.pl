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
our $problem="7";
our $description="LEVEL:        Experienced

Extend the partion previously created and mounted under /mnt/mulder to 180 Mb (+-10%). 
A test file was created, which should be left on the filesystem.
Do not destroy the filesystem and just recreate it.
It has to be reboot persistent.";

our $hint="Umount the partition. (umount)
With fdisk delete the partition and just recreate it from same starting sector. (fdisk)
No metadata will be deleted. Then just use resize2fs.
Don't forget to put it into /etc/fstab.";
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
use Framework qw($verbose $topic $author $version $hint $problem $name $exercise_number $exercise_success $student_file $result_file &printS &cryptText2File &decryptFile &getStudent &EncryptResultFile &DecryptResultFile $description &showdescription &getALTSParameter setALTSParameter &compareValues);
use Disk qw($verbose $topic $author $version $hint $problem $name &checkMount &checkFilesystemType &checkPartitionSize &getFilerMountedFrom &getFilesystemParameter &checkFilesystemParameter &checkMountedWithUUID &checkMountedWithLABEL &checkMountOptions &checkSwapSize &RecreateVDisk &CreateFile &CreateDirectory &CreatePartition );
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
my $DFile="/mnt/mulder/doNotTouchIt.txt";

sub break() {
	print "Break has been selected.\n";
	&pre();

	RecreateVDisk("vdb","300","vdb");
	
	sleep(2);
	CreatePartition("/dev/vdb","1","+100M","ext3");
	CreateDirectory("/mnt/mulder","","","");
	my $ssh=Framework::ssh_connect;
        my $output=$ssh->capture("mkfs.ext3 /dev/vdb1; mount /dev/vdb1 /mnt/mulder;");
	CreateFile($DFile,"root","root","444","!!!!This file has been created for $topic-$problem and should not be modified!!!!");

	my $p;
	$ssh=Framework::ssh_connect;
        $output=$ssh->capture("ls -li $DFile");	
	chomp($output);	$p.=$output;
	$output=$ssh->capture("md5sum $DFile");
	chomp($output); $p.=$output;
	$p=~s/\s/_/g;	
	setALTSParameter("FILE","$p");
		
	system("cp -p /ALTS/EXERCISES/$topic/$problem-grade /var/www/cgi-bin/Grade 1>/dev/null 2>&1; chmod 6555 /var/www/cgi-bin/Grade");

	print "Your task: $description\n";
}

sub grade() {
	system("clear");
	my $Student = Framework::getStudent();
	print "Grade has been selected.\n";
	print "rebooting server:";

	Framework::restart;
	Framework::timedconTo("120");

## Checking if mounted

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
	Framework::grade(checkMount("vdb1","/mnt/mulder/"));

	printS("Checking filesystem type:","$L");
	Framework::grade(checkFilesystemType(&getFilerMountedFrom('/mnt/mulder'),"ext3"));

	printS("Checking size:","$L");
	Framework::grade(checkPartitionSize(&getFilerMountedFrom('/mnt/mulder'),"180","10"));

	my $File_original=getALTSParameter("FILE");

        my $ssh=Framework::ssh_connect;
	my $File_now;
        my $output=$ssh->capture("ls -li $DFile");
        chomp($output); $File_now.=$output;
        $output=$ssh->capture("md5sum $DFile");
        chomp($output); $File_now.=$output;
        $File_now=~s/\s/_/g;

	printS("Checking file hasn't been changed:","$L");
        Framework::grade(compareValues("$File_original","$File_now"));


	#rintS("Checking Label is test1-label: ","$L");
	#ramework::grade(checkFilesystemParameter(&getFilerMountedFrom('/mnt/das'),"LABEL","test1-label"));

	#printS("Checking mounted with UUID: ","$L");
	#Framework::grade(checkMountedWithUUID("/mnt/das"));

	#rintS("Checking mounted with LABEL: ","$L");
	#ramework::grade(checkMountedWithLABEL("/mnt/das"));

	#rintS("Checking mounted with \"rw\" and \"acl\" options: ","$L");		
	#ramework::grade(checkMountOptions("/mnt/das","rw,acl"));

	#rintS("Checking swap size increased with 50M: ","$L");
	#ramework::grade(checkSwapSize("561","5"));

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
#	setALTSParameter("clear","");
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
