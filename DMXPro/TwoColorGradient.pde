class TwoColorGradient{
 
  PVector location;
  PVector velocity;
  float hue = 0;
  float saturation = 0;
  float brightness = 0;
  float hueOffset = 127;
  float gradWidth = 0;
  
  TwoColorGradient(){
   location = new PVector(-width / 2, 0);
   velocity = new PVector(1,0);
  }
  
  void display(PGraphics g, float gradSp,float hu,float sat,float bri, float wi){
    brightness = bri;
    hue = (hu + hueOffset) % 255;;
    saturation = sat;
    gradWidth = wi;
    velocity.normalize();
    velocity.mult(gradSp);
    location.add(velocity);
    g.colorMode(HSB);
    g.rectMode(CENTER);
    g.noStroke();
    g.fill(hue, saturation, brightness);
    g.rect(location.x, location.y, gradWidth, 1000);
  }
  
  void checkEdges(){
   if(location.x > width + gradWidth / 2 ){
    location.x = -gradWidth / 2; 
   }
  }
}