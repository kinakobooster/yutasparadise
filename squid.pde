final String[] teamNameDefault = {"アルファチーム","ブラボーチーム","クレイジーウンチ","ダイブツレクイエム"};
final color[] teamColorDefault = {#d88b25, #503ba0,#428944,#c25779};
final int PADDING = 40;
public static final int SHOOTER = 0;
public static final int ROLLER  = 1;
public static final int CHARGER = 2;
public static final int[] reach = {6,3,20};
public static final int[] range = {15,80,5}; //degree
public static final int[] shotRate = {4,2,20};
public static final String[] weaponStr = {"シューター","ローラー","チャージャー"};


class Team{
  int teamID;
  color teamColor;
  PVector respawn;


  String teamName;
  Squid[] members = new Squid[numberOfIka];
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


    for (int i=0;i< numberOfIka;i++){
      members[i] = new Squid(teamID, i);
      members[i].position = this.respawn;
    }
  }

  void Paint(){
    for(int i = 0; i < numberOfIka; i++) members[i].Paint();
  }


}

class Squid {
  PVector position;
  PVector velocity;
  PVector acceleration;
  float r;

  int weapon;
  int remainInk;


  int ikaNumber;
  int life;
  int kill = 0;
  int death = 0;

  int teamID;
  int paintPoint;
  int deadTime;

  boolean isPlaying;

  Squid(int teamID,int ikaNumber){

    acceleration = new PVector(0, 0);
    float angle = random(TWO_PI);
    velocity = new PVector(cos(angle), sin(angle));

    this.teamID = teamID;
    this.ikaNumber = ikaNumber;
    this.weapon = (teamID + ikaNumber) % 3;

    life = 3;
    remainInk = 400;
    paintPoint = 0;
    isPlaying = true;
    deadTime = 10;
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
    this.velocity.add(new PVector(cos(ang), sin(ang)));
  }

  void RandomWalkPos(){
    this.velocity = new PVector(random(2)-1,random(2)-1);
  }

  void SlowDown(){
    if(this.velocity.mag() > 5)  this.velocity.mult(0.8);
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

      this.StopWalking();
      teams[killTeamID].members[killSquidID].kill++;
      sePlayer.play();
      sePlayer.rewind();

      this.deadTime = 10;

      println("dead!");
    }
  }

  void Respawn(){
    if(this.isPlaying == false) this.deadTime--;
    if(this.deadTime == 0) {
    this.isPlaying = true;
    this.position = teams[this.teamID].respawn;
    this.life = 3;
    this.remainInk = 100;
    this.deadTime = 10;
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

  void setCell(PVector pos, Cell newCell){
    cells[(int)(pos.x/CELLSIZE)][(int)(pos.y/CELLSIZE)] = newCell;
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


    void DrawSquid(){
      fill(255);
      pushMatrix();
      translate(this.position.x,this.position.y);
      text(String.valueOf(ikaNumber+1),-16,-16);

      rotate(this.velocity.heading() + PI/2 );
      shape(ikaShape,-9,-9,6*this.life,6*this.life);
      popMatrix();
    }

      void Shot(){
        this.SlowDown();
        for (int i = 1 ; i < reach[this.weapon] ;i++){
          for (int j = 0; j < 2 * range[this.weapon]; j++){
                if(this.remainInk < 0) return;
                PVector splash = PVector.fromAngle(this.velocity.heading() + radians(range[this.weapon] - j) ).mult((float)(i * CELLSIZE));
                PVector ppos = PVector.add(this.position, splash);
                if(IsInFrame(ppos)){
                  if(getCell(ppos).state != WALL){

                    this.remainInk--;
                    cells[(int)(ppos.x/CELLSIZE)][(int)(ppos.y/CELLSIZE)].Painted(this.teamID,this.ikaNumber);
                    }else{
                      return;
                      }
                  }
          }
        }
      }



      void Paint(){
          this.Respawn();
          if (this.isPlaying == false) return;

          this.IsDead();
          this.Walk();
          this.DrawSquid();


          if(getCell(this.position).state == BLANK){
            this.RandomWalkVelAngle();
            this.SlowDown();
            this.remainInk += 30;
          }
          else if(getCell(this.position).teamID == this.teamID){
            this.RandomWalkVelAngle();
            if (this.remainInk < 380) this.remainInk += 200;

            this.life = 3;
            }else{
              this.velocity.mult(0.2);
              this.life--;
            }

            // 足元を塗る

            cells[(int)(this.position.x/CELLSIZE)][(int)(this.position.y/CELLSIZE)].Painted(this.teamID,this.ikaNumber);

            // ブキの発射タイミング
            Random rnd = new Random();
            if ((frameCount + rnd.nextInt(25))% shotRate[this.weapon] == 0) this.Shot();

            /*


            if(this.weapon == ROLLER && (frameCount % 50 > 20)) this.Shot();
            if(this.weapon == SHOOTER && (frameCount % 50 > 3)) this.Shot();
            else if ((frameCount + rnd.nextInt(25))% (10 * shotRate[this.weapon])  == 0) this.Shot();
            */

        }

      }
