// Code from Visualizing Data, First Edition, Copyright 2008 Ben Fry.
// Based on the GraphLayout example by Sun Microsystems.

BufferedReader reader;
StringList actors;
StringList games;
int drawCount;
boolean highlight;
int count;
int nodeX, nodeY;

int nodeCount;
Node[] nodes = new Node[100];
HashMap nodeTable = new HashMap();

int altNodeCount;
Node[] altNodes = new Node[100];
HashMap altNodeTable = new HashMap();

int edgeCount;
Edge[] edges = new Edge[500];

int altEdgeCount;
Edge[] altEdges = new Edge[500];


static final color nodeColor = #BBBBBB;
static final color selectColor = #FF3030;
static final color fixedColor = #FF8080;
static final color highlightColor = #9999FF;
static final color edgeColor = #000000;

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
  
  nodeX = (int) random(width);
  nodeY = (int) random(height);
  
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
    for (int j = i+1; j < actors.size(); j++){
      addEdge(actors.get(i), actors.get(j), edgeLabel, nodeX, nodeY);
    }
  }    
}


void addEdge(String fromLabel, String toLabel, String edgeLabel, int x, int y) {

  Node from = findNode(fromLabel, x, y);
  Node to = findNode(toLabel, x, y);
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

Node findNode(String label, int x, int y) {
  Node n = (Node) nodeTable.get(label);
  if (n == null) {
    return addNode(label, x, y);
  }
  return n;
}


Node addNode(String label, int x, int y) {
  Node n = new Node(label, x, y);  
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
  fill(0);
  textAlign(LEFT);
  int step = 20;
  int start = height/2 - games.size()/2*step;
  for (int i = 0; i < games.size(); i++){
    if (mouseX > 0 && mouseX < 250 && mouseY > start+(i-1)*step && mouseY < start+i*step){
      fill(highlightColor);
      text(games.get(i), 20, start + i*step);
      highlight(games.get(i));
    }
    else{
      fill(0);
      text(games.get(i), 10, start + i*step);
    }
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
  drawCount = 120;
}
