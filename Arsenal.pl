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

our @ALTS_MODULES=();
#push(@ALTS_MODULES,"UserGroup");
#push(@ALTS_MODULES,"Disk");
#push(@ALTS_MODULES,"Packages");
#push(@ALTS_MODULES,"Scripting");
push(@ALTS_MODULES,"Network");


#use Sys::Virt;
use lib '/scripts/common_perl/';
use Framework qw($verbose $topic $author $version $hint $problem $name $exercise_number $exercise_success $student_file $result_file &printS &cryptText2File &decryptFile &getStudent);
use Disk qw($verbose $topic $author $version $hint $problem $name &checkMount &checkFilesystemType &checkPartitionSize &getFilerMountedFrom &getFilesystemParameter &checkFilesystemParameter &checkMountedWithUUID &checkMountedWithLABEL &checkMountOptions &checkSwapSize &checkVGExist &getVGData &checkVGData &checkLVExist &getLVData &checkLVData &CreatePartition &fileEqual &checkOwner &checkGroup &checkType &checkSymlink &Delete &Move &Copy &checkSwapSize &RecreateVDisk );
use UserGroup qw(userExist groupExist getUserAttribute checkUserAttribute checkUserPassword &checkUserGroupMembership &checkUserSecondaryGroupMembership &checkUserPrimaryGroup &checkGroupNameAndID &checkUserChageAttribute &checkUserLocked &delUser &delGroup &checkUserHasNoShellAccess &checkUserCrontab &setupGroup &setupUser &delUser &delGroup  &checkUserFilePermission &checkUserHasNoShellAccess &checkGroupFilePermission &checkOtherFilePermission &checkUserFileSpecialPermission &checkNewlyCreatedFilesAttributes &checkUserUnlocked);
use Packages qw( &CreateRepo &CheckRepoExist &CheckRepoAttribute &GetRepoAttribute &CheckPackageInstalled &RemovePackage &InstallPackage);
use Scripting qw( &CheckScriptOutput );
use Network qw( &CheckInterface &CheckNameserver &CheckHostsIP &CheckDefaultGateway );

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

		EXERCISE("Checking LABEL",'checkFilesystemParameter(getFilerMountedFrom(\'/tmp/test\'),"LABEL","test1-label")');
		printS("Checking Label is test1-label: ","$L");
		Framework::grade(checkFilesystemParameter(&getFilerMountedFrom('/tmp/test'),"LABEL","test1-label"));

		EXERCISE("Checking UUID",'checkFilesystemParameter(getFilerMountedFrom(\'/tmp/test\'),"UUID","7080795d-0c0c-422c-b268-3bead2208fce")');
		printS("Checking UUID is 7080795d-0c0c-422c-b268-3bead2208fce: ","$L");
		Framework::grade(checkFilesystemParameter(&getFilerMountedFrom('/tmp/test'),"UUID","7080795d-0c0c-422c-b268-3bead2208fce"));

		EXERCISE("Checking if the mounted disk is mounted with UUID",'checkMountedWithUUID("/tmp/test")');
		printS("Checking if mounted with UUID: ","$L");
		Framework::grade(checkMountedWithUUID("/tmp/test"));

		EXERCISE("Checking if the mounted disk is mounted with LABEL",'checkMountedWithLABEL("/tmp/test)"');
		printS("Checking if mounted with LABEL: ","$L");
		Framework::grade(checkMountedWithLABEL("/tmp/test"));

		EXERCISE("Checking mount options",'checkMountOptions("/tmp/test","rw,acl")');
		printS("Checking mounted with \"rw\" and \"acl\" options: ","$L");
		Framework::grade(checkMountOptions("/tmp/test","rw,acl"));

	MMODULE("OTHER FILESYSTEM (Disk.pm)");

		EXERCISE("Checking if the two given files are the same",'fileEqual("/etc/passwd","/etc/passwd.old")');
		printS("Checking if /etc/passwd equals /etcpasswd.old: ","$L");
		Framework::grade(fileEqual("/etc/passwd","/etc/passwd.old"));

		EXERCISE("Check the owner of the given file",'checkOwner("/tmp/test","tihamer")');
		printS("The owner of /tmp/test is tihamer","$L");
		Framework::grade(checkOwner("/tmp/test","tihamer"));

		EXERCISE("Check the type of the given file",'checkType("/tmp/testdir","directory")');
		printS("Directory /tmp/testdir exist and it's a directory","$L");
		Framework::grade(checkType("/tmp/testdir","directory"));

		EXERCISE("Check the type of the given file",'checkType("/tmp/testfile","regular file")');
		printS("File /tmp/testfile exist and its type is file","$L");
		Framework::grade(checkType("/tmp/testfile","regular file"));

		EXERCISE("Check the type of the given file",'checkType("/tmp/testsymlink","symbolic link")');
		printS("File /tmo/testsymlink exist and it's a symbolic link","$L");
		Framework::grade(checkType("/tmp/testsymlink","symbolic link"));

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



		if ("UserGroup" ~~ @ALTS_MODULES)
		{
		MODULE("UserGroup.pm Module");

		MMODULE("Users and Groups (UserGroup.pm)");

		EXERCISE("Checking if user exist",'userExist("mary")');
		printS("Checking User mary exist:","$L");
		Framework::grade(userExist("mary"));

                EXERCISE("Checking if group exist",'groupExist("mary")');
                printS("Checking Group mary exist:","$L");
                Framework::grade(groupExist("mary"));

		#       UID - User ID
		#       GID - Primary Group ID
		#       DESC - Description of the user
		#       HOME - Home of the user
		#       SHELL - Shell of the user
		#
        	
                EXERCISE("Checking Users UID",'checkUserAttribute("mary","UID","5556")');
		printS("Mary's UID is 5556: ","$L");
	       	Framework::grade(UserGroup::checkUserAttribute("mary","UID","5556"));

                EXERCISE("Checking Users primary group  withGID",'checkUserAttribute("mary","GID","5556")');
                printS("Mary's GID is 5556: ","$L");
                Framework::grade(UserGroup::checkUserAttribute("mary","GID","5556"));

                EXERCISE("Checking Users description",'checkUserAttribute("mary","DESC","This is Mary")');
                printS("Mary's desription is 'This is Mary': ","$L");
                Framework::grade(UserGroup::checkUserAttribute("mary","DESC","This is Mary"));

                EXERCISE("Checking Users home directory",'checkUserAttribute("mary","HOME","/home/mary")');
                printS("Mary's home directory is /home/mary:","$L");
                Framework::grade(UserGroup::checkUserAttribute("mary","HOME","/home/mary"));

                EXERCISE("Checking Users default shell",'checkUserAttribute("mary","SHELL","/bin/bash")');
                printS("Mary's default shell is /bin/bash:","$L");
                Framework::grade(UserGroup::checkUserAttribute("mary","HOME","/home/mary"));

                EXERCISE("Checking user has no shell access:",'checkUserHasNoShellAccess("thomas")');
                printS("Thomas should not have access to any shell:","$L");
                Framework::grade(UserGroup::checkUserHasNoShellAccess("thomas"));
		
		EXERCISE("Checking groups name and ID:",'checkGroupNameAndID("tadmins","885")');
        	printS("Group tadmins with GID 885","$L");
        	Framework::grade(checkGroupNameAndID("tadmins","885"));
	
		EXERCISE("Checking primary group of the user:",'checkUserPrimaryGroup("john","tadmins")');
		printS("John's primary group is tadmins","$L");
		Framework::grade(checkUserPrimaryGroup("john","tadmins"));

                EXERCISE("Checking secondary group of the user:",'checkUserSecondaryGroupMembership("john","ftp")');
                printS("John's secondary group is ftp","$L");
                Framework::grade(checkUserSecondaryGroupMembership("john","ftp"));

	MMODULE("User password (UserGroup.pm)");


                EXERCISE("Checkig users password",'checkUserPassword("mary","kuka002")');
                printS("Mary's password is kuka002:","$L");
                Framework::grade(checkUserPassword("mary","kuka002"));

		EXERCISE("Checking user password is locked",'checkUserLocked(tihamer)');			
		printS("Tihamer is locked","$L");
		Framework::grade(checkUserLocked("tihamer"));

                EXERCISE("Checking user password is unlocked",'checkUserUnlocked(tihamer)');
                printS("Tihamer is locked","$L");
                Framework::grade(checkUserUnlocked("tihamer"));		

		#EXPIRE_DATE - Account expires (date format: YYYY-MM-DD)
		#INACTIVE - Password inactive
		#MIN_DAYS - Minimum number of days between password change
		#MAX_DAYS - Maximum number of days between password change
		#WARN_DAYS - Number of days of warning before password expires

		EXERCISE("Checking user password expire date",'checkUserChageAttribute("john","EXPIRE_DATE","2025-12-12")');		
	        printS("john's account will expire on 2025-12-12","$L");
        	Framework::grade(checkUserChageAttribute("john","EXPIRE_DATE","2025-12-12"));

                EXERCISE("Checking user password inactive days (set password inactive after expiration)",'checkUserChageAttribute("john","INACTIVE","20")');
                printS("john's account inactive days:","$L");
                Framework::grade(checkUserChageAttribute("john","INACTIVE","20"));		

                EXERCISE("Checking user password MIN_DAYS (minimum number of days between password change)",'checkUserChageAttribute("john","MIN_DAYS","8")');
                printS("john can't change password for 8 days","$L");
                Framework::grade(checkUserChageAttribute("john","MIN_DAYS","8"));

                EXERCISE("Checking user password MAX_DAYS (Maximum number of days between password change)",'checkUserChageAttribute("john","MAX_DAYS","60")');
                printS("john must change his password after 60 days","$L");
                Framework::grade(checkUserChageAttribute("john","MAX_DAYS","60"));

                EXERCISE("Checking user password WARN_DAYS (Number of days of warning before password expires)",'checkUserChageAttribute("john","WARN_DAYS","10")');
                printS("john will be warned 10 days before his password will expire","$L");
                Framework::grade(checkUserChageAttribute("john","WARN_DAYS","10"));
		

	MMODULE("Create/Delete Users and groups (UserGroup.pm)");

		EXERCISE("Create Group",'setupGroup("testgroup1","5778","")');
		printS("Create group testgroup1","$L");
		Framework::grade(setupGroup("testgroup1","5778",""));
		
		EXERCISE("Create User",'setupUser("test1","1233","testgroup1","ftp,users","/home/test1","This is the Test user","/bin/bash","true")');
		printS("Create user test1","$L");
		Framework::grade(setupUser("test1","1233","testgroup1","ftp,users","/home/test1","This is the Test user","/bin/bash","true","pw123"));

		EXERCISE("Delete user (second parameter true if you want to delete the home directory too)",'delUser("test1","true")');
		printS("Delete test1 user","$L");
		Framework::grade(delUser("test1","true"));

		EXERCISE("Delete group",'delGroup("testgroup1")');
		printS("Delete testgroup1 group","$L");
		Framework::grade(delGroup("testgroup1"));

	MMODULE("Crontab (UserGroup.pm)");


		EXERCISE("Checking users crontab is denied",'UserGroup::checkUserCrontabDenied("william")');
	        printS("william's crontab is denied","$L");
        	Framework::grade(UserGroup::checkUserCrontabDenied("william"));

		EXERCISE("Checking users crontab entries",'checkUserCrontab("tihamer","25","5","*","*","*","/bin/echo \'crontab exam test\'")');
	        printS("tihamer run \"/bin/echo 'crontab exam test'\" every day at 5:25","$L");
	        Framework::grade(checkUserCrontab("tihamer","25","5","*","*","*","/bin/echo 'crontab exam test'"));
		
	MMODULE("User/Group file permissions (UserGroup.pm)");

		EXERCISE("User permissions on file",'checkUserFilePermission("john","/tmp/testfile","rw*")');
	        printS("User john can write and read /tmp/testfile","$L");
        	Framework::grade(checkUserFilePermission("john","/tmp/testfile","rw*"));

                EXERCISE("User permissions on file",'checkUserFilePermission("tihamer","/tmp/testfile","r*-")');		
                printS("User tihamer can write but can't execute /tmp/testfile","$L");
                Framework::grade(checkUserFilePermission("tihamer","/tmp/testfile","r*-"));

                EXERCISE("User permissions on file",'checkUserFilePermission("mary","/tmp/testfile2","---")');
                printS("User mary has no permissions on /tmp/testfile2","$L");
                Framework::grade(checkUserFilePermission("mary","/tmp/testfile2","---"));

		EXERCISE("Group permissions on file",'checkGroupFilePermission("group1","/tmp/test","rw*")');				
        	printS("Members of group1 can read and write /tmp/test","$L");
	        Framework::grade(checkGroupFilePermission("group1","/tmp/test","rw*"));

		EXERCISE("Group permissions on file",'checkGroupFilePermission("group1","/tmp/test2","rwx")');
	        printS("Members of group1 can read, write and execute /tmp/test2","$L");
	        Framework::grade(checkGroupFilePermission("group1","/tmp/test2","rwx"));

		EXERCISE("Others permissions on file",'checkOtherFilePermission("/tmp/test3","---")');
	        printS("Other can't read, write or execute /tmp/test3","$L");
                Framework::grade(checkOtherFilePermission("/tmp/test3","---"));

	MMODULE("File special permissions (UserGroup.pm)");

		EXERCISE("Special permissions on files (SETUID, NO_SETUID, SETGID, NO_SETGID, STICKY, NO_STICKY)",'checkUserFileSpecialPermission("/tmp/test2","SETUID")');
	        printS("SETUID set on /tmp/test2","$L");
        	Framework::grade(checkUserFileSpecialPermission("/tmp/test2","SETUID"));

		EXERCISE("Special permissions on files (SETUID, NO_SETUID, SETGID, NO_SETGID, STICKY, NO_STICKY)",'checkUserFileSpecialPermission("/tmp/test","NO_STICKY")');
        	printS("STICKY not set on /tmp/test","$L");
	        Framework::grade(checkUserFileSpecialPermission("/tmp/test","NO_STICKY"));


	MMODULE("Newly created file attributes (UserGroup.pm)");

		#  Parameter 1: Directory
		#  Parameter 2: Group of the newly created file (optional)
		#  Parameter 3: The user, whos permissions you want to check (optional)
		#  Parameter 4: Permission of this user (optional)
		#  Parameter 5: The group, which permissions you want to check (optinal)
		#  Parameter 6: Permission of this group (optional)
		#  Parameter 7: Permission others
		# 
		#    About permissions:
		#         use * if you don't want to check, or it doesn't matter
		#         e.g. r*- means, that it has to be readable, it can be writable or not writable either, it musn't be executable

		
                EXERCISE("Checking newly created file attributes (other group, given users permissions, given groups permissions, others permissions",'checkNewlyCreatedFilesAttributes("/tmp/testdir","group1","","","","","")');
                printS("The group of every newly created file in this directory is group1","$L");
                Framework::grade(checkNewlyCreatedFilesAttributes("/tmp/testdir","group1","","","","",""));
		
		EXERCISE("Checking newly created file attributes (other group, given users permissions, given groups permissions, others permissions",'checkNewlyCreatedFilesAttributes("/tmp/test/testdir","john","r-*","","","","")');
		printS("A newly created file in /tmp/test/testdir should be readable but not writable for user john","$L");
		Framework::grade(checkNewlyCreatedFilesAttributes("/tmp/test/testdir","","john","r**","","",""));

                EXERCISE("Checking newly created file attributes (other group, given users permissions, given groups permissions, others permissions",'checkNewlyCreatedFilesAttributes("/tmp/test/testdir","","","","group1","rw*","")');
                printS("A newly created file in /tmp/test/testdir should be readable and writable for group group1","$L");
                Framework::grade(checkNewlyCreatedFilesAttributes("/tmp/test/testdir","","","","group1","rw*",""));
		
                EXERCISE("Checking newly created file attributes (other group, given users permissions, given groups permissions, others permissions",'checkNewlyCreatedFilesAttributes("/tmp/test/testdir","","","","","","r**")');
                printS("A newly created file in /tmp/test/testdir should be readable for others","$L");
                Framework::grade(checkNewlyCreatedFilesAttributes("/tmp/test/testdir","","","","","","r**"));
}
 if ("Packages" ~~ @ALTS_MODULES)
                {

                MODULE("Packages.pm Module");
		
	 	MMODULE("Yum repositories (Packages.pm)");

		EXERCISE("Creating yum repository",'CreateRepo("local.repo","local","Local Repo","http://desktop",0,"",1)');
		printS("Creating yum repository","$L");
		Framework::grade(Packages::CreateRepo("local.repo","local","Local Repo","http://desktop",0,"",1));

		EXERCISE("Checking if yum repo exist and enabled/diabled",'CheckRepoExist("local","enabled")');
	        printS("Checking Repo exist and activated","$L");
	        Framework::grade(Packages::CheckRepoExist("local","enabled"));

		EXERCISE("Checking repos attributes (enabled, name, gpgcheck...)",'CheckRepoExist("local","enabled")');
		printS("Checking Repos gpgcheck is disabled","$L");
	        Framework::grade(Packages::CheckRepoAttribute("local","gpgcheck","0"));

		EXERCISE("Checking repos attributes (enabled, name, gpgcheck...)",'CheckRepoAttribute("local","name","Local Repo")');
	        printS("Checking Repos name is 'Local Repo'","$L");
	        Framework::grade(Packages::CheckRepoAttribute("local","name","Local Repo"));

		EXERCISE("Checking repos attributes (enabled, name, gpgcheck...)",'CheckRepoAttribute("local","baseurl","http://desktop")');
	        printS("Checking Repos baseurl is http://desktop/","$L");
	        Framework::grade(Packages::CheckRepoAttribute("local","baseurl","http://desktop"));

		MMODULE("Packages (install/remove/update) (Packages.pm)");

		EXERCISE("Checking package is installed",'CheckPackageInstalled("nano")');
                printS("Checking nano is installed","$L");
        	Framework::grade(Packages::CheckPackageInstalled("nano"));

		EXERCISE("Checking package has been updated/checking package with version",'CheckPackageInstalled("mc","4.7.0.2-3")');
	        printS("Checking mc has been updated","$L");
	        Framework::grade(Packages::CheckPackageInstalled("mc","4.7.0.2-3"));

		EXERCISE("Checking package has been removed",'!CheckPackageInstalled("wget")');
	        printS("Checking wget has been removed","$L");
	        Framework::grade(!Packages::CheckPackageInstalled("wget"));	
		}
 if ("Scripting" ~~ @ALTS_MODULES)
                {
		MODULE("Scripting.pm Module");
	
		MMODULE("Script output (Scripting.pm)");

	        my $Commands="#!/bin/bash
        	cat /tmp/testinput.txt | tr 'aA' '**'";
	
		EXERCISE("Checking scripts output compared with our scripts output are the same",'CheckScriptOutput("root","/tmp/testscript","$Commands","")');
	        printS("Checking Script output","$L");
	        Framework::grade(Scripting::CheckScriptOutput("root","/tmp/testscript","$Commands",""));

		EXERCISE("Checking scripts error output compared with our scripts output",'CheckScriptOutput("$TmpUser","/tmp/testscript","$Commands","","STDERR_ONLY")');
	        printS("Checking Script output","$L");
        	Framework::grade(Scripting::CheckScriptOutput("root","/tmp/testscript","$Commands","","STDERR_ONLY"));	
		}	

