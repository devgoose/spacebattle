class ExplosionFactory extends ParticleFactory {
  float explosionRadius = 0.3;
 ExplosionFactory() {
   super();
 }
 
   Particle generate(float particleLifetime, color c, Vec3 position, Vec3 direction) {
    return new ExplosionParticle(
                        particleLifetime, 
                        initialPosition(position),
                        initialVelocity(),
                        c);
  }
  
  String type() {
    return "ExplosionFactory";
  }
  
  Vec3 initialPosition(Vec3 position) {
   return new Vec3(position);
  }
 
    
  // Gens an initial velocity for a new particle
  // No direction for explosions
  Vec3 initialVelocity() {
    // random wobble
    Vec3 random = new Vec3(random(-1, 1), random(-1, 1), random(-1, 1));
    random.setToLength(sqrt(random(0, 1)) * explosionRadius); // random speed between 5 and 7
    return random;
  }
}
