#!/usr/bin/perl


sub moveDown($$)
{
	my $T=$_[0];
	my $P=$_[1];

#print ("Moving down $T/$P...\n");
	my $N=$P+1;
	if (-f "/leats-scripts/${T}/${N}.pl") { &moveDown($T,$N); }
	if (-f "/leats-scripts/${T}/${P}.pl") 
	{
		print "Action DOWN ${T}/${P}\n";
		my $fh;
		my $fh2;
		open($fh,"<","/leats-scripts/${T}/${P}.pl");
		open($fh2,">","/leats-scripts/${T}/${N}.pl");
		my $line;
		while ($line=<$fh>)
		{
			if ($line=~m/our \$problem="$P";/) { print $fh2 "our \$problem=\"$N\";\n"; }
			else
			{			
				print $fh2 "$line";
			}
		}
		close($fh);
		system("rm -f /leats-scripts/${T}/${P}.pl");
		system("mv /leats-scripts/${T}/${P}-solution.pl /leats-scripts/${T}/${N}-solution.pl");
		return 0;
	}
}

sub moveUp($$)
{
 my $T=$_[0];
 my $P=$_[1];

my $N=$P-1;
if (-f "/leats-scripts/${T}/${P}.pl")
        {
                print "Action UP ${T}/${P}\n";
   		if (-f "/leats-scripts/${T}/${N}.pl") { print "/leats-scripts/${T}/${N}.pl is exist..\n\n"; return 1; }
                my $fh;
                my $fh2;
                open($fh,"<","/leats-scripts/${T}/${P}.pl");
                open($fh2,">","/leats-scripts/${T}/${N}.pl");
                my $line;
                while ($line=<$fh>)
                {
                        if ($line=~m/our \$problem="$P";/) { print $fh2 "our \$problem=\"$N\";\n"; }
                        else
                        {
                                print $fh2 "$line";
                        }
                }
                close($fh);
		system("rm -f /leats-scripts/${T}/${P}.pl");
                system("mv /leats-scripts/${T}/${P}-solution.pl /leats-scripts/${T}/${N}-solution.pl");
		my $NN=$P+1;
		if (-f "/leats-scripts/${T}/${NN}.pl") { &moveUp($T,$NN); }
                return 0;
        }


}

sub useage()
{
	print "Useage:
		ExerciseMoveDown.pl <DIRECTION> <TOPIC>/<PROBLEM>

		E.g. ExerciseMoveDown.pl DOWN 05-user-group/3";
	exit 0;

}

if ((scalar @ARGV) < 2)
{
	&useage;
}
else
{
	my $Direction=uc($ARGV[0]);	

	my @A = $ARGV[1] =~ m/(.*)\/(.*)/g;
	my $Topic=$A[0];
	my $Problem =$A[1];

	print "Topic: $Topic | Problem: $Problem\n";

	if (-f "/leats-scripts/${Topic}/${Problem}.pl") 
	{ 
		if ( $Direction eq "DOWN") { &moveDown($Topic,$Problem); }
		elsif ( $Direction eq "UP") { &moveUp($Topic,$Problem); }
	}
	else{ print "/leats-scripts/${Topic}/${Problem}.pl not exist!\n"; &useage; }
}
