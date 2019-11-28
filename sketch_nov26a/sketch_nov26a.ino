#include <Arduino.h>
#include <Wire.h>
#include <SoftwareSerial.h>
//#include <EEPROM.h>
//
#define SSCSerial         Serial1
#define cSSC_BAUD        9600
#define cSSC_OUT     12        //Output pin for (SSC32 RX) on BotBoarduino (Yellow)
#define cSSC_IN      13       //Input pin for (SSC32 TX) on BotBoarduino (Blue)
//
SoftwareSerial SSCSerial(cSSC_IN, cSSC_OUT);
//SoftwareSerial SSCSerial(A12, A12);

int moveServo(int servoNum, int moveAmount) {
  // #9 to lower leg, lower the P , to raise leg increase P, #8 move backward descrease P, move forward increase P

  // move amout should be +ve meaning up/forward, and -ve is down/backward for all legs

  int zeroPosition;
  int directionFlip;
  switch (servoNum) {
    case 0:   //BR
      zeroPosition = 1500;
      directionFlip = -1;
      break;
    case 1:   //BR  
      zeroPosition = 1500;
      directionFlip = -1;
      break;
    case 2:   //BR
       zeroPosition = 1550;
       directionFlip = -1;
      break;
    case 8:     //FR  
       zeroPosition = 1500;
       directionFlip = 1;
      break;
    case 9:     //FR 
       zeroPosition = 1500;
       directionFlip = 1;
      break;
    case 10:    //FR  
       zeroPosition = 1640;
       directionFlip = 1;
      break;            
    case 16:  //BL  
       zeroPosition = 1500;
       directionFlip = 1;
      break;
    case 17:  //BL 
       zeroPosition = 1500;
       directionFlip = 1;
      break;
    case 18:  //BL  
       zeroPosition = 1500;
       directionFlip = 1;
      break;        
    case 24:     //FL  
       zeroPosition = 1500;
       directionFlip = -1;
      break;
    case 25:     //FL 
       zeroPosition = 1550;
       directionFlip = -1;
      break;
    case 26:     //FL  
       zeroPosition = 1500;
       directionFlip = -1;
      break;
  }

    int actualServoPosition = zeroPosition + (directionFlip * moveAmount);
    return actualServoPosition;
}

void moveServosToSame(int servoNumbers[], int nServos, int movement, int timeTaken){
  String comdToSend="";
  for (int i = 0; i < nServos; i++){
    comdToSend = comdToSend + " #" + servoNumbers[i] + " P" + moveServo(servoNumbers[i], movement);

//    Serial.println(comdToSend);
  }

  comdToSend = comdToSend + " T" + timeTaken;
  
  Serial.println(comdToSend);
  SSCSerial.println(comdToSend);
}

void setup() {
  // put your setup code here, to run once:
  SSCSerial.begin(cSSC_BAUD);
  Serial.begin(9600);
}

void loop() {
  // put your main code here, to run repeatedly:
  int nMotors = 8;
//  int motorNumbers[nMotors] = {0, 1, 2, 8, 9, 10, 16, 17, 18, 24, 25, 26};
  int motorNumbers[nMotors] = {1, 2, 9, 10, 17, 18, 25, 26};
//  int motorNumbers[nMotors] = {2, 10, 18, 26};

  moveServosToSame(motorNumbers, nMotors, 0, 500);
//  String comdToSend="";
//  for (int i = 0; i < nMotors; i++){
//    comdToSend = comdToSend + " #" + motorNumbers[i] + " P" + moveServo(motorNumbers[i], 0);
//
//    Serial.println(comdToSend);
//  }
//
//  comdToSend = comdToSend + " T500 ";
//  
//  Serial.println(comdToSend);
//  SSCSerial.println(comdToSend);

  delay(3000);
  // second move
  moveServosToSame(motorNumbers, nMotors, 100, 500);
  
//  comdToSend="";
//  for (int i = 0; i < nMotors; i++){
//    comdToSend = comdToSend + " #" + motorNumbers[i] + " P" + moveServo(motorNumbers[i], 100);
//
//    Serial.println(comdToSend);
//  }
//
//  comdToSend = comdToSend + " T500 ";
//  
//  Serial.println(comdToSend);
//  SSCSerial.println(comdToSend);
  
//  SSCSerial.println("#8 P1500 #9 P1500 #10 P1600 T500");
//  Serial.println("#9 P1500 #17 P1500 #25 P1500 #1 P1500 #10 P1400 #18 P1400 #26 P1600 #2 P1600 T500");
//  delay(3000);
//  SSCSerial.println("#8 P1800 #9 P1800 #10 P1600 T500");
//  Serial.println("#9 P1200 #17 P1200 #25 P1800 #1 P1800 #10 P1400 #18 P1400 #26 P1600 #2 P1600 T500");
  delay(1000);
}
