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

int convToRawVals(int servoNum, int moveAmount, int hipOffset) {
  // #9 to lower leg, lower the P , to raise leg increase P, #8 move backward descrease P, move forward increase P

  // move amout should be +ve meaning up/forward, and -ve is down/backward for all legs

  int zeroPosition;
  int directionFlip;
  switch (servoNum) {
    case 0:   //BR
      directionFlip = -1;
      zeroPosition = 1500 + ( hipOffset);
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
       directionFlip = 1;
       zeroPosition = 1500 + ( hipOffset);
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
       directionFlip = 1;
       zeroPosition = 1500 + ( hipOffset);       
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
       directionFlip = -1;
       zeroPosition = 1500 + ( hipOffset);       
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
    comdToSend = comdToSend + " #" + servoNumbers[i] + " P" + convToRawVals(servoNumbers[i], movement,0);
    // Serial.println(comdToSend);
  }

  comdToSend = comdToSend + " T" + timeTaken;
  
  Serial.println(comdToSend);
  SSCSerial.println(comdToSend);
}

String getLegCommand(enum legLocations legNum, enum legPoses poseNum, int timeTaken){  
  // in theory 1000ms == 90deg
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
      kneeAngle = 200;
      ankleAngle = -300;
      break;
    case upMiddle:
      hipAngle = 0;
      kneeAngle = 200;
      ankleAngle = 0;
      break;   
    case upSide: 
      hipAngle = -500;
      kneeAngle = 200;
      ankleAngle = 0;
      break;              
  }
  String comdToSend="";
  switch (legNum) {
    case frontLeft:
      comdToSend = comdToSend+" #24P"+ convToRawVals(24,hipAngle,0) + " #25P" + convToRawVals(25,kneeAngle,0) + " #26P" + convToRawVals(26,ankleAngle,0);
      break;
    case frontRight:
      comdToSend = comdToSend+" #8P"+  convToRawVals(8,hipAngle,0) + " #9P" +   convToRawVals(9,kneeAngle,0) + " #10P" +  convToRawVals(10,ankleAngle,0);
      break;
    case backLeft: 
      comdToSend =comdToSend+" #16P"+ convToRawVals(16,hipAngle,0) + " #17P" + convToRawVals(17,kneeAngle,0) + " #18P" + convToRawVals(18,ankleAngle,0);
      break;
    case backRight: 
      comdToSend =comdToSend+" #0P"+  convToRawVals(0,hipAngle,0) + " #1P" +   convToRawVals(1,kneeAngle,0) + " #2P" +   convToRawVals(2,ankleAngle,0);
      break;      
  }
  comdToSend = comdToSend + "T" + timeTaken;

  return comdToSend;
  
}

String getLegCommandHipRotate(enum legLocations legNum, enum legPoses poseNum, int hipAngleOffset, int timeTaken){  
  // in theory 1000ms == 90deg
  int hipPwmOffset = float(hipAngleOffset)*float(float(50)/float(4.5)); //note this is int maths, not nice float, bit of a bodge. NB max int val ~32,000
  
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
      kneeAngle = 200;
      ankleAngle = -300;
      break;
    case upMiddle:
      hipAngle = 0;
      kneeAngle = 200;
      ankleAngle = 0;
      break;   
    case upSide: 
      hipAngle = -500;
      kneeAngle = 200;
      ankleAngle = 0;
      break;              
  }
  String comdToSend="";
  switch (legNum) {
    case frontLeft:
      comdToSend = comdToSend+" #24P"+ convToRawVals(24,hipAngle,hipPwmOffset) + " #25P" + convToRawVals(25,kneeAngle,0) + " #26P" + convToRawVals(26,ankleAngle,0);
      break;
    case frontRight:
      comdToSend = comdToSend+" #8P"+  convToRawVals(8,hipAngle,hipPwmOffset) + " #9P" +   convToRawVals(9,kneeAngle,0) + " #10P" +  convToRawVals(10,ankleAngle,0);
      break;
    case backLeft: 
      comdToSend =comdToSend+" #16P"+ convToRawVals(16,hipAngle,hipPwmOffset) + " #17P" + convToRawVals(17,kneeAngle,0) + " #18P" + convToRawVals(18,ankleAngle,0);
      break;
    case backRight: 
      comdToSend =comdToSend+" #0P"+  convToRawVals(0,hipAngle,hipPwmOffset) + " #1P" +   convToRawVals(1,kneeAngle,0) + " #2P" +   convToRawVals(2,ankleAngle,0);
      break;      
  }
  comdToSend = comdToSend + "T" + timeTaken;

  return comdToSend;
  
}

