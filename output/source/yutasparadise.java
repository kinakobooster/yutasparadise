import processing.core.*; 
import processing.data.*; 
import processing.event.*; 
import processing.opengl.*; 

import java.util.Random; 
import ddf.minim.*; 
import java.util.Arrays; 

import java.util.HashMap; 
import java.util.ArrayList; 
import java.io.File; 
import java.io.BufferedReader; 
import java.io.PrintWriter; 
import java.io.InputStream; 
import java.io.OutputStream; 
import java.io.IOException; 

public class yutasparadise extends PApplet {

final int BLANK = 0;
final int PAINTED = 1;
final int WALL = 2;


class Cell{

int state;

int teamID;
// color myColor;
int whoPainted;

Cell(){
  this.state = BLANK;
//  this.myColor = black;
}

public void Painted(int teamID,int ikaNumber){
  this.state = PAINTED;
//  this.myColor = teamColor;
  this.teamID = teamID;
  this.whoPainted = ikaNumber;


}



}
final String[] teamNameDefault = {"\u30a2\u30eb\u30d5\u30a1\u30c1\u30fc\u30e0","\u30d6\u30e9\u30dc\u30fc\u30c1\u30fc\u30e0","\u30af\u30ec\u30a4\u30b8\u30fc\u30bd\u30eb\u30c8","\u30c0\u30a4\u30d6\u30c4\u30ec\u30af\u30a4\u30a8\u30e0"};
final int[] teamColorDefault = {0xffd88b25, 0xff503ba0,0xff428944,0xffc25779};
final int PADDING = 40;

class Team{
  int teamID;
  int teamColor;
  int respawnx;
  int respawny;
  String teamName;
  Squid[] members = new Squid[NumberOfIka];
  int paintPoint;

  Team(int teamID){
    this.teamID = teamID;
    this.teamColor = teamColorDefault[teamID];
    this.paintPoint = 0;

    switch (teamID){
      case 0:
      this.respawnx = PADDING;
      this.respawny = PADDING;
      break;

      case 1:
      this.respawnx = width  - PADDING;
      this.respawny = height - PADDING;
      break;

      case 2:
      this.respawnx = PADDING;
      this.respawny = height - PADDING;
      break;

      case 3:
      this.respawnx = width  - PADDING;
      this.respawny = PADDING;
      break;

      default:
      break;
    }



    this.teamName = teamNameDefault[teamID];
    for (int i=0;i< NumberOfIka;i++){
        members[i] = new Squid(teamID, i);

        members[i].x = this.respawnx;
        members[i].y = this.respawny;

      }
    }
  public void Paint(){

    for(int i = 0; i < NumberOfIka; i++){

        members[i].Paint();
    }


  }


  }






public static final int SHOOTER = 0;
public static final int ROLLER  = 1;
public static final int CHARGER = 2;
public static final int[] reach = {8,1,20};
public static final int[] range = {2,4,2};
public static final int[] shotRate = {4,1,8};
public static final String[] weaponStr = {"\u30b7\u30e5\u30fc\u30bf\u30fc","\u30ed\u30fc\u30e9\u30fc","\u30c1\u30e3\u30fc\u30b8\u30e3\u30fc"};



public static final int UP = 0;
public static final int DOWN  = 1;
public static final int RIGHT = 2;
public static final int LEFT = 3;


class Squid {

    int weapon;
    int x;
    int y;
//    int respawnx;
//    int respawny;
    int vx;
    int vy;
    int ax;
    int ay;
    int direction;

    int ikaNumber;
    int life;
    int kill = 0;
    int death = 0;

//    color teamColor;
//    color enemyColor;
    int teamID;
    int paintPoint;

   boolean isPlaying;
   Squid(int teamID,int ikaNumber){

//    this.x = x;
//    this.y = y;
//    respawnx = x;
//    respawny = y;

    vx = 0;
    vy = 0;
    ax = 0;
    ay = 0;
//    this.teamColor = teamColor;
//    this.enemyColor = enemyColor;
    this.teamID = teamID;
    this.ikaNumber = ikaNumber;
    this.weapon = (teamID + ikaNumber) % 3;
    life = 3;
    paintPoint = 0;
    isPlaying = true;
  }


