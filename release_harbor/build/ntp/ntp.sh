#!/usr/bin/env bash

cd $1/build/ntp

sudo dpkg --install ../../release/ntp/*.deb

cp ntp-server.conf /etc/ntp.conf

sudo /etc/init.d/ntp restart