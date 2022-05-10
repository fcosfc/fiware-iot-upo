#!/bin/bash
#
#   arduino-simulator.sh: script que simula el comportamiento de Arduino en el envío de mensajes
#                         con datos de temperatura (formato Ultralight 2.0) al broker de mensajería.
#
#   Dependencia: mosquitto-clients 
#
while [ 1 ]
do
    temperature=$((20 + RANDOM % 10))
    echo "Temperatura: $temperature"

    mosquitto_pub -m "t|$temperature" -t "/ul/4pacosaucedo2guadiaro4s40d59ov/temperature001/attrs"

    sleep 2
done