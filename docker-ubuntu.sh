#!/bin/bash

echo "#########################################################################"
echo "build docker base"
sudo  docker build --rm --no-cache   --file docker/Dockerfile.base  --tag dev:base-build .
echo "#########################################################################"

echo "build docker dataloader"
sudo  docker build --file docker/Dockerfile.dataloader --tag dev:dataloader-build .
echo "#########################################################################"

echo "build docker detection"
sudo  docker build  --file docker/Dockerfile.detection --tag dev:detection-build .
echo "#########################################################################"

echo "build docker node-red"
sudo  docker build  --file docker/Dockerfile.node-red --tag dev:node-red-build .
echo "#########################################################################"

# test
# sudo nvidia-docker run -it -p 5550:5550  --device  /dev/video0  --name dataloader  dev:dataloader-build 
# sudo nvidia-docker run -it  -p 5560:5560   --name detection  dev:detection-build
# sudo nvidia-docker run -it -d --restart=always  -p 1880:1880  --name node-red   dev:node-red-build

echo "start all of docker"

sudo curl -SL https://github.com/docker/compose/releases/download/v2.5.0/docker-compose-linux-aarch64  -o /usr/local/bin/docker-compose
#deamon
sudo  docker-compose --file docker/docker-compose.yaml  up -d

#no deamon
#sudo  docker-compose --file docker/docker-compose.yaml  up
echo "#########################################################################"
