#!/bin/bash
#
#  import-initial-context-data.sh: script de carga del contexto inicial del sistema
#
#  Referencia: https://github.com/FIWARE/tutorials.Step-by-Step

set -e

printf "⏳ Loading initial context data \n"

#
# Crea varias entidades de tipo Estación Meteorológica
#

curl -s -o /dev/null -X POST \
  'http://orion:1026/v2/op/update' \
  -H 'Content-Type: application/json' \
  -g -d '{
    "actionType": "append",
    "entities": [
  	    {
            "id": "urn:ngsi-ld:WeatherStation:001",
            "type": "WeatherStation",
            "name": {
                "type": "Text",
                "value": "Algeciras"
            },
            "location": {
                "type": "geo:json",
                "value": {
                    "type": "Point",
                    "coordinates": [36.13, -5.45]
                }
            }
        },
  	    {
            "id": "urn:ngsi-ld:WeatherStation:002",
            "type": "WeatherStation",
            "name": {
                "type": "Text",
                "value": "San Roque"
            },
            "location": {
                "type": "geo:json",
                "value": {
                    "type": "Point",
                    "coordinates": [36.21, -5.39]
                }
            }
        },
  	    {
            "id": "urn:ngsi-ld:WeatherStation:003",
            "type": "WeatherStation",
            "name": {
                "type": "Text",
                "value": "La Línea de la Concepción"
            },
            "location": {
                "type": "geo:json",
                "value": {
                    "type": "Point",
                    "coordinates": [36.17, -5.35]
                }
            }
        }
    ]
}'

printf "\tWeather Station entities created\n"

#
# Creación del grupo de servicios para sensores que usan MQTT
#

curl -s -o /dev/null -X POST \
  'http://iot-agent:4041/iot/services' \
  -H 'Content-Type: application/json' \
  -H 'fiware-service: iotupo' \
  -H 'fiware-servicepath: /' \
  -d '{
    "services": [
        {
            "apikey":      "4pacosaucedo2guadiaro4s40d59ov",
            "cbroker":     "http://orion:1026",
            "entity_type": "Thing",
            "resource":    ""
        }
    ]
}'

printf "\tMQTT group services created\n"

#
# Creación de sensores de temperatura asociados a las estaciones meteorológicas
#

curl -s -o /dev/null -X POST \
  'http://iot-agent:4041/iot/devices' \
  -H 'Content-Type: application/json' \
  -H 'fiware-service: iotupo' \
  -H 'fiware-servicepath: /' \
  -d '{
    "devices": [
        {
            "device_id":   "temperature001",
            "entity_name": "urn:ngsi-ld:TemperatureSensor:001",
            "entity_type": "TemperatureSensor",
            "protocol":    "PDI-IoTA-UltraLight",
            "transport":   "MQTT",
            "timezone":    "Europe/Madrid",
            "attributes": [
                { "object_id": "t", "name": "temperature", "type": "Float" }
            ],
            "static_attributes": [
                { "name":"refWeatherStation", "type": "Relationship", "value": "urn:ngsi-ld:WeatherStation:001"}
            ]
        },
        {
            "device_id":   "temperature002",
            "entity_name": "urn:ngsi-ld:TemperatureSensor:002",
            "entity_type": "TemperatureSensor",
            "protocol":    "PDI-IoTA-UltraLight",
            "transport":   "MQTT",
            "timezone":    "Europe/Madrid",
            "attributes": [
                { "object_id": "t", "name": "temperature", "type": "Float" }
            ],
            "static_attributes": [
                { "name":"refWeatherStation", "type": "Relationship", "value": "urn:ngsi-ld:WeatherStation:002"}
            ]
        },
        {
            "device_id":   "temperature003",
            "entity_name": "urn:ngsi-ld:TemperatureSensor:003",
            "entity_type": "TemperatureSensor",
            "protocol":    "PDI-IoTA-UltraLight",
            "transport":   "MQTT",
            "timezone":    "Europe/Madrid",
            "attributes": [
                { "object_id": "t", "name": "temperature", "type": "Float" }
            ],
            "static_attributes": [
                { "name":"refWeatherStation", "type": "Relationship", "value": "urn:ngsi-ld:WeatherStation:003"}
            ]
        }
    ]
}'

printf "\tSensors created\n"

#
# Creación de actuadores de alarma asociaciados a las estaciones meteorológicas
#

curl -s -o /dev/null -X POST \
  'http://iot-agent:4041/iot/devices' \
  -H 'Content-Type: application/json' \
  -H 'fiware-service: iotupo' \
  -H 'fiware-servicepath: /' \
  -d '{
    "devices": [
        {
            "device_id": "alarm001",
            "entity_name": "urn:ngsi-ld:AlarmActuator:001",
            "entity_type": "AlarmActuator",
            "protocol": "PDI-IoTA-UltraLight",
            "transport": "MQTT",
            "commands": [
                { "name": "ring", "type": "command" }
            ],
            "static_attributes": [
                { "name":"refWeatherStation", "type": "Relationship", "value": "urn:ngsi-ld:WeatherStation:001"}
            ]
        },
        {
            "device_id": "alarm002",
            "entity_name": "urn:ngsi-ld:AlarmActuator:002",
            "entity_type": "AlarmActuator",
            "protocol": "PDI-IoTA-UltraLight",
            "transport": "MQTT",
            "commands": [
                { "name": "ring", "type": "command" }
            ],
            "static_attributes": [
                { "name":"refWeatherStation", "type": "Relationship", "value": "urn:ngsi-ld:WeatherStation:002"}
            ]
        },
        {
            "device_id": "alarm003",
            "entity_name": "urn:ngsi-ld:AlarmActuator:003",
            "entity_type": "AlarmActuator",
            "protocol": "PDI-IoTA-UltraLight",
            "transport": "MQTT",
            "commands": [
                { "name": "ring", "type": "command" }
            ],
            "static_attributes": [
                { "name":"refWeatherStation", "type": "Relationship", "value": "urn:ngsi-ld:WeatherStation:003"}
            ]
        }
    ]
}'

printf "\tActuators created\n"

echo -e " \033[1;32mdone\033[0m"
