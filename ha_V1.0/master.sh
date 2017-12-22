#!/bin/bash
/usr/sbin/ucarp -i eth0 -v 40 -p gw22 -a 10.10.103.222 -u /etc/master-up.sh -d /etc/master-down.sh -s 10.10.103.141 -P -B