if ("Network" ~~ @ALTS_MODULES)
                {
                MODULE("Network.pm Module");

                MMODULE("DNS (Network.pm)");

		EXERCISE("Checking nameserver",'Network::CheckNameserver("2.2.2.1","server1")');
	        printS("Checking nameserver is 2.2.2.1:","$L");
        	Framework::grade(Network::CheckNameserver("2.2.2.1","server1"));

		EXERCISE("Checking IP for host",'Network::CheckHostsIP("test1machine","1.1.1.1")');
        	printS("Checking IP of test1machine is 1.1.1.1:","$L");
	        Framework::grade(Network::CheckHostsIP("test1machine","1.1.1.1"));

		EXERCISE("Checking name resolving sequence",'Network::CheckNsswitchConfig("hosts","false","files","dns")');
        	printS("In name resolving sequence files are before dns:","$L");
		printS("\n\t(stricted=false, other object can be in the sequence ","$L");
		printS("\n\tE.g. hosts:  'files     nic dns is OK too'):","$L");
	        Framework::grade(Network::CheckNsswitchConfig("hosts","false","files","dns"));

                EXERCISE("Checking name resolving sequence",'Network::CheckNsswitchConfig("hosts","false","files","dns")');
                printS("\n\tIn name resolving sequence files are before dns:","$L");
		printS("\n\t(stricted=true, no other object can be in the sequence):","$L");
                Framework::grade(Network::CheckNsswitchConfig("hosts","true","files","dns"));
		
		MMODULE("Routing (Network.pm)");

		EXERCISE("Checking default gateway",'Network::CheckDefaultGateway("2.2.2.1","eth1")');
	        printS("Checking default gateway is 2.2.2.1 through eth1","$L");
       	 	Framework::grade(Network::CheckDefaultGateway("2.2.2.1","eth1"));

		 MMODULE("Interface (Network.pm)");

		EXERCISE("Checking interface status",'Network::CheckInterface("eth1","state","UP")');
	        printS("Checking interface is up:","$L");
        	Framework::grade(Network::CheckInterface("eth1","state","UP"));

		EXERCISE("Checking interface bootproto (e.g. static)",'Network::CheckInterface("eth1","bootproto","static")');
                printS("Checking interface IP is static:","$L");
		Framework::grade(Network::CheckInterface("eth1","bootproto","static"));
	
		EXERCISE("Checking interface IP (or alias IP)",'Network::CheckInterface("eth1","ip","1.1.1.1")');
	        printS("Checking interface IP is 1.1.1.1:","$L");
        	Framework::grade(Network::CheckInterface("eth1","ip","1.1.1.1"));
		
		EXERCISE("Checking interface IP+MASK",'Network::CheckInterface("eth1","ip_mask","2.2.2.88/16")');
        	printS("Checking interface IP is 2.2.2.88/16","$L");
	        Framework::grade(Network::CheckInterface("eth1","ip_mask","2.2.2.88/16"));
		
		EXERCISE("Checking interface MAC",'Network::CheckInterface("eth1","mac","52:54:00:e9:e1:2c")');
		printS("Checking Mac address is 52:54:00:e9:e1:2c","$L");	
	        Framework::grade(Network::CheckInterface("eth1","mac","52:54:00:e9:e1:2c"));
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
