
public class Vec3 {
  public float x, y, z;
  
  public Vec3() {
    this.x = 0;
    this.y = 0;
    this.z = 0;
  }
  public Vec3(float x, float y, float z){
    this.x = x;
    this.y = y;
    this.z = z;
  }
  
  public Vec3(Vec3 v) {
    this.x = v.x;
    this.y = v.y;
    this.z = v.z;
  }
  
  public void rand() {
    this.x = random(-0.1, 0.1);
    this.y = random(-0.1, 0.1);
    this.z = random(-0.1, 0.1);
  }
  
  public String toString(){
    return "(" + x + "," + y + "," + z + ")";
  }
  
  public float length(){
    return sqrt(x*x+y*y+z*z);
  }
  
  public float lengthSqr(){
    return x*x+y*y+z*z;
  }
  
  public Vec3 plus(Vec3 rhs){
    return new Vec3(x+rhs.x,y+rhs.y,z+rhs.z);
  }
  
  public void add(Vec3 rhs){
    x += rhs.x;
    y += rhs.y;
    z += rhs.z;
  }
  
  public Vec3 minus(Vec3 rhs){
    return new Vec3(x-rhs.x,y-rhs.y,z-rhs.z);
  }
  
  public void subtract(Vec3 rhs){
    x -= rhs.x;
    y -= rhs.y;
    z -= rhs.z;
  }
  
  public Vec3 times(float rhs){
    return new Vec3(x*rhs,y*rhs,z*rhs);
  }
  
  public void mul(float rhs){
    x *= rhs;
    y *= rhs;
    z *= rhs;
  }
  
  public void normalize(){
    float l = this.length();
    x /= l;
    y /= l;
    z /= l;
  }
  
  public Vec3 normalized(){
    float l = this.length();
    return new Vec3(x/l,y/l,z/l);
  }
  
  //If the vector is longer than maxL, shrink it to be maxL otherwise do nothing
  public void clampToLength(float maxL){
    float l = this.length();
    if (l > maxL) {
      x = x / l * maxL;
      y = y / l * maxL;
      z = z / l * maxL;
    }
  }
  
  //Grow or shrink the vector have a length of maxL
  public void setToLength(float newL){
    float l = this.length();
    x = x / l * newL;
    y = y / l * newL;
    z = z / l * newL;
  }
  
  public float distanceTo(Vec3 rhs){
    return sqrt((x-rhs.x)*(x-rhs.x) +
                (y-rhs.y)*(y-rhs.y) +
                (z-rhs.z)*(z-rhs.z));
  }
  
  public Vec3 matMult(PMatrix mat) {
    PVector copy = new PVector(x, y, z);
    PVector result = new PVector();
    mat.mult(copy, result);
    return new Vec3(result.x, result.y, result.z);
  }
}

Vec3 interpolate(Vec3 a, Vec3 b, float t){
  return new Vec3(interpolate(a.x, b.x, t),
                  interpolate(a.y, b.y, t),
                  interpolate(a.z, b.z, t)); 
}

float dot(Vec3 a, Vec3 b){
  return  a.x*b.x +
          a.y*b.y +
          a.z*b.z;
}

Vec3 cross(Vec3 a, Vec3 b){
  return new Vec3((a.y*b.z-a.z*b.y),
                  (a.z*b.x-a.x*b.z),
                  (a.x*b.y-a.y*b.x));
}




Vec3 projAB(Vec3 a, Vec3 b){
  return b.times(dot(a, b)/b.lengthSqr());
}
