class Obstacle {
  PShape model; //<>// //<>// //<>// //<>//
  PImage texture;
  float radius;
  color emissive;
  Vec3 position;
  
  float rot;
  
  float orbitTilt;
  float orbitDistance;
  float orbitAngle;
  
  float orbitSpeed;
  float spinSpeed;
  
  // these values are used to normalize the objects position and size to a r=1 at 0,0,0 
  Vec3 offset;
  float scale;
  
  Obstacle(String objPath) {
    this.model = loadShape(objPath);
    this.rot = 0;
    this.emissive = color(0,0,0);
    this.orbitTilt = 0;
    this.orbitDistance = 0;
    this.orbitAngle = 0;
    this.position = new Vec3();
    this.spinSpeed = PI / 240;
    this.orbitSpeed = PI / 500;
  }
  
  void setTexture(String texPath) {
    texture = loadImage(texPath);
    this.model.setTexture(texture);
  }
  
  void setRadius(float r) {
    this.radius = r; 
  }
  
  void setOffset(Vec3 offset) {
    this.offset = offset;
  }
  
  void setScale(float scale) {
    this.scale = scale;
  }
  
  void setEmissive(color c) {
    this.emissive = c;
  }
  
  void setOrbitTilt(float o) {
    this.orbitTilt = o;
  }
  
  void setOrbitDistance(float o) {
    this.orbitDistance = o;
  }
  
  void setSpin(float o) {
    this.spinSpeed = o;
  }
  
  void setOrbit(float o) {
    this.orbitSpeed = o;
  }
  
  void update() {
    rot += spinSpeed;
    orbitAngle += orbitSpeed;
    PVector pos = new PVector(0, 0, 0);
    PVector newpos = new PVector();
    PMatrix mat = new PMatrix3D();
    mat.rotateZ(orbitTilt);
    mat.rotateY(orbitAngle);
        mat.translate(orbitDistance, 0, 0);

    mat.mult(pos, newpos);
    this.position.x = newpos.x;
    this.position.y = newpos.y;
    this.position.z = newpos.z;
  }
  
  void render() {    
    pushMatrix();
    translate(position.x, position.y, position.z);
    scale(radius);
    rotateY(rot);
    scale(scale);
    translate(offset.x, offset.y, offset.z);
    shape(model);
    popMatrix();
    noTint();
  }
}
