//the ball class that has check edges functions and a basic physics engine
class Ball{
 PVector location;
 PVector velocity;
 PVector acceleration;
 boolean bounce = true;
 float sz;
 float speed;
 float hue = 0;
 float saturation = 0;
 float brightness = 255;
 float hueOffset;
 
 //constructor takes just the size of the ball
 Ball(float s){
   location = new PVector(random(width), random(height));
   velocity = new PVector(random(-3, 3), random(-3,3));
   acceleration = new PVector(0,0);
   sz = s;
   float rand = random(1.0);
   if(rand < 0.10){
   hueOffset = 127;
   }
   else if(rand >= 0.10 && rand < 0.20){
    hueOffset = -20; 
   }
   else{
    hueOffset = 0; 
   }
 }
 
 //allows for switching whether the ball bounce or wrap around the screen
 void checkEdges(){
   if(bounce == true){
   if(location.x <= 0 || location.x >= width){
     velocity.x *=-1;
   }
   if(location.y <= 0 || location.y >=height){
    velocity.y *= -1; 
   }
   }else{
    if(location.x <= 0){
     location.x = width; 
    }
    if(location.x >= width){
     location.x = 0; 
    }
    if(location.y <= 0){
     location.y = height; 
    }
    if(location.y >= height){
     location.y = 0; 
    }
   }
 }
 
 //applies physics engine to each ball
 void update(float s, float sp, float hu, float sat, float bri, boolean oneC){
   velocity.normalize();
   velocity.mult(sp);
   velocity.add(acceleration);
   location.add(velocity);
   acceleration.mult(0);
   sz = s;
   if(oneC){
    hue = hu; 
   }
   else{
   hue = (hu + hueOffset) % 255;
   }
   saturation = sat;
   brightness = bri;
 }
 
 //takes the PGraphics you want to effect and applies the ball to it
 void display(PGraphics g){
   g.colorMode(HSB);
   g.fill(hue, saturation, brightness);
   g.noStroke();
   g.ellipse(location.x, location.y, sz, sz);
 }
 
 //capibility of adding an outside force on each ball
 void applyForce(PVector force){
  acceleration.add(force); 
 }
}