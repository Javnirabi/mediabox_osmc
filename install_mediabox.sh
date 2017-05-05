#!/bin/bash

#Preparate environment 
cd /home/osmc
echo "deb http://linux-packages.getsync.com/btsync/deb btsync non-free" | sudo tee /etc/apt/sources.list.d/btsync.list
wget -qO - https://linux-packages.resilio.com/resilio-sync/key.asc | sudo apt-key add -
mkdir /home/osmc/Wallpapers
sudo chmod -R 777 /home/osmc/Wallpapers

#download and install packages .deb
wget https://sourceforge.net/projects/bananapi/files/unrar_5.2.6-1_armhf.deb
sudo dpkg -i /opt/unrar_5.2.6-1_armhf.deb
rm unrar_5.2.6-1_armhf.deb

#update O.S
sudo apt update && apt upgrade -y

#install dependecies
sudo apt install armv7-transmission-app-osmc btsync cron-app-osmc apt-transport-https libav-tools atomicparsley git-core libffi-dev libssl-dev zlib1g-dev libxslt1-dev libxml2-dev python python-pip python-dev build-essential git libxslt1.1 libxml2 -y
sudo pip install lxml cryptography pyopenssl youtube-dl

#clone apps couchpotato - sickrage - headphones
sudo git clone http://github.com/RuudBurger/CouchPotatoServer /opt/couchpotato
sudo git clone https://github.com/rembo10/headphones.git /opt/headphones
sudo git clone https://github.com/SickRage/SickRage.git /opt/sickrage
sudo git https://github.com/Javnirabi/mediabox_osmc/tree/master/doclimus /opt/doclimus

#change own and create folders
sudo chown -R osmc:osmc /opt/headphones /opt/couchpotato /opt/sickrage /opt/doclimus

#config btsync
sudo sed  -i 's/127.0.0.1:8888/0.0.0.0:8888/g' /etc/btsync/config.json
sudo systemctl restart btsync.service

#create file default to couchpotato
sudo echo "CP_HOME=/opt/couchpotato
CP_USER=osmc
CP_PIDFILE=/home/osmc/.couchpotato.pid
CP_DATA=/opt/couchpotato
CP_OPTS=--daemon" > /etc/default/couchpotato

#create file default to sickrage
sudo echo "SR_USER=osmc
SR_HOME=/opt/sickrage
SR_DATA=/opt/sickrage
SR_PIDFILE=/home/pi/.sickrage.pid" > /etc/default/sickrage

#create file default to headphones
sudo echo "HP_USER=osmc
HP_HOME=/opt/headphones
HP_PORT=8181" > /etc/default/headphones

#active service couchpotato in systemd
sudo cp /opt/couchpotato/init/couchpotato.service /lib/systemd/system/couchpotato.service
sudo sed -i 's/\/var\/lib\/CouchPotatoServer\//\/opt\/couchpotato\//g' /lib/systemd/system/couchpotato.service
sudo sed -i 's/=couchpotato/=osmc/g' /lib/systemd/system/couchpotato.service
#sudo systemctl enable couchpotato.service

#active service sickrage in systemd
sudo cp /opt/sickrage/runscripts/init.systemd /lib/systemd/system/sickrage.service
sudo sed -i 's/=sickrage/=osmc/g' /lib/systemd/system/sickrage.service
#sudo systemctl enable sickrage.service

sudo cp /opt/headphones/init-scripts/init.fedora.centos.systemd /lib/systemd/system/headphones.service
sudo sed -i 's/\/home\/sabnzbd\//\/opt\//g' /lib/systemd/system/headphones.service
sudo sed -i 's/\/etc\/headphones\/headphones.ini/\/opt\/headphones\/config.ini/g' /lib/systemd/system/headphones.service
sudo sed -i 's/\/opt\/.headphones/\/opt\/headphones\/data/g' /lib/systemd/system/headphones.service
sudo sed -i 's/=sabnzbd/=osmc/g' /lib/systemd/system/headphones.service
touch /opt/headphones/config.ini
echo "[General]
http_host = 0.0.0.0" > /opt/headphones/config.ini
#sudo systemctl enable headphones.service

#scheduled task
#echo "0 2 * * *     /opt/doclimus/./down_youtube.sh" >> /var/spool/cron/crontabs/osmc
