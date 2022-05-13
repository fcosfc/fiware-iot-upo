#!/bin/sh
#
#   temperature-pub.sh: script que simula el comportamiento de Arduino en el envío de mensajes
#                       con datos de temperatura (formato Ultralight 2.0) al broker de mensajería.
#
#   Dependencia: mosquitto-clients 
#
echo "Comienza el envío de mensajes al tópico ${MQTT_SEND_TO_TOPIC}"

while [ 1 ]
do
    temperature=$((20 + RANDOM % 10))
    echo "Enviando temperatura aleatoria... $temperature grados centígrados"

    mosquitto_pub -h ${MQTT_SERVER_HOST} -p ${MQTT_SERVER_PORT} -m "t|$temperature" -t ${MQTT_SEND_TO_TOPIC}

    sleep 2
done