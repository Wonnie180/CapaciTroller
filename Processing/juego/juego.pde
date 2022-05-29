
/*

 Creditos a:
 Purple Rain (https://github.com/CodingTrain/website/tree/main/CodingChallenges/CC_004_PurpleRain/Processing)
 Simple Platformer Example (https://openprocessing.org/sketch/119522)
 
 
 */

Jugador personaje;
Lluvia lluvia;
Mando mando;
Mapa mapa;
float gravity = .1;


void setup() {
  size(500, 500);

  // Elementos del Juego
  personaje = new Jugador(10, 10, 10);
  lluvia = new Lluvia(500);
  mando = new Mando(personaje, lluvia);
  mapa = new Mapa("niveles/colisiones_1.png", "niveles/nivel_1.png", personaje, gravity);

  // Selector de Puerto COM
  setupBtn();
}


void draw() {
  background(230, 230, 250); // background color in RGB color cordinates

  // Elementos del Juego
  mando.update();
  mapa.comprobarColisiones();
  personaje.dibujar();
  mapa.getColorPredominante();
  mando.setLedsRGB(mapa.getColoresIzq(), mapa.getColoresDer());
  lluvia.dibujarLluvia();

  // Selector de Puerto COM
  drawButtons();
}
