


class Player {
  PVector pos, size, vel;
  
  // Surface values
  boolean grounded = false;
  float groundAngle = 0;
  
  Line groundSurface = null;
  Line ceilSurface = null;
  
  // Player values
  float speed = 5;
  int facing = 1;
  
  Player(float x, float y, float w, float h) {
    pos = new PVector(x, y);
    size = new PVector(w, h);
    vel = new PVector();
  }
  
  // ===== COLLISION POINTS =====
  
  PVector getGroundPoint() {
    return new PVector(pos.x + size.x/2, pos.y + size.y);
  }
  
  PVector getCeilingPoint() {
    return new PVector(pos.x + size.x/2, pos.y);
  }
  
  // ===== COLLISION CHECKS =====
  
  void groundCheck() {
    PVector groundPoint = getGroundPoint();


    // Prevent riding a slope downwards into another one while moving
    groundPoint.x += sign(vel.x) * vel.x;
    
    Line surf = null;
    float minY = pos.y + height * 2; // This should be offscreen and will serve as a good max value.
    
    Line groundRay = new Line(groundPoint, new PVector(groundPoint.x, groundPoint.y - height*2));
    
    // Find the highest surface in this shape and compare it to the highest surface in previous shapes.
    // The check for the ceiling is not the same.
    for (Solid tempSolid : solids) {
      
      if (!isInside(tempSolid, groundPoint)) continue; // Skip irrelevant shapes
      
      ArrayList<Line> surfaces = shapeIntersection(groundRay, tempSolid); // Get surface intersections per shape
      
      for (Line tempSurf : surfaces) {
        float y = getIntersection(tempSurf, groundRay).y;
        
        // Set highest surface (at this x position)
        if (y <= minY) {
          surf = tempSurf;
          minY = y;
        }
      }
    }
    
    // Handle ground
    if (surf != null) {
      // Properly reposition object
      pos.y = surf.solve(groundPoint.x) - size.y + 1; // Add 1 for consistent groundedness
      vel.y = 0;
      
      // Store surface data (grounded, groundAngle, surface)
      grounded = true;
      groundSurface = surf;
      
      if (surf.isVertical()) groundAngle = 90;
      else groundAngle = atan(-surf.getSlope()); // Negative for up meaning positive like in cartesian
      
      //strokeWeight(10);
      //stroke(255, 0, 0);
      //line(surf.a.x, surf.a.y, surf.b.x, surf.b.y);
      
      //println("Grounded.");
    } else {
      // Reset surface data
      grounded = false;
      groundSurface = null;
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
    
    // Reset ceilSurface if no ceilSolid
    if (colSolid == null) {
      ceilSurface = null;
      return;
    }
    
    Line ceilRay = new Line(ceilPoint, new PVector(ceilPoint.x, ceilPoint.y + height*2));
    ArrayList<Line> surfaces = shapeIntersection(ceilRay, colSolid);
    
    Line surf = null;
    float minY = 0;
    
    // Search for the highest surface if there are any.
    if (surfaces.size() > 0) {
      minY = getIntersection(surfaces.get(0), ceilRay).y;
    
      // Find highest ground surface
      for (Line tempSurf : surfaces) {
        float y = getIntersection(tempSurf, ceilRay).y;
        
        if (y <= minY) {
          surf = tempSurf;
          minY = y;
        }
      }
    }
    
    if (surf != null) {
      stroke(0);
      strokeWeight(5);
    
      line(surf.a.x, surf.a.y, surf.b.x, surf.b.y);
      
      strokeWeight(1);
      fill(0, 200, 0);
      ellipse(ceilPoint.x, surf.solve(ceilPoint.x), 10, 10);
    }
    
    if (surf != null && !grounded && vel.y < 0) {
      pos.y = surf.solve(ceilPoint.x) + 1;
      vel.y = 0;
      
      // Reset surface data
      grounded = false;
      groundSurface = null;
      ceilSurface = surf;
      
      groundAngle = 0;
    }
  }
  
  // ===== MAIN FUNCTIONS =====
  
  void collision() {
    
    ceilCheck();
    groundCheck();
    
  }
  
  // ===== MOVEMENT =====
  
  void movement() {
    
    boolean ceilingAbove = false;
    if (ceilSurface != null) {
      ceilingAbove = (pos.y - ceilSurface.solve(getCeilingPoint().x)) < 30;
    }
    
    // Jump conditions
    if (grounded && Input.action && !ceilingAbove) {
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
      pos.y = groundSurface.solve(getGroundPoint().x) - size.y + 1;
      
    } else {
      // Handle air movement
      int mov = boolToInt(Input.right) - boolToInt(Input.left); // Thanks Harmony
      
      vel.x = mov * speed;
    }
    
    if      (Input.left)  facing = -1;
    else if (Input.right) facing = 1;
    
    // Friction
    if (!Input.left && !Input.right) {
      if (abs(vel.x) > 1) {
        vel.x -= sign(vel.x) * 0.2; 
      } else {
        vel.x = 0;
      }
    }
    
  }
  
  // ===== UPDATE & DRAW =====
  
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


void spawnPlayer() {
  player = new Player(100, 100, 35, 60);
}
