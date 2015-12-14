final int BLANK = 0;
final int PAINTED = 1;
final int WALL = 2;


class Cell{

  int state;
  int teamID;
  int whoPainted;

  Cell(){
    this.state = BLANK;
  }

  void Painted(int teamID,int ikaNumber){
    this.state = PAINTED;
    this.teamID = teamID;
    this.whoPainted = ikaNumber;
  }

  void ChangeState(int state){
    this.state = state;
  }
}
