import serial
import time

def serial_write_read(ser, msg):
    # send msg over serial (encoding and adding appropriate line endings),
    # then decode the response

    # need to match format that matlab used
    msg = msg + "\n"
    encoded_msg = msg.encode("utf-8")
    ser.write(b'start_pose\n')     # write a string
    response = ser.readline().decode("utf-8") # decode removes b' \r\n' from message

    return response

# NB, robot batteries must be switched on, even if not trying to move legs!
ser = serial.Serial('/dev/ttyUSB0')  # open serial port
time.sleep(1.5) # in matlab this is needed to allow serial port time to open

print(ser.name)         # check which port was really used

# ser.write(b'start_pose\n')     # write a string
# response = ser.readline().decode("utf-8") # decode removes b' \r\n' from message

# response = serial_write_read(ser, 'start_pose')

response = serial_write_read(ser, 'BR_leg_forward')


ser.close()

print(f"response was {response} of type {type(response)}")
