#!/bin/bash

usage="
Usage ./$(basename "$0") -n <service name> -c <command>

Options:
    -n  service name
    -c  command

Commands:
    start   start service
    stop    stop service

Services:
    consul          Consul Hashicorp
    kafka           Kafka AMQ Stream
    mysql           MySQL Database
    postgresql      PostgreSQL Database
    rabbitmq        RabbitMQ Message Broker
    redis           Redis Memcached Database
    sonarqube       Sonarqube Code Quality and Code Security
    sqlserver       SQLServer Database
    mongodb         MongoDB Database
    kafka-redis     Run Kafka AMQ Stream and Redis Database
    mysql-redis     Run MySQL and Redis Database
    consul-redis    Run Consul and Redis
"

help="
$(basename "$0"): '$1' is not a ./$(basename "$0") command.
See './$(basename "$0") --help'
"


if [ "$1" == "--help" ] ; then
    echo "$usage"
    exit 0
fi

while getopts ":n:c:" opt; do
  case $opt in
    n) name="$OPTARG"
    ;;
    c) command="$OPTARG"
    ;;
    \?) echo "Invalid option -$OPTARG" >&2
    echo "$usage"
    exit 0
    ;;
  esac
done

invalidCommand="
$(basename "$0"): '$command' is not a ./$(basename "$0") command.
See './$(basename "$0") --help'
"

invalidService="
$(basename "$0"): '$name' is not a ./$(basename "$0") service.
See './$(basename "$0") --help'
"
dir=pouncher
mkdir -p $dir

# ----- BLOCK KAFKA -----
start_kafka() {
    if [[ ! -f ~/$dir/kafka-cli.yaml ]]; then
        curl -o ~/$dir/kafka-cli.yaml https://raw.githubusercontent.com/piinalpin/docker-compose-collection/master/kafka-cli.yaml
    fi

    zookeeperSecrets=`docker volume ls -q -f name=zookeeper-secrets`
    if [ -z "$zookeeperSecrets" ];  then
        zookeeperSecrets=`docker volume create zookeeper-secrets`
        echo "Create docker volume: $zookeeperSecrets"
    fi

    zookeeperData=`docker volume ls -q -f name=zookeeper-data`
    if [ -z "$zookeeperData" ];  then
        zookeeperData=`docker volume create zookeeper-data`
        echo "Create docker volume: $zookeeperData"
    fi

    zookeeperLogs=`docker volume ls -q -f name=zookeeper-logs`
    if [ -z "$zookeeperLogs" ];  then
        zookeeperLogs=`docker volume create zookeeper-logs`
        echo "Create docker volume: $zookeeperLogs"
    fi

    kafkaSecrets=`docker volume ls -q -f name=kafka-secrets`
    if [ -z "$kafkaSecrets" ];  then
        kafkaSecrets=`docker volume create kafka-secrets`
        echo "Create docker volume: $kafkaSecrets"
    fi

    kafkaData=`docker volume ls -q -f name=kafka-data`
    if [ -z "$kafkaData" ];  then
        kafkaData=`docker volume create kafka-data`
        echo "Create docker volume: $kafkaData"
    fi

    docker compose -f ~/$dir/kafka-cli.yaml -p kafka-cli up -d

    echo "Also starting crypto generator."
    docker compose -f ~/$dir/encryption-tool-generator.yaml up -d

    echo "Kafka has started."
}

stop_kafka() {
    if [[ ! -f ~/$dir/kafka-cli.yaml ]]; then
        curl -o ~/$dir/kafka-cli.yaml https://raw.githubusercontent.com/piinalpin/docker-compose-collection/master/kafka-cli.yaml
    fi
    docker compose -f ~/$dir/kafka-cli.yaml -p kafka-cli down -v
    docker compose -f ~/$dir/encryption-tool-generator.yaml down -v
    echo "Kafka has stoped."
}
# ----- BLOCK KAFKA -----

