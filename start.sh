#!/bin/bash

./status.sh $1
SERVER_STATUS=$?
export $(cat $1 | xargs)
shift 1

if [ $SERVER_STATUS -eq 0 ]; then
    echo "Attempting to start server..."

    cd $SERVER_PATH; screen -m -d -S $SCREEN_NAME java -Xmx${MEM_MAX}M -Xms${MEM_MIN}M  -jar ${SERVER_JAR} nogui; sleep 3

    echo "Started Minecraft server"
fi