"""pub_sub_broadcast.py
broadcast OpenCV stream using PUB SUB.
broadcast port 5555 and use the /dev/video0 data source
python3 python/pub_sub_broadcast.py  --port 5555 --source 0
 """

import sys

import socket
import traceback
from time import sleep
import cv2
# import imagezmq
from dataloaders import LoadStreams
import os
import argparse
import base64

from http.server import HTTPServer, BaseHTTPRequestHandler

from multiprocessing import Process
import subprocess
import threading
from flask import Flask
from flask import request
import numpy as np
import re

# logging.getLogger('dataloader').disabled = True
from logging.config import dictConfig

dictConfig({
    'version': 1,
    'root': {
        'level': 'INFO',
    }
})


app = Flask(__name__)

host = ('0.0.0.0', 5550)

def parse_args():
    return 5555, '0'



# def parse_args():
#     parser = argparse.ArgumentParser(description='broadcast OpenCV stream using PUB SUB.')
#     parser.add_argument('--port', type=int, required=True, help='video stream broadcast port')
#     parser.add_argument('--source', type=str, default='data/images', help='file/dir/URL/glob, 0 for webcam')
#     args = parser.parse_args()

#     return args.port, args.source

def generate_image_with_text(text):
    img = np.ones(shape=(480,640,3), dtype=np.int16)
    y0, dy = 10, 10
    #auto line , 64 words new line
    text = text + "                                                                " # retain the last line less than 64 words.
    for i, line in enumerate(re.findall(r'.{64}', text)):
        y = y0 + i*dy
        # cv2.putText(img, line, (0, y ), cv2.FONT_HERSHEY_SIMPLEX, 1, 2)
        cv2.putText(img=img, text=line, org=(0, y), fontFace=cv2.FONT_HERSHEY_PLAIN, fontScale=1, color=(0, 255, 0),thickness=1)

    # cv2.putText(img=img, text=text, org=(0, 30), fontFace=cv2.FONT_HERSHEY_TRIPLEX, fontScale=1, color=(0, 255, 0),thickness=1)
    ret_code, jpg_buffer = cv2.imencode(".jpg", img, [int(cv2.IMWRITE_JPEG_QUALITY), 95])

    return jpg_buffer





class DataLoadderThread(threading.Thread):
    # overriding constructor
    def __init__(self):
        # calling parent class constructor
        threading.Thread.__init__(self)
        # JPEG quality, 0 - 100
        self.jpeg_quality = 95
        self.data = None
        self.is_init = False
        self.is_ok = True
        self.resolution = None
        self.device = None
        self.rtsp = None
        self.pre_input = None
        self.reset = False
        self.screen_table = {'3840': {'h':3840,'w':2160}, 
                '2560': {'h':2560,'w':1600}, 
                '1920': {'h':1920,'w':1080}, 
                '1280': {'h':1280,'w':720}, 
                '800': {'h':800,'w':600}, 
                '640': {'h':640,'w':480}, 
                '320': {'h':320,'w':320}}


    # define your own run method
    def run(self):
        self.start_streams()

    def set_args(self,resolution,device,rtsp):
        self.resolution = resolution
        self.device = device
        self.rtsp = rtsp
        if self.pre_input and self.pre_input != [resolution, device, rtsp]:
            self.reset = True
        self.pre_input = [resolution, device, rtsp]

    def stop(self):
        self.reset = True
        # sleep(0.1)  # time to interrupt thread
        # self.reset = False


    def start_streams(self):
        port, source = parse_args()
        # sender = imagezmq.ImageSender("tcp://*:{}".format(port), REQ_REP=False)

        if not self.is_init:
            self.data = generate_image_with_text("not init....")
            while not self.is_init:
                try:
                    if not self.resolution:
                        continue
                    if  self.rtsp :
                        source = ('rtspsrc location={} ! ''rtph264depay ! h264parse ! nvv4l2decoder ! nvvidconv !'
               'video/x-raw,width={},height={},format=BGRx ! videoconvert ! video/x-raw,format=BGR ! appsink ').format(self.rtsp,
                                                                                                                self.screen_table[self.resolution]['h'],
                                                                                                                self.screen_table[self.resolution]['w'])
                    else:
                        source = ("v4l2src device={} ! image/jpeg,framerate=30/1,width={}, height={},type=video ! "
                        "jpegdec ! videoconvert ! video/x-raw ! appsink").format(self.device,
                                                                                self.screen_table[self.resolution]['h'],
                                                                                self.screen_table[self.resolution]['w'])
                    app.logger.info(source)
                    print(source)
                    dataloader = LoadStreams(source)  # Webcam
                    self.is_init = True
                except Exception as ex:
                    self.data =  generate_image_with_text(f"Traceback error: {ex}")
                    print(ex)
                    self.is_ok = False                

        # Send RPi hostname with each image
        # This might be unnecessary in this pub sub mode, as the receiver will
        #    already need to know our address and can therefore distinguish streams
        # Keeping it anyway in case you wanna send a meaningful tag or something
        #    (or have a many to many setup)
        rpi_name = socket.gethostname()

        try:
            counter = 0
            for path, im, im0s, vid_cap, s in dataloader:
                for img in im0s:
                    if self.reset:
                        dataloader.killed = True
                        break
                    # img = cv2.resize(img, (1280,720), interpolation=cv2.INTER_LINEAR)
                    ret_code, jpg_buffer = cv2.imencode(
                        ".jpg", img, [int(cv2.IMWRITE_JPEG_QUALITY), self.jpeg_quality ])
                    # sender.send_jpg(rpi_name, base64.b64encode(jpg_buffer))

                    self.data = jpg_buffer

                    # sender.send_jpg(rpi_name, jpg_buffer)

                    #sender.send_jpg(rpi_name, img)

                    # jancee updated
                    # print("Sent frame {}".format(counter))

                    # Jancee updated
                    # sleep(0.05)
                    counter = counter + 1

                if not dataloader.camera_exist: 
                    self.data = generate_image_with_text(f"Video stream unresponsive, please check your IP camera connection. " 
                                                            f"Then kill the docker container docker-dataloader-1 and restart it.")
                    self.is_ok = False
            
        except (KeyboardInterrupt, SystemExit):
            print('Exit due to keyboard interrupt')
        except Exception as ex:
            print('Python error with no Exception handler:')
            print('Traceback error:', ex)
            traceback.print_exc()
        finally:
            sys.exit()




if __name__ == "__main__":
    dataloader = DataLoadderThread()
    dataloader.start()

    @app.route('/health')
    def http_get_request_health():
        return 'ok'

    @app.route('/')
    def hello():
        global dataloader
        resolution = request.args.get("resolution")
        device = request.args.get("localAddress")
        rtsp = request.args.get("rtspUrl")
        dataloader.set_args(resolution,device,rtsp)
        if dataloader.reset:
            dataloader.stop()
            dataloader.join()
            # print(dataloader.is_alive())
            dataloader = DataLoadderThread()
            dataloader.start()
            # print(dataloader.is_alive())
    
        if dataloader.is_ok:
            return base64.b64encode(dataloader.data), 200, [("ok",1)] 
        else:
            return base64.b64encode(dataloader.data), 200, [("ok",0)] 


    app.run(host="0.0.0.0", port=5550)

