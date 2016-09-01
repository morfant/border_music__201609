/**
 * Copyright (c) 2009 Andrew Rapp. All rights reserved.
 *
 * This file is part of XBee-Arduino.
 *
 * XBee-Arduino is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * XBee-Arduino is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with XBee-Arduino.  If not, see <http://www.gnu.org/licenses/>.
 */

#include <XBee.h>
/*
 0 : 1st module (0x0A0A)
 1 : 2nd module (0x1B1B)
 2 : 3rd module (0x2C2C)
 3 : CENTER MODULE (0x3D3D)
 */

#define MODULE_NUM 1 // Set this module number



//#define DEBUG
//#define DEBUG_SEND
#define RSPTIME 100
#define STARTUP_DELAY 1000

uint8_t senderID[] = {
  'A', 'B', 'C', 'D'}; // 'D' is Center module.
uint8_t distID[] = {
  1, 2, 3};
uint16_t addr_dest[]= {
  0x0A0A, 0x1B1B, 0x2C2C, 0x3D3D};

XBee xbee = XBee();
HardwareSerial Uart = HardwareSerial(); // For Teensy 2.0 only.


// TX

uint8_t payloadToC[] = { 'o' };

Tx16Request tx = Tx16Request(addr_dest[3], payloadToC, sizeof(payloadToC)); // to center module


// RX
XBeeResponse response = XBeeResponse();
// create reusable response objects for responses we expect to handle 
Rx16Response rx16 = Rx16Response();

// IO pins for Teensy 2.0
int txLed = 11; // 13 for Teensy 3.0
int rxLed = 12; // 16 for Teensy 3.0
int but = 0;


// Variables
uint8_t getSenderID = 0;
uint8_t tmpData = 0;
uint8_t rssi = 0;
boolean reachedGood = false;
boolean justStart = true;
boolean isSolo = false;
boolean butPressed = false;
boolean butReachedGood = false;


// Functions
void flashLed(int pin, int times, int wait) {
  for (int i = 0; i < times; i++) {
    digitalWrite(pin, HIGH);
    delay(wait);
    digitalWrite(pin, LOW);

    if (i + 1 < times) {
      delay(wait);
    }
  }
}


// Setup
void setup() {
  pinMode(txLed, OUTPUT);
  pinMode(rxLed, OUTPUT);
  pinMode(but, INPUT_PULLUP);

  //start USB serial  
  Serial.begin(9600);


  // start serial1 for xbee UART serial
  //    Uart.begin(57600); // Not working
  Uart.begin(58824); // Working with xbee(57600)
  xbee.setSerial(Uart);

  // Start signal
  flashLed(txLed, 1, 50);
  flashLed(rxLed, 1, 50);    
  flashLed(txLed, 1, 50);    

  delay(STARTUP_DELAY); // Is it needed?  
}



