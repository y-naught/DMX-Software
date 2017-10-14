import processing.serial.*;
import dmxP512.*;

ArrayList<ThreeCh> Lights3Ch;
int numLights = 5;

//set the number of pre-created effects here and create a switch for each effect
int numEffects = 5;
ArrayList<Boolean> modes;

//variable for total number of effects
int totalChannels;
ArrayList<PGraphics> Layers;

//start the DMX libaray this is build on top of with necessary variables
DmxP512 dmxOutput;
int universeSize = 256;
String DMXPRO_PORT = "COM5";
int DMXPRO_BAUDRATE = 115000;

//Initialize the array for Boucing Balls effect with variables for 
ArrayList<Ball> balls;
int numBalls = 40;
float ballSize = 30;

//Calls an object that uses the particle class to evenly shower from the top to bottom
Shower shower;
float pSize = 10;
//number of particles generated per frame in draw if switched on
int pCount = 5;

//rotating rectangle at the center of the screen
float rectWidth = 50;

RadialGradient radGrad;

void setup(){
  size(500,500,P2D);
  rectMode(CENTER);
  colorMode(HSB);
  //colorMode(RGB);
  
  //DMX setup procedure
  dmxOutput = new DmxP512(this, universeSize, false);
  dmxOutput.setupDmxPro(DMXPRO_PORT, DMXPRO_BAUDRATE);
  
  modes = new ArrayList<Boolean>(numEffects);
  for(int i = 0; i < numEffects; i++){
   modes.add(false);
  }
  
  //create an arraylist of PGraphics for all the layers for the preset effects
  Layers = new ArrayList<PGraphics>();
  for(int i = 0; i < numEffects; i++){
   Layers.add(createGraphics(width, height, P2D));
  }
  
  //create an array list for each type of light
  Lights3Ch = new ArrayList<ThreeCh>();
  
  //add your lights
  for(int i = 0; i < numLights; i++){
    Lights3Ch.add(new ThreeCh(i*3, new PVector(i * width / 10, height / 2)));
  }
  
  //Creates a the arrayList for the Bouncing Ball preset effect
  balls = new ArrayList<Ball>(numBalls);
  for(int i = 0; i < numBalls; i++){
    balls.add(new Ball(ballSize));
  }
  
  //initializes the Shower preset effect
  shower = new Shower(pCount, pSize);
  
  radGrad = new RadialGradient(100.0, 2.0);
  
  //start the program with the first effect on
  for(int i = 0; i < modes.size(); i++){
    if(i == 0){
      modes.set(i, true);
    }else{
     modes.set(i, false);
    }
  }
}

void draw(){
  //Mouse Controlled HSB
  if(modes.get(0)){
  PGraphics g = Layers.get(0);
  g.beginDraw();
  g.colorMode(HSB);
  g.background(map(mouseX, 0, width, 0, 255), map(mouseY, 0, height, 0, 255), 255);
  g.endDraw();
  
  image(g, 0, 0);
  }
  
  //Bouncing Balls
  else if(modes.get(1)){
    PGraphics g = Layers.get(1);
    g.beginDraw();
    g.background(0);
    for(int i = 0; i < balls.size(); i++){
      Ball b = balls.get(i);
      b.checkEdges();
      b.update();
      b.display(g);
    }
    g.endDraw();
    
    image(g, 0, 0);
  }
  
  //Particle Shower
  else if(modes.get(2)){
    PGraphics g = Layers.get(2);
    g.beginDraw();
    g.background(0);
    shower.run(g);
    g.endDraw();
    image(g,0,0);
  }
  
  //rotating rectangle
  else if(modes.get(3)){
    PGraphics g = Layers.get(3);
    g.rectMode(CENTER);
    g.beginDraw();
    g.background(0);
    g.pushMatrix();
    g.translate(width / 2, height / 2);
    g.rotate(TWO_PI * (frameCount % 120) / 240);
    g.rect(0, 0, rectWidth, width * 1.5);
    g.popMatrix();
    g.endDraw();
    image(g,0,0);
  }
  
  //radial gradient flow
  else if(modes.get(4)){
    PGraphics g = Layers.get(4);
    g.colorMode(HSB, 255, 255, 255);
    g.beginDraw();
    g.background(0);
    radGrad.display(g);
    g.endDraw();
    image(g,0,0);
  }
  
  if(mousePressed == true){
   lightArranger(Lights3Ch); 
  }
  
  //this function runs through all the switches and applies the layer to the light color calculator
  for(int j = 0; j < modes.size(); j++){
    if(modes.get(j) == true){
      PGraphics g = Layers.get(j);
      
      //iterates through all the lights and applies color to all the 3 channel lights
  for(int i = 0; i < Lights3Ch.size(); i++){
    ThreeCh l = Lights3Ch.get(i);
    color c = l.sampleColor(g);
    dmxOutput.set(i, int(red(c)));
    dmxOutput.set(i+1, int(green(c)));
    dmxOutput.set(i+2, int(blue(c)));
    noStroke();
    fill(c);
    l.display();
   }
  }
 }
}

//calling this function will allow you to click on the lights in the window and arrange them on the running effect
void lightArranger(ArrayList<ThreeCh> lights){
  for(int i = 0; i < lights.size(); i++){
    ThreeCh l = lights.get(i);
    if(mouseX > l.location.x - l.sz && mouseX < l.location.x + l.sz && mouseY > l.location.y - l.sz && mouseY- l.sz < l.location.y + l.sz){
      l.move(mouseX, mouseY);
    }
  }
}

//currently usingthe keys on the keyboard to switch between effects
void keyPressed(){
 if(key == '1'){
   for(int i = 0; i < modes.size(); i++){
   if(i == 0){
    Boolean m = modes.get(i);
    m = true; 
    modes.set(i, m);
   }else{
    Boolean m = modes.get(i);
    m = false; 
    modes.set(i, m);
   }
  }
 }
 if(key == '2'){
   for(int i = 0; i < modes.size(); i++){
   if(i == 1){
    Boolean m = modes.get(i);
    m = true; 
    modes.set(i, m);
   }else{
    Boolean m = modes.get(i);
    m = false; 
    modes.set(i, m);
   }
  }
 }
 if(key == '3'){
   for(int i = 0; i < modes.size(); i++){
   if(i == 2){
    Boolean m = modes.get(i);
    m = true; 
    modes.set(i, m);
   }else{
    Boolean m = modes.get(i);
    m = false; 
    modes.set(i, m);
   }
  }
 }
 if(key == '4'){
   for(int i = 0; i < modes.size(); i++){
   if(i == 3){
    Boolean m = modes.get(i);
    m = true; 
    modes.set(i, m);
   }else{
    Boolean m = modes.get(i);
    m = false; 
    modes.set(i, m);
   }
  }
 }
 if(key == '5'){
   for(int i = 0; i < modes.size(); i++){
   if(i == 4){
    Boolean m = modes.get(i);
    m = true; 
    modes.set(i, m);
   }else{
    Boolean m = modes.get(i);
    m = false; 
    modes.set(i, m);
   }
  }
 }
}