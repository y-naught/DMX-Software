class RadialGradient{
 float hue;
 float saturation;
 float brightness;
 //how many circles there are -- the larger the number the smoother the gradient
 float smoothness;
 float speed;
 
 RadialGradient(float sm, float sp){
  hue = 0;
  saturation = 255;
  brightness = 255;
  smoothness = sm;
  speed = sp;
 }
 
 void display(PGraphics g){
   
   float radius = 1;
   float distance = width * 1.5 / smoothness;
   colorMode(HSB, 255, 255, 255);
   
  for(int i = 0; i < smoothness; i++){
    fill(hue, saturation, brightness);
    noStroke();
    g.ellipse(width / 2, height / 2, radius, radius);
    radius += distance;
    hue = (hue + speed) % 255;
  }
 }
}