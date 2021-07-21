import serial
import time
from beam_following_2d import QuadRobot

robot = QuadRobot()

print(robot.ser.name)         # check which port was really used

# ser.write(b'start_pose\n')     # write a string
# response = ser.readline().decode("utf-8") # decode removes b' \r\n' from message

# response = serial_write_read(ser, 'start_pose')

response = robot.write_read('BR_leg_forward')


# ser.close()

print(f"response was {response} of type {type(response)}")
