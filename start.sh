#!/bin/bash

#Load environment variables from arguments
if [ $1 ]; then
    if [ -f $1 ]; then
        export $(cat $1 | xargs)
    else
        echo "Please provide a valid environment file"
        exit -1
    fi
else
    echo "Please specify an environment file for the server"
    exit -1
fi

echo "Received environemnt file $1"
echo "screen name = ${SCREEN_NAME}"
echo "server path = ${SERVER_PATH}"
echo ""

#Check if server is running
if [ $(screen -ls | wc -l) -gt 2 ] && [ $(screen -S $SCREEN_NAME -Q select . ; echo $?) = 0 ]; then
    echo "That server is already running"
    exit 1
fi

echo "Attempting to start server..."

MEM_MAX=4096
MEM_MIN=1024
SERVER_JAR=fabric-server-launch.jar

cd $SERVER_PATH; screen -m -d -S $SCREEN_NAME java -Xmx${MEM_MAX}M -Xms${MEM_MIN}M  -jar ${SERVER_JAR} nogui;

echo "Started Minecraft server"