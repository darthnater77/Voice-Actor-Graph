// Code from Visualizing Data, First Edition, Copyright 2008 Ben Fry.
// Based on the GraphLayout example by Sun Microsystems.


class Node {
  float x, y;
  float dx, dy;
  boolean fixed;
  boolean highlight;
  String label;
  int count;

  Node(String label, int a, int b) {
    this.label = label;
    x = a;
    y = b;
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
        if (lensq == 0) {
          ddx += random(1);
          ddy += random(1);
        } else if (lensq < 100*100) {
          ddx += vx / lensq;
          ddy += vy / lensq;
        }
      }
    }
    float dlen = mag(ddx, ddy) / 2;
    if (dlen > 0) {
      dx += ddx / dlen;
      dy += ddy / dlen;
    }
  }

  void update() {
    if (!fixed) {      
      x += constrain(dx, -5, 5);
      y += constrain(dy, -5, 5);
      
      x = constrain(x, 250, width);
      y = constrain(y, 0, height);
    }
    dx /= 2;
    dy /= 2;
  }

  void draw() {
    fill(decideColor());
    stroke(0);
    strokeWeight(0.5);
    
    ellipse(x, y, count, count);
    float w = textWidth(label);

    fill(0);
    textAlign(CENTER, CENTER);
    if (count > w+2)
      text(label, x, y);
    else if (dist(mouseX, mouseY, x, y) < count/2 || highlight)
      text(label, x, y - count/2 - 10);
  }
  
  color decideColor(){
    if (this == selection)
      return selectColor;
    else if (highlight)
      return highlightColor;
    else if (fixed)
      return fixedColor;
    else
      return nodeColor;
  }
}

