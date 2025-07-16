

static class EditorMode {
  static final int place  = 1;
  static final int delete = 2;
  static final int save   = 3;
}

class Editor {
  
  int mode = EditorMode.delete;
  boolean enableSwitchMode = true;
  
  EditorPlaceMode  editorPlaceMode;
  EditorDeleteMode editorDeleteMode;
  EditorSaveMode   editorSaveMode;
  
  Editor() {
    editorPlaceMode  = new EditorPlaceMode();
    editorDeleteMode = new EditorDeleteMode();
    editorSaveMode   = new EditorSaveMode(this);
  }
  
  void switchMode() {
    if (!enableSwitchMode) return;
    
    switch (keyCode) {
      case 49: mode = EditorMode.place;  break;
      case 50: mode = EditorMode.delete; break;
      case 51: mode = EditorMode.save;   break;
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

      case EditorMode.save:
        modeDisplay = "Load & Save (mode)";
        break;
        
      default:
        modeDisplay = "Unknown?!";
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
      
      // Drag window
      camera.pos.x -= deltaX;
      camera.pos.y -= deltaY;
    }
  }
  
  void onKeyReleased() {
    switch (mode) {
      case EditorMode.save: editorSaveMode.onKeyReleased(); break;
    }
  }
}


// ===== EDITOR PLACE MODE =====

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
    
    fill(0, 255, 0);
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

// ===== EDITOR DELETE MODE =====

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

class EditorSaveMode {
  Editor editor;
  boolean saveMode = false;
  boolean loadMode = false;
  
  EditorSaveMode(Editor e) {
    editor = e;
  }
  
  boolean saveData(String fileName) {
    String[] data = new String[solids.size()]; // Initialize data string
    
    println("Saving level data...");
    
    // Check if file exists
    if (loadStrings(fileName) != null) {
      println("Cannot save to preexisting file location: " + fileName);
      return false;
    }
    
    for (int i = 0; i < solids.size(); i ++) {
      Solid solid = solids.get(i);
      String solidData = "";
      
      for (int j = 0; j < solid.points.length; j ++) {
        PVector point = solid.points[j];
        solidData += Float.toString(point.x) + "," + Float.toString(point.y);
        
        if (j < solid.points.length - 1) solidData += ",";
      }
      
      float progress = (i+1)/(float)data.length * 100;
      println("Compiling: " + Float.toString(progress) + "%");
      
      data[i] = solidData;
    }
    
    saveStrings(fileName, data);
    println("Saved.");
    return true;
  }
  
  boolean loadData(String fileName) {
    String[] data = loadStrings(fileName);
    
    if (data == null) {
      println("No data to load for: " + fileName);
      return false;
    }
    
    println("Initializing load");
    solids = new ArrayList();
    
    for (int i = 0; i < data.length; i ++) {
      String datum = data[i];
      String coords[] = datum.split(",");
      Solid tempSolid = new Solid(0, 0, 0, 0, 0, 0);
      
      boolean isX = true;
      
      for (int j = 0; j < coords.length; j ++) {
        int   pointIndex = floor(j/2);
        float coordValue = parseFloat(coords[j]);
        
        if (isX) tempSolid.points[pointIndex].x = coordValue;
        else     tempSolid.points[pointIndex].y = coordValue;
        isX = !isX;
      }
      
      solids.add(tempSolid);
      
      float progress = (i+1)/(float)data.length * 100;
      println("Decompiling: " + Float.toString(progress) + "%");
    }
    
    spawnPlayer();
    return true;
  }
  
  void onKeyReleased() {
    if (key == 's') {
      editor.enableSwitchMode = false;
      saveMode = true;
      loadMode = false;
      println("Enabled saving; pick a save slot from 1-3");
      return;
    }
    
    if (key == 'l') {
      editor.enableSwitchMode = false;
      saveMode = false;
      loadMode = true;
      println("Enabled loading; pick a save slot from 1-3");
      return;
    }
    
    boolean success = true;
    
    if (key >= 49 && key <= 53) {
      if (saveMode) {
        success = saveData("saves/slot" + Integer.toString(key - 49) + ".txt");
        saveMode = false;
        
      } else if (loadMode) {
        success = loadData("saves/slot" + Integer.toString(key - 49) + ".txt");
        loadMode = false;
      }
    }
    
    if (success) {
      editor.enableSwitchMode = true;
    } else {
      println("Operation failed");
    }
  }
}

















// End
