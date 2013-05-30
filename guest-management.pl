#!/usr/bin/perl
#
use strict;
use warnings;
use Getopt::Long;
use Switch;
use File::Basename;
use Sys::Virt;
use Net::Ping;
#use Sys::Virt::Domain;
######
#Options
#
our ($topic, $author, $version, $hint, $problem, $name);
our $verbose=0;
our $help=0;
my $install=0;
my $reset=0;
my $output;
use lib '/scripts/common_perl/';
use Framework qw($verbose $topic $author $version $hint $problem $name &connectTo);


GetOptions("help|?" => \$help,
           "verbose|v" => \$verbose,
	   "i|install" => \$install,
	    "r|reset" => \$reset,
	);

sub useage() {
	print "Provisioning the guest\n";
	print "$0 \$options \n";
	print "i|install	Install the guest\n";
	print "r|reset		Reinstall the guest\n";
	};

if ( $help) {
	&useage;
}

sub install () {
	$verbose and print "Doing an install\n";
	my $args = "-n server" .
		   " --description \"Troubleshooting server \"".
		   " -r 512".
		   " --vcpus 1".
		   " -l http://1.1.1.1/".
		   " --os-type=linux".
		   " --os-variant=rhel6".
		   " --disk /dev/mapper/vg_desktop-server".
		   " --network bridge=br0,model=e1000".
		   " --network bridge=br0,model=e1000".
		   " --graphics vnc,listen=1.1.1.1,port=9999".
		   " --noautoconsole".
		   " --autostart".
		   " -x \"console=tty0".
		   " console=ttyS0,115200n8".
		   " ks=http://1.1.1.1/ks.cfg".
		   " ksdevice=link".
		   " ip=dhcp".
		   " method=http://1.1.1.1/".
		   "\"";
	$args .= " >/dev/null 2>&1" if (!$verbose);
	system("virt-install $args");
}

