
static class CameraModes {
  final static int panAhead = 0;
  final static int fixed = 1;
}

class Camera {
  PVector pos, vel;
  float speed = 5;
  
  boolean panAhead = true;
  boolean enable = true;
  
  // Focus data
  PVector focusPos;
  int facing = 1;
  
  // boolean follow = true;
  
  Camera() {
    pos = new PVector(width/2, height/2);
    vel = new PVector();
    focusPos = new PVector();
  }
  
  PVector screenToWorldCoords(float x, float y) {
    return new PVector(pos.x + (x - width/2), y);
  }
  
  PVector worldToScreenCoords(float x, float y) {
    return new PVector(x + width/2 - pos.x, y);
  }
  
  void updateFocus(PVector fpos, int f) {
    focusPos.x = fpos.x;
    facing = f;
  }
  
  void update() {
    
    if (!enable) return;
    
    float boundRadius = 50;
    
    float focusX = focusPos.x + (panAhead ? 100 * facing : 0);
    
    boolean withinRange = (pos.x > focusX - boundRadius && pos.x < focusX + boundRadius);
    
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
