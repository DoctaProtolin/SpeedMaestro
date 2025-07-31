

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
        editorSaveMode.draw();
        break;
        
      default:
        modeDisplay = "Unknown?!";
        break;
    }
    
    PVector textPos = camera.screenToWorldCoords(100, 100);
    
    fill(0);
    textSize(15);
    text("Mode: " + modeDisplay, textPos.x, textPos.y);
    
    if (!enableSwitchMode) {
      fill(255, 0, 0);
      text("Locked!", textPos.x, textPos.y + 20);
    }
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
    PVector point = camera.screenToWorldCoords(mouseX, mouseY);
      
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
    PVector point = camera.screenToWorldCoords(mouseX, mouseY);
      
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
      fill(#00ff00);
      ellipse(p.x, p.y, 10, 10);
    }
  }
}

// ===== EDITOR DELETE MODE =====

class EditorDeleteMode {
  void onClick() {
    for (Solid s : solids) {
      PVector mousePoint = camera.screenToWorldCoords(mouseX, mouseY);
      
      if (isInside(s, mousePoint)) {
        solids.remove(s);
        break;
      }
    }
  }
  
  void draw() {
    for (Solid s : solids) {
      PVector mousePoint = camera.screenToWorldCoords(mouseX, mouseY);
      
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
  boolean saveMode   = false;
  boolean loadMode   = false;
  boolean deleteMode = false;
  boolean updateSaveDisplay = true;
  
  boolean[] saveDisplay = {false, false, false};
  
  EditorSaveMode(Editor e) {
    editor = e;
  }
  
  void draw() {
    
    if (updateSaveDisplay) {
      
      for (int i = 0; i < 3; i ++) {
        String slotName = "saves/slot" + Integer.toString(i) + ".txt";
        String[] data = loadStrings(slotName); // For checking if file is empty
    
        // Check if file exists
        saveDisplay[i] = data != null && !data[0].equals("EMPTY");
      }
      
      // Reset so we don't constantly read these files
      updateSaveDisplay = false;
    }
    
    PVector windowPos = camera.screenToWorldCoords(width - 200, 200);
    
    
    for (int i = 0; i < 3; i ++) {
      String displayText = "";
      if (saveDisplay[i]) {
        fill(#FF0000);
        displayText = "In use";
      } else {
        fill(#4F934C);
        displayText = "Empty";
      }
      
      textSize(30);
      text(displayText, windowPos.x, windowPos.y + i * 50);
    }
  }
  
  boolean saveData(String fileName) {
    String[] data = loadStrings(fileName); // For checking if file is empty
    
    // Check if file exists
    if (data != null && !data[0].equals("EMPTY")) {
      println("Cannot save to preexisting file location: " + fileName);
      return false;
    }
    
    println("Saving level data...");
    
    data = new String[solids.size()]; // Initialize data string
    
    for (int i = 0; i < solids.size(); i ++) {
      Solid solid = solids.get(i);
      String solidData = "";
      
      for (int j = 0; j < solid.points.length; j ++) {
        PVector point = solid.points[j];
        solidData += Float.toString(point.x) + "," + Float.toString(point.y) + ",";
      }
      
      solidData += solid.name;
      
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
    
    if (data == null || data[0].equals("EMPTY")) {
      println("No data to load for: " + fileName);
      return false;
    }
    
    println("Initializing load");
    solids = new ArrayList();
    
    for (int i = 0; i < data.length; i ++) {
      String datum = data[i];
      String values[] = datum.split(",");
      Solid tempSolid = new Solid(0, 0, 0, 0, 0, 0);
      
      boolean isX = true;
      
      for (int j = 0; j < 6; j ++) {
        int   pointIndex = floor(j/2);
        float coordValue = parseFloat(values[j]);
        
        if (isX) tempSolid.points[pointIndex].x = coordValue;
        else     tempSolid.points[pointIndex].y = coordValue;
        
        isX = !isX; // Switch between setting x and y coords
      }
      
      tempSolid.name = values[6];
      
      solids.add(tempSolid);
      
      float progress = (i+1)/(float)data.length * 100;
      println("Decompiling: " + Float.toString(progress) + "%");
    }
    
    spawnPlayer();
    return true;
  }
  
  boolean deleteData(String fileName) {
    String data[] = loadStrings(fileName);
    
    if (data == null || data[0] == "EMPTY") {
      println("File does not exist or has been cleared.");
      return false;
    }
    
    data = new String[1];
    data[0] = "EMPTY";
    
    saveStrings(fileName, data);
    
    println("File cleared.");
    
    return true;
  }
  
  void onKeyReleased() {
    
    editor.enableSwitchMode = false;
    updateSaveDisplay = true;
    
    if (key == 's') {
      saveMode   = true;
      loadMode   = false;
      deleteMode = false;
      
      println("Enabled saving; pick a save slot from 1-3");
      return;
    } else if (key == 'l') {
      saveMode   = false;
      loadMode   = true;
      deleteMode = false;
      
      println("Enabled loading; pick a save slot from 1-3");
      return;
    } else if (key == 'd') {
      saveMode   = false;
      loadMode   = false;
      deleteMode = true;
      
      println("Enabled DELETING; pick a save slot from 1-3");
    } else {
      editor.enableSwitchMode = true;
    }
    
    boolean success = true;
    
    if (key >= 49 && key <= 53) {
      
      String slotName = "saves/slot" + Integer.toString(key - 49) + ".txt";
      
      if (saveMode) {
        success = saveData(slotName);
        saveMode = false;
        
      } else if (loadMode) {
        success = loadData(slotName);
        loadMode = false;
        
      } else if (deleteMode) {
        success = deleteData(slotName);
        deleteMode = false;
        
      }
      
      if (success) {
        editor.enableSwitchMode = true;
      } else {
        println("Operation failed");
      }
    }
    
    
  }
}

















// End
