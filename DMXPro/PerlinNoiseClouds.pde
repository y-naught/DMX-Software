class PNoise{
  
  float increment;
  float moveX;
  float moveY;
  float hue;
  float saturation;
  float brightness;
  float offX;
  float curX;
  float offY;
  float curY;
  
  PNoise(float hu, float sat, float bri, float mx, float my, float inc){
    increment = inc;
    moveX = mx;
    moveY = my;
    hue = hu;
    saturation = sat;
    brightness = bri;
    offX = 0.0;
    curX = 0.0;
    offY = 0.0;
    curY = 0.0;
  }
  
  void update(PGraphics g, float hu, float sat, float bri, float mx, float my, float inc){
    g.colorMode(HSB);
    g.loadPixels();
    
    hue = hu;
    saturation = sat;
    brightness = bri;
    moveX = mx;
    moveY = my;
    increment = inc;
    
    
    for(int x = 0; x < width; x++){
    offX += inc;
   
     for( int y = 0; y < height; y++){
     offY += inc;
     
     brightness = noise(offX, offY) * 255;
     
     g.pixels[x + y * width] = color(hue, saturation, brightness);
   }
   offY = curY;
  }
  
  g.updatePixels();
  curX += moveX;
  offX = curX;
  curY += moveY;
  offY = curY;
  }
}