package Disk;
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
use Linux::LVM;
use XML::Simple;
use Data::Dumper;
use Switch;
BEGIN {
	use Exporter;
	use lib '/scripts/common_perl/';
	use Framework qw($verbose $topic $author $version $hint $problem $name);

    	@Disk::ISA         = qw(Exporter);
    	@Disk::EXPORT      = qw( &lvm_free &lv_count &base &lv_remove &lv_create &xml_parse &checkMount &checkFilesystemType &checkPartitionSize &checkPartitionSize &getFilerMountedFrom &getFilesystemParameter &checkFilesystemParameter &checkMountedWithUUID &checkMountedWithLABEL &fileEqual &checkMountOptions &getInfo &checkOwner &checkGroup &checkType &checkSymlink &Delete &getInfo &Copy &Move &checkSwapSize &checkVGExist &getVGData &checkVGData &checkLVExist &getLVData &checkLVData &CreatePartition &RecreateVDisk &Exist &CreateFile &CreateDirectory &checkPartitionMaxUsedSpace);
    	@Disk::EXPORT_OK   = qw( $verbose $topic $author $version $hint $problem $name);
	## We need to colse STDERR since Linux::LVM prints information to STDERR that is not relevant.
	close(STDERR);
}
use vars qw ($verbose $topic $author $version $hint $problem $name);

#
#Returns the free space on the given vg.
#
#1. Parameter: VG name (optional)
#
sub lvm_free(;$) {
	my $vgname = $_[0] || "vg_desktop";
	## How much free space is on local vg
	my %vg_server= get_volume_group_information("$vgname");
	my $pe_size=$vg_server{'pe_size'};
	my $pe_free=$vg_server{'free_pe'};
	my $sum=$pe_size*$pe_free;
	return $sum;
}

#
# Returns the logical volumes on the given local vg
#
# 1. Parameter: VG name (optional)
#
sub lv_count(;$) {
	my $vgname = $_[0] || "vg_desktop";
	my %lv=get_logical_volume_information("$vgname");
	$verbose and print "Our current lvs are on $vgname: ";
	my $count=0;
	foreach my $lvname (sort keys %lv) {
		$verbose and print "$lvname ";
		$count+=1;
	}
	$verbose and print "\n";
	$verbose and print "Count is:$count\n";
	return $count;
}

#
# Restore base setup for lvm setup on vg_desktop
#
sub base() {
	## Restore base setup for lvm setup on desktop
	$verbose and print "Base has been invoked.\n";
	print "Do you want me to restore base lvm number? [y/n] :";
	my $input = <STDIN>;
	chomp $input;
	outer: 
	while (1) { 
		if ( $input == "y" ) {
			$verbose and print "Yes selected. restoring default state.\n";
			my %lv=get_logical_volume_information("vg_desktop");
			foreach my $lvname (sort keys %lv) {
				if ( $lvname eq "LogVol00" or ($lvname eq "LogVol01" or ($lvname eq "server" or $lvname eq "web") ) ) {
					$verbose and print "This is a base lv. Leaving.\n";
				} else {
					print "\n$lvname is a non base lv. We should delete it.\n";
					print "Is $lvname unused on internal server and can be deleted? [y/n] ";
					my $confirm = <STDIN>;
					chomp $confirm;
					inner:
					while (1) {
						if ( $confirm eq "y" ) {
							$verbose and print "\nDeleting $lvname lv.\n";
							my $ret=&lv_remove("$lvname");
							if ( $ret eq 0) {
								print "$lvname was deleted succesfully.\n";
								last inner;
							} else {
								print "There was some problem deleting $lvname lv.\n";
								last inner;
							}
						} elsif ( $confirm eq "n" ) {
							print "\nNot doing anything as requested.\n";
							last inner;
						} else {
							print "\n $confirm incorrect. Please answer y or n : ";
						}
					}
				}
			}
		last outer;
		} elsif ( $input == "n" ) {
			$verbose and print "\nNot restoring.\n";
			last outer;
		} else {
			print "\n $input incorrect. Please answer y or n : ";
		}
	}
}


