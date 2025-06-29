

static class Keybinds {
  static final int action = 90;
}

static class Input {
  
  static boolean up = false;
  static boolean down = false;
  static boolean left = false;
  static boolean right = false;
  static boolean action = false;
  
  static boolean upPress   = false;
  static boolean downPress = false;
  static boolean leftPress = false;
  static boolean rightPress = false;
  static boolean actionPress = false;
  
  static int pressTimer = 0;
  
  public static void registerPressInputs(int keyCode, boolean k) {
    switch (keyCode) {
      case UP:
        upPress = k;
        break;
      case DOWN:
        downPress = k;
        break;
      case LEFT:
        leftPress = k;
        break;
      case RIGHT:
        rightPress = k;
        break;
        
      case Keybinds.action:
        actionPress = k;
        print("action");

        break;
    }
  }
  
  public static void registerInputs(int keyCode, boolean k) {

    switch (keyCode) {
      case UP:
        up = k;
        break;
      case DOWN:
        down = k;
        break;
      case LEFT:
        left = k;
        break;
      case RIGHT:
        right = k;
        break;
        
      case Keybinds.action:
        action = k;
        break;
    }
  }
  
  // Press inputs only exist for one frame and must be reset at the end.
  public static void resetPressInputs() {
    
    upPress    = false;
    downPress  = false;
    leftPress  = false;
    rightPress = false;
    actionPress = false;
    

  }
}