# ----- BLOCK MYSQL -----
start_mysql() {
    if [[ ! -f ~/$dir/mysql.yaml ]]; then
        curl -o ~/$dir/mysql.yaml https://raw.githubusercontent.com/piinalpin/docker-compose-collection/master/mysql.yaml
    fi

    mysqlData=`docker volume ls -q -f name=mysql-data`

    if [ -z "$mysqlData" ];  then
        mysqlData=`docker volume create mysql-data`
        echo "Create docker volume: $mysqlData"
    fi

    docker compose -f ~/$dir/mysql.yaml -p mysql up -d

    echo "MySQL has started."
}

stop_mysql() {
    if [[ ! -f ~/$dir/mysql.yaml ]]; then
        curl -o ~/$dir/mysql.yaml https://raw.githubusercontent.com/piinalpin/docker-compose-collection/master/mysql.yaml
    fi

    docker compose -f ~/$dir/mysql.yaml -p mysql down -v

    echo "MySQL has stoped."
}
# ----- BLOCK MYSQL -----

# ----- BLOCK POSTGRESQL -----
start_postgresql() {
    if [[ ! -f ~/$dir/postgresql.yaml ]]; then
        curl -o ~/$dir/postgresql.yaml https://raw.githubusercontent.com/piinalpin/docker-compose-collection/master/postgresql.yaml
    fi

    postgreData=`docker volume ls -q -f name=postgre-data`

    if [ -z "$postgreData" ];  then
        postgreData=`docker volume create postgre-data`
        echo "Create docker volume: $postgreData"
    fi

    docker compose -f ~/$dir/postgresql.yaml -p postgresql up -d

    echo "PostgreSQL has started."
}

stop_postgresql() {
    if [[ ! -f ~/$dir/postgresql.yaml ]]; then
        curl -o ~/$dir/postgresql.yaml https://raw.githubusercontent.com/piinalpin/docker-compose-collection/master/postgresql.yaml
    fi

    docker compose -f ~/$dir/postgresql.yaml -p postgresql down -v

    echo "PostgreSQL has stoped."
}
# ----- BLOCK POSTGRESQL -----

# ----- BLOCK RABBITMQ -----
start_rabbitmq() {
    if [[ ! -f ~/$dir/rabbitmq.yaml ]]; then
        curl -o ~/$dir/rabbitmq.yaml https://raw.githubusercontent.com/piinalpin/docker-compose-collection/master/rabbitmq.yaml
    fi

    rabbitmqData=`docker volume ls -q -f name=rabbitmq-data`

    if [ -z "$rabbitmqData" ];  then
        rabbitmqData=`docker volume create rabbitmq-data`
        echo "Create docker volume: $rabbitmqData"

        rabbitmqLog=`docker volume ls -q -f name=rabbitmq-log`

        if [ -z "$rabbitmqLog" ];  then
            rabbitmqLog=`docker volume create rabbitmq-log`
            echo "Create docker volume: $rabbitmqLog"
        fi
    fi

    docker compose -f ~/$dir/rabbitmq.yaml -p rabbitmq up -d

    echo "RabbitMQ has started."
}

stop_rabbitmq() {
    if [[ ! -f ~/$dir/rabbitmq.yaml ]]; then
        curl -o ~/$dir/rabbitmq.yaml https://raw.githubusercontent.com/piinalpin/docker-compose-collection/master/rabbitmq.yaml
    fi

    docker compose -f ~/$dir/rabbitmq.yaml -p rabbitmq down -v

    echo "RabbitMQ has stoped."
}
# ----- BLOCK RABBITMQ -----

# ----- BLOCK REDIS -----
start_redis() {
    if [[ ! -f ~/$dir/redis.yaml ]]; then
        curl -o ~/$dir/redis.yaml https://raw.githubusercontent.com/piinalpin/docker-compose-collection/master/redis.yaml
    fi

    redisBitnamiData=`docker volume ls -q -f name=redis-bitnami-data`

    if [ -z "$redisBitnamiData" ];  then
        redisBitnamiData=`docker volume create redis-bitnami-data`
        echo "Create docker volume: $redisBitnamiData"
    fi

    redisData=`docker volume ls -q -f name=redis-data`

    if [ -z "$redisData" ];  then
        redisData=`docker volume create redis-data`
        echo "Create docker volume: $redisData"
    fi

    docker compose -f ~/$dir/redis.yaml -p redis up -d

    echo "Redis has started."
}

