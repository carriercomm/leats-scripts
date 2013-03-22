#!/usr/bin/perl

use strict;
use warnings;
use Sys::Virt;
use Crypt::Tea;
use Crypt::Random;
use String::Random;

use lib '/scripts/common_perl/';
use Framework qw(&cryptText &decryptText);

my %DMin=();
my %DMax=();

$DMin{1}=1;
$DMax{1}=2;
$DMin{2}=301;
$DMax{2}=600;
$DMin{3}=601;
$DMax{3}=800;
$DMin{4}=801;
$DMax{4}=900;
$DMin{5}=901;
$DMax{5}=1000;


if (((scalar @ARGV) < 2) && (($ARGV[1] ne "1") || ($ARGV[1] ne "2") || ($ARGV[1] ne "3") || ($ARGV[1] ne "4") || ($ARGV[1] ne "5")) )
{
	print "\n\nUsing of the script:\n";
	print "1. argument: Path of your file, that contains the username (1 in each line)\n";
	print "2. argument: Exercise difficulty, must be between 1 and 5";
	print "\t E.g ./ExerciseCoding '/tmp/usersfile.txt' '1'\n\n";
	die;
}

my $UserFile=$ARGV[0];
my $Difficulty=$ARGV[1];

my $fn;
open ($fn,"<","$UserFile") or die "Can't read $UserFile!!";
print "Username;Password;Exercise\n";

while (my $U = <$fn>)
{
	chomp($U);
	my $pass = new String::Random;
	my $password = $pass->randpattern("CnCcnC");
	my $e=-1;
	while (!(($e>=$DMin{$Difficulty})&&($e<=$DMax{$Difficulty})))
	{
	$e = int(rand($DMax{$Difficulty}));
	}
	my $exercise=cryptText("$e","${U}${pass}");

#	print "EXERCISE=$e\n";
	print "$U;$password;$exercise\n";
}
close($fn);
