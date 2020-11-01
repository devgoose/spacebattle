class BulletParticle extends Particle {
 
 BulletParticle(float maxLife, Vec3 position, Vec3 velocity, color c) {
   super(maxLife, position, velocity, c);
 }
 
  void update(Vec3 acceleration, float dt) {
    if (paused) { return; }
  lifetime += dt;
  velocity.add(acceleration.times(dt));
  position.add(velocity);
 }
 
 
 void render() {
   sphereDetail(1);
   pushMatrix();
   stroke(c);
   fill(c, (maxLife-lifetime/maxLife) * 255);
   translate(position.x, position.y, position.z);
   sphere(0.5);
   popMatrix();
 }
 
 
}
