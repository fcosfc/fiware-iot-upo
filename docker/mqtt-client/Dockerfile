#
# Dockerfile: definición de imagen para un cliente MQTT.
#             Los scripts deben ser inyectados como volúmenes en /opt/mqtt-client
# 
FROM alpine:3.14
RUN apk add --no-cache mosquitto-clients
ENTRYPOINT [ "/opt/mqtt-client/init.sh" ]