package Framework;
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
use MIME::Base64;
use Crypt::RSA;
use Crypt::Random;
BEGIN {
	use Exporter ();

    	@Framework::ISA         = qw(Exporter);
    	@Framework::EXPORT      = qw( &restart &shutdown &start &mount &umount &verbose &connecto &return &grade &timedconTo &useage &hint &ssh_connect &printS &cryptText &decryptText &cryptText2File &decryptFile &getStudent );
    	@Framework::EXPORT_OK   = qw( $verbose $topic $author $version $hint $problem $name $exercise_number $exercise_success $line_length $result_file $student_file);

}


use vars qw ($verbose $topic $author $version $hint $problem $name $exercise_number $exercise_success $line_length $result_file $student_file);

$student_file="/ALTS/User.alts";

sub restart (;$) {
	### Parameters: server
	my ($virt) = @_;
	$virt ||="server";
	$verbose and print "Restart has been requested\n";
	$verbose and print "Shutdown started.\n";
	&shutdown($virt);
	$verbose and print "Startup started\n";
	&start($virt);
}
sub shutdown (;$) {
	### Parameters: server
	my ($virt) = @_;
	$virt ||="server";
	$verbose and print "Shutdown has been requested.\n";
	my $con= Sys::Virt-> new (address=> "qemu:///system" ) ;
        my $server= $con->get_domain_by_name("$virt");
	if ( $server->is_active() ) {
		$verbose and print "Server needs to be shut down.\n";
		$server->destroy();
		my $time=0;
                while ( $time < 46 ) {
                        $verbose and print "Waiting for command to return $time\\45\n";
                        $time+=5;
                        sleep 5;
                        if ( ! $server->is_active() ) {
                                $verbose and print "Server is down.\n";
                                return 0;
                        }
                }
		return 1;
	} else {
		$verbose and print "Server is already shutdown.\n";
		return 0;
	}
        return 1;
}

sub start (;$) {
	### Parameters: server
	my ($virt) = @_;
	$virt ||="server";
	$verbose and print "Start has been requested.\n";
        my $con= Sys::Virt-> new (address=> "qemu:///system" ) ;
        my $server= $con->get_domain_by_name("$virt");
	if ( $server->is_active() ) {
		$verbose and print "Server is already running.\n";
		return 0;
	} else {
		$server->create();
		my $time=0;
		while ( $time < 46 ) {
                	$verbose and print "Waiting for command to return $time\\45\n";
                	$time+=5;
                	sleep 5;
                	if ( $server->is_active() ) {
                        	$verbose and print "Server is up.\n";
				return 0;
                	}
		}
        }
	$verbose and print "Server failed to start. Please contact Dev.\n";
	return 1;
}

sub mount(;$$) {
	### Parameters: server fs
	my ($server, $fs)=@_;
        $server ||="1.1.1.2";
        $fs ||="/mentes";
	$verbose and print "Mount has been requested.\n";
	$verbose and print "Checking if already mounted.\n";
	open my $mounts, "/proc/mounts";
        while ( my $line=<$mounts> ) {
                chomp $line;
                if ( $line=~/$fs/ ) {
                        $verbose and print "Found mount $fs, unmounting directory.\n";
                        system("umount", "$fs");
                }
        }
	$verbose and print "Mounting the internal filesystem.\n";
	my $disk=`kpartx -av /dev/mapper/vg_desktop-server 2>/dev/null | head -n1 | awk '{print \$3}'`;
        chomp $disk;
        $disk="/dev/mapper/$disk";
        $verbose and print "My disk is:$disk\n";
        system("mount", "$disk", "$fs");
	while ( my $line=<$mounts> ) {
                chomp $line;
		if ( $line=~/$fs/ ) {
			$verbose and print "Mount was succesful.\n";
        		close $mounts;
			return 0;
		}
	}
        close $mounts;
	system("kpartx -d /dev/mapper/vg_desktop-server >/dev/null 2>\&1");
	$verbose and print "Mount was not succesful.\n";
	return 1;
}

sub umount(;$$) {
	### Parameters: server fs
	my ($server, $fs)=@_;
        $server ||="1.1.1.2";
        $fs ||="/mentes";
	$verbose and print "Umount has been requested.\n";
	open my $mounts, "/proc/mounts";
        while ( my $line=<$mounts> ) {
                chomp $line;
                if ( $line=~/$fs/ ) {
                        $verbose and print "Found mount $fs, unmounting directory.\n";
                        system("umount", "$fs");
			last;
                }
        }
	while ( my $line=<$mounts> ) {
                chomp $line;
                if ( $line=~/$fs/ ) {
			close $mounts;
			$verbose and print "Umount was not succesful.\n";
			return 1;
                }
        }
	$verbose and print "Umount was succesful.\n";
	system("kpartx -d /dev/mapper/vg_desktop-server >/dev/null 2>\&1");
	close $mounts;
	return 0;
}

