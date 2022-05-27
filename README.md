# No-Code Edge AI Vision with Node-RED

Now you can get started with AI vision at the edge in just **THREE STEPS** with no coding experience at all!

## Prerequisites

- NVIDIA Jetson device
- USB webcam
- PC (Windows/Mac/Linux)

## Getting Started

**Note:** For this guide, we have used a [reComputer J1010 with Jetson Nano](https://www.seeedstudio.com/Jetson-10-1-A0-p-5336.html) running [NVIDIA JetPack 4.6.1](https://developer.nvidia.com/jetpack-sdk-461)

### Step 1 - Install

SSH into Jetson device using a PC, clone this GitHub repo and run the installer

```sh
git clone https://github.com/Seeed-Studio/node-red-contrib-ml
cd node-red-contrib-ml && sudo ./docker-ubuntu.sh
```

### Step 2 - Configure

Open a web browser on PC, type `jetson_device_ip_address:1880` on the search box, drag and drop blocks and connect them as follows 

<p style=":center"><img src="https://files.seeedstudio.com/wiki/node-red/nodered-UI-overview-2.png" /></p>

### Step 3 - Deploy

Press **DEPLOY** to see it in action!

https://user-images.githubusercontent.com/20147381/170643573-2a2d70c2-7e0b-430b-b66c-ee56ade3116f.mp4

**Note:** Here the pre-loaded AI model is trained using the [COCO dataset](https://cocodataset.org/#home) and you can detect 80 different objects.

## Learn more

For a more detailed step-by-step guide on using Node-RED for Edge AI Vision, please refer to [this wiki](https://wiki.seeedstudio.com/No-code-Edge-AI-Tool/).
