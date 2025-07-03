


class Player {
  PVector pos, size, vel;
  
  // Surface values
  boolean grounded = false;
  float groundAngle = 0;
  Line surface = null;
  
  float speed = 5;
  
  
  Player(float x, float y, float w, float h) {
    pos = new PVector(x, y);
    size = new PVector(w, h);
    vel = new PVector();
  }
  
  PVector getGroundPoint() {
    return new PVector(pos.x + size.x/2, pos.y + size.y);
  }
  
  PVector getCeilingPoint() {
    return new PVector(pos.x + size.x/2, pos.y);
  }
  
  void groundCheck() {
    PVector groundPoint = getGroundPoint();
    Solid colSolid = null;
    
    
    for (Solid s : solids) {
      if (isInside(s, groundPoint)) {
        colSolid = s;
        break;
      }
    }
    
    if (colSolid == null) {
      grounded = false;
      return;
    }
    
    Line groundRay = new Line(groundPoint, new PVector(groundPoint.x, groundPoint.y - height*2));
    Line groundSurf = shapeIntersection(groundRay, colSolid);
    
    // Handle ground
    if (groundSurf != null) {
      // Properly reposition object
      pos.y = groundSurf.solve(groundPoint.x) - size.y + 1; // Add 1 for consistent groundedness
      vel.y = 0;
      
      // Store surface data (grounded, groundAngle, surface)
      grounded = true;
      surface = groundSurf;
      
      if (groundSurf.isVertical()) groundAngle = 90;
      else groundAngle = atan(-groundSurf.getSlope()); // Negative for up meaning positive like in cartesian
      
    } else {
      // Reset surface data
      grounded = false;
      surface = null;
      groundAngle = 0;
    }
  }
  
  void ceilCheck() {
    
    Solid colSolid = null;
    PVector ceilPoint = getCeilingPoint();
    
    for (Solid s : solids) {
      if (isInside(s, ceilPoint)) {
        colSolid = s;
        break;
      }
    }
    
    if (colSolid == null) {
      return;
    }
    
    Line ceilRay = new Line(ceilPoint, new PVector(ceilPoint.x, ceilPoint.y - height*2));
    Line ceilSurf = shapeIntersection(ceilRay, colSolid);
    
    if (ceilSurf != null && !grounded) {
      pos.y = ceilSurf.solve(ceilPoint.x) + 1;
      vel.y = 0;
      
      // Reset surface data
      grounded = false;
      surface = null;
      groundAngle = 0;
    }
  }
  
  void collision() {
    
    ceilCheck();
    groundCheck();
    
    
  }
  
  void movement() {
    if (grounded && Input.action) {
      vel.y = -10;
      grounded = false;
    }
    
    // Direction for debugging
    if (grounded) {
      PVector dir = PVector.fromAngle(groundAngle);
      dir.mult(40);
      
      strokeWeight(3);
      line(100, 100, 100 + dir.x, 100 + dir.y);
    }

    if (grounded) {
      // Handle ground movement
      if (Input.left) {
        vel.x = -cos(groundAngle) * speed;
        vel.y = sin(groundAngle) * speed;
      }
      if (Input.right) {
        vel.x = cos(groundAngle) * speed;
        vel.y = -sin(groundAngle) * speed;
      }
      
      // Adhere to surface
      pos.y = surface.solve(getGroundPoint().x) - size.y + 1;
      
    } else {
      // Handle air movement
      int mov = convertBool(Input.right) - convertBool(Input.left); // Thanks Harmony
      
      vel.x = mov * speed;
    }
    
    // Friction
    if (!Input.left && !Input.right) {
      if (abs(vel.x) > 1) {
        vel.x -= sign(vel.x) * 0.2; 
      } else {
        vel.x = 0;
      }
    }
    
  }
  
  void update() {
    
    // Update gravity
    if (!grounded) vel.y += 0.5;
    
    collision();
    movement();
    
    // Update position
    pos.add(vel);
  }
  
  void draw() {
    
    // Test for groundedness
    if (grounded) {
      fill(0, 255, 0); 
    } else fill(255, 0, 0);
    rect(100, 100, 20, 20);
    
    fill(200, 0, 0);
    strokeWeight(1);
    rect(pos.x, pos.y, size.x, size.y);
  }
}
