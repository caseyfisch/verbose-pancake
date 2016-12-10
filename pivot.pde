import android.content.Context;
import android.hardware.Sensor;
import android.hardware.SensorManager;
import android.hardware.SensorEvent;
import android.hardware.SensorEventListener;

import java.util.ArrayList;
import java.util.Collections;

Context context;
SensorManager manager;
Sensor accelerometer;
Sensor proximitySensor;
AccelerometerListener accListener;
ProximitySensorListener proxListener;
float ax, ay, az;

// Variables to manage phases
boolean onFirstPhase, onSecondPhase;
boolean printed;
int countDownTimerWait = 0;

boolean showX, showCheck;
int showXCount = 0, showCheckCount = 0;


private class Target {
  int target = 0;
  int action = 0;
  
  String toString() {
    return "(" + target + ", " + action + ")"; 
  }
}

int trialCount = 5; //this will be set higher for the bakeoff
int trialIndex = 0;
ArrayList<Target> targets = new ArrayList<Target>();

int startTime = 0; // time starts when the first click is captured
int finishTime = 0; //records the time of the final click
boolean userDone = false;

boolean tiltLeft, tiltRight, tiltBack, tiltForward;

void setup() {
  fullScreen();
  frameRate(60);

  context = getActivity();
  
  // Set up sensors and listeners.
  manager = (SensorManager) context.getSystemService(Context.SENSOR_SERVICE);
  accelerometer = manager.getDefaultSensor(Sensor.TYPE_ACCELEROMETER);
  accListener = new AccelerometerListener();
  manager.registerListener(accListener, accelerometer, SensorManager.SENSOR_DELAY_GAME);
  
  proximitySensor = manager.getDefaultSensor(Sensor.TYPE_PROXIMITY);
  proxListener = new ProximitySensorListener();
  manager.registerListener(proxListener, proximitySensor, SensorManager.SENSOR_DELAY_FASTEST);
  
  textFont(createFont("Arial", 60));
  textAlign(CENTER);
  
  // Generate targets.
  for (int i=0; i<trialCount; i++) {  //don't change this!
    Target t = new Target();
    t.target = ((int)random(1000)) % 4;
    t.action = ((int)random(1000)) % 2;
    targets.add(t);
  }
  Collections.shuffle(targets); // randomize the order of the button;
  println(targets);
  
  // Start on first phase.
  onFirstPhase = true;
  onSecondPhase = false;
  printed = false;
}

void drawArrow(int cx, int cy, int len, float angle){
  pushMatrix();
  translate(cx, cy);
  rotate(radians(angle));
  line(0,0,len, 0);
  line(len, 0, len - 8, -8);
  line(len, 0, len - 8, 8);
  popMatrix();
}

void drawTargets() {
  
  strokeWeight(8);
  
  fill(65);
  textAlign(CENTER);
  text("Tilt Away", width / 2, 60);
  stroke(65);
  drawArrow(width / 2, height / 2 - height / 6, width / 4, 270);
  
  
  fill(65);
  textAlign(LEFT);
  text("Tilt", 10, height / 2 - 30);
  text("Left", 10, height / 2 + 60);
  stroke(65);
  drawArrow(width / 2 - 50, height / 2, width / 4, 180);
  
  
  fill(65);
  textAlign(RIGHT);
  text("Tilt", width - 10, height / 2 - 30);
  text("Right", width - 10, height / 2 + 60);
  stroke(65);
  drawArrow(width / 2 + 50, height / 2, width / 4, 0);

  fill(65);
  textAlign(CENTER);
  text("Tilt Towards", width / 2, height - 30);
  stroke(65);
  drawArrow(width / 2, height / 2 + height / 6, width / 4, 90);
  
  noStroke();
  textAlign(LEFT);
}

