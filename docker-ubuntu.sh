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
#if storage > 3.8G
if [ $storage -gt 3800000 ] ; then
	echo -e "${IGreen}Your storage space left is $(($storage /1000000))GB, you can install this application."
else
	echo -e "${IRed}Sorry, you don't have enough storage space to install this application. You need about 3.8GB of storage space."
	echo -e "${IYellow}However, you can regain about 3.8GB of storage space by performing the following:"
	echo -e "${IYellow}-Remove unnecessary packages (~100MB)"
	echo -e "${IYellow}-Clean up apt cache (~1.6GB)"
	echo -e "${IYellow}-Remove thunderbird, libreoffice and related packages (~400MB)"
	echo -e "${IYellow}-Remove cuda, cudnn, tensorrt, visionworks and deepstream samples (~800MB)"
	echo -e "${IYellow}-Remove local repos for cuda, visionworks, linux-headers (~100MB)"
	echo -e "${IYellow}-Remove GUI (~400MB)"
	echo -e "${IYellow}-Remove Static libraries (~400MB)"
	echo -e "${IRed}So, please agree to uninstall the above. Press [y/n]"
	read yn
	if [ $yn = "y" ] ; then
		echo "${IGreen}starting to remove the above-mentioned"
		# Remove unnecessary packages, clean apt cache and remove thunderbird, libreoffice
		apt update
		apt autoremove -y
		apt clean
		apt remove thunderbird libreoffice-* -y

		# Remove samples
		rm -rf /usr/local/cuda/samples \
    		/usr/src/cudnn_samples_* \
    		/usr/src/tensorrt/data \
    		/usr/src/tensorrt/samples \
    		/usr/share/visionworks* ~/VisionWorks-SFM*Samples \
    		/opt/nvidia/deepstream/deepstream*/samples	

		# Remove local repos
		apt purge cuda-repo-l4t-*local* libvisionworks-*repo -y
		rm /etc/apt/sources.list.d/cuda*local* /etc/apt/sources.list.d/visionworks*repo*
		rm -rf /usr/src/linux-headers-*

		# Remove GUI
		apt-get purge gnome-shell ubuntu-wallpapers-bionic light-themes chromium-browser* libvisionworks libvisionworks-sfm-dev -y
		apt-get autoremove -y
		apt clean -y

		# Remove Static libraries
		rm -rf /usr/local/cuda/targets/aarch64-linux/lib/*.a \
    		/usr/lib/aarch64-linux-gnu/libcudnn*.a \
    		/usr/lib/aarch64-linux-gnu/libnvcaffe_parser*.a \
    		/usr/lib/aarch64-linux-gnu/libnvinfer*.a \
    		/usr/lib/aarch64-linux-gnu/libnvonnxparser*.a \
    		/usr/lib/aarch64-linux-gnu/libnvparsers*.a

		# Remove additional 100MB
		apt autoremove -y
		apt clean
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