#
# Remove the logical volume
#
# 1. Parameter: LV name
# 2. Parameter: VG name (optional, default is vg_desktop)
#
sub lv_remove($;$) {
	## Removes lv
	my ($lvname)=$_[0];
	my $vgname =$_[1] || "vg_desktop";
	$lvname="/dev/mapper/$vgname-$lvname";
	if ( !-e $lvname ) {
		$verbose and print "There is no such lv.\n";
		return 0;
	}
	$verbose and print "Removing $lvname.\n";
	my $xml=&xml_parse;
	$verbose and print "I got information.\n";
	$verbose and print Dumper($xml->{devices}->{disk});
	if ( ref($xml->{devices}->{disk}) eq "ARRAY" ) {
		$verbose and print "Referencing array.\n";
		my $length= @{$xml->{devices}->{disk}};
        	$verbose and print "My length is:$length\n";
        	for ( my $i=0; $i < $length; $i++ ) {
			$verbose and print "working on: ";
			$verbose and print Dumper($xml->{devices}->{disk}->[$i]);
			if ( $lvname eq $xml->{devices}->{disk}->[$i]->{source}{dev} ) {
				$verbose and print "Found match.\n";
				my $target = $xml->{devices}->{disk}->[$i]->{target}{dev};
				$verbose and print "My target is:$target\n";
				my $ret=`virsh detach-disk server $target --persistent`;
				$verbose and print "$ret\n";
			}
        	}
	} elsif ( ref($xml->{devices}->{disk}) eq "HASH" ) {
		$verbose and print "Referencing hash.\n";
		if ( $lvname eq $xml->{devices}->{disk}->{source}{dev} ) {
			my $target = $xml->{devices}->{disk}->{target}{dev};
			$verbose and print "My target is:$target\n";
			my $ret=`virsh detach-disk server $target --persistent`;
			$verbose and print "$ret\n";
		}
	} else {
		$verbose and print "Unknown reference. Something has gone wrong.\n";
		exit 1;
	} 
	### After clearing the attachment, we can delete lv.
	my $return=`lvremove -t -f $lvname >/dev/null 2>\&1 ; echo \$?`;
	chomp $return;
	$verbose and print "My return for lvremove test is: $return\n";
	if ( $return eq 0 ) {
		$verbose and print "Lvremove test was succesful. Doing real remove.\n";
		my $ret=`lvremove -f $lvname >/dev/null 2>\&1 ; echo \$?`;
		chomp $ret;
		$verbose and print "My return for removal is: $ret\n";
		if ( $ret eq 0 ) {
			$verbose and print "Removal was succesful.\n";
			return 0;
		} else {
			$verbose and print "There were errors during removal.\n";
			return 1;
		}
	} else {
		$verbose and print "Lvremove not succesful. We should investigate why.\n";
		return 1;
	}
}

#
# Create logical volume
#
# 1. Parameter: Logical volume
# 2. Parameter: Size
# 3. Parameter: Target
# 4. Parameter: Volume Group name (optional, default is vg_desktop)
#
sub lv_create($$$;$) {
	## Create lv
	## Size should be accoring to PE size.
	my $lvname = $_[0];
	my $size = $_[1];
	my $target =$_[2];
	my $vgname = $_[3]||"vg_desktop";
	## Pre tests
	if ( -e "/dev/mapper/$vgname-$lvname" ) {
		$verbose and print "Already exists.\n";
		$verbose and print "Testing if attached.\n";
		my $count=`virsh dumpxml server | grep $target |wc -l`;
		chomp $count;
		if ( $count eq 0 ) {  
			my $ret=`/usr/bin/virsh attach-disk server /dev/mapper/$vgname-$lvname $target --persistent >/dev/null 2>\&1;echo \$?`;
			chomp $ret;
			$verbose and print "Attach return value is: $ret\n";
			if ( $ret eq 0 ) {
				$verbose and print "Succesful attached disk to server.\n";
				return 0;
			} else {
				$verbose and print "There was an error attaching disk to server.\n";
				return 1;
			}
		} else {
			$verbose and print "Mounted on target already.\n";
		}

	}
	my $free= &lvm_free($vgname);
	$verbose and print "Free space on $vgname: $free\n";
	$verbose and print "Size of $lvname: $size\n";
	if ( $free < $size ) {
		$verbose and print "I dont have enough free space. We should free up some space.\n";
		return 1;
	} else {
		$verbose and print "We have enough space.\n";
	}
	my %vg_server= get_volume_group_information("$vgname");
	my $unit=$vg_server{pe_size_unit};
	$verbose and print "My PE size unit:$unit\n";
	#system("/sbin/lvcreate","-n $lvname","-L $size$unit","vg_desktop");
	my $return=`/sbin/lvcreate -n $lvname -L $size$unit $vgname >/dev/null 2>\&1; echo \$?`;
	chomp $return;
	$verbose and print "Lvcreation ret value:$return\n";
	if ( $return ne 0 ) {
		$verbose and print "There was an error creating the lv\n";
		return 1;
	}
	my %lv=get_logical_volume_information("$vgname");
        foreach my $lvs (sort keys %lv) {
		if ( $lvname eq $lvs ) {
			$verbose and print "Lv was created succesfully\n";
			$verbose and print "Attaching to guest.\n";
			my $ret=`/usr/bin/virsh attach-disk server /dev/mapper/$vgname-$lvname $target --persistent >/dev/null 2>\&1;echo \$?`;
			chomp $ret;
			$verbose and print "Attach return value is: $ret\n";
			if ( $ret eq 0 ) {
				$verbose and print "Succesful attached disk to server.\n";
				return 0;
			} else {
				$verbose and print "There was an error attaching disk to server.\n";
				return 1;
			}
		} 
	}
	return 1;
}



