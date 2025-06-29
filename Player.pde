


class Player {
  PVector pos, size, vel;
  
  boolean grounded = false;
  float groundAngle = 0;
  float speed = 5;
  
  Player(float x, float y, float w, float h) {
    pos = new PVector(x, y);
    size = new PVector(w, h);
    vel = new PVector();
  }
  
  void collision() {
    PVector groundPoint = new PVector(pos.x + size.x/2, pos.y + size.y);
    grounded = false;
    
    fill(0, 255, 0);
    ellipse(groundPoint.x, groundPoint.y, 30, 30);
    
    Solid colSolid = null;
    
    for (Solid s : solids) {
      if (isInside(s, groundPoint)) {
        colSolid = s;
        // println("Found colSolid");
        break;
      }
    }
    
    if (colSolid == null) {
      return;
    }
    
    Line vertRay = new Line(groundPoint, new PVector(groundPoint.x, groundPoint.y - height*2));
    
    Line l = shapeIntersection(vertRay, colSolid);
    
    if (l != null) {
      // Add 1 for consistent groundedness
      pos.y = l.solve(groundPoint.x) - size.y + 1;
      vel.y = 0;
      // println("Slope: " + l.getSlope());
      grounded = true;
      
      if (l.isVertical()) groundAngle = 90;
      else {
        groundAngle = atan(-l.getSlope()); // Negative for up meaning positive like in cartesian
      }
    } else {
      groundAngle = 0;
    }
    
    
  }
  
  void movement() {
    if (grounded && Input.action) {
      vel.y = -10;
    }
    
    
    if (Input.left == !Input.right) {
      if (Input.left) {
        if (grounded) {
          vel.x = -cos(groundAngle) * speed;
          vel.y = sin(groundAngle) * speed;
        } else vel.x = -speed;
      } else if (Input.right) {
        
        if (grounded) {
          vel.x = cos(groundAngle) * speed;
          vel.y = -sin(groundAngle) * speed;
        } else vel.x = speed;
      }
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
    vel.y += 0.5;
    
    collision();
    movement();
    
    
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
