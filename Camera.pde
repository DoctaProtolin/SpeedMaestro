

class Camera {
  PVector pos, vel, focusPos;
  float speed = 5;
  
  // boolean follow = true;
  
  Camera() {
    pos = new PVector(width/2, height/2);
    vel = new PVector();
    focusPos = new PVector();
  }
  
  void updateFocus(PVector fpos) {
    focusPos.x = fpos.x;
  }
  
  void update() {
    
    float boundRadius = 50;
    
    boolean withinRange = !(pos.x < focusPos.x - boundRadius || pos.x > focusPos.x + boundRadius);
    
    if (!withinRange) {
      if (pos.x < focusPos.x - boundRadius) {
        vel.x = speed;
      } else if (pos.x > focusPos.x + boundRadius) {
        vel.x = -speed;
      }
    } else {
      if (abs(vel.x) > 1) {
        vel.x -= sign(vel.x) * 0.2; 
      } else {
        vel.x = 0;
      }
    }
    
    pos.add(vel);
  }
}












// End
