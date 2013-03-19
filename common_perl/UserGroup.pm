package UserGroup;
### This Module are common subroutines used in the script.
#This file is part of Leats.
#
#Leats is free software: you can redistribute it and/or modify
#it under the terms of the GNU General Public License as published by
#the Free Software Foundation, either version 3 of the License, or
#(at your option) any later version.
#
#Leats is distributed in the hope that it will be useful,
#but WITHOUT ANY WARRANTY; without even the implied warranty of
#MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#GNU General Public License for more details.
#
#You should have received a copy of the GNU General Public License
#along with Leats.  If not, see <http://www.gnu.org/licenses/>.
use strict;
use warnings;
use Term::ANSIColor;
use Data::Dumper;
use POSIX qw(ceil);
use Switch;
use Time::Local;

BEGIN {
	use Exporter;

	@UserGroup::ISA         = qw(Exporter);
	@UserGroup::EXPORT      = qw( &userExist &groupExist &getUserAttribute &checkUserAttribute &checkUserPassword &checkUserGroupMembership &checkUserSecondaryGroupMembership &checkUserPrimaryGroup &checkGroupNameAndID &checkUserChageAttribute &checkUserLocked &setupUser &setupGroup &delGroup &delUser &checkUserFilePermission &checkUserHasNoShellAccess &checkGroupFilePermission &checkOtherFilePermission &checkUserFileSpecialPermission &checkNewlyCreatedFilesAttributes &checkUserCrontabDenied &checkUserCrontab );
	@UserGroup::EXPORT_OK   = qw( $verbose $topic $author $version $hint $problem $name $exercise_number $exercise_success);
	
	use Disk qw(&fileEqual &checkOwner &checkGroup &checkType &checkSymlink &Delete &getInfo);
}
use vars qw ($verbose $topic $author $version $hint $problem $name $exercise_number $exercise_success);

#Check if user exist
#1. Paramter: username (not ID!)
sub userExist($)
{
	my $User = $_[0];
	my $ssh=Framework::ssh_connect;
	my $output=$ssh->capture("getent passwd $User");
	if ($output =~ m/^$User:.*$/) {  return 0; }
	#if User not exist
	return 1;
}



#Check if group exist
#1. Parameter: groupname (not ID!)
sub groupExist($)
{
	my $Group = $_[0];
	my $ssh=Framework::ssh_connect;
	my $output=$ssh->capture("getent group $Group");
	if ($output =~ m/^$Group:.*$/) { return 0; }
	#if Group not exist in /etc/group
	return 1;
}


#Return the attribute of the user from passwd
#Example from /etc/passwd: 	ftp:x:14:50:FTP User:/var/ftp:/sbin/nologin
#1. Parameter: Username
#2. Parameter:
#	UID - User ID
#	GID - Primary Group ID
#	DESC - Description of the user
#	HOME - Home of the user
#	SHELL - Shell of the user
sub getUserAttribute($$)
{
        my $User = $_[0];
        my $P = uc($_[1]);

        if (userExist($User) != 0 ) { return undef;  }
        if (($P ne "UID" ) && ($P ne "GID" ) && ($P ne "DESC" ) && ($P ne "HOME" ) && ($P ne "SHELL" ))
        {
                $verbose && print "\nInvalid Attribute: $P!\n"; exit 1;
                return undef;
        }

        my @A=();
        my $ssh=Framework::ssh_connect;
        my $output=$ssh->capture("getent passwd $User");
        if (@A = $output =~ m/^$User:[^:]*:(\d+):(\d+):([^:]*):([^:]+):([^:]+)$/)
        {
                switch ($P) {
                        case "UID" { return $A[0]; }
                        case "GID" { return $A[1]; }
                        case "DESC" { return $A[2]; }
                        case "HOME" { return $A[3]; }
                        case "SHELL" { chomp($A[4]); return $A[4]; }
                }
        }
}


