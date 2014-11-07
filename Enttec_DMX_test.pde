//Serial------------------------------------
import processing.serial.*;
Serial myPort;  // The serial port
//Serial end--------------------------------

//Define some setting variables
int inComingPort = 12000;
int outGoingPort = 12000;
String outGoingIp = "127.0.0.1";
int serialIndex = 0;
int serialBaud = 9600;
int enttecDMXchannels = 24;
boolean useEnttec = true;
//Setting end

//Define variables-------------------------
int numberOfChannels = 24;
int[] channelValue = new int[600];
boolean[] channelValueHasChanged = new boolean[channelValue.length];
boolean cycleStart;
int counter;
int[] check = { 126, 5, 14, 0, 0, 0 };
boolean error;
//Define variables end----------------------




void setup() {
  size(displayWidth, displayHeight);
  String portName = Serial.list()[serialIndex];
  myPort = new Serial(this, portName, 115000);
   
}


void draw() { 
  background(0);
  dmxCheck();
  drawRects();
}

void dmxCheck() {
  enttecDMXchannels = 512;
  if(useEnttec == true) {
       while (myPort.available() > 0) {
          if (cycleStart == true) {
            if (counter <= 6+enttecDMXchannels) {
              int inBuffer = myPort.read();
              if(counter > 4) { if(channelValue[counter-5] == 126 && channelValue[counter-4] == 5 && channelValue[counter] == 0) { counter = 0; cycleStart = true; } }
                channelValue[counter] = inBuffer;
                counter++;
              
            }
            else {
              cycleStart = false;
            }
          }
          else {
            for(int i = 0; i <= 5; i++) {
              if(channelValue[i] == check[i]) {
                if(error == false) {
                  error = false;
                }
              }
            }
            if(error == false) {
              counter = 0;
              cycleStart = true;    
            }
           } 
      }
  }

}



void drawRects() {
  pushMatrix();
  for(int i = 1; i <= 12; i++) {
    stroke(255, 255, 0);
    fill(255, 255, 50);
    rect(i*100, height/2-100, 70, channelValue[i]*(-1));
    text("ch", i*100+10, height/2-50);
    text(str(i), i*100+30, height/2-50);
    text(":", i*100+45, height/2-50);
    text(str(channelValue[i]), i*100+50, height/2-50);
  }
  translate(-12*100, 255+100);
  for(int i = 13; i <= 24; i++) {
    stroke(255, 255, 0);
    fill(255, 255, 50);
    rect(i*100, height/2-100, 70, channelValue[i]*(-1));
    text("ch", i*100+10, height/2-50);
    text(str(i), i*100+30, height/2-50);
    text(":", i*100+45, height/2-50);
    text(str(channelValue[i]), i*100+50, height/2-50);
  }
  popMatrix();
}

void sendValuesToDmx() {
  for(int i = 0; i < channelValue.length; i++) {
    if(channelValueHasChanged[i]) {
      dmxSend(i, channelValue[i]);
      channelValueHasChanged[i] = false;
    }
  }
}

void dmxSend(int ch, int v) {
  myPort.write(str(ch) + "c" + str(v) + "w");
}