sub connectTo(;$$) {
	###  Parameters: server port
	my ($server, $port)=@_;
	$server ||="1.1.1.2";
	$port ||="22";
	$verbose and print "Trying to connect to $port on $server.\n";
	my $return=`nc -z $server $port > /dev/null 2>&1 && echo -n 0 || echo -n 1`;
	$verbose and print "My return is:'$return'\n";
	if ( $return ) {
		$verbose and print "Connection unsuccesful.\n";
		return 1;
	} else {
		$verbose and print "Connection succesful.\n";
		return 0;
	}
}

sub timedconTo(;$$$) {
	### Parameters: time server port
	my ( $time, $server, $port)=@_;
	$time ||="45";
	$server ||="1.1.1.2";
        $port ||="22";
	$verbose and print "Timed connection $server on port $port for $time seconds.\n";
	while ( $time>1) {
		$time-=5;
		sleep 5;
		my $return=&connectTo($server,$port);
		if ( $return ) {
			$verbose and print "Server not up yet. Left: $time\n";
		} else {
			$verbose and print "Server Up.\n";
			return 0;
		}
	}
	return 1;
}


sub cryptText($)
{
	my $Data=$_[0];
	my $File=$_[1];

#	$verbose and print "Crypting the given Data...";
#	$verbose and print "\nText: $Data\n\n";
	my $rsa = new Crypt::RSA;

my $public = bless( {
                 'e' => 65537,
                 'n' => '110185927530538182741032138784217912951071916313574883320975228314295176610794175045816124151503972363121001080720758472285809475647093180514931501190970725426325035359206093659836137650897109900806043300415344860446319369853995999860939402408608126574409195778387386026503853537015920191570288558344165964673',
                 'Version' => '1.99'
               }, 'Crypt::RSA::Key::Public' );

	my $EData = $rsa->encrypt ( 
			Message    => $Data,
			Key        => $public,
			Armour     => 1,
			) or die $rsa->errstr();


	$EData =~ s/\n/\t/g;
#	$verbose and print "\nEncrypted Text: $EData\n\n";

	return $EData;
}

sub decryptText($)
{
my $EData=$_[0];

$EData =~ s/\t/\n/g;

#$verbose and print "Encpting the given Data...";
#$verbose and print "\nEncrypted Data: $EData\n\n";

my $rsa = new Crypt::RSA;

my $private = bless( {
                 'Version' => '1.99',
                 'Checked' => 1,
                 'private' => {
                                '_phi' => '110185927530538182741032138784217912951071916313574883320975228314295176610794175045816124151503972363121001080720758472285809475647093180514931501190970703955488738272762377222866937942397942445596326809324649951751063046494262974062477095470368749497251544066300759404904887302581975174770665114999649531860',
                                '_n' => '110185927530538182741032138784217912951071916313574883320975228314295176610794175045816124151503972363121001080720758472285809475647093180514931501190970725426325035359206093659836137650897109900806043300415344860446319369853995999860939402408608126574409195778387386026503853537015920191570288558344165964673',
                                '_q' => '8485245867687154883482642244160775448589107722987002303200226001014411977652195261004541335270688649535423542741912983157907145756596143913048318546676083',
                                '_p' => '12985590429399288832954326955547723718866101993504088391708469255308947755373603201302396904106388508116288543884708615808327288188420655710395025969756731',
                                '_u' => '1920728030938391399175292649129357944966690250449115055512129892330756942087195107550699039547118226235723825563354310197906839863563727059933907805554680',
                                '_dp' => '8091300651158114634214609999797776001092758914914215688295269092417965279741771218218482383631970964759399407633488884678103256793297616561479641736743913',
                                '_dq' => '6748370922007261346062259167342843552975593523315509316071870540685005128388356522179512389596393392909125316917069571511610788579356763553960426313225365',
                                '_d' => '95318384659296759575813297469100666140471355470677852739664152983057673417647511482788338536175995379019211060475497517856656276795341574623701520187388697835611616760547327681664070367980056288976275266305319199300773125989070983589393418230878524863774341811417294867047281394213688459319896974682852900793',
                                '_e' => '65537'
                              },
                 'Cipher' => 'Blowfish'
		 }, 'Crypt::RSA::Key::Private' );

my $Data = $rsa->decrypt (
		Cyphertext => $EData,
		Key        => $private,
		Armour     => 1,
		) or die $rsa->errstr();

return $Data;
}

