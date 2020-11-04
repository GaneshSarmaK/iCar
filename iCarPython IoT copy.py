#!/usr/bin/python
import RPi.GPIO as GPIO       #package for RFID 
import serial                 #pacakge for GPS
from time import sleep        #sleep timer
import time
import sys 
import math 
from mfrc522 import SimpleMFRC522
import smbus
import datetime
import firebase_admin
import google.cloud
import requests
from firebase_admin import credentials, firestore
import busio as rgbIO
import adafruit_tcs34725
import signal
import mfrc522 
import os

os.system("stty -F /dev/serial0 9600")
os.system("sudo gpsd /dev/serial0 -F /var/run/gpsd.sock")

filePath = "/home/pi/Desktop/sensorDataNoInternet.txt"

bus = smbus.SMBus(1)
MIFAREReader = mfrc522.MFRC522()


#required data is stored in these variables
ultrasonicDistance = 0.0
presentLat = 0.0
presentLong = 0.0
previousLat = 0.0
previousLong = 0.0
previousGpsTime = 0.0
presentGpsTime = 0.0
speedOfObject = 0 
rfidTag = 0
rfidText = "name"
outsideTemp = 0.0
insideTemp  = 0.0
luminance = 0.0
lat_in_degrees = 0
long_in_degrees = 0
accel_dataX = 0
accel_dataY = 0
accel_dataZ = 0
gyro_dataX = 0
gyro_dataY = 0
gyro_dataZ = 0
lockStatus = True
prevTag = 0


# Credentials and Firebase App initialization. Always required
firCredentials = credentials.Certificate("./Key.json")
firApp = firebase_admin.initialize_app (firCredentials)

# Get access to Firestore
firStore = firestore.client()

# Get access to the hero collection
# The ‘u’ prior to strings means a Unicode string. This is required for Firebase
firHeroesCollectionRef = firStore.collection(u'iCar')

#Gyro and Accelero class