#Check users Attribute
#
#Return values:
#0: Correct
#1: Not correct
#
#1.Parameter: Username (not ID!)
#2.Parameter:
#       UID - User ID
#       GID - Primary Group ID
#       DESC - Description of the user
#       HOME - Home of the user
#       SHELL - Shell of the user
#3.Parameter: Value of the Attribute
#example:  checkUserAttribute("john","UID","688")
sub checkUserAttribute($$$)
{
	my $User = $_[0];
	my $P = $_[1];
	my $Value = $_[2];

	if (userExist($User) != 0 ) { return 1; }

	my $AttributeValue = getUserAttribute($User,$P);

	if (($P eq "HOME")) 
	{
		$Value = "${Value}/"; $Value=~s@/+@/@g; 
		$AttributeValue = "${AttributeValue}/"; $AttributeValue=~s@/+@/@g;;
	} 

	(($Value eq $AttributeValue) && return 0) || return 1;
}

#Check users password
#
#1.Parameter: Username (not ID!)
#2.Parameter: Password
#
#Example: checkUserPassword("john","secretPassword");
sub checkUserPassword($$)
{
	my $User = $_[0];
	my $P = $_[1];

	if (userExist($User) != 0 ) { return 1; }

	my $line;
	my @A;
	my $ssh=Framework::ssh_connect;
	my $output=$ssh->capture("cat /etc/shadow");
	my @lines = split("\n",$output);
	foreach $line (@lines)
	{
		if (@A = $line =~ m/^$User:\$(\d+)\$([^:]+)\$([^:]*):.*$/)
		{
			if ("\$${A[0]}\$${A[1]}\$${A[2]}" eq crypt("$P", "\$$A[0]\$" . "$A[1]")) { return 0; }
			else { return 1; }
		}
	}	

	return 1;
}

#
# Returns the groupname of the ID you give as 1.Parameter
#
# 1.Parameter: GroupID
#
sub getGroupName($)
{
        my $GroupID = $_[0];
        my @M;
        my $ssh=Framework::ssh_connect;
        my $output=$ssh->capture("getent group $GroupID");
        if (@M = $output =~ m/^([^:]+):x:$GroupID:.*$/){ return $M[0];  }
        return undef;
}


#
#Check the group ID of the group
#
#1. Parameter: Groupname
#2. Parameter: GroupID
#
#Return value is 0 if the groupID related to the groupname 
sub checkGroupNameAndID($$)
{
	my $GroupName = $_[0];
	my $GroupID = $_[1];
	my $line;
	my @M;

	my $ssh=Framework::ssh_connect;
	my $output=$ssh->capture("getent group $GroupName");
	if (@M = $output =~ m/^$GroupName:x:$GroupID:.*$/) { return 0; }
	return 1;
}




#Check if User is member of the group
#It checks only the secondary groups
#
#1.Parameter: Username (not ID!)
#2.Parameter: Groupname (not ID!)
#
#Example: checkUserSecondaryGroupMembership("john","admins");
sub checkUserSecondaryGroupMembership($$)
{
	my $User = $_[0];
	my $Group = $_[1];
	my @M;

	if (userExist($User) != 0 ) { return 1;  }

	my $ssh=Framework::ssh_connect;
	my $output=$ssh->capture("getent group $Group");
	if (@M = $output =~ m/^$Group:x:\d+:([^:]*)$/) 
	{ 	
		chomp($M[0]);
		my @Members = split(",",$M[0]);
		my $Member;
		foreach $Member (@Members) { ($User eq $Member) && return 0; }		
	}	
	return 1;
}

#Check users primary group 
#
#1.Parameter: Username (not ID!)
#2.Parameter: Groupname (not ID!)
#
sub checkUserPrimaryGroup($$)
{
	my $User = $_[0];
	my $Group = $_[1];

 	if (userExist($User) != 0 ) { return 1;  }

	if ($Group eq getGroupName(UserGroup::getUserAttribute("$User","GID"))) { return 0; }
	else {	return 1; }
}

#Check if User's account is locked
#
#1.Parameter: Username (not ID!)
#
#Returns 0 if user's account is locked
sub checkUserLocked($)
{
my $User = $_[0];
if (userExist($User) != 0 ) { return 1;  }

my $ssh=Framework::ssh_connect;
my $output=$ssh->capture("passwd -S $User");
if ($output =~ m/Password locked/) { return 0; }

return 1;
}

