// Code from Visualizing Data, First Edition, Copyright 2008 Ben Fry.
// Based on the GraphLayout example by Sun Microsystems.

class Node {
  float x, y;
  float dx, dy;
  boolean fixed;
  boolean highlight;
  boolean type;
  String label, printLabel;
  int count, size;
  int maxSize = 125;

  Node(String label) {
    String[] hold = split(label, ":");
    printLabel = join(hold, "\n");
    this.label = label;
    x = random(200+maxSize, width-maxSize);
    y = random(maxSize, height-maxSize);
  }
  
  void increment() {
    count++;
  }
    
  void relax() {
    float ddx = 0;
    float ddy = 0;

    for (int j = 0; j < nodeCount; j++) {
      Node n = nodes[j];
      if (n != this) {
        float vx = x - n.x;
        float vy = y - n.y;
        float lensq = vx * vx + vy * vy;
        if (lensq < size || lensq < n.size) {
          ddx += random(5*n.size);
          ddy += random(5*n.size);
        } else {
          ddx += vx / lensq;
          ddy += vy / lensq;
        }
      }
    }
    float dlen = mag(ddx, ddy);
    if (dlen > 0) {
      dx += ddx / dlen;
      dy += ddy / dlen;
    }
  }

  void update() {
    if (!fixed) {      
      x += constrain(dx, -5, 5);
      y += constrain(dy, -5, 5);
      
      x = constrain(x, 200+size/1.5, width-size/1.5);
      y = constrain(y, size/1.5, height-size/1.5);
    }
    dx /= 2;
    dy /= 2;
  }
  
  void typeCheck(){
    if (type)
      size = count*5;
    else{
      size = maxSize;
      
    }
  }

  void draw() {
    fill(decideColor());
    stroke(0);
    strokeWeight(0.5);
    
    ellipse(x, y, size, size);
    float w = textWidth(printLabel);

    fill(0);
    textAlign(CENTER, CENTER);
    if (size > w+2)
      text(printLabel, x, y);
    else if (highlight)
      text(printLabel, x, y - size/2 - 10);
    checkHighlight(false);
  }
  
  void checkHighlight(boolean check){
    if(dist(mouseX, mouseY, x, y) < size/2 || check){
      for(int i = 0; i < edgeCount; i++){
        if (edges[i].to == this || edges[i].from == this){
          edges[i].to.highlight = true;
          edges[i].from.highlight = true;
        }
      }
    }
    else{
      highlight = false;
    }
  }
  
  color decideColor(){
    if (this == selection)
      return selectColor;
    else if (highlight)
      return highlightColor;
    else if (!type)
      if (fixed)
        return gameFixed;
      else
        return gameColor;
    else if (fixed)
      return fixedColor;
    else
      return nodeColor;
  }
}

