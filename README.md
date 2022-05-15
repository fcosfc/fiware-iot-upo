# Prueba de concepto tecnología FIWARE

Proyecto asignatura Sistemas Empotrados y Ubícuos \
[Máster Universitario en Ingeniería Informática](https://www.upo.es/postgrado/Master-Oficial-Ingenieria-Informatica/) \
[Universidad Pablo de Olavide](https://www.upo.es)

## Contenido

* [Objetivo](/Objetivo).
* [Introducción a FIWARE](/Introducción-a-FIWARE).
* [Alcance de la PoC FIWARE](/Alcance-de-la-PoC-FIWARE).
* [Arquitectura de la PoC FIWARE](/Arquitectura-de-la-PoC-FIWARE).
  * [Requisitos](/Requisitos).
  * [Uso](/Uso).
  * [Pruebas mediante Postman](/Pruebas-mediante-Postman).
* [Componentes](/Componentes).
  * [FIWARE Context Broker](/FIWARE-Context-Broker).
  * [FIWARE IoT Agent](/FIWARE-IoT-Agent).
  * [Arduino](/Arduino).
  * [Telegraf & InfluxDB](/Telegraf-&-InfluxDB).
  * [Grafana](/Grafana).

## Objetivo

Explorar la tecnología IoT Smart Solutions [FIWARE](https://www.fiware.org/) mediante una prueba de concepto básica, aplicando también los conocimientos adquiridos en la asignatura.

## Introducción a FIWARE

FIWARE se puede definir como un [conjunto de componentes software de código abierto](https://www.fiware.org/developers/catalogue/) que se pueden ensamblar para construir soluciones inteligentes, basadas en IoT, de una manera rápida, fácil y económica.

El principal y único componente obligatorio de cualquier plataforma o solución "Powered by FIWARE" es el [FIWARE Context Broker](https://github.com/telefonicaid/fiware-orion/), que proporciona una función fundamental requerida en cualquier solución inteligente: la necesidad de administrar, actualizar y proporcionar acceso a la **información de contexto**. Las entidades que forman este contexto pueden ser, por ejemplo, dispositivos IoT, que proporcionan información sobre el entorno y/o pueden actuar sobre el mismo. La gestión del contexto se hace mediante el [API NGSI v2](http://fiware.github.io/specifications/ngsiv2/stable/).

El uso de este API estándar FIWARE para acceder a la información de contexto por parte de las aplicaciones les  puede proporcionar los siguientes beneficios:

* Desacoplamiento entre la solución y los dispositivos IoT.
* Portabilidad, con aplicativos que funcionarán de igual forma en diversos entornos. Ciudades distintas, por ejemplo.
* Posibilidad de desarrollo de una Economía de datos, con organizaciones pertenecientes a diferentes dominios que pueden compartir datos de una manera estándar, en beneficio mútuo.

La siguiente figura muestra la **arquitectura general de FIWARE**:
![Arquitectura general de FIWARE](images/fiware-general-architecture.png)

Este [vídeo](https://www.youtube.com/watch?v=97JsnnpPLrA) proporciona una muy buena introducción a FIWARE. Los [tutoriales Step-by-step for NGSI v2](https://fiware-tutorials.readthedocs.io/en/latest/) son realmente interesantes a la hora de aprender esta tecnología.

## Alcance de la PoC FIWARE

Esta Prueba de concepto (PoC) cubre el siguiente alcance:

1. **Integración de un dispositivo de baja potencia IoT Arduino**, que proporciona datos sobre el entorno y permite actuar sobre el mismo.
2. **Montaje de los componentes FIWARE**, que permiten gestionar el contexto y desacoplar los aplicativos de los dispositivos IoT.
3. **Procesamiento, análisis y visualización de datos mediante componentes de terceros**, lo que demuestra la capacidad de FIWARE para integrarse con tecnologías ajenas al stack de habilitadores que propone.

Al tratarse de una PoC, no se tratan aspectos que sí deben considerarse en un sistema de producción, como la elasticidad y solidez de la solución, ni la seguridad.

## Arquitectura de la PoC FIWARE

Esta Prueba de concepto utiliza [Docker Compose](/docker/docker-compose.yml) para montar la siguiente arquitectura:
![Arquitectura de la PoC](images/fiware-iot-upo-architecture.png)

La PoC se compone de una placa Arduino con un sensor de temperatura y una alarma. El programa envía mediciones de temperatura al broker MQTT, tomando información del entorno, y se suscribe a comandos para hacer sonar la alarma, actuando sobre el entorno. Los datos de temperatura son recibidos en el IoT Agent, que los pasa al Context Broker. Éste no almacena información histórica, para ello es necesario una base de datos de series temporales, que captura la información mediante un agente. Los datos almacenados en BBDD son mostrados en un dashboard por la herramienta de visualización. Por último, mediante Postman, vía API NGSI v2, se puede explorar la información de contexto y enviar comandos para hacer sonar la alarma.

### Requisitos

Para ejecutar esta PoC son necesarios los siguientes elementos tecnológicos:

* [Arduino MKR1000](https://arduino.cl/producto/kit-arduino-mkr-iot/) (no es imprescindible, se proporciona un contenedor con un simulador).
* [Bash shell](https://en.wikipedia.org/wiki/Bash_(Unix_shell)). [Cygwin](http://www.cygwin.com/) puede ser una alternativa para los usuarios de Microsoft Windows.
* [Docker](https://www.docker.com/).
* [Docker Compose](https://docs.docker.com/compose/).
* [Postman](https://www.postman.com/).

### Uso

Para crear la arquitectura de contenedores antes mencionada, se debe ejecutar el siguiente comando:

```
./services.sh start
```
Al iniciar, se carga una [información de contexto básica](/scripts/import-initial-context-data.sh) para que la PoC comience de una forma totalmente operativa.

Si no se dispone de Arduino, se puede utilizar un contenedor de test, que simula las tareas encomendadas a éste, mediante el siguiente comando:

```
./services.sh start test
```

En consola se verá un resultado similar al siguiente:

![Contenedores](images/screenshot-containers.png)

Pasado un minuto, el sistema debería tener datos que se podrán visualizar en [http://localhost:3000](http://localhost:3000):

![Grafana](images/screenshot-grafana.png)

Se pueden parar y eliminar los componentes de la PoC mediante el siguiente comando:

```
./services.sh stop
```

### Pruebas mediante Postman

Se ha creado una [colección con diversas llamadas de prueba al API NGSI v2](/postman/FIWARE%20NGSI%20API%20Examples.postman_collection.json), que puede ser importada en la herramienta Postman. La siguiente figura muestra a la izquierda el conjunto de llamadas disponibles y un ejemplo, que proporciona los datos de la instalación del Context Broker:

![Context Broker Version Information](/images/screenshot-postman-context-broker-version.png)

## Componentes

### FIWARE Context Broker

Como se ha mencionado en el apartado [Introducción a FIWARE](/Introducción-a-FIWARE), el [Context Broker](https://github.com/telefonicaid/fiware-orion/) es el núcleo de esta tecnología, proporcionando una [API Restful](http://fiware.github.io/specifications/ngsiv2/stable/), simple pero poderosa, que permite realizar actualizaciones, consultas o suscribirse a cambios en la información de contexto. En la [colección Postman de la PoC](/postman/FIWARE%20NGSI%20API%20Examples.postman_collection.json) figuran algunos ejemplos de llamadas al API. Por otro lado, el [script de carga de datos inicial](/scripts/import-initial-context-data.sh) contiene las llamadas que crean el contexto básico de la PoC. Por ejemplo, estaciones meteorológicas:

![Estaciones meteorológicas](/images/screenshot-postman-retrieve-all-stations.png)

Y sensores de temperatura asociadas a éstas:

![Sensores de temperatura](/images/screenshot-postman-retrieve-all-temperature-sensors.png)

Es recomendable que las entidades de contexto sigan un [Smart Data Model estándar](https://www.fiware.org/smart-data-models/). Al ser una PoC muy básica, en el presente trabajo se ha creado un modelo específico muy simple, que se puede ver en las llamadas de la [colección Postman de la PoC](/postman/FIWARE%20NGSI%20API%20Examples.postman_collection.json). Por ejemplo, estaciones meteorológicas:

![Crear estación meteorológica](/images/screenshot-postman-create-one-station.png)

Como se puede ver en la [definición de contenedores de la PoC](/docker/docker-compose.yml), el [Context Broker](https://github.com/telefonicaid/fiware-orion/) almacena la información de contexto en una base de datos documental NoSQL MongoDB. En este punto, se debe tener en cuenta que:

* No se almacenan datos históricos. Si, por ejemplo, los datos de temperatura van cambiando, se guarda el último valor recibido. Si, como es lógico, queremos analizar la evolución de estos valores, deberemos suscribirnos a los cambios y procesarlos con otro componente, como se ve en la presente PoC.
* Aunque las entidades pueden tener relaciones, como se ve en la PoC entre los sensores de temperatura, los actuadores de alarma y las estaciones meteorológicas, no se puede hacer join de las entidades de contexto al estilo de las bases de datos relacionales. Para obtener la información de estas entidades relacionadas, se deben hacer diversas llamadas al API, usando como base los atributos de relación.

### FIWARE IoT Agent

Este componente desacopla a los dispositivos físicos del resto de la arquitectura, existiendo distintos agentes que adaptan diversos protocolos e incluso la posibilidad de desarrollar uno propio, tal y como se puede ver en la [documentación sobre componentes](https://www.fiware.org/developers/catalogue/) (apartado *Interface with IoT, Robots and third-party systems*).

En la PoC se utiliza el [IoT Agent for the Ultralight 2.0 protocol](https://github.com/telefonicaid/iotagent-ul/blob/master/README.md), asociado a un broker MQTT [Mosquitto](https://mosquitto.org/), al Context Broker y a la BBDD MongoDB, como repositorio de información, tal y como se puede ver en la [definición de contenedores](/docker/docker-compose.yml). De forma que el IoT Agent recibe datos de Arduino, a través de Mosquitto, en un formato muy ligero, Ultralight 2.0, destinado para dispositivos de baja potencia, y los convierte en llamadas de actualización de contexto al API NGSI v2 estándar publicada por el Context Broker.
Por otro lado, el Iot Agent recibe llamadas, desde el Context Broker en formato NGSI, con comandos para los actuadores, los convierte a Ultralight 2.0 y los publica en el broker MQTT para que los lea procese Arduino. De esta forma, los aplicativos finales se aislan de los dispositivos, utilizando sólo el [API NGSI v2](http://fiware.github.io/specifications/ngsiv2/stable/).

la [colección Postman de la PoC](/postman/FIWARE%20NGSI%20API%20Examples.postman_collection.json) contiene diversos ejemplos con llamadas para interactuar tanto con el IoT Agent directamente, como con el contexto de sensores y actuadores en el Context Broker. Por ejemplo, obtener información sobre los sensores de temperatura cercanos a un punto geolocalizado:

![Filtrar sensores por distancia](/images/screenshot-postman-filter-sensors-by-distance.png)

Y para lanzar un comando que haga sonar una alarma:

![Hacer sonar una alarma](/images/screenshot-postman-ring-an-alarm.png)

Por otro lado, en el [script de carga de datos inicial](/scripts/import-initial-context-data.sh), que, como se ha mencionado antes, contiene las llamadas que crean el contexto básico de la PoC, están las correspondientes a sensores y actuadores.

## Arduino

Se ha utilizado para esta PoC el bundle [Arduino MKR1000](https://arduino.cl/producto/kit-arduino-mkr-iot/) propuesto en la asignatura, con un montaje que contiene un sensor de temperatura y, como actuador, una alarma:

![Montaje Arduino](/images/fiware-iot-upo-arduino.png)

Se tiene que tener en cuenta en este punto, que el objetivo de la PoC es explorar la tecnología FIWARE, no disponer de un montaje físico complejo.

El [sketch Arduino](/arduino/fiware-iot-upo.ino) se conecta a una red WiFi y publica datos de temperatura, en formato Ultralight 2.0, vía MQTT. Por otro lado, se suscribe a un tópico del que recibe comandos para hacer sonar la alarma. En la interfaz serie se puede ver el registro de su trabajo:

![Log Arduino](/images/screenshot-arduino-log.png)

Como se ha mencionado en el apartado [Uso](/Uso), si no se dispone del bundle Arduino, puede utilizarse la PoC mediante el contenedor simulador proporcionado. Ejecutando en una consola el comando:

```
docker logs mqtttestclient
```

Obtenemos el log de este contenedor de test, con las temperaturas que va enviando y los comandos que recibe:

![Cliente de test](/images/screenshot-test-client-logs.png)

### Telegraf & InfluxDB

TO DO

### Grafana

TO DO
