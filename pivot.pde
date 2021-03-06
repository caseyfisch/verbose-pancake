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
boolean correctFirstPhase, correctSecondPhase;
boolean printed;
int countDownTimerWait = 0;

boolean showX, showCheck;
int showXCount = 0, showCheckCount = 0;

boolean hasUserStartedGame = false;

private class Target {
  int target = 0;
  int action = 0;
  
  String toString() {
    return "(" + target + ", " + action + ")"; 
  }
}

int trialCount = 10; //this will be set higher for the bakeoff
int trialIndex = 0;
ArrayList<Target> targets = new ArrayList<Target>();
ArrayList<String> keywords = new ArrayList<String>();

int startTime = 0; // time starts when the first click is captured
int finishTime = 0; //records the time of the final click
boolean userDone = false;

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
  rectMode(CENTER);
  
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
  
  ballX = width / 2;
  ballY = height / 2;
  
  keywords.add("UP");
  keywords.add("DOWN");
  keywords.add("RIGHT");
  keywords.add("LEFT");
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

int ballX, ballY;

void drawBall() {
  ballX += (-1 * ax) * 8;
  ballY += ay * 12;

  if (!hasUserStartedGame) {
    ballX = constrain(ballX, width / 2 - width / 8, width / 2 + width / 8);
    ballY = constrain(ballY, height / 2 - height / 8, height / 2 + height / 8);
  } else {
    ballX = constrain(ballX, 0, width);
    ballY = constrain(ballY, 0, height);
  }
  
  fill(255);
  noStroke();
  ellipse(ballX, ballY, 50, 50);
  
  if (!hasUserStartedGame) return;
  
  int tar = targets.get(trialIndex).target;
  
  if (ballX <= 25) {
    // on Left
    // tar = 3
    
    println("Left");
      
    if (tar == 3) {
      correctFirstPhase = true;
      correctSecondPhase = false;
    } else {
      correctFirstPhase = false;
      correctSecondPhase = false;
    }
    
    nextPhase();
    
  } else if (ballX >= width - 25) {
    // on Right
    // tar = 2
    
    println("Right");
    
    if (tar == 2) {
      correctFirstPhase = true;
      correctSecondPhase = false;
    } else {
      correctFirstPhase = false;
      correctSecondPhase = false;
    }
    nextPhase();
    
  } else if (ballY <= 25) {
    // on Top
    // tar = 0
    
    println("Top");
    
    if (tar == 0) {
      correctFirstPhase = true;
      correctSecondPhase = false;
    } else {
      correctFirstPhase = false;
      correctSecondPhase = false;
    }
    nextPhase();
    
  } 
  
  if (ballY >= height - 25) {
    // on Bottom
    // tar = 1 
      
    println("Bottom");  
      
    if (tar == 1) {
      correctFirstPhase = true;
      correctSecondPhase = false;
    } else {
      correctFirstPhase = false;
      correctSecondPhase = false;
    }   
    nextPhase();
    
  }
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
  
  drawBall();
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
    fill(65);
    ellipse(width / 2 - diam, height / 2, diam, diam); 
    ellipse(width / 2 + diam, height / 2, diam, diam); 
  } else if (num0s == 1) {
    fill(#C4FF58);
    ellipse(width / 2 - diam, height / 2, diam, diam); 
    fill(65);
    ellipse(width / 2 + diam, height / 2, diam, diam); 
  } else if (num0s == 2) {
    fill(#C4FF58);
    ellipse(width / 2 - diam, height / 2, diam, diam); 
    ellipse(width / 2 + diam, height / 2, diam, diam);        
  }
  
}

void draw() {
  background(0);
  
  if (!hasUserStartedGame) {
    textAlign(CENTER);
    fill(255);
    text("Touch to start!", width / 2, 60);
    fill(65);
    rect(width / 2, height / 2, width / 4, height / 4);
    drawBall();
    return;
  }
    
  if (startTime == 0) {
    println("Starting...");
    startTime = millis();
  }
  
  if (trialIndex >= targets.size() && !userDone) {
    userDone = true;
    finishTime = millis();
  }
  
  if (userDone) {
    textSize(24);
    textAlign(LEFT);
    fill(255);
    text("User completed " + trialCount + " trials", 10, 50);
    text("User took " + nfc((finishTime-startTime)/1000f/trialCount, 3) + " sec per target", 10, 80);
    textAlign(RIGHT);
    textSize(18);
    text("Next... " + (3 - touchCount), width - 10, 20);
    return;
  }
  
  textSize(18);
  fill(255);
  textAlign(RIGHT);
  text("Trial " + (trialIndex + 1), width - 10, 20);
  // text(keywords.get(targets.get(trialIndex).target) + "." + (targets.get(trialIndex).action + 1), width - 10, 40);
  textSize(60);
  
  countDownTimerWait -= 1;
  
  if (startClock) {
    timeCount += 1; 
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
    
    if (timeCount >= 75) {
      startClock = false;
      
      if (sequence.size() <= 2) {
        if (act == 0) {
          println("1 swipe good");
          correctSecondPhase = true;
          nextPhase();
        } else {
          println("1 swipe bad");
          correctSecondPhase = false;
          nextPhase();
        }
      } else if (sequence.size() >= 3) {
        if (act == 1) {
          println("2 swipes good");
          correctSecondPhase = true;
          nextPhase();
        } else {
          println("2 swipes bad");
          correctSecondPhase = false;
          nextPhase();
        }
      }
      
      sequence.clear();
      num0s = 0;
      timeCount = 0;
    }
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
  
}

class AccelerometerListener implements SensorEventListener {
  public void onSensorChanged(SensorEvent event) {
    ax = event.values[0];
    ay = event.values[1];
    az = event.values[2];
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
      
      if (sequence.size() == 0) {
        // want to make sure we start with 0.0 in the sequence
        if (i.dist == 0) {
          sequence.add(i); 
        }
      } else {
        // otherwise just add as usual
        sequence.add(i);
      }
      
      if (i.dist == 0) {
        num0s += 1; 
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
  if (onFirstPhase) {
    onSecondPhase = true;
    onFirstPhase = false;
    printed = false;
    showCheck = false;
    showX = false;
    return;
  }
  
  println("correct 1st: " + correctFirstPhase + ", correct 2nd: " + correctSecondPhase);
  
  if (!onFirstPhase && onSecondPhase && correctFirstPhase && correctSecondPhase) {
    // success
    showCheck = true;
    showX = false;
    trialIndex++;
    
  } else {
    showX = true;
    showCheck = false;
    
    if (trialIndex > 0) {
      trialIndex -= 1;
    }
    
    countDownTimerWait = 30;
    
    sequence.clear();

  }
  
  ballX = width / 2;
  ballY = height / 2;
  correctFirstPhase = false;
  correctSecondPhase = false;
  onFirstPhase = !onFirstPhase;
  onSecondPhase = !onSecondPhase;
  printed = false;
}

int touchCount = 0;
void mousePressed() {
  hasUserStartedGame = true; 
  
  if (userDone) {
    touchCount += 1; 
    println("here");
    if (touchCount == 3) {
      // Restart game
      
      startTime = 0;
      finishTime = 0;
      userDone = false;
      hasUserStartedGame = false;
      ballX = width / 2;
      ballY = height / 2;
      onFirstPhase = true;
      onSecondPhase = false;
      trialIndex = 0;
      correctFirstPhase = false;
      correctSecondPhase = false;
      printed = false;
      showX = false;
      showCheck = false;
      showXCount = 0;
      showCheckCount = 0;
      countDownTimerWait = 0;
      touchCount = 0;
      sequence.clear();
      
      // Generate targets.
      targets.clear();
      for (int i=0; i<trialCount; i++) {  //don't change this!
        Target t = new Target();
        t.target = ((int)random(1000)) % 4;
        t.action = ((int)random(1000)) % 2;
        targets.add(t);
      }
      println("=========== new game ==========");
      Collections.shuffle(targets); // randomize the order of the button;
      println(targets);
      
      textSize(60);
      
    }
  }
}