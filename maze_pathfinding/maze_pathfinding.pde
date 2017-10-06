/*
* Written by: Ginny Tice, 2017
 * Algorithm from here: https://en.wikipedia.org/wiki/Pathfinding
 * Specifically, I am following the steps listed under "Sample Algorithm"
 * Shout-out to Justin from my Computer Science with Java class at DMA for inspiring me to write this  
 */


// Size of cells
int cellSize = 40;


// Variables for timer
int interval = 500; //one square draws every half second 
int lastRecordedTime = 0;

// Colors for active/inactive cells
int wall = color(0, 200, 0); //green
int space = color(100); //grey
color start = #F3F70A; //yellow
color dest = #F024DC;  //pink
color path = #7A9FE8; //light blue


// Array of cells
char[][] cells; //contains character corresponding to cell type 
int[][] cellsCounters; //contains numeric counters corresponding to distance from destination cell
ArrayList<CellInfo> pointList; //queue for list of cells to be evaluated



boolean doingPathAnimation = false;
int curX;
int curY;


int startX;
int startY;
int destX;
int destY;


public void settings() {
  size (900, 800);
  noSmooth();
}


String[] lines;
String trimLine2 = "";

public void setup() {


  // This stroke will draw the background grid
  stroke(48);


  //Part 1: read in text file, save characters to cells array

  //https://processing.org/reference/loadStrings_.html
  //lines = loadStrings("justinMaze.txt");   //layout 1
  lines = loadStrings("MazeLayout.txt");  //layout 2
  //lines = loadStrings("maze.txt");   //layout 3: sample from wikipedia page


  println("there are " + lines.length + " lines");

  //find length of first line after removing spaces (columns)  
  for (int j=0; j< lines[0].length(); j++) { //loop over chars line
    if (lines[0].charAt(j) != ' ') 
      trimLine2+= lines[0].charAt(j);
  }

  //assume text file being read in is a rectangular grid
  //so just use the first line to find the number of columns
  cells = new char[trimLine2.length()][lines.length];
  cellsCounters = new int[trimLine2.length()][lines.length];

  println("there are: " + trimLine2.length() + " columns");

  for (int i = 0; i < lines.length; i++) { //for each line, each is a row
    println(lines[i]);

    //remove spaces from line
    String trimLine = "";
    for (int j=0; j< lines[i].length(); j++) { //loop over chars line
      if (lines[i].charAt(j) != ' ') 
        trimLine+= lines[i].charAt(j);
    }

    //Add chars to cells array, find start + dest,
    for (int j=0; j< trimLine.length(); j++) { //loop over chars line (j=x)
      cells[j][i] = trimLine.charAt(j);
      if (cells[j][i]== 'S') {
        startX = j;
        startY = i;
      } else if (cells[j][i]== 'O') {
        destX = j;
        destY = i;
      }
    }
  }

  println("start x: " + startX + " y: " + startY);
  println("dest x: " + destX + " y: " + destY);

  //Part 2: Add numbers to cellsCounters array - proper pathfinding algorithm
  //start at dest, continue until we find start

  //pointList is a queue, we examine first item in list, then remove it
  //adding a queue like this allows us to do a breadth-first search
  //can't do this recursively or we'd end up with depth first search
  pointList = new ArrayList<CellInfo>();

  //add dest cell first - start with dest counter = 1 because int arrays init to 0
  //every counter after this one will be a higher number, showing the distance from dest
  CellInfo dest = new CellInfo(destX, destY, 1);   
  pointList.add(dest);

  //we could stop the while loop when the starting point is found 
  //but let's keep going to show the whole algorithm
  while (pointList.size() != 0) {
    CellInfo c = pointList.get(0);

    //only set counter if the counter has not already been set
    if (cellsCounters[c.x][c.y] == 0) {
      cellsCounters[c.x][c.y] = c.counter; //transfer info from point queue to cellsCounters array
      addValidNeighbors(c); //add neighbors to queue (if any)
    }
    pointList.remove(0);  //now we're done so remove it!
  }


  //print out counters grid for debugging or learning
  for (int i = 0; i < lines.length; i++) { //for each line, each is a row
    for (int j=0; j< trimLine2.length(); j++) { //loop over chars line (j=x)
      if (cellsCounters[j][i] < 10)
        print ("0" + cellsCounters[j][i] + " "); //make it line up neatly
      else
        print (cellsCounters[j][i] + " ");
    }
    println();
  }


  //At this point the cellsCounters array is fully populated, so path can be shown visually

  //Part 3: Path Animation
  //set up variables for path animation
  curX = startX;
  curY = startY;
  doingPathAnimation = true; //start path animation!!!

  background(0); // Fill in black in case cells don't cover the whole window
}





