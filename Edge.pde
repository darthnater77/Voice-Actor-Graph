// Code from Visualizing Data, First Edition, Copyright 2008 Ben Fry.
// Based on the GraphLayout example by Sun Microsystems.

class Edge {
  Node from;
  Node to;
  float len;

  Edge(Node from, Node to) {
    this.from = from;
    this.to = to;  
    if (this.from.count > 1){
      for (int i = 0; i < edgeCount; i++){
        if (edges[i].from == this.from)
          edges[i].len = 85 + (this.from.count-1)*20;
      }
      len = 85 + (this.from.count-1)*20;
    }
    else
      this.len = 85;
  }
  
  void relax() {
    float vx = to.x - from.x;
    float vy = to.y - from.y;
    float d = mag(vx, vy);
    if (d > 0) {
      float f = (len - d) / (d * 10);
      float dx = f * vx;
      float dy = f * vy;
      to.dx += dx;
      to.dy += dy;
      from.dx -= dx;
      from.dy -= dy;
    }
  }

  void draw() {
    stroke(edgeColor);
    strokeWeight(.5);
    line(from.x, from.y, to.x, to.y);
  }
}
