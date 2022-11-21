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
dir=$HOME/.config/pouncher
mkdir -p $dir

# ----- BLOCK KAFKA -----
start_kafka() {
    if [[ ! -f $dir/kafka-cli.yaml ]]; then
        curl -o $dir/kafka-cli.yaml https://raw.githubusercontent.com/piinalpin/docker-compose-collection/arch-linux/kafka-cli.yaml
    fi

    zookeeperSecrets=`podman volume ls -q -f name=zookeeper-secrets`
    if [ -z "$zookeeperSecrets" ];  then
        zookeeperSecrets=`podman volume create zookeeper-secrets`
        echo "Create podman volume: $zookeeperSecrets"
    fi

    zookeeperData=`podman volume ls -q -f name=zookeeper-data`
    if [ -z "$zookeeperData" ];  then
        zookeeperData=`podman volume create zookeeper-data`
        echo "Create podman volume: $zookeeperData"
    fi

    zookeeperLogs=`podman volume ls -q -f name=zookeeper-logs`
    if [ -z "$zookeeperLogs" ];  then
        zookeeperLogs=`podman volume create zookeeper-logs`
        echo "Create podman volume: $zookeeperLogs"
    fi

    kafkaSecrets=`podman volume ls -q -f name=kafka-secrets`
    if [ -z "$kafkaSecrets" ];  then
        kafkaSecrets=`podman volume create kafka-secrets`
        echo "Create podman volume: $kafkaSecrets"
    fi

    kafkaData=`podman volume ls -q -f name=kafka-data`
    if [ -z "$kafkaData" ];  then
        kafkaData=`podman volume create kafka-data`
        echo "Create podman volume: $kafkaData"
    fi

    podman-compose -f $dir/kafka-cli.yaml -p kafka-cli up -d
    echo "Kafka has started."
}

stop_kafka() {
    if [[ ! -f $dir/kafka-cli.yaml ]]; then
        curl -o $dir/kafka-cli.yaml https://raw.githubusercontent.com/piinalpin/docker-compose-collection/arch-linux/kafka-cli.yaml
    fi
    podman-compose -f $dir/kafka-cli.yaml -p kafka-cli down -v
    echo "Kafka has stoped."
}
# ----- BLOCK KAFKA -----

# ----- BLOCK MYSQL -----
start_mysql() {
    if [[ ! -f $dir/mysql.yaml ]]; then
        curl -o $dir/mysql.yaml https://raw.githubusercontent.com/piinalpin/docker-compose-collection/arch-linux/mysql.yaml
    fi

    mysqlData=`podman volume ls -q -f name=mysql-data`

    if [ -z "$mysqlData" ];  then
        mysqlData=`podman volume create mysql-data`
        echo "Create podman volume: $mysqlData"
    fi

    podman-compose -f $dir/mysql.yaml -p mysql up -d

    echo "MySQL has started."
}

stop_mysql() {
    if [[ ! -f $dir/mysql.yaml ]]; then
        curl -o $dir/mysql.yaml https://raw.githubusercontent.com/piinalpin/docker-compose-collection/arch-linux/mysql.yaml
    fi

    podman-compose -f $dir/mysql.yaml -p mysql down -v

    echo "MySQL has stoped."
}
# ----- BLOCK MYSQL -----

# ----- BLOCK POSTGRESQL -----
start_postgresql() {
    if [[ ! -f $dir/postgresql.yaml ]]; then
        curl -o $dir/postgresql.yaml https://raw.githubusercontent.com/piinalpin/docker-compose-collection/arch-linux/postgresql.yaml
    fi

    postgreData=`podman volume ls -q -f name=postgre-data`

    if [ -z "$postgreData" ];  then
        postgreData=`podman volume create postgre-data`
        echo "Create podman volume: $postgreData"
    fi

    podman-compose -f $dir/postgresql.yaml -p postgresql up -d

    echo "PostgreSQL has started."
}

stop_postgresql() {
    if [[ ! -f $dir/postgresql.yaml ]]; then
        curl -o $dir/postgresql.yaml https://raw.githubusercontent.com/piinalpin/docker-compose-collection/arch-linux/postgresql.yaml
    fi

    podman-compose -f $dir/postgresql.yaml -p postgresql down -v

    echo "PostgreSQL has stoped."
}
# ----- BLOCK POSTGRESQL -----

