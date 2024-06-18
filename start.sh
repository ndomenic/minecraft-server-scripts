#!/bin/bash

while [[ $# -gt 0 ]]; do
    case $1 in
        *.env-*)
            SERVER_ENV=$1
            shift
            ;;
        -v|--verbose)
            VERBOSE=true
            shift
            ;;
        -*|--*|*)
            echo "Unknown option $1"
            exit -1
            ;;
    esac
done

if [ $SERVER_ENV ]; then
    export $(cat $SERVER_ENV | xargs)
else
    echo "Please provide a valid server environment file"
    exit -1
fi

if [ $VERBOSE ]; then
    echo "Received environment file $SERVER_ENV"
    echo "screen name = ${SCREEN_NAME}"
    echo "server path = ${SERVER_PATH}"
    echo ""
    ./status.sh $SERVER_ENV
else
    ./status.sh $SERVER_ENV > /dev/null
fi

SERVER_STATUS=$?

if [ $SERVER_STATUS -eq 0 ]; then
    echo "Attempting to start server..."

    cd $SERVER_PATH; screen -m -d -S $SCREEN_NAME java -Xmx${MEM_MAX}M -Xms${MEM_MIN}M  -jar ${SERVER_JAR} nogui; sleep 3

    echo "Started Minecraft server"
    exit 1
fi

exit 0