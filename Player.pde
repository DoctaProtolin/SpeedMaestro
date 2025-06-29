


class Player {
  PVector pos, size, vel;
  Player(float x, float y, float w, float h) {
    pos = new PVector(x, y);
    size = new PVector(w, h);
    vel = new PVector();
  }
  
  void collision() {
    PVector groundPoint = new PVector(pos.x + size.x/2, pos.y + size.y);
    
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
      pos.y = l.solve(pos.x);
      vel.y = 0;
      // println("Slope: " + l.getSlope());
    }
    
    
  }
  
  void update() {
    vel.y += 0.5;
    
    collision();
    
    pos.add(vel);
  }
  
  void draw() {
    fill(200, 0, 0);
    strokeWeight(1);
    rect(pos.x, pos.y, size.x, size.y);
  }
}