#Check if User's crontab is denied
#
#1.Parameter: Username (not ID!)
#
#Returns 0 if user's crontab is denied
#
sub checkUserCrontabDenied($)
{
my $User = $_[0];
if (userExist($User) != 0 ) { return 1;  }

my $ssh=Framework::ssh_connect;
my $output=$ssh->capture("cat /etc/cron.allow 2>/dev/null");
my @USER_ALLOW=split("\n","$output");
if ($User ~~ @USER_ALLOW) { return 1; }

my $output=$ssh->capture("cat /etc/cron.deny 2>/dev/null");
my @USER_DENY=split("\n","$output");
if ($User ~~ @USER_DENY) { return 0; }
else { return 1; }
}

#Check Users crontab
#
#1.Parameter: Username (not ID!)
#2.Parameter: Time: minute
#3.Parameter: Time: hour
#4.Parameter: Time: day of the month
#5.Parameter: Time: month
#6.Parameter: Time: day of week
#7.Parameter: Command
#
#Returns 0 if user's crontab is well setup
#
sub checkUserCrontab($$$$$$$)
{
	my $User = $_[0];
	if (userExist($User) != 0 ) { return 1;  }
	my $T_minute=$_[1];
	my $T_hour=$_[2];
	my $T_day=$_[3];
	my $T_month=$_[4];
	my $T_dayofweek=$_[5];
	my $Command=$_[6];

	my $ssh=Framework::ssh_connect;
	my $output=$ssh->capture("crontab -l -u $User");

#my @Cronentries = $output =~ m/^\s*(\S+\s+\S+\s+\S+\s+\S+\s+\S+\s+\S+)\s*$/;
	my @Cronentries = split("\n",$output);
	foreach my $Cronentry (@Cronentries)
	{
		#print "\n++++++++++++ ENTRY: $Cronentry ++++++++++++++\n";
		my @A = $Cronentry =~ m/\s*(\S+)\s+(\S+)\s+(\S+)\s+(\S+)\s+(\S+)\s+(.*)/;
		if (($A[0] eq "$T_minute")&&($A[1] eq "$T_hour")&&($A[2] eq "$T_day")&&($A[3] eq "$T_month")&&($A[4] eq "$T_dayofweek")) 
		{	
			$verbose and print "Time OK\n";			
			my $ACommand=$A[5];
			#print "\nWant:   $User | $T_minute $T_hour $T_day $T_month $T_dayofweek $Command\n";
			#print "\nWCommand: $Command\nACommand: $ACommand\n\n";

			if ($ACommand eq $Command) { return 0; }
			else {
				$ACommand=~s/"/\\"/g;
				my $Aoutput=$ssh->capture("su $User -c \"$ACommand\"");
				my $Woutput=$ssh->capture("su $User -c \"$Command\"");
				if ($Aoutput eq $Woutput) { return 0; }
			
			}
		}	
		else {
			next;
		}	
	}

	return 1;
}


#
# Checks if user has no shell access
#
# 1.Parameter: USername (not ID!)
#
sub checkUserHasNoShellAccess($)
{
	my $User = $_[0];
	if (userExist($User) != 0 ) { return 1;  }

	my $ssh=Framework::ssh_connect;
	my $output=$ssh->capture("su - $User -c \"\" >/dev/null 2>\&1; echo \$?");
	chomp($output);

	if ($output ne "0" ) { return 0; }
	else { return 1; }


}

#Check users group memberships
#If checks primary and secondary groups also
#
#Return value is 0 if user is member of the group else 1
#
#1.Parameter: Username (not ID!)
#2.Parameter: Groupname (not ID!)
#
sub checkUserGroupMembership($$)
{
	my $User = $_[0];
	my $Group = $_[1];
	if (userExist($User) != 0 ) { return 1; }

	if ((checkUserPrimaryGroup($User,$Group)==0) || (checkUserSecondaryGroupMembership($User,$Group)==0)) { return 0 ; }
	else { return 1; }
}

