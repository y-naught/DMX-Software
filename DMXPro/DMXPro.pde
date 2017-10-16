import processing.serial.*;
import dmxP512.*;
import themidibus.*;

//decalre the handler for the midi controller
MidiBus bus;



//contains all ofthe 3 channel light fixture information
ArrayList<ThreeCh> Lights3Ch;
int numLights = 14;

//set the number of pre-created effects here and create a switch for each effect
int numEffects = 7;
ArrayList<Boolean> modes;



//variable for total number of effects
int totalChannels;
ArrayList<PGraphics> Layers;

//start the DMX libaray this is build on top of with necessary variables
DmxP512 dmxOutput;
int universeSize = 256;
String DMXPRO_PORT = "COM5";
int DMXPRO_BAUDRATE = 115000;



//a switch between using one color or an array of colors with a preset effect
boolean oneColor = true;

//the global hue, sat, and brightness  values that get passed into each preset
int hue = 0;
int saturation = 255;
int brightness = 255;



//Initialize the array for Boucing Balls effect with variables for 
ArrayList<Ball> balls;
int numBalls = 40;
float ballSize = 50;
float ballSpeed = 5;

//Calls an object that uses the particle class to evenly shower from the top to bottom
Shower shower;
float pSize = 5;
//number of particles generated per frame in draw if switched on
int pCount = 20;
float particleSpeed = 5;

//rotating rectangle at the center of the screen
float rectWidth = 20;
float rotationSpeed = 100; 
//inverse of what you think

//radial gradient function
RadialGradient radGrad;

LinearGradient linGrad;
float linGradOffset = 10;

PNoise noise;
float noiseMX = 0;
float noiseMY = 0;
float noiseInc = 0.01;
int noiseMode = 0;




