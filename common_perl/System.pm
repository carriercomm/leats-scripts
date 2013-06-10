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
    	@Packages::EXPORT      = qw( &checkProcessRun &CopyFromDesktop );
    	@Packages::EXPORT_OK   = qw( $verbose $topic $author $version $hint $problem $name );
	## We need to colse STDERR since Linux::LVM prints information to STDERR that is not relevant.
#	close(STDERR);
}
use vars qw ($verbose $topic $author $version $hint $problem $name);


sub checkProcessRun($)
{
	my $Process=$_[0];

	print "PROCESS: $Process\n";

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

	my $output=`scp $Source root\@1.1.1.2:/$Destination`;
	$verbose and print "$output";

	my $ssh=Framework::ssh_connect;
        my $output=$ssh->capture("chmod $Permissions $Destination; chown $Owner $Destination; chgrp $Group $Destination");


}

#### We need to end with success
1
