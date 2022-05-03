/*
  @file: fiware-iot-upo.ino
  @author: Paco Saucedo
  @brief: sketch que interactua con un broker MQTT para:
          - Publicar la temperatura leída desde un sensor.
          - Suscribirse a un tópico para recibir comandos para hacer sonar un actuador alarma.
          En el formato de payloads de publicación y suscripción se usa el protocolo Ultralight 2.0 (ul)
*/
#include <SPI.h>
#include <WiFi101.h>
#include <PubSubClient.h>
#include "arduino_secrets.h"

#define UPDATE_TIME_INTERVAL 2000
#define MQTT_BROKER_PORT     1883
#define MQTT_BUFFER_SIZE     2048

#define ALARM_TONE_FREC      440
#define ALARM_MILISECS       500

char ssid[] = SECRET_SSID;
char pass[] = SECRET_PASS;

const char  clientID[]   = "arduino_client";
// Cambiar por la dirección IP del equipo en el que se ejecute el broker MQTT
const char* mqttBrokerIp = "192.168.0.17";

const int  pinTempSensor = A0;
const int  pinAlarm      = 9;

const String alarmTopic       = "/TEF/alarm001/cmd";
const String temperatureTopic = "/ul/4pacosaucedo2guadiaro4s40d59ov/temperature001/attrs";

const String expectedAlarmMsgUl     = "alarm001@ring|";
const String ulTemperatureMsgPrefix = "t|";

long lastPublishMillis   = 0;

WiFiClient client;

PubSubClient mqttClient(client);

/**
   Configuración inicial
*/
void setup() {
  Serial.begin(9600);

  pinMode(pinAlarm, OUTPUT);
  tone(pinAlarm, ALARM_TONE_FREC, ALARM_MILISECS); // tono de test inicial

  connectWifi();

  mqttClient.setServer(mqttBrokerIp, MQTT_BROKER_PORT);
  mqttClient.setCallback(mqttSubscriptionCallback);
  mqttClient.setBufferSize(MQTT_BUFFER_SIZE);
}

/**
   Bucle principal del programa
*/
void loop() {
  if (WiFi.status() != WL_CONNECTED) {
    connectWifi();
  }

  if (!mqttClient.connected()) {
    mqttConnect();

    mqttClient.subscribe(alarmTopic.c_str());
  }

  mqttClient.loop();

  if (abs(millis() - lastPublishMillis) > UPDATE_TIME_INTERVAL) {
    publishTemperature();

    lastPublishMillis = millis();
  }

  delay(50);
}

/**
   Método que conecta a la red WiFi
*/
void connectWifi() {
  int status = WL_IDLE_STATUS;

  if (WiFi.status() == WL_NO_SHIELD) {
    Serial.println("WiFi shield not present");
    while (true);
  }

  while ( status != WL_CONNECTED) {
    Serial.print("Attempting to connect to Network named: ");
    Serial.println(ssid);

    status = WiFi.begin(ssid, pass);

    delay(10000);
  }

  printWiFiStatus();
}

/**
   Método que muestra el estado de la conexión a la red WiFi
*/
void printWiFiStatus() {
  Serial.print("SSID: ");
  Serial.println(WiFi.SSID());

  IPAddress ip = WiFi.localIP();
  Serial.print("IP Address: ");
  Serial.println(ip);

  long rssi = WiFi.RSSI();
  Serial.print("Signal strength (RSSI):");
  Serial.print(rssi);
  Serial.println(" dBm");
}

/**
   Método que conecta al broker MQTT
*/
void mqttConnect() {
  while ( !mqttClient.connected() ) {
    if ( mqttClient.connect( clientID ) ) {
      Serial.print( "MQTT to " );
      Serial.print( mqttBrokerIp );
      Serial.print (" at port ");
      Serial.print( MQTT_BROKER_PORT );
      Serial.println( " successful." );
    } else {
      Serial.print( "MQTT connection failed, rc = " );
      Serial.print( mqttClient.state() );
      Serial.println( " Will try again in a few seconds" );
      delay( 10000 );
    }
  }
}

/**
   Método que gestiona la suscripción a los canales de actuadores del broker MQTT
*/
void mqttSubscriptionCallback(char* topic, byte* payload, unsigned int length) {
  String topicString = String(topic);
  String payloadString = getPayloadString(payload, length);

  Serial.print("Message arrived [");
  Serial.print(topicString);
  Serial.print("], payload: ");
  Serial.println(payloadString);

  if (payloadString.compareTo(expectedAlarmMsgUl) == 0) {
    tone(pinAlarm, ALARM_TONE_FREC, ALARM_MILISECS);
  }
}

/**
   Método de conversión de los bytes recibidos a String
*/
String getPayloadString(byte* payload, unsigned int length) {
  char payloadCharArray[length + 1];

  memcpy(payloadCharArray, payload, length);
  payloadCharArray[length] = '\0';

  return String(payloadCharArray);
}

/**
   Método de envío de un mensaje a un tópico del broker MQTT
*/
void publishData(String topic, String payload) {
  mqttClient.publish(topic.c_str(), payload.c_str());

  Serial.print("Publishing data, Topic = ");
  Serial.print(topic);
  Serial.print(", Payload = ");
  Serial.println(payload);
}

/**
   Método que devuelve la medida del sensor de temperatura
*/
float readTemperatureSensor() {
  int tempSensor = 0;
  float tempVoltage = 0;
  float tempDegrees;
  tempSensor  = analogRead(pinTempSensor);
  tempVoltage = tempSensor * (3300 / 1024);
  tempDegrees = (tempVoltage - 500) / 10;
  return tempDegrees;
}

/**
   Método de envío del dato de temperatura broker MQTT
*/
void publishTemperature(void) {
  String payload = ulTemperatureMsgPrefix;
  payload.concat(String(readTemperatureSensor()));

  publishData(temperatureTopic, payload);
}