void startPosition(){
  SSCSerial.println("#P");
  
}

/** Note, timeToTake is not overall time, but time per leg command */
void acheivePose(String poseName, int timeToTake, int timeAllowance, bool responseOn)
{
  if(poseName.indexOf("rotateHip") != -1) // NB for extended pose only atm 
  // Should be: poseName == "+xx_BR_rotateHip\n" //will starting with xx cause type errors?
  {
    String numberAsString = poseName.substring(0,3); //number will be in deg, converted to pwm in getLegCommandHipRotate
//    Serial.println(numberAsString);
    int number = numberAsString.toInt();

    int timeToTakeTapping =1;
    
    enum legLocations selectedLeg;
    enum legPoses upPose;
    enum legPoses downPose;
    if(poseName.indexOf("BR") != -1){ //probably inef. use single func call and var assg instead...
      selectedLeg = backRight;
      upPose = upSide;
      downPose = side;
    } 
    else if (poseName.indexOf("BLm") != -1)
    {
      selectedLeg = backLeft;
      upPose = upMiddle;
      downPose = middle;
    }
    else if (poseName.indexOf("BLs") != -1)
    {
      selectedLeg = backLeft;
      upPose = upSide;
      downPose = side;

      timeToTakeTapping = 700;
      String cmd = getLegCommand(selectedLeg, upPose, timeToTakeTapping);
      /* Serial.println(cmd);*/SSCSerial.println(cmd);
      delay(timeToTake + timeAllowance);
      
      cmd = getLegCommandHipRotate(selectedLeg, upPose, number, timeToTakeTapping);
      /* Serial.println(cmd);*/SSCSerial.println(cmd);
      delay(timeToTake + timeAllowance);
    } 
    else if (poseName.indexOf("FR") != -1)
    {
      selectedLeg = frontRight;
      upPose = upExtend;
      downPose = extended;
      timeToTakeTapping = 700;
      String cmd = getLegCommand(selectedLeg, upPose, timeToTakeTapping);
      /* Serial.println(cmd);*/SSCSerial.println(cmd);
      delay(timeToTake + timeAllowance);
      
      cmd = getLegCommandHipRotate(selectedLeg, upPose, number, timeToTakeTapping);
      /* Serial.println(cmd);*/SSCSerial.println(cmd);
      delay(timeToTake + timeAllowance);
      
    } 
    else if (poseName.indexOf("FLm") != -1)
    {
      selectedLeg = frontLeft;
      upPose = upMiddle;
      downPose = middle;
    }
    else if (poseName.indexOf("FLe") != -1)
    {
      selectedLeg = frontLeft;
      upPose = upExtend;
      downPose = extended;

      timeToTakeTapping = 700;
      String cmd = getLegCommand(selectedLeg, upPose, timeToTakeTapping);
      /* Serial.println(cmd);*/SSCSerial.println(cmd);
      delay(timeToTake + timeAllowance);
      
      cmd = getLegCommandHipRotate(selectedLeg, upPose, number, timeToTakeTapping);
      /* Serial.println(cmd);*/SSCSerial.println(cmd);
      delay(timeToTake + timeAllowance);
    }
//     else if (poseName.indexOf("allf") != -1){
//      selectedLeg = frontLeft;
//      upPose = upMiddle;
//      downPose = middle;
//      String cmd = getLegCommandHipRotate(frontRight, upPose, number, timeToTakeTapping);
//      cmd = cmd + getLegCommand(backLeft, middle, 1000);
//    } 
    else{
      /* Serial.println(cmd);*/SSCSerial.println("ERROR Leg not identified in command");
    }

    String cmd = getLegCommandHipRotate(selectedLeg, downPose, number, timeToTakeTapping);
    /* Serial.println(cmd);*/SSCSerial.println(cmd);
    delay(timeToTake + timeAllowance);
    if (responseOn) Serial.println("Acheived");

  }
  else if(poseName == "BR_leg_forward\n")
  {
//    /* Acheive diagram 1 */
//    String cmd =getLegCommand(frontLeft, middle, 1000);
//    cmd = cmd + getLegCommand(backLeft, middle, 1000);
//    cmd = cmd + getLegCommand(frontRight, side, 1000);
//    cmd = cmd + getLegCommand(backRight, side, 1000);
//    /* Serial.println(cmd);*/ SSCSerial.println(cmd);    
//    delay(timeToTake + timeAllowance); 
//    if (responseOn) Serial.println("Acheived");

    String cmd = getLegCommand(backRight, upExtend, timeToTake);
    /* Serial.println(cmd);*/SSCSerial.println(cmd);
    delay(timeToTake + timeAllowance);  
    
    cmd = getLegCommand(backRight, upSide, timeToTake);
    /* Serial.println(cmd);*/SSCSerial.println(cmd);
    delay(timeToTake + timeAllowance);
    
    cmd = getLegCommand(backRight, side, timeToTake);
    /* Serial.println(cmd);*/SSCSerial.println(cmd);
    delay(timeToTake + timeAllowance); 
    if (responseOn) Serial.println("Acheived");
  } 
  else if(poseName == "BR_leg_middle\n")
  {
//    /* Acheive diagram 1 */
//    String cmd =getLegCommand(frontLeft, middle, 1000);
//    cmd = cmd + getLegCommand(backLeft, middle, 1000);
//    cmd = cmd + getLegCommand(frontRight, side, 1000);
//    cmd = cmd + getLegCommand(backRight, side, 1000);
//    /* Serial.println(cmd);*/ SSCSerial.println(cmd);    
//    delay(timeToTake + timeAllowance); 
//    if (responseOn) Serial.println("Acheived");

    String cmd = getLegCommand(backRight, upExtend, timeToTake);
    /* Serial.println(cmd);*/SSCSerial.println(cmd);
    delay(timeToTake + timeAllowance);  
    
    cmd = getLegCommand(backRight, upMiddle, timeToTake);
    /* Serial.println(cmd);*/SSCSerial.println(cmd);
    delay(timeToTake + timeAllowance);
    
    cmd = getLegCommand(backRight, middle, timeToTake);
    /* Serial.println(cmd);*/SSCSerial.println(cmd);
    delay(timeToTake + timeAllowance); 
    if (responseOn) Serial.println("Acheived");
  }
  else if (poseName == "start_pose\n")
  {
        /* Acheive diagram 1 */
    String cmd =getLegCommand(frontLeft, middle, 1000);
    cmd = cmd + getLegCommand(backLeft, middle, 1000);
    cmd = cmd + getLegCommand(frontRight, side, 1000);
    cmd = cmd + getLegCommand(backRight, side, 1000);
    /* Serial.println(cmd);*/ SSCSerial.println(cmd);    
    delay(timeToTake + timeAllowance); 
    if (responseOn) Serial.println("Acheived");
  }
  else if (poseName == "FR_leg_forward\n")
  {
    /*Acheive diagram 2 position*/
    String cmd = getLegCommand(frontRight, upSide, timeToTake);
    /* Serial.println(cmd);*/ SSCSerial.println(cmd);
    delay(timeToTake + timeAllowance);
    
    cmd = getLegCommand(frontRight, upExtend, timeToTake);
    /* Serial.println(cmd);*/SSCSerial.println(cmd);
    delay(timeToTake + timeAllowance);
    
    cmd = getLegCommand(frontRight, extended, timeToTake);
    /* Serial.println(cmd);*/SSCSerial.println(cmd);
    delay(timeToTake + timeAllowance);
    if (responseOn) Serial.println("Acheived");
  } 
  else if (poseName == "FR_leg_forward_hover\n")
  {
    /*Acheive diagram 2 position*/
    String cmd = getLegCommand(frontRight, upSide, timeToTake);
    /* Serial.println(cmd);*/ SSCSerial.println(cmd);
    delay(timeToTake + timeAllowance);
    
    cmd = getLegCommand(frontRight, upExtend, timeToTake);
    /* Serial.println(cmd);*/SSCSerial.println(cmd);
    delay(timeToTake + timeAllowance);
    if (responseOn) Serial.println("Acheived");
  } 
  else if (poseName == "FR_leg_forward_tap\n")
  {
    /*Acheive diagram 2 position*/
//    String cmd = getLegCommand(frontRight, upSide, timeToTake);
//    /* Serial.println(cmd);*/ SSCSerial.println(cmd);
//    delay(timeToTake + timeAllowance);
    
    String cmd = getLegCommand(frontRight, upExtend, timeToTake);
    /* Serial.println(cmd);*/SSCSerial.println(cmd);
    delay(timeToTake + timeAllowance);
    
    cmd = getLegCommand(frontRight, extended, timeToTake);
    /* Serial.println(cmd);*/SSCSerial.println(cmd);
    delay(timeToTake + timeAllowance);
    if (responseOn) Serial.println("Acheived");
  } 
    else if (poseName == "FR_leg_side\n")
  {
    /*Acheive diagram 2 position*/
    String cmd = getLegCommand(frontRight, upExtend, timeToTake);
    /* Serial.println(cmd);*/ SSCSerial.println(cmd);
    delay(timeToTake + timeAllowance);
    
    cmd = getLegCommand(frontRight, upSide, timeToTake);
    /* Serial.println(cmd);*/SSCSerial.println(cmd);
    delay(timeToTake + timeAllowance);
    
    cmd = getLegCommand(frontRight, side, timeToTake);
    /* Serial.println(cmd);*/SSCSerial.println(cmd);
    delay(timeToTake + timeAllowance);
    if (responseOn) Serial.println("Acheived");
  } 
  else if (poseName == "FRf_body_forward\n")
  {
    /* Acheive diagram 3 position*/
    String cmd =       getLegCommand(frontRight, middle, timeToTake);
    cmd = cmd + getLegCommand(frontLeft, side, timeToTake);
    cmd = cmd + getLegCommand(backRight, middle, timeToTake);
    cmd = cmd + getLegCommand(backLeft, extended, timeToTake);
   /* Serial.println(cmd);*/SSCSerial.println(cmd);
    delay(timeToTake + timeAllowance);
    if (responseOn) Serial.println("Acheived");
  } 
  else if (poseName == "BL_leg_forward\n")
  {
    /* diagram 4 */ 
    String cmd = getLegCommand(backLeft, upExtend, timeToTake);
    /* Serial.println(cmd);*/SSCSerial.println(cmd);
    delay(timeToTake + timeAllowance);  
    
    cmd = getLegCommand(backLeft, upSide, timeToTake);
    /* Serial.println(cmd);*/SSCSerial.println(cmd);
    delay(timeToTake + timeAllowance);
    
    cmd = getLegCommand(backLeft, side, timeToTake);
    /* Serial.println(cmd);*/SSCSerial.println(cmd);
    delay(timeToTake + timeAllowance); 
    if (responseOn) Serial.println("Acheived");
  } 
  else if (poseName == "FL_leg_forward\n")
  {
    /* 5 */
    String cmd = getLegCommand(frontLeft, upSide, timeToTake);
    /* Serial.println(cmd);*/SSCSerial.println(cmd);
    delay(timeToTake + timeAllowance);
    
    cmd = getLegCommand(frontLeft, upExtend, timeToTake);
    /* Serial.println(cmd);*/SSCSerial.println(cmd);
    delay(timeToTake + timeAllowance);
    
    cmd = getLegCommand(frontLeft, extended, timeToTake);
    /* Serial.println(cmd);*/SSCSerial.println(cmd);
    delay(timeToTake + timeAllowance);  
    if (responseOn) Serial.println("Acheived");
  } 
  else if (poseName == "FLf_body_forward\n")
  {
    /* 6 */
    String cmd =getLegCommand(frontRight, side, timeToTake);
    cmd = cmd + getLegCommand(frontLeft, middle, timeToTake);
    cmd = cmd + getLegCommand(backRight, extended, timeToTake);
    cmd = cmd + getLegCommand(backLeft, middle, timeToTake);
    /* Serial.println(cmd);*/SSCSerial.println(cmd);
    delay(timeToTake + timeAllowance);
    if (responseOn) Serial.println("Acheived");
  }
  else if (poseName == "all_middle\n")
  {
    /* 6 */
    String cmd =getLegCommand(frontRight, middle, timeToTake);
    cmd = cmd + getLegCommand(frontLeft, middle, timeToTake);
    cmd = cmd + getLegCommand(backRight, middle, timeToTake);
    cmd = cmd + getLegCommand(backLeft, middle, timeToTake);
    /* Serial.println(cmd);*/SSCSerial.println(cmd);
    delay(timeToTake + timeAllowance);
    if (responseOn) Serial.println("Acheived");
  }
  else{
    String errorMsg = "Error unknown pose name: " + poseName;
    if (responseOn) Serial.println(errorMsg);
  }
}