#
#
##
#
sub xml_parse() {
	## Lets parse our server xml
	my $info=`virsh dumpxml server`;
	my $xml= new XML::Simple;
	my $data=$xml->XMLin( $info );
	#print Dumper($data->{devices}->{disk});
	#print "$#{$data->{devices}->{disk}}\n";
	return $data;
}


#
# Check if file/directory exist
#
# 1.Parameter: Path
# 2. Parameter: Type  f=file, d=directory, e=both
#
# E.g.: Exist(/tmp,"d");
#
#
sub Exist($;$)
{
my $File = $_[0];
my $Option =$_[1] || "e";

	my $ssh=Framework::ssh_connect;
	my $output=$ssh->capture("test -$Option $File; echo \$?");
	chomp($output);
	return $output;
}

#
#
# Creates a files with the given attributes and content
#
# 1. Parameter: Filename (with full path)
# 2. Parameter: Owner (default root)
# 3. Parameter: Owner group (default root)
# 4. Parameter: Permissions
# 5. Parameter: content
#
sub CreateFile($$$$$)
{
	my $FileName = $_[0];
	my $Owner = $_[1] || "root";
	my $Group = $_[2] || "root";
	my $Permissions = $_[3] || "744";
	my $Content =$_[4] || "";

        my $ssh=Framework::ssh_connect;
        my $output=$ssh->capture("echo \"$Content\" > $FileName; chown $Owner $FileName; chgrp $Group $FileName; chmod $Permissions $FileName");
        chomp($output);
	$verbose and print "Creating file: echo \"$Content\" > $FileName; chown $Owner $FileName; chgrp $Group $FileName; chmod $Permissions $FileName\n";
	$verbose and print "output: $output \n";

	if (Exist($FileName,"f") == 0) {$verbose and print "$FileName has been created\n"; return 0;}
	else { $verbose and print "$FileName hasn't been created\n"; return 1; }
}


#
# Creates a directory with the given attributes and content
#
# 1. Parameter: Directory name (with full path)
# 2. Parameter: Owner (default root)
# 3. Parameter: Owner group (default root)
# 4. Parameter: Permissions
#

sub CreateDirectory($$$$)
{

        my $DirectoryName = $_[0];
        my $Owner = $_[1] || "root";
        my $Group = $_[2] || "root";
        my $Permissions = $_[3] || "744";

        my $ssh=Framework::ssh_connect;
        my $output=$ssh->capture("mkdir -p $DirectoryName; chown $Owner $DirectoryName; chgrp $Group $DirectoryName; chmod $Permissions $DirectoryName");
        chomp($output);
        $verbose and print "Creating directory: mkdir DirectoryName; chown $Owner $DirectoryName; chgrp $Group $DirectoryName; chmod $Permissions $DirectoryName\n";
        $verbose and print "output: $output \n";

        if (Exist($DirectoryName,"d")==0) {$verbose and print "$DirectoryName has been created\n"; return 0;}
        else { $verbose and print "$DirectoryName hasn't been created\n"; return 1; }

}



