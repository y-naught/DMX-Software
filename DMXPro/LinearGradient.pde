class LinearGradient{
 
  int hue = 0;
  int saturation = 255;
  int brightness = 255;
  float spacing = 2;
  float colOffset = 10;
  color c1;
  color c2;
  
  //should change this to create an arraylist of colors
  LinearGradient(){
    c1 = color((hue), saturation, brightness);
    c2 = color((hue + colOffset % 255), saturation, brightness);
  }
  
  //should change to accomidate an array list of colors
  void updateColor(float hue, float saturation, float brightness, float offset){
    colOffset = offset;
    colorMode(HSB);
    c1 = color((hue % 255), saturation, brightness);
    c2 = color(((hue + colOffset) % 255), saturation, brightness);
  }
  
  //draw the gradient to the graphic passed to the function
  //should iterate through the list of colors and mapo between each one with lerp and a distance variable passed into the update function
  void display(PGraphics g){
    g.colorMode(HSB, 255,255,255);
    g.background(0);
    g.strokeWeight(spacing);
    for(int i = 0; i < width; i += spacing){
    color c = lerpColor(c1, c2, map(i, 0, width, 0, 1.0));
    g.stroke(c);
    g.line(i, 0, i, height);
   }
  }
}