



Solid s;
Player player;
Camera camera;

Editor editor;

ArrayList<Solid> solids = new ArrayList();

boolean lastKeyPressed = false;

void setup() {
  size(1000, 500);
  
  camera = new Camera();
  editor = new Editor();
  
  player = new Player(100, 100, 35, 60);
  solids.add(new Solid(0, 300, 500, 300, 250, 400));
  solids.add(new Solid(300, 300, 500, 200, 0, 0));
}

void draw() {
  
  
  background(200, 200, 200);
  
  // solids.get(1).points[2] = new PVector(mouseX, mouseY);
  
  player.update();

  camera.updateFocus(player.pos);
  camera.update();
  
  
  // Draw within camera translation
  pushMatrix();
  
  translate(width/2-camera.pos.x, 0);
  editor.update();
  
  player.draw();
  
  for (Solid s : solids) {
    fill(#ffffff);
    s.draw();
  }
  
  popMatrix();
  
  fill(255, 0, 0);
  ellipse(camera.pos.x, camera.pos.y, 10, 10);
  
  lastKeyPressed = keyPressed;
  // Input.resetPressInputs();
}

void mouseClicked() {
  editor.onClick();
}


void keyPressed() {
  Input.registerInputs(keyCode, true);
  
  if (key == ESC) {
    key = 0;
  }
}

void keyReleased() {
  Input.registerInputs(keyCode, false);
}
