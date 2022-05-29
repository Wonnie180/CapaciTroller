import processing.serial.*;

class Mando {
  int botones = 0;
  Jugador jugador;
  Lluvia lluvia;
  Serial puerto = null;
  String mensaje;
  boolean[] botones_pulsados = {false, false, false, false, false, false, false, false, false, false, false, false};
  boolean[] capacitivos = {false, false};
  boolean[] slider = {false, false, false, false};
  color ultimoColorIzq = color(0, 0, 0);
  color ultimoColorDer = color(0, 0, 0);
  byte bytes_RGB[] = {0, 0, 0, 0, 0, 0};
  int slider_valor = 0;

  Mando(Jugador jugador, Lluvia lluvia) {
    this.jugador = jugador;
    this.lluvia = lluvia;
  }

  void setPort(Serial port) {
    puerto = port;
  }

  void update() {
    getMensaje();    

    realizarAccionesMando();
  }

  void realizarAccionesMando() {
    realizarAccionesSlider();
    realizarAccionesBotones();
  }


  boolean esDistintoColor(color antiguo, color nuevo) {
    boolean esDistinto = false;

    if (red(antiguo) != red(nuevo)) {
      esDistinto = true;
    } else if (green(antiguo) != green(nuevo)) {
      esDistinto = true;
    } else if (blue(antiguo) != blue(nuevo)) {
      esDistinto = true;
    }
    return esDistinto;
  }

  byte[] valoresRGB(color RGB) {
    byte colores[] = {(byte) red(RGB), (byte)green(RGB), (byte)blue(RGB)};
    return colores;
  }

  void setLedsRGB(color LedsIzq, color LedsDer) {
    if (puerto == null || (capacitivos[0] == false && capacitivos[1] == false))
      return;

    boolean hayCambios = false;  

    if (esDistintoColor(ultimoColorIzq, LedsIzq)) {
      ultimoColorIzq = LedsIzq;
      bytes_RGB[0] = (byte) red(ultimoColorIzq);
      bytes_RGB[1] = (byte) green(ultimoColorIzq);
      bytes_RGB[2] = (byte) blue(ultimoColorIzq);
      hayCambios = true;
    }

    if (esDistintoColor(ultimoColorDer, LedsDer)) {    
      ultimoColorDer = LedsDer;
      bytes_RGB[3] = (byte) red(ultimoColorDer);
      bytes_RGB[4] = (byte) green(ultimoColorDer);
      bytes_RGB[5] = (byte) blue(ultimoColorDer);
      hayCambios = true;
    } 

    if (hayCambios) {
      puerto.write(bytes_RGB);
    }
  }

  void getMensaje() {
    if (puerto != null && puerto.available() > 0) {
      mensaje = puerto.readStringUntil('\n');
      if (mensaje == null)
        return;
      mensaje = mensaje.trim();
      botones = Integer.parseInt(mensaje);
      println(botones);
      updateBotonesPulsados();
    }
  }

  void updateBotonesPulsados() {
    int aux = 1;
    for (int i = 0; i < 12; i++) {
      botones_pulsados[i] = (botones & aux) == aux;
      aux = aux << 1;
    }
    for (int i = 0; i < 2; i++) {
      capacitivos[i] = (botones & aux) == aux;
      print(aux+":"+capacitivos[i] + " ");
      aux = aux << 1;
    }
    println();
  }

  void copiarValoresSlider() {
    for (int i = 0; i < 4; i++) {
      this.slider[i] = this.botones_pulsados[i+2];
    }
  }
  void realizarAccionesSlider() {
    // slider -> 2 al 5
    // Dirección -> (aumentar velocidad)
    if (slider_valor == 0 && ((slider[3] && botones_pulsados[4]) || (slider[2] && botones_pulsados[3]))) {
      slider_valor+=1;
    } else if (slider_valor > 0 && ((slider[2] && botones_pulsados[3]) || (slider[1] && botones_pulsados[2]))) {
      slider_valor+=1;
      // Dirección <- (disminuir velocidad)
    } else if (slider_valor == 0 && ((slider[0] && botones_pulsados[3]) || (slider[1] && botones_pulsados[4]))) {
      slider_valor-=1;
    } else if (slider_valor < 0 && ((slider[1] && botones_pulsados[4]) || (slider[2] && botones_pulsados[5]))) {
      slider_valor-=1;
    } 

    if (slider_valor > 1 && botones_pulsados[2]) {
      this.lluvia.setAccelLluvia(+0.1);
      slider_valor = 0;
    } else if (slider_valor < -1  && botones_pulsados[5]) {
      this.lluvia.setAccelLluvia(-0.1);
      slider_valor = 0;
    }

    copiarValoresSlider();

    //// Dirección <- (disminuir velocidad)
    //if ((botones_pulsados[5] || botones_pulsados[4])  && slider[0]) {
    //  this.lluvia.setAccelLluvia(-0.1);
    //  for (int i = 0; i < 4; i++) {
    //    this.slider[i] = false;
    //  }
    //} else if (botones_pulsados[2] && (slider[3] || slider[2])) {
    //  this.lluvia.setAccelLluvia(+0.1);
    //  for (int i = 0; i < 4; i++) {
    //    this.slider[i] = false;
    //  }
    //} else {
    //copiarValoresSlider()    
    //}
  }

  void realizarAccionesBotones() {
    if (botones_pulsados[0]) {
      jugador.saltar();
    }

    // Reinicio de la velocidad
    jugador.setPlayerVelocityX(0);
    jugador.velocidadNormal();

    // Circulo interior
    if (botones_pulsados[8]) {
      jugador.velocidadBaja();
    }

    // Circulo exterior
    if (botones_pulsados[7]) {
      jugador.velocidadMedia();
    }

    if (botones_pulsados[6]) {
      jugador.moverDer();
    }

    if (botones_pulsados[10]) {
      jugador.moverIzq();
    }

    if (botones_pulsados[9]) {
      jugador.moverArriba();
    }

    if (botones_pulsados[11]) {
      jugador.moverAbajo();
    }
  }
}
