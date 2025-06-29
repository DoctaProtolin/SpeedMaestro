


class Solid {
  PVector[] points = new PVector[3];
  
  Solid(PVector a, PVector b, PVector c) {
    points[0] = a.copy();
    points[1] = b.copy();
    points[2] = c.copy();
  }
  
  Solid(float a, float b, float c, float d, float e, float f) {
    points[0] = new PVector(a, b);
    points[1] = new PVector(c, d);
    points[2] = new PVector(e, f);
  }
  
  Line[] getLines() {
    Line[] lines = new Line[3];
    
    lines[0] = new Line(points[0], points[1]);
    lines[1] = new Line(points[1], points[2]);
    lines[2] = new Line(points[2], points[0]);
    
    return lines;
  }
  
  void draw() {
    beginShape();
    
    for (PVector p : points) {
      vertex(p.x, p.y);
    }
    
    endShape(CLOSE);
  }
  
}


class Line {
  PVector a, b;
  
  Line(PVector _a, PVector _b) {
    a = _a.copy();
    b = _b.copy();
  }
  
  Line(float _a, float _b, float c, float d) {
    a = new PVector(_a, _b);
    b = new PVector(c, d);
  }
  
  boolean isVertical() {
    return a.x == b.x;
  }
  
  float getSlope() {
    return (a.y - b.y)/(a.x - b.x);
  }
  
  float getIntercept() {
    return (a.y - getSlope() * a.x);
  }
  
  float solve(float x) {
    return getSlope() * x + getIntercept();
  }
  
  float solveRev(float y) {
    return (y - getIntercept()) / getSlope();
  }
  
  boolean inRange(float x) {
    float lesserX = min(a.x, b.x);
    float greaterX = max(a.x, b.x);
    
    // Maybe shouldn't be <= in case you select two lines joined at their edges.
    return lesserX < x && x < greaterX;
  }
  
  boolean inRangeY(float y) {
    float lesserY = min(a.y, b.y);
    float greaterY = max(a.y, b.y);
    
    // Maybe shouldn't be <= in case you select two lines joined at their edges.
    return lesserY < y && y < greaterY;
  }
  
  void draw() {
    stroke(0);
    strokeWeight(2);
    line(a.x, a.y, b.x, b.y);
    
  }
    
}






























// End
