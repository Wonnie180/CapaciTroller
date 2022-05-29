
class Lluvia {
  Drop[] drops;
  float velocidad_lluvia = 1;

  Lluvia(int numDrops) {
    drops = new Drop[numDrops];
    for (int i = 0; i < drops.length; i++) {
      drops[i] = new Drop(0, width);
    }
  }

  public void setAccelLluvia(float accel) {
    this.velocidad_lluvia += accel;
    if (this.velocidad_lluvia < 0.5)
      this.velocidad_lluvia = 0.5;
    else if (this.velocidad_lluvia > 1.5)
      this.velocidad_lluvia = 1.5;
  }

  public void setVelocidadLluvia(float velocidad_lluvia) {
    this.velocidad_lluvia = velocidad_lluvia;
  }

  public void dibujarLluvia() {
    for (int i = 0; i < drops.length; i++) {
      drops[i].fall(velocidad_lluvia); // sets the shape and speed of drop
      drops[i].show(); // render drop
    }
  }
}
