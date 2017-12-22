#!/usr/bin/env bash

#example:./1main-servers.sh /root/release_harbor

./ntp/ntp.sh $1

./nfs/nfs.sh $1