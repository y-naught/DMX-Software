class RadialGradient{
 float hue;
 float saturation;
 float brightness;
 //how many circles there are -- the larger the number the smoother the gradient
 float smoothness;
 float speed;
 float radius = 1;
 
 RadialGradient(float sm, float sp){
  hue = 0;
  saturation = 200;
  brightness = 200;
  smoothness = sm;
  speed = sp;
 }
 
 void display(PGraphics g){
   //float distance = width * 1.5 / smoothness;
   g.colorMode(HSB);
   g.ellipseMode(RADIUS);
   g.noFill();
   g.strokeWeight(30);
   for(int i = 0; i < width / 1.5; i+=30){
    g.stroke(hue, saturation, brightness);
    g.ellipse(width / 2, height / 2, i, i);
    hue = (hue + 1.0) % 255;
  }
 }
}