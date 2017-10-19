class CirGradient{
 float angle;
 float weight;
 float speed;
 float numLines;
 color c1;
 color c2;
 
 CirGradient(){
  angle = 0;
  weight = 2;
  speed = 2;
  c1 = color(0, 255, 255);
  c2 = color(30, 255, 255);
  numLines = 30;
 }
 
 void update(){
   angle += frameCount / 60 % TWO_PI;
 }
 
 void display(PGraphics g){
   for(int i = 0; i < numLines; i++){
     color temp = lerpColor(c1, c2, map(i, 0 , numLines, 0, 1.0));
     color temp2 = lerpColor(c2, c1, map(i, 0 , numLines, 0, 1.0));
     if(i < numLines / 2){
      g.fill(temp); 
      g.line(width / 2, height / 2, width / 2 * sin(angle + i / 20), height / 2 * cos(angle + i / 20)); 
     }
     else if(i >= numLines / 2){
       g.fill(temp2);
       g.line(width / 2, height / 2, width / 2 * sin(angle), height / 2 * cos(angle));
     }
   }
 }
}