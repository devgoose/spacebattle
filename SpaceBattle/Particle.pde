class Particle {
 float lifetime;
 float maxLife;
 Vec3 position;
 Vec3 velocity;
 color c;
 
 Particle(float maxLife, Vec3 position, Vec3 velocity, color c) {
   this.lifetime = 0;
   this.maxLife = maxLife;
   this.position = position;
   this.velocity = velocity;
   this.c = c;
 }

 
 boolean isExpired() {
   return lifetime > maxLife;
 }
 
 // FUNCTINOS TO IMPLEMENT WHEN EXTENDING
 
 void update(Vec3 acceleration, float dt) {
  lifetime += dt;
  velocity.add(acceleration.times(dt));
  position.add(velocity);
 }
 
 void render() {
   // Just render a sphere for now
   pushMatrix();
   translate(position.x, position.y, position.z);
   fill(c);
   sphere(5);
   popMatrix();
 }
 
 
  
}
