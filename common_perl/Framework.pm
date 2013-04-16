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
use Crypt::Tea;
use Crypt::Random;
BEGIN {
	use Exporter ();

    	@Framework::ISA         = qw(Exporter);
    	@Framework::EXPORT      = qw( &restart &shutdown &start &mount &umount &verbose &connectTo &return &grade &timedconTo &useage &hint &ssh_connect &printS &cryptText &decryptText &cryptText2File &decryptFile &getStudent &EncryptResultFile &DecryptResultFile );
    	@Framework::EXPORT_OK   = qw( $verbose $topic $author $version $hint $problem $name $exercise_number $exercise_success $line_length $result_file $student_file $description &showdescription);

}


use vars qw ($verbose $topic $author $version $hint $problem $name $exercise_number $exercise_success $line_length $result_file $student_file $description);

$student_file="/ALTS/User.alts";

my $AESKeyFile="/ALTS/SECURITY/ALTSkey";

my $key = 'sdfsdds b$*LKDF D)(F IDD&P?/'; #Key for encryptions

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


sub cryptText($;$)
{
	my $Data=$_[0];
	my $Key=$_[1] ||= $key; #If you don't use the deafult

	my $EData = &encrypt ($Data, $key);

#	$verbose and print "\n[CryptText] Text: $Data\n\n";
#	$verbose and print "\n[CryptText] Encrypted Text: $EData\n\n";

	$EData =~ s/\n/|/g;

	return $EData;
}

sub decryptText($;$)
{
	my $EData=$_[0];
	my $Key=$_[1] ||= $key; #If you don't use the deafult

	$EData =~ s/|/\n/g;

	my $Data =  &decrypt ($EData, $key);

#	$verbose and print "[DecrypText] Encrypt Text: $EData \n";	
#	$verbose and print "\n[DecrypText] Decrypted Data: $Data\n\n";

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
	$verbose && print "Decrypt $File...\n";
	open($fd,"<",$File) || ( print "\nUnable to open $File !\n\n" and die);
	my $line;
	while($line=readline($fd))
	{
		chomp($line);
		$EFC .= decryptText($line);
	}
	close($fd);

	return $EFC;
}

sub EncryptResultFile(;$)
{
	my $File = $_[0] |= "$result_file";
	my $AES_Directory="/ALTS/RESULTS/ACTUAL/AES";
	$verbose && print "Encrypting $File...\n";
	if (!(-f $AESKeyFile)) { print "$AESKeyFile is unreachable!\n"; die; }
	system("openssl aes-256-cbc -a -salt -in $File -out $File.alts.aes -pass file:$AESKeyFile");
	system("chown root:apache $AESKeyFile; chmod 750 $AESKeyFile");
	system("chown root:root $result_file; chmod 700 $result_file");
	if (!-d $AES_Directory) {
		system("mkdir $AES_Directory; chown root:apache $AES_Directory; chmod 750 $AES_Directory");
	}
	system("ln -s /ALTS/RESULTS/ACTUAL/$topic-$problem.alts.aes $AES_Directory/$topic-$problem.alts.aes");

}

sub DecryptResultFile($$)
{
	my $File = $_[0];
	my $OutFile = $_[1];
	if (!(-f $AESKeyFile)) { print "$AESKeyFile is unreachable!\n"; die; }
	$verbose && print "Decrypting $File...\n";
	system("openssl aes-256-cbc -d -a -in $File -out $OutFile -pass file:$AESKeyFile");
}

sub getStudent()
{
	$verbose and print "Get students data..\n";
	if (!(-e "$student_file")) { 
		print color 'bold red';
		print "\n\nThere is no ALTS user logged in! Please Login with the command \"ALTSLogin\"!\n\n"; 
		print color 'reset';
		die; 
	}
	my $UserData =decryptFile("$student_file");
	$UserData=~s/\n//g;
	my @A = $UserData =~ m/<STUDENT>(.*)<\/STUDENT>/;
	my $UserName = $A[0];
	if ($UserName eq "") {
		print color 'bold red';
		print "\n\nThere is no ALTS user logged in! Please Login with the command \"ALTSLogin\"!\n\n";
		print color 'reset';
		die;
	}

	return "$UserName";
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
		cryptText2File("<RESULT>[ PASS ]</RESULT></TASK>\n","$result_file");
	} else {
		print " [ ";
		print color 'bold red';
		print 'Fail';
		print color 'reset';
		print " ]\n";
		$exercise_number++;
		my $T=$topic; $T =~ s/\s//g;
		cryptText2File("<RESULT>[ Fail ]</RESULT></TASK>\n","$result_file");
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
	cryptText2File("<TASK><TASKDESC>$Text</TASKDESC>","$result_file");
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
	print "-d | -description	Description of the exercise";
	print "-v | -verbose    	Verbose mode (only for developers)\n";
	print "Designed by $author, version $version\n";
	exit 0;
};
sub ssh_connect() {
	$verbose and print "SSH connection to server.\n";
	open my $stderr_fh, '>', '/dev/null';
	my $ssh = Net::OpenSSH->new("server", key_path=>"/ALTS/SECURITY/id_rsa", default_stderr_fh => $stderr_fh);
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

sub showdescription() {

print "$description";
exit 0;

}

sub verbose () {
	print "verbose is :'$verbose'\n";
}

#### We need to end with success
1
