#!/usr/bin/env bash

#./ucarp.sh /root/ha/docker-harbor-cluster/release_harbor/build/harbor 40 love 10.10.103.222 10.10.103.141 eth0
# $1 path $2 ucarp id (1~255) $3 ucarp password $4 VIP $5 ip  $6 eth0

cd $1/build/ucarp
#apt-get -y install ucarp #need to change
sudo dpkg --install ../../release/ucarp/*.deb

if [ ! -d "/etc/uuarp" ]
then
	mkdir /etc/uuarp
fi

healcheckP="/etc/uuarp/healthCheck"

cp healthCheck $healcheckP
chmod +x $healcheckP

harbor_down="#!/bin/bash \ncd $1/build/harbor \ndocker-compose stop"
#harbor_down="#!/bin/bash \ncd $1/build/harbor \nkill -9 \`pgrep -l harbor_gc| awk -F ' ' '{ print \$1 }'\` \ndocker-compose stop"
harbor_downP="/etc/uuarp/harbor-down.sh"
echo -e $harbor_down > $harbor_downP
chmod +x $harbor_downP

#harbor_up="#!/bin/bash \ncd $1/build/harbor \ndocker-compose start \nsleep 0.5 \ndocker-compose start \nnohup ./harbor_gc >/dev/null 2>&1 </dev/null &"
harbor_up="#!/bin/bash \ncd $1/build/harbor \ndocker-compose start \nsleep 0.5 \ndocker-compose start \n"
harbor_upP="/etc/uuarp/harbor-up.sh"
echo -e $harbor_up > $harbor_upP
chmod +x $harbor_upP

master_down="#!/bin/bash\n/sbin/ip addr del $4/24 dev $6\nsh $harbor_downP"
master_downP="/etc/uuarp/master-down.sh"
echo -e $master_down > $master_downP
chmod +x $master_downP

mater_up="#!/bin/bash\n/bin/sh $harbor_upP\n/sbin/ip addr add $4/24 dev $6\nsleep 60\nnohup .$healcheckP >/dev/null 2>&1 </dev/null &"
master_upP="/etc/uuarp/master-up.sh"
echo -e $mater_up > $master_upP
chmod +x $master_upP

master="#!/bin/bash \n/usr/sbin/ucarp -i $6 -v $2 -p $3 -a $4 -u $master_upP -d $master_downP -s $5 -P -B"
masterP="/etc/uuarp/master.sh"
echo -e $master > $masterP
chmod +x $masterP

sh $masterP

grep -wq "sh $masterP" /etc/rc.local &> /dev/null
if [ $? -ne 0 ]
then
    sed -i "/multiuser/i\sh $masterP" /etc/rc.local
fi







