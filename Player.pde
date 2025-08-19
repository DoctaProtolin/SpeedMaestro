


class Player {
  PVector pos, size, vel;
  
  // Surface values
  boolean grounded = false;
  float groundAngle = 0;
  
  Line groundSurface = null;
  Line ceilSurface = null;
  
  // Player values
  float speed = 0.5;
  float speedCap = 5;
  float frictionStrength = 0.5;
  float frictionThreshold = 1;
  
  float jumpStrength = 15;
  
  int facing = 1;
  
  Player(float x, float y, float w, float h) {
    pos = new PVector(x, y);
    size = new PVector(w, h);
    vel = new PVector();
  }
  
  // ===== COLLISION POINTS =====
  
  PVector getGroundPoint() {
    return new PVector(pos.x + size.x/2, pos.y + size.y + 2);
  }
  
  PVector getCeilingPoint() {
    return new PVector(pos.x + size.x/2, pos.y);
  }
  
  // ===== COLLISION CHECKS =====
  
  //void insideGroundCheck() {
    
  //  //Line innerRay = new Line(mid.x, mid.y, mid.x, mid.y + size.y/2 - 1);
    
  //  for (Solid tempSolid : solids) {
  //    PVector mid = new PVector(pos.x + size.x/2, pos.y + size.y/2);
  //    while(isInside(tempSolid, mid)) {
  //      mid = new PVector(pos.x + size.x/2, pos.y + size.y/2);
  //      pos.y -= size.y/2 + 1;
  //      grounded = true;
  //      println("Inside, moving up: " + pos.y);
  //    }
  //  }
  //}
  
  void groundCheck() {
    
    
    
    float minY = height;
    
    for (Solid tempSolid : solids) {
      PVector mid = new PVector(pos.x + size.x/2, pos.y + size.y/2);
      Line innerCheck = new Line(mid, new PVector(mid.x, mid.y + size.y));
      ArrayList<Line> surfaces = shapeIntersection(innerCheck, tempSolid);
      
      for (Line surface : surfaces) {
        float y = surface.solve(mid.x);
        
        if (surface.inRange(mid.x) && y < pos.y + size.y) {
          pos.y = y - size.y;
          println("Adjusted");
        }
      }
    }
    
    /*
      sign(vel.x) * vel.x:
        Standard ground point check. When transitioning from a triangle going downwards to another triangle going upwards while grounded,
        the default ground point will not be inside the highest shape, making it ineligible for collision. This causes a bug
        which has you clip through the top shape. This is fixed by shifting the point ahead so it's inside the top shape before we ever enter it and
        cause all of our problems.
        
      0:
        If the above check fails, it's possible we're going down a slope with no other objects ahead of us, causing us to continuously detatch from the surface
        when the ground point looks ahead. The proper solution may be to shift the y coordinate too, which will be necessary to make more
        rad ramps.
    
    */
    
    // There's probably a faster way to do this than looping through all of the shapes thrice just for one of these points.
    // I added the third one (-sign(vel.x) * vel.x) to prevent this odd staggering movement when sliding down to the right.
    // When I only had two items, and the first one was changed to be the third one, the staggering was flipped, happening on slopes going down to the left.
    float[] groundPointShift = {sign(vel.x) * vel.x, 0, -sign(vel.x) * vel.x};
    
    int shiftIndex = 0; 
    
    Line surf = null;
    minY = pos.y + height*2; // This should be offscreen and will serve as a good max value.
    PVector groundPoint;
    
    do {
      groundPoint = getGroundPoint();
      
      groundPoint.x += groundPointShift[shiftIndex]; // Prevent riding a slope downwards into another one while moving
      
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
      shiftIndex ++;
    } while(shiftIndex < groundPointShift.length && surf == null);
    
    // Handle ground
    if (surf != null) {
      // Properly reposition object
      pos.y = surf.solve(groundPoint.x) - size.y + 1; // Add 1 for consistent groundedness
      vel.y = 0;
      
      // Store surface data (grounded, groundAngle, surface)
      grounded = true;
      groundSurface = surf;
      
      if (surf.isVertical()) groundAngle = -HALF_PI;
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
    
    //ceilCheck();
    //insideGroundCheck();
    groundCheck();
    
  }
  
  // ===== MOVEMENT =====
  
  void gravity() {
    
    float gStrength = 1;
    
    if (grounded) {
      PVector gForce = new PVector();
      gForce.x = gStrength * cos(groundAngle + PI/2);
      gForce.y = -gStrength * sin(groundAngle + PI/2);
      
      gForce.normalize();
      gForce.mult(gStrength);
      
      vel.add(gForce);
    } else {
      vel.y += gStrength;
    }
  }
  
  void movement() {
    
    boolean ceilingAbove = false;
    if (ceilSurface != null) {
      ceilingAbove = (pos.y - ceilSurface.solve(getCeilingPoint().x)) < 30;
    }
    
    // Jump conditions
    if (grounded && Input.action && !ceilingAbove) {
      vel.y = -jumpStrength;
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
        if (vel.x > -speedCap) {
          vel.x += -cos(groundAngle) * speed;
        }
        
        vel.y = sin(groundAngle) * speed;
      }
      
      if (Input.right) {
        if (vel.x < speedCap) {
          vel.x += cos(groundAngle) * speed;
        }
        
        vel.y = -sin(groundAngle) * speed;
      }
      
      // Adhere to surface
      pos.y = groundSurface.solve(getGroundPoint().x) - size.y + 1;
    } else {
      // Handle air movement
      int mov = boolToInt(Input.right) - boolToInt(Input.left); // Thanks Harmony
      
      //vel.x += mov * speed;
    }
    
    // Update facing
    if      (Input.left)  facing = -1;
    else if (Input.right) facing = 1;
    
    // Update friction
    boolean slopeForceAllow = groundAngle > deg2Rad(35) && groundAngle < deg2Rad(360 - 35);
    if (!Input.left && !Input.right) {
      if (abs(vel.x) > (frictionThreshold+0.5) && slopeForceAllow) {
        vel.x -= sign(vel.x) * frictionStrength; 
      } else if (groundAngle == 0) {
        vel.x = 0;
      }
    }
    
  }
  
  // ===== UPDATE & DRAW =====
  
  void update() {
    
    gravity();
    collision();
    movement();
    
    // Update position
    pos.add(vel);
  }
  
  void draw() {
    
    // Test for groundedness
    fill(grounded ? #00ff00 : #ff0000);
    
    stroke(0);
    strokeWeight(1);
    rect(100, 100, 20, 20);
    
    fill(200, 0, 0);
    strokeWeight(1);
    rect(pos.x, pos.y, size.x, size.y);
  }
}


void spawnPlayer() {
  player = new Player(100, 100, 35, 60);
}












// End
