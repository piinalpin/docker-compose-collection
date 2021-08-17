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
    kafka-cli       Kafka AMQ Stream
    mysql           MySQL Database
    postgresql      PostgreSQL Database
    rabbitmq        RabbitMQ Message Broker
    redis           Redis Memcached Database
    sonarqube       Sonarqube Code Quality and Code Security
    sqlserver       SQLServer Database
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

if [ $command == "start" ]; then
    net=`docker network ls -q -f name=my-network`
    if [ -z "$net" ];  then
        net=`docker network create my-network`
        echo "Create docker network: $net"
    fi

    case $name in
    kafka)
        if [[ ! -f ~/$dir/kafka-cli.yaml ]]; then
            curl -o ~/$dir/kafka-cli.yaml https://raw.githubusercontent.com/piinalpin/docker-compose-collection/master/kafka-cli.yaml
        fi

        docker compose -f ~/$dir/kafka-cli.yaml -p kafka-cli up -d 

        echo "Kafka has started."
        exit 0
    ;;
    mysql)
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
        exit 0
    ;;
    postgresql)
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
        exit 0
    ;;
    rabbitmq)
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
        exit 0
    ;;
    redis)
        if [[ ! -f ~/$dir/redis.yaml ]]; then
            curl -o ~/$dir/redis.yaml https://raw.githubusercontent.com/piinalpin/docker-compose-collection/master/redis.yaml
        fi

        docker compose -f ~/$dir/redis.yaml -p redis up -d

        echo "Redis has started."
        exit 0
    ;;
    sonarqube)
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
        exit 0
    ;;
    sqlserver)
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
        if [[ ! -f ~/$dir/kafka-cli.yaml ]]; then
            curl -o ~/$dir/kafka-cli.yaml https://raw.githubusercontent.com/piinalpin/docker-compose-collection/master/kafka-cli.yaml
        fi
        docker compose -f ~/$dir/kafka-cli.yaml -p kafka-cli down -v
        echo "Kafka has stopped."
    ;;
    mysql)
        if [[ ! -f ~/$dir/mysql.yaml ]]; then
            curl -o ~/$dir/mysql.yaml https://raw.githubusercontent.com/piinalpin/docker-compose-collection/master/mysql.yaml
        fi

        docker compose -f ~/$dir/mysql.yaml -p mysql down -v

        echo "MySQL has stopped."
        exit 0
    ;;
    postgresql)
        if [[ ! -f ~/$dir/postgresql.yaml ]]; then
            curl -o ~/$dir/postgresql.yaml https://raw.githubusercontent.com/piinalpin/docker-compose-collection/master/postgresql.yaml
        fi

        docker compose -f ~/$dir/postgresql.yaml -p postgresql down -v

        echo "PostgreSQL has stopped."
        exit 0
    ;;
    rabbitmq)
        if [[ ! -f ~/$dir/rabbitmq.yaml ]]; then
            curl -o ~/$dir/rabbitmq.yaml https://raw.githubusercontent.com/piinalpin/docker-compose-collection/master/rabbitmq.yaml
        fi

        docker compose -f ~/$dir/rabbitmq.yaml -p rabbitmq down -v

        echo "RabbitMQ has stopped."
        exit 0
    ;;
    redis)
        if [[ ! -f ~/$dir/redis.yaml ]]; then
            curl -o ~/$dir/redis.yaml https://raw.githubusercontent.com/piinalpin/docker-compose-collection/master/redis.yaml
        fi

        docker compose -f ~/$dir/redis.yaml -p redis down -v

        echo "Redis has stopped."
        exit 0
    ;;
    sonarqube)
        if [[ ! -f ~/$dir/sonarqube.yaml ]]; then
            curl -o ~/$dir/sonarqube.yaml https://raw.githubusercontent.com/piinalpin/docker-compose-collection/master/sonarqube.yaml
        fi

        docker compose -f ~/$dir/sonarqube.yaml -p sonarqube down -v

        echo "Sonarqube has stopped."
        exit 0
    ;;
    sqlserver)
        if [[ ! -f ~/$dir/sqlserver.yaml ]]; then
            curl -o ~/$dir/sqlserver.yaml https://raw.githubusercontent.com/piinalpin/docker-compose-collection/master/sqlserver.yaml
        fi

        docker compose -f ~/$dir/sqlserver.yaml -p sqlserver down -v

        echo "SQLServer has stopped."
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