  public void RandomWalkAcc(){
    Random rnd = new Random();
    this.ax += -1 + (int)rnd.nextInt(3);
    this.ay += -1 + (int)rnd.nextInt(3);
    this.vx += this.ax;
    this.vy += this.ay;

  }

  public void RandomWalkVel(){
    Random rnd = new Random();
    this.vx += -1 + (int)rnd.nextInt(3);
    this.vy += -1 + (int)rnd.nextInt(3);
  }

  public void RandomWalkPos(){
    Random rnd = new Random();
    this.vx = -1 + (int)rnd.nextInt(3);
    this.vy = -1 + (int)rnd.nextInt(3);
  }

  public void SlowDown(){
    if(Math.abs(this.vx) > 5)  this.vx *= 0.8f;
    if(Math.abs(this.vy) > 5)  this.vy *= 0.8f;

  }
  public void isDead(){
    if(life == 0){
      death++;

      int deadx = Math.round(this.x / cellSize);
      int deady = Math.round(this.y / cellSize);
      int killTeamID  = cells[deadx][deady].teamID;
      int killSquidID = cells[deadx][deady].whoPainted;


      for (int i = 0;  i < 7  ; i++){
        for(int j = 0; j < 7 ; j++){
           if(i*i + j * j < 7*7 && (deadx + i <  width/cellSize) && (deady + j <  width/cellSize)
          && (deadx - i >  0) && (deady - j >  0) ){


             cells[deadx+i][deady+j].Painted(killTeamID, killSquidID);
             cells[deadx-i][deady+j].Painted(killTeamID, killSquidID);
             cells[deadx+i][deady-j].Painted(killTeamID, killSquidID);
             cells[deadx-i][deady-j].Painted(killTeamID, killSquidID);
           }
        }
      }


      teams[killTeamID].members[killSquidID].kill++;

      sePlayer.play();
      sePlayer.rewind();

      this.x = teams[this.teamID].respawnx;
      this.y = teams[this.teamID].respawny;
      this.life = 3;
      println("dead!");
    }


  }


  public void Walk(){

    this.x += this.vx;
    this.y += this.vy;

  }

  public void StopWalking(){
    this.isPlaying = false;
  }


  public void ToBeInFrame(){
    while(this.x < 0)          this.x = this.x + width;
    while(this.x >= width)     this.x = this.x - width;
    while(this.y < 0)          this.y = this.y + height;
    while(this.y >= height)    this.y = this.y - height;
  }

    public void ReflectWall(){
      if(this.x < 0){
      this.x  = 1;
      this.vx *= -1;
      }
      if(this.x >= width){
      this.x  = width-1;
      this.vx *= -1;
      }
      if(this.y < 0){
      this.y  = 1;
      this.vy *= -1;
      }
      if(this.y >= height){
      this.y  = height-1;
      this.vy *= -1;
      }

    }

  public void DrawSquid(){

        pushMatrix();
        translate(this.x,this.y);

        if(Math.abs(vx) >= Math.abs(vy)){
             if(vx >= 0){rotate(PI     /2); direction = RIGHT ;}
             else{       rotate(PI  *3 /2); direction = LEFT  ;}
        }else{
             if(vy >= 0){rotate(PI       ); direction = UP ;}
              else{      rotate(0        ); direction = DOWN ;}
        }


        shape(ikaShape,0,0,5*this.life,5*this.life);
        popMatrix();

  }

