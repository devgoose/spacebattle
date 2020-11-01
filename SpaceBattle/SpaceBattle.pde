
// Globals
/*
Credits:

Planet models and textures:
From user "3dShard" on CGTrader:
  https://www.cgtrader.com/free-3d-models/space/planet/alien-grey-planet
  https://www.cgtrader.com/free-3d-models/space/planet/pink-alien-planet
  https://www.cgtrader.com/free-3d-models/space/planet/blue-water-planet
  https://www.cgtrader.com/free-3d-models/space/planet/natural-planet
  
Blue planet and sun texture from:
  https://www.solarsystemscope.com/textures/
  
Spaceships from:
  https://www.cgtrader.com/free-3d-models/space/spaceship/spaceships-pack


*/

/*
  write up and video:
  
  Show overview of full program working
  
  Basic flocking: show flocking with no planets or bullets
  Camera: Show moving around
  Camera: show k/j/l feature
  User interaction: ???
  Obstacle avoidance: Show avoiding of planets, multiple planets
  Explain additional behaviors -> dying whwen being shot, turning on particles, targeting 
  Boid rendering: 
  Benchmarking features
  
  Particle System: Individual bullets shooting
  Particle System: Explosions exploding
  


*/

Flock redflock;
Flock blueflock;
Flock[] flocks;

Camera camera;
Boundary boundary; 

ParticleFactory particleFactory;
ParticleFactory bulletFactory;
ParticleFactory explosionFactory;
Skybox skybox;
float dt = 1/frameRate;
float lf;
PShape blueShip;
PShape redShip; // about 35 units off in z dimension
PShape playerShip;

// Obstacles
ArrayList<Obstacle> obstacles;

PFont font;

boolean defaultMode;
boolean gameMode;
boolean boidMode;
boolean paused;
Player player;
int  numBoids;


void setup() {
  frameRate(35);
  numBoids = 75;
  gameMode = false;
  boidMode = false;
  defaultMode = true;
  paused = false;
  obstacles = new ArrayList();
  
  Obstacle sun = new Obstacle("purpleplanet/planet2.obj");
  sun.setTexture("sun.jpg");
  sun.setOffset(new Vec3(1, -90, 5));
  sun.setScale(0.01);
  sun.setRadius(150);
  sun.setSpin(PI / 500);
  sun.setEmissive(color(255, 200, 200));
  
  Obstacle green = new Obstacle("greenplanet/planet2.obj");
  green.setTexture("greenplanet/planet2.png");
  green.setOffset(new Vec3(1, -90, 5));
  green.setScale(0.01);
  green.setRadius(50);
  green.setSpin(PI / 250);
  green.setOrbit(PI / 500);
  green.setOrbitDistance(400);
  green.setOrbitTilt(PI / 4);
  
  Obstacle grey = new Obstacle("greyplanet/planet2.obj");
  grey.setTexture("greyplanet/planet2.png");
  grey.setOffset(new Vec3(1, -90, 5));
  grey.setScale(0.01);
  grey.setRadius(60);
  grey.setSpin(PI / 200);
  grey.setOrbit(PI / 700);
  grey.setOrbitDistance(-550);
  grey.setOrbitTilt(-PI / 4);
  
  Obstacle rock = new Obstacle("greyplanet/planet2.obj");
  rock.setTexture("planet3.jpg");
  rock.setOffset(new Vec3(1, -90, 5));
  rock.setScale(0.01);
  rock.setRadius(40);
  rock.setSpin(PI / 100);
  rock.setOrbit(PI / 300);
  rock.setOrbitDistance(350);
  rock.setOrbitTilt(PI / 1.1);
  
  Obstacle blue = new Obstacle("greyplanet/planet2.obj");
  blue.setTexture("uranus.jpg");
  blue.setOffset(new Vec3(1, -90, 5));
  blue.setScale(0.01);
  blue.setRadius(60);
  blue.setSpin(PI / 50);
  blue.setOrbit(PI / 350);
  blue.setOrbitDistance(600);
  blue.setOrbitTilt(-PI/ 1.5);
  
  obstacles.add(sun);
  obstacles.add(green);
  obstacles.add(grey);
  obstacles.add(rock);
  obstacles.add(blue);
  // Must update BEFORE we instantiate the flock,
  // because the obstacle's initial position is only set after an update
  for (int i = 0; i < obstacles.size(); i++) {
    obstacles.get(i).update();
  }
  
  blueShip = loadShape("spaceship2.obj");
  redShip = loadShape("spaceship2.obj");
  playerShip = loadShape("spaceship10.obj");
  
  redShip.setFill(color(255, 107, 159));
  redShip.translate(0, 0, -35);
  redShip.scale(2);
  blueShip.setFill(color(41, 212, 255));
  blueShip.translate(0, 0, -35);
  blueShip.scale(2);
  playerShip.setFill(color(35, 145, 64));
  playerShip.translate(0, -0.5, 17.75);
  //playerShip.rotateX(PI);
  //playerShip.scale(2);
  playerShip.scale(2, 3, 2);
  
  
  particleFactory = new ParticleFactory();
  bulletFactory = new BulletFactory();
  explosionFactory = new ExplosionFactory();

  camera = new Camera(0, 0, 1500); //1500

  boundary = new Boundary(0, 0, 0, 200); // Create boundary centered at origin with r=50
  
  flocks = new Flock[2];
  redflock = new Flock(boundary, redShip, numBoids, "red");
  blueflock = new Flock(boundary, blueShip, numBoids, "blue");
  redflock.setBulletColor(color(255, 168, 199));
  redflock.setEnemy(blueflock.boids);
  blueflock.setBulletColor(color(186, 201, 255));
  blueflock.setEnemy(redflock.boids);
  flocks[0] = redflock;
  flocks[1] = blueflock;
  player = new Player(playerShip);
  
  skybox = new Skybox(5000);

  size(1280, 720, P3D);
  
  lf = 200;
  
}



