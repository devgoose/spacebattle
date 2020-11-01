class Skybox {
 
  PShape model;
  PImage texture;
  float r;
  Vec3 position;
  
  float rot;
  Skybox(float r) {
    texture = loadImage("space.jpg");
    this.r = r;
    model = loadShape("purpleplanet/planet2.obj");
    model.setTexture(texture);
    this.rot = 0;
    position = new Vec3(0,0,0);
  }
  
  void update(float dt) {
    if (gameMode) {
      this.position = player.position;
    }
    else {
      this.position.x = camera.position.x;
      this.position.y = camera.position.y;
      this.position.z = camera.position.z;
    }
    float distToSun = position.length() + 2000; // accounting for some extra space here
    if (distToSun > r) {
      this.r = distToSun;
    }
    rot += PI / 100 * dt; 
  }
  
  
  
  void render() {
    pushMatrix();
    translate(position.x,position.y,position.z);
    scale(r);
    rotateY(rot);
    scale(0.01);
    translate(1, -90, 5);
    shape(model);
    popMatrix();
  }
}
