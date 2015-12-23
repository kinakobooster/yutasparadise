// weapon
public static final int WEAPONCOUNT = 7;

public static final int SHOOTER = 0;
public static final int ROLLER  = 1;
public static final int CHARGER = 2;
public static final int PABLO = 3;
public static final int TAKE = 4;
public static final int RAIZIN = 5;
public static final int SPINNER = 6;


public static final int[] reachDefault = {6,3,20,1,6,2,12};
public static final int[] rangeDefault = {15,80,5,30,5,30,40}; //degree

public static final int[] shotRateDefault   = {4,2,20,1,2,3,15};
public static final int[] chargeTimeDefault = {1,0,10,0,3,1,20};
public static final int[] shotDelayDefault  = {2,4,2,0,1,3,1};
public static final int[] maxWalkSpeedDefault  = {8,5,4,30,4,12,2};
public static final String[] weaponStrDefault = {"シューター","ローラー","チャージャー","パブロ","タケ","ボールド","スピナー"};

Weapon[] weapons = new Weapon[WEAPONCOUNT];



static class Weapon{
  int weaponID;
  String weaponStr;

  int reach;
  int range; //degrees

  int shotRate;
  int chargeTime;
  int shotDelay;
  int maxWalkSpeed;

  Weapon(int ID){
    weaponStr = weaponStrDefault[ID];
    reach = reachDefault[ID];
    range = rangeDefault[ID];

    shotRate = shotRateDefault[ID];
    chargeTime = chargeTimeDefault[ID];
    shotDelay = shotDelayDefault[ID];
    maxWalkSpeed = maxWalkSpeedDefault[ID];
  }
}
