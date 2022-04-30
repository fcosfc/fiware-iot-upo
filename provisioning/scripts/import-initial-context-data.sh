#!/bin/bash
#
#  import-initial-context-data.sh: script de carga del contexto inicial del sistema
#
#  Referencia: https://github.com/FIWARE/tutorials.Step-by-Step

set -e

printf "⏳ Loading initial context data "

#
# Crea varias entidades de tipo Estación Meteorológica, registrando la temperatura para cada una de ellas
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
            "temperature": {
                "type": "Number",
                "value": 20,
                "metadata": {
    		        "verified": {
        		        "value": false,
        		        "type": "Boolean"
    		        }
    	        }
            },
            "location": {
                "type": "geo:json",
                "value": {
                    "type": "Point",
                    "coordinates": [36.13, -5.45]
                }
            },
            "name": {
                "type": "Text",
                "value": "Algeciras"
            }
        },
  	    {
            "id": "urn:ngsi-ld:WeatherStation:002",
            "type": "WeatherStation",
            "temperature": {
                "type": "Number",
                "value": 20.3,
                "metadata": {
    		        "verified": {
        		        "value": true,
        		        "type": "Boolean"
    		        }
    	        }
            },
            "location": {
                "type": "geo:json",
                "value": {
                    "type": "Point",
                    "coordinates": [36.21, -5.39]
                }
            },
            "name": {
                "type": "Text",
                "value": "San Roque"
            }
        },
  	    {
            "id": "urn:ngsi-ld:WeatherStation:003",
            "type": "WeatherStation",
            "temperature": {
                "type": "Number",
                "value": 19.5,
                "metadata": {
    		        "verified": {
        		        "value": true,
        		        "type": "Boolean"
    		        }
    	        }
            },
            "location": {
                "type": "geo:json",
                "value": {
                    "type": "Point",
                    "coordinates": [36.17, -5.35]
                }
            },
            "name": {
                "type": "Text",
                "value": "La Línea de la Concepción"
            }
        }
    ]
}'

echo -e " \033[1;32mdone\033[0m"
