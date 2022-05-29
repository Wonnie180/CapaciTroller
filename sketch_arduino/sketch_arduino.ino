/*
  Imports
*/
// Globales
#include <FastLED.h>
#include <Wire.h>
#include <CapacitiveSensor.h>

#include "MPR121.h"

/*
  Defines
*/

#ifndef _BV
#define _BV(bit) (1 << (bit))
#endif

//----- Mitad  Izquierda
#define LEDS_IZQ 10   //D10
#define CAP1_IN A0    //A0 1k Ohm
#define CAP1_OUT A1   //A1 3M Ohm
#define MOTOR_1 9     //D9
#define MOTOR_2 6     //D6
//----- Mitad  Derecha
#define MOTOR_4 5     //D5
#define MOTOR_3 4     //D4
#define CAP2_OUT A7   //A7 3M Ohm
#define CAP2_IN A6    //A6 1k Ohm
#define LEDS_DER 2    //D2

#define NUM_LEDS 5

#define MOTOR_APAGADO 0
#define MOTOR_SUAVE 64 // 255 / 4 * 1
#define MOTOR_MODERADO 128 // 255 / 4 * 2
#define MOTOR_FUERTE 192 // 255 / 4 * 2

#define MPR121_ADDR 0x5A // Dirección I2C del MPR121

// Variables
int motores[] = {MOTOR_1, MOTOR_2, MOTOR_3, MOTOR_4};
int posiblesEstadosMotor[] = {MOTOR_APAGADO, MOTOR_SUAVE, MOTOR_MODERADO, MOTOR_FUERTE};
int estadoMotores[4] = {MOTOR_APAGADO, MOTOR_APAGADO, MOTOR_APAGADO, MOTOR_APAGADO};
int numMotores = sizeof(motores) / sizeof(int);
int numEstadosMotor = sizeof(posiblesEstadosMotor) / sizeof(int);

unsigned long tiempoVibracionBotones[4] = {0, 0, 0, 0};
unsigned int tiempoVibracion = 200; // milisegundos

CRGB leds_izq[NUM_LEDS];
CRGB leds_der[NUM_LEDS];

int led, r, g, b;
/*
  Variables Globales
*/
MPR121_type sensorMPR121;

//Adafruit_NeoPixel leds_izq(NUM_LEDS, LEDS_IZQ, NEO_GRB + NEO_KHZ800);
//Adafruit_NeoPixel leds_der(NUM_LEDS, LEDS_DER, NEO_GRB + NEO_KHZ800);


CapacitiveSensor Cap_Izq = CapacitiveSensor(CAP1_OUT, CAP1_IN);
CapacitiveSensor Cap_Der = CapacitiveSensor(CAP2_OUT, CAP2_IN);

uint16_t lasttouched = 0;
uint16_t currtouched = 0;

long valorCapIzq = 0;
long valorCapDer = 0;
unsigned char tocadoCapIzq = 0;
unsigned char tocadoCapDer = 0;
unsigned long milisCapIzq = millis();
unsigned long milisCapDer = millis();
unsigned long thresholdMilisCap = 1000;

bool nuevo = false;

String mensaje = "";
byte valores_leds[6] = {0};
uint8_t nuevos_datos = 0;
/*
  Setup
*/
void setup() {
  Serial.begin(9600);

  // Inicializar Leds
  FastLED.addLeds<WS2812, LEDS_IZQ, GRB>(leds_izq, NUM_LEDS);
  FastLED.addLeds<WS2812, LEDS_DER, GRB>(leds_der, NUM_LEDS);

  // Incializar sensorMPR121 Capacitivo (MPR121)
  inicializarMPR121();

  // Incializar Pads Capacitivos
  Cap_Izq.set_CS_AutocaL_Millis(0xFFFFFFFF);
  Cap_Izq.set_CS_Timeout_Millis(50);
  Cap_Der.set_CS_AutocaL_Millis(0xFFFFFFFF);
  Cap_Der.set_CS_Timeout_Millis(50);


  // Inicializar Motores
  inicializarMotores();

  // Pruebas
  for (int i = 0; i < NUM_LEDS; i++) { // For each pixel...
    leds_izq[i] = CRGB(0, 0, 100);
    leds_der[i] = CRGB(0, 0, 100);
  }
  FastLED.show();
}

/*
  Loop
*/

void loop() {
  getEstadoPinesCapacitivos();
  getEstadoPadsCapacitivos();
  vibracionBoton();

  if (nuevo) {
    enviarDatosSerial();
    nuevo = false;
  }
  leerSerial();
  interpretarSerial();

}


/*
  Funciones Auxiliares
*/
void interpretarSerial() {
  if (nuevos_datos) {
    for (int i = 0; i < 5; i++) {
      leds_izq[i] = CRGB(valores_leds[0], valores_leds[1], valores_leds[2]);
    }
    for (int i = 0; i < 5; i++) {
      leds_der[i] = CRGB(valores_leds[3], valores_leds[4], valores_leds[5]);
    }
    FastLED.show();
    //
    nuevos_datos = 0;
  }
}

void leerSerial() {
  if (Serial.available()) {
    Serial.readBytes(valores_leds, 6);
    nuevos_datos = 1;
  }
}