#Check the Users user password expiry information
#
#EXPIRE_DATE - Account expires (date format: YYYY-MM-DD)                         
#INACTIVE - Password inactive
#MIN_DAYS - Minimum number of days between password change
#MAX_DAYS - Maximum number of days between password change   
#WARN_DAYS - Number of days of warning before password expires
#
#
#Examples: 
#1. The User tom's account should expire in 2025-12-10:
#checkUserChageAttribute("tom","EXPIRE_DATE","2025-12-10");
#
#2. The warning days should be 12 before the password expires:
#checkUserChageAttribute("tom","WARN_DAYS","12");
#
#Return Value is 0 when the Attribute is correct, else it returns with 1.
#
sub checkUserChageAttribute($$$)
{
	my $User = $_[0];
	my $P = $_[1];
	my $Value = lc($_[2]);
	if (userExist($User) != 0 ) { return 1; }
	if (($P eq "EXPIRE_DATE") && ($Value =~ m@\d{4}-\d{2}-\d{2}@)){ $Value=`date +%s -d "$Value"`; $Value=ceil($Value/86400);  }
	elsif ($Value eq "never") { $Value=""; }

	my $line;
	my @A;
	my $ssh=Framework::ssh_connect;
	my $output=$ssh->capture("cat /etc/shadow");
	my @lines = split("\n",$output);
	foreach $line (@lines)
	{  
		if (@A = $line =~ m/^$User:[^:]*:([^:]*):([^:]*):([^:]*):([^:]*):([^:]*):([^:]*):.*$/)
		{
			switch ($P) 
			{
				case "EXPIRE_DATE" { ((${A[5]} eq $Value) && return 0) || return 1;  } 
				case "INACTIVE" { ((${A[4]} eq $Value) && return 0) || return 1; 	}
				case "MIN_DAYS" { ((${A[1]} eq $Value) && return 0) || return 1; }
				case "MAX_DAYS" { ((${A[2]} eq $Value) && return 0) || return 1;}
				case "WARN_DAYS" { ((${A[3]} eq $Value) && return 0) || return 1;}
			}
		}
	}	
	return 1;
}

#Setup User with the given parameters
#If the user doesn't exist, then it will be created, otherwise it will be modified as specified
#
#1. Parameter: Username (not ID!)
#2. Parameter: UID
#3. Parameter: Primary Group
#4. Parameter: Secondary Group(s) e.g. "group1,group2,group3"
#5. Parameter: Users home directory
#6. Parameter: User comment
#7. Parameter: Users default shell
#8. Parameter: Generate SSH key for key authentication (true/false)
#
sub setupUser($$$$$$$$)
{
	my $User = $_[0];
	my $User_UID = $_[1];
	my $Group = $_[2];
	my $Group_Secondary = $_[3];	
	my $User_Home = $_[4];
	my $User_Comment = $_[5];
	my $User_Shell = $_[6];
	my $User_Generate_SSH_Key = lc($_[7]);

	if ($User eq "") { return 1; }

	if (userExist($User) != 0 ) { 
		my $ssh=Framework::ssh_connect;
		my $output=$ssh->capture("useradd $User");
#$verbose and print "Add user $User: $output \n";
	}

	if ($User_UID =~ m/\d+/) {
		my $ssh=Framework::ssh_connect;
		my $output=$ssh->capture("usermod -u $User_UID $User");
#$verbose and print "Modify ${User}'s UID to $User_UID: $output \n";  
	}

	if ($Group ne "") {
		my $ssh=Framework::ssh_connect;
		my $output=$ssh->capture("usermod -g $Group $User");
#$verbose and print "Modify ${User}'s Primary Group to $Group: $output \n";
	}

	if ($Group_Secondary ne "") {
		$Group_Secondary=~s/\s//g; my @GS=split(",",$Group_Secondary);
		my $ssh=Framework::ssh_connect;
		my $output=$ssh->capture("usermod -G \"\" $User");
		my $G;
		foreach $G (@GS)
		{
			if (groupExist($G) == 0)
			{
				my $ssh=Framework::ssh_connect;
				my $output=$ssh->capture("usermod -aG $G $User");
#$verbose and print "Add $G to ${User}'s Secondary Group(s): $output \n";
			}
		}
	}

	if ($User_Home ne "") {
		my $ssh=Framework::ssh_connect;
		my $output=$ssh->capture("usermod -d $User_Home $User");
#$verbose and print "Modify ${User}'s Home directory to $User_Home: $output \n";
	}

	if ($User_Comment ne "") {
		my $ssh=Framework::ssh_connect;
		my $output=$ssh->capture("usermod -c '$User_Comment' $User");
#$verbose and print "Modify ${User}'s Comment to $User_Comment: $output \n";
	}

	if ($User_Shell ne "") {
		my $ssh=Framework::ssh_connect;
		my $output=$ssh->capture("usermod -s $User_Shell $User");
#$verbose and print "Modify ${User}'s default shell to $User_Shell: $output \n";
	}

	if ($User_Generate_SSH_Key eq "true") {
		my $ssh=Framework::ssh_connect;		
		my $output=$ssh->capture("su - $User -c \"mkdir ./.ssh; rm -f ./.ssh/*; ssh-keygen -q -t rsa -f ./.ssh/id_rsa -N ''\"");
#$verbose and print "Generate ssh key for $User: $output \n";
	}		

#	my $ssh=Framework::ssh_connect;
#	my $output=$ssh->capture("cat /etc/shadow");
	if (userExist($User) != 0 ) { return 1; }
	return 0;
}