void drawActions() {
  int act = targets.get(trialIndex).action;
  textAlign(CENTER);
  if (act == 0) {
    if (num0s == 1) fill(#C4FF58);
    text("Fill 1 circle", width / 2, 60); 
  } else {
    if (num0s == 2) fill(#C4FF58);
    text("Fill 2 circles", width / 2, 60); 
  }
  noStroke();
  int diam = width / 4;
  
  if (num0s == 0) {
    fill(255);
    ellipse(width / 2 - diam, height / 2, diam, diam); 
    ellipse(width / 2 + diam, height / 2, diam, diam); 
  } else if (num0s == 1) {
    fill(#C4FF58);
    ellipse(width / 2 - diam, height / 2, diam, diam); 
    fill(255);
    ellipse(width / 2 + diam, height / 2, diam, diam); 
    
  } else if (num0s == 2) {
    fill(#C4FF58);
    ellipse(width / 2 - diam, height / 2, diam, diam); 
    ellipse(width / 2 + diam, height / 2, diam, diam);        
  }
  
}

void draw() {
  background(0);
  if (trialIndex >= targets.size()) {
    userDone = true;
    return;
  }
  
  countDownTimerWait -= 1;
  
  if (startClock) {
    timeCount += 1; 
  }
  
  if (showCheck) {
    showCheckCount += 1;
    textAlign(CENTER);
    fill(255);
    text("Good!", width / 2, height / 4);
    if (showCheckCount > 20) {
      showCheck = false; 
      showCheckCount = 0;
    }
  } else if (showX) {
    showXCount += 1;
    textAlign(CENTER);
    fill(255);
    text("Wrong :(", width / 2, height / 4);
    if (showXCount > 20) {
      showX = false; 
      showXCount = 0;
    }
  }
  
  int tar = targets.get(trialIndex).target;
  
  if (onFirstPhase) {
    drawTargets();
    
    if (tar == 0) {
      //text("BACK", 10, 240);
      fill(#75FCC5);
      textAlign(CENTER);
      text("Tilt Away", width / 2, 60);
      stroke(#75FCC5);
      drawArrow(width / 2, height / 2 - height / 6, width / 4, 270);
      
    } else if (tar == 1) {
      //text("FRONT", 10, 240);
      fill(#71D8FF);
      textAlign(CENTER);
      text("Tilt Towards", width / 2, height - 30);
      stroke(#71D8FF);
      drawArrow(width / 2, height / 2 + height / 6, width / 4, 90);
    } else if (tar == 2) {
      //text("RIGHT", 10, 240);
      fill(#FFA25A);
      textAlign(RIGHT);
      text("Tilt", width - 10, height / 2 - 30);
      text("Right", width - 10, height / 2 + 60);
      stroke(#FFA25A);
      drawArrow(width / 2 + 50, height / 2, width / 4, 0);
    } else if (tar == 3) {
      //text("LEFT", 10, 240);
      fill(#FF5ADC);
      textAlign(LEFT);
      text("Tilt", 10, height / 2 - 30);
      text("Left", 10, height / 2 + 60);
      stroke(#FF5ADC);
      drawArrow(width / 2 - 50, height / 2, width / 4, 180);
    }
  } else if (onSecondPhase) {
    if (!printed) {
      println("Starting Trial " + trialIndex + ", Phase 2"); 
      printed = true;
    }
    
    drawActions();
    int act = targets.get(trialIndex).action;
    
    if (timeCount >= 90) {
      startClock = false;
      
      if (sequence.size() <= 2) {
        if (act == 0) {
          nextPhase();
          trialIndex++;
        } else {
          wrongAction("Wrong 2nd round action"); 
        }
      } else if (sequence.size() >= 3) {
        if (act == 1) {
          nextPhase();
          trialIndex++;
        } else {
          wrongAction("Wrong 2nd round action"); 
        }
      }
      
      sequence.clear();
      num0s = 0;
      timeCount = 0;
    }
  }
}

class AccelerometerListener implements SensorEventListener {
  public void onSensorChanged(SensorEvent event) {
    ax = event.values[0];
    ay = event.values[1];
    az = event.values[2];
    if (trialIndex >= trialCount) return;
    
    if (onFirstPhase && countDownTimerWait < 0 && !userDone) {
      int tar = targets.get(trialIndex).target;
      
      if (-2 <= ax && ax <= 2 && 0 <= ay && ay <= 4 && az >= 7) {
        // Back...
        println("Back");
        tiltLeft = false;
        tiltRight = false;
        tiltBack = true;
        tiltForward = false;
        
        if (tar == 0) {
          nextPhase();
        } else {
          wrongAction("Wrong 1st round action");
        }
          
      } else if (-2 <= ax && ax <= 2 && 0 <= ay && ay <= 4 && az <= 0) { 
        // Forward...
        println("Forward");
        tiltLeft = false;
        tiltRight = false;
        tiltBack = false;
        tiltForward = true;   
          
        if (tar == 1) {
          nextPhase();
        } else {
          wrongAction("Wrong 1st round action");
        }   
      } else if (-2 <= az && az <= 2 && 3 <= ay && ay <= 8  && ax <= -7) {
        // Right...
        println("Right");
        tiltLeft = false;
        tiltRight = true;
        tiltBack = false;
        tiltForward = false;
        
        if (tar == 2) {
          nextPhase();
        } else {
          wrongAction("Wrong 1st round action");
        }     
          
      } else if (-2 <= az && az <= 2 && 3 <= ay && ay <= 8  && ax >= 7) { 
        // left
        println("Left");
        tiltLeft = true;
        tiltRight = false;
        tiltBack = false;
        tiltForward = false;
          
        if (tar == 3) {
          nextPhase();
        } else {
          wrongAction("Wrong 1st round action");
        }
      } else { // nothing
        tiltLeft = false;
        tiltRight = false;
        tiltBack = false;
        tiltForward = false;
      }
    }
  }
  
  public void onAccuracyChanged(Sensor sensor, int accuracy) {
    // No-op
  }
}

boolean startClock = false;
int timeCount = 0;

ArrayList<EventInfo> sequence = new ArrayList<EventInfo>();
class EventInfo {
  float dist;
  float time;
}


int num0s = 0;

class ProximitySensorListener implements SensorEventListener {
  public void onSensorChanged(SensorEvent event) {
    if (trialIndex >= trialCount) return;
    
    if (onSecondPhase && !userDone) {
      float distance = event.values[0];
      println("Dist: " + distance);
      
      EventInfo i = new EventInfo();
      i.time = event.timestamp;
      i.dist = event.values[0];
      sequence.add(i);
      
      if (i.dist == 0) {
        num0s += 1; 
      }
      
      for (EventInfo e : sequence) {
        println(e.dist); 
      }      
      
      if (sequence.size() > 0) {
        startClock = true;
      }
    }
  }
  
  public void onAccuracyChanged(Sensor sensor, int accuracy) {
    // No-op
  }
}

void nextPhase() {  
  onFirstPhase = !onFirstPhase;
  onSecondPhase = !onSecondPhase;
  printed = false;
  showCheck = true;
  showX = false;
  
}

void wrongAction(String error) {
  println(error);
  showX = true;
  showCheck = false;
  
  if (trialIndex > 0) {
    trialIndex -= 1;
  }
  
  if (onSecondPhase) {
    onSecondPhase = false;
    onFirstPhase = true;
  } else if (onFirstPhase) {
    // Redundant, oh well
    onFirstPhase = true;
    onSecondPhase = false;
  }
  countDownTimerWait = 30;
}