#!/bin/bash

if [ "$(id -u)" -eq 0 ]
then
	service zramdrive stop
	systemctl disable zramdrive
	rm /etc/systemd/system/zramdrive.service
	rm /usr/local/bin/zramdrive/zramdrive
	rm /etc/zramdrive.conf


	echo "zramdrive is uninstalled, removing the uninstaller in progress"
	rm -rf /usr/local/bin/zramdrive
	echo "##### Reboot isn't needed #####"
else
	echo "You need to be ROOT (sudo can be used)"
fi
