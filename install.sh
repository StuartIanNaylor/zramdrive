#!/bin/bash

. ./zramdrive.conf

systemctl -q is-active zramdrive  && { echo "ERROR: zramdrive service is still running. Please run \"sudo service zramdrive stop\" to stop it and uninstall"; exit 1; }
[ "$(id -u)" -eq 0 ] || { echo "You need to be ROOT (sudo can be used)"; exit 1; }
[ -d /usr/local/bin/zramdrive ] && { echo "zramdrive is already installed, uninstall first"; exit 1; }


# zramdrive install 
mkdir -p /usr/local/bin/zramdrive
install -m 644 zramdrive.service /etc/systemd/system/zramdrive.service
install -m 755 zramdrive /usr/local/bin/zramdrive/zramdrive
install -m 644 zramdrive.conf /etc/zramdrive.conf
install -m 644 uninstall.sh /usr/local/bin/zramdrive/uninstall.sh
systemctl enable zramdrive


# Make sure we start clean
rm -rf $HDD_DIR
mkdir -p $HDD_DIR

echo "#####          Reboot to activate zramdrive         #####"
echo "##### edit /etc/zramdrive.conf to configure options #####"


