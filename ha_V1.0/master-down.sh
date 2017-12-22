#!/bin/bash

/sbin/ip addr del 10.10.103.222/24 dev eth0

pid=`pgrep -l healthCheck| awk -F ' ' '{ print $1 }'`

kill -9 $pid

/bin/sh /etc/harbor-down.sh



