class ParticleEmitter {
  ArrayList<Particle> particles;
  int maxParticles; 
  int numParticles;
  float maxLife; // will be negative if the emitter loops forever
  float particleLifetime;
  float lifetime;
  float rate; // particles per second to spawn
  color c;
  Vec3 position;
  Vec3 gravity;
  Vec3 direction;
  boolean active;
  Boid[] enemyboids;
  boolean isPlayer;
  
  ParticleFactory particleFactory;
  
  ParticleEmitter(int maxParticles, float rate, float maxLife, float particleLifetime, Vec3 position, Vec3 gravity, Vec3 direction, color c, ParticleFactory particleFactory) {
    this.maxParticles = maxParticles;
    this.rate = rate;
    this.maxLife = maxLife;
    this.particleLifetime = particleLifetime;
    this.position = position;
    this.gravity = gravity;
    this.direction = direction; this.direction.normalize();
    this.c = c;
    this.particleFactory = particleFactory;
    
    this.particles = new ArrayList<Particle>();
    this.numParticles = 0;
    this.lifetime = 0;
    this.active = false;
    this.isPlayer = false;
  }
  
  int numParticles() {
    return particles.size();
  }
  
  void togglePlayer() {
    this.isPlayer = true;
  }
  
  void setEnemy(Boid[] enemyboids) {
    this.enemyboids = enemyboids;
  }
  
  void setDirection(Vec3 direction) {
    this.direction = direction;
  }
  
  void setPosition(Vec3 position) {
    this.position = position;
  }
  
  void setGravity(Vec3 gravity) {
    // NOT USED!!!!!
    this.gravity = gravity;
  } //<>// //<>// //<>// //<>// //<>//
   //<>// //<>// //<>// //<>// //<>//
  // Deletes, updates, renders, and spawns particles
  void run(float dt) {
    boolean renderedLight = false; // Explosions should render only one light
    Obstacle sun = obstacles.get(0);
    for (int i = 0; i < numParticles; i++) {
     Particle particle = particles.get(i);
     // ALWAYS update existing particles and render first
     Vec3 grav = sun.position.minus(particle.position);
     grav.setToLength(5);
     particle.update(grav, dt);
     fill(particle.c);
     stroke(particle.c);
     particle.render();
     
     // Remove expired particles for next render period
     if (particle.isExpired()) {
       particles.remove(i);
       --numParticles;
       --i;
       continue;
     }

     // Special Conditions for each type of particle

     // Bullet collision with enemy
     // ONLY FOR BULLETS!!!
     if (particleFactory.type().equals("BulletFactory")) {
       for (int j = 0; j < enemyboids.length; j++) {
         Boid enemyBoid = enemyboids[j];
         if (particle.position.distanceTo(enemyBoid.position) < enemyBoid.radius) {
           particles.remove(i);
           --numParticles;
           --i;
           enemyBoid.kill();
           break;
         }
       } 
       if (!isPlayer) {
         if (particle.position.distanceTo(player.position) < player.radius) {
           particles.remove(i);
           --numParticles;
           --i;
           player.kill();
           continue;
         }
       }
     } 
     else if (particleFactory.type().equals("ExplosionFactory")) {
       if (!renderedLight) {
        renderedLight = true;
        //pointLight(red(particle.c),
        //           green(particle.c),
        //           blue(particle.c),
        //           particle.position.x,
        //           particle.position.y,
        //           particle.position.z);
       }
     }
     

    }
    
    // Emit new particles only if is currently active, and the life has not worn off
    if (active && !isExpired()) {
      emit(dt);
    }
    
    // Always increment time
    lifetime += dt;
  }
  
  void resume() {
    active = true;
  }
  
  void pause() {
    active = false;
  }
  
  void start() {
    if (!active) {
      reset();
    }
    active = true;
  }
  
  void emit(float dt) {
    if (paused) { return; }
    int particlesToSpawn = floor(dt * rate);
    if (random(1) > (dt*rate)-particlesToSpawn) {
      ++particlesToSpawn;
    }
    for (int i = 0; i < particlesToSpawn; i++) {
      particles.add(particleFactory.generate(particleLifetime, c, position, direction));
      ++numParticles;
    }
  }
  
  boolean isExpired() {
       return lifetime > maxLife && maxLife > 0;
  }
  
  boolean isFinished() {
    
    return particles.size() == 0 && isExpired();
  
}
  
  boolean isActive() {
    return active;
  }
  
  void reset() {
    lifetime = 0;
  }
 

  
}