void draw() {
  dt = 1.0/frameRate;
  if (paused) { dt = 0; } 
  //// Main program!
  //// Render sun (and lights) first
  pointLight(255, 255, 255, 0, 0, 0); // this lights the actual sun
  lightFalloff(0, 0, 1.0/pow(obstacles.get(0).radius*2, 2)); // falloff should be 1 
  ambientLight(255, 180, 180, 0, 0, 0);
  obstacles.get(0).update();
  obstacles.get(0).render();
  // Render skybox (should be lit up)
  skybox.update(dt);
  skybox.render();
  // Render planets (obstacles)
  for (int i = 1; i < obstacles.size(); i++) {
    obstacles.get(i).update();
    obstacles.get(i).render();
  }
  
  // Update camera
  camera.Update(1.0/frameRate);
  // Update flocks
  fill(255, 0, 0);
  sphereDetail(5);
  specular(255, 255, 255);
  ambient(200, 200, 200);
  for (int i = 0; i < flocks.length; i++) {
    flocks[i].update();
    flocks[i].render(dt);
  } 

  player.update(dt);
  player.render();
 
   // Print information
  int numAgents = flocks[0].agents() + flocks[1].agents();
  System.out.println("FPS:" + frameRate + " agents: " + numAgents + "\t" + flocks[0].boids[0].stats());
  
}

/* INPUTS
Three modes, switched with the keys 1: default, 2: game, 3: boid camera

On default mode, the simulation runs as normal and you can move the camera around. 
W/S: Accelerate forward/backward
A/D: Accelerate left/right
E/Q: Accelerate up/down
LEFT/RIGHT: Turn left/right
UP/DOWN: Turn up/down

In default mode, you can also edit the parameters of the flock actively with these keys:
T/F: Increment maximum boid speed up and down
Y/G: Increment maximum boid acceleration up and down
U/H: Increment the how influential a nearby enemy boid is to each boid's movement
I/J: Increment how well a boid can aim at a target

In game mode, the camera is fixed to a green ship, and you can control the ship.
W/S: Accelerate forward/backward
A/D: Yaw left/right
LEFT/RIGHT: Roll left/right
UP/DOWN: Pitch up/down
SPACE: Hold to shoot
The ship's rotational velocity will decelerate automatically, but its forward velocity does not (because it's in space.)
The ship acts as an object just like all the boids. Every boid in the scene will try to target you if it can. You can
destroy boids by shooting them as well;

In boid mode, the camera is affixed to a boid, so you can view the boid from it's perspective. It is not controllable:
LEFT/RIGHT: change boid to focus on 

*/
void keyPressed() {
  if (key == '1') {
    defaultMode = true; 
    gameMode = false;
    boidMode = false;
  }
  if (key == '3') {
    defaultMode = false; 
    gameMode = true; 
    boidMode = false;
  }
  if (key == '2') {
    defaultMode = false; 
    gameMode = false; 
    boidMode = true;
  }
  
  if (defaultMode && key == ' ') {
    paused = !paused;
  }
  
  camera.HandleKeyPressed();
  player.handleKeyPressed();
}

void keyReleased() {
  camera.HandleKeyReleased();
  player.handleKeyReleased();
  for (int i = 0; i < flocks.length; i++ ) {
    flocks[i].handleKeyReleased();
  }
}
