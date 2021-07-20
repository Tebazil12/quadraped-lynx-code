import serial
import time

# NB, robot batteries must be switched on, even if not trying to move legs!
ser = serial.Serial('/dev/ttyUSB0', baudrate=9600)  # open serial port
time.sleep(1.5) # in matlab this is needed to allow serial port time to open


print(ser.name)         # check which port was really used
ser.write(b'hello\n')     # write a string
response = ser.readline().decode("utf-8") # decode removes b' \r\n' from message

ser.close()

print(f"response was {response} of type {type(response)}")
