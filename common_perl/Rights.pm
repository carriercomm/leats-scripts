package Rights;
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

BEGIN {
	use Exporter;

	@UserGroup::ISA         = qw(Exporter);
	@UserGroup::EXPORT      = qw( &CanRead );
	@UserGroup::EXPORT_OK   = qw( $verbose $topic $author $version $hint $problem $name $exercise_number $exercise_success);
}
use vars qw ($verbose $topic $author $version $hint $problem $name $exercise_number $exercise_success);

use UserGroup qw(userExist groupExist getUserAttribute checkUserAttribute checkUserPassword &checkUserGroupMembership &checkUserSecondaryGroupMembership &checkUserPrimaryGroup &checkGroupNameAndID &checkUserChageAttribute &checkUserLocked );

sub CanRead($$$)
{


}


#We need to end with success
1