#
#
# Checks if VG exist
#
# 1.Parameter: Volume Groups name
#
#
sub checkVGExist($)
{
my $VGName=$_[0];

        my $ssh=Framework::ssh_connect;
        my $output=$ssh->capture("vgdisplay $VGName >/dev/null 2>\&1;echo \$?");
	chomp($output);

	if ($output eq 0) {return 0;}
	else {return 1;}
}

#
# Checks if LV exist
#
# 1. Parameter: Volume Groups name
# 2. Parameter: Logical Volume name
#
sub checkLVExist($$)
{
my $VGName=$_[0];
my $LVName=$_[1];

        my $ssh=Framework::ssh_connect;
        my $output=$ssh->capture("lvdisplay /dev/$VGName/$LVName >/dev/null 2>\&1;echo \$?");
        chomp($output);

        if ($output eq 0) {return 0;}
        else {return 1;}
}



#
# Returns VGs Value
#
# 
# 1. Parameter:   Volume Group name
# 2. Parameter:   Parameter you want to check
# 	VGSize:		size of volume group in MBytes
# 	PESize: 	physical extent size in MBytes
# 	PEFree: 	free number of physical extents for this volume group
# 	FreeSpace:	Free Space in MBytes
#
sub getVGData($$)
{
	my $VGName=$_[0];
	my $Parameter=$_[1];

	if (checkVGExist($VGName)!=0) { return ""; }

        my $ssh=Framework::ssh_connect;
        my $output=$ssh->capture("vgdisplay -c $VGName");

	my @A=split(":","$output");

	#     0  volume group name
	#     1  volume group access
	#     2  volume group status
	#     3  internal volume group number
	#     4  maximum number of logical volumes
	#     5  current number of logical volumes
	#     6  open count of all logical volumes in this volume group
	#     7  maximum logical volume size
	#     8  maximum number of physical volumes
	#     9  current number of physical volumes
	#     10 actual number of physical volumes
	#     11 size of volume group in kilobytes
	#     12 physical extent size
	#     13 total number of physical extents for this volume group
	#     14 allocated number of physical extents for this volume group
	#     15 free number of physical extents for this volume group
	#     16 uuid of volume group

	switch ($Parameter)
	{
		case "VGSize" { return $A[11]/1024; }
		case "PESize" { return $A[12]/1024; }
		case "PEFree" { return $A[15]; }
		case "FreeSpace" { return $A[15]*($A[12]/1024) }
	}


}

#
# Returns LVs Value
#
#
# 1. Parameter:   Volume Group name
# 2. Parameter:	  Logical Volume name
# 3. Parameter:   Parameter you want to check
#       LVSize:         size of volume group in MBytes
#       LVPESize:	size of volume group in PEs
sub getLVData($$$)
{

        my $VGName=$_[0];
	my $LVName=$_[1];
        my $Parameter=$_[2];

	if (checkLVExist($VGName,$LVName)!=0) { return ""; }

        my $ssh=Framework::ssh_connect;
        my $output=$ssh->capture("lvdisplay -c /dev/$VGName/$LVName");

	my @A=split(":","$output");

# 	0: logical volume name
# 	1: volume group name
# 	2: logical volume access
# 	3: logical volume status
# 	4: internal logical volume number
# 	5: open count of logical volume
# 	6: logical volume size in kilobytes
# 	7: current logical extents associated to logical volume
# 	8: allocated logical extents of logical volume
#	9: allocation policy of logical volume
# 	10: read ahead sectors of logical volume
# 	11: major device number of logical volume
# 	12: minor device number of logical volume

        switch ($Parameter)
        {
		case "LVSize" { return $A[7]*getVGData("$VGName","PESize"); }
		case "LVPESize" { return $A[7]; }
	}	

}


#
#
# Checks VGData
#
# 1. Parameter:   Volume Group name
# 2. Parameter:   Parameter you want to check
# 3. Parameter:   Value of the Parameter
# 4. Parameter:   Margin (optinal)
# 	
#
sub checkVGData($$$;$)
{
	my $VGName=$_[0];
	my $Parameter=$_[1];
	my $Value=$_[2];
	my $Margin=$_[3] || 0;
	$Margin*=0.01;

	if (checkVGExist($VGName)!=0) { return 1; }	

	if ($Parameter eq "VGSize")
	{
		my $VGSize=getVGData($VGName,$Parameter);
		if ($VGSize >= (((1-$Margin)*$Value))&&($VGSize <= ((1+$Margin)*$Value))) { return 0; }
                else { return 1;}
	}
	else
	{
	if ((getVGData($VGName,$Parameter) eq "$Value")) { return 0; }
	else { return 1; }
	}

}


