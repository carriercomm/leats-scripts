#!/bin/bash

echo ""
echo "Restore server's basic state..."
echo "==============================="
echo ""

echo "Destroy server..."
if [ `virsh list | grep server | wc -l` -gt "0" ]; then
virsh destroy server
fi

echo "Umount LVs..."
if [ `mount | grep /dev/vg_desktop/server | wc -l` -gt "0" ]; then
umount /dev/vg_desktop/server
fi

if [ `mount | grep /dev/vg_desktop/server_snapshot | wc -l` -gt "0" ]; then
umount /dev/vg_desktop/server_snapshot 
fi

if [ `mount | grep /dev/mapper/vg_desktop-vdb | wc -l` -gt "0" ]; then
umount /dev/mapper/vg_desktop-vdb
fi

echo "LV vdb recreate..."
lvremove -f /dev/mapper/vg_desktop-vdb
lvcreate -L 300M -n vdb vg_desktop

echo "Restore server main LV..."
lvchange -an /dev/vg_desktop/server
lvchange -ay /dev/vg_desktop/server
lvconvert --merge /dev/vg_desktop/server_snapshot
lvcreate -pr --snapshot -L 2G --name server_snapshot /dev/vg_desktop/server

echo "Recreate /etc/libvirt/qemu/server.xml..."

cp -p /ALTS/SECURITY/server.xml /etc/libvirt/qemu/server.xml

echo "Restart libvirtd service..."
service libvirtd restart

echo "Starting server..."

if [ `virsh list | grep server | wc -l` -eq "0" ]; then
virsh start server
fi

i=1;
echo -en "Trying to connect via SSH"
while ! ssh root@1.1.1.2 1>/dev/null 2>&1 true
do
  ((i++))
  echo -en "."
  sleep 10

  if [ $i -eq "12" ]; then
	echo ""
	echo -e "\e[1;31mSSH Connection wasn't successful! Server reset failed!\e[0m"
	echo ""
	exit 1;
  fi

done

echo "SSH Connection was successful!"
echo ""
echo -e "\e[1;32mThe server machine has been reseted successfully!\e[0m"
echo ""
exit 0