// continuously reads packets, looking for RX16 or RX64
void loop() {
  // Trigger networking at first time.
//  if (justStart){
//    xbee.send(tx);
//    justStart = false;
//  }

    /*-------------------------------------------------*/
    /*-------------------- Button ---------------------*/
    /*-------------------------------------------------*/
    
    if (!digitalRead(but) && !butPressed){
      payloadToC[0] = 'R';
      xbee.send(tx);
      
      while(!butReachedGood){
        if (xbee.readPacket(RSPTIME)) {
          TxStatusResponse txStatus = TxStatusResponse();          

          if (xbee.getResponse().getApiId() != TX_STATUS_RESPONSE) {
            xbee.send(tx);
            butReachedGood = false;
            continue;
          }
          
          xbee.getResponse().getZBTxStatusResponse(txStatus);
          if (txStatus.getStatus() != SUCCESS) {
            xbee.send(tx);
            butReachedGood = false;
            continue;
          } else { //SUCCESS case
            butReachedGood = true;
            break;                                
          }
          
        } else {
          //Didn't readPacket at all after RSPTIME.
          // Send again
          xbee.send(tx);
          //                flashLed(txLed, 1, 10);
          butReachedGood = false;
          continue;
        }
      }
      
      butPressed = true;

    } else if(digitalRead(but)) {
      butPressed = false;
    }




    /*-------------------------------------------------*/
    /*-------------------- Receive --------------------*/
    /*-------------------------------------------------*/
    xbee.readPacket();

    // Parse receive packet
    if (xbee.getResponse().isAvailable()) {
#ifdef DEBUG
      Serial.println("Waiting...");                
      Serial.println("--------------------Available");
#endif
      getSenderID = 0;
      rssi = 0;

      if (xbee.getResponse().getApiId() == RX_16_RESPONSE) {

#ifdef DEBUG
        // got something
        Serial.println("--------------------Coming");            
        Serial.println("Serial datas are comming.");            
#endif

        // got a rx packet
        xbee.getResponse().getRx16Response(rx16);
        getSenderID = rx16.getData(0);
        tmpData = rx16.getData(1);
        rssi = rx16.getRssi();
        reachedGood = false;
        
        flashLed(rxLed, 1, 10);
        


#ifdef DEBUG
        Serial.print("senderID: "); 
        Serial.println(char(getSenderID)); //received as Decimal Number
        Serial.print("RSSI: "); 
        Serial.println(rssi);
#endif
      }
      else if(xbee.getResponse().isError()) {
        Serial.println("Error reading packet.  Error code: ");  
        Serial.println(xbee.getResponse().getErrorCode());
        // Do something to resolve error.
      }

      
    }




    /*-------------------------------------------------*/
    /*---------------------- Send ---------------------*/
    /*-------------------------------------------------*/    
    // Send to Center module
    if (getSenderID == 'O' && reachedGood == false){

      // Sending
      payloadToC[0] = 'o';
//      payloadToC[0] = distID[MODULE_NUM]; // one of 1, 2, 3
//      payloadToC[1] = 'o';
      xbee.send(tx);
//      reachedGood = true;
      flashLed(txLed, 1, 10);

      // Check TX Status.
//      reachedGood = false; // Exactly, unknown yet.
      while(!reachedGood) {

        if (xbee.readPacket(RSPTIME)) {
          TxStatusResponse txStatus = TxStatusResponse();          

          if (xbee.getResponse().getApiId() == TX_STATUS_RESPONSE) {
#ifdef DEBUG_SEND                  
            Serial.println("TX STATUS");
#endif                                       
            xbee.getResponse().getZBTxStatusResponse(txStatus);

            if (txStatus.getStatus() == SUCCESS) {
#ifdef DEBUG_SEND                  
              Serial.println("TX STATUS - SUCCESS");         
#endif                                         
              // another msg sendable
#ifdef DEBUG
              Serial.println("--------------------Success ending");            
              Serial.print("Reached Good Confirmed from RX.");
              Serial.print("CYCLE END\n");             
              Serial.print("\n");             
#endif                     
              flashLed(txLed, 1, 10);
              reachedGood = true;
              break;
            }
            else{
              // get response but it is not SUCCESS
#ifdef DEBUG_SEND                  
              Serial.println("TX STATUS - NOT SUCCESS");                    
#endif                                         
              xbee.send(tx);
              reachedGood = false;
              continue;
            }
          }
          else{
#ifdef DEBUG_SEND                  
            Serial.println("NO TX STATUS!!!");
#endif                                       
            xbee.send(tx);
            reachedGood = false;
            continue;
          }
        }
        else{
#ifdef DEBUG_SEND                  
          Serial.println("In else of while loop.");
#endif                                     
          //Didn't readPacket at all after RSPTIME.
          // Send again
          xbee.send(tx);
          //                flashLed(txLed, 1, 10);
          reachedGood = false;
          continue;
        }
      }



    }

//  }
}

