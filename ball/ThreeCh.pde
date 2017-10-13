class ThreeCh{
  int[] channel;
  color c;
  PVector location;
  float sz = 20;
  
  ThreeCh(int stCh, PVector loc){
   channel = new int[3];
   for(int i = stCh; i < stCh + channel.length; i++){
    channel[i - stCh] =  i;
   }
   location = loc.get();
  }
  
  color sampleColor(PImage img){
    img.loadPixels();
    c = color(img.pixels[int(location.x) + int(location.y) * img.width]);
    img.updatePixels();
    return c;
  }
  
  void move(float x, float y){
    location.x = x;
    location.y = y;
  }
  
  void display(){
    noStroke();
    fill(255);
   rect(location.x, location.y, sz, sz);
  }
}