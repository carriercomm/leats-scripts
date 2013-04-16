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
echo "<!--
WARNING: THIS IS AN AUTO-GENERATED FILE. CHANGES TO IT ARE LIKELY TO BE
OVERWRITTEN AND LOST. Changes to this xml configuration should be made using:
  virsh edit server
or other application using the libvirt API.
-->

<domain type='kvm'>
  <name>server</name>
  <uuid>c23dec02-2ffb-4c08-015c-3d6bf571ee36</uuid>
  <description>Troubleshooting server </description>
  <memory unit='KiB'>524288</memory>
  <currentMemory unit='KiB'>524288</currentMemory>
  <vcpu placement='static'>1</vcpu>
  <os>
    <type arch='x86_64' machine='rhel6.3.0'>hvm</type>
    <boot dev='hd'/>
  </os>
  <features>
    <acpi/>
    <apic/>
    <pae/>
  </features>
  <clock offset='utc'/>
  <on_poweroff>destroy</on_poweroff>
  <on_reboot>restart</on_reboot>
  <on_crash>restart</on_crash>
  <devices>
    <emulator>/usr/libexec/qemu-kvm</emulator>
    <disk type='block' device='disk'>
      <driver name='qemu' type='raw' cache='none' io='native'/>
      <source dev='/dev/mapper/vg_desktop-server'/>
      <target dev='vda' bus='virtio'/>
      <address type='pci' domain='0x0000' bus='0x00' slot='0x05' function='0x0'/>
    </disk>
    <disk type='block' device='disk'>
      <driver name='qemu' type='raw'/>
      <source dev='/dev/mapper/vg_desktop-vdb'/>
      <target dev='vdb' bus='virtio'/>
      <address type='pci' domain='0x0000' bus='0x00' slot='0x07' function='0x0'/>
    </disk>
    <controller type='usb' index='0'>
      <address type='pci' domain='0x0000' bus='0x00' slot='0x01' function='0x2'/>
    </controller>
    <interface type='bridge'>
      <mac address='52:54:00:c1:5c:be'/>
      <source bridge='br0'/>
      <model type='e1000'/>
      <address type='pci' domain='0x0000' bus='0x00' slot='0x03' function='0x0'/>
    </interface>
    <interface type='bridge'>
      <mac address='52:54:00:1e:bd:71'/>
      <source bridge='br0'/>
      <model type='e1000'/>
      <address type='pci' domain='0x0000' bus='0x00' slot='0x04' function='0x0'/>
    </interface>
    <serial type='pty'>
      <target port='0'/>
    </serial>
    <console type='pty'>
      <target type='serial' port='0'/>
    </console>
    <input type='tablet' bus='usb'/>
    <input type='mouse' bus='ps2'/>
    <graphics type='vnc' port='9999' autoport='no' listen='1.1.1.1'>
      <listen type='address' address='1.1.1.1'/>
    </graphics>
    <video>
      <model type='cirrus' vram='9216' heads='1'/>
      <address type='pci' domain='0x0000' bus='0x00' slot='0x02' function='0x0'/>
    </video>
    <memballoon model='virtio'>
      <address type='pci' domain='0x0000' bus='0x00' slot='0x06' function='0x0'/>
    </memballoon>
  </devices>
</domain>" > /etc/libvirt/qemu/server.xml

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
