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
public final color red = #d88b25;
public final color blue = #503ba0;

public static final int NumberOfIka = 4;
public static final int NumberOfteams = 4;




void setup() {
  frameRate(25);
  size(600, 600);
  printArray(PFont.list());
  f = createFont("ikamodoki", 14);
  textFont(f);
  minim = new Minim(this);
  bgmPlayer = minim.loadFile("bgm.mp3");
  sePlayer = minim.loadFile("dead.mp3");
  bgmPlayer.play();

  ikaShape = loadShape("ika3.svg");


  cells = new Cell[width/cellSize][height/cellSize];
  for(int i = 0; i < width/cellSize; i++){
    for(int j = 0; j < height/cellSize; j++) cells[i][j] = new Cell();
    //Arrays.fill(cells[i],new Cell());
  }


  noStroke();
  background(black);
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
    text(teams[i].teamName + String.valueOf(teams[i].paintPoint) + "P", 100,100 + i * 150);
    for(int j = 0; j < NumberOfIka; j++){

      text(String.valueOf(j+1) +"ゴウ \n" +teams[i].members[j].paintPoint +"P \n" + weaponStr[teams[i].members[j].weapon] + "\nキル "   + teams[i].members[j].kill + "\n デス " + teams[i].members[j].death , 100 + j* 80 ,100 + i * 150 + 20);


    }


  }





    /*
    int redCount = 0;
    int blueCount= 0;
    for (int x=0; x<width/cellSize; x++) {
    for (int y=0; y<height/cellSize; y++) {
      if(cells[x][y].myColor == red)   redCount++;
      if(cells[x][y].myColor == blue) blueCount++;
      }
    }

    for ()

  text("アルファチーム " + String.valueOf(redCount) + "P" + "\n ブラボーチーム " +String.valueOf(blueCount) + "P", width/2,height/2);
  println("アルファチーム " + String.valueOf(redCount) + "P" + "\n ブラボーチーム " +String.valueOf(blueCount) + "P");
  */
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