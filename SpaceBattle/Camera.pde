// Created for CSCI 5611 by Liam Tyler

class Camera
{
  Camera(float x, float y, float z)
  {
    position      = new PVector( x, y, z ); // initial position
    theta         = 0; // rotation around Y axis. Starts with forward direction as ( 0, 0, -1 )
    phi           = 0; // rotation around X axis. Starts with up direction as ( 0, 1, 0 )
    moveSpeed     = 200;
    turnSpeed     = 1.57; // radians/sec
    
    // dont need to change these
    negativeMovement = new PVector( 0, 0, 0 );
    positiveMovement = new PVector( 0, 0, 0 );
    negativeTurn     = new PVector( 0, 0 ); // .x for theta, .y for phi
    positiveTurn     = new PVector( 0, 0 );
    fovy             = PI / 4;
    aspectRatio      = width / (float) height;
    nearPlane        = 0.1;
    farPlane         = 20000;
    
    
    curBoid = 0;
    boids = new ArrayList();
    decel          = 5;
    
    wdown = false;
    adown = false;
    sdown = false;
    ddown = false;
  }
  
  void setBoids(Boid[] bs) {
    for (int i = 0; i < bs.length; i++) {
      this.boids.add(bs[i]);
    }
  }
  
  void Update(float dt)
  {
    if (defaultMode) {
      if ( wdown ) positiveMovement.z = 1; 
      if ( sdown ) negativeMovement.z = -1;
      if ( adown ) negativeMovement.x = -1;
      if ( ddown ) positiveMovement.x = 1;
      if ( qdown ) positiveMovement.y = 1;
      if ( edown ) negativeMovement.y = -1;
      
      if ( l_down )  negativeTurn.x = 1;
      if ( r_down ) positiveTurn.x = -0.5;
      if ( u_down )    positiveTurn.y = 0.5;
      if ( d_down )  negativeTurn.y = -1;
      
      negativeMovement.mult(1 - (decel * dt));
      positiveMovement.mult(1 - (decel * dt));
      negativeTurn.mult(1 - (decel * dt));
      positiveTurn.mult(1 - (decel * dt));
    } 
    
    PVector forwardDir;
    PVector upDir;
    
    if (defaultMode) {
      theta += turnSpeed * ( negativeTurn.x + positiveTurn.x)*dt;
      
      // cap the rotation about the X axis to be less than 90 degrees to avoid gimble lock
      float maxAngleInRadians = 85 * PI / 180;
      phi = min( maxAngleInRadians, max( -maxAngleInRadians, phi + turnSpeed * ( negativeTurn.y + positiveTurn.y ) * dt ) );
      
      // re-orienting the angles to match the wikipedia formulas: https://en.wikipedia.org/wiki/Spherical_coordinate_system
      // except that their theta and phi are named opposite
      float t = theta + PI / 2;
      float p = phi + PI / 2;
      forwardDir = new PVector( sin( p ) * cos( t ),   cos( p ),   -sin( p ) * sin ( t ) );
      upDir      = new PVector( sin( phi ) * cos( t ), cos( phi ), -sin( t ) * sin( phi ) );
      PVector rightDir   = new PVector( cos( theta ), 0, -sin( theta ) );
      PVector velocity   = new PVector( negativeMovement.x + positiveMovement.x, negativeMovement.y + positiveMovement.y, negativeMovement.z + positiveMovement.z );
     
      position.add( PVector.mult( forwardDir, moveSpeed * velocity.z * dt ) );
      position.add( PVector.mult( upDir,      moveSpeed * velocity.y * dt ) );
      position.add( PVector.mult( rightDir,   moveSpeed * velocity.x * dt ) );
    } else if (gameMode) {
      position.x = player.position.x;
      position.y = player.position.y;
      position.z = player.position.z;
      
      forwardDir = new PVector();
      forwardDir.x = player.forward.x;
      forwardDir.y = player.forward.y;
      forwardDir.z = player.forward.z;
      
      PVector offset = new PVector();
      offset.x = player.forward.x;
      offset.y = player.forward.y;
      offset.z = player.forward.z;
      offset.normalize();
      
      upDir = new PVector();
      upDir.x = player.up.x;
      upDir.y = player.up.y;
      upDir.z = player.up.z;
      upDir.normalize();
      
      position.add(new PVector(offset.x * 0, offset.y * 0, offset.z * 0)); // More offset when speed up
      position.add(new PVector(offset.x * -100, offset.y * -100, offset.z * -100)); // Default camera posiion;
      position.add(new PVector(upDir.x * -20, upDir.y * -20, upDir.z * -20));
    } else { // boid mode
      Boid boid = boids.get(curBoid);
      boid.select();
      position.x = boid.position.x;
      position.y = boid.position.y;
      position.z = boid.position.z;
      
      forwardDir = new PVector();
      forwardDir.x = boid.velocity.x;
      forwardDir.y = boid.velocity.y;
      forwardDir.z = boid.velocity.z;
      
      PVector offset = new PVector();
      offset.x = boid.velocity.x;
      offset.y = boid.velocity.y;
      offset.z = boid.velocity.z;
      
      upDir = new PVector();
      upDir.y = 1;
      
      position.add(offset.mult(-15).add(offset.normalize().mult(30)));
      position.add(new PVector(0, -15, 0));
    }
    aspectRatio = width / (float) height;
    perspective( fovy, aspectRatio, nearPlane, farPlane );
    camera( position.x, position.y, position.z,
            position.x + forwardDir.x, position.y + forwardDir.y, position.z + forwardDir.z,
            upDir.x, upDir.y, upDir.z );
            
    if (position.mag() > skybox.r) {
      position.normalize();
      position.mult(skybox.r-0.1);
    }
  }
  