#
# Checks LVData
#
# 1. Parameter:   Volume Group name
# 2. Parameter:   Logical Volume name
# 2. Parameter:   Parameter you want to check
# 3. Parameter:   Value of the Parameter
# 4. Parameter:   Margin (optional)
#
sub checkLVData($$$$;$)
{
        my $VGName=$_[0];
	my $LVName=$_[1];
        my $Parameter=$_[2];
        my $Value=$_[3];
        my $Margin=$_[4] || 0;
        $Margin*=0.01;


	if (checkLVExist($VGName,$LVName)!=0) { return 1; }

	if ($Parameter eq "LVSize")
	{
		my $LVSize=getLVData($VGName,$LVName,$Parameter);
		if ($LVSize >= (((1-$Margin)*$Value))&&($LVSize <= ((1+$Margin)*$Value))) { return 0; }
	        else { return 1;}
	}
	else
	{
        	if ((getLVData($VGName,$LVName,$Parameter) eq "$Value")) { return 0; }	
        	else { return 1; }
	}
}


#
# Returns the filer of the given qtree
#
# Parameter 1: The mountpoint e.g. /mnt/test
#
sub getFilerMountedFrom($)
{
	my $mount_to=$_[0];

	my $ssh=Framework::ssh_connect;
	my $output=$ssh->capture("df -P -B M $mount_to | tail -1");
	my @A = $output =~ m/(\S+)\s+\d+M\s+\d+M\s+\d+M\s+\S+\s+\S+/;

	my $mounted_from = $A[0];

	return $mounted_from;
}

#
# Extends the input Path with a / (if there is already one, then it will stay)
# It is necessary because e.g. /tmp and /tmp/ means the same in the operation system, but are not equal as strings
#
#
sub extendWithSlash($)
{
	if (not defined ${_[0]}) { return ""; }
	my $A = "${_[0]}/";    
	$A =~ s/\/\//\//g;
	return $A;
}

#
#  Checks if mount successful
#	
#  1. Parameter: Mount source e.g. if you write vdb, then it will be accepted /dev/vdb and /home/anymody/avdba too.
#  2. Parameter: Mount destination
#
sub checkMount($$)
{
	my $mount_from = $_[0];
	my $mount_to = extendWithSlash($_[1]);

	my $ssh=Framework::ssh_connect;
	my $output=$ssh->capture("df -P -B M $mount_to | tail -1");
	my @A = $output =~ m/(\S+)\s+\d+M\s+\d+M\s+\d+M\s+\S+\s+(\S+)/;

	my $mounted_from = extendWithSlash($A[0]);
	my $mounted_to = extendWithSlash($A[1]);

	if (($mounted_from =~ m/$mount_from/) && ($mounted_to eq $mount_to)) { return 0; }
	else { return 1; }
}

#
#
# Checks the filesystems type
#
# 1. Parameter: partition
# 2. Paramterer: filesystems type (e.g. ext3)
#
sub checkFilesystemType($$)
{
	my $partition = $_[0];
	my $type = $_[1];

	if (not defined $partition) { return 1;}

	my $ssh=Framework::ssh_connect;
	my $output=$ssh->capture("df -T -P $partition | tail -1");
	my @A = $output =~ m/\S+\s+(\S+).*/;

	if ($A[0] eq $type) { return 0; }
	else { return 1; }
}


#
# Checks if partitions size is between 90% and 110% of the wanted size 
#
# 1. Parameter: partition
# 2. Parameter: wanted size in MB
# 3. Parameter: margin in % (optional, defualt is 10)
#
# e.g. checkPartitionSize("/mnt/test","150","10")
#
sub checkPartitionSize($$;$)
{
	my $partition = $_[0];
	my $wanted_size = $_[1];
	my $margin = $_[2]*0.01 || 0.1;

	if (not defined $partition) { return 1;}

	my $ssh=Framework::ssh_connect;
	my $output=$ssh->capture("df -P -B M $partition | tail -1");
	my @A = $output =~ m/\S+\s+(\d+)M\s+\d+M\s+\d+M\s+\S+\s+\S+/;

	if ($A[0] >= (((1-$margin)*$wanted_size))&&($A[0] <= ((1+$margin)*$wanted_size))) { return 0; }
	else { return 1;}
}

