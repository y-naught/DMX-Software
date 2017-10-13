import dmxP512.*;
ArrayList<ThreeCh> Lights3Ch;

int numEffects = 3;
boolean modes[] = new boolean[numEffects];

int totalChannels;
PGraphics sampleImage;

DmxP512 dmxOutput;
int universeSize = 256;
String DMXPRO_PORT = "COM4";
int DMXPRO_BAUDRATE = 115000;

Ball[] balls;
int numBalls = 10;
float ballSize = 20;

void setup(){
  size(500,500);
  colorMode(RGB);
  
  dmxOutput = new DmxP512(this, universeSize, false);
  dmxOutput.setupDmxPro(DMXPRO_PORT, DMXPRO_BAUDRATE);
  
  sampleImage = createGraphics(width, height, P2D);
  //create an array list for each type of light
  Lights3Ch = new ArrayList<ThreeCh>();
  
  //add your lights
  for(int i = 0; i < 5; i++){
    Lights3Ch.add(new ThreeCh(i*3, new PVector(i * width / 20, height / 2)));
  }
  
  //start the program with the first effect on
  for(int i = 0; i < numEffects; i++){
    if(i == 0){
   modes[i] = true; 
    }else{
     modes[i] = false; 
    }
  }
  balls = new Ball[numBalls];
  for(int i = 0; i < balls.length; i++){
    balls[i] = new Ball(ballSize);
  }
}

void draw(){
  //Mouse Controlled HSB
  if(modes[0] == true){
  sampleImage.beginDraw();
  sampleImage.colorMode(HSB);
  sampleImage.background(mouseX,mouseY,255);
  sampleImage.endDraw();
  
  sampleImage.loadPixels();
  }
  else if(modes[1] == true){
    
    sampleImage.beginDraw();
    sampleImage.background(0);
    for(int i = 0; i < balls.length; i++){
      balls[i].checkEdges();
      balls[i].update();
      balls[i].display(sampleImage);
    }
    sampleImage.endDraw();
  }
  
  for(int i = 0; i < Lights3Ch.size(); i+=3){
    ThreeCh l = Lights3Ch.get(i);
    color c = l.sampleColor(sampleImage);
    dmxOutput.set(i, int(red(c)));
    dmxOutput.set(i+1, int(green(c)));
    dmxOutput.set(i+2, int(blue(c)));
    noStroke();
    fill(c);
    l.display();
 }
}

void keyPressed(){
 if(key == '1'){
   for(int i = 0; i < modes.length; i++){
   if(i == 0){
    modes[i] = true; 
   }else{
    modes[i] = false;
   }
  }
 }
 if(key == '2'){
   for(int i = 0; i < modes.length; i++){
   if(i == 1){
    modes[i] = true; 
   }else{
    modes[i] = false;
   }
  }
 }
}