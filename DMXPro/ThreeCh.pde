//assumes 3 channel RGB light that we are passing a signal into
class ThreeCh{
  int[] channel;
  color c;
  PVector location;
  float sz = 20;
  
  //constructor takes the first of the channels this light will occupy and a PVector for location in window
  ThreeCh(int stCh, PVector loc){
   channel = new int[3];
   //stores the channel numbers for RGB
   for(int i = stCh; i < stCh + channel.length; i++){
    channel[i - stCh] =  i;
   }
   //switch this to the static PVector method
   location = loc.get();
  }
  
  //returns a color from the layer passed into the function
  color sampleColor(PGraphics img){
    img.loadPixels();
    int redTotal = 0;
    int greenTotal = 0;
    int blueTotal = 0;
    //finds the pixel it should reference based on the lights location on the sketch
    for(int i = -1; i <= 1; i++){
      for(int j = -1; j <= 1; j++){
        color cn = color(img.pixels[int(location.x + i) + int(location.y + j) * img.width]);
        redTotal += red(cn);
        greenTotal += green(cn);
        blueTotal += blue(cn);
      }
    }
    img.updatePixels();
    //returns the color it extracts from that given pixel in the image
    c = color(redTotal / 9, greenTotal / 9, blueTotal / 9);
    return c;
  }
  
  //a method for moving the light
  void move(float x, float y){
    location.x = x;
    location.y = y;
  }
  
  //a method for displaying the light on the screen
  void display(){
    noStroke();
    fill(255);
    rect(location.x, location.y, sz, sz);
    fill(0);
    text(channel[0], location.x - sz / 2, location.y + sz / 4);
  }
}