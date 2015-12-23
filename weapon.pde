// weapon
public static final int WEAPONCOUNT = 3;

public static final int SHOOTER = 0;
public static final int ROLLER  = 1;
public static final int CHARGER = 2;


public static final int[] reachDefault = {6,3,20};
public static final int[] rangeDefault = {15,80,5}; //degree

public static final int[] shotRateDefault   = {4,2,20};
public static final int[] chargeTimeDefault = {1,0,10};
public static final int[] shotDelayDefault  = {2,4,2};
public static final int[] maxWalkSpeedDefault  = {8,5,4};


public static final String[] weaponStrDefault = {"シューター","ローラー","チャージャー"};

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
