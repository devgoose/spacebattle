class Boid {
    Vec3 position;
    Vec3 velocity;
    Vec3 acceleration;
    float radius;
    float influenceRange;
    
    float sepMul;
    float alignMul;
    float attractMul;
    float wanderMul;
    float targetMul; // How much weight the target has towards attraction force. 
    float targetAccel; // How much to boost accel when targeting
    float avoidMul;
    float avoidDist;
    
    float maxAccel;
    float maxSpeed;
    Boundary boundary;
    float coe; 
    PShape model;
    ParticleEmitter bulletEmitter;
    ParticleEmitter explosionEmitter;
    boolean alive;
    Boid target;
    Player targetPlayer;
    float fov;
    float shootfov;
    boolean shooting;
    float range;
    String name;
    
    boolean selected;
    
    
    Boid(Boundary boundary, PShape model, String name) {
       this.boundary = boundary;
       this.position = boundary.randomInside();
       this.velocity = new Vec3(random(1),random(1),random(1));
       this.velocity.normalize();
       this.acceleration = new Vec3(0, 0, 0);
       this.radius = 6; // hitbox size
       this.influenceRange = 30;
       
       this.sepMul = 20;
       this.alignMul = 20;
       this.attractMul = 1;
       this.wanderMul = 0.5;
       this.targetMul = 5;
       this.targetAccel = 1.5;
       this.avoidMul = 1000; // Huge, basically should be the main and only force 
       this.avoidDist = 200;
       
       this.maxAccel = 2;
       this.maxSpeed = 3.5;
       this.coe = 0.8;
       this.model = model;
       this.alive = true;
       this.name = name;
       this.shooting = false;
       this.selected = false;
       this.target = null;
       this.targetPlayer = null;
       spawn();
    }
    
    void spawn() {
      int c;
      if (name.equals("red")) {
        c = 1;
      } else {
        c = 2;
      }
      Obstacle o = obstacles.get(c);
      Vec3 dir = position.minus(o.position);
      dir.setToLength(o.radius + 20);
      this.position = o.position.plus(dir);
      dir.setToLength(random(0, maxSpeed));
      velocity = dir;
    }
    
    void setBulletEmitter(ParticleEmitter emitter) {
      this.bulletEmitter = emitter;
    }
    
    void setExplosionEmitter(ParticleEmitter emitter) {
      this.explosionEmitter = emitter;
    }
    
    void setTarget(Boid target) {
     this.target = target; 
     this.targetPlayer = null;
    }
    
    void setTargetPlayer(Player player) {
      this.targetPlayer = player;
      this.target = null;
    }
    
    void setRange(float range) {
      this.range = range;
    }
    
    void setFov(float fov) {
      this.fov = fov;
      this.shootfov = fov / 3;
    }
    
    void setName(String name) {
      this.name = name;
    }
    
    // Update position based on all other boids in flock
    void update(Boid boids[]) {
      if (paused) { return; }
      this.acceleration = new Vec3(0,0,0);
      Vec3 averagePos = new Vec3(0,0,0); // Average position of nearby boids
      Vec3 averageVel = new Vec3(0,0,0);
      float boidsInRange = 0; // Float because targets can be weighted by a float
      
      for (int i = 0; i < boids.length; i++) {
        Boid compare = boids[i];
        float distance = position.distanceTo(boids[i].position);
        
        // Only consider boids in range of influence
        if (distance > 0.01 && distance < influenceRange) {
          boidsInRange++;
          averagePos.add(compare.position);
          averageVel.add(compare.velocity);
          // Separation 
          Vec3 separation = position.minus(compare.position).normalized();
          separation.setToLength(200.0/pow(distance, 2));
          acceleration.add(separation.times(sepMul));
          
        }
      }
      
      // Avoid obstacles AND check for collision
      for (int i = 0; i < obstacles.size(); i++) {
        Obstacle obstacle = obstacles.get(i);
        Vec3 avoid = position.minus(obstacle.position);
        float distanceToObstacle = avoid.length() - obstacle.radius;
        avoid.normalize();
        
        // hit the planet!!! kaboom!!!
        if (distanceToObstacle < 3) { // correcting for the size of the objects here
          kill();
          break;
        }
        
        // Oh shit steer away!!!
        if (distanceToObstacle < avoidDist) {
          avoid.setToLength(50.0/pow(distanceToObstacle, 2));
          acceleration.add(avoid.times(avoidMul));
        }
      }
      
      // Factor in target to attraction
      // Works for both player targeting and boid targeting
      if (target != null) {
         Vec3 aim = target.position.minus(position);
         aim.normalize();
         acceleration.add(aim.times(targetMul));
      } else if (targetPlayer != null) {
         Vec3 aim = targetPlayer.position.minus(position);
         aim.normalize();
         acceleration.add(aim.times(targetMul));
      }
      
      // Attraction and Alignment
      if (boidsInRange > 0) { 
        averagePos.mul(1.0 / boidsInRange);
        Vec3 attraction = averagePos.minus(position);
        acceleration.add(attraction.times(attractMul));
        
        averageVel.mul(1.0 / boidsInRange);
        Vec3 alignment = averageVel.minus(velocity);
        acceleration.add(alignment.times(alignMul));
      }
      
       // Check if out of bounds
      Vec3 dir = boundary.center.minus(position);
      float offset = boundary.distance(position);
      if (offset > 0) {
        dir.setToLength(offset/50);
        acceleration.add(dir);
      }
      
      acceleration.add(wander().times(wanderMul));
      acceleration.clampToLength(maxAccel * (target == null ? 1.0 : targetAccel));
      acceleration.mul(dt);
      
      
      velocity.add(acceleration);
      velocity.clampToLength(maxSpeed);
      position.add(velocity);
     
      bulletEmitter.setPosition(position);
      bulletEmitter.setDirection(velocity);
      explosionEmitter.setPosition(position);
      
      // Always run emitters to simulate particles, but pause and resume dictate new particle generation
      if ((target == null && targetPlayer == null) || shooting == false) {
        bulletEmitter.pause();
      } else {
        bulletEmitter.resume();
      }
      
      if (alive) {
        explosionEmitter.pause();
      } else {
        explosionEmitter.start();
        if (explosionEmitter.isFinished()) {
          revive();
        }
      }
    }
    
    Vec3 wander() {
      Vec3 random = new Vec3(1-random(2),1-random(2),1-random(2));
      // also move it forward
      return random.plus(velocity);
    }
    
    
    void render(float dt) {
      if (alive) {
        Vec3 baseDir = new Vec3(1, 0, 0);
        Vec3 moveDir = new Vec3(velocity);
        moveDir.normalize();
        float angle = acos(dot(baseDir, moveDir));
        Vec3 axis;
        if (angle > 0) {
          axis = cross(baseDir, moveDir);
        }
        else {
          axis = cross(moveDir, baseDir);
        }
        PMatrix rotMat = new PMatrix3D();
        rotMat.rotate(angle, axis.x, axis.y, axis.z);
        
        pushMatrix();
        translate(position.x, position.y, position.z);
        applyMatrix(rotMat);
        scale(0.5);
        shape(model);
        popMatrix();
      } 

      
      // particles may still be around, msut always render them
      bulletEmitter.run(dt);
      explosionEmitter.run(dt);
    }
    
    String stats() {
      return ("\tspeed:" + maxSpeed + "\taccel:" + maxAccel + "\ttargetmul:" + targetMul + "\ttargetaccel:" + targetAccel);
    }
    
    void kill() {
      alive = false;
    }
    
    void select() {
      selected = true;
    }
    
    void deselect() {
      selected = false;
    }
    
    void revive() {
      explosionEmitter.pause();
      explosionEmitter.reset();
      alive = true;
      spawn();
      //float b = boundary.radius;
      //position = new Vec3();
      //position.rand();
      //position.setToLength(random(b*2, b*2));
    }
    
    boolean canTarget(Boid enemyBoid) {
      if (enemyBoid.alive && this.alive) {
        Vec3 direction = new Vec3(velocity);
        direction.normalize();
        Vec3 distance = enemyBoid.position.minus(this.position);
        
        float min = range;
        if (target != null) {
          min = target.position.distanceTo(position) - 10; // minus 10 because don't switch target just cause some passerby
        }
        
        if (distance.length() < min) {
          distance.normalize();
          float angle = acos(dot(distance, direction));
          if (angle < fov) {
            if (angle < shootfov) {
              this.shooting = true;
            } else {
              this.shooting = false;
            }
            return true;
          } 
        }
      }
      return false;
    }
    
    boolean canTargetPlayer(Player player) {
      if (player.alive && this.alive) {
        Vec3 direction = new Vec3(velocity);
        direction.normalize();
        Vec3 distance = player.position.minus(this.position);
        
        float min = range;
        if (target != null) {
          min = target.position.distanceTo(position) - 10;
        }
        
        if (distance.length() < min) {
          distance.normalize();
          float angle = acos(dot(distance, direction));
          if (angle < fov) {
            if (angle < shootfov) {
              this.shooting = true;
            } else {
              this.shooting = false;
            }
            return true;
          }
        }
      }
      return false;
    }
   
}
