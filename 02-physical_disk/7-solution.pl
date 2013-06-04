#!/usr/bin/perl

use strict;
use warnings;
use Sys::Virt;
use Term::ANSIColor;
use Net::OpenSSH;
use MIME::Base64;


my $Command="umount /dev/vdb1; e2fsck -f -y /dev/vdb1; resize2fs /dev/vdb1 40M; e2fsck -f -y /dev/vdb1; tune2fs -O extents,uninit_bg,dir_index,has_journal /dev/vdb1; e2fsck -f -y /dev/vdb1; echo '/dev/vdb1       /mnt/testdir                ext4    defaults 0 0' >> /etc/fstab; mount -av";

sub ssh_connect() {
        open my $stderr_fh, '>', '/dev/null';
        my $ssh = Net::OpenSSH->new("server", key_path=>"/ALTS/SECURITY/id_rsa", default_stderr_fh => $stderr_fh);
        $ssh->error and ( print "Couldn't establish SSH connection: ". $ssh->error);
        return $ssh;
}

       my $ssh=ssh_connect();
       my $output=$ssh->capture("$Command");
       print "output = $output";