#
# Setup a group with the given parameters
# If the group doesn't exist, then it will be created, otherwise it will be modified as specified
#
#1. Parameter: Group name
#2. Parameter: GID
#3. Parameter: Members
#
sub setupGroup($$$)
{
	my $Group = $_[0];
	my $Group_GID = $_[1];
	my $Group_Members = $_[2];

	if ($Group eq "") { return 1; }

	if (groupExist($Group) != 0 ) {
		my $ssh=Framework::ssh_connect;
		my $output=$ssh->capture("groupadd $Group");
	}

	if ($Group_GID =~ m/\d+/) {
		my $ssh=Framework::ssh_connect;
		my $output=$ssh->capture("groupmod -g $Group_GID $Group");
	}
	if ($Group_Members ne "") {
		$Group_Members=~s/\s//g; my @GM=split(",",$Group_Members);	
			my $U;
		foreach $U (@GM)
		{
			if (userExist($U) == 0)
			{
				my $ssh=Framework::ssh_connect;
				my $output=$ssh->capture("usermod -aG $Group $U");
			}
		}
	}

}

#
#Delete the group, if does exist
#
#1. Parameter: Group name (not GID!)
#
sub delGroup($)
{
	my $Group=$_[0];

	if (($Group eq "") || (groupExist($Group) != 0 )) { return 1; }

	my $ssh=Framework::ssh_connect;
	my $output=$ssh->capture("groupdel $Group");
}

#
#Delete the user, if does exist
#
#1. Parameter: User name (not UID!)
#2. Parameter: true, if you want to delete the users home directory, otherwise false
#
sub delUser($;$)
{
	my $User=$_[0];
	my $delHome=lc($_[1]) || "false";

	if ($User eq "") { return 1; }
	if (userExist($User) == 0) {
		if ($delHome eq "true") {  
			my $ssh=Framework::ssh_connect;
			my $output=$ssh->capture("userdel -r $User");
		}
		else 
		{
			my $ssh=Framework::ssh_connect;
			my $output=$ssh->capture("userdel $User");
		}
	}

	if (userExist($User) == 0) {return 1;}
	else {return 0;}
}


