//an object the culminates the particles
class Shower{
  
 //create the array list of particles
 ArrayList<Particle> Particles;
 int perFrame;
 float sz;
 //float particleSpeed = 0;
 //constructor takes number per frame and size of each particle
 Shower(int count, float s){
  Particles = new ArrayList<Particle>();
  perFrame = count;
  sz = s;
 }
 
 //calling this method in draw will run the particle shower
 //must have a graphic to apply the effect to as an argument of the method
 void run(PGraphics g, float hue, float saturation, float brightness, float particleSpeed, float nppf, float size){
   
   //adds particles every frame
   for(int i = 0; i < nppf; i++){
     Particles.add(new Particle(sz));
   }
   //Tests to see of the particle should be removed,
   //applies the changes to the characteristics of it, and draws it on the layer passed
   for(int i = 0; i < Particles.size(); i++){
    Particle p = Particles.get(i);
    if(p.isDead()){
      Particles.remove(i);
    }else{
     p.update(hue, saturation, brightness, particleSpeed, size);
     p.display(g);
    }
   }
 }
}

//a Particle class with a basic physics engine for use in multiple effect presets
class Particle{
 PVector location;
 PVector velocity;
 PVector acceleration;
 float sz;
 float hue = 0;
 float saturation = 0;
 float brightness = 255;
 float speed;
 int startFrame;
 
 Particle(float s){
  location = new PVector(random(0, width), 0);
  velocity = new PVector(0, random(3, 7));
  acceleration = new PVector(0, 0);
  sz = s;
  startFrame = frameCount;
 }
 
 //applying the physics for each particle
 void update(float hu, float sat, float bri, float Sp, float siz){
   sz = siz;
   speed = Sp;
   velocity.normalize();
   velocity.mult(speed);
  velocity.add(acceleration);
  location.add(velocity);
  hue = hu;
  saturation = sat;
  brightness = bri;
 }
 //takes the graphic you want to effect and adds the particle
 void display(PGraphics g){
   g.colorMode(HSB);
   g.fill(hue, saturation, brightness);
   g.noStroke();
   g.ellipse(location.x, location.y, sz, sz);
 }
 
 //a function that can be called to delete the particle after it leaves the display window
 boolean isDead(){
  if(frameCount - startFrame > 10000){
     return true;
   }
  else if(location.y > height){
   return true; 
  }else{
   return false; 
  }
 }
}