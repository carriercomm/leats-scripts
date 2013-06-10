package Packages;
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
    	@Packages::EXPORT      = qw( &CreateRepo &CheckRepoExist &CheckRepoAttribute &GetRepoAttribute &CheckPackageInstalled &RemovePackage &InstallPackage);
    	@Packages::EXPORT_OK   = qw( $verbose $topic $author $version $hint $problem $name );
	## We need to colse STDERR since Linux::LVM prints information to STDERR that is not relevant.
#	close(STDERR);
}
use vars qw ($verbose $topic $author $version $hint $problem $name);

#Create repository
#
# CreateRepo
# ----------
#
# 1. Parameter: Repository file name 	E.g. local.repo
# 2. Parameter: Repository ID		E.g. local
# 3. Parameter: Repository Name		E.g. Local Repo
# 4. Parameter: Baseurl			E.g. http://desktop
# 5. Parameter: Gpgcheck 		0 or 1, default 0
# 6. Parameter: Gpgkey
# 7. Parameter: Enabled			0 or 1, default 1
#
# CreateRepo("local.repo","local","Local Repo","http://desktop",0,"",1);
#
# E.g. cat /etc/yum.repos.d/local.repo
#
# [local]
# name=Local Repo
# baseurl=http://desktop/
# gpgcheck=0
# enabled=1
# 
#
sub CreateRepo($$$$$$$) 
{
my $RepoFile 	  = $_[0];
my $Repo_ID 	  = $_[1];
my $Repo_name	  = $_[2];
my $Repo_baseurl  = $_[3];
my $Repo_gpgcheck = $_[4] || 0;
my $Repo_gpgkey   = $_[5] || "";
my $Repo_enabled  = $_[6] || 1;

my $GPG="gpgcheck=$Repo_gpgcheck";
if ($Repo_gpgcheck eq 1) {  $GPG.="\ngpgkey=$Repo_gpgkey"; }

my $Repo="[$Repo_ID]\nname=$Repo_name\nbaseurl=$Repo_baseurl\n$GPG\nenabled=$Repo_enabled";

 $verbose and print "Creating repo $RepoFile.repo\n\n";
 my $ssh=Framework::ssh_connect;
 my $output=$ssh->capture("echo '$Repo' > /etc/yum.repos.d/$RepoFile; chmod 644 /etc/yum.repos.d/$RepoFile; chown root:root /etc/yum.repos.d/$RepoFile");
 $verbose and print "$output";

return 0;

}

#
# CheckRepoExist
#
# Checks if Repo Exist
#
# 1. Parameter: 	  Repository name 	E.g. local
# 2. Parameter(optional): Enabled 		E.g. 1,0,disabled,enabled 
#     If you don't declare it, then it can be disabled and enabled too
#
# CheckRepoExist("local","1") -> true if repo "local" exist and it's enabled
# CheckRepoExist("local","0") -> true if repo "local" exist and it's diabled
#
#
sub CheckRepoExist($;$)
{
	my $Repo_ID = $_[0];
	my $Enabled = $_[1] || "";

	my $Command="";
	if (($Enabled eq '1')||($Enabled eq 'enabled')) { 
		$Command="yum repolist enabled"; 
	}
	elsif (($Enabled eq '0')||($Enabled eq 'disabled')) { 
		$Command="yum repolist disabled"; 
	}
	else { 
		$Command="yum repolist all"; 
	}

	my $ssh=Framework::ssh_connect;
	my $output=$ssh->capture("$Command");

	$verbose and print "$Command output:\n $output\n\n";
	my @Repos=split("\n",$output);

	if ($output =~ m/$Repo_ID\s+\S+.*/g) {return 0; }
	
	return 1; 

}


#
# GetRepoAttribute
#
# 1. Parameter: Repository name            E.g. local
# 2. Parameter: Attribute		   E.g.gpgcheck
#
# Returns the value of the given repository attirbute
#
# GetRepoAttribute("local","gpgcheck");
#
sub GetRepoAttribute($$)
{
	my $Repo_ID = $_[0];
	my $Attribute =$_[1];

	$verbose and print "\nRepo: $Repo_ID | $Attribute\n";

        my $ssh=Framework::ssh_connect;
        my $output=$ssh->capture("cat /etc/yum.repos.d/*.repo 2>/dev/null;echo '['");

	chomp($output);
	$output=~s/\n/;/g;
	$output=~s/\[/\n\[/g;
	my @Repos = split("\n","$output");

	foreach my $R (@Repos)
	{
		$verbose and print "+-+-+$R+-+-+-\n";
		if (my @B = $R =~ m/\[$Repo_ID];.*$Attribute\s*=\s*([^;]*);/) 
		{ 
			$verbose and print "\nRepo: $Repo_ID | $Attribute = $B[0]\n";
			return $B[0]; 
		}
	}

	return "";

}

#
# CheckRepoAttribute
#
# 1. Parameter: Repository name            		E.g. local
# 2. Parameter: Attribute                  		E.g. gpgcheck
# 3. Parameter: Attribute Value you want to check  	E.g. 0
#
# Check the value of the given repository attirbute
#
# CheckRepoAttribute("local","gpgcheck","1");
#
#
sub CheckRepoAttribute($$$)
{
	my $Repo_ID = $_[0];
	my $Attribute =$_[1];
	my $Value =$_[2];

	my $RepoAttributeValue = GetRepoAttribute("$Repo_ID","$Attribute");	
	
	if ($Attribute eq "baseurl") 
	{
		$RepoAttributeValue=extendWithSlash("$RepoAttributeValue");
		$Value=extendWithSlash("$Value");
	}

	if ( $RepoAttributeValue eq $Value ) { return 0; }
	return 1;

}

sub extendWithSlash($)
{
    my $A = "${_[0]}/";    
    $A =~ s/\/\//\//g;
    return $A;
}


#
# CheckPackageInstalled
#
# 1. Parameter: Package Name
# 2. Parameter: $Version (optional)
#
sub CheckPackageInstalled($;$)
{
	my $Package=$_[0];
	my $Version=$_[1] || ".*";

	my $ssh=Framework::ssh_connect;
	my $output=$ssh->capture("yum list installed");

	$verbose and print "Check PACKAGE: $Package\n";

	my @InstalledPackages=split("\n","$output");	
	foreach my $P (@InstalledPackages) { 
		if ($P =~ m/^$Package.*$Version.*/) { $verbose and print "++$P++\n"; return 0; }
	}
	
	return 1;
}
#
# Remove Package
#
# 1. Parameter: Package name (E.g. nano)
#
#
sub RemovePackage($)
{
	my $Package=$_[0];
	
	$verbose and print "Remove Package $Package..\n";

        my $ssh=Framework::ssh_connect;
        my $output=$ssh->capture("yum -y remove $Package");

	$verbose and print "$output\n";
}

#
# Install Package
#
# 1. Parameter: Package full name
# 2. Parameter: Path to the package
#
#
sub InstallPackage($;$)
{
my $Package=$_[0];
my $Path2Package=$_[1] || "http://1.1.1.1/Packages/";

	$verbose and print "Install package $Path2Package/$Package\n";
	
        my $ssh=Framework::ssh_connect;
        my $output=$ssh->capture("yum -y install $Path2Package/$Package");

	$verbose and print "$output\n";
}

#### We need to end with success
1
