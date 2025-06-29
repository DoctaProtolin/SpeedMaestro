



Solid s;
Player player;
ArrayList<Solid> solids = new ArrayList();

boolean lastKeyPressed = false;

void setup() {
  size(1000, 500);
  s = new Solid(new PVector(10, 100), new PVector(200, 200), new PVector(50, 50));
  
  player = new Player(100, 100, 35, 60);
  solids.add(new Solid(0, 300, 500, 300, 250, 400));
  solids.add(new Solid(300, 300, 500, 200, 0, 0));
}

void draw() {
  
  
  background(200, 200, 200);
  
  solids.get(1).points[2] = new PVector(mouseX, mouseY);
  
  player.update();
  player.draw();
  

  
  for (Solid s : solids) {
    fill(#ffffff);
    s.draw();
  }
  
  lastKeyPressed = keyPressed;
  // Input.resetPressInputs();
}


void keyPressed() {
  Input.registerInputs(keyCode, true);
  
  if (key == ESC) {
    key = 0;
  }
}

void keyReleased() {
  Input.registerInputs(keyCode, false);
  println("Release");
}
