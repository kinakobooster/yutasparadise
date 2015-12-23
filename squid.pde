// Team settings
final String[] teamNameDefault = {"アルファチーム","ブラボーチーム","クレイジーウンチ","ダイブツレクイエム"};
final color[] teamColorDefault = {#d88b25, #503ba0,#428944,#c25779};
final int PADDING = 40;


public static final int NOBRAIN= 0;
public static final int DEFENSIVE= 1;
public static final int AGGRESSIVE= 2;
public static final int BALANCE= 3;

public static final int INTELLIGENCECOUNT= 4;
public static String[] INTELIGENCENAME = {"N","D","A","B"};

public static final int RESPAWNFRAME = 25;
public static final int INKTANKSIZE  = 100;

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
  int shotCharge;
  int shotDelay;


  int ikaNumber;
  int life;
  int kill = 0;
  int death = 0;

  int teamID;
  int paintPoint;
  int deadTime;
  int intelligece;

  boolean isPlaying;

  Squid(int teamID,int ikaNumber){
    acceleration = new PVector(0, 0);
    float angle = random(TWO_PI);
    velocity = new PVector(cos(angle), sin(angle));

    this.teamID = teamID;
    this.ikaNumber = ikaNumber;
    this.weapon = (teamID + ikaNumber + (int)random(12)) % WEAPONCOUNT;
    this.intelligece = (teamID + ikaNumber +(int)random(4)) % INTELLIGENCECOUNT;
    this.shotCharge = 0;

    life = 3;
    remainInk = INKTANKSIZE;
    paintPoint = 0;
    isPlaying = true;
    deadTime = RESPAWNFRAME;
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
    //if(teamID == 0 && ikaNumber == 0) return;
    this.velocity.add(PVector.fromAngle(this.velocity.heading() + random(TWO_PI - 1) - PI - 0.5).mult(2));
  }

  void RandomWalkPos(){
    this.velocity = new PVector(random(2)-1,random(2)-1);
  }

  void ApproachToTeammate(){
    PVector closestFriendsPos;
    int closestID = 0;
    float closestDist = 100;
    for (int i = 0; i < numberOfIka; i++){
      if (i == this.ikaNumber) continue;
      float d = this.position.dist(teams[this.teamID].members[i].position);
      if (closestDist > d){
        closestDist = d;
        closestID = i;
      }
    }
    this.velocity.add(PVector.sub(teams[this.teamID].members[closestID].position,this.position).normalize());
  }

  void ApproachToEnemy(){
    PVector closestEnemysPos;
    int closestTeamID = 0;
    int closestMemberID = 0;
    float closestDist = 200;
    for (int i = 0; i < numberOfTeams; i++){
      if(i == this.teamID) continue;
      for (int j = 0; j < numberOfIka; j++){
        float d = this.position.dist(teams[i].members[j].position);
        if (closestDist > d){
          closestDist = d;
          closestTeamID = i;
          closestMemberID = j;
        }
      }
    }

    this.velocity.add(PVector.sub(teams[closestTeamID].members[closestMemberID].position,this.position).normalize());
  }



  void SlowDown(){
    if(this.velocity.mag() > weapons[this.weapon].maxWalkSpeed )  this.velocity.mult(0.8);
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

      this.deadTime = RESPAWNFRAME;

      println("dead!");
    }
  }

  void Respawn(){
    if(this.isPlaying == false) this.deadTime--;
    if(this.deadTime == 0) {
      this.isPlaying = true;
      this.position = teams[this.teamID].respawn;
      this.life = 3;
      this.remainInk = INKTANKSIZE;
      this.deadTime = 25;
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
      text(String.valueOf(ikaNumber+1) + INTELIGENCENAME[intelligece],-16,-16);

      rotate(this.velocity.heading() + PI/2 );
      shape(ikaShape,-9,-9,6*this.life,6*this.life);
      popMatrix();
    }

    void ShotPrepare(){
      if(this.remainInk < 0) return;
      if(this.shotDelay < 0) {
        this.shotDelay--;
        return;
      }

      this.SlowDown();

      if (this.shotCharge == 0 ){
        this.shotCharge = weapons[this.weapon].chargeTime;
      }else{
      this.shotCharge--;
      }

      if (this.shotCharge == 0 ) {
        this.Shot();
        this.shotDelay = weapons[this.weapon].shotDelay;
        }

      }
      void Shot(){
        for (int i = 1 ; i < weapons[this.weapon].reach; i++){
          for (int j = 0; j < 2 * weapons[this.weapon].range; j++){

            PVector splash = PVector.fromAngle(this.velocity.heading() + radians(weapons[this.weapon].range - j) ).mult((float)(i * CELLSIZE));
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
        //あしもとの状況で動きを変える
        //塗られてないから歩く
        if(getCell(this.position).state == BLANK){

          this.RandomWalkVelAngle();
          this.SlowDown();
          if (this.remainInk < INKTANKSIZE) this.remainInk += 30;
        }
        // 自陣にいる

        else if(getCell(this.position).teamID == this.teamID){
          if(this.intelligece == BALANCE && frameCount % 5 == 0){
            if (this.remainInk > 50) this.ApproachToEnemy();
            else if (this.remainInk < 20) this.ApproachToTeammate();
            else this.RandomWalkVelAngle();

          }else if(this.intelligece == DEFENSIVE && frameCount % 6 == 0){
            this.ApproachToTeammate();
          }else if(this.intelligece == AGGRESSIVE && frameCount % 4 == 0){
            this.ApproachToEnemy();
          }else{
          this.RandomWalkVelAngle();
          }
          if (this.remainInk < INKTANKSIZE) this.remainInk = INKTANKSIZE;
          this.life = 3;

          }else{ //敵インクを踏んだ
            this.velocity.mult(0.2);
            this.life--;
          }

          // 足元を塗る
          cells[(int)(this.position.x/CELLSIZE)][(int)(this.position.y/CELLSIZE)].Painted(this.teamID,this.ikaNumber);
          this.ShotPrepare();
          // ブキの発射タイミング

          Random rnd = new Random();
          if ((frameCount + rnd.nextInt(25))% weapons[this.weapon].shotRate == 0) this.ShotPrepare();

          /*
          if(this.weapon == ROLLER && (frameCount % 50 > 20)) this.Shot();
          if(this.weapon == SHOOTER && (frameCount % 50 > 3)) this.Shot();
          else if ((frameCount + rnd.nextInt(25))% (10 * shotRate[this.weapon])  == 0) this.Shot();
          */

        }

      }