stop_redis() {
    if [[ ! -f ~/$dir/redis.yaml ]]; then
        curl -o ~/$dir/redis.yaml https://raw.githubusercontent.com/piinalpin/docker-compose-collection/master/redis.yaml
    fi

    docker compose -f ~/$dir/redis.yaml -p redis down -v

    echo "Redis has stoped."
}
# ----- BLOCK REDIS -----

# ----- BLOCK SONARQUBE -----
start_sonarqube() {
    if [[ ! -f ~/$dir/sonarqube.yaml ]]; then
        curl -o ~/$dir/sonarqube.yaml https://raw.githubusercontent.com/piinalpin/docker-compose-collection/master/sonarqube.yaml
    fi

    sonarqubeData=`docker volume ls -q -f name=sonarqube-data`

    if [ -z "$sonarqubeData" ];  then
        sonarqubeData=`docker volume create sonarqube-data`
        echo "Create docker volume: $sonarqubeData"

        sonarqubeExtensions=`docker volume ls -q -f name=sonarqube-extensions`

        if [ -z "$sonarqubeExtensions" ];  then
            sonarqubeExtensions=`docker volume create sonarqube-extensions`
            echo "Create docker volume: $sonarqubeExtensions"

            sonarqubeLogs=`docker volume ls -q -f name=sonarqube-logs`

            if [ -z "$sonarqubeLogs" ];  then
                sonarqubeLogs=`docker volume create sonarqube-logs`
                echo "Create docker volume: $sonarqubeLogs"

                sonarqubeTemp=`docker volume ls -q -f name=sonarqube-temp`

                if [ -z "$sonarqubeTemp" ];  then
                    sonarqubeTemp=`docker volume create sonarqube-temp`
                    echo "Create docker volume: $sonarqubeTemp"
                fi
            fi
        fi
    fi

    docker compose -f ~/$dir/sonarqube.yaml -p sonarqube up -d

    echo "Sonarqube has started."
}

stop_sonarqube() {
    if [[ ! -f ~/$dir/sonarqube.yaml ]]; then
        curl -o ~/$dir/sonarqube.yaml https://raw.githubusercontent.com/piinalpin/docker-compose-collection/master/sonarqube.yaml
    fi

    docker compose -f ~/$dir/sonarqube.yaml -p sonarqube down -v

    echo "Sonarqube has stoped."
}
# ----- BLOCK SONARQUBE -----

# ----- BLOCK SQLSERVER -----
start_sqlserver() {
    if [[ ! -f ~/$dir/sqlserver.yaml ]]; then
        curl -o ~/$dir/sqlserver.yaml https://raw.githubusercontent.com/piinalpin/docker-compose-collection/master/sqlserver.yaml
    fi

    sqlserverData=`docker volume ls -q -f name=sqlserver-data`

    if [ -z "$sqlserverData" ];  then
        sqlserverData=`docker volume create sqlserver-data`
        echo "Create docker volume: $sqlserverData"

        sqlserverUser=`docker volume ls -q -f name=sqlserver-user`

        if [ -z "$sqlserverUser" ];  then
            sqlserverUser=`docker volume create sqlserver-user`
            echo "Create docker volume: $sqlserverUser"
        fi
    fi

    docker compose -f ~/$dir/sqlserver.yaml -p sqlserver up -d

    echo "SQLServer has started."
}

stop_sqlserver() {
    if [[ ! -f ~/$dir/sqlserver.yaml ]]; then
        curl -o ~/$dir/sqlserver.yaml https://raw.githubusercontent.com/piinalpin/docker-compose-collection/master/sqlserver.yaml
    fi

    docker compose -f ~/$dir/sqlserver.yaml -p sqlserver down -v

    echo "SQLServer has stoped."
}
# ----- BLOCK SQLSERVER -----

