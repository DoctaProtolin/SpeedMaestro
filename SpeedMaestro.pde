

Solid s;

Player player;

ArrayList<Solid> solids = new ArrayList();

PVector getIntersection(Line a, Line b) {
  
  if (a.isVertical() || b.isVertical()) {
    
  }
  
  float x = (b.getIntercept() - a.getIntercept())/(a.getSlope() - b.getSlope());
  float y = a.solve(x);
  
  return new PVector(x, y);
}

Line shapeIntersection(Line ray, Solid s) {
  for (Line l : s.getLines()) {
    
    //if (l.isVertical()) {
    //  if (ray.inRange(l.a.x)) {
    //    return l;
    //  }
    //}
    
    float x = getIntersection(l, ray).x;

    if (l.inRange(x)) {
      strokeWeight(10);
      line(l.a.x, l.a.y, l.b.x, l.b.y);
      println("Found line");
      return l;
    }
  }
  
  return null;
}

boolean isInside(Solid s, PVector p) {
  
  Line ray = new Line(p.x, p.y, p.x + width*2, p.y);
  int intersections = 0;
  for (Line l : s.getLines()) {
    
    //if (l.isVertical()) {
    //  if (ray.inRange(l.a.x)) {
    //    intersections ++;
    //    continue;
    //  }
    //}
    
    float x = getIntersection(l, ray).x;
    
    if (l.inRange(x) && ray.inRange(x)) {
      intersections ++;
    }
  }
  return intersections % 2 == 1;
}

void setup() {
  size(500, 500);
  s = new Solid(new PVector(10, 100), new PVector(200, 200), new PVector(50, 50));
  
  player = new Player(100, 100, 35, 60);
  solids.add(new Solid(0, 300, 500, 300, 250, 400));
}

void draw() {
  background(200, 200, 200);
  player.update();
  player.draw();
  
  for (Solid s : solids) {
    fill(#ffffff);
    s.draw();
  }
}
