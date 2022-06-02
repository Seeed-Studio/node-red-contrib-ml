# -*- coding: utf-8 -*-
# @Time    : 2022/6/2 11:28
# @Author  : Kenny Zhou
# @FileName: video_frame_control.py
# @Software: PyCharm
# @Email    ：l.w.r.f.42@gmail.com


from threading import Thread


def create_thread(f):
    def wrapper(*args, **kwargs):
        thr = Thread(target=f, args=args, kwargs=kwargs,daemon=True)
        thr.start()

    return wrapper

class FrameBuffer(list):
	"""
		Create a frame buffer with automatic length management
	"""
	def __init__(self):
		super(FrameBuffer, self).__init__()
		self.clear()

	def smart_append(self, object):

		while self.__len__()>=self.size:
			if self.__len__()<self.size:
				break
			else:
				self.pop(0)
		self.append(object)

	@property
	def size(self):
		return self._size

	@size.setter
	def size(self, value):
		if not isinstance(value, int):
			raise ValueError('size must be an integer!')
		if value <= 1 or value > 120:
			raise ValueError('size must between0! 0 ~ 120')
		self._size = value

# class FrameManager:
# 	"""
# 		Control video frames to not exceed current reasoning capabilities.
# 	"""
# 	def __init__(self,frame_buffer_size=5,**kwargs):
#
# 		self.frame_buffer = FrameBuffer()
# 		self.frame_buffer.size = frame_buffer_size


if __name__ == "__main__":
	f = FrameBuffer(frame_buffer_size=2)
	f.smart_append(0)