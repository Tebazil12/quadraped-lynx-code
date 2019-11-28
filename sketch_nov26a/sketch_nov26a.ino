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

enum legLocations {frontLeft, 
                  frontRight,
                  backLeft, 
                  backRight};
enum legPoses {extended, 
               middle,
               side,
               upMiddle,
               upExtend,
               upSide};                  

//enum legStates newState; 

SoftwareSerial SSCSerial(cSSC_IN, cSSC_OUT);
//SoftwareSerial SSCSerial(A12, A12);

                 

/********************************
 * FUNCTIONS 
 ********************************/

int convToRawVals(int servoNum, int moveAmount) {
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
    comdToSend = comdToSend + " #" + servoNumbers[i] + " P" + convToRawVals(servoNumbers[i], movement);
    // Serial.println(comdToSend);
  }

  comdToSend = comdToSend + " T" + timeTaken;
  
  Serial.println(comdToSend);
  SSCSerial.println(comdToSend);
}

String getLegCommand(enum legLocations legNum, enum legPoses poseNum, int timeTaken){  
  int hipAngle;
  int kneeAngle;
  int ankleAngle;
  switch (poseNum) {
    case extended:
      hipAngle = 100;
      kneeAngle = -100;
      ankleAngle = -300;
      break;
    case middle:
      hipAngle = 0;
      kneeAngle = 0;
      ankleAngle = 0;
      break;
    case side: 
      hipAngle = -500;
      kneeAngle = 0;
      ankleAngle = 0;
      break; 
    case upExtend:
      hipAngle = 100;
      kneeAngle = 100;
      ankleAngle = -300;
      break;
    case upMiddle:
      hipAngle = 0;
      kneeAngle = 100;
      ankleAngle = 0;
      break;   
    case upSide: 
      hipAngle = -500;
      kneeAngle = 100;
      ankleAngle = 0;
      break;              
  }
  String comdToSend="";
  switch (legNum) {
    case frontLeft:
      comdToSend = comdToSend+" #24P"+ convToRawVals(24,hipAngle) + " #25P" + convToRawVals(25,kneeAngle) + " #26P" + convToRawVals(26,ankleAngle);
      break;
    case frontRight:
      comdToSend = comdToSend+" #8P"+  convToRawVals(8,hipAngle) + " #9P" +   convToRawVals(9,kneeAngle) + " #10P" +  convToRawVals(10,ankleAngle);
      break;
    case backLeft: 
      comdToSend =comdToSend+" #16P"+ convToRawVals(16,hipAngle) + " #17P" + convToRawVals(17,kneeAngle) + " #18P" + convToRawVals(18,ankleAngle);
      break;
    case backRight: 
      comdToSend =comdToSend+" #0P"+  convToRawVals(0,hipAngle) + " #1P" +   convToRawVals(1,kneeAngle) + " #2P" +   convToRawVals(2,ankleAngle);
      break;      
  }
  comdToSend = comdToSend + "T" + timeTaken;

  return comdToSend;
  
}

void startPosition(){
  SSCSerial.println("#P");
  
}

/********************************
 * SETUP 
 ********************************/
void setup() {
  // put your setup code here, to run once:
  SSCSerial.begin(cSSC_BAUD);
  Serial.begin(9600);

  /* Acheive diagram 1 */
  String cmd =getLegCommand(frontLeft, middle, 1000);
  cmd = cmd + getLegCommand(backLeft, middle, 1000);
  cmd = cmd + getLegCommand(frontRight, side, 1000);
  cmd = cmd + getLegCommand(backRight, side, 1000);
  Serial.println(cmd);
  SSCSerial.println(cmd);
  delay(2500);

}

/********************************
 * MAIN 
 ********************************/
