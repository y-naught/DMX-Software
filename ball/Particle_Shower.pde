class Shower{
 ArrayList<Particle> Particles;
 int perFrame;
 float sz;
 Shower(int count, float s){
  Particles = new ArrayList<Particle>();
  perFrame = count;
  sz = s;
 }
 
 void run(PGraphics g){
   for(int i = 0; i < perFrame; i++){
     Particles.add(new Particle(sz));
   }
   for(int i = 0; i < Particles.size(); i++){
    Particle p = Particles.get(i);
    if(p.isDead()){
      Particles.remove(i);
    }else{
     p.update();
     p.display(g);
    }
   }
 }
}

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