# ----- BLOCK RABBITMQ -----
start_rabbitmq() {
    if [[ ! -f $dir/rabbitmq.yaml ]]; then
        curl -o $dir/rabbitmq.yaml https://raw.githubusercontent.com/piinalpin/docker-compose-collection/arch-linux/rabbitmq.yaml
    fi

    rabbitmqData=`podman volume ls -q -f name=rabbitmq-data`

    if [ -z "$rabbitmqData" ];  then
        rabbitmqData=`podman volume create rabbitmq-data`
        echo "Create podman volume: $rabbitmqData"

        rabbitmqLog=`podman volume ls -q -f name=rabbitmq-log`

        if [ -z "$rabbitmqLog" ];  then
            rabbitmqLog=`podman volume create rabbitmq-log`
            echo "Create podman volume: $rabbitmqLog"
        fi
    fi

    podman-compose -f $dir/rabbitmq.yaml -p rabbitmq up -d

    echo "RabbitMQ has started."
}

stop_rabbitmq() {
    if [[ ! -f $dir/rabbitmq.yaml ]]; then
        curl -o $dir/rabbitmq.yaml https://raw.githubusercontent.com/piinalpin/docker-compose-collection/arch-linux/rabbitmq.yaml
    fi

    podman-compose -f $dir/rabbitmq.yaml -p rabbitmq down -v

    echo "RabbitMQ has stoped."
}
# ----- BLOCK RABBITMQ -----

# ----- BLOCK REDIS -----
start_redis() {
    if [[ ! -f $dir/redis.yaml ]]; then
        curl -o $dir/redis.yaml https://raw.githubusercontent.com/piinalpin/docker-compose-collection/arch-linux/redis.yaml
    fi

    redisBitnamiData=`podman volume ls -q -f name=redis-bitnami-data`

    if [ -z "$redisBitnamiData" ];  then
        redisBitnamiData=`podman volume create redis-bitnami-data`
        echo "Create podman volume: $redisBitnamiData"
    fi

    redisData=`podman volume ls -q -f name=redis-data`

    if [ -z "$redisData" ];  then
        redisData=`podman volume create redis-data`
        echo "Create podman volume: $redisData"
    fi

    podman-compose -f $dir/redis.yaml -p redis up -d

    echo "Redis has started."
}

stop_redis() {
    if [[ ! -f $dir/redis.yaml ]]; then
        curl -o $dir/redis.yaml https://raw.githubusercontent.com/piinalpin/docker-compose-collection/arch-linux/redis.yaml
    fi

    podman-compose -f $dir/redis.yaml -p redis down -v

    echo "Redis has stoped."
}
# ----- BLOCK REDIS -----

# ----- BLOCK SONARQUBE -----
start_sonarqube() {
    if [[ ! -f $dir/sonarqube.yaml ]]; then
        curl -o $dir/sonarqube.yaml https://raw.githubusercontent.com/piinalpin/docker-compose-collection/arch-linux/sonarqube.yaml
    fi

    sonarqubeData=`podman volume ls -q -f name=sonarqube-data`

    if [ -z "$sonarqubeData" ];  then
        sonarqubeData=`podman volume create sonarqube-data`
        echo "Create podman volume: $sonarqubeData"

        sonarqubeExtensions=`podman volume ls -q -f name=sonarqube-extensions`

        if [ -z "$sonarqubeExtensions" ];  then
            sonarqubeExtensions=`podman volume create sonarqube-extensions`
            echo "Create podman volume: $sonarqubeExtensions"

            sonarqubeLogs=`podman volume ls -q -f name=sonarqube-logs`

            if [ -z "$sonarqubeLogs" ];  then
                sonarqubeLogs=`podman volume create sonarqube-logs`
                echo "Create podman volume: $sonarqubeLogs"

                sonarqubeTemp=`podman volume ls -q -f name=sonarqube-temp`

                if [ -z "$sonarqubeTemp" ];  then
                    sonarqubeTemp=`podman volume create sonarqube-temp`
                    echo "Create podman volume: $sonarqubeTemp"
                fi
            fi
        fi
    fi

    podman-compose -f $dir/sonarqube.yaml -p sonarqube up -d

    echo "Sonarqube has started."
}

