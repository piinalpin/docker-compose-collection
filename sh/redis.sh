#!/bin/bash

usage="
Usage ./$(basename "$0") COMMAND

Commands:
    start   start redis server
    stop    stop redis server
"

help="
$(basename "$0"): '$1' is not a ./$(basename "$0") command.
See './$(basename "$0") --help'
"

FILE=redis-compose.yml

if [ "$1" == "--help" ] ; then
    echo "$usage"
    exit 0
fi

if [ $# = 1 ]; then
    if [[ ! -f "$FILE" ]]; then
        curl -o redis-compose.yml https://raw.githubusercontent.com/piinalpin/docker-compose-collection/master/redis-compose.yml
    fi

    if [ $* = "start" ]; then
        docker-compose -f redis-compose.yml up -d
        echo "Redis has started."
    elif [ $* = "stop" ]; then
        docker-compose -f redis-compose.yml down -v
        echo "Redis has stopped."
    else
        echo "$help"
        exit 0
    fi
else
    echo "$help"
    exit 0
fi