  public void Shot(){



    switch(direction){
      case UP:
      for (int i = 0 ; i < range[this.weapon] ;i++){
        for (int j = 0 ; j < reach[this.weapon];j++){
          int px = (Math.round(this.x / cellSize) - i - (range[this.weapon] / 2));
          int py = Math.round(this.y / cellSize) - j;
          if(px < width/cellSize && py < height/cellSize && px >= 0 && py >=0)
          cells[px][py].Painted(this.teamID,this.ikaNumber);
        }
      }

      break;
      case DOWN:
      for (int i = 0 ; i < range[this.weapon] ;i++){
        for (int j = 0 ; j < reach[this.weapon];j++){
          int px = (Math.round(this.x / cellSize) - i - (range[this.weapon] / 2));
          int py = Math.round(this.y / cellSize) + j;
          if(px < width/cellSize && py < height/cellSize && px >= 0 && py >=0)
          cells[px][py].Painted(this.teamID,this.ikaNumber);
        }
      }
      break;

      case LEFT:
      for (int i = 0 ; i < reach[this.weapon] ;i++){
        for (int j = 0 ; j < range[this.weapon];j++){
          int px = (Math.round(this.x / cellSize) - i - (range[this.weapon] / 2));
          int py = Math.round(this.y / cellSize) - j;
          if(px < width/cellSize && py < height/cellSize && px >= 0 && py >=0)
          cells[px][py].Painted(this.teamID,this.ikaNumber);
        }
      }
      break;

      case RIGHT:
      for (int i = 0 ; i < reach[this.weapon] ;i++){
        for (int j = 0 ; j < range[this.weapon];j++){
          int px = (Math.round(this.x / cellSize) - i - (range[this.weapon] / 2));
          int py = Math.round(this.y / cellSize) + j;
          if(px < width/cellSize && py < height/cellSize && px >= 0 && py >=0)
          cells[px][py].Painted(this.teamID,this.ikaNumber);
        }
      }
      break;

    }


  }



  public void Paint(){
    if(this.isPlaying){
        this.isDead();
        this.DrawSquid();





        this.Walk();

        this.ReflectWall();


        if( cells[Math.round(this.x / cellSize)][Math.round(this.y / cellSize)].state == BLANK){
             this.SlowDown();
        }else if( cells[Math.round(this.x / cellSize)][Math.round(this.y / cellSize)].teamID == this.teamID){
            this.RandomWalkVel();
            this.life = 3;
        }else{

            this.vx = 0; this.vy = 0 ;
            this.life--;

        }

        cells[Math.round(this.x / cellSize)][Math.round(this.y / cellSize)].Painted(this.teamID,this.ikaNumber);
        Random rnd = new Random();
        if(this.weapon == ROLLER && (frameCount % 50 > 20)) this.Shot();
        if(this.weapon == SHOOTER && (frameCount % 50 > 5)) this.Shot();
        else if ((frameCount + rnd.nextInt(25))% (10 * shotRate[this.weapon])  == 0) this.Shot();

      }

  }

}




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

public final int black = (12);
public final int red = 0xffd88b25;
public final int blue = 0xff503ba0;

public static final int NumberOfIka = 4;
public static final int NumberOfteams = 4;

public void settings(){
  //frameRate(25);
  size(600, 600);
}


public void setup() {

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

public void draw() {
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

      text(String.valueOf(j+1) +"\u30b4\u30a6 \n" +teams[i].members[j].paintPoint +"P \n" + weaponStr[teams[i].members[j].weapon] + "\n\u30ad\u30eb "   + teams[i].members[j].kill + "\n \u30c7\u30b9 " + teams[i].members[j].death , 100 + j* 80 ,100 + i * 150 + 20);


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

  text("\u30a2\u30eb\u30d5\u30a1\u30c1\u30fc\u30e0 " + String.valueOf(redCount) + "P" + "\n \u30d6\u30e9\u30dc\u30fc\u30c1\u30fc\u30e0 " +String.valueOf(blueCount) + "P", width/2,height/2);
  println("\u30a2\u30eb\u30d5\u30a1\u30c1\u30fc\u30e0 " + String.valueOf(redCount) + "P" + "\n \u30d6\u30e9\u30dc\u30fc\u30c1\u30fc\u30e0 " +String.valueOf(blueCount) + "P");
  */
  noLoop();



}
}

public void stop()
{
  bgmPlayer.close();
  sePlayer.close();
  minim.stop();
  super.stop();
}
  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "yutasparadise" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}
