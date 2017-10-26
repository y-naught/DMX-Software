import processing.serial.*;
import dmxP512.*;
import themidibus.*;
import KinectPV2.KJoint;
import KinectPV2.*;
import java.util.*;
import processing.sound.*;

AudioDevice audioDevice;
AudioIn audioIn;
FFT fft;
int bands = 128;
float [] spectrum = new float[bands];
float [] audioSmooth = new float[bands];
float audioSmFact = 0.2;

//decalre the handler for the midi controller
MidiBus bus;
boolean colSwitch = true;
//kinect variables
KinectPV2 kinect;
boolean trigger = true;
PImage img;
float lastX = 0;
float lastY = 0;
float curX = 250;
float curY = 250;
float spreadX = 0;
float spreadY = 0;
float curZ = 0;
float lastZ = 0;

int xTrimL = 50;
int xTrimR = 50;
int yTrimT = 100;
int yTrimB = 100;

float zoom = 200;
int maxD = 3300; // 4.5mx
int minD = 00;  //  0cm
float totalPixels;


//light spacing variables
float currentAngle = 0.10;
float radius = 200.0;
float lightSpacing = 0.37;
float hueOffset = 127;


//contains all ofthe 3 channel light fixture information
ArrayList<ThreeCh> Lights3Ch;
int numLights = 17;

//set the number of pre-created effects here and create a switch for each effect
int numEffects = 12;
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
float alpha = 255;

int hue2 = 127;
int saturation2 = 255;
int brightness2 = 255;
int alpha2 = 255;



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
float particleSpeed = 10;

//rotating rectangle at the center of the screen
float rectWidth = 20;
float rotationSpeed = 100; 
//inverse of what you think

//radial gradient function
RadialGradient radGrad;

LinearGradient linGrad;
float linGradOffset = 10;
float linGradSpeed = 1;

PNoise noise;
float noiseMX = 0;
float noiseMY = 0;
float noiseInc = 0.01;
int noiseMode = 0;
float contrastMin = -10;
float contrastMax = 265;

TwoColorGradient twoColGrad;
float gradientSpeed = 1;
float gradW = 200;

Fountain fountain;

CirGradient cirGrad;
float gradAngle = 0;
float newAngle = 0;
float gradRotSpeed = 1;
float gradSpread = 0;

TwoCirGrad twoCirGrad;

