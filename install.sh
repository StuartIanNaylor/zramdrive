#!/bin/bash

. ./zramdrive.conf

systemctl -q is-active zramdrive  && { echo "ERROR: zramdrive service is still running. Please run \"sudo service zramdrive stop\" to stop it and uninstall"; exit 1; }
[ "$(id -u)" -eq 0 ] || { echo "You need to be ROOT (sudo can be used)"; exit 1; }
[ -d /usr/local/bin/zramdrive ] && { echo "zramdrive is already installed, uninstall first"; exit 1; }

#apt-get install libattr1-dev -y already part of core
git clone -b fix_xattr_lib_include https://github.com/Izual750/overlayfs-tools
cd overlayfs-tools
make
cd ..

mkdir -p /usr/local/share/zramdrive/
# zramdrive install 
install -m 644 zramdrive.service /etc/systemd/system/zramdrive.service
install -m 755 zramdrive /usr/local/bin/zramdrive
install -m 644 zramdrive.conf /etc/zramdrive.conf
install -m 644 uninstall.sh /usr/local/share/zramdrive/uninstall.sh
mkdir -p /usr/local/lib/zramdrive/
install -m 755 overlayfs-tools/overlay /usr/local/lib/zramdrive/overlay
mkdir -p /usr/local/share/zramdrive/log
systemctl enable zramdrive

echo "#####          Reboot to activate zramdrive         #####"
echo "##### edit /etc/zramdrive.conf to configure options #####"