#
#File Permission Check
#
# Parameter 1: Users name (not UID!)
# Parameter 2: File to check
# Parameter 3: Permission you want to check 
#		use * if you don't want to check, or it doesn't matter
#		e.g. r*- means, that it has to be readable, it can be writable or not writable either, it musn't be executable
#
#
sub checkUserFilePermission($$$)
{
	my $User = $_[0];
	my $FileName = $_[1];
	my $Permission = lc($_[2]);

	if (($User eq "") || (userExist($User) != 0 )) { return 1; }

	my $ssh=Framework::ssh_connect;
	my $output=$ssh->capture("test -e $FileName >/dev/null 2>/dev/null;echo \$?");
	chomp($output);
	if ($output ne "0"  ) { return 1; }

#print "\n$FileName || $Permission\n\n";
	$ssh=Framework::ssh_connect;	

	if ($Permission =~ m/r../) {    #print "READABLE\n"; 
		$output=$ssh->capture("su - $User -c 'test -r $FileName >/dev/null 2>/dev/null;echo \$?'");
		chomp($output);
		if ($output ne "0"  ) { return 1; }
	}
	if ($Permission =~ m/-../) {  #print "NOT READABLE\n";  
		$output=$ssh->capture("su - $User -c 'test -r $FileName >/dev/null 2>/dev/null;echo \$?'");
		chomp($output);
		if ($output eq "0"  ) { return 1; }
	}
	if ($Permission =~ m/.w./) {  #print "WRITABLE\n";  
		$output=$ssh->capture("su - $User -c 'test -w $FileName >/dev/null 2>/dev/null;echo \$?'");
		chomp($output);
		if ($output ne "0"  ) { return 1; }

	}
	if ($Permission =~ m/.-./) {  #print "NOT WRITABLE\n";  
		$output=$ssh->capture("su - $User -c 'test -w $FileName >/dev/null 2>/dev/null;echo \$?'");
		chomp($output);
		if ($output eq "0"  ) { return 1; }

	}
	if ($Permission =~ m/..x/) {  #print "EXECUTABLE\n";  
		$output=$ssh->capture("su - $User -c 'test -x $FileName >/dev/null 2>/dev/null;echo \$?'");
		chomp($output);
		if ($output ne "0"  ) { return 1; }

	}
	if ($Permission =~ m/..-/) {  #print "NOT EXECUTABLE\,";  
		$output=$ssh->capture("su - $User -c 'test -x $FileName >/dev/null 2>/dev/null;echo \$?'");
		chomp($output);
		if ($output eq "0"  ) { return 1; }

	}


	return 0;
}

#
#File Special Permission Check
#
# Parameter 1: File to check
# Parameter 2: Permission you want to check
#              It can be: SETUID, NO_SETUID, SETGID, NO_SETGID, STICKY, NO_STICKY
#
#
#
sub checkUserFileSpecialPermission($$)
{
	my $FileName = $_[0];
	my $Permission = uc($_[1]);

	my $ssh=Framework::ssh_connect;
	my $output=$ssh->capture("test -e $FileName >/dev/null 2>/dev/null;echo \$?");
	chomp($output);
	if ($output ne "0"  ) { return 1; }

	$ssh=Framework::ssh_connect;

	if ($Permission eq "SETUID") {
		$output=$ssh->capture("test -u $FileName >/dev/null 2>/dev/null; echo \$?");
		chomp($output);
		if ($output eq "0"  ) { return 0; }
	}
	elsif ($Permission eq "NO_SETUID") {
		$output=$ssh->capture("test -u $FileName >/dev/null 2>/dev/null;echo \$?");
		chomp($output);
		if ($output ne "0"  ) { return 0; }
	}

	elsif ($Permission eq "SETGID") {
		$output=$ssh->capture("test -g $FileName >/dev/null 2>/dev/null;echo \$?");
		chomp($output);
		if ($output eq "0"  ) { return 0; }
	}
	elsif ($Permission eq "NO_SETGID") {
		$output=$ssh->capture("test -g $FileName >/dev/null 2>/dev/null;echo \$?");
		chomp($output);
		if ($output ne "0"  ) { return 0; }
	}
	elsif ($Permission eq "STICKY") {
		$output=$ssh->capture("test -k $FileName >/dev/null 2>/dev/null;echo \$?");
		chomp($output);
		if ($output eq "0"  ) { return 0; }

	}
	elsif ($Permission eq "NO_STICKY") {
		$output=$ssh->capture("test -k $FileName >/dev/null 2>/dev/null;echo \$?");
		chomp($output);
		if ($output ne "0"  ) { return 0; }
	}


	return 1;
}



