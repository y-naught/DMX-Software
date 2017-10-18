class PNoise{
  
  int noiseMode = 0;
  float increment;
  float moveX;
  float moveY;
  float hue;
  float saturation;
  float brightness;
  float alpha;
  float contrastMin = -10;
  float contrastMax = 265;
  float offX;
  float curX;
  float offY;
  float curY;
  
  //pass all the global variables into the noise function
  PNoise(float hu, float sat, float bri,float al, float mx, float my, float inc){
    increment = inc;
    moveX = mx;
    moveY = my;
    hue = hu;
    saturation = sat;
    brightness = bri;
    alpha = al;
    offX = 0.0;
    curX = 0.0;
    offY = 0.0;
    curY = 0.0;
  }
  
  
  void update(PGraphics g, float hu, float sat, float bri,float al, float mx, float my, float inc, int nm,float cMin, float cMax){
    g.colorMode(HSB);
    g.loadPixels();
    
    //load the global function variables
    hue = hu;
    saturation = sat;
    brightness = bri;
    alpha = al;
    moveX = mx;
    moveY = my;
    increment = inc;
    noiseMode = nm;
    contrastMin = cMin;
    contrastMax = cMax;
    
    //iterate for all the x pixels
    for(int x = 0; x < width; x++){
    offX += inc;
   
   //iterate for all the y pixels
     for( int y = 0; y < height; y++){
     offY += inc;
     
     //setup a switcher for how the noise is calculated
     if(noiseMode > 2){
      noiseMode = 0;
     }
     if(noiseMode == 0){
      brightness = noise(offX, offY) * 255;
      brightness = map(brightness, 0, 255, contrastMin, contrastMax);
     }
     else if(noiseMode == 1){
      saturation = noise(offX, offY) * 255; 
      saturation = map(saturation, 0, 255, contrastMin, contrastMax);
     }
     else if(noiseMode == 2){
      hue = noise(offX, offY) *255;
      hue = map(hue, 0, 255, contrastMin, contrastMax);
     }
     
     //set the new color
     g.pixels[x + y * width] = color(hue, saturation, brightness, alpha);
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