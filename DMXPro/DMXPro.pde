import dmxP512.*;

ArrayList<ThreeCh> Lights3Ch;
int numLights = 5;

//set the number of pre-created effects here and create a switch for each effect
int numEffects = 3;
ArrayList<Boolean> modes = new ArrayList<Boolean>(numEffects);

//variable for total number of effects
int totalChannels;
ArrayList<PGraphics> Layers;

//start the DMX libaray this is build on top of with necessary variables
//DmxP512 dmxOutput;
//int universeSize = 256;
//String DMXPRO_PORT = "COM4";
//int DMXPRO_BAUDRATE = 115000;

//Initialize the array for Boucing Balls effect with variables for 
ArrayList<Ball> balls;
int numBalls = 10;
float ballSize = 20;

//Calls an object that uses the particle class to evenly shower from the top to bottom
Shower shower;
float pSize = 20;
//number of particles generated per frame in draw if switched on
int pCount = 10;


void setup(){
  size(500,500,P2D);
  //colorMode(RGB);
  
  //DMX setup procedure
  //dmxOutput = new DmxP512(this, universeSize, false);
  //dmxOutput.setupDmxPro(DMXPRO_PORT, DMXPRO_BAUDRATE);
  
  
  //create an arraylist of PGraphics for all the layers for the preset effects
  Layers = new ArrayList<PGraphics>();
  for(int i = 0; i < numEffects; i++){
   Layers.add(createGraphics(width, height, P2D));
  }
  
  //create an array list for each type of light
  Lights3Ch = new ArrayList<ThreeCh>();
  
  //add your lights
  for(int i = 0; i < numLights; i++){
    Lights3Ch.add(new ThreeCh(i*3, new PVector(i * width / 20, height / 2)));
  }
  
  //Creates a the arrayList for the Bouncing Ball preset effect
  balls = new ArrayList<Ball>(numBalls);
  for(int i = 0; i < balls.size(); i++){
    balls.add(new Ball(ballSize));
  }
  
  //initializes the Shower preset effect
  shower = new Shower(pCount, pSize);
  
  //start the program with the first effect on
  for(int i = 0; i < numEffects; i++){
    if(i == 0){
      Boolean m = modes.get(i);
      m = true;
      modes.set(i, m);
    }else{
     Boolean m = modes.get(i);
      m = true;
      modes.set(i, m);
    }
  }
}

void draw(){
  //Mouse Controlled HSB
  if(modes.get(0) == true){
  PGraphics g = Layers.get(0);
  g.beginDraw();
  g.colorMode(HSB);
  g.background(mouseX,mouseY,255);
  g.endDraw();
  
  g.loadPixels();
  }
  
  //Bouncing Balls
  else if(modes.get(1) == true){
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
  }
  
  //Particle Shower
  else if(modes.get(2) == true){
    PGraphics g = Layers.get(2);
    g.beginDraw();
    g.background(0);
    shower.run(g);
    g.endDraw();
  }
  
  //this function runs through all the switches and applies the layer to the light color calculator
  for(int j = 0; j < modes.size(); j++){
    if(modes.get(j) == true){
      PGraphics g = Layers.get(j);
      
      //iterates through all the lights and applies color to all the 3 channel lights
  for(int i = 0; i < Lights3Ch.size(); i+=3){
    ThreeCh l = Lights3Ch.get(i);
    color c = l.sampleColor(g);
    //dmxOutput.set(i, int(red(c)));
    //dmxOutput.set(i+1, int(green(c)));
    //dmxOutput.set(i+2, int(blue(c)));
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
    if(mouseX > l.location.x && mouseX < l.location.x + l.sz && mouseY > l.location.y && mouseY < l.location.y + l.sz){
     if(mousePressed == true){
      l.move(mouseX, mouseY);
     }
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
}