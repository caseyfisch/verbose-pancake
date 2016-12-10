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

void draw() {
  background(0);
  if (trialIndex >= targets.size()) return;
  countDownTimerWait -= 1;
  
  
  if (countDownTimerWait < 0) {
    text("X: " + ax, 10, 60);
    text("Y: " + ay, 10, 120);
    text("Z: " + az, 10, 180);
  }
  
  int tar = targets.get(trialIndex).target;
  int act = targets.get(trialIndex).action;
  if (onFirstPhase) {
    if (tar == 0) {
      text("BACK", 10, 240);
    } else if (tar == 1) {
      text("FRONT", 10, 240);
    } else if (tar == 2) {
      text("RIGHT", 10, 240);
    } else if (tar == 3) {
      text("LEFT", 10, 240);
    }
  } else if (onSecondPhase) {
    if (!printed) {
      println("Starting Trial " + trialIndex + ", Phase 2"); 
      printed = true;
    }
  }
  
}

class AccelerometerListener implements SensorEventListener {
  public void onSensorChanged(SensorEvent event) {
    ax = event.values[0];
    ay = event.values[1];
    az = event.values[2];
    
    if (onFirstPhase && countDownTimerWait < 0) {
      int tar = targets.get(trialIndex).target;
      
      if (-2 <= ax && ax <= 2) {
        if (az >= 8) { // back
          tiltLeft = false;
          tiltRight = false;
          tiltBack = true;
          tiltForward = false;
          
          if (tar == 0) {
            nextPhase();
          } else {
            wrongAction("Wrong 1st round action");
          }
          
        } else if (az <= -2) { // forward
          tiltLeft = false;
          tiltRight = false;
          tiltBack = false;
          tiltForward = true;   
          
          if (tar == 1) {
            nextPhase();
          } else {
            wrongAction("Wrong 1st round action");
          }   
        }
      } else if (-2 <= az && az <= 2) {
        if (ax <= -7) { // right
          tiltLeft = false;
          tiltRight = true;
          tiltBack = false;
          tiltForward = false;
          
          if (tar == 2) {
            nextPhase();
          } else {
            wrongAction("Wrong 1st round action");
          }     
          
        } else if (ax >= 7) { // left
          tiltLeft = true;
          tiltRight = false;
          tiltBack = false;
          tiltForward = false;
          
          if (tar == 3) {
            nextPhase();
          } else {
            wrongAction("Wrong 1st round action");
          }
          
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

class ProximitySensorListener implements SensorEventListener {
  public void onSensorChanged(SensorEvent event) {
    if (onSecondPhase) {
      println(event.values[0]);
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
}

void wrongAction(String error) {
  println(error);
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