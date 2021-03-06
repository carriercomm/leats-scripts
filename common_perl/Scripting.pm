package Scripting;
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
use Sys::Virt;
use Term::ANSIColor;
use Linux::LVM;
use XML::Simple;
use Data::Dumper;
use Switch;
BEGIN {
	use Exporter;
	use lib '/scripts/common_perl/';
	use Framework qw($verbose $topic $author $version $hint $problem $name);

    	@Disk::ISA         = qw( Exporter );
    	@Disk::EXPORT      = qw( &CheckScriptOutput );
    	@Disk::EXPORT_OK   = qw( $verbose $topic $author $version $hint $problem $name );
	## We need to colse STDERR since Linux::LVM prints information to STDERR that is not relevant.
#	close(STDERR);
}
use vars qw ($verbose $topic $author $version $hint $problem $name);
#use Disk qw(&Exist);
use UserGroup qw(&checkUserFilePermission);

#Returns the free space on the given vg.
#
# 1. Parameter: Runtime user 
# 2. Parameter: Command
# 3. Parameter: Check Commands
# 4. Parameter: Arguments
# 5. Parameter: OTHER Options
# 		STDERR_ONLY: print only the Standard Error Output
#
#
sub CheckScriptOutput($$$$;$) 
{
	my $User = $_[0];
	my $Script = $_[1];
	my $CheckCommands = $_[2];
	my $Arguments = $_[3] || "";
	my $OtherOption = $_[4] || "";

	my $TestScript="/tmp/$topic-$problem-check.sh";

	my $RedirectionPre="";
	my $Redirection="";

	my $Sudo="";
	my $SudoPost="";

	if ($User ne "root") 
	{ 
		$Sudo="su - $User -c '";
		$SudoPost="'";
	}

	if ($OtherOption eq "STDERR_ONLY") 
	{   
		$RedirectionPre="mkfifo err 2>/dev/null;";
		$Redirection="1>/dev/null 2>err | cat - err";
	}

	$CheckCommands=~s/'/\\'/g;

	if (checkUserFilePermission("$User","$Script","r*x") == 0) 
	{
		$verbose and print "Script is executable for $User.\n";
	}
	else
	{
		$verbose and print "Script is not executable for $User!\n";
		return 1;
	}

	$verbose and print "Check the scripts ($Script) output.\n";

	$verbose and print "CheckCommand: \n$CheckCommands\n\n";

	my $ssh=Framework::ssh_connect;
	my $CheckOutput=$ssh->capture("$Sudo echo \"$CheckCommands\" > $TestScript; chmod +x $TestScript; $RedirectionPre $TestScript $Arguments $Redirection; rm -rf $TestScript $SudoPost");
	$verbose and print "CheckOutput: $CheckOutput\n";

	$ssh=Framework::ssh_connect;
	my $ScriptOutput=$ssh->capture("$Sudo $RedirectionPre $Script $Arguments $Redirection $SudoPost");
	$verbose and print "ScriptOutput: $ScriptOutput\n";


	if ($CheckOutput eq $ScriptOutput) { return 0; }
	else { return 1; }
}



#### We need to end with success
1
