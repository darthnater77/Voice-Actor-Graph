// Code from Visualizing Data, First Edition, Copyright 2008 Ben Fry.
// Based on the GraphLayout example by Sun Microsystems.

class Edge {
  Node from;
  Node to;
  float len;
  int count;
  StringList labels;
  boolean highlighted;

  Edge(Node from, Node to) {
    this.from = from;
    this.to = to;
    this.len = 200;
    labels = new StringList();
  }
  
  void increment(String label) {
    count++;
    labels.append(label);
  }
  
  String getLabel(int i){
    return labels.get(i);
  }
  
  boolean hasLabel(String label){
    return labels.hasValue(label);
  }
    
  void relax() {
    float vx = to.x - from.x;
    float vy = to.y - from.y;
    float d = mag(vx, vy);
    if (d > 0) {
      float f = (len - d) / (d * 3);
      float dx = f * vx;
      float dy = f * vy;
      to.dx += dx;
      to.dy += dy;
      from.dx -= dx;
      from.dy -= dy;
    }
  }

  void draw() {
    if (to.highlight && from.highlight)
      highlighted = true;
    else
      highlighted = false;
    stroke(decideColor());
    strokeWeight(count/2);
    line(from.x, from.y, to.x, to.y);
  }
  
  color decideColor(){
    if (highlighted)
      return highlightColor;
    else
      return edgeColor;
  }
}
