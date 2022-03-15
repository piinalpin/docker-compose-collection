#!/bin/bash

usage="
Usage ./$(basename "$0") COMMAND

Commands:
    start   start kafka server
    stop    stop kafka server
"

help="
$(basename "$0"): '$1' is not a ./$(basename "$0") command.
See './$(basename "$0") --help'
"

FILE=~/kafka-cli.yaml
NAME=Kafka

if [ "$1" == "--help" ] ; then
    echo "$usage"
    exit 0
fi

if [ $# = 1 ]; then
    if [[ ! -f "$FILE" ]]; then
        curl -o $FILE https://raw.githubusercontent.com/piinalpin/docker-compose-collection/master/kafka-cli.yaml
    fi

    if [ $* = "start" ]; then
        docker-compose -f $FILE up -d
        echo "$NAME has started."
    elif [ $* = "stop" ]; then
        docker-compose -f $FILE down -v
        echo "$NAME has stopped."
    else
        echo "$help"
        exit 0
    fi
else
    echo "$help"
    exit 0
fi