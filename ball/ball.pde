//the ball class that has check edges functions and a basic physics engine
class Ball{
 PVector location;
 PVector velocity;
 PVector acceleration;
 boolean bounce = true;
 float sz;
 
 //constructor takes just the size of the ball
 Ball(float s){
   location = new PVector(random(width), random(height));
   velocity = new PVector(random(-3, 3), random(-3,3));
   acceleration = new PVector(0,0);
   sz = s;
 }
 
 //allows for switching whether the ball bounce or wrap around the screen
 void checkEdges(){
   if(bounce == true){
   if(location.x <= 0 || location.x >= width){
     velocity.mult(-1);
   }
   if(location.y <= 0 || location.y >=height){
    velocity.mult(-1); 
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
 void update(){
   velocity.add(acceleration);
   location.add(velocity);
   acceleration.mult(0);
 }
 
 //takes the PGraphics you want to effect and applies the ball to it
 void display(PGraphics img){
   img.ellipse(location.x, location.y, sz, sz);
 }
 
 //capibility of adding an outside force on each ball
 void applyForce(PVector force){
  acceleration.add(force); 
 }
}