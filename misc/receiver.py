import serial
import numpy as np
import struct

HEADER_LENGTH = 2
FRAME_LENGTH = 2048
BAUD_RATE = 115200 #921600

def read_frame(ser):
    while True:
        if ser.read(HEADER_LENGTH) == b'\xAA\xAA':
            return ser.read(FRAME_LENGTH)

connection = serial.Serial('/dev/ttyUSB0', BAUD_RATE)

with open("data.bin", "wb") as f:
    while True:
        #data = connection.read(FRAME_LENGTH)  # Match buffer size
        data = read_frame(connection)
        f.write(data)
        
data = np.fromfile("data.bin", dtype=np.uint16)

import matplotlib.pyplot as plt
plt.plot(data[:2000])
plt.show()

