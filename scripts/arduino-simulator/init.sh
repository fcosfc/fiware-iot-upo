#!/bin/sh
#
#   init.sh: script de inicio de las tareas a ejecutar por el contenedor que simula el trabajo de Arduino.
#
export $(cat /opt/mqtt-client/.env | grep "#" -v)
echo "Servidor MQTT: ${MQTT_SERVER_HOST}"
echo "Puerto: ${MQTT_SERVER_PORT}"

sleep 10 # Espera unos segungos a que el broker esté operativo

/opt/mqtt-client/temperature-pub.sh & 
/opt/mqtt-client/alarm-sub.sh