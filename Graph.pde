// Code from Visualizing Data, First Edition, Copyright 2008 Ben Fry.
// Based on the GraphLayout example by Sun Microsystems.

BufferedReader reader;
StringList actors;
StringList games;
int drawCount;
boolean highlight;
int count;

int nodeCount;
Node[] nodes = new Node[100];
HashMap nodeTable = new HashMap();

int edgeCount;
Edge[] edges = new Edge[500];


static final color nodeColor   = #F0C070;
static final color selectColor = #FF3030;
static final color fixedColor  = #FF8080;
static final color highlightColor = #0000FF;
static final color edgeColor   = #000000;

PFont font;

void setup() {
  count = 0;
  drawCount = 120;
  highlight = false;
  size(1000, 700);  
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
  edgeLabel = html.substring(idx+7,idx2).trim();
  if (!games.hasValue(edgeLabel))
    games.append(edgeLabel);
  
  idx = html.indexOf("itemprop='url'> <span class=\"itemprop\" itemprop=\"name\">", idx+55);
  while(idx != -1){
    idx2 = html.indexOf("</span>", idx+55);
    actors.append(html.substring(idx+55,idx2).trim());
    idx = html.indexOf("itemprop='url'> <span class=\"itemprop\" itemprop=\"name\">", idx+55);
  }
  
  for (int i = 0; i < actors.size()-1; i++){
    for (int j = i+1; j < actors.size(); j++){
      addEdge(actors.get(i), actors.get(j), edgeLabel);
    }
  }    
}


void addEdge(String fromLabel, String toLabel, String edgeLabel) {

  Node from = findNode(fromLabel);
  Node to = findNode(toLabel);
  from.increment();
  to.increment();
  
  for (int i = 0; i < edgeCount; i++) {
    if (edges[i].from == from && edges[i].to == to) {
      edges[i].increment(edgeLabel);
      return;
    }
  } 
  
  Edge e = new Edge(from, to);
  e.increment(edgeLabel);
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

  if (drawCount > 0){
    for (int i = 0; i < edgeCount; i++) {
      edges[i].relax();
    }
    for (int i = 0; i < nodeCount; i++) {
      nodes[i].relax();
    }
    for (int i = 0; i < nodeCount; i++) {
      nodes[i].update();
    }
    drawCount--;
  }
  
  for (int i = 0; i < edgeCount; i++) {
    edges[i].draw();
  }
  for (int i = 0; i < nodeCount; i++) {
    nodes[i].draw();
  }
  
  if (record) {
    endRecord();
    record = false;
  }
}

void highlight(String selected){
  for (int i = 0; i < nodeCount; i++){
    nodes[i].highlight = false;
  }
  for (int i = 0; i < edgeCount; i++){
    if (edges[i].hasLabel(selected)){
      edges[i].to.highlight = true;
      edges[i].from.highlight = true;
    }
  }
}


boolean record;

void keyPressed(){
  if (key == 'r'){
    record = true;
  }
  if (key == ' '){
    highlight(games.get(count));
    count++;
    if (count > games.size())
      count = 0;
  }
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
    selection.x = mouseX;
    selection.y = mouseY;
  }
}


void mouseReleased() {
  selection = null;
}
