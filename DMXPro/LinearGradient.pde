class LinearGradient{
 
  int hue = 0;
  int saturation = 255;
  int brightness = 255;
  float spacing = 2;
  float colOffset = 10;
  color c1;
  color c2;
  
  LinearGradient(){
    c1 = color((hue), saturation, brightness);
    c2 = color((hue + colOffset % 255), saturation, brightness);
  }
  
  void updateColor(float hue, float saturation, float brightness, float offset){
    colOffset = offset;
    c1 = color((hue), saturation, brightness);
    c2 = color(((hue + colOffset) % 255), saturation, brightness);
  }
  
  void display(PGraphics g){
    g.background(0);
    g.strokeWeight(spacing);
    for(int i = 0; i < width; i += spacing){
    color c = lerpColor(c1, c2, map(i, 0, width, 0, 1.0));
    g.stroke(c);
    g.line(i, 0, i, height);
   }
  }
}