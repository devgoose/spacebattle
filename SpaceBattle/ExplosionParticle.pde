class ExplosionParticle extends Particle {
  color white = color(255, 255, 255, 255);
  color middle = color(252, 135, 0);
  color gone = color(0, 0,0);
  float decelerate = 1;
 
 ExplosionParticle(float maxLife, Vec3 position, Vec3 velocity, color c) {
   super(maxLife, position, velocity, c);
 }
 
  void update(Vec3 acceleration, float dt) {
    if (paused) { return; }
  lifetime += dt;
  velocity.add(acceleration.times(dt));
  // Explosion velocity should decelerate
  float l = velocity.length();
  velocity.setToLength((l - (dt * l * decelerate)));
  velocity.add(wander());
  position.add(velocity);
 }
 
 Vec3 wander() {
  Vec3 wander = new Vec3();
  wander.rand();
  wander.setToLength(0.01);
  return wander;
 }
 
 
 void render() {
   noStroke();
   float ratio = (lifetime/maxLife);
   if (ratio > 1) { ratio = 1; }
   float first = 0.3;
   float second = 0.7;
   color cur; 
   
   if (ratio < first) {
    cur = lerpColor(white, c, ratio * (1.0 / first)); 
   }
   else if (ratio < second) {
     cur = lerpColor(c, middle, (ratio - first) * (1.0/(second - first))); 
   }
   else {
     cur = lerpColor(middle, gone, (ratio - second) * (1 / (1-second)));
   }
   //quadratically fade
   fill(lerpColor(cur, color(0,0,0,0), ratio));
   fill(cur);
   
   pushMatrix();
   translate(position.x, position.y, position.z);
   sphere(7);
   popMatrix();
 }
 
 
}
