class Flock {
  int maxBoids;
  float influenceRange;
  PShape model;
  Boid[] boids;
  Boundary boundary;
  Boid[] enemyboids;
  color bulletColor;
  String name;
  int agents;
  
  Flock(Boundary boundary, PShape model, int maxBoids, String name) {
    this.boundary = boundary;
    this.maxBoids = maxBoids;
    this.influenceRange = 5.0;
    this.boids = new Boid[maxBoids];
    this.model = model;
    this.name = name;
    agents = 0;
  }
  
  void setBulletColor(color c) {
    this.bulletColor = c;
  }
  
  int agents() {
    return agents;
  }
  
  void setEnemy(Boid[] enemyboids) {
    this.enemyboids = enemyboids;
    for (int i = 0; i < maxBoids; i++) {
      boids[i] = new Boid(boundary, model, name);
      boids[i].setRange(3000); // TO DO CHANGE????
      boids[i].setFov(PI/4); // TO DO CHANGE??
      //int maxParticles, float rate, float maxLife, float particleLifetime, Vec3 position, Vec3 gravity, Vec3 direction color c, ParticleFactory particleFactory
      ParticleEmitter bulletEmitter = new ParticleEmitter(1000, 100, -1, 1, new Vec3(0,0,0), new Vec3(0,0.2, 0), new Vec3(0,0,1), bulletColor, bulletFactory);
      bulletEmitter.setEnemy(enemyboids);
      
      boids[i].setBulletEmitter(bulletEmitter);
      boids[i].setExplosionEmitter( new ParticleEmitter(5000, 500, 0.1, 2, new Vec3(0, 0, -20), new Vec3(0, 0.1, 0), new Vec3(0, 1, 1), color(255, 182, 99), explosionFactory));
    }
    camera.setBoids(this.boids);
  }
  
  void update() {
   for (int i = 0; i < maxBoids; i++) {
     boids[i].update(boids);
   }
  }
  
  void render(float dt) {
    agents = 0;
   for (int i = 0; i < maxBoids; i++) {
    agents ++;
    Boid boid = boids[i];
    agents += boid.explosionEmitter.numParticles() + boid.bulletEmitter.numParticles();
    boid.setTarget(null);
    if (boid.alive) { 
      for (int j = 0; j < maxBoids; j++) {
       Boid enemyBoid = enemyboids[j];
       if (boid.canTarget(enemyBoid)) {
           boid.setTarget(enemyBoid);
       }
      } 
      // Also must check for the PLAYER target
      if (boid.canTargetPlayer(player)) {
        boid.setTargetPlayer(player);
      }
    } 
    else {
     // If boid is dead
     // Make sure explosion is finished
     if (boid.explosionEmitter.isFinished()) {
       boid.revive();  
     }
    }
    boid.render(dt);
   }
  }
  
  void handleKeyReleased() {
    Boid b = boids[0];
    float maxSpeed = b.maxSpeed;
    float maxAccel = b.maxAccel;
    float targetMul = b.targetMul;
    float targetAccel = b.targetAccel;
    if (defaultMode) {
      if (key == 't') { for (int i = 0; i < boids.length; i++) { boids[i].maxSpeed = maxSpeed + 0.5; } }
      if (key == 'f') { for (int i = 0; i < boids.length; i++) { boids[i].maxSpeed = maxSpeed - 0.5; } }
      
      if (key == 'y') { for (int i = 0; i < boids.length; i++) { boids[i].maxAccel = maxAccel + 0.5; } }
      if (key == 'g') { for (int i = 0; i < boids.length; i++) { boids[i].maxAccel = maxAccel - 0.5; } } 
      
      if (key == 'u') { for (int i = 0; i < boids.length; i++) { boids[i].targetMul = targetMul + 1; } }
      if (key == 'h') { for (int i = 0; i < boids.length; i++) { boids[i].targetMul = targetMul - 1; } }
      
      if (key == 'j') { for (int i = 0; i < boids.length; i++) { boids[i].targetAccel = targetAccel - .1; } }
      if (key == 'i') { for (int i = 0; i < boids.length; i++) { boids[i].targetAccel = targetAccel + .1; } }
    }
  }
}