  // only need to change if you want difrent keys for the controls
  void HandleKeyPressed()
  {
    if ( key == 'w' || key == 'W' ) wdown = true;
    if ( key == 's' || key == 'S' ) sdown = true;
    if ( key == 'a' || key == 'A' ) adown = true;
    if ( key == 'd' || key == 'D' ) ddown = true;
    if ( key == 'q' || key == 'Q' ) qdown = true;
    if ( key == 'e' || key == 'E' ) edown = true;
    
    if ( keyCode == LEFT )  l_down = true;
    if ( keyCode == RIGHT ) r_down = true;
    if ( keyCode == UP )    u_down = true;
    if ( keyCode == DOWN )  d_down = true;
    
    if ( keyCode == LEFT ) {
      boids.get(curBoid).deselect();
      curBoid--;
      if (curBoid < 0) {
        curBoid = boids.size() - 1;
      }
    }
    if ( keyCode == RIGHT ) {
      boids.get(curBoid).deselect();
      curBoid++;
      if (curBoid >= boids.size()) {
        curBoid = 0;
      }
    }
  }
  
  // only need to change if you want difrent keys for the controls
  void HandleKeyReleased()
  {
    if ( key == 'w' || key == 'W' ) wdown = false;
    if ( key == 'q' || key == 'Q' ) qdown = false;
    if ( key == 'd' || key == 'D' ) ddown = false;
    if ( key == 'a' || key == 'A' ) adown = false;
    if ( key == 's' || key == 'S' ) sdown = false;
    if ( key == 'e' || key == 'E' ) edown = false;
    
    if ( keyCode == LEFT  ) l_down = false;
    if ( keyCode == RIGHT ) r_down = false;
    if ( keyCode == UP    ) u_down = false;
    if ( keyCode == DOWN  ) d_down = false;
  }
  
  // only necessary to change if you want different start position, orientation, or speeds
  PVector position;
  float theta;
  float phi;
  float moveSpeed;
  float turnSpeed;
  float decel;
 
  int curBoid;
  ArrayList<Boid> boids;
  
  // probably don't need / want to change any of the below variables
  float fovy;
  float aspectRatio;
  float nearPlane;
  float farPlane;  
  PVector negativeMovement;
  PVector positiveMovement;
  PVector negativeTurn;
  PVector positiveTurn;
  
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
};
