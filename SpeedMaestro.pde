
Solid s;
Player player;
Camera camera;

Editor editor;

ArrayList<Solid> solids = new ArrayList();

boolean lastKeyPressed = false;

void setup() {
  size(800, 600);
  
  camera = new Camera();
  editor = new Editor();
  
  spawnPlayer();
  solids.add(new Solid(0, 300, 500, 300, 250, 400)); // Ground
  //solids.add(new Solid(300, 300, 500, 200, 0, 0));
  
  solids.get(0).name = "Solid 0";
  //solids.get(1).name = "Solid 1";
  // solids.get(2).name = "Solid 2";
}

void draw() {
  
  background(#CCCCCC);
  
  camera.updateFocus(player.pos, player.facing);
  camera.update();
  
  
  // Draw within camera translation
  pushMatrix();
  
  float xOffset = camera.worldToScreenCoords(0, 0).x;
  
  translate(xOffset, 0);
  
  editor.update();
  
  player.update();
  player.draw();
  
  for (Solid s : solids) {
    fill(#FFFFFF);
    s.draw();
  }
  
  editor.draw();
  
  popMatrix();
  
  fill(255, 0, 0);
  ellipse(camera.pos.x, camera.pos.y, 10, 10);
  
  lastKeyPressed = keyPressed;
  // Input.resetPressInputs();
}

void mouseClicked() {
  editor.onClick();
}

void mouseDragged() {
  editor.onDrag();
}

void keyPressed() {
  Input.registerInputs(keyCode, true);
  
  if (Input.left || Input.right) camera.enable = true;
  
  if (key == 'r') {
    println("Spawning player");
    spawnPlayer();
  }
  
  if (key == ESC) {
    key = 0;
  }
}

void keyReleased() {
  Input.registerInputs(keyCode, false);
  editor.switchMode();
  editor.onKeyReleased();
}
