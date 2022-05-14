# Prueba de concepto tecnología FIWARE

Proyecto asignatura [Sistemas Empotrados y Ubícuos](http://robotics.upo.es/) \
[Máster Universitario en Ingeniería Informática](https://www.upo.es/postgrado/Master-Oficial-Ingenieria-Informatica/) \
[Universidad Pablo de Olavide](https://www.upo.es)

## Contenido

* [Objetivo](/Objetivo).
* [Introducción a FIWARE](/Introducción-a-FIWARE).
* [Alcance de la PoC FIWARE](/Alcance-de-la-PoC-FIWARE).
* [Arquitectura de la PoC FIWARE](/Arquitectura-de-la-PoC-FIWARE).
  * [Requisitos](/Requisitos).
  * [Uso](/Uso).

## Objetivo

Explorar la tecnología IoT Smart Solutions [FIWARE](https://www.fiware.org/) mediante una prueba de concepto básica, aplicando también los conocimientos adquiridos en la asignatura.

## Introducción a FIWARE

FIWARE se puede definir como un [conjunto de componentes software de código abierto](https://www.fiware.org/developers/catalogue/) que se pueden ensamblar para construir soluciones inteligentes de una manera rápida, fácil y económica.

El principal y único componente obligatorio de cualquier plataforma o solución "Powered by FIWARE" es un habilitador genérico de [FIWARE Context Broker](https://github.com/telefonicaid/fiware-orion/), que proporciona una función fundamental requerida en cualquier solución inteligente: la necesidad de administrar, actualizar y proporcionar acceso a la información de contexto. Las entidades que forman este contexto pueden ser, por ejemplo, dispositivos IoT, que proporcionan información sobre el entorno y/o pueden actuar sobre el mismo. La gestión del contexto se hace mediante el [API NGSI v2](http://fiware.github.io/specifications/ngsiv2/stable/).

El uso de un API estándar por parte de las aplicaciones para acceder a la información de contexto, FIWARE puede proporcionar los siguientes beneficios:

* Desacoplamiento entre la solución y los dispositivos IoT.
* Portabilidad, con aplicativos que funcionarán de igual forma en diversos entornos. Ciudades distintas, por ejemplo.
* Posibilidad de desarrollo de una Economía de datos, con organizaciones pertenecientes a diferentes dominios que pueden compartir datos de una manera estándar.

La siguiente figura muestra la arquitectura general de FIWARE:
![Arquitectura general de FIWARE](images/fiware-general-architecture.png)

Este [vídeo](https://www.youtube.com/watch?v=97JsnnpPLrA) proporciona una muy buena introducción a FIWARE.

## Alcance de la PoC FIWARE

Esta Prueba de concepto (PoC) cubre el siguiente alcance:

1. Integración de un dispositivo de baja potencia IoT Arduino, que proporciona datos sobre el entorno y permite actuar sobre el mismo.
2. Montaje de los componentes FIWARE, que permiten gestionar el contexto y desacoplar los aplicativos de los dispositivos IoT.
3. Procesamiento, análisis y visualización de datos mediante componentes de terceros, lo que demuestra la capacidad de FIWARE para integrarse con componentes de terceros.

Al tratarse de una PoC, no se tratan aspectos que sí deben considerarse en un sistema de producción, como la elasticidad y solidez de la solución, ni la seguridad.

## Arquitectura de la PoC FIWARE

Esta Prueba de concepto utiliza [Docker Compose](https://docs.docker.com/compose/) para montar la siguiente arquitectura:
![Arquitectura de la PoC](images/fiware-iot-upo-architecture.png)

La PoC se compone de una placa Arduino con un sensor de temperatura y una alarma. El programa envía mediciones de temperatura al broker MQTT, tomando información del entorno, y se suscribe a comandos para hacer sonar la alarma, actuando sobre el entorno. Los datos de temperatura son recibidos en el IoT Agent, que los pasa al Context Broker. Éste no almacena información histórica, para ello es necesario una base de datos de series temporales, que captura la información mediante un agente. Estos datos son mostrados en un dashboard por la herramienta de visualización. Por último, mediante Postman, vía API NGSI v2, se puede explorar la información de contexto y enviar comandos para hacer sonar la alarma.

### Requisitos

Para ejecutar esta PoC son necesarios los siguientes elementos tecnológicos:

* [Arduino MKR1000](https://arduino.cl/producto/kit-arduino-mkr-iot/) (no es imprescindible, se proporciona un contenedor con un simulador).
* [Bash shell](https://en.wikipedia.org/wiki/Bash_(Unix_shell)). [Cygwin](http://www.cygwin.com/) puede ser una alternativa para los usuarios de Microsoft Windows.
* [Docker](https://www.docker.com/).
* [Docker Compose](https://docs.docker.com/compose/).
* [Postman](https://www.postman.com/).

### Uso

Ejecutar el siguiente comando para crear la arquitectura de contenedores antes mencionada:

```
./services.sh start
```

Si no se dispone de Arduino, se puede utilizar un contenedor de test que simula las tareas encomendadas a éste mediante el siguiente comando:

```
./services.sh start test
```

En consola se verá un resultado similar al siguiente:

![Contenedores](images/screenshot-containers.png)

Pasado un minuto el sistema debería tener datos que se podrán visualizar en [http://localhost:3000](http://localhost:3000):

![Grafana](images/screenshot-grafana.png)