stop_sonarqube() {
    if [[ ! -f $dir/sonarqube.yaml ]]; then
        curl -o $dir/sonarqube.yaml https://raw.githubusercontent.com/piinalpin/docker-compose-collection/arch-linux/sonarqube.yaml
    fi

    podman-compose -f $dir/sonarqube.yaml -p sonarqube down -v

    echo "Sonarqube has stoped."
}
# ----- BLOCK SONARQUBE -----

# ----- BLOCK SQLSERVER -----
start_sqlserver() {
    if [[ ! -f $dir/sqlserver.yaml ]]; then
        curl -o $dir/sqlserver.yaml https://raw.githubusercontent.com/piinalpin/docker-compose-collection/arch-linux/sqlserver.yaml
    fi

    sqlserverData=`podman volume ls -q -f name=sqlserver-data`

    if [ -z "$sqlserverData" ];  then
        sqlserverData=`podman volume create sqlserver-data`
        echo "Create podman volume: $sqlserverData"

        sqlserverUser=`podman volume ls -q -f name=sqlserver-user`

        if [ -z "$sqlserverUser" ];  then
            sqlserverUser=`podman volume create sqlserver-user`
            echo "Create podman volume: $sqlserverUser"
        fi
    fi

    podman-compose -f $dir/sqlserver.yaml -p sqlserver up -d

    echo "SQLServer has started."
}

stop_sqlserver() {
    if [[ ! -f $dir/sqlserver.yaml ]]; then
        curl -o $dir/sqlserver.yaml https://raw.githubusercontent.com/piinalpin/docker-compose-collection/arch-linux/sqlserver.yaml
    fi

    podman-compose -f $dir/sqlserver.yaml -p sqlserver down -v

    echo "SQLServer has stoped."
}
# ----- BLOCK SQLSERVER -----

# ----- BLOCK MONGODB -----
start_mongodb() {
    if [[ ! -f $dir/mongodb.yaml ]]; then
        curl -o $dir/mongodb.yaml https://raw.githubusercontent.com/piinalpin/docker-compose-collection/arch-linux/mongodb.yaml
    fi

    mongodbData=`podman volume ls -q -f name=mongodb-data`

    if [ -z "$mongodbData" ];  then
        mongodbData=`podman volume create mongodb-data`
        echo "Create podman volume: $mongodbData"

        mongodbConfig=`podman volume ls -q -f name=mongodb-config`

        if [ -z "$mongodbConfig" ];  then
            mongodbConfig=`podman volume create mongodb-config`
            echo "Create podman volume: $mongodbConfig"
        fi
    fi

    podman-compose -f $dir/mongodb.yaml -p mongodb up -d

    echo "MongoDB has started."
}

stop_mongodb() {
    if [[ ! -f $dir/mongodb.yaml ]]; then
        curl -o $dir/mongodb.yaml https://raw.githubusercontent.com/piinalpin/docker-compose-collection/arch-linux/mongodb.yaml
    fi

    podman-compose -f $dir/mongodb.yaml -p mongodb down -v

    echo "MongoDB has stoped."
}
# ----- BLOCK MONGODB -----

# ----- BLOCK CONSUL -----
start_consul() {
    if [[ ! -f $dir/consul.yaml ]]; then
        curl -o $dir/consul.yaml https://raw.githubusercontent.com/piinalpin/docker-compose-collection/arch-linux/consul.yaml
    fi

    consulData=`podman volume ls -q -f name=consul-data`

    if [ -z "$consulData" ];  then
        consulData=`podman volume create consul-data`
        echo "Create podman volume: $consulData"
    fi

    podman-compose -f $dir/consul.yaml -p consul up -d

    echo "Consul has started."
}

stop_consul() {
    if [[ ! -f $dir/consul.yaml ]]; then
        curl -o $dir/consul.yaml https://raw.githubusercontent.com/piinalpin/docker-compose-collection/arch-linux/consul.yaml
    fi

    podman-compose -f $dir/consul.yaml -p consul down -v

    echo "Consul has stoped."
}
# ----- BLOCK CONSUL -----

if [ $command == "start" ]; then
    net=`podman network ls -q -f name=archlabs-network`
    if [ -z "$net" ];  then
        net=`podman network create archlabs-network`
        echo "Create podman network: $net"
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