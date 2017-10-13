class Ball{
 PVector location;
 PVector velocity;
 PVector acceleration;
 boolean bounce = false;
 float sz;
 
 Ball(float s){
   location = new PVector(random(width), random(height));
   velocity = new PVector(random(-3, 3), random(-3,3));
   acceleration = new PVector(0,0);
   sz = s;
 }
 
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
 
 void update(){
   velocity.add(acceleration);
   location.add(velocity);
   acceleration.mult(0);
 }
 
 void display(PGraphics img){
   img.ellipse(location.x, location.y, sz, sz);
 }
 
 void applyForce(PVector force){
  acceleration.add(force); 
 }
}