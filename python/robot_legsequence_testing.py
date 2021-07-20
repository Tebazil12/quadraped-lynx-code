import serial
import time
from robot_legmoves_testing import serial_write_read

# NB, robot batteries must be switched on, even if not trying to move legs!
ser = serial.Serial('/dev/ttyUSB0')  # open serial port
time.sleep(1.5) # in matlab this is needed to allow serial port time to open

print(ser.name)         # check which port was really used

# ser.write(b'start_pose\n')     # write a string
# response = ser.readline().decode("utf-8") # decode removes b' \r\n' from message

response = serial_write_read(ser, 'start_pose')
print(response)
time.sleep(1.5)

response = serial_write_read(ser, 'BR_leg_forward')
print(response)
time.sleep(1.5)

response = serial_write_read(ser, 'FR_leg_forward')
print(response)
time.sleep(1.5)

response = serial_write_read(ser, 'FRf_body_forward')
print(response)
time.sleep(1.5)

response = serial_write_read(ser, 'BL_leg_forward')
print(response)
time.sleep(1.5)

response = serial_write_read(ser, 'FL_leg_forward')
print(response)
time.sleep(1.5)

response = serial_write_read(ser, 'FLf_body_forward')
print(response)
time.sleep(1.5)


ser.close()

print(f"response was {response} of type {type(response)}")
