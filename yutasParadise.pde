import java.util.Random;
import ddf.minim.*;
import java.util.Arrays;

Minim minim;
AudioPlayer bgmPlayer;
AudioPlayer sePlayer;

PShape ikaShape;
PFont f;

int i = 0;
int x = 0;


public int cellSize = 10;
public Cell[][] cells;
Team[] teams;

public final color black = (12);

public static final int NumberOfIka = 4;
public static final int NumberOfteams = 4;

void settings(){
  size(600, 600);
}

void setup() {

  frameRate(25);
 // font settings
  printArray(PFont.list());
  f = createFont("ikamodoki", 12);
  textFont(f);

  // sound settings
  minim = new Minim(this);
  bgmPlayer = minim.loadFile("bgm.mp3");
  sePlayer = minim.loadFile("dead.mp3");
  bgmPlayer.play();

  // shape settings
  ikaShape = loadShape("ika3.svg");

  // cell initialization
  cells = new Cell[width/cellSize][height/cellSize];
  for(int i = 0; i < width/cellSize; i++){
    for(int j = 0; j < height/cellSize; j++) cells[i][j] = new Cell();
  }

  // 背景とかの整形
  noStroke();
  background(black);

  // team initialization
  teams = new Team[NumberOfteams];
  for(int i = 0; i < NumberOfteams; i++){
    teams[i] = new Team(i);
  }

}

void draw() {
  int timer = millis();
  fill(0,15);
  rect(0, 0, width, height);

  for (int x=0; x<width/cellSize; x++) {
    for (int y=0; y<height/cellSize; y++) {
      if(cells[x][y].state == BLANK) fill(black);
      else fill(teams[cells[x][y].teamID].teamColor);

      rect (x*cellSize, y*cellSize, cellSize, cellSize);
    }
  }

  fill(255);

  if (timer <= 60000){
  for(int i = 0; i < teams.length; i++){
      teams[i].Paint();
      }

}else{
  for (int x=0; x<width/cellSize; x++) {
  for (int y=0; y<height/cellSize; y++) {
    if(cells[x][y].state != BLANK){
      teams[cells[x][y].teamID].paintPoint++;
      teams[cells[x][y].teamID].members[cells[x][y].whoPainted].paintPoint++;

    }

  }

}
  for(int i = 0; i < teams.length ; i++ ){
    text(teams[i].teamName + String.valueOf(teams[i].paintPoint) + "P", 100,50 + i * 140);
    for(int j = 0; j < NumberOfIka; j++){
      text(String.valueOf(j+1) +"ゴウ \n" + teams[i].members[j].paintPoint +"P \n"
      + weaponStr[teams[i].members[j].weapon] + "\nキル "
      + teams[i].members[j].kill + "\nデス " + teams[i].members[j].death , 100 + j* 80 ,50 + i * 140 + 20);

    }
  }

  noLoop();



}
}

void stop()
{
  bgmPlayer.close();
  sePlayer.close();
  minim.stop();
  super.stop();
}