sub clean($) {
	my $con= Sys::Virt-> new (address=> "qemu:///system" ) ;
	my @doms=`virsh list --all | tail -n+3 | awk -F" " '(NF>0 ) {print \$2}'`;
        foreach my $dom (@doms) {
                $verbose and print "Found domain: $dom\n";
		chomp($dom);
                $verbose and print "Lets Destroy all domains before we continue.\n";
                $dom=$con->get_domain_by_name("$dom");
		if ( $dom->is_active() ) {
			$verbose and print "Domain is running, destroyin, and undefining.\n";
                	$dom->destroy();
                	$dom->undefine();
		} else {
			$verbose and print "Domain is not running, undefining.\n";
                	$dom->undefine();

		}
        }
}
if ( $install ) {
	&clean();
	system('http_proxy=""; https_proxy="";');
 	$verbose and print "Return to LV Snapshot of server if possible..\n";
        $output=`lvchange -an /dev/vg_desktop/server;lvchange -ay /dev/vg_desktop/server;lvconvert --merge /dev/vg_desktop/server_snapshot`;
        $verbose and print "$output";

	print "Running install, May take up to 15 minutes.\n";
	my $time=0;
	&install;
	my $con= Sys::Virt-> new (address=> "qemu:///system" ) ;
	my $server= $con->get_domain_by_name("server");
	while ( $server->is_active() ) {
		sleep 15;
		$time +=15;
		print "Install still running..$time\\900 seconds\n";
		if ( $time > 901 ) {
			last;
		}
	};
	if ( $server->is_active() ) {
		print "Install is still active, or some error has happened. Please contact developers.\n";
		exit 10;
	};
	print "Install compeleted Succesfully in $time seconds.\n";
	system("cp -p /etc/libvirt/qemu/server.xml /ALTS/SECURITY/server.xml");
        $verbose and print "Creating snapshot\n";
	system("lvcreate -pr --snapshot -L 2G --name server_snapshot /dev/vg_desktop/server");	
	print "Performing post test.\n";

	system("kill `ps -ef | grep \"/usr/bin/python /usr/share/virt-manager/virt-manager.py\" | grep -v grep | awk '{print \$2}'`");

        $verbose and print "Restart libvirtd service...";
        $output=`service libvirtd restart`;
        $verbose and print "$output";

        sleep 3;

	Framework::start;
## Ping test if host is alive.
	my $p = Net::Ping->new();
	$time=0;
	my $succes=1;
	while ( $time < 90 ) {
		print "Testing if server is ready... $time\\90 seconds\n";
		$time += +5;
		if ( $p->ping("server") ) {
			$verbose and print "Server is up\n";
			$succes=0;
			last;
		} else {
			$verbose and print "Server is not up yet....\n";
			sleep 5;
		}
	}
	$p->close();

 	my $i=0;
        while((connectTo("1.1.1.2","22")) && ($i<10) ) { sleep 6; $i++; $verbose and print "Trying to connect via SSH ($i/10)..\n"; };

	if ( $succes ) {
		print "Post test Not complete. Maybe Computer is only slow....\n";
	} else {
		print "Post test Complete.\n";
	}
} elsif ( $reset ) {
	&clean();
	print "Reset the server machine to the original state....\n";

	$verbose and print "Umount LVs if they are mounted";
#	$output=`umount /dev/vg_desktop/server 2>&1;umount /dev/vg_desktop/server_snapshot 2>&1;umount /dev/mapper/vg_desktop-vdb 2>&1`;
	$output=`umount /dev/vg_desktop/server 2>&1;umount /dev/vg_desktop/server_snapshot 2>&1`;
	$verbose and print "$output";

#	$verbose and print "Recreate vdb LV..";
#	$output=`lvremove -f /dev/mapper/vg_desktop-vdb;lvcreate -L 300M -n vdb vg_desktop`;
#	$verbose and print "$output";

	$verbose and print "Return to LV Snapshot of server if possible..\n";
	$output=`lvchange -an /dev/vg_desktop/server; lvchange -ay /dev/vg_desktop/server; lvchange -an /dev/vg_desktop/server;lvchange -ay /dev/vg_desktop/server;lvconvert --merge /dev/vg_desktop/server_snapshot`;
	$verbose and print "$output";        	

        $verbose and print "Creating new snapshot..\n";
        $output=`lvcreate -pr --snapshot -L 2G --name server_snapshot /dev/vg_desktop/server`;
        $verbose and print "$output";

#	system("kill `ps -ef | grep '/usr/bin/python /usr/share/virt-manager/virt-manager.py' | grep -v grep | awk '{print \$2}'`");

	$verbose and print "Recreate /etc/libvirt/qemu/server.xml..\n";
#	system("cp -p /ALTS/SECURITY/server.xml /etc/libvirt/qemu/server.xml");
	$output=`virsh define /ALTS/SECURITY/server.xml`;
	$verbose and print "$output";

#	$verbose and print "Restart libvirtd service...";	
#	$output=`service libvirtd restart`;
#	$verbose and print "$output";

#	sleep 4;

	Framework::start;
# Ping test if host is alive.
	my $p = Net::Ping->new();
	my $time=0;
	my $succes=1;
	while ( $time < 90 ) {
		$verbose and print "Testing if server is ready... $time\\90 seconds\n";
		$time += +5;
		if ( $p->ping("server") ) {
			$verbose and print "Server is up\n";
			$succes=0;
			last;
		} else {
			$verbose and print "Server is not up yet....\n";
			sleep 5;
		}
	}
	$p->close();

	my $i=0;
	while((connectTo("1.1.1.2","22")) && ($i<10) ) { sleep 6; $i++; $verbose and print "Trying to connect via SSH ($i/10)..\n"; };

        if ( $succes ) {
                print "Server isn't up and running. There has happened something. Please try the Reinstallation.\n";
		exit 1;
        } else {
                print "Server is up and running.\n";
		exit 0;
        }

}
