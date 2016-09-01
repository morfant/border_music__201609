import serial
import time
import OSC
from xbee import XBee,ZigBee


#------------------------ OSC ------------------------#
send_addr_SC = 'localhost', 57120 #to Supercollider
#send_addr = '192.168.1.2', 5557
#send_addr = '192.168.1.101', 5557 #EGG
#send_addr = '192.168.0.2', 5555
c = OSC.OSCClient()
c.connect(send_addr_SC)
oscmsg = OSC.OSCMessage()


#------------------------ xbee serial ------------------------#
serial_port = serial.Serial('/dev/tty.usbserial-A104BR3A', 57600)


#------------------------ DEFINE ------------------------#
RX_TIME_LIMIT = 10
# AVG_INTERVAL = 1 
dest_addrs = '\x0a\x0a' # Destination Xbee Address 
curMilliTime = lambda: int(round(time.time() * 1000))

#------------------------ VAR ------------------------#
updateTime = 0




# xbee async callback function
def dataProcess(data):
    # print data 

    dataLetter = ord(data['rf_data'])
    global rssi
    rssi = ord(data['rssi'])
    # print "rssi: %d " % rssi
    # print rssi

    # Button pressed
    global isButtonPressed    
    isButtonPressed = False

    if dataLetter == ord('R'):
        print "Button pressed."
        isButtonPressed = True
        rssi = -1
                
    global xbeeAsyncProcessDone 
    xbeeAsyncProcessDone = True
    # global getNum
    # getNum = getNum + 1
    # global rssiAvg
    # rssiAvg = rssiAvg + rssi
    # # print getNum



#------------------------ Init ------------------------#
# Set xbee asynchronosly
xbee = XBee(serial_port, callback=dataProcess)
global xbeeAsyncProcessDone 
xbeeAsyncProcessDone = False
global isButtonPressed
isButtonPressed = False
# global getNum
# getNum = 0
# global rssiAvg
# rssiAvg = 0



#------------------------ Main loop ------------------------#
while True:
    try:
        time.sleep(0.001)

        # if xbeeAsyncProcessDone is True and getNum >= AVG_INTERVAL:
        if xbeeAsyncProcessDone is True:
            # rssiAvg = rssiAvg/AVG_INTERVAL
            # print "send osc rssi: %d" % rssi
            oscmsg.setAddress("/rssi")
            if isButtonPressed is True:
                oscmsg.setAddress("/but")
            oscmsg.append(rssi)
            c.send(oscmsg)
            oscmsg.clearData()

            xbeeAsyncProcessDone = False
            # getNum = 0
            # rssiAvg = 0

        if curMilliTime() - updateTime > RX_TIME_LIMIT:
            xbee.tx(dest_addr=dest_addrs, data='O')
            updateTime = curMilliTime()
            # print "Send... \n"

    except KeyboardInterrupt:
        break


#------------------------ closing ------------------------#
xbee.halt()
serial_port.close()
c.close()
