#!/usr/bin/env bash

cd $1/build/nfs
#apt-get -y install nfs-kernel-server #need to change
sudo dpkg --install ../../release/nfs-kernel/*.deb

if [ ! -d "/home/harbor" ]
then
	mkdir /home/harbor
fi

cp exports /etc

sudo service nfs-kernel-server restart