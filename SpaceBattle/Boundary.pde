// Singleton Class to hold a boundary for the boids to be held in 

class Boundary {
 Vec3 center;
 float radius;
 
 Boundary(float x, float y, float z, float r) {
   this.center = new Vec3(x,y,z);
   this.radius = r;
 }
 
 float distance(Vec3 pos) {
   return pos.length() - radius;
 }
 
 // Randomly generates (probably not equally distributed) a vector
 // Sets it to a length somewhere in the sphere
 Vec3 randomInside() {
   Vec3 randomDir = new Vec3(random(1), random(1), random(1));
   randomDir.setToLength(random(0, radius));
   return randomDir;
 }
 void render() {
   fill(0, 255, 0, 0.75);
   pushMatrix();
   translate(0, 0, 0);
   sphereDetail(20);
   sphere(radius);
   popMatrix();
 }
}
