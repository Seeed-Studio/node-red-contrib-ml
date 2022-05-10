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
	echo -e "${IRed}But uninstalling nvidia-jetpack will free up space to install this docker, so please agree to uninstall nvidia-jetpack.y/n"
	read yn
	if [ $yn = "y" ] ; then
		echo "${IGreen}start remove nvidia-jetpack"
		sudo apt remove -y nvidia-jetpack
		sudo apt autoremove -y
	else
		exit 1
	fi
fi

sudo apt update

if ! [ -x "$(command -v curl)" ]; then
	sudo apt install curl
fi


if ! [ -x "$(command -v docker)" ]; then
	sudo apt install docker
fi

if ! [ -x "$(command -v nvidia-docker)" ]; then
	sudo apt install nvidia-docker2
fi

if ! [ -x "$(command -v docker-compose)" ]; then
	curl -SL https://files.seeedstudio.com/wiki/reComputer/compose.tar.bz2  -o /tmp/compose.tar.bz2 
	tar xvf /tmp/compose.tar.bz2 -C /usr/local/bin
	sudo chmod +x  /usr/local/bin/docker-compose
fi



echo -e  "${IBlue}#########################################################################"
echo -e  "${IGreen}build docker base"
sudo  docker build --rm --no-cache   --file docker/Dockerfile.base  --tag dev:base-build .
echo -e  "${IYellow}#########################################################################"

echo -e  "${IGreen}build docker dataloader"
sudo  docker build --file docker/Dockerfile.dataloader --tag dev:dataloader-build .
echo -e  "${IYellow}#########################################################################"

echo -e  "${IGreen}build docker detection"
sudo  docker build  --file docker/Dockerfile.detection --tag dev:detection-build .
echo -e  "${IYellow}#########################################################################"

echo -e  "${IGreen}build docker node-red"
sudo  docker build  --file docker/Dockerfile.node-red --tag dev:node-red-build .
echo -e  "${IYellow}#########################################################################"

# test
# sudo nvidia-docker run -it -p 5550:5550  --device  /dev/video0  --name dataloader  dev:dataloader-build 
# sudo nvidia-docker run -it  -p 5560:5560   --name detection  dev:detection-build
# sudo nvidia-docker run -it -d --restart=always  -p 1880:1880  --name node-red   dev:node-red-build

echo -e  "${IGreen}start all of docker"

#deamon
sudo  docker-compose --file docker/docker-compose.yaml  up -d

#no deamon
#sudo  docker-compose --file docker/docker-compose.yaml  up
echo -e  "${IYellow}#########################################################################"
