class Mapa {
  String rutaImagenColisiones;
  String rutaImagenGraficos;
  PImage collisionImage;
  PImage displayImage;
  float gravity;
  Jugador jugador;
  color pixelColor_Izq = color(0, 0, 0);
  color pixelColor_Der = color(0, 0, 0);


  // constructor
  Mapa(String rutaImagenColisiones, String rutaImagenGraficos, Jugador jugador, float gravity) {
    this.gravity = gravity;
    this.rutaImagenColisiones = rutaImagenColisiones;
    this.rutaImagenGraficos = rutaImagenGraficos;
    this.collisionImage = requestImage(rutaImagenColisiones);
    this.displayImage = requestImage(rutaImagenGraficos);
    collisionImage.loadPixels();
    displayImage.loadPixels();
    this.jugador = jugador;
  }

  color getColoresIzq() {
    return this.pixelColor_Izq;
  }

  color getColoresDer() {
    return this.pixelColor_Der;
  } 

  void getColorPredominante() {
    //Necesario ya que no siempre carga los pixeles al principio
    if (displayImage.pixels.length < 1)
      return;

    int playerX = (int) this.jugador.getPlayerX();
    int playerY = (int) this.jugador.getPlayerY(); 
    int playerSize = (int) this.jugador.getPlayerSize();

    if (playerX > displayImage.width || playerX < 0 || playerY > displayImage.height || playerY < 0)
      return;

    displayImage.loadPixels();

    int pixelIzq = playerY*displayImage.width+playerX-1;
    if (pixelIzq < 0) {
      pixelIzq = 0;
    } else if (pixelIzq > displayImage.width*displayImage.height) {
      pixelIzq = displayImage.width*displayImage.height;
    }

    this.pixelColor_Izq = displayImage.pixels[pixelIzq];

    int pixelDer = playerY*displayImage.width+playerX+playerSize+2;

    if (pixelDer < 0) {
      pixelDer = 0;
    } else if (pixelDer > displayImage.width*displayImage.height) {
      pixelDer = displayImage.width*displayImage.height - 1;
    }
    this.pixelColor_Der = displayImage.pixels[pixelDer];
  }

  void comprobarColisiones() {
    float playerVelocityX = this.jugador.getPlayerVelocityX();
    float playerVelocityY = this.jugador.getPlayerVelocityY() + gravity;
    float playerX = this.jugador.getPlayerX();
    float playerY = this.jugador.getPlayerY();

    float nextY = playerY + playerVelocityY;
    float nextX = playerX + playerVelocityX;

    boolean tempOnGround = false;

    if (collisionImage.width > 0)
    {
      image(collisionImage, 0, 0, width, height);
      if (displayImage.width > 0)
      {
        image(displayImage, 0, 0, width, height);
      }
      for (int y = 0; y < collisionImage.height; y += 1) 
      {
        for (int x = 0; x < collisionImage.width; x += 1)
        { 
          color pixelColor = collisionImage.pixels[y*collisionImage.width+x];
          float scaleDiff = width / collisionImage.width; // 500 / 50 = 10
          float px = nextX;
          float py = playerY;
          float platformX = x * (int)scaleDiff;
          float platformY = y * (int)scaleDiff;
          float tileSize = 10;
          float playerSize = this.jugador.getPlayerSize();
          if (isRectOverlapping(platformX, platformY, platformX + tileSize, platformY + tileSize, px, py, px + playerSize, py + playerSize) == true && red(pixelColor) == 0)
          {
            // moving left and character is currently on the right side of the wall
            if (playerVelocityX < 0 && playerX >= platformX + tileSize)
            {
              playerVelocityX = 0;
            }
            // moving right and character is currently on the left side of the wall
            if (playerVelocityX > 0 && playerX < platformX)
            {
              playerVelocityX = 0;
            }
          }

          px = playerX;
          py = nextY;
          if (isRectOverlapping(platformX, platformY, platformX + tileSize, platformY + tileSize, px, py, px + playerSize, py + playerSize) && red(pixelColor) == 0)
          {
            fill(255, 0, 0);

            // moving up and character is currently on the bottom side of the wall
            // commented out to jump up through platforms
            /*if (playerVelocityY < 0  && playerY >= platformY)
             {
             playerVelocityY = 0;
             }*/
            // moving down and character is currently on the top side of the wall
            if (playerVelocityY > 0 && playerY < platformY)
            {
              playerVelocityY = 0;
              tempOnGround = true;
            }
          }
        }
      }
    }
    jugador.setPlayerVelocityX(playerVelocityX);
    jugador.setPlayerVelocityY(playerVelocityY);
    jugador.setOnGround(tempOnGround);
  }

  boolean isRectOverlapping(float left, float top, float right, float bottom, 
    float otherLeft, float otherTop, float otherRight, float otherBottom) {
    return !(left > otherRight || right < otherLeft || top > otherBottom || bottom < otherTop);
  }
}