#
# Returns the filesystems parameter
#
# 1. Parameter: Filesystems name
# 2. Parameter: wished parameter 
# 		it can be: UUID, LABEL
#
#	e.g. getFilesystemParameter("/mnt/test","UUID");
#
sub getFilesystemParameter($$)
{
	my $partition = $_[0];
	my $parameter = uc($_[1]);

	if (not defined $partition) { return 1;}

	my $ssh=Framework::ssh_connect;
	my $output=$ssh->capture("tune2fs -l $partition");

	switch($parameter) {
		case "UUID"  { my @A = $output =~ m/Filesystem UUID:\s+(\S+)/; return $A[0]; }
		case "LABEL" { my @A = $output =~ m/Filesystem volume name:\s+(\S+)/; return $A[0]; }
	}
}

#
# Checks the filesystem parameter
#
# 1. Parameter: Filesystems name
# 2. Parameter: wished parameter
#               it can be: UUID, LABEL
## 3. Parameter: value of the parameter
#
# e.g checkFilesystemParameter("/mnt/test","LABEL","test1-label")
#
sub checkFilesystemParameter($$$)
{
	my $partition = $_[0];
	my $parameter = uc($_[1]);
	my $value = $_[2];

	switch($parameter) {
		case "UUID"  { if ( getFilesystemParameter($partition,$parameter) eq $value) { return 0;} }
		case "LABEL" { if ( getFilesystemParameter($partition,$parameter) eq $value) { return 0;} }
	}

	return 1;

}

