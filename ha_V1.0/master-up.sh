#!/bin/bash

/bin/sh /etc/harbor-up.sh
/sbin/ip addr add 10.10.103.222/24 dev eth0
sleep 10
nohup ./etc/healthCheck >/dev/null 2>&1 </dev/null &