void addValidNeighbors(CellInfo c) {

  //if left neighbor has space AND counter has not already been set
  if ((cells[c.x-1][c.y] == '_' || cells[c.x-1][c.y] == 'S')  && cellsCounters[c.x-1][c.y] == 0) {
    pointList.add(new CellInfo(c.x-1, c.y, c.counter+1));
  }

  //if right neighbor has space
  if ((cells[c.x+1][c.y] == '_' || cells[c.x+1][c.y] == 'S') && cellsCounters[c.x+1][c.y] == 0) {
    pointList.add(new CellInfo(c.x+1, c.y, c.counter+1));
  }

  //if top neighbor has space
  if ((cells[c.x][c.y-1] == '_' || cells[c.x][c.y-1] == 'S') && cellsCounters[c.x][c.y-1] == 0) {
    pointList.add(new CellInfo(c.x, c.y-1, c.counter+1));
  }

  //if bottom neighbor has space
  if ((cells[c.x][c.y+1] == '_' || cells[c.x][c.y+1] == 'S') && cellsCounters[c.x][c.y+1] == 0) {
    pointList.add(new CellInfo(c.x, c.y+1, c.counter+1));
  }
}





public void draw() {

  //Draw grid
  for (int x=0; x<trimLine2.length(); x++) {
    for (int y=0; y<lines.length; y++) {
      if (cells[x][y]== 'X') {
        fill(wall); // wall
      } else if (cells[x][y]== 'S') {
        fill(start); // starting positiion
      } else if (cells[x][y]== 'O') {
        fill(dest); // destination/goal
      } else if (cells[x][y]== 'P') {
        fill(path); //square on path from start to dest
      } else {
        fill(space); // space (no wall)
      }
      rect (x*cellSize, y*cellSize, cellSize, cellSize);
    }
  }


  //Path Animation: color in one square of the path every [interval] of time
  if (doingPathAnimation && millis()-lastRecordedTime>interval) {   
    pathIteration();
    lastRecordedTime = millis();
  }
}




//show one more square of path
void pathIteration() {
  //println("adding path " + curX + " " + curY);

  if (cells[curX][curY] == 'O') {
    doingPathAnimation = false;
    return;
  }

  //update array so we can color this path cell IF not start or dest
  if (cells[curX][curY] != 'S') {
    cells[curX][curY] = 'P'; //P for path
  }

  int counter = cellsCounters[curX][curY]; 

  //find next cell of path
  //if left cell has space AND counter is exactly one less than current counter
  if ((cells[curX-1][curY] == '_' || cells[curX-1][curY] == 'O') && cellsCounters[curX-1][curY] == counter-1) {
    curX = curX-1;
  }

  //if right cell has space AND counter is exactly one less than current counter
  else if ((cells[curX+1][curY] == '_' || cells[curX+1][curY] == 'O') && cellsCounters[curX+1][curY] == counter-1) {
    curX = curX+1;
  }

  //if top cell has space AND counter is exactly one less than current counter
  else if ((cells[curX][curY-1] == '_'  || cells[curX][curY-1] == 'O') && cellsCounters[curX][curY-1] == counter-1) {
    curY = curY-1;
  }

  //if bottom cell has space AND counter is exactly one less than current counter
  else if ((cells[curX][curY+1] == '_' || cells[curX][curY+1] == 'O') && cellsCounters[curX][curY+1] == counter-1) {
    curY = curY+1;
  }
}