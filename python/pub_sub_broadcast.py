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
import imagezmq
from dataloaders import LoadStreams
import os
import argparse
import base64

from http.server import HTTPServer, BaseHTTPRequestHandler

from multiprocessing import Process
import subprocess
import threading
from flask import Flask

import logging
logging.getLogger('werkzeug').disabled = True

app = Flask(__name__)

host = ('0.0.0.0', 5550)

to_jpg_buffer = bytes('seeed',encoding="utf-8")

def parse_args():
    return 5555, '0'

# def parse_args():
#     parser = argparse.ArgumentParser(description='broadcast OpenCV stream using PUB SUB.')
#     parser.add_argument('--port', type=int, required=True, help='video stream broadcast port')
#     parser.add_argument('--source', type=str, default='data/images', help='file/dir/URL/glob, 0 for webcam')
#     args = parser.parse_args()

#     return args.port, args.source

@app.route('/health')
def http_get_request_health():
    return 'ok'

@app.route('/')
def hello():
    return base64.b64encode(to_jpg_buffer)

def start_streams():
    global to_jpg_buffer
    port, source = parse_args()
    sender = imagezmq.ImageSender("tcp://*:{}".format(port), REQ_REP=False)

    # Open input stream; comment out one of these capture = VideoStream() lines!
    # *** You must use only one of Webcam OR PiCamera
    # Webcam source for broadcast images
    dataloader = LoadStreams(source)  # Webcam

    # JPEG quality, 0 - 100
    jpeg_quality = 95

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
                # img = cv2.resize(img, (640,360), interpolation=cv2.INTER_LINEAR)
                ret_code, jpg_buffer = cv2.imencode(
                    ".jpg", img, [int(cv2.IMWRITE_JPEG_QUALITY), jpeg_quality])
                # sender.send_jpg(rpi_name, base64.b64encode(jpg_buffer))

                to_jpg_buffer = jpg_buffer

                sender.send_jpg(rpi_name, jpg_buffer)

                #sender.send_jpg(rpi_name, img)

                # jancee updated
                # print("Sent frame {}".format(counter))

                # Jancee updated
                # sleep(0.05)
                counter = counter + 1

    except (KeyboardInterrupt, SystemExit):
        print('Exit due to keyboard interrupt')
    except Exception as ex:
        print('Python error with no Exception handler:')
        print('Traceback error:', ex)
        traceback.print_exc()
    finally:
        sender.close()
        sys.exit()

def init_streams():
    t = threading.Thread(target=start_streams)
    t.start()

if __name__ == "__main__":
    init_streams()
    app.run(host="0.0.0.0", port=5550)
