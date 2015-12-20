final String[] teamNameDefault = {"アルファチーム","ブラボーチーム","クレイジーウンチ","ダイブツレクイエム"};
final color[] teamColorDefault = {#d88b25, #503ba0,#428944,#c25779};
final int PADDING = 40;
public static final int SHOOTER = 0;
public static final int ROLLER  = 1;
public static final int CHARGER = 2;
public static final int[] reach = {8,1,20};
public static final int[] range = {2,4,2};
public static final int[] shotRate = {4,1,6};
public static final String[] weaponStr = {"シューター","ローラー","チャージャー"};
public static final int UP = 0;
public static final int DOWN  = 1;
public static final int RIGHT = 2;
public static final int LEFT = 3;

class Team{
  int teamID;
  color teamColor;
  PVector respawn;


  String teamName;
  Squid[] members = new Squid[NUMBEROFIKA];
  int paintPoint;

  Team(int teamID){
    this.teamID = teamID;
    this.teamColor = teamColorDefault[teamID];
    this.paintPoint = 0;

    switch (teamID){
      case 0:
      this.respawn = new PVector(PADDING,PADDING);
      break;

      case 1:
      this.respawn = new PVector(FIELDSIZEX  - PADDING,FIELDSIZEY  - PADDING);
      break;

      case 2:
      this.respawn = new PVector(PADDING,FIELDSIZEY  - PADDING);
      break;

      case 3:
      this.respawn = new PVector(FIELDSIZEX  - PADDING,PADDING);
      break;

      default:
      break;
    }

    this.teamName = teamNameDefault[teamID];

    for (int i=0;i< NUMBEROFIKA;i++){
      members[i] = new Squid(teamID, i);
      members[i].position = this.respawn;
    }
  }

  void Paint(){
    for(int i = 0; i < NUMBEROFIKA; i++) members[i].Paint();
  }


}

class Squid {
  PVector position;
  PVector velocity;
  PVector acceleration;
  float r;


  int x;
  int y;
  float vx;
  float vy;
  float ax;
  float ay;

  int direction;
  int weapon;
  int ikaNumber;
  int life;
  int kill = 0;
  int death = 0;

  int teamID;
  int paintPoint;

  boolean isPlaying;

  Squid(int teamID,int ikaNumber){

    acceleration = new PVector(0, 0);
    float angle = random(TWO_PI);
    velocity = new PVector(cos(angle), sin(angle));
    //int direction = 0;
    this.teamID = teamID;
    this.ikaNumber = ikaNumber;
    this.weapon = (teamID + ikaNumber) % 3;
    life = 3;
    paintPoint = 0;
    isPlaying = true;
  }

  void RandomWalkAcc(){
    Random rnd = new Random();
    this.acceleration.add(new PVector(random(2)-1,random(2)-1));
    this.velocity.add(this.acceleration);
  }

  void RandomWalkVel(){
    Random rnd = new Random();
    this.velocity.add(new PVector(rnd.nextFloat()*2 -1,rnd.nextFloat()*2 -1));
  }

  void RandomWalkVelAngle(){
    float ang = random(TWO_PI);
    Random rnd = new Random();
    this.velocity.add(new PVector(cos(ang), sin(ang)));
  }

  void RandomWalkPos(){
    this.velocity = new PVector(random(2)-1,random(2)-1);
  }

  void SlowDown(){
    if(this.velocity.mag() > 10)  this.velocity.mult(0.8);
  }

  void IsDead(){
    if(life == 0){
      death++;
      PVector dead = new PVector(Math.round(this.position.x/CELLSIZE),Math.round(this.position.y/CELLSIZE));
      int killTeamID  = cells[(int)dead.x][(int)dead.y].teamID;
      int killSquidID = cells[(int)dead.x][(int)dead.y].whoPainted;


      for (int i = 0;  i < 7  ; i++){
        for(int j = 0; j < 7 ; j++){
          if(i*i + j * j < 7*7 && (dead.x + i <  FIELDSIZEX/CELLSIZE) && (dead.y + j <  FIELDSIZEX/CELLSIZE)
          && (dead.x - i >  0) && (dead.y - j >  0) ){

            cells[(int)dead.x+i][(int)dead.y+j].Painted(killTeamID, killSquidID);
            cells[(int)dead.x-i][(int)dead.y+j].Painted(killTeamID, killSquidID);
            cells[(int)dead.x+i][(int)dead.y-j].Painted(killTeamID, killSquidID);
            cells[(int)dead.x-i][(int)dead.y-j].Painted(killTeamID, killSquidID);
          }
        }
      }


      teams[killTeamID].members[killSquidID].kill++;

      sePlayer.play();
      sePlayer.rewind();

      this.position = teams[this.teamID].respawn;
      this.life = 3;
      println("dead!");
    }
  }

  boolean IsInFrame(PVector pos){
    if(pos.x > 1 && pos.x/CELLSIZE < CELLNUMBERX - 1  && pos.y > 1 && pos.y/CELLSIZE < CELLNUMBERY - 1) return true;
    return false;
  }

  Cell getCell(PVector pos){
    if(pos.x < 1 && pos.x/CELLSIZE > CELLNUMBERX - 1  && pos.y < 1 && pos.y/CELLSIZE > CELLNUMBERY - 1) return cells[0][0];
    return cells[(int)(pos.x/CELLSIZE)][(int)(pos.y/CELLSIZE)];
  }

  void setCell(int x, int y, Cell newCell){
    cells[x][y] = newCell;
    return;
  }

  void Walk(){
    PVector nextPos = PVector.add(this.velocity,this.position);
    if(IsInFrame(nextPos) && getCell(nextPos).state != WALL ){
        this.position = nextPos;
      }else{
        this.velocity.mult(-0.7);
      }
    }

    void StopWalking(){
      this.isPlaying = false;
    }



    void ToBeInFrame(){
      while(this.x < 0)          this.x = this.x + FIELDSIZEX;
      while(this.x >= FIELDSIZEX)     this.x = this.x - FIELDSIZEX;
      while(this.y < 0)          this.y = this.y + FIELDSIZEY;
      while(this.y >= FIELDSIZEY)    this.y = this.y - FIELDSIZEY;
    }


    void DrawSquid(){

      pushMatrix();
      translate(this.position.x,this.position.y);
      text(String.valueOf(ikaNumber+1),-16,-16);


      Random rnd = new Random();
      rotate(this.velocity.heading() + PI/2 );
      shape(ikaShape,-9,-9,6*this.life,6*this.life);
      popMatrix();


     /*
      if(Math.abs(vx) > Math.abs(vy)){
        if(vx > 0){rotate(PI     /2); direction = RIGHT ;}
        else if(vx == 0){
          direction = rnd.nextInt(2) + 2;
        }
        else{       rotate(PI  *3 /2); direction = LEFT  ;}
        }else if(Math.abs(vx) == Math.abs(vy)){
          if(vx > 0){
            rotate(PI/2);
            direction = RIGHT;
          }
          else if(vx == 0){
            direction = rnd.nextInt(2) + 2;
          }
          else{
            rotate(PI  *3 /2); direction = LEFT ;
          }
        }
        else{
          if(vy > 0){rotate(PI ); direction = UP ;}
          else if(vy == 0){
            direction = rnd.nextInt(2);
          }
          else{
            rotate(0);
            direction = DOWN;
          }
        }

        */

      }

      void Shot(){
        this.SlowDown();
        boolean isWall = false;

        /*
        switch(direction){
          case UP:
          for (int i = 0 ; i < range[this.weapon] ;i++){
            for (int j = 0 ; j < reach[this.weapon];j++){
              int px = (Math.round(this.position.x / CELLSIZE) - i - (range[this.weapon] / 2));
              int py = Math.round(this.position.y / CELLSIZE) - j;
              if(px < FIELDSIZEX/CELLSIZE && py < FIELDSIZEY/CELLSIZE && px >= 0 && py >=0){
                if(cells[px][py].state == WALL){
                  isWall = true;
                  break;
                }
                cells[px][py].Painted(this.teamID,this.ikaNumber);
              }
            }
            if(isWall) break;
          }

          break;
          case DOWN:
          for (int i = 0 ; i < range[this.weapon] ;i++){
            for (int j = 0 ; j < reach[this.weapon];j++){
              int px = (Math.round(this.position.x / CELLSIZE) - i - (range[this.weapon] / 2));
              int py = Math.round(this.position.y / CELLSIZE) + j;
              if(px < FIELDSIZEX/CELLSIZE && py < FIELDSIZEY/CELLSIZE && px >= 0 && py >=0){
                if(cells[px][py].state == WALL){
                  isWall = true;
                  break;
                }
                cells[px][py].Painted(this.teamID,this.ikaNumber);
              }
            }
            if(isWall) break;
          }
          break;

          case LEFT:
          for (int i = 0 ; i < reach[this.weapon] ;i++){
            for (int j = 0 ; j < range[this.weapon];j++){
              int px = Math.round(this.position.x / CELLSIZE) - i ;
              int py = Math.round(this.position.y / CELLSIZE) - j - (range[this.weapon] / 2);
              if(px < FIELDSIZEX/CELLSIZE && py < FIELDSIZEY/CELLSIZE && px >= 0 && py >=0){
                if(cells[px][py].state == WALL){
                  isWall = true;
                  break;
                }
                cells[px][py].Painted(this.teamID,this.ikaNumber);
              }
            }
            if(isWall) break;
          }
          break;

          case RIGHT:
          for (int i = 0 ; i < reach[this.weapon] ;i++){
            for (int j = 0 ; j < range[this.weapon];j++){
              int px = Math.round(this.position.x / CELLSIZE) + i;
              int py = Math.round(this.position.y / CELLSIZE) + j- (range[this.weapon] / 2);
              if(px < FIELDSIZEX/CELLSIZE && py < FIELDSIZEY/CELLSIZE && px >= 0 && py >=0){

                if(cells[px][py].state == WALL){
                  isWall = true;
                  break;
                }
                cells[px][py].Painted(this.teamID,this.ikaNumber);
              }
            }
            if(isWall) break;
          }
          break;

        }

        */
      }



      void Paint(){
          this.IsDead();
          this.Walk();
          this.DrawSquid();


          if(getCell(this.position).state == BLANK){
            this.SlowDown();
          }
          else if(getCell(this.position).teamID == this.teamID){
            this.RandomWalkVelAngle();
            this.life = 3;
            }else{
              this.velocity.mult(0.4);
              this.life--;
            }

            // 足元を塗る

            cells[(int)(this.position.x/CELLSIZE)][(int)(this.position.y/CELLSIZE)].Painted(this.teamID,this.ikaNumber);

            // ブキの発射タイミング
            Random rnd = new Random();
            if(this.weapon == ROLLER && (frameCount % 50 > 20)) this.Shot();
            if(this.weapon == SHOOTER && (frameCount % 50 > 5)) this.Shot();
            else if ((frameCount + rnd.nextInt(25))% (10 * shotRate[this.weapon])  == 0) this.Shot();


        }

      }
