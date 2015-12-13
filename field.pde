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

void Painted(int teamID,int ikaNumber){
  this.state = PAINTED;
//  this.myColor = teamColor;
  this.teamID = teamID;
  this.whoPainted = ikaNumber;


}



}