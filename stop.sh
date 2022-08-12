#!/bin/bash

./status.sh $1
SERVER_STATUS=$?
export $(cat $1 | xargs)
shift 1

stop_server () {
    screen -S $SCREEN_NAME -p 0 -X stuff "stop\n"; sleep 3
    echo "Minecraft server stopped"
}

if ! [ $SERVER_STATUS -eq 0 ]; then
    if [ $1 ] && [ $1 = '-f' ] || [ $1 = "--force"]; then
        echo ""
        echo "Stopping Minecraft server"

        stop_server
    else
        echo ""
        echo "Stopping Minecraft server in 15 seconds..."

        screen -S $SCREEN_NAME -p 0 -X stuff "say The server will shut down in 15 seconds\n"; sleep 10
        screen -S $SCREEN_NAME -p 0 -X stuff "say The server will shut down in 5 seconds\n"; sleep 1
        screen -S $SCREEN_NAME -p 0 -X stuff "say The server will shut down in 4 seconds\n"; sleep 1
        screen -S $SCREEN_NAME -p 0 -X stuff "say The server will shut down in 3 seconds\n"; sleep 1
        screen -S $SCREEN_NAME -p 0 -X stuff "say The server will shut down in 2 seconds\n"; sleep 1
        screen -S $SCREEN_NAME -p 0 -X stuff "say The server will shut down in 1 second\n"; sleep 1

        stop_server
    fi
fi