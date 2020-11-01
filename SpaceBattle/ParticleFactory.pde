class ParticleFactory {
  ParticleFactory() {
  }
  
  
  Particle generate(float particleLifetime, color c, Vec3 position, Vec3 direction) {
    return new Particle(
                        particleLifetime, 
                        initialPosition(position),
                        initialVelocity(direction),
                        c);
  }
  
  
  // FUNCTIONS TO IMPLEMENT WHEN EXTENDING PARTICLEFACTORY
  
  String type() {
    return "ParticleFactory";
  }
  // Generates initial position for a new particle
  
  Vec3 initialPosition(Vec3 position) {
   Vec3 random = new Vec3(random(0.1), random(0.1), random(0.1));
   return position.plus(random); // Offset from the emitter's position
  }
 
    
  // Gens an initial velocity for a new particle
  Vec3 initialVelocity(Vec3 direction) {
    // random direction going signifigantly up
    Vec3 random = new Vec3(0.5 - random(1),
                           random(-5, -1),
                           0.5 - random(1));
    return direction.plus(random);
  }
  

}
