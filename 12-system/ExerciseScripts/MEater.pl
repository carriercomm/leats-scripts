#!/usr/bin/perl
#

my $FreeMem=`free -m`;
my @A = $FreeMem =~ m/Mem:\s+\S+\s+\S+\s+(\S+)\s+/;
my $FM = $A[0];

my $i=0;
my %H = ();

while (1)
{
	while ($FM > 40)
	{

		my $FreeMem=`free -m`;
		my @A = $FreeMem =~ m/Mem:\s+\S+\s+\S+\s+(\S+)\s+/;
		$FM = $A[0];
		print "$FM   \r";
		$i++;
		for(my $j=0; $j<1000; $j++)
		{
			my $k="$i.$j";
			$H{$k}=100000 x "A";
		}

	}
	sleep(5);
}
