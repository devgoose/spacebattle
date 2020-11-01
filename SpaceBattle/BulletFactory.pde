class BulletFactory extends ParticleFactory {
 BulletFactory() {
   super();
 }
 
   Particle generate(float particleLifetime, color c, Vec3 position, Vec3 direction) {
    return new BulletParticle(
                        particleLifetime, 
                        initialPosition(position),
                        initialVelocity(direction),
                        c);
  }
  
  String type() {
    return "BulletFactory";
  }
  
  Vec3 initialPosition(Vec3 position) {
   return new Vec3(position);
  }
 
    
  // Gens an initial velocity for a new particle
  /// Direction should be normalized
  Vec3 initialVelocity(Vec3 direction) {
    // random wobble
    Vec3 wobble = new Vec3(random(-0.02, 0.02), random(-0.02, 0.02), random(-0.02, 0.02));
    wobble.add(direction);
    wobble.setToLength((random(50, 60))); // random speed between 5 and 7
    return wobble;
  }
}
