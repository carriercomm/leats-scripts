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
#our $author='Krisztian Banhidy <krisztian@banhidy.hu>';
our $author='Richard Gruber <richard.gruber@it-services.hu>';
our $version="v0.92";
our $topic="Users and groups";
our $problem="1";
our $description="- crypt testing";
our $hint="";
#
#
#
#############
our $verbose=0;
my $help=0;
my $break=0;
my $grade=0;
my $hint=0;
use strict;
use warnings;
use Getopt::Long;
use Term::ANSIColor;
use File::Basename;
our $name=basename($0);
use lib '/scripts/common_perl/';
use Framework qw($verbose $topic $author $version $hint $problem $name $exercise_number $exercise_success &printS &cryptText &encryptText &cryptText2File);
######
###Options
###
GetOptions("help|?|h" => \$help,
		"verbose|v" => \$verbose,
		"b|break" => \$break,
		"g|grade" => \$grade,
		"hint" => \$hint,
	  );

#####
# Subs
#
sub break() {
	print "Break has been selected.\n";
	&pre();
	
	$verbose and print "Pre complete breaking\n";	
	print "Your task: $description\n";
}

sub grade() {
	print "Grade has been selected.\n";
	system("clear");
	$exercise_number = 0;
	$exercise_success = 0;

	my $L=50;

	print "="x$L."=========\n";
	print "$topic/$problem.\n";
	print "\n$description\n\n";
	print "="x$L."=========\n\n";

	print "Testing crypt\n\n";
	my $Line="This line will be crypted.";
	print "Line= $Line\n";

	my $CLine = cryptText("$Line");
	print "\nKODOLT: $CLine\n\n";

	print "DEKODOLVA: ".encryptText($CLine)."\n\n";


	&cryptText2File("Szupertitkos","/tmp/a.txt");
	&cryptText2File("kodolt uzenet","/tmp/a.txt");
	&cryptText2File("R.G.","/tmp/a.txt");

## Running post
	&post();

}

sub pre() {
### Prepare the machine 
	$verbose and print "Running pre section\n";
}

sub post() {
### Cleanup after succeful grade
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

if ( $break ) {
	&break;
} elsif ( $grade ) {
	&grade;
} else {
	print "Nothing has been selected. Please select one option.\n";
	Framework::useage;
}
