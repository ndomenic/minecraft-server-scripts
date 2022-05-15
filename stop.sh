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
    if [ $2 = "-f" ] || [ $2 = "--force"]; then
        screen -S $SCREEN_NAME -p 0 -X stuff "stop\n"; sleep 3

        echo "Minecraft server stopped"
    else
        echo "Stopping Minecraft server in 15 seconds..."

        screen -S $SCREEN_NAME -p 0 -X stuff "say The server will shut down in 15 seconds\n"; sleep 10
        screen -S $SCREEN_NAME -p 0 -X stuff "say The server will shut down in 5 seconds\n"; sleep 1
        screen -S $SCREEN_NAME -p 0 -X stuff "say The server will shut down in 4 seconds\n"; sleep 1
        screen -S $SCREEN_NAME -p 0 -X stuff "say The server will shut down in 3 seconds\n"; sleep 1
        screen -S $SCREEN_NAME -p 0 -X stuff "say The server will shut down in 2 seconds\n"; sleep 1
        screen -S $SCREEN_NAME -p 0 -X stuff "say The server will shut down in 1 second\n"; sleep 1

        screen -S $SCREEN_NAME -p 0 -X stuff "stop\n"; sleep 3

        echo "Minecraft server stopped"
    fi
else 
    echo "The specified server is not running"
    exit -1
fi