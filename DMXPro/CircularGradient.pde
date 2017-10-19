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
  c1 = color(0, 255, 255, 255);
  c2 = color(50, 255, 255, 0);
  numLines = 600;
 }
 
 void update(){
 }
 
 void display(PGraphics g, float a, float sp, color col1, color col2){
   c1 = col1;
   c2 = col2;
   g.strokeWeight(5);
   angle = frameCount % sp / sp * TWO_PI;
   for(int i = 0; i < numLines; i++){
     angle += a;
     color temp = lerpColor(c1, c2, map(i, 0 , numLines, 0, 1.0));
     color temp2 = lerpColor(c2, c1, map(i, 0 , numLines, 0, 1.0));
     if(i < numLines / 2){
      g.stroke(temp);
      g.line(width / 2, height / 2, (width / 2 - 250 * sin(angle)),(height / 2) - 250 * cos(angle));
     }
     else if(i >= numLines / 2){
       g.stroke(temp2);
       g.line(width / 2, height / 2, (width / 2 - 250 * sin(angle)),(height / 2) - 250 * cos(angle));
     }
   }
 }
}