# ----- BLOCK MONGODB -----
start_mongodb() {
    if [[ ! -f ~/$dir/mongodb.yaml ]]; then
        curl -o ~/$dir/mongodb.yaml https://raw.githubusercontent.com/piinalpin/docker-compose-collection/master/mongodb.yaml
    fi

    mongodbData=`docker volume ls -q -f name=mongodb-data`

    if [ -z "$mongodbData" ];  then
        mongodbData=`docker volume create mongodb-data`
        echo "Create docker volume: $mongodbData"

        mongodbConfig=`docker volume ls -q -f name=mongodb-config`

        if [ -z "$mongodbConfig" ];  then
            mongodbConfig=`docker volume create mongodb-config`
            echo "Create docker volume: $mongodbConfig"
        fi
    fi

    docker compose -f ~/$dir/mongodb.yaml -p mongodb up -d

    echo "MongoDB has started."
}

stop_mongodb() {
    if [[ ! -f ~/$dir/mongodb.yaml ]]; then
        curl -o ~/$dir/mongodb.yaml https://raw.githubusercontent.com/piinalpin/docker-compose-collection/master/mongodb.yaml
    fi

    docker compose -f ~/$dir/mongodb.yaml -p mongodb down -v

    echo "MongoDB has stoped."
}
# ----- BLOCK MONGODB -----

# ----- BLOCK CONSUL -----
start_consul() {
    if [[ ! -f ~/$dir/consul.yaml ]]; then
        curl -o ~/$dir/consul.yaml https://raw.githubusercontent.com/piinalpin/docker-compose-collection/master/consul.yaml
    fi

    consulData=`docker volume ls -q -f name=consul-data`

    if [ -z "$consulData" ];  then
        consulData=`docker volume create consul-data`
        echo "Create docker volume: $consulData"
    fi

    docker compose -f ~/$dir/consul.yaml -p consul up -d

    echo "Consul has started."
}

stop_consul() {
    if [[ ! -f ~/$dir/consul.yaml ]]; then
        curl -o ~/$dir/consul.yaml https://raw.githubusercontent.com/piinalpin/docker-compose-collection/master/consul.yaml
    fi

    docker compose -f ~/$dir/consul.yaml -p consul down -v

    echo "Consul has stoped."
}
# ----- BLOCK CONSUL -----

if [ $command == "start" ]; then
    net=`docker network ls -q -f name=my-network`
    if [ -z "$net" ];  then
        net=`docker network create my-network`
        echo "Create docker network: $net"
    fi

    case $name in
    kafka)
        start_kafka
        exit 0
    ;;
    mysql)
        start_mysql
        exit 0
    ;;
    postgresql)
        start_postgresql
        exit 0
    ;;
    rabbitmq)
        start_rabbitmq
        exit 0
    ;;
    redis)
        start_redis
        exit 0
    ;;
    sonarqube)
        start_sonarqube
        exit 0
    ;;
    sqlserver)
        start_sqlserver
        exit 0
    ;;
    mongodb)
        start_mongodb
        exit 0
    ;;
    kafka-redis)
        start_kafka
        start_redis
        exit 0
    ;;
    mysql-redis)
        start_mysql
        start_redis
        exit 0
    ;;
    consul)
        start_consul
        exit 0
    ;;
    consul-redis)
        start_consul
        start_redis
        exit 0
    ;;
    *)
    echo "$invalidService"
    exit 0
    ;;
    esac
elif [ $command == "stop" ]; then
    case $name in
    kafka)
        stop_kafka
        exit 0
    ;;
    mysql)
        stop_mysql
        exit 0
    ;;
    postgresql)
        stop_postgresql
        exit 0
    ;;
    rabbitmq)
        stop_rabbitmq
        exit 0
    ;;
    redis)
        stop_redis
        exit 0
    ;;
    sonarqube)
        stop_sonarqube
        exit 0
    ;;
    sqlserver)
        stop_sqlserver
        exit 0
    ;;
    mongodb)
        stop_mongodb
        exit 0
    ;;
    kafka-redis)
        stop_kafka
        stop_redis
        exit 0
    ;;
    mysql-redis)
        stop_mysql
        stop_redis
        exit 0
    ;;
    consul)
        stop_consul
        exit 0
    ;;
    consul-redis)
        stop_consul
        stop_redis
        exit 0
    ;;
    *)
    echo "$invalidService"
    exit 0
    ;;
    esac
else
    echo "$invalidCommand"
    exit 0
fi