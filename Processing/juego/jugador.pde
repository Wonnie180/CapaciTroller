class Jugador {
  float playerX = 100;
  float playerY = 100;
  float playerVelocityY = 0;
  float playerVelocityX = 0;
  float playerJumpSpeed = -5;
  float playerSize = 10;
  boolean onGround = true;
  float velBaja = 1;
  float velMedia = 3;
  float velNormal = 5;
  float velocidad = 0;


  Jugador(int x_inicial, int y_inicial, int tam) {
    playerX = x_inicial;
    playerY = y_inicial;
    playerSize = tam;
  }

  void dibujar() {
    update();
    rect(personaje.getPlayerX(), personaje.getPlayerY(), personaje.getPlayerSize(), personaje.getPlayerSize());
  }

  void update() {
    playerX += playerVelocityX;
    playerY += playerVelocityY;
  }

  void saltar() {
    if (this.onGround) {
      this.playerVelocityY = this.playerJumpSpeed;
    }
  }

  void setOnGround(boolean onGround) {
    this.onGround = onGround;
  }

  void setPlayerX(float x) {
    this.playerX = x;
  }
  void setPlayerY(float y) {
    this.playerY = y;
  }

  void setPlayerVelocityX(float vel) {
    this.playerVelocityX = vel;
  }

  void setPlayerVelocityY(float vel) {
    this.playerVelocityY = vel;
  }

  float getPlayerVelocityX() {
    return this.playerVelocityX;
  }

  float getPlayerVelocityY() {
    return this.playerVelocityY;
  }

  float getPlayerX() {
    return this.playerX;
  }

  float getPlayerY() {
    return this.playerY;
  }

  float getPlayerSize() {
    return this.playerSize;
  }

  void velocidadBaja() {
    this.velocidad = velBaja;
  }

  void velocidadMedia() {
    this.velocidad = velMedia;
  }

  void velocidadNormal() {
    this.velocidad = velNormal;
  }

  void moverDer() {    
    this.playerVelocityX = 1 * this.velocidad;
  }

  void moverIzq() {
    this.playerVelocityX = -1 * this.velocidad;
  }

  void moverArriba() {
    saltar();
  }

  void moverAbajo() {
    //
  }
}
