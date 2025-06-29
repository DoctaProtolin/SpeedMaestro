


class Player {
  PVector pos, size, vel;
  
  boolean grounded = false;
  
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
        println("Found colSolid");
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
      pos.y = l.solve(pos.x) - size.y + 1;
      vel.y = 0;
      println("Slope: " + l.getSlope());
      grounded = true;
    }
    
    
  }
  
  void update() {
    vel.y += 0.5;
    
    collision();
    
    if (grounded) {
      fill(0, 255, 0); 
    } else fill(255, 0, 0);
    
    rect(100, 100, 20, 20);
    
    pos.add(vel);
  }
  
  void draw() {
    fill(200, 0, 0);
    strokeWeight(1);
    rect(pos.x, pos.y, size.x, size.y);
  }
}
