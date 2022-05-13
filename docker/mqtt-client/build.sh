#!/bin/bash
#
#   build.sh: script que construye la imagen y la publica.
#
docker build . -t fcosfc/mqtt-client
docker login
docker push fcosfc/mqtt-client