void setup(){
  size(500,500,P2D);
  rectMode(CENTER);
  colorMode(HSB);
  frameRate(30);
  
  audioIn = new AudioIn(this, 0);
  audioIn.start();
  
  fft = new FFT(this, bands);
  
  fft.input(audioIn);
  
  bus = new MidiBus(this, 0, -1);
  
  kinect = new KinectPV2(this);
  kinect.enableDepthImg(true);
  //Enable point cloud
  kinect.enablePointCloud(true);
  kinect.init();
  
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
    PVector nextLoc = new PVector(radius * sin(currentAngle) + width / 2,radius * cos(currentAngle) + height / 2);
    Lights3Ch.add(new ThreeCh(i*3,nextLoc));
    currentAngle += (lightSpacing);
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
  noise = new PNoise(hue, brightness, saturation,alpha, noiseMX, noiseMY, noiseInc);
  
  twoColGrad = new TwoColorGradient();
  fountain = new Fountain();
  cirGrad = new CirGradient();
  twoCirGrad = new TwoCirGrad();
  
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
  if(modes.get(8)){
  int [] rawData = kinect.getRawDepthData();
  img = createImage(kinect.WIDTHDepth, kinect.HEIGHTDepth, RGB);
  
  img.loadPixels();
  
  
  float sumX = 0;
  float sumY = 0;
  float sumZ = 0;
  spreadX = 0;
  spreadY = 0;
  totalPixels = 0;
  
  //a loop that iterates through all the the depth pixels and creates an image that shows up in red if the depth is within
  //the minimum and maximum thresholds currently set (see key pressed for adjustments)
  for(int i = xTrimL; i < kinect.WIDTHDepth - xTrimR; i++){
   for(int j = yTrimT; j < kinect.HEIGHTDepth - yTrimB; j++){
      if(rawData[i + j*kinect.WIDTHDepth] > minD && rawData[i + j*kinect.WIDTHDepth] < maxD){
       img.pixels[i + j*kinect.WIDTHDepth] = color(0, 255, 255);
       sumX += i;
       sumY += j;
       sumZ += rawData[i + j *kinect.WIDTHDepth];
       totalPixels++;
       spreadX += abs(i - curX);
       spreadY += abs(i - curY);
      }
     }
  }
  
  
  
  if(totalPixels > 150){
   float x = sumX / totalPixels; 
   float y = sumY / totalPixels;
   float z = sumZ / totalPixels;
   
   curX = map(x, 0, kinect.WIDTHDepth, 0, width);
   curY = map(y, 0, kinect.HEIGHTDepth, 0, height);
   curZ = map(z, 50, 3000, 0, height);
   
   lastX = curX;
   lastY = curY;
   lastZ = curZ;
   
   spreadX = spreadX / totalPixels;
   spreadY = spreadY / totalPixels;
   }
   
  if(trigger == true){
   img.updatePixels(); 
   image(img, 0, 0);
   }
  }
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
    //g.background((hue + hueOffset) % 255 ,saturation, brightness);
    shower.run(g, hue, saturation, brightness, alpha, particleSpeed, pCount, pSize, oneColor);
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
    linGrad.updateColor(hue, saturation, brightness, linGradOffset, linGradSpeed);
    linGrad.display(g);
    g.endDraw();
    image(g,0,0);
  }
  
  
  //perlin noise field
  else if(modes.get(6)){
    PGraphics g = Layers.get(6);
    g.beginDraw();
    g.background(hue, saturation, 255);
    noise.update(g, hue, saturation, brightness, alpha, noiseMX, noiseMY, noiseInc, noiseMode, contrastMin, contrastMax);
    g.endDraw();
    image(g,0,0);
  }
  
  //moving bar x-direction
  else if(modes.get(7)){
    PGraphics g = Layers.get(7);
    g.colorMode(HSB);
    g.beginDraw();
    g.background(hue, saturation, brightness);
    twoColGrad.checkEdges();
    twoColGrad.display(g, gradientSpeed, hue, saturation, brightness, gradW, hue2, saturation2, brightness2);
    g.endDraw();
    image(g,0,0);
  }
  
  //Kinect Particle Fountain
  else if(modes.get(8)){
    float x;
    float y;
    float z;
    if(totalPixels > 150){
      x = curX;
      y = curY;
      z = curZ;
    }else{
      x = lastX;
      y = lastY;
      z = lastZ;
    }
    
    PVector direction = new PVector((width - x - width / 2),  height - y - height / 2);
    //hue = int(map(spreadX + spreadY, 0, width, 0, 255));
    
    PGraphics g = Layers.get(8);
    g.colorMode(HSB);
    g.beginDraw();
    g.background((hue + hueOffset) % 255, saturation, brightness);
    fountain.run(g, hue, saturation, brightness, alpha, particleSpeed, pCount, pSize, oneColor, direction.x, direction.y);
    g.endDraw();
    if(trigger != true){
    image(g,0,0);
    }
  }
  //spinning circular gradient
  else if(modes.get(9)){
    color tempC1 = color(hue, saturation,brightness, 255);
    color tempC2 = color((hue + hueOffset % 255), saturation, 0, 0);
    PGraphics g = Layers.get(9);
    g.colorMode(HSB);
    g.beginDraw();
    g.background(0);
    cirGrad.display(g, gradAngle, gradRotSpeed, tempC1, tempC2);
    g.endDraw();
    g.pushMatrix();
    g.translate(width / 2, height / 2);
    g.rotate(newAngle);
    image(g,0,0);
    g.popMatrix();
    newAngle = (frameCount % gradRotSpeed) / gradRotSpeed * TWO_PI;
  }
  
  //sound active
  else if(modes.get(10)){
    float ang = 0;
    PGraphics g = Layers.get(10);
    fft.analyze(spectrum);
    
    g.colorMode(HSB);
    g.beginDraw();
    g.background(0);
    g.ellipseMode(CENTER);
    g.noStroke();
    for(int i = 0; i < bands; i++){
      audioSmooth[i] += ((spectrum[i] - audioSmooth[i]) * audioSmFact);
      ang = random(0, TWO_PI);
      float s = map(audioSmooth[i], 0, 0.0001, 0, 20);
      if(s > 30){
      g.pushMatrix();
      g.translate(width / 2, height / 2);
      g.fill(map(i, 0, bands, 0, 255), saturation, brightness);
      g.ellipse(200 * sin(ang), 200 * cos(ang), s,s);
      g.popMatrix();
      }
    }
    g.endDraw();
    image(g,0,0);
  }
  
  if(modes.get(11)){
  PGraphics g = Layers.get(11);
   color temp1 = color(hue,saturation,brightness, 0);
   color temp2 = color(hue + 40, saturation, brightness, 255);
   color temp3 = color(0,0,0,0);
   
    g.colorMode(HSB);
    g.beginDraw();
    g.background(0);
    twoCirGrad.update(g, 2000, 0.005, temp1, temp2, temp3);
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

void lightReset(ArrayList<ThreeCh> lights){
 for(int i = 0; i < lights.size(); i ++){
   float x = radius * sin(-currentAngle) + width / 2;
   float y = radius * cos(-currentAngle) + height / 2;
   currentAngle += lightSpacing;
   ThreeCh l = lights.get(i);
   l.move(x, y);
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
 if(key == '8'){
   for(int i = 0; i < modes.size(); i++){
   if(i == 7){
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
 if(key == '9'){
   for(int i = 0; i < modes.size(); i++){
   if(i == 8){
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
 if(key == '0'){
   for(int i = 0; i < modes.size(); i++){
   if(i == 9){
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
 if(key == 'i'){
   if(trigger == true){
    trigger = false; 
   }else{
    trigger = true;
   }
 }
 if(key == 'p'){
  println(lastX);
  println(lastY);
 }
}




//the sliders on the midi controller
void controllerChange(int channel, int number, int value){
 if(number == 48){
   if(colSwitch == true){
   hue = value * 2;
   }else{
    hue2 = value * 2; 
   }
 }
 if(number == 49){
   if(colSwitch == true){
   saturation = value * 2;
   }else{
    saturation2 = value * 2; 
   }
 }
 if(number == 50){
   if(colSwitch == true){
   brightness = value * 2;
   }else{
    brightness2 = value * 2; 
   }
 }
 if(number == 51){
   if(modes.get(1)){
     ballSize = map(value, 0, 127, 0, 50);
   }
   else if(modes.get(2) || modes.get(8)){
    pSize = map(value, 0, 127, 0, 20);
   }
   else if(modes.get(3)){
    rectWidth = map(value, 0, 127, 0, 330); 
   }
   else if(modes.get(5)){
    linGradOffset = map(value, 0, 127, 0, 255); 
   }
   else if(modes.get(6)){
    noiseMX = map(value, 0, 127, -0.50, 0.50); 
   }
   else if(modes.get(7)){
    gradientSpeed = map(value, 0, 127, 0, 40);
   }
 }
 if(number == 52){
   if(modes.get(1)){
    numBalls = int(map(value, 0, 127, 0, 100)); 
   }
   else if(modes.get(2) || modes.get(8)){
    pCount = int(map(value, 0, 127, 0, 100)); 
   }
   else if(modes.get(3)){
    rotationSpeed = map(value, 0, 127, 150, 5); 
   }
   else if(modes.get(6)){
    noiseMY = map(value, 0, 127, -0.50, 0.50); 
   }
   else if(modes.get(7)){
    gradW = map(value, 0, 127, 0, width); 
   }
 }
 if(number == 53){ 
   if(modes.get(1)){
   ballSpeed = map(value, 0, 127, 0, 50);
   }
   else if(modes.get(2) || modes.get(8)){
    particleSpeed = map(value,0, 127, 0, 18); 
   }
   else if(modes.get(6)){
    noiseInc = map(value,0, 127, 0.001, 0.08);
   }
 }
 if(number == 54){
   if(modes.get(2)){
    hueOffset = map(value, 0 , 127, 0, 255); 
   }
   if(modes.get(6)){
   contrastMin = map(value, 0, 127, 20, -180);
   }
   if(modes.get(9)){
    gradRotSpeed = map(value, 0 , 127, 900, 10); 
   }
 }
 if(number == 55){
   if(modes.get(2)){
     alpha = map(value, 0, 127, 0 ,255);
   }
   if(modes.get(6)){
   contrastMax = map(value, 0, 127, 235, 360);
   }
   if(modes.get(9)){
    gradAngle = map(value, 0 , 127, 0, 0.025); 
   }
 }
 if(number == 56){
   currentAngle = map(value, 0, 127, 0, TWO_PI);
   lightReset(Lights3Ch);
   if(modes.get(6)){
    alpha = map(value, 0, 127, 0 ,255); 
   }
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
  if(note.pitch() == 63){
    for(int i = 0; i < modes.size(); i++){
   if(i == 7){
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
 if(note.pitch() == 48){
   for(int i = 0; i < modes.size(); i++){
   if(i == 8){
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
 if(note.pitch() == 49){
   for(int i = 0; i < modes.size(); i++){
   if(i == 9){
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
 if(note.pitch() == 50){
   for(int i = 0; i < modes.size(); i++){
   if(i == 10){
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
 if(note.pitch() == 51){
   for(int i = 0; i < modes.size(); i++){
   if(i == 11){
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
 if(note.pitch() == 98){
    if(oneColor == true){
   oneColor = false; 
  }
  else{
   oneColor = true; 
  }
 }
 if(note.pitch() == 0){
   if(noiseMode != 0){
    noiseMode = 0; 
   }
 }
 if(note.pitch() == 1){
   if(noiseMode != 1){
    noiseMode = 1; 
   }
 }
 if(note.pitch() == 2){
   if(noiseMode != 2){
    noiseMode = 2; 
   }
 }
 if(note.pitch() == 89){
   if(colSwitch == true){
    colSwitch = false;
   }
   else{
    colSwitch = true; 
   }
 }
 if(note.pitch() == 70){
  if(colSwitch == true){
   
   println("Background: " + hex(color(hue, saturation, brightness)));  
  }else{
   println("Secondary: " + hex(color(hue2, saturation2, brightness2)));  
  }
 }
}