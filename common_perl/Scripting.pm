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
use Disk qw(&Exist);
use UserGroup qw(&checkUserFilePermission);
#
#Returns the free space on the given vg.
#
#1. Parameter: Runtime user 
#2. Parameter: Command
#3. Paramter:  Check Command
#
sub CheckScriptOutput($$) 
{
	my $User = $_[0];
	my $Script = $_[1];

	if (checkUserFilePermission("$User","$Script","r*x") == 0) 
	{
		$verbose and print "Script is executable for $User.";
	}
	else
	{
		$verbose and print "Script is not executable for $User!";
		return 1;
	}

	$verbose and print "Check the scripts ($Script) output.\n";

	

	return 1;
}



#### We need to end with success
1
