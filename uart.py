import serial
import threading

ser = serial.Serial("COM8", 115200, timeout=0.1)

def rx_thread():
    while True:
        data = ser.read(1024)
        if data:
            print(data.decode(errors="ignore"), end="")

threading.Thread(target=rx_thread, daemon=True).start()

while True:
    cmd = input()
    ser.write((cmd + "\r").encode())