/********************************
 * SETUP 
 ********************************/
void setup() {
  SSCSerial.begin(cSSC_BAUD);
  Serial.begin(9600);

  /* Acheive diagram 1 */
  acheivePose("Pose 01\n", 1000, 1500, false);

}

/********************************
 * MAIN 
 ********************************/
void loop() {

  int timeToTake = 700;
  int timeAllowance = 200;
  
//  acheivePose("Pose 01\n", timeToTake, timeAllowance, false);
  
  while(!Serial.available()){} // waiting
  String msg = Serial.readString();


  
//  Serial.println(msg);
  acheivePose(msg, timeToTake, timeAllowance, true);

//  if (msg == "hello world 2\n")
//  {
//      /*Acheive diagram 2 position*/
//    String cmd = getLegCommand(frontRight, upSide, timeToTake);
//   /* Serial.println(cmd);*/ SSCSerial.println(cmd);
//    delay(timeToTake + timeAllowance);
//    
//    cmd = getLegCommand(frontRight, upExtend, timeToTake);
//   /* Serial.println(cmd);*/SSCSerial.println(cmd);
//    delay(timeToTake + timeAllowance);
//  
//    cmd = getLegCommand(frontRight, extended, timeToTake);
//   /* Serial.println(cmd);*/SSCSerial.println(cmd);
//    delay(timeToTake + timeAllowance);
//  } 
//  else 
//  {
//    /* 5 */
//    String cmd = getLegCommand(frontLeft, upSide, timeToTake);
//   /* Serial.println(cmd);*/SSCSerial.println(cmd);
//    delay(timeToTake + timeAllowance);
//  
//    cmd = getLegCommand(frontLeft, upExtend, timeToTake);
//   /* Serial.println(cmd);*/SSCSerial.println(cmd);
//    delay(timeToTake + timeAllowance);
//  
//    cmd = getLegCommand(frontLeft, extended, timeToTake);
//   /* Serial.println(cmd);*/SSCSerial.println(cmd);
//    delay(timeToTake + timeAllowance);      
//  }
    
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

  
//        /* Acheive diagram 3 position*/
//      String cmd =       getLegCommand(frontRight, middle, timeToTake);
//      cmd = cmd + getLegCommand(frontLeft, side, timeToTake);
//      cmd = cmd + getLegCommand(backRight, middle, timeToTake);
//      cmd = cmd + getLegCommand(backLeft, extended, timeToTake);
//     /* Serial.println(cmd);*/SSCSerial.println(cmd);
//      delay(timeToTake + timeAllowance);


//  /* diagram 4 */ 
//  cmd = getLegCommand(backLeft, upExtend, timeToTake);
// /* Serial.println(cmd);*/SSCSerial.println(cmd);
//  delay(timeToTake + timeAllowance);  
//
//  cmd = getLegCommand(backLeft, upSide, timeToTake);
// /* Serial.println(cmd);*/SSCSerial.println(cmd);
//  delay(timeToTake + timeAllowance);
//
//  cmd = getLegCommand(backLeft, side, timeToTake);
// /* Serial.println(cmd);*/SSCSerial.println(cmd);
//  delay(timeToTake + timeAllowance);
//
//  /* 5 */
//  cmd = getLegCommand(frontLeft, upSide, timeToTake);
// /* Serial.println(cmd);*/SSCSerial.println(cmd);
//  delay(timeToTake + timeAllowance);
//
//  cmd = getLegCommand(frontLeft, upExtend, timeToTake);
// /* Serial.println(cmd);*/SSCSerial.println(cmd);
//  delay(timeToTake + timeAllowance);
//
//  cmd = getLegCommand(frontLeft, extended, timeToTake);
// /* Serial.println(cmd);*/SSCSerial.println(cmd);
//  delay(timeToTake + timeAllowance);
//
//  /* 6 */
//  cmd =       getLegCommand(frontRight, side, timeToTake);
//  cmd = cmd + getLegCommand(frontLeft, middle, timeToTake);
//  cmd = cmd + getLegCommand(backRight, extended, timeToTake);
//  cmd = cmd + getLegCommand(backLeft, middle, timeToTake);
// /* Serial.println(cmd);*/SSCSerial.println(cmd);
//  delay(timeToTake + timeAllowance);
//
//  /* 1 */
//  cmd = getLegCommand(backRight, upExtend, timeToTake);
// /* Serial.println(cmd);*/SSCSerial.println(cmd);
//  delay(timeToTake + timeAllowance);
//
//  cmd = getLegCommand(backRight, upSide, timeToTake);
// /* Serial.println(cmd);*/SSCSerial.println(cmd);
//  delay(timeToTake + timeAllowance);
//
//  cmd = getLegCommand(backRight, side, timeToTake);
// /* Serial.println(cmd);*/SSCSerial.println(cmd);
//  delay(timeToTake + timeAllowance);
//  
  
//  SSCSerial.println("#8 P1500 #9 P1500 #10 P1600 T500");
//  Serial.println("#9 P1500 #17 P1500 #25 P1500 #1 P1500 #10 P1400 #18 P1400 #26 P1600 #2 P1600 T500");
//  delay(3000);
//  SSCSerial.println("#8 P1800 #9 P1800 #10 P1600 T500");
//  Serial.println("#9 P1200 #17 P1200 #25 P1800 #1 P1800 #10 P1400 #18 P1400 #26 P1600 #2 P1600 T500");
  
}