void loop() {

//  int nMotors = 4;
//  int motorNumbers[nMotors] = {0, 1, 2, 8, 9, 10, 16, 17, 18, 24, 25, 26};
//  int motorNumbers[nMotors] = {1, 2, 9, 10, 17, 18, 25, 26};
//  int motorNumbers[nMotors] = {0, 8, 16, 24};

//  moveServosToSame(motorNumbers, nMotors, 0, 500);
//  delay(2000);
//  moveServosToSame(motorNumbers, nMotors, 300, 500);
//  delay(1000);
//  moveServosToSame(motorNumbers, nMotors, 0, 500);
//  delay(2000);
//  moveServosToSame(motorNumbers, nMotors, -500, 500); //-500 is good position for inermost servo for legs going to side (first part of stepping)
//  delay(1000);

//  enum legLocations legToMove = frontLeft;
  int timeToTake = 1000;
  
  /*Acheive diagram 2 position*/
  String cmd = getLegCommand(frontRight, upSide, timeToTake);
  Serial.println(cmd); SSCSerial.println(cmd);
  delay(timeToTake + 1000);
  
  cmd = getLegCommand(frontRight, upExtend, timeToTake);
  Serial.println(cmd);SSCSerial.println(cmd);
  delay(timeToTake + 1000);

  cmd = getLegCommand(frontRight, extended, timeToTake);
  Serial.println(cmd);SSCSerial.println(cmd);
  delay(timeToTake + 1000);
  
  /* Acheive diagram 3 position*/
  cmd =       getLegCommand(frontRight, middle, timeToTake);
  cmd = cmd + getLegCommand(frontLeft, side, timeToTake);
  cmd = cmd + getLegCommand(backRight, middle, timeToTake);
  cmd = cmd + getLegCommand(backLeft, extended, timeToTake);
  Serial.println(cmd);SSCSerial.println(cmd);
  delay(timeToTake + 1000);

  /* diagram 4 */ 
  cmd = getLegCommand(backLeft, upExtend, timeToTake);
  Serial.println(cmd);SSCSerial.println(cmd);
  delay(timeToTake + 1000);  

  cmd = getLegCommand(backLeft, upSide, timeToTake);
  Serial.println(cmd);SSCSerial.println(cmd);
  delay(timeToTake + 1000);

  cmd = getLegCommand(backLeft, side, timeToTake);
  Serial.println(cmd);SSCSerial.println(cmd);
  delay(timeToTake + 1000);

  /* 5 */
  cmd = getLegCommand(frontLeft, upSide, timeToTake);
  Serial.println(cmd);SSCSerial.println(cmd);
  delay(timeToTake + 1000);

  cmd = getLegCommand(frontLeft, upExtend, timeToTake);
  Serial.println(cmd);SSCSerial.println(cmd);
  delay(timeToTake + 1000);

  cmd = getLegCommand(frontLeft, extended, timeToTake);
  Serial.println(cmd);SSCSerial.println(cmd);
  delay(timeToTake + 1000);

  /* 6 */
  cmd =       getLegCommand(frontRight, side, timeToTake);
  cmd = cmd + getLegCommand(frontLeft, middle, timeToTake);
  cmd = cmd + getLegCommand(backRight, extended, timeToTake);
  cmd = cmd + getLegCommand(backLeft, middle, timeToTake);
  Serial.println(cmd);SSCSerial.println(cmd);
  delay(timeToTake + 1000);

  /* 1 */
  cmd = getLegCommand(backRight, upExtened, timeToTake);
  Serial.println(cmd);SSCSerial.println(cmd);
  delay(timeToTake + 1000);

  cmd = getLegCommand(backRight, upSide, timeToTake);
  Serial.println(cmd);SSCSerial.println(cmd);
  delay(timeToTake + 1000);

  cmd = getLegCommand(backRight, side, timeToTake);
  Serial.println(cmd);SSCSerial.println(cmd);
  delay(timeToTake + 1000);
  
  
//  SSCSerial.println("#8 P1500 #9 P1500 #10 P1600 T500");
//  Serial.println("#9 P1500 #17 P1500 #25 P1500 #1 P1500 #10 P1400 #18 P1400 #26 P1600 #2 P1600 T500");
//  delay(3000);
//  SSCSerial.println("#8 P1800 #9 P1800 #10 P1600 T500");
//  Serial.println("#9 P1200 #17 P1200 #25 P1800 #1 P1800 #10 P1400 #18 P1400 #26 P1600 #2 P1600 T500");
  
}
