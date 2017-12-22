#!/usr/bin/env bash

#example:./harbor-main.sh /mnt/1/release-HARBOR 192.168.112.128 smtp.exmail.qq.com 25 598892742@qq.com aaaa 598892742@qq.com 123 10.10.103.141
# 1:path 2:hostIP 9:nfs,ntp IP

cd $1/build/harbor

ntpdate $9

grep -wq "ntpdate $9" /etc/rc.local &> /dev/null
if [ $? -ne 0 ]
then
sed -i "/multiuser/i\ntpdate $9" /etc/rc.local
fi

#apt-get -y install nfs-common
sudo dpkg --install ../../release/nfs-common/*.deb

if [ ! -d "/data" ]
then
	mkdir /data
fi

#mount nfs
mount -t nfs $9:/home/harbor /data

grep -wq "mount -t nfs $9:/home/harbor /data" /etc/rc.local &> /dev/null
if [ $? -ne 0 ]
then
sed -i "/multiuser/i\mount -t nfs $9:/home/harbor /data" /etc/rc.local
fi

#load docker images
docker load -i ../../release/docker/harbor-jobservice.tar

docker load -i ../../release/docker/harbor-nginx.tar

docker load -i ../../release/docker/harbor-registry.tar

docker load -i ../../release/docker/harbor-ui.tar

docker load -i ../../release/docker/mysql.tar

docker load -i ../../release/docker/ubuntu.tar

#insecure-registry
regitry='DOCKER_OPTS="--insecure-registry "'$2'""'

echo $regitry >> /etc/default/docker

service docker stop

service docker start


#change host ip
sed -i "s/.*hostname = .*/hostname = $2/" harbor.cfg

#change email(email server)
sed -i "s/.*email_server = .*/email_server = $3/" harbor.cfg

##change email(email port)
sed -i "s/.*email_server_port = .*/email_server_port = $4/" harbor.cfg

##change email(email username)
sed -i "s/.*email_username = .*/email_username = $5/" harbor.cfg

##change email(email password)
sed -i "s/.*email_password = .*/email_password = $6/" harbor.cfg

##change email(email from)
sed -i "s/.*email_from = .*/email_from = $7/" harbor.cfg

##change admin password
sed -i "s/.*harbor_admin_password = .*/harbor_admin_password = $8/" harbor.cfg

if [ ! -d "/root/.ssh/" ]
then
	mkdir /root/.ssh/
fi

if [ ! -f "/root/.ssh/authorized_keys" ]
then
  touch /root/.ssh/authorized_keys
fi

docker-compose down

./prepare

docker-compose up --build -d

uiUUID=`docker ps | grep deploy_ui | awk -F ' ' '{print $1}'`

docker exec -it $uiUUID rm -rf ~/.ssh/

docker exec -it $uiUUID /usr/bin/ssh-keygen -t rsa -f ~/.ssh/id_rsa -P ''

docker exec -it $uiUUID cat /root/.ssh/id_rsa.pub >> /root/.ssh/authorized_keys

#mysqlUUID=`docker ps | grep harbor_mysql | awk -F ' ' '{print $1}'`

#docker exec -it $mysqlUUID service mysql restart >/dev/null 2>&1

sleep 60

docker-compose stop

nohup ./harbor_gc >/dev/null 2>&1 </dev/null &

grep -wq "cd $1/build/harbor" /etc/rc.local &> /dev/null
if [ $? -ne 0 ]
then
sed -i "/multiuser/i\cd $1/build/harbor" /etc/rc.local
fi

grep -wq "nohup ./harbor_gc >/dev/null 2>&1 </dev/null &" /etc/rc.local &> /dev/null
if [ $? -ne 0 ]
then
sed -i "/multiuser/i\nohup ./harbor_gc >/dev/null 2>&1 </dev/null &" /etc/rc.local
fi


