#!/bin/bash
#
#  services.sh: script para la gestión de los contenedores del proyecto
# 
#  Referencia: https://github.com/FIWARE/tutorials.Step-by-Step
#  
#  Dependencias: 
#  		- Docker: https://docs.docker.com/engine/install/ 
#       - Docker Compose: https://docs.docker.com/compose/
#
#  Uso: services.sh [start|stop]

set -e

DOCKER_CMD="docker-compose"
USAGE="usage: services [help | start [test] | stop]"

if [[ $# < 1 || $# > 2 ]]; then	
	echo "Illegal number of parameters"
	echo $USAGE
	exit 1;
fi

if [[ $# == 2 && "$1" == "start" ]]; then
	if [[ "$2" == "test" ]]; then
		DOCKER_CMD="$DOCKER_CMD --profile test"
	else
		echo "Wrong parameter"
		echo $USAGE
		exit 1;
	fi
fi

loadData () {
	docker run --rm -v $(pwd)/scripts/import-initial-context-data.sh:/import-initial-context-data.sh \
		--network fiware-iot-upo_default \
		--entrypoint /bin/ash curlimages/curl import-initial-context-data.sh
	echo ""
}

stoppingContainers () {
	CONTAINERS=$(docker ps --filter "label=com.wordpress.fcosfc=fiware-iot-upo" -aq)
	if [[ -n $CONTAINERS ]]; then 
		echo "Stopping containers"
		docker rm -f $CONTAINERS || true
	fi
	VOLUMES=$(docker volume ls -qf dangling=true) 
	if [[ -n $VOLUMES ]]; then 
		echo "Removing old volumes"
		docker volume rm $VOLUMES || true
	fi
	NETWORKS=$(docker network ls  --filter "label=com.wordpress.fcosfc=fiware-iot-upo" -q) 
	if [[ -n $NETWORKS ]]; then 
		echo "Removing tutorial networks"
		docker network rm $NETWORKS || true
	fi
}

addDatabaseIndex () {
	printf "Create \033[1mMongoDB\033[0m database indexes ..."
	docker exec  db-mongo mongo --eval '
	conn = new Mongo();db.createCollection("orion");
	db = conn.getDB("orion");
	db.createCollection("entities");
	db.entities.createIndex({"_id.servicePath": 1, "_id.id": 1, "_id.type": 1}, {unique: true});
	db.entities.createIndex({"_id.type": 1}); 
	db.entities.createIndex({"_id.id": 1});' > /dev/null
	echo -e " \033[1;32mdone\033[0m"
}

displayServices () {
	echo ""
	docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}" --filter "label=com.wordpress.fcosfc=fiware-iot-upo"
	echo ""
}

waitForMongo () {
	echo -e "\n⏳ Waiting for \033[1mMongoDB\033[0m to be available\n"
	while ! [ `docker inspect --format='{{.State.Health.Status}}' db-mongo` == "healthy" ]
	do 
		sleep 1
	done
}

waitForOrion () {
	echo -e "\n⏳ Waiting for \033[1;34mOrion\033[0m to be available\n"

	while ! [ `docker inspect --format='{{.State.Health.Status}}' fiware-orion` == "healthy" ]
	do
	  echo -e "Context Broker HTTP state: " `curl -s -o /dev/null -w %{http_code} 'http://localhost:1026/version'` " (waiting for 200)"
	  sleep 1
	done
}

waitIoTAgent () {
	echo -e "\n⏳ Waiting for \033[1;34mIoT Agent\033[0m to be available\n"

	while ! [ `docker inspect --format='{{.State.Health.Status}}' fiware-iot-agent` == "healthy" ]
	do
	  echo -e "IoT Agent HTTP state: " `curl -s -o /dev/null -w %{http_code} 'http://localhost:4041/version'` " (waiting for 200)"
	  sleep 1
	done
}

command="$1"
case "${command}" in
	"help")
		echo $USAGE
		;;
	"start")
		export $(cat docker/.env | grep "#" -v)
		stoppingContainers
		echo -e "Starting containers: \033[1;34mOrion\033[0m and a \033[1mMongoDB\033[0m database."
		echo -e "- \033[1;34mOrion\033[0m is the context broker"
		echo ""		
		$DOCKER_CMD -f docker/docker-compose.yml up -d --remove-orphans
		waitForMongo
		addDatabaseIndex
		waitForOrion
		waitIoTAgent
		loadData
		displayServices
		;;
	"stop")
		export $(cat docker/.env | grep "#" -v)
		stoppingContainers
		;;
	*)
		echo "Command not Found."
		echo $USAGE
		exit 127;
		;;
esac