#
# Checks if mounted with UUID
#
# 1.Parameter: Mountpoint
#
#	e.g. checkMountedWithUUID("/mnt/test")
#
sub checkMountedWithUUID($)
{
	my $mounted_to=$_[0];

	if (Exist($mounted_to,"d") ne "0") { return 1;}

	my $ssh=Framework::ssh_connect;
	my $output=$ssh->capture("cat /etc/fstab");

	my $UUID=getFilesystemParameter(getFilerMountedFrom($mounted_to),"UUID");
	my @A = $output =~ m/UUID=['"]?(\S+)['"]?\s+$mounted_to.*/;

	if ($A[0] eq $UUID) { return 0; }
	else { return 1; }
}

#
## Checks if mounted with Label
##
## 1.Parameter: Mountpoint
##
##       e.g. checkMountedWithLABEL("/mnt/test")
##
sub checkMountedWithLABEL($)
{

	my $mounted_to=$_[0];

	if (Exist($mounted_to,"d") ne "0") { return 1;}

	my $ssh=Framework::ssh_connect;
	my $output=$ssh->capture("cat /etc/fstab");

	my $LABEL=getFilesystemParameter(getFilerMountedFrom($mounted_to),"LABEL");
	my @A = $output =~ m/LABEL=['"]?(\S+)['"]?\s+$mounted_to.*/;

	if ($A[0] eq $LABEL) { return 0; }
	else { return 1; }
}

#
# Check mounted Options
#
# 1. Parameter: Mountpoint, where filesystem mounted to
# 2. Parameter: Mount options separated with
#
# 		E.g. checkMountOption("/mnt/test","rw,acl");
#

sub checkMountOptions($$)
{
	my $mounted_to=$_[0];


	if (Exist($mounted_to,"d") ne 0) { return 1;}

	my $options_list=$_[1]; $options_list=~s/\s+//g; #remove whitespaces
	my @options = split(/,/,$options_list); # move them into an array

	my $ssh=Framework::ssh_connect;
	my $output=$ssh->capture("cat /proc/mounts");

	my @MO = $output =~ m/\S+\s+$mounted_to\s+\S+\s+(\S+).*/g;
	if ( $#MO == -1 ) { return 1; }

	my @MOptions=split(/,/,$MO[$#MO]);

	foreach my $o (@options)
	{
		if (!(grep(/^$o$/,@MOptions))) { return 1; }
	}

	return 0;
}

#
# Compares 2 files
# Parameter 1: File1 with fullpath
# Parameter 2: File2 with fullpath
#
#       E.g. fileEqual("/etc/passwd","/etc/passwd.old")
#
sub fileEqual($$)
{
	my $File1 = $_[0];
	my $File2 = $_[1];

	my $ssh=Framework::ssh_connect;
	my $output=$ssh->capture("md5sum $File1");
	my @A = $output =~ m/(\S+).*/;

	$ssh=Framework::ssh_connect;
	$output=$ssh->capture("md5sum $File2");
	my @B = $output =~ m/(\S+).*/;

	if ($A[0] eq $B[0]) { return 0; }
	else { return 1; }
}

#
#
# Get information about file or directory
# 
# Parameter 1: File or Directory
# Parameter 2: Info you require (OWNER, GROUP)
#
#	e.g. getINFO("/etc/passwd","OWNER")
#
sub getInfo($$)
{
	my $File=$_[0];
	my $parameter=uc($_[1]);

	my $ssh=Framework::ssh_connect;
	my $output;
	switch($parameter) {
		case "OWNER"  { 
			$output=$ssh->capture("stat -c %U $File"); chomp($output);	
		}
		case "GROUP"  {   
			$output=$ssh->capture("stat -c %G $File"); chomp($output);
		}
		case "TYPE"  {
			$output=$ssh->capture("stat -c %F $File"); chomp($output);
		}		

	}

	return $output;
}

#
#
# Checks the owner of the given file or directory
#
# 1. Parameter: File or directory 
# 2. Parameter: Owner
#
sub checkOwner($$)
{
	my $File=$_[0];
	my $Owner=$_[1];

	if ($Owner eq getInfo("$File","OWNER")) { return 0; }
	else {return 1; }
}

#
#
# Checks the owner of the given file or directory
#
# 1. Parameter: File or directory
# 2. Parameter: Owner
#
#
sub checkGroup($$)
{
	my $File=$_[0];
	my $Group=$_[1];

	if ($Group eq getInfo("$File","GROUP")) { return 0; }
	else {return 1; }

}


#
# Checks the type
#
# 1. Parameter: File, directory or symlink
# 2. Parameter: regular file/directory/symbolic link
#
sub checkType($$)
{
	my $File=$_[0];
	my $Type=$_[1];

	if ($Type eq getInfo("$File","TYPE")) { return 0; }
	else {return 1; }

}

#
# Checks symlink
#
# 1. Parameter: Source
# 2. Parameter: Symlinks path
#
#  
sub checkSymlink($$)
{
	my $File=$_[0];
	my $Symlink=$_[1];

	if ((checkType($Symlink,"symbolic link")==0) && (fileEqual($File,$Symlink)==0)) { return 0; }
	else { return 1; }

}

#
# Remove File or Directory
# 
# 1. Target you want to delete
#
sub Delete($;$$$$$$$$)
{
	my $output;
	my @T = @_; # move them into an array
		foreach my $t (@T)
		{
			my $ssh=Framework::ssh_connect;
			my $output1=$ssh->capture("rm -rf $t 1>/dev/null 2>&1;echo \$?");
			chomp($output1);
			$output+=$output1;
		}
	if ($output eq "0") {$verbose and print ("Remove was successful\n"); }
	else {$verbose and print ("Remove wasn't successful\n"); }
	
	return $output;
}

#
#
# Move/rename
#
# 1. Parameter: What you want to move
# 2: Peremeter: where you want to move is
#
sub Move($$)
{
	my $FROM=$_[0];
	my $TO=$_[1];

	if (Exist($FROM)!=0) { $verbose and print ("Move: $FROM not exist\n"); return 1; }
	
	my $ssh=Framework::ssh_connect;
	my $output=$ssh->capture("mv $FROM $TO 1>/dev/null 2>&1; echo \$?");
	chomp($output);

        if ($output eq "0") {$verbose and print ("Move ($FROM->$TO) was successful\n"); }
        else {$verbose and print ("Move ($FROM->$TO) wasn't successful\n"); }

	return $output;
}

#
#
# Copy
#
# 1. Parameter: What you want to copy
# 2: Peremeter: where you want to copy it
#  
#
sub Copy($$)
{
	my $FROM=$_[0];
	my $TO=$_[1];

	my $ssh=Framework::ssh_connect;
	my $output=$ssh->capture("cp -pr $FROM $TO 1>/dev/null 2>&1; echo \$?");
	chomp($output);

        if ($output eq "0") {$verbose and print ("Copy ($FROM->$TO) was successful\n"); }
        else {$verbose and print ("Copy ($FROM->$TO) wasn't successful\n"); }

	return $output;
}


#
#
# Checks Swap Size
#
# 1. Parameter: Swap size should be
# 2. Parameter: margin in % (optional, default is 10)
#
#

#my $margin = $_[2]*0.01 || 0.1;
#
#        my $ssh=Framework::ssh_connect;
#        my $output=$ssh->capture("df -P -B M $partition | tail -1");
#        my @A = $output =~ m/\S+\s+(\d+)M\s+\d+M\s+\d+M\s+\S+\s+\S+/;
#
#        if ($A[0] >= (((1-$margin)*$wanted_size))&&($A[0] <= ((1+$margin)*$wanted_size))) { return 0; }
#        else { return 1;}
#

sub checkSwapSize($;$)
{
	my $wanted_size = $_[0];
	my $margin = $_[1]*0.01 || 0.1;

	my $ssh=Framework::ssh_connect;	
	my $output=$ssh->capture("free -m");

	my @A = $output =~ m/Swap:\s+(\S+)\s+/;

	if ($A[0] >= (((1-$margin)*$wanted_size))&&($A[0] <= ((1+$margin)*$wanted_size))) { return 0; }
	else { return 1; }
}

#
# Create Partitions
#
# 1. Parameter: Disk name inside the "server" virtual machine (e.g. /dev/vdb)
# 2. Parameter: Partition number
# 3. Parameter: Partition size (e.g. +40M)
# 4. Parameter: Partition Type (swap/linux/lvm)
#
sub CreatePartition($$$$)
{

	my $Disk=$_[0];
	my $P=$_[1];
	my $PS=$_[2];
	my $PT=lc($_[3]);

	my %Type=("lvm","8e","8e","8e","ext3","83","linux","83","83","83","swap","82","82","82");

	$verbose && print "\nAdd new partition to $Disk: \n\n";
	$verbose && print "Partition number: $P\n";
	$verbose && print "Partition size: $PS\n\n";
	$verbose && print "Partition type: $Type{$PT}\n";

	my $ssh=Framework::ssh_connect;
	my $output=$ssh->capture("fdisk -l | grep '$Disk\[1234]' | wc -l");	
	chomp($output);

	$verbose && print "output (number of partitions) = \n$output\n\n";


	if ($output ne "0")  {  
		$output=$ssh->capture("(echo n; echo p; echo $P; echo \"\"; echo $PS; echo t; echo $P; echo $Type{$PT}; echo w) | fdisk $Disk; partx -va $Disk");
	}
	else 
	{
		$output=$ssh->capture("(echo n; echo p; echo $P; echo \"\"; echo $PS; echo t; echo $Type{$PT}; echo w) | fdisk $Disk; partx -va $Disk");
	}
	$verbose && print "Output=\n$output\n\n";


	return 0;
}

#
#
# Delete and recreate the virtual disk inside the server virtual machine
#
# 1. Parameter: Target inside the "server" virtual machine (e.g. vdb)
# 2. Parameter: size of the disk in MB
# 3. Parameter: LV name 
# 4. Parameter: VG name (optional, default is vg_desktop)
#
# E.g. RecreateVDisk("vdb","300","vdb");
#
sub RecreateVDisk($$$;$)
{
my $Target=$_[0];
my $Size=$_[1];
my $LVName=$_[2];
my $VGName =$_[3] || "vg_desktop";

                $verbose and print "Removing /dev/mapper/$VGName-$LVName\n";
		system("lvremove -f /dev/mapper/$VGName-$LVName");
		$verbose and print "Creating $LVName\n";
                lv_create("$LVName","$Size","$Target","$VGName");
                print "Disk attached to server. Local disk is vdb\n";

}

#
# Check free disk space on the given partition (mountpoint)
#
# 1. Parameter: Mountpoint E.g. /mnt/data
# 2. Parameter: Maximal Used in % E.g. 90 (default is 90%)
#
sub checkPartitionMaxUsedSpace($;$)
{
my $Mountpoint=$_[0];
my $MaxUsed=$_[1] || "90";

#print "MOUNTPOINT: $Mountpoint || MAXUSED: $MaxUsed\n";

my $ssh=Framework::ssh_connect;
my $output=$ssh->capture("df $Mountpoint | tail -1");

my @A = $output =~ m/.*\s+(\d+)%.*/;

if ((defined $A[0]) and ($A[0]<$MaxUsed)) { return 0; }

return 1;

}

#### We need to end with success
1