void setup(){
  size(500,500,P2D);
  rectMode(CENTER);
  colorMode(HSB);
  frameRate(30);
  
  
  bus = new MidiBus(this, 0, -1);
  
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
  
  
  // setup for distributing the light fixtures into to the window about a circle
  float currentAngle = PI / 2;
  float radius = 200.0;
  
  //add your lights
  for(int i = 0; i < numLights; i++){
    PVector nextLoc = new PVector(radius * sin(currentAngle) + width / 2,radius * cos(currentAngle) + height / 2);
    Lights3Ch.add(new ThreeCh(i*3,nextLoc));
    currentAngle += (numLights) / TWO_PI;
  }

  
  //Creates a the arrayList for the Bouncing Ball preset effect
  balls = new ArrayList<Ball>(numBalls);
  for(int i = 0; i < numBalls; i++){
    balls.add(new Ball(ballSize));
  }
  
  //initializes the Shower preset effect
  shower = new Shower(pCount, pSize);
  
  //initialize the radial gradient preset effect
  radGrad = new RadialGradient(50.0, 4.0);
  
  //initialize the linear gradient preset effect
  linGrad = new LinearGradient();
  
  //initialize the 2D perlin noise effect
  noise = new PNoise(hue, brightness, saturation, noiseMX, noiseMY, noiseInc);
  
  
  
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
  
  //Solid Color in the window
  if(modes.get(0)){
  PGraphics g = Layers.get(0);
  g.beginDraw();
  g.colorMode(HSB);
  g.background(hue, saturation, brightness);
  g.endDraw();
  image(g, 0, 0);
  }
  
  
  //Bouncing Balls Effect
  else if(modes.get(1)){
    //add or remove from the array depending on what the numBalls variable is set to
    if(balls.size() != numBalls){
     while(balls.size() < numBalls){
      balls.add(new Ball(ballSize)); 
     }
     while(balls.size() > numBalls){
      balls.remove(int(random(balls.size())));
     }
    }
    
    PGraphics g = Layers.get(1);
    g.beginDraw();
    g.background(0);
    for(int i = 0; i < balls.size(); i++){
      Ball b = balls.get(i);
      b.checkEdges();
      b.update(ballSize, ballSpeed, hue, saturation, brightness, oneColor);
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
    shower.run(g, hue, saturation, brightness, particleSpeed, pCount, pSize, oneColor);
    g.endDraw();
    image(g,0,0);
  }
  
  
  //rotating rectangle
  else if(modes.get(3)){
    PGraphics g = Layers.get(3);
    g.colorMode(HSB);
    g.rectMode(CENTER);
    g.beginDraw();
    g.background(0);
    g.pushMatrix();
    g.translate(width / 2, height / 2);
    g.rotate(TWO_PI * (frameCount % rotationSpeed / 2) / rotationSpeed);
    g.fill(hue, saturation, brightness);
    g.rect(0, 0, rectWidth, width * 1.5);
    g.popMatrix();
    g.endDraw();
    image(g,0,0);
  }
  
  
  //radial gradient flow
  else if(modes.get(4)){
    PGraphics g = Layers.get(4);
    //g.colorMode(HSB, 255, 255, 255);
    //g.ellipseMode(RADIUS);
    g.beginDraw();
    g.background(0);
    radGrad.display(g);
    g.endDraw();
    image(g,0,0);
  }
  
  
  //linear gradient
  else if(modes.get(5)){
    PGraphics g = Layers.get(5);
    g.beginDraw();
    g.background(0);
    linGrad.updateColor(hue, saturation, brightness, linGradOffset);
    linGrad.display(g);
    g.endDraw();
    image(g,0,0);
  }
  
  
  //perlin noise field
  else if(modes.get(6)){
    PGraphics g = Layers.get(6);
    g.beginDraw();
    g.background(0);
    noise.update(g, hue, saturation, brightness, noiseMX, noiseMY, noiseInc);
    g.endDraw();
    image(g,0,0);
  }
  
  
  
  //this uses the move lights function of you press the mouse over any of the lights
  if(mousePressed == true){
   lightArranger(Lights3Ch); 
  }
  
  
  
  //this function runs through all the switches and applies the layer to the light color calculator
  for(int j = 0; j < modes.size(); j++){
    if(modes.get(j) == true){
      PGraphics g = Layers.get(j);
  
  
  //iterates through all the lights and applies color to all the 3 channel lights
  for(int i = 1; i < Lights3Ch.size() * 3; i++){
    colorMode(HSB);
    ThreeCh l = Lights3Ch.get(i / 3);
    color c = l.sampleColor(g);
    dmxOutput.set(i, int(red(c)));
    i++;
    dmxOutput.set(i, int(green(c)));
    i++;
    dmxOutput.set(i, int(blue(c)));
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
    if(mouseX > l.location.x - l.sz / 2 && mouseX < l.location.x + l.sz / 2 && mouseY > l.location.y - l.sz / 2 && mouseY- l.sz / 2 < l.location.y + l.sz / 2){
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
 if(key == '6'){
   for(int i = 0; i < modes.size(); i++){
   if(i == 5){
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
 if(key == '7'){
   for(int i = 0; i < modes.size(); i++){
   if(i == 6){
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
 if(key == 'c'){
  if(oneColor == true){
   oneColor = false; 
  }
  else{
   oneColor = true; 
  }
 }
 if(key == 'b'){
   if(noiseMode != 0){
    noiseMode = 0; 
   }
 }
 if(key == 'n'){
   if(noiseMode != 1){
    noiseMode = 1; 
   }
 }
 if(key == 'm'){
   if(noiseMode != 2){
    noiseMode = 2; 
   }
 }
}




//the sliders on the midi controller
void controllerChange(int channel, int number, int value){
 if(number == 48){
   hue = value * 2;
 }
 if(number == 49){
   saturation = value * 2;
 }
 if(number == 50){
   brightness = value * 2;
 }
 if(number == 51){
   if(modes.get(1)){
     ballSize = map(value, 0, 127, 0, 50);
   }
   else if(modes.get(2)){
    pSize = map(value, 0, 127, 0, 20);
   }
   else if(modes.get(3)){
    rectWidth = map(value, 0, 127, 0, 200); 
   }
   else if(modes.get(5)){
    linGradOffset = map(value, 0, 127, 0, 255); 
   }
   else if(modes.get(6)){
    noiseMX = map(value, 0, 127, -0.50, 0.50); 
   }
 }
 if(number == 52){
   if(modes.get(1)){
    numBalls = int(map(value, 0, 127, 0, 100)); 
   }
   else if(modes.get(2)){
    pCount = int(map(value, 0, 127, 0, 50)); 
   }
   else if(modes.get(3)){
    rotationSpeed = map(value, 0, 127, -300, 300); 
   }
   else if(modes.get(6)){
    noiseMY = map(value, 0, 127, -0.50, 0.50); 
   }
 }
 if(number == 53){ 
   if(modes.get(1)){
   ballSpeed = map(value, 0, 127, 0, 50);
   }
   else if(modes.get(2)){
    particleSpeed = map(value,0, 127, 0, 30); 
   }
   else if(modes.get(6)){
    noiseInc = map(value,0, 127, 0.001, 0.08);
   }
 }
 if(number == 54){
 }
 if(number == 55){
 }
 if(number == 56){
 }
}




//the buttons on the midi controller
void noteOn(Note note){
  if(note.pitch() == 56){
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
  if(note.pitch() == 57){
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
  if(note.pitch() == 58){
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
  if(note.pitch() == 59){
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
  if(note.pitch() == 60){
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
  if(note.pitch() == 61){
    for(int i = 0; i < modes.size(); i++){
   if(i == 5){
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
  if(note.pitch() == 62){
    for(int i = 0; i < modes.size(); i++){
   if(i == 6){
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