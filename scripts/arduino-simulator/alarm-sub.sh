#!/bin/sh
#
#   alarm-sub.sh: script que simula el comportamiento de Arduino en el consumo de mensajes
#                 publicados en el broker de mensajería con comandos de alarma (formato Ultralight 2.0).
#
#   Dependencia: mosquitto-clients 
#
echo "Suscrito al tópico ${MQTT_SUBSCRIBE_TO_TOPIC}"

mosquitto_sub -h ${MQTT_SERVER_HOST} -p ${MQTT_SERVER_PORT} -t ${MQTT_SUBSCRIBE_TO_TOPIC}