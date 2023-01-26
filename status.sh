#!/bin/bash

POSITIONAL_ARGS=()

while [[ $# -gt 0 ]]; do
    case $1 in
        .env-webhook)
        WEBHOOK=$1
        shift
        ;;
        .env-*)
        SERVER_ENV=$1
        shift
        ;;
        -v|--verbose)
        VERBOSE=true
        shift
        ;;
        -*|--*)
        echo "Unknown option $1"
        exit -1
        ;;
        *)
        POSITIONAL_ARGS+=("$1")
        shift
        ;;
    esac
done

set -- "${POSITIONAL_ARGS[@]}"

if [ $SERVER_ENV ]; then
    export $(cat $SERVER_ENV | xargs)
else
    echo "Please provide a valid server environment file"
    exit -1
fi

if [ $VERBOSE ]; then
    echo "Received environemnt file $SERVER_ENV"
    echo "screen name = ${SCREEN_NAME}"
    echo "server path = ${SERVER_PATH}"
    echo ""
fi

#Check if server is running
if [ $(screen -ls | wc -l) -gt 2 ]; then
    screen_running=$(screen -S $SCREEN_NAME -Q select . ; echo $?)  
    if [[ $screen_running =~ ^[0-9]+$ ]] && [ $screen_running -eq 0 ]; then
        echo "The specified server is running"
        exit 1
    else
        echo "The specified server is not running"
        exit 0
    fi
else 
    echo "The specified server is not running"
    exit 0
fi