class mpu6050:

    # Global Variables
    GRAVITIY_MS2 = 9.80665
    address = None
    bus = None

    # Scale Modifiers
    ACCEL_SCALE_MODIFIER_2G = 16384.0
    ACCEL_SCALE_MODIFIER_4G = 8192.0
    ACCEL_SCALE_MODIFIER_8G = 4096.0
    ACCEL_SCALE_MODIFIER_16G = 2048.0

    GYRO_SCALE_MODIFIER_250DEG = 131.0
    GYRO_SCALE_MODIFIER_500DEG = 65.5
    GYRO_SCALE_MODIFIER_1000DEG = 32.8
    GYRO_SCALE_MODIFIER_2000DEG = 16.4

    # Pre-defined ranges
    ACCEL_RANGE_2G = 0x00
    ACCEL_RANGE_4G = 0x08
    ACCEL_RANGE_8G = 0x10
    ACCEL_RANGE_16G = 0x18

    GYRO_RANGE_250DEG = 0x00
    GYRO_RANGE_500DEG = 0x08
    GYRO_RANGE_1000DEG = 0x10
    GYRO_RANGE_2000DEG = 0x18

    # MPU-6050 Registers
    PWR_MGMT_1 = 0x6B
    PWR_MGMT_2 = 0x6C

    ACCEL_XOUT0 = 0x3B
    ACCEL_YOUT0 = 0x3D
    ACCEL_ZOUT0 = 0x3F

    TEMP_OUT0 = 0x41

    GYRO_XOUT0 = 0x43
    GYRO_YOUT0 = 0x45
    GYRO_ZOUT0 = 0x47

    ACCEL_CONFIG = 0x1C
    GYRO_CONFIG = 0x1B

    def __init__(self, address, bus=1):
        self.address = address
        self.bus = smbus.SMBus(bus)
        # Wake up the MPU-6050 since it starts in sleep mode
        self.bus.write_byte_data(self.address, self.PWR_MGMT_1, 0x00)

    # I2C communication methods

    def read_i2c_word(self, register):
        """Read two i2c registers and combine them.
        register -- the first register to read from.
        Returns the combined read results.
        """
        # Read the data from the registers
        high = self.bus.read_byte_data(self.address, register)
        low = self.bus.read_byte_data(self.address, register + 1)

        value = (high << 8) + low

        if (value >= 0x8000):
            return -((65535 - value) + 1)
        else:
            return value

    # MPU-6050 Methods

    def get_temp(self):
        """Reads the temperature from the onboard temperature sensor of the MPU-6050.
        Returns the temperature in degrees Celcius.
        """
        raw_temp = self.read_i2c_word(self.TEMP_OUT0)

        # Get the actual temperature using the formule given in the
        # MPU-6050 Register Map and Descriptions revision 4.2, page 30
        actual_temp = (raw_temp / 340.0) + 36.53

        return actual_temp

    def set_accel_range(self, accel_range):
        """Sets the range of the accelerometer to range.
        accel_range -- the range to set the accelerometer to. Using a
        pre-defined range is advised.
        """
        # First change it to 0x00 to make sure we write the correct value later
        self.bus.write_byte_data(self.address, self.ACCEL_CONFIG, 0x00)

        # Write the new range to the ACCEL_CONFIG register
        self.bus.write_byte_data(self.address, self.ACCEL_CONFIG, accel_range)

    def read_accel_range(self, raw = False):
        """Reads the range the accelerometer is set to.
        If raw is True, it will return the raw value from the ACCEL_CONFIG
        register
        If raw is False, it will return an integer: -1, 2, 4, 8 or 16. When it
        returns -1 something went wrong.
        """
        raw_data = self.bus.read_byte_data(self.address, self.ACCEL_CONFIG)

        if raw is True:
            return raw_data
        elif raw is False:
            if raw_data == self.ACCEL_RANGE_2G:
                return 2
            elif raw_data == self.ACCEL_RANGE_4G:
                return 4
            elif raw_data == self.ACCEL_RANGE_8G:
                return 8
            elif raw_data == self.ACCEL_RANGE_16G:
                return 16
            else:
                return -1

    def get_accel_data(self, g = False):
        """Gets and returns the X, Y and Z values from the accelerometer.
        If g is True, it will return the data in g
        If g is False, it will return the data in m/s^2
        Returns a dictionary with the measurement results.
        """
        x = self.read_i2c_word(self.ACCEL_XOUT0)
        y = self.read_i2c_word(self.ACCEL_YOUT0)
        z = self.read_i2c_word(self.ACCEL_ZOUT0)

        accel_scale_modifier = None
        accel_range = self.read_accel_range(True)

        if accel_range == self.ACCEL_RANGE_2G:
            accel_scale_modifier = self.ACCEL_SCALE_MODIFIER_2G
        elif accel_range == self.ACCEL_RANGE_4G:
            accel_scale_modifier = self.ACCEL_SCALE_MODIFIER_4G
        elif accel_range == self.ACCEL_RANGE_8G:
            accel_scale_modifier = self.ACCEL_SCALE_MODIFIER_8G
        elif accel_range == self.ACCEL_RANGE_16G:
            accel_scale_modifier = self.ACCEL_SCALE_MODIFIER_16G
        else:
            print("Unkown range - accel_scale_modifier set to self.ACCEL_SCALE_MODIFIER_2G")
            accel_scale_modifier = self.ACCEL_SCALE_MODIFIER_2G

        x = x / accel_scale_modifier
        y = y / accel_scale_modifier
        z = z / accel_scale_modifier

        if g is True:
            return {'x': x, 'y': y, 'z': z}
        elif g is False:
            x = x * self.GRAVITIY_MS2
            y = y * self.GRAVITIY_MS2
            z = z * self.GRAVITIY_MS2
            return {'x': x, 'y': y, 'z': z}

    def set_gyro_range(self, gyro_range):
        """Sets the range of the gyroscope to range.
        gyro_range -- the range to set the gyroscope to. Using a pre-defined
        range is advised.
        """
        # First change it to 0x00 to make sure we write the correct value later
        self.bus.write_byte_data(self.address, self.GYRO_CONFIG, 0x00)

        # Write the new range to the ACCEL_CONFIG register
        self.bus.write_byte_data(self.address, self.GYRO_CONFIG, gyro_range)

    def read_gyro_range(self, raw = False):
        """Reads the range the gyroscope is set to.
        If raw is True, it will return the raw value from the GYRO_CONFIG
        register.
        If raw is False, it will return 250, 500, 1000, 2000 or -1. If the
        returned value is equal to -1 something went wrong.
        """
        raw_data = self.bus.read_byte_data(self.address, self.GYRO_CONFIG)

        if raw is True:
            return raw_data
        elif raw is False:
            if raw_data == self.GYRO_RANGE_250DEG:
                return 250
            elif raw_data == self.GYRO_RANGE_500DEG:
                return 500
            elif raw_data == self.GYRO_RANGE_1000DEG:
                return 1000
            elif raw_data == self.GYRO_RANGE_2000DEG:
                return 2000
            else:
                return -1

    def get_gyro_data(self):
        """Gets and returns the X, Y and Z values from the gyroscope.
        Returns the read values in a dictionary.
        """
        x = self.read_i2c_word(self.GYRO_XOUT0)
        y = self.read_i2c_word(self.GYRO_YOUT0)
        z = self.read_i2c_word(self.GYRO_ZOUT0)

        gyro_scale_modifier = None
        gyro_range = self.read_gyro_range(True)

        if gyro_range == self.GYRO_RANGE_250DEG:
            gyro_scale_modifier = self.GYRO_SCALE_MODIFIER_250DEG
        elif gyro_range == self.GYRO_RANGE_500DEG:
            gyro_scale_modifier = self.GYRO_SCALE_MODIFIER_500DEG
        elif gyro_range == self.GYRO_RANGE_1000DEG:
            gyro_scale_modifier = self.GYRO_SCALE_MODIFIER_1000DEG
        elif gyro_range == self.GYRO_RANGE_2000DEG:
            gyro_scale_modifier = self.GYRO_SCALE_MODIFIER_2000DEG
        else:
            print("Unkown range - gyro_scale_modifier set to self.GYRO_SCALE_MODIFIER_250DEG")
            gyro_scale_modifier = self.GYRO_SCALE_MODIFIER_250DEG

        x = x / gyro_scale_modifier
        y = y / gyro_scale_modifier
        z = z / gyro_scale_modifier

        return {'x': x, 'y': y, 'z': z}

    def get_all_data(self):
        """Reads and returns all the available data."""
        temp = self.get_temp()
        accel = self.get_accel_data()
        gyro = self.get_gyro_data()

        return [accel, gyro, temp]

#RFID initializer
reader = SimpleMFRC522()

#GPS initializers
gpgga_info = "$GPGGA,"
ser = serial.Serial ("/dev/ttyS0")              #Open port with baud rate
GPGGA_buffer = 0
NMEA_buff = 0

#GPS. Get data from serial0 and then extract coordinates from NMEA data 
def GPS_Info():
    global NMEA_buff
    global presentLat
    global presentLong
    global presentGpsTime
    nmea_time = []
    nmea_latitude = []
    nmea_longitude = []
    nmea_time = NMEA_buff[0]                    #extract time from GPGGA string
    nmea_latitude = NMEA_buff[1]                #extract latitude from GPGGA string
    nmea_longitude = NMEA_buff[3]               #extract longitude from GPGGA string
    
    try:
        lat = float(nmea_latitude)              #convert string into float for calculation
        longi = float(nmea_longitude)
        if (NMEA_buff[2] == "S"):
        lat = lat * -1                          #convertr string into float for calculation
        if (NMEA_buff[4] == "W"):
            longi = longi * -1
        presentLat = convert_to_degrees(lat)    #get latitude in degree decimal format
        presentLong = convert_to_degrees(longi) #get longitude in degree decimal format
        presentGpsTime = nmea_time
    except:
        pass
#convert raw NMEA string into degree decimal format   
def convert_to_degrees(raw_value):
    decimal_value = raw_value/100.00
    degrees = int(decimal_value)
    mm_mmmm = (decimal_value - int(decimal_value))/0.6
    position = degrees + mm_mmmm
    position = "%.4f" %(position)
    return position   

def calculateSpeed(lat1, lon1, lat2, lon2, timeDiff):
        
    lat1 = lat1 * math.pi / 180.0;
    lon1 = lon1 * math.pi / 180.0;
     
    lat2 = lat2 * math.pi / 180.0;
    lon2 = lon2 * math.pi / 180.0;
     
    r = 6378100;
     
    rho1 = r * math.cos(lat1);
    z1 = r * math.sin(lat1);
    x1 = rho1 * math.cos(lon1);
    y1 = rho1 * math.sin(lon1);
     
    rho2 = r * math.cos(lat2);
    z2 = r * math.sin(lat2);
    x2 = rho2 * math.cos(lon2);
    y2 = rho2 * math.sin(lon2);
     
    dot = (x1 * x2 + y1 * y2 + z1 * z2);
    cos_theta = dot / (r * r);
    theta = math.acos(cos_theta);
     
    distance = r * theta;
    if (timeDiff == 0):
        timeDiff = 1
    speed = (distance / timeDiff) * (3600 / 1000)   
    return speed                   

#Alitmeter Temperature
TEMP_ADDRESS = 0x60 

bus.write_byte_data(TEMP_ADDRESS, 0x26, 0xB9) 
bus.write_byte_data(TEMP_ADDRESS, 0x13, 0x07)
bus.write_byte_data(TEMP_ADDRESS, 0x26, 0xB9)


def getInsidetemp():
    data = bus.read_i2c_block_data(TEMP_ADDRESS, 0x00, 6)         
    clear = ((data[4] * 256) + (data[5] & 0xF0))/16        
    tempCelcius = clear / 16
    return tempCelcius



def readluminance():
    global luminance
    bus.write_byte(0x29,0x80|0x12)
    ver = bus.read_byte(0x29)
    if ver == 0x44:
        bus.write_byte(0x29, 0x80|0x00) # 0x00 = ENABLE register
        bus.write_byte(0x29, 0x01|0x02) # 0x01 = Power on, 0x02 RGB sensors enabled
        bus.write_byte(0x29, 0x80|0x14) # Reading results start register 14, LSB then MSB
        data = bus.read_i2c_block_data(0x29, 0)
        clear = data[1] << 8 | data[0]
        red = data[3] << 8 | data[2]
        green = data[5] << 8 | data[4]
        blue = data[7] << 8 | data[6]
        luminance = (-0.32466 * red) + (1.57837 * green) + (-0.73191 * blue)
        return int(luminance)

def offlineDataHandler():
    if os.path.exists(filePath):
        print("Offline data found")
        lines = [line.rstrip('\n') for line in open('sensorDataNoInternet.txt')]
        os.remove(filePath)
        for line in lines:
            line = line.replace("'", "\"") + ""
            print(line)
            data = eval(line)
            if requests.get('https://google.com').ok:
                print('Writing to Firebase Server')
                firHeroesCollectionRef.add(data)
            else:
                with open('sensorDataNoInternet.txt', 'a') as file:
                    print(str(data), file=file)
                
    else:
        print("No data in offline storage")

def handler(signum, frame):
    print()

signal.signal(signal.SIGALRM, handler)

try:

      #Ultrasonic
        GPIO.setmode(GPIO.BOARD)
        PIN_TRIGGER = 33
        PIN_ECHO = 37

        GPIO.setup(PIN_TRIGGER, GPIO.OUT)
        GPIO.setup(PIN_ECHO, GPIO.IN)

        GPIO.output(PIN_TRIGGER, GPIO.LOW)



        print ("Waiting for sensors to settle")

        sleep(5)

          #Main loop
        
        
        while (True):

            
          #GPS
            ser = serial.Serial ("/dev/ttyS0")              #Open port with baud rate
            GPGGA_buffer = 0
            NMEA_buff = 0
            received_data = (str)(ser.readline())                   #read NMEA string received
            GPGGA_data_available = received_data.find(gpgga_info)   #check for NMEA GPGGA string
            if (GPGGA_data_available>0):
                GPGGA_buffer = received_data.split("$GPGGA,",1)[1]  #store data coming after "$GPGGA," string 
                NMEA_buff = (GPGGA_buffer.split(','))               #store comma separated data in buffer
                previousLong = presentLong
                previousLat = presentLat
                previousGpsTime = presentGpsTime
                GPS_Info()
              
              
              #Ultrasonic

            GPIO.output(PIN_TRIGGER, GPIO.HIGH)

            sleep(0.0001)

            GPIO.output(PIN_TRIGGER, GPIO.LOW)

            while GPIO.input(PIN_ECHO)==0:
                pulse_start_time = time.time()
            while GPIO.input(PIN_ECHO)==1:
                pulse_end_time = time.time()

            pulse_duration = pulse_end_time - pulse_start_time
            ultrasonicDistance = round(pulse_duration * 17150, 2)

            rfidTag = 0
# Scan for card
            (status,TagType) = MIFAREReader.MFRC522_Request(MIFAREReader.PICC_REQIDL)
         
            # Get the UID of the card
            (status,uid) = MIFAREReader.MFRC522_Anticoll()
         
            # If we have the UID, continue
            if status == MIFAREReader.MI_OK:
         
              # Print UID
                print("UID: "+str(uid[0])+","+str(uid[1])+","+str(uid[2])+","+str(uid[3]))
                rfidTag = int(str(uid[0])+str(uid[1])+str(uid[2])+str(uid[3]))
                rfidText = "User"
                if (rfidTag == 19285100168):
                    rfidText = "White"
                if (rfidTag == 167783131):
                    rfidText = "Blue"
                if (rfidTag == 13647327):
                    rfidText = "Raghu"
                if (rfidTag == 13649622):
                    rfidText = "Ganesh"
                if (rfidTag == 33343536):
                    rfidText = "Ganesh"
                
                    
                if(prevTag == 0):
                    lockStatus = False
                else:
                    print(prevTag)
                    print(rfidTag)
                    print(lockStatus)
                    print()
                    print()
                    
                    if(prevTag == rfidTag):
                        if(lockStatus):
                            lockStatus = False
                        else:
                            lockStatus = True
                    else:
                        prevTag = rfidTag
                        lockStatus = False
                
                prevTag = rfidTag


          #Gyro and Accelero
            if __name__ == "__main__":
                mpu = mpu6050(0x68)
                outsideTemp = mpu.get_temp()
                accel_data = mpu.get_accel_data()
                gyro_data = mpu.get_gyro_data()
                accel_dataX = accel_data['x']
                accel_dataY = accel_data['y']
                accel_dataZ = accel_data['z']
                gyro_dataX = gyro_data['x']
                gyro_dataY = gyro_data['y']
                gyro_dataZ = gyro_data['z']

          #luminiscance
            luminiscance = readluminance()

          #inside temp
            insideTemp = getInsidetemp()

            print("Distance " ,ultrasonicDistance)
            print("Lat ",presentLat)
            print("Long ",presentLong)
            print("Plat ",previousLat)
            print("PLong ",previousLong)
            print("time ",previousGpsTime)
            print("Ptime ",presentGpsTime)
            print("Lock ",lockStatus) 
            print("Present ",rfidTag)
            print("Prev ", prevTag)
            print("Long ",rfidText)
            print("Otemp ",outsideTemp)
            print("Itemp ",insideTemp)
            print("Lux ",luminance)
            
            if(previousLat == 0):
                previousLat = presentLat
                previousLong = presentLong
                previousGpsTime = presentGpsTime

            rfid = {
                "tag" : rfidTag,
                "name": rfidText,
                "lockStatus" : lockStatus
                }
            
            gpsData = {
                "curLat" : float(presentLat),
                "curLong": float(presentLong),
                "curTime": float(presentGpsTime),
                "prevLat" : float(previousLat),
                "prevLong": float(previousLong),
                "prevTime": float(previousGpsTime)
                }
            
            gyro = {
                "accelX" : accel_dataX ,
                "accelY" : accel_dataY ,
                "accelZ" : accel_dataZ ,
                "gyroX"  : gyro_dataX ,
                "gyroY"  : gyro_dataY ,
                "gyroZ"  : gyro_dataZ ,
                }
            
            light = {
                "lux": luminance
                }
            
            outsideTemp = round(outsideTemp,1)
            insideTemp = round(insideTemp,1)
            
            temp = {
                "outside": int(outsideTemp),
                "inside" : int(insideTemp)
                }
            
            ultrasonic = {
                "distance" : int(ultrasonicDistance)
                }
            
            sensor = {
                "id" : "iCar",
                "timestamp": int(time.time()),
                "rfid": rfid,
                "gps" : gpsData,
                "light" : light,
                "gyro": gyro,
                "temp": temp,
                "ultrasonic": ultrasonic
                }
            
            if requests.get('https://google.com').ok:
                print("Checking is any offline data exists")
                offlineDataHandler()
                print('Writing to Firebase Server')
                firHeroesCollectionRef.add(sensor)
                print('Writing date to file as backup')
                with open('sensorData.txt', 'a') as file:
                    print(str(sensor), file=file)
            else:
                print("No network connection. Now writing to a local file")
                with open('sensorDataNoInternet.txt', 'a') as file:
                    print(str(sensor), file=file)
            #print(sensor)
            print()
            sleep(3)


except KeyboardInterrupt: 
      sys.exit(0)
finally:
      GPIO.cleanup()
      
      