#
#
# checks a groups file permissions on a file
#
# Parameter 1: Group name (not GID!)
# Parameter 2: File to check
# Parameter 3: Permission you want to check
#		use * if you don't want to check, or it doesn't matter
#	        e.g. r*- means, that it has to be readable, it can be writable or not writable either, it musn't be executable
#
#
sub checkGroupFilePermission($$$)
{
	my $Group = $_[0];
	my $FileName = $_[1];
	my $Permission = lc($_[2]);

	delUser("group1-user001-temp","true");
	setupUser("group1-user001-temp","","$Group","","","Temporary User 4 test 1","","");

	my $RV=checkUserFilePermission("group1-user001-temp","$FileName","$Permission");

	delUser("group1-user001-temp","true");

	return $RV;
}

#
#
# checks "other users" permissions on a file
#
# Parameter 1: File to check
# Parameter 2: Permission you want to check
#               use * if you don't want to check, or it doesn't matter
#               e.g. r*- means, that it has to be readable, it can be writable or not writable either, it musn't be executable
#
#
#
sub checkOtherFilePermission($$)
{
	my $FileName = $_[0];
	my $Permission = lc($_[1]);

	setupGroup("other-group001","","");
	setupUser("other_group001-user001-temp","","other_group001","","","OTHER Temporary User 4 grade","","");

	my $RV=checkUserFilePermission("other_group001-user001-temp","$FileName","$Permission");

	delUser("other_group001-user001-temp","true");
	delGroup("other_group001");

	return $RV;
}

#
#
# Checks a newly created files permissions
#
# Parameter 1: Directory
# Parameter 2: Group of the newly created file (optional)
# Parameter 3: The user, whos permissions you want to check (optional)
# Parameter 4: Permission of this user (optional)		
# Parameter 5: The group, which permissions you want to check (optinal)
# Parameter 6: Permission of this group (optional)
# Parameter 7: Permission others
#
#	About permissions:
#               use * if you don't want to check, or it doesn't matter
#               e.g. r*- means, that it has to be readable, it can be writable or not writable either, it musn't be executable
#
#
sub checkNewlyCreatedFilesAttributes($$$$$$$)
{
	my $Directory = $_[0];	

	my $Group = $_[1];

	my $NUser = $_[2];
	my $Permission_NUser = lc($_[3]) || "***";

	my $NGroup = $_[4];
	my $Permission_NGroup = lc($_[5]) || "***";

	my $Permission_Other = lc($_[6]) || "***";


	my @A = localtime(time);
	my $FileName=join("_",@A);

	my $ssh=Framework::ssh_connect;
	my $output=$ssh->capture("touch $Directory/$FileName");

	if (($Group ne "") && (checkGroup("$Directory/$FileName","$Group") != 0)) { 
		$ssh->capture("rm -rf $Directory/$FileName"); return 1; 
	}

	if (($Permission_NUser ne "") && ($NUser ne "") && (checkUserFilePermission("$NUser","$Directory/$FileName","$Permission_NUser") != 0)) { 
		$ssh->capture("rm -rf $Directory/$FileName"); return 1; 
	}

	if (($Permission_NGroup ne "") && ($NGroup ne "") && (checkGroupFilePermission("$NGroup","$Directory/$FileName","$Permission_NGroup") != 0)) {
		$ssh->capture("rm -rf $Directory/$FileName"); return 1;
	}

	if (($Permission_Other ne "") && (checkOtherFilePermission("$Directory/$FileName","$Permission_Other") != 0)) { 
		$ssh->capture("rm -rf $Directory/$FileName"); return 1;
	}

	$ssh->capture("rm -rf $Directory/$FileName");

	return 0;
}

#We need to end with success
1
