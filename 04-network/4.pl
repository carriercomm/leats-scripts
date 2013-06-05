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

our $version="v0.8";
our $topic="04-network";
our $problem="4";
our $description="Level:        Advanced

- Setup 2.2.2.1 for nameserver.
- Define test1machine into hosts file as 1.1.1.1.
- Make sure that the name resolving first should check the files and only after the DNS.
- Configure 2.2.2.1 to default gateway.
- Configure up the eth1 interface as follows:

Static IP
IP: 	2.2.2.88/16
ALIAS: 	1.1.1.88/24

(Mind that every modification has to be reboot-persistent.)";

our $hint="Set nameserver in /etc/resolv.conf.
Set test1machine in /etc/hosts.
Set the name resolving sequence in /etc/nsswitch.conf.
Delete the default gateway and add the new one. (route)
Set up eth1 with /etc/sysconfig/network-scripts/ifcfg-eth1.
Do not forget that the interface has to be up after reboot.
Reboot or restart network service.";
#
#
#
#############
our $verbose=0;
my $help=0;
my $break=0;
my $grade=0;
my $hint=0;
my $desc=0;
use strict;
use warnings;
use Getopt::Long;
use Term::ANSIColor;
use File::Basename;
use POSIX qw/strftime/;
our $name=basename($0);
#use Sys::Virt;
use lib '/scripts/common_perl/';
use Framework qw($verbose $topic $author $version $hint $problem $name $exercise_number $exercise_success $student_file $result_file &printS &cryptText2File &decryptFile &getStudent &EncryptResultFile &DecryptResultFile $description &showdescription);
use Network qw( &CheckInterface &CheckNameserver &CheckHostsIP &CheckDefaultGateway );
######
###Options
###
GetOptions("help|?|h" => \$help,
		"verbose|v" => \$verbose,
		"b|break" => \$break,
		"g|grade" => \$grade,
		"hint" => \$hint,
		"d|description" => \$desc,
	  );
#####
# Subs
#
sub break() {
	print "Break has been selected.\n";
	&pre(); #Reset server
        my $ssh=Framework::ssh_connect;
        my $output=$ssh->capture(" sed 's/^nameserver 1.1.1.1/#nameserver 1.1.1.1/g' /etc/resolv.conf > /tmp/test123233.txt; cat /tmp/test123233.txt > /etc/resolv.conf; sed 's/^hosts:      files dns/hosts:      dns files/g' /etc/nsswitch.conf > /tmp/test123233.txt;  cat /tmp/test123233.txt > /etc/nsswitch.conf; rm -rf /tmp/test123233.txt; cat /etc/sysconfig/network-scripts/ifcfg-eth0 | grep -v DNS1 > /tmp/1234; cat /tmp/1234 > /etc/sysconfig/network-scripts/ifcfg-eth0");
	
	print "Your task: $description\n";
}

sub grade() {
	system("clear");
	my $Student = Framework::getStudent();
	print "Grade has been selected.\n";
	print "rebooting server:";

#	Framework::restart;
#	Framework::timedconTo("120");

## Checking if mounted

	system("clear");
	my $T=$topic; $T =~ s/\s//g;
	$result_file="/ALTS/RESULTS/${Student}/${T}-${problem}"; #Empty the result file
	my $fn; open($fn,">","$result_file"); close($fn);
	my $now = strftime "%Y/%m/%d %H:%M:%S", localtime;
	$exercise_number = 0;
	$exercise_success = 0;

	my $L=80;


	print "="x$L."=========\n";
	print "Student:\t$Student\n\n";
	print "Date:   \t$now\n";
	print "-"x$L."---------\n\n";
	print "$topic/$problem\n";
	print "\n$description\n\n";
	print "="x$L."=========\n\n";

	my $USERDATA=decryptFile("$student_file");
	
	cryptText2File("<ROOT>$USERDATA<DATE>$now</DATE><TOPIC>$topic</TOPIC><PROBLEM>$problem</PROBLEM><DESCRIPTION>$description</DESCRIPTION>","$result_file");	
	
        printS("Checking nameserver is 2.2.2.1:","$L");
        Framework::grade(Network::CheckNameserver("2.2.2.1","server1"));	

	printS("Checking IP of test1machine is 1.1.1.1:","$L");
	Framework::grade(Network::CheckHostsIP("test1machine","1.1.1.1"));

        printS("In name resolving sequence files are before dns:","$L");
        Framework::grade(Network::CheckNsswitchConfig("hosts","false","files","dns"));

        printS("Checking default gateway is 2.2.2.1 through eth1","$L");
        Framework::grade(Network::CheckDefaultGateway("2.2.2.1","eth1"));

	printS("Checking interface is up:","$L");
	Framework::grade(Network::CheckInterface("eth1","state","UP"));

	printS("Checking interface IP is static:","$L");
        Framework::grade(Network::CheckInterface("eth1","bootproto","static"));

	printS("Checking interface IP is 2.2.2.88/16","$L");
        Framework::grade(Network::CheckInterface("eth1","ip_mask","2.2.2.88/16"));	

	printS("Checking interface IP is 1.1.1.88/24","$L");
        Framework::grade(Network::CheckInterface("eth1","ip_mask","1.1.1.88/24"));

#	printS("Checking Mac address is 52:54:00:e9:e1:2c","$L");
#       Framework::grade(Network::CheckInterface("eth1","mac","52:54:00:e9:e1:2c"));	

	print "\n"."="x$L."=========\n";
	print "\n\tNumber of exercises: \t$exercise_number\n";
	print "\n\tSuccessful: \t\t$exercise_success\n";
	if ($exercise_number == $exercise_success) {
		cryptText2File("<TASKNUMBER>$exercise_number</TASKNUMBER><TASKSUCCESSFUL>$exercise_success</TASKSUCCESSFUL><FINALRESULT>PASSED</FINALRESULT></ROOT>","$result_file");
		print color 'bold green' and print "\n\n\tSuccessful grade.\n\n"  and print color 'reset';
		&EncryptResultFile();
		exit 0;;
		#Running post
		&post();
	}
	else
	{
		cryptText2File("<TASKNUMBER>$exercise_number</TASKNUMBER><TASKSUCCESSFUL>$exercise_success</TASKSUCCESSFUL><FINALRESULT>FAILED</FINALRESULT></ROOT>","$result_file");
		&EncryptResultFile();
		print color 'bold red' and print "\n\n\tUnsuccessful grade. Please try it again!\n\n"  and print color 'reset';
		exit 1;
	}
}

sub pre() {
### Prepare the machine 
        $verbose and print "Reseting server machine...\n";
        system("/ALTS/RESET");

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

if ( $desc ) {
	Framework::showdescription;
}

if ( $break ) {
	&break;
} elsif ( $grade ) {
	&grade;
} else {
	print "Nothing has been selected. Please select one option.\n";
	Framework::useage;
}
