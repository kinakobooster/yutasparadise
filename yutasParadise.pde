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


public Cell[][] cells;
Team[] teams;

public final color black = (12);  //Blank floor color
public final color gray = (220);  //Wall color

public static final int NUMBEROFIKA = 4;
public static final int NUMBEROFTEAMS = 4;
public static final int FIELDSIZEX = 600;
public static final int FIELDSIZEY= 600;

public static final int CELLSIZE = 10;

public static final int CELLNUMBERX = Math.round(FIELDSIZEX / CELLSIZE);
public static final int CELLNUMBERY = Math.round(FIELDSIZEY / CELLSIZE);

public static final int BEFOREBATTLE = 0;
public static final int BATTLE = 1;
public static final int ENDBATTLE = 2;

int startTime;
int gameState;
int timer;

void settings(){
  size(FIELDSIZEX + 400, FIELDSIZEY);

}

void setup() {
  startTime = 0;
  frameRate(25);
  // font settings
  printArray(PFont.list());
  f = createFont("ikamodoki", 12);
  textFont(f);

  // sound settings
  minim = new Minim(this);
  bgmPlayer = minim.loadFile("bgm.mp3");
  sePlayer = minim.loadFile("dead.mp3");


  // shape settings
  ikaShape = loadShape("ika3.svg");

  // cell initialization
  cells = new Cell[FIELDSIZEX/CELLSIZE][FIELDSIZEY/CELLSIZE];
  for(int i = 0; i < FIELDSIZEX/CELLSIZE; i++){
    for(int j = 0; j < FIELDSIZEY/CELLSIZE; j++) cells[i][j] = new Cell();

  }

  // 背景とかの整形
  noStroke();
  background(black);

  // team initialization
  teams = new Team[NUMBEROFTEAMS];
  for(int i = 0; i < NUMBEROFTEAMS; i++){
    teams[i] = new Team(i);
  }
  gameState = BEFOREBATTLE;

}

void draw() {

  timer = millis();

    for (int x=0; x<FIELDSIZEX/CELLSIZE; x++) {
      for (int y=0; y<FIELDSIZEY/CELLSIZE; y++) {
        if(cells[x][y].state == BLANK) fill(black);
        else if (cells[x][y].state == WALL) fill(gray);
        else fill(teams[cells[x][y].teamID].teamColor);

        rect (x*CELLSIZE, y*CELLSIZE, CELLSIZE, CELLSIZE);
      }
    }

  switch (gameState){
    case  BEFOREBATTLE :
      BattleSetup();
      break;

    case  BATTLE :
      Battle();
      break;

    case  ENDBATTLE :

    noLoop();
    break;


  }






  }


  void mouseDragged() {
    int onMouseCellx = Math.round(mouseX / CELLSIZE);
    int onMouseCelly = Math.round(mouseY / CELLSIZE);

    if ( onMouseCellx > 0 && onMouseCellx < CELLNUMBERX && onMouseCelly > 0 && onMouseCelly < CELLNUMBERY) {
      cells[onMouseCellx][onMouseCelly].ChangeState(WALL);
      cells[onMouseCellx][Math.abs(onMouseCelly - CELLNUMBERY)].ChangeState(WALL);
      cells[Math.abs(onMouseCellx - CELLNUMBERX)][onMouseCelly].ChangeState(WALL);
      cells[Math.abs(onMouseCellx - CELLNUMBERX)][Math.abs(onMouseCelly - CELLNUMBERY)].ChangeState(WALL);
    }
  }
  void mousePressed(){
    if(gameState == BEFOREBATTLE && RectOver(FIELDSIZEX + 20, FIELDSIZEY /2 - 40, 60, 40) ) {
      gameState = BATTLE;
      bgmPlayer.play();
      startTime = timer;
    }
  }

  boolean RectOver(int x,int y, int w,int h){
  if (mouseX >= x && mouseX <= x+w &&
      mouseY >= y && mouseY <= y+h) {
    return true;
  } else {
    return false;
    }
  }

    void BattleSetup(){
      noFill();
      stroke(200);
      rect(0,0,FIELDSIZEX,FIELDSIZEY);
      rect(FIELDSIZEX + 20, FIELDSIZEY /2 - 40, 60, 40);

      noStroke();
      fill(255);
      text("スタート", FIELDSIZEX + 40, FIELDSIZEY /2 -20);

    }

    void Battle(){
      if(timer - startTime >= 61000) {
        gameState = ENDBATTLE;
        return;
        }

        //イカを動かす
        for(int i = 0; i < teams.length; i++){
          teams[i].Paint();
        }

        //イカの状態を出す


        if(frameCount % 25 == 0){
          fill(0);
          rect(FIELDSIZEX, 0, 400, height);

          for(int i=0; i <NUMBEROFTEAMS; i++){
            teams[i].paintPoint = 0;
            for(int j=0; j <NUMBEROFIKA; j++){
              teams[i].members[j].paintPoint = 0;
            }

          }

          for (int x=0; x<FIELDSIZEX/CELLSIZE; x++) {
            for (int y=0; y<FIELDSIZEY/CELLSIZE; y++) {
              if(cells[x][y].state != BLANK){
                teams[cells[x][y].teamID].paintPoint++;
                teams[cells[x][y].teamID].members[cells[x][y].whoPainted].paintPoint++;
              }
            }
          }
          fill(255);



          for(int i = 0; i < teams.length ; i++ ){
            fill(teams[i].teamColor);
            text(teams[i].teamName + String.valueOf(teams[i].paintPoint) + "P", width - 380,50 + i * 140);
            for(int j = 0; j < NUMBEROFIKA; j++){
              text(String.valueOf(j+1) +"ゴウ \n" + teams[i].members[j].paintPoint +"P \n"
              + weaponStr[teams[i].members[j].weapon] + "\nキル "
              + teams[i].members[j].kill + "\nデス " + teams[i].members[j].death , width - 380 + j* 80 ,50 + i * 140 + 20);
            }
          }


          }



      }

  void stop()
  {
    bgmPlayer.close();
    sePlayer.close();
    minim.stop();
    super.stop();
  }
