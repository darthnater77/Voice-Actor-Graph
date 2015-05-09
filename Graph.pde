// Code from Visualizing Data, First Edition, Copyright 2008 Ben Fry.
// Based on the GraphLayout example by Sun Microsystems.

BufferedReader reader;
StringList actors;
StringList games;
boolean highlight;

int nodeCount;
Node[] nodes = new Node[100];
HashMap nodeTable = new HashMap();

int edgeCount;
Edge[] edges = new Edge[500];

static final color nodeColor = #5699FF;
static final color selectColor = #A9FF00;
static final color fixedColor = #333333;
static final color highlightColor = #11FFFF;
static final color gameColor = #1BB200;
static final color gameFixed = #71FF58;
static final color edgeColor = #000000;
static final color textHighlight = #C64DFF;

PFont font;

void setup() {
  highlight = false;
  size(1200, 700);  
  loadData();
  println(edgeCount);
  font = createFont("SansSerif", 10);
  textFont(font);  
  smooth();
}

void loadData(){
  String[] lines = loadStrings("gamePages.txt");
  actors = new StringList();
  games = new StringList();
  for (int i = 0; i < lines.length; i++)
    readParseURL(lines[i]);
  for (int i = 0; i < nodeCount; i++)
    nodes[i].typeCheck();
  games.sort();
}

void readParseURL(String url){
  actors.clear();
  String edgeLabel;
  int idx, idx2;
  
  reader = createReader(url);
  String line = "";
  String html = "";
  try{
    line = reader.readLine();
    while (line != null){
      html += line;
      line = reader.readLine();
    }
  }
  catch (Exception e){
    println("error parsing file: " + e.toString());
  }

  idx = html.indexOf("<title>");
  idx2 = html.indexOf("- IMDb");
  edgeLabel = html.substring(idx+7,idx2-18).trim();
  if (!games.hasValue(edgeLabel))
    games.append(edgeLabel);
  
  idx = html.indexOf("itemprop='url'> <span class=\"itemprop\" itemprop=\"name\">", idx+55);
  while(idx != -1){
    idx2 = html.indexOf("</span>", idx+55);
    actors.append(html.substring(idx+55,idx2).trim());
    idx = html.indexOf("itemprop='url'> <span class=\"itemprop\" itemprop=\"name\">", idx+55);
  }
  
  for (int i = 0; i < actors.size()-1; i++){
    addEdge(actors.get(i), edgeLabel);
  }    
}


void addEdge(String fromLabel, String toLabel) {
  Node from = findNode(fromLabel);
  Node to = findNode(toLabel);
  from.increment();
  from.type = false;
  to.increment();
  from.type = true;
  
  Edge e = new Edge(from, to);
  if (edgeCount == edges.length) {
    edges = (Edge[]) expand(edges);
  }
  edges[edgeCount++] = e;
}


Node findNode(String label) {
  Node n = (Node) nodeTable.get(label);
  if (n == null) {
    return addNode(label);
  }
  return n;
}


Node addNode(String label) {
  Node n = new Node(label);  
  if (nodeCount == nodes.length) {
    nodes = (Node[]) expand(nodes);
  }
  nodeTable.put(label, n);
  nodes[nodeCount++] = n;  
  return n;
}


void draw() {
  if (record) {
    beginRecord(PDF, "output.pdf");
  } 
  background(255);
  for (int i = 0; i < edgeCount; i++) {
    edges[i].relax();
  }
  for (int i = 0; i < nodeCount; i++) {
    nodes[i].relax();
  }
  for (int i = 0; i < nodeCount; i++) {
    nodes[i].update();
  }
  for (int i = 0; i < edgeCount; i++) {
    edges[i].draw();
  }
  for (int i = 0; i < nodeCount; i++) {
    if (!nodes[i].highlight)
      nodes[i].draw();    
  }
  for (int i = 0; i < nodeCount; i++) {
    if (nodes[i].highlight)
      nodes[i].draw();    
  }
  
  drawList();
  
  if (record) {
    endRecord();
    record = false;
  }
}

void drawList(){
  noStroke();
  fill(200);
  rect(0, 0, 200, height);
  int step = 20;
  int start = height/2 - games.size()/2*step;
  textAlign(LEFT);
  for (int i = 0; i < games.size(); i++){
    if (mouseX > 0 && mouseX < 250 && mouseY > start+(i-1)*step && mouseY < start+i*step){
      fill(textHighlight);
      for (int j = 0; j < nodeCount; j++){
        if (games.get(i).equals(nodes[j].label)){
          nodes[j].checkHighlight(true);
        }
      }
    }
    else{
      fill(0);
    }
    text(games.get(i), 10, start + i*step);
  }
}

boolean record;

void keyPressed(){
  if (key == 'r')
    record = true;
}

Node selection;

void mousePressed(){
  // Ignore anything greater than this distance
  float closest = 20;
  for (int i = 0; i < nodeCount; i++) {
    Node n = nodes[i];
    float d = dist(mouseX, mouseY, n.x, n.y);
    if (d < closest) {
      selection = n;
      closest = d;
    }
  }
  if (selection != null) {
    if (mouseButton == LEFT) {
      selection.fixed = true;
    } else if (mouseButton == RIGHT) {
      selection.fixed = false;
    }
  }
}

void mouseDragged() {
  if (selection != null) {
    if (mouseX <= width && mouseX > 250)
      selection.x = mouseX;
    else if(mouseX > width)
      selection.x = width;
    else
      selection.x = 250;
    if (mouseY <= height && mouseY >= 0)
      selection.y = mouseY;
    else if (mouseY > height)
      selection.y = height;
    else
      selection.y = 0;
  }
}


void mouseReleased() {
  selection = null;
}
