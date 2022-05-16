#!/bin/bash


# High Intensity
IBlack='\033[0;90m'       # Black
IRed='\033[0;91m'         # Red
IGreen='\033[0;92m'       # Green
IYellow='\033[0;93m'      # Yellow
IBlue='\033[0;94m'        # Blue
IPurple='\033[0;95m'      # Purple
ICyan='\033[0;96m'        # Cyan
IWhite='\033[0;97m'       # White



if ! [ $(id -u) = 0 ] ; then
	echo "$0 must be run as sudo user or root"
	exit 1
fi

storage=$(df   | awk '{ print  $4  } ' | awk 'NR==2{print}' )
#if storage > 3G
if [ $storage -gt 3200000 ] ; then
	echo -e "${IGreen}Your system space left is $storage, you can install this application."
else
	echo -e "${IRed}Sorry, you don't have enough storage space to install this docker."
	#echo -e "${IRed}But uninstalling nvidia-jetpack will free up space to install this docker, so please agree to uninstall nvidia-jetpack.y/n"
	read yn
	if [ $yn = "y" ] ; then
		echo "${IGreen}start autoremove"
		#apt remove -y nvidia-jetpack
		apt autoremove -y
	else
		exit 1
	fi
fi

apt update

if ! [ -x "$(command -v curl)" ]; then
	apt install curl
fi


if ! [ -x "$(command -v docker)" ]; then
	apt install docker
fi

if ! [ -x "$(command -v nvidia-docker)" ]; then
	apt install nvidia-docker2
fi

if ! [ -x "$(command -v docker-compose)" ]; then
	curl -SL https://files.seeedstudio.com/wiki/reComputer/compose.tar.bz2  -o /tmp/compose.tar.bz2 
	tar xvf /tmp/compose.tar.bz2 -C /usr/local/bin
	chmod +x  /usr/local/bin/docker-compose
fi

#node-red setting
mkdir -p $HOME/node-red
cp node-red-config/*  $HOME/node-red



echo -e  "${IGreen}start all of docker"

#deamon
docker-compose --file docker-compose.yaml  up -d

#install node-red theme package
docker exec node-red-contrib-ml-node-red-1 bash -c "cd /data && npm install"

#no deamon
#docker-compose --file docker/docker-compose.yaml  up
echo -e  "${IYellow}#########################################################################"


#sudo docker login
#sudo  docker tag  dev:dataloader-build baozhu/node-red-dataloader:v1.0
#sudo  docker tag  dev:detection-build baozhu/node-red-detection:v1.0
#sudo  docker push baozhu/node-red-detection:v1.0
#sudo  docker push baozhu/node-red-dataloader:v1.0
