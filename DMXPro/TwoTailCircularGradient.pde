class TwoCirGrad{
  color c1;
  color c2;
  color c3;
  float angle = 0;
  
  TwoCirGrad(){
    c1 = color(0);
    c2 = color(0);
    c3 = color(0);
  }
  
  void update(PGraphics g, float numLines , float speed, color tempC1, color tempC2, color tempC3){
    g.colorMode(HSB);
    
    c1 = tempC1;
    c2 = tempC2;
    c3 = tempC3;
    g.background(c3);
    g.strokeWeight(1);
    
    angle = 0;
   
    
    for(int i = 0; i < numLines; i++){
      angle += speed;
     if(i < numLines / 4){
        angle += speed;
       g.pushMatrix();
       g.stroke(lerpColor(c1, c2, map(i, 0, numLines /4, 0, 1.0)));
       g.translate(width / 2, height / 2);
       g.line(0,0,width / 2 * sin( i * angle/ numLines /2), height / 2 * cos(i * angle/ numLines /2));
       g.popMatrix();
     }
       else if(i > numLines / 4 && i < numLines / 2){
       g.pushMatrix();
       g.stroke(lerpColor(c2, c1, map(i, 0, numLines / 4, 0, 1.0)));
       g.translate(width / 2, height / 2);
       g.line(0,0,width / 2 * sin(i * angle/ numLines /2), height / 2 * cos(i * angle/ numLines / 2));
       g.popMatrix();
       }
     }
     /*
     else{
       g.pushMatrix();
       g.stroke(lerpColor(c2, c1, i / numLines*2));
       g.translate(width / 2, height / 2);
       g.line(0,0,width / 2 * sin(i * angle / numLines / 2), height / 2 * cos(i * angle / numLines / 2));
       g.popMatrix();
       
       g.pushMatrix();
       g.stroke(lerpColor(c2, c1, i / numLines*2));
       g.translate(width / 2, height / 2);
       g.line(0,0,width / 2 * sin(i * angle / numLines / 2 - TWO_PI), height / 2 * cos(i * angle / numLines / 2 - TWO_PI));
       g.popMatrix();
     }*/
    }
  }
  