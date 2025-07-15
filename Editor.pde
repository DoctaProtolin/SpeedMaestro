

static class EditorMode {
  static final int place = 1;
  static final int delete = 2;
}

class Editor {
  
  int mode = EditorMode.delete;
  
  EditorPlaceMode  editorPlaceMode;
  EditorDeleteMode editorDeleteMode;
  
  Editor() {
    editorPlaceMode  = new EditorPlaceMode();
    editorDeleteMode = new EditorDeleteMode();
  }
  
  void switchMode() {
    
    switch (keyCode) {
      case 49: mode = EditorMode.place;  break;
      case 50: mode = EditorMode.delete; break;
    }
  }
  
  void onClick() {
    switch (mode) {
      case EditorMode.place:  editorPlaceMode.onClick();  break;
      case EditorMode.delete: editorDeleteMode.onClick(); break;
    }
  }
  
  void update() {
    switch (mode) {
      case EditorMode.place: editorPlaceMode.update(); break;
    }
  }
  
  void draw() {
    
    String modeDisplay = "";
    
    switch (mode) {
      case EditorMode.place: 
        editorPlaceMode.draw();
        modeDisplay = "Place mode";
        break;
        
      case EditorMode.delete:
        modeDisplay = "Delete mode";
        break;
    }
    
    PVector textPos = camera.getWorldCoords(100, 100);
    
    fill(0);
    textSize(15);
    text("Mode: " + modeDisplay, textPos.x, textPos.y);
  }
  
  void onDrag() {
    if (mouseButton == RIGHT) {
      camera.enable = false;
      
      float deltaX = mouseX - pmouseX;
      float deltaY = mouseY - pmouseY;
      
      camera.pos.x -= deltaX;
      camera.pos.y -= deltaY;
    }
  }
}


// EDITOR PLACE MODE

class EditorPlaceMode {
  ArrayList<PVector> tempPoints = new ArrayList();
  
  void update() {
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
  
  void draw() {
    for (PVector p : tempPoints) {
      ellipse(p.x, p.y, 10, 10);
    }
  }
}

// EDITOR DELETE MODE

class EditorDeleteMode {
  void onClick() {
    for (Solid s : solids) {
      PVector mousePoint = camera.getWorldCoords(mouseX, mouseY);
      
      if (isInside(s, mousePoint)) {
        solids.remove(s);
        break;
      }
    }
  }
  
  void draw() {
    for (Solid s : solids) {
      PVector mousePoint = camera.getWorldCoords(mouseX, mouseY);
      
      if (isInside(s, mousePoint)) {
        fill(#ff0000);
        s.draw();
        break;
      }
    }
  }
}



















// End
