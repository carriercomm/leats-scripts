package System;
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
use XML::Simple;
use Data::Dumper;
use Switch;
BEGIN {
	use Exporter;
	use lib '/scripts/common_perl/';
	use Framework qw($verbose $topic $author $version $hint $problem $name);

    	@Packages::ISA         = qw( Exporter );
    	@Packages::EXPORT      = qw( &checkProcessIsRunning &checkProcessIsntRunning &CopyFromDesktop &checkZombieProcesses );
    	@Packages::EXPORT_OK   = qw( $verbose $topic $author $version $hint $problem $name );
	## We need to colse STDERR since Linux::LVM prints information to STDERR that is not relevant.
#	close(STDERR);
}
use vars qw ($verbose $topic $author $version $hint $problem $name);


#
# Returns the number of running processes
#
# 1. Parameter: Process (or part of it)
#
#
sub getProcessNum($)
{
        my $Process=$_[0];

	my $PN=0;

	my $ssh=Framework::ssh_connect;
        my $output=$ssh->capture("ps -ef");
        $verbose and print "$output";
	
	my @Ps = split("\n",$output);
	foreach my $p (@Ps)
	{
		if ($p =~ m/(?:\S+\s+){6}\s+.*$Process.*/) { $PN++; }
	} 

return $PN;

}

#
# Checks if process is running
#
# 1. Parameter: Process (or part of it)
#
#
sub checkProcessIsRunning($)
{
	my $Process=$_[0];

	my $PN=&getProcessNum($Process);

	if ($PN>0) { return 0; }
	else { return 1; }
}

#
# Checks if process isn't running
#
# 1. Parameter: Process (or part of it)
#
sub checkProcessIsntRunning($)
{
        my $Process=$_[0];

        my $PN=&getProcessNum($Process);

        if ($PN==0) { return 0; }
        else { return 1; }
}

#
# Checks Zombie Processes
#
# Returns 0 if there isn't any.
#
sub checkZombieProcesses()
{

  my $ssh=Framework::ssh_connect;
  my $output=$ssh->capture("ps aux");

  my $ZN=0;
  my @Ps = split("\n",$output);
        foreach my $p (@Ps)
        {
                if ($p =~ m/(?:\S+\s+){6}\s+Z\s+.*/) { $ZN++; }
        }

 if ($ZN==0) { return 0; }

 return 1;

}

#
# Copy a file form Desktop machine to the Server machine
#
# 1. Parameter:  Source  E.g. /ALTS/ExerciseScripts/12-system-1.pl
# 2. Parameter:  Destination E.g. /usr/bin/MyScript.pl
# 3. Parameter:  Permissions E.g. 755
# 4. Parameter:  Owner E.g. john
# 5. Parameter:  Group E.g. group1
#
#
#
sub CopyFromDesktop($$$$$)
{
	my $Source=$_[0];
	my $Destination=$_[1];
	my $Permissions=$_[2] || "755";
	my $Owner=$_[3] || "root";
	my $Group=$_[4] || "root";

	$verbose and print "Copy $Source -> root\@1.1.1.2:/$Destination\n";

	system("scp $Source root\@1.1.1.2:/$Destination >/dev/null 2>&1");

	my $ssh=Framework::ssh_connect;
        my $output=$ssh->capture("chmod $Permissions $Destination; chown $Owner $Destination; chgrp $Group $Destination");
}

#### We need to end with success
1
