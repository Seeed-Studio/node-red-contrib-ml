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
	#curl -SL https://files.seeedstudio.com/wiki/reComputer/compose.tar.bz2  -o /tmp/compose.tar.bz2 
	cp $HOME/compose.tar.bz2 /tmp/compose.tar.bz2 
	tar xvf /tmp/compose.tar.bz2 -C /usr/local/bin
	chmod +x  /usr/local/bin/docker-compose
fi

#node-red setting
mkdir -p $HOME/node-red
cp node-red-config/*  $HOME/node-red

echo -e  "${IBlue}#########################################################################"
echo -e  "${IGreen}build docker base"
docker build --rm --no-cache   --file docker/Dockerfile.base  --tag dev:base-build .
echo -e  "${IYellow}#########################################################################"

echo -e  "${IGreen}build docker dataloader"
docker build --file docker/Dockerfile.dataloader --tag dev:dataloader-build .
echo -e  "${IYellow}#########################################################################"

echo -e  "${IGreen}build docker detection"
docker build  --file docker/Dockerfile.detection --tag dev:detection-build .
echo -e  "${IYellow}#########################################################################"


# test
# nvidia-docker run -it -p 5550:5550  --device  /dev/video0  --name dataloader  dev:dataloader-build 
# nvidia-docker run -it  -p 5560:5560   --name detection  dev:detection-build

echo -e  "${IGreen}start all of docker"

#deamon
docker-compose --file docker/docker-compose.yaml  up -d

#install node-red theme package
docker exec docker-node-red-1 bash -c "cd /data && npm install"


#no deamon
#docker-compose --file docker/docker-compose.yaml  up
echo -e  "${IYellow}#########################################################################"


#sudo docker login
#sudo  docker tag  dev:dataloader-build baozhu/node-red-dataloader:v1.0
#sudo  docker tag  dev:detection-build baozhu/node-red-detection:v1.0
#sudo  docker push baozhu/node-red-detection:v1.0
#sudo  docker push baozhu/node-red-dataloader:v1.0