sub cryptText2File($$)
{
	my $Data = $_[0];
	my $File = $_[1];

	my $fn;
	open($fn,">>",$File) || ( print "\nUnable to open $File\n\n" and die); 
	print $fn cryptText($Data)."\n";
	close($fn);
}


sub decryptFile($)
{
	my $File=$_[0];

	my $EFC; #Encrypted File Content

	my $fd;
	$verbose && print "Encrypt $File...\n";
	open($fd,"<",$File) || ( print "\nUnable to open $File !\n\n" and die);
	my $line;
	while($line=readline($fd))
	{
		chomp($line);
		$EFC .= decryptText($line)."\n";
	}
	close($fd);

	return $EFC;
}

sub getStudent()
{
	print "RUNINIG getStudent....";
	if (!(-e "$student_file")) { print "There is no ALTS user logged in! Please Login with the command LoginALTSUser!"; die; }
	my $UserData =decryptFile("$student_file");
	$UserData=~s/\n//g;
	print "UD= $UserData\n\n";
	my @A = $UserData =~ m/<STUDENT>(.*)<\/STUDENT>/;
	print "A= @A\n";
	return "$A[0]";
}

sub return($) {
### Parameter: return_value
	my ($value)=@_;
	$verbose and print "Testing return value.\n";
	if ( $value ) {
		print "Something wrong has happened.\n";
		exit 1;
	} else {
		$verbose and print "Everything ok with value.\n";
		return 0;
	}
}

sub grade($;$$$$$) {
### Parameter: booleen
	my $grade=0;
	foreach my $g (@_){ $grade += $g; }

	$verbose and print "Grading user\n";

	if ( $grade == 0 ) {
		print " [ ";
		print color 'bold green';
		print 'PASS';
		print color 'reset';
		print " ]\n";
		${exercise_number}++;
		${exercise_success}++;
		my $T=$topic; $T =~ s/\s//g;
		cryptText2File("<RESULT>[ PASS ]</RESULT>","/ALTS/RESULTS/${T}-${problem}");
	} else {
		print " [ ";
		print color 'bold red';
		print 'Fail';
		print color 'reset';
		print " ]\n";
		$exercise_number++;
		my $T=$topic; $T =~ s/\s//g;
		cryptText2File("<RESULT>[ Fail ]</RESULT>","/ALTS/RESULTS/${T}-${problem}");
	}
}


sub printS ($;$)
{
	my $Text = $_[0];
	my $E;
	if ((scalar (@_)) == 2) { $E = $_[1]-length($Text); }
	else
	{
		my $TerminalCols=`tput cols`;
		$E=($TerminalCols-length($Text))-($TerminalCols/1.75);
	}
	print "$Text"." "x${E};

	my $T=$topic; $T =~ s/\s//g;
	cryptText2File("<TASK>$Text</TASK>","/ALTS/RESULTS/${T}-${problem}");
}

sub useage() {
	print "You are doing $topic topic\n";
	print "$name \$options \$switches\n";
	print "Options:\n";
	print "-b | -break 	     	Break the guest\n";
	print "-g | -grade      	Grade the solution\n";
	print "-hint	       		Helpful hint for solution if stuck\n";
	print "Switches::\n";
	print "-h | -? | -help       	Help (this menu)\n";
	print "-v | -verbose    	Verbose mode (only for developers)\n";
	print "Designed by $author, version $version\n";
	exit 0;
};
sub ssh_connect() {
	$verbose and print "SSH connection to server.\n";
	open my $stderr_fh, '>', '/dev/null';
	my $ssh = Net::OpenSSH->new("server", key_path=>"/scripts/ssh-key/id_rsa", default_stderr_fh => $stderr_fh);
	$ssh->error and ( $verbose and print "Couldn't establish SSH connection: ". $ssh->error);
	return $ssh;
}

sub hint() {
### Hint for solution
	print "Problem number: $problem in $topic topic \n";
	print "=========================================\n";
	print "$hint\n";
	exit 0;
};

sub verbose () {
	print "verbose is :'$verbose'\n";
}

#### We need to end with success
1
