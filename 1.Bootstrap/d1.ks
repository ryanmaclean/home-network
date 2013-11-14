#version=DEVEL
#
# d1 Kickstart
# Craig J Perry, 8th November 2013
#
# This is a minimal install, package selection is handled
# post-reboot by ansible config management. This ks file
# defines:
#  a) disk layout, 2x 500Gb sliced up as:
#    1) /boot, 256M RAID1 ext4
#    2) pv.11, 200Gb RAID1 LVM PV (/, /var, /home etc.)
#    3) pv.20, Remainder RAID0 LVM PV (/scratch)
#  b) Hostname (with F19 bug workaround, see %post)
#  c) Root account with default password (changed on first reboot)
#

cdrom

lang en_GB.UTF-8
keyboard --vckeymap=uk --xlayouts='gb'
timezone Europe/London --isUtc

zerombr
clearpart --all --initlabel --drives=sda,sdb
ignoredisk --only-use=sda,sdb
# BUG: Only installs on sda
bootloader --location=mbr --driveorder=sda,sdb

# /boot
part raid.01 --ondisk=sda --maxsize=256 --size=256 --asprimary --fstype="mdmember"
part raid.02 --ondisk=sdb --maxsize=256 --size=256 --asprimary --fstype="mdmember"
raid /boot --fstype=ext4 --level=1 --device=0 raid.01 raid.02

# RAID 1 vgroot
part raid.11 --ondisk=sda --size=200000 --asprimary --fstype="mdmember"
part raid.12 --ondisk=sdb --size=200000 --asprimary --fstype="mdmember"
raid pv.11 --fstype="lvmpv" --level=1 --device=1 raid.11 raid.12
volgroup d1-vgroot --pesize=4096 pv.11

# RAID 0 vgfast
part raid.21 --ondisk=sda --size=1 --grow --asprimary --fstype="mdmember"
part raid.22 --ondisk=sdb --size=1 --grow --asprimary --fstype="mdmember"
raid pv.20 --fstype="lvmpv" --level=0 --device=2 raid.21 raid.22
volgroup d1-vgfast --pesize=4096 pv.20

# LVs
logvol swap  --fstype="swap" --size=4000 --name=swap --vgname=d1-vgroot
logvol /  --fstype="ext4" --size=15000 --label="d1-vgroot-lvroot" --name=root --vgname=d1-vgroot
logvol /var  --fstype="ext4" --size=10000 --label="d1-vgroot-lvvar" --name=var --vgname=d1-vgroot
logvol /home  --fstype="ext4" --size=30000 --label="d1-vgroot-lvhome" --name=home --vgname=d1-vgroot
logvol /scratch --fstype="ext4" --size=30000 --label="d1-vgfast-lvsrv" --name=srv --vgname=d1-vgfast

# Users
auth --enableshadow --passalgo=sha512
rootpw --iscrypted $6$JSdgnAXgP16EA7MR$HQ4isREWMEgyKP3can3iaTr678f4HPgAhp3eUp7SAYBzSPevGyooLpQ0LapodSvXU27kvOJZA6Xt9M66//x5X/

# Network information
# BUG: Fedora 19 https://bugzilla.redhat.com/show_bug.cgi?id=981934
#      manual workaround in %post below
network  --bootproto=dhcp --device=eth0 --activate --hostname=d1.local --activate

xconfig  --startxonboot

# No packages specified here, we want a minimal install, ansible
# will handle installing the appropriate packages later
%packages
%end

# There are a couple of required packages to let ansible function
# however depending on the install media used, they may only be
# available over the network, easiest to grab during post install
%post
echo "d1.local" > /etc/hostname
echo "HOSTNAME=\"d1.local\"" > /etc/sysconfig/network
yum -y update
yum -y install git ansible
useradd -c "Ansible Config Management" -G wheel -m -r -U ansible
echo "Defaults: ansible !requiretty" > /etc/sudoers.d/ansible
echo "ansible ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers.d/ansible
cat - > /tmp/ansible.cron <<CAT
#Ansible: ansible-pull site.yml
@hourly ansible-pull -U https://github.com/CraigJPerry/home-network -d home-network -i 2.Config/hosts 2.Config/site.yml > /tmp/ansible-pull.$LOGNAME.crontab 2>&1
CAT
crontab -u ansible /tmp/ansible.cron
%end

reboot --eject

