class Particle{
 PVector location;
 PVector velocity;
 float sz;
 
 Particle(float s){
  location = new PVector(random(0, width), 0);
  velocity = new PVector(0, random(3, 7));
  sz = s;
 }
 
 void update(){
  location.add(velocity);
 }
 
 void display(PGraphics g){
   g.ellipse(location.x, location.y, sz, sz);
 }
 boolean isDead(){
  if(location.y > height){
   return true; 
  }else{
   return false; 
  }
 }
}