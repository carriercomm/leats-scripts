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
use Net::OpenSSH;
use XML::Simple;
use Data::Dumper;
use Switch;
BEGIN {
	use Exporter;
	use lib '/scripts/common_perl/';
	use Framework qw($verbose $topic $author $version $hint $problem $name);

    	@Packages::ISA         = qw( Exporter );
    	@Packages::EXPORT      = qw( &checkProcessIsRunning &checkProcessIsntRunning &CopyFromDesktop &checkZombieProcesses &checkService);
    	@Packages::EXPORT_OK   = qw( $verbose $topic $author $version $hint $problem $name );
	## We need to colse STDERR since Linux::LVM prints information to STDERR that is not relevant.
	#close(STDERR);
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
# 6. Parameter:	 Action E.g. 
# 			- decompressTGZ (tar+gzip)
# 			- compressTGZ (tar+gzip)
# 			- decomressGZ (gunzip)
# 			- compressGZ (gzip)
#
#
#
sub CopyFromDesktop($$$$$;$)
{
	my $Source=$_[0];
	my $Destination=$_[1];
	my $Permissions=$_[2] || "755";
	my $Owner=$_[3] || "root";
	my $Group=$_[4] || "root";
	my $Action=$_[5] || "";

	$verbose and print "Copy $Source -> root\@1.1.1.2:/$Destination\n";

	system("scp $Source root\@1.1.1.2:/$Destination >/dev/null 2>&1");

	my $ssh=Framework::ssh_connect;
        my $output=$ssh->capture("chmod -R $Permissions $Destination; chown -R $Owner $Destination; chgrp -R $Group $Destination");

	my @D = $Destination =~ m/(.*)\/([^\/]*)/;
	my $Dir=$D[0];
	my $File=$D[1] || "*";

	if ($Action eq "compressGZ") 	{ $output=$ssh->capture("cd $Dir; gzip ./$File");  }
	elsif ($Action eq "decompressGZ")	{ $output=$ssh->capture("cd $Dir; gunzip ./$File"); }
	elsif ($Action eq "compressTGZ")       { $output=$ssh->capture("cd $Dir; tar -czvf /tmp/compressed.tgz ./$File); rm -rf ./*; mv /tmp/compressed.tgz ./compressed.tgz"); }
	elsif ($Action eq "decompressTGZ" )   { $output=$ssh->capture("cd $Dir; tar -xzvf $File; rm -rf ./$File"); }
}


#
# Checking service status
#
# 1. Parameter: service name
# 2. Parameter: service status; default: running
#
#
# E.g.
#      checkService("nfs","running");
#      checkService("nfs","stopped");
sub checkService($;$)
{
	my $service=$_[0];
	my $status=$_[1] || "running";

	my $ssh=Framework::ssh_connect;
        my $output=$ssh->capture("service $service status >/dev/null 2>&1; echo \$?");
	chomp($output);

	#print "output= $output";
	#print "status= $status";

	if (($output eq "0") && ($status eq "running") )  { return 0;}
	if (($output ne "0") && ($status eq "stopped") )  { return 0;}

	return 1;
}

#
#
# Checking chkconfig
#
# 1. Parameter: service name (E.g. nfs)
# 2. Parameter: RC0: on/off/* *=don't care
# 2. Parameter: RC1: on/off/* *=don't care
# 3. Parameter: RC2: on/off/* *=don't care
# 4. Parameter: RC3: on/off/* *=don't care
# 5. Parameter: RC4: on/off/* *=don't care
# 6. Parameter: RC5: on/off/* *=don't care
# 7. Parameter: RC6: on/off/* *=don't care
#
#
#  TODO: TEST IT
sub checkChkconfig($$$$$$$)
{ 
	my ($service,@RC) = @_;

	 print "Parameters: $service,0:$RC[0],1:$RC[1],2:$RC[2],3:$RC[3],4:$RC[4],5:$RC[5],6:$RC[6]";

	 my $ssh=Framework::ssh_connect;
         my $output=$ssh->capture("chkconfig --list $service");
	
	if (my @A = $output =~ m/$service\s+0:(\S+)\s+1:(\S+)\s+2:(\S+)\s+3:(\S+)\s+4:(\S+)\s+5:(\S+)\s+6:(\S+)\s+/) {  
		my $i;
		for($i=0;$i<7;$i++)
		{
			if ((($RC[$i] eq "on") && ("$A[$i]" ne "on")) || ( ($RC[$i] eq "off") && ("$A[$i]" ne "off")  ))  { return 1; }
		}
	}
	else
	{
		return 1;
	}
return 0;
}



#### We need to end with success
1
