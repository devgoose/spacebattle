class Player {
   PShape model;
   
   boolean wdown;
   boolean adown;
   boolean sdown;
   boolean ddown;
   boolean qdown;
   boolean edown;
   boolean l_down;
   boolean r_down;
   boolean u_down;
   boolean d_down;
   boolean spacedown;
   
   boolean alive;
   
   float maxSpeed;
   float maxYaw;
   float maxPitch;
   float maxRoll;
   
   float speed;
   float rollSpeed;
   float yawSpeed;
   float pitchSpeed;
   
   float pitch;
   float yaw;
   float roll;
   
   float accel;
   float rollAccel;
   float pitchAccel;
   float yawAccel;
   float decel;
   
   float radius; // hitbox size
   
   Vec3 forward;
   Vec3 up;
   Vec3 right;
   Vec3 position;
   
   ParticleEmitter bulletEmitter;
   ParticleEmitter explosionEmitter;
   
   Boid[] enemyBoids;
   
   Player(PShape model) {
     this.model = model;
     init();
   }
   
   void init() {
     this.maxSpeed = 4;
     this.maxYaw = PI / 32.0;
     this.maxPitch = PI / 8.0;
     this.maxRoll = PI / 6.0;
     
     this.speed = 0;
     this.rollSpeed = 0;
     this.pitchSpeed = 0;
     this.yawSpeed = 0;
     
     this.pitch = 0;
     this.yaw = 0;
     this.roll = 0;
     
     this.accel = 3;
     this.rollAccel = PI / 70.0;
     this.pitchAccel = PI / 70.0;
     this.yawAccel = PI / 70.0;
     this.decel = 1;
     
     this.forward = new Vec3(1, 0, 0);
     this.right = new Vec3(0, 0, 1);
     this.up = new Vec3(0, 1, 0);
     this.position = new Vec3();
     
     this.wdown = false;
     this.adown = false;
     this.sdown = false;
     this.ddown = false;
     this.l_down = false;
     this.r_down = false;
     this.u_down = false;
     this.d_down = false;
     this.spacedown = false;
     
     this.radius = 11;
     
     // Assumes enemy flocks are already made
     int maxBoids = 0;
     for (int i = 0; i < flocks.length; i++) {
       maxBoids += flocks[i].maxBoids;
     }
     this.enemyBoids = new Boid[maxBoids];
     int k = 0;
     for (int i = 0; i < flocks.length; i++) {
       Flock cur = flocks[i];
       for (int j = 0; j < cur.maxBoids; j++) {
         enemyBoids[k] = cur.boids[j];
         k++;
       }
     }
     
     //int maxParticles, float rate, float maxLife, float particleLifetime, Vec3 position, Vec3 gravity, Vec3 direction color c, ParticleFactory particleFactory
     this.bulletEmitter = new ParticleEmitter(1000, 100, -1, 1, this.position, new Vec3(0,0.2, 0), this.forward, color(100, 230, 100), new BulletFactory());
     this.bulletEmitter.setEnemy(enemyBoids);
     this.explosionEmitter = new ParticleEmitter(5000, 500, 0.1, 2, this.position, new Vec3(0, 0.1, 0), this.forward, color(255, 182, 99), new ExplosionFactory());
     
     this.alive = true;
     spawn();
   }
   
   void update(float dt) {
     
     float oldpitch = pitch;
     float oldroll = roll;
     float oldyaw = yaw;
     forward.normalize();
     
     if (alive && gameMode) {
       if (wdown) speed += accel * dt;
       if (sdown) speed -= accel * dt;
       if (adown) yawSpeed -= yawAccel * dt;
       if (ddown) yawSpeed += yawAccel * dt;
       if (l_down) rollSpeed -= rollAccel * dt;
       if (r_down) rollSpeed += rollAccel * dt;
       if (u_down) pitchSpeed += pitchAccel * dt;
       if (d_down) pitchSpeed -= pitchAccel * dt;
     }
     
     pitchSpeed *= 1 - (decel * dt);
     rollSpeed *= 1 - (decel * dt);
     yawSpeed *= 1 - (decel * dt);
     
     pitchSpeed = min (pitchSpeed, maxPitch);
     yawSpeed = min (yawSpeed, maxYaw);
     rollSpeed = min (rollSpeed, maxYaw);
     
     pitch += pitchSpeed;
     roll += rollSpeed;
     yaw += yawSpeed;

     //if (pitch > PI / 2.0) {
     //  pitch -= PI;
     //  up.mul(-1);
     //} else if (pitch < -PI / 2.0) {
     //  pitch += PI;
     //  up.mul(-1);
     //}
     
     speed = min(speed, maxSpeed);
     
     
     PMatrix pitchMat = new PMatrix3D();
     PMatrix rollMat = new PMatrix3D();
     PMatrix yawMat = new PMatrix3D();
     
     pitchMat.rotate(oldpitch - pitch, right.x, right.y, right.z); 
     rollMat.rotate(oldroll - roll, forward.x, forward.y, forward.z);
     yawMat.rotate(oldyaw - yaw, up.x, up.y, up.z);
     
     PMatrix mat = new PMatrix3D();
     mat.apply(pitchMat);
     mat.apply(rollMat);
     mat.apply(yawMat);
     
     forward = forward.matMult(mat).normalized();
     right = right.matMult(mat).normalized();
     up = up.matMult(mat).normalized();
      
     position.add(forward.times(speed));
     
     // Avoid obstacles AND check for collision
     for (int i = 0; i < obstacles.size(); i++) {
       Obstacle o = obstacles.get(i);
       float distToObstacle = o.position.minus(this.position).length() - o.radius;
       if (distToObstacle < 3) {
         kill();
         break;
       }
     }
     
     // Update emitters
     bulletEmitter.setPosition(position);
     bulletEmitter.setDirection(forward);
     explosionEmitter.setPosition(position);
     if (alive) {
       if (spacedown) {
         bulletEmitter.start();
       } else {
         bulletEmitter.pause();
       }
     } else {
       explosionEmitter.start();
       if (explosionEmitter.isFinished()) {
         explosionEmitter.pause();
         revive();
         spawn();
       }
     }
   }
   
   void spawn() {
     this.forward = new Vec3(-1,0,0);
     this.position = new Vec3(1000,0,0);
   }
   
   void revive() {
     init();
   }
   
   void kill() {
     this.speed = 0;
     this.yaw = 0;
     this.pitch = 0;
     this.roll = 0;
     this.alive = false;
     this.bulletEmitter.pause();
   }
   
   void render() {
     if (alive && gameMode) {
     // Make sure these are normalized!!
     PMatrix mat = new PMatrix3D();
     mat.set(forward.x, up.x, right.x, position.x,
             forward.y, up.y, right.y, position.y,  
             forward.z, up.z, right.z, position.z,
             0,         0,    0,       1);
     pushMatrix();
     //translate(0,0,0);
     //System.out.println(position.toString());
     //translate(position.x, position.y, position.z);
     //rotateZ(pitch);
     applyMatrix(mat);
     shape(model);
     popMatrix();
     }
     bulletEmitter.run(dt);
     explosionEmitter.run(dt);
   }
   
   void handleKeyPressed() {
    if ( key == 'w' || key == 'W' ) wdown = true;
    if ( key == 'd' || key == 'D' ) ddown = true;
    if ( key == 'a' || key == 'A' ) adown = true;
    if ( key == 's' || key == 'S' ) sdown = true;
    
    if ( keyCode == LEFT  ) l_down = true;
    if ( keyCode == RIGHT ) r_down = true;
    if ( keyCode == UP    ) u_down = true;
    if ( keyCode == DOWN  ) d_down = true;
    
    if ( key == ' ' ) spacedown = true;
   }
   
   void handleKeyReleased() {
    if ( key == 'w' || key == 'W' ) wdown = false;
    if ( key == 'd' || key == 'D' ) ddown = false;
    if ( key == 'a' || key == 'A' ) adown = false;
    if ( key == 's' || key == 'S' ) sdown = false;
    
    if ( keyCode == LEFT  ) l_down = false;
    if ( keyCode == RIGHT ) r_down = false;
    if ( keyCode == UP    ) u_down = false;
    if ( keyCode == DOWN  ) d_down = false;
    
    if ( key == ' ' ) spacedown = false; 
   }
   
}