void enviarDatosSerial() {
  Serial.println(lasttouched);
}

//---------------------------------------------------------------------------------------
// Funciones Capacitivos
void vibracionBoton() {
  for (int i = 0; i < numMotores; i++) {
    if (estadoMotores[i] != 0 && tiempoVibracionBotones[i] < millis()) {
      setEstadoMotor(i, MOTOR_APAGADO);
    }
  }
}

void getEstadoPinesCapacitivos() {
  currtouched = sensorMPR121.getSensorData();

  uint16_t lasttouched_Aux = lasttouched;
  bitClear(lasttouched_Aux, 12);
  bitClear(lasttouched_Aux, 13);

  nuevo = currtouched != lasttouched_Aux;

  for (uint8_t i = 0; i < 12; i++) {
    // it if *is* touched and *wasnt* touched before, alert!
    if ((currtouched & _BV(i)) && !(lasttouched & _BV(i)) ) {
      if (i == 0)
        setEstadoMotor(3, 3);
      else if (i == 1)
        setEstadoMotor(3, 3); // Motor 2 (arriba derecha) dejo de funcionar
      else if (i == 9)
        setEstadoMotor(0, 3);
      else if (i == 11)
        setEstadoMotor(1, 3);
      else if (i == 10 || i == 6) {
        setEstadoMotor(0, 3);
        setEstadoMotor(1, 3);
      }
    }
  }
  // reset our state
  lasttouched = currtouched;
}


void getEstadoPadsCapacitivos() {
  valorCapIzq = Cap_Izq.capacitiveSensor(1);
  if (valorCapIzq > 10) {
    if (!tocadoCapIzq && milisCapIzq < millis()) {
      milisCapIzq = millis() + thresholdMilisCap;
      nuevo = true;
    }
    tocadoCapIzq = 1;
    bitSet(lasttouched, 13);
  } else if (valorCapIzq < 6) {
    if (tocadoCapIzq && milisCapIzq < millis()) {
      milisCapIzq = millis() + thresholdMilisCap;
      nuevo = true;
    }
    tocadoCapIzq = 0;
    bitClear(lasttouched, 13);
  }
  //
  valorCapDer = Cap_Der.capacitiveSensor(1);
  if (valorCapDer > 10) {
    if (tocadoCapDer && milisCapDer < millis()) {
      milisCapDer = millis() + thresholdMilisCap;
      nuevo = true;
    }
    tocadoCapDer = 1;
    bitSet(lasttouched, 12);

  } else if (valorCapDer < 6) {
    if (tocadoCapDer && milisCapDer < millis()) {
      milisCapDer = millis() + thresholdMilisCap;
      nuevo = true;
    }
    tocadoCapDer = 0;
    bitClear(lasttouched, 12);
  }

  if (!tocadoCapIzq && !tocadoCapDer && nuevo)
    apagarLeds();
}

//---------------------------------------------------------------------------------------
// Funciones de Motores
void apagarMotores() {
  for (int i = 0; i < numMotores; i++) {
    analogWrite(motores[i], MOTOR_APAGADO);
    estadoMotores[i] = MOTOR_APAGADO;
    tiempoVibracionBotones[i] = 0;
  }
}

void setEstadoMotor(int motor, int estadoMotor) {
  if (motor < 0 || motor > numMotores || estadoMotor < 0 || estadoMotor > numEstadosMotor)
    return;
  analogWrite(motores[motor], posiblesEstadosMotor[estadoMotor]);
  estadoMotores[motor] = posiblesEstadosMotor[estadoMotor];
  if (estadoMotor > 0)
    tiempoVibracionBotones[motor] = millis() + tiempoVibracion;
  else
    tiempoVibracionBotones[motor] = 0;
}

//-------------------------------
void inicializarMotores() {
  pinMode(MOTOR_1, OUTPUT);
  pinMode(MOTOR_2, OUTPUT);
  pinMode(MOTOR_3, OUTPUT);
  pinMode(MOTOR_4, OUTPUT);
  apagarMotores();
}

void apagarLeds() {
  FastLED.clear();
  FastLED.show();
}
void inicializarMPR121() {
  if (!sensorMPR121.begin(MPR121_ADDR)) {
    Serial.println("error setting up MPR121");
    switch (sensorMPR121.getError()) {
      case NO_ERROR:
        Serial.println("no error");
        break;
      case ADDRESS_UNKNOWN:
        Serial.println("incorrect address");
        break;
      case READBACK_FAIL:
        Serial.println("readback failure");
        break;
      case OVERCURRENT_FLAG:
        Serial.println("overcurrent on REXT pin");
        break;
      case OUT_OF_RANGE:
        Serial.println("electrode out of range");
        break;
      case NOT_INITED:
        Serial.println("not initialised");
        break;
      default:
        Serial.println("unknown error");
        break;
    }
    while (1);
  }
  sensorMPR121.setInterruptPin(4);
  sensorMPR121.setTouchThreshold(8);
  sensorMPR121.setReleaseThreshold(4);
  sensorMPR121.setFFI(FFI_10);
  sensorMPR121.setSFI(SFI_10);
  sensorMPR121.setGlobalCDT(CDT_4US);
  sensorMPR121.autoSetElectrodes();
}
