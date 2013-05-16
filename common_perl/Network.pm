package Network;
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
#use Sys::Virt;
use Term::ANSIColor;
#use XML::Simple;
#use Data::Dumper;
use Switch;
use IO::Socket;
use IO::Interface qw(:flags);
BEGIN {
	use Exporter;
	use lib '/scripts/common_perl/';
	use Framework qw($verbose $topic $author $version $hint $problem $name);

    	@Packages::ISA         = qw( Exporter );
    	@Packages::EXPORT      = qw( &CheckInterface &CheckNameserver &CheckHostsIP &CheckNsswitchConfig &CheckDefaultGateway);
    	@Packages::EXPORT_OK   = qw( $verbose $topic $author $version $hint $problem $name );
	## We need to colse STDERR since Linux::LVM prints information to STDERR that is not relevant.
#	close(STDERR);
}
use vars qw ($verbose $topic $author $version $hint $problem $name);

#
# Checking Interface
# 
# 1. Parameter: Interface E.g. eth0
# 2. Parameter: Attribute 
# 		Possible values: 
#	 		-state (e.g. "UP")
# 			-ip (e.g. "1.1.1.1")
# 			-ip_mask (e.g. "1.1.1.1/24")
# 			-mac (e.g. "52:54:00:E9:E1:2C")
# 			-bootproto (e.g. static)
# 3. Parameter: Value
#
# E.g. CheckInterface("eth0","state","UP");
#
sub CheckInterface($$$) 
{
	my $IF=$_[0];
	my $Attribute=lc($_[1]);
	my $Value=$_[2];

        my $ssh=Framework::ssh_connect;
        my $output=$ssh->capture("ip addr show $IF");
	my $output2=$ssh->capture("cat /etc/sysconfig/network-scripts/ifcfg-$IF");

	$output =~ s/\n/\t/g;
	$output2 =~ s/\n/\t/g;
#	print "\n\n$output\n";
#	print "\n\n$output2\n";
	
	my @A;
	switch ($Attribute)
	{
		case "state" { 
			@A = $output =~ m/state\s+(\S+)\s.*/;  
			if ((defined $A[0]) and ($Value eq $A[0])) { return 0; }
		}
		case "ip" {  
			@A = $output =~ m/inet (.*?)\/\d+\s+/g;
			if ($Value ~~ @A) { return 0; }
		}
		case "ip_mask" {
			@A = $output =~ m/inet (\S+\/\d+)\s+/g;
			if ($Value ~~ @A) { return 0; }
		}
		case "mac" {
			@A = $output =~ m/link\/ether\s+(\S+)\s/;
                        if (((defined $A[0]) and $Value eq $A[0])) { return 0; }
		}
		case "bootproto" {
			@A = $output2 =~ m/BOOTPROTO=["]{0,1}([^\"\s]+)["]{0,1}\s*/;
                        if ((defined $A[0]) and ($Value eq $A[0])) { return 0; }
		}
	}

#	print "\nATTRIBUTE: $Attribute || Value1: $Value || Value2: @A\n";

	return 1;
}


#
# Checking nameserver setup
#
# 1. Parameter: Nameserver
# 2. Parameter: Query
#
# E.g. CheckNameserver("1.1.1.1","desktop");
#
sub CheckNameserver($;$)
{
	my $NS=$_[0];
	my $Query=$_[1] || "desktop";

#Server:         1.1.1.1
#Address:        1.1.1.1#53
#
#Name:   desktop.pelda.hu
#Address: 1.1.1.1
#

#	print "\nNameserver: $NS\n";
#	print "\nQuery:      $Query\n";

	my $ssh=Framework::ssh_connect;
	my $output=$ssh->capture("nslookup $Query");

#	print "\nOutput:\n-------\n$output\n";

	my @SNS = $output =~ m/Server:\s+(\S+)\nAddress:\s+(\S+)\n/;
#	print "SNS: @SNS\n\n";

	if ($NS ~~ @SNS) { return 0;}

	return 1;

}

#
# Check Hosts IP
# Checks the IP for the host
# 
#
sub CheckHostsIP($$)
{
	my $Host=$_[0];
	my $IP=$_[1];

	my $ssh=Framework::ssh_connect;
	my $output=$ssh->capture("getent hosts $Host");

#	print "HOST: $Host | IP: $IP\n";
#	print "OUTPUT: $output\n";

#[root@server ~]# getent hosts test1machine
#1.1.1.1         test1machine

	my @A = $output =~ m/(\S+)\s+(\S+)/;
#	print "OUTPUT2: @A\n";

	if ((defined $A[0]) and ($IP eq $A[0])) { return 0; }

	return 1;
}


#
# CheckNsswitchConfig
#
# 1. Parameter: E.g hosts
# 2. Parameter: Stricted mode 
# 		true, if only the given values can be set up
# 		false, if only the sequence of the given values are necessary
# 		E.g. CheckNsswitchConfig("hosts","true","files","dns")
# 		in nswwitch.conf the following are: hosts:      files db dns
# 		in stricted mode it will be false, otherwise true, because "files" is before "dns"
# 3. Parameter: ARRAY of Values
#
#  E.g. CheckNsswitchConfig("hosts","true","files","dns")
#
#
sub CheckNsswitchConfig($$@)
{
	my $Parameter=shift @_;
	my $Stricted=lc(shift @_);
	my @Values=@_;

#	print "Parameter: $Parameter | Values: @Values\n";

	my $ssh=Framework::ssh_connect;
	my $output=$ssh->capture("cat /etc/nsswitch.conf");

#print "NSSWITCH: \n$output\n\n";

	my @NSS = split("\n",$output);
	my $V;
	if ($Stricted eq "false")
	{
		$V = join('\s+[\S+\s+]*',@Values);
		$V='[\S+\s+]*'.$V;
		$V.='[\S+\s+]*';
	}
	else
	{
		$V = join('\s+',@Values);
	}

	foreach my $line (@NSS)
	{
#		print "++ $line ++ $V ++\n";
		if ($line =~ m/^\s*$Parameter:\s*$V\s*$/) { return 0;};
	}

	return 1;
}

sub CheckDefaultGateway($$)
{
	my $IP=$_[0];
	my $IF=$_[1];


	my $ssh=Framework::ssh_connect;
        my $output=$ssh->capture("route -n | grep UG");

	my @A=$output=~m/^\S+\s+(\S+)\s+\S+\s+\S+\s+\S+\s+\S+\s+\S+\s+(\S+)/;

	$verbose and print "\nIP: $IP | IF: $IF | Check Default Gateway..\n";
	$verbose and print "\nFOUND: @A";

	if ((scalar @A)<2) { return 1; }

	if (($IP eq $A[0]) and ($IF eq $A[1]) ) { return 0; }
	return 1;

}

#### We need to end with success
1
