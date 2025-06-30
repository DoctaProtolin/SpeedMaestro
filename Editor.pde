


class Editor {
  final String PLACEMODE = "1";
  String mode = "1";
  
  ArrayList<PVector> tempPoints = new ArrayList();
  
  void placeMode() {
    
    for (PVector p : tempPoints) {
        fill(0, 255, 0);
        strokeWeight(1);
        ellipse(p.x, p.y, 10, 10);
      }
    
    if (tempPoints.size() == 3) {
      solids.add(new Solid(tempPoints.get(0), tempPoints.get(1), tempPoints.get(2)));
      tempPoints = new ArrayList();
    }
    
    
    // Draw snap to point
    PVector point = camera.getWorldCoords(mouseX, mouseY);
      
    for (Solid s : solids) {
      for (PVector p : s.points) {
        if (dist(point.x, point.y, p.x, p.y) < 20) {
          point.x = p.x;
          point.y = p.y;
          break;
        }
      }
    }
    
    ellipse(point.x, point.y, 10, 10);
  }
  
  void onClick() {
    if (mode == PLACEMODE) {
      PVector point = camera.getWorldCoords(mouseX, mouseY);
      
      // Snap to point
      for (Solid s : solids) {
        for (PVector p : s.points) {
          if (dist(point.x, point.y, p.x, p.y) < 20) {
            point.x = p.x;
            point.y = p.y;
            break;
          }
        }
      }
      
      tempPoints.add(point);
    }
  }
  
  void update() {
    if (mode == PLACEMODE) {
      placeMode();
    }
  }
}
