#!/bin/bash

./status.sh $1
SERVER_STATUS=$?
export $(cat $1 | xargs)
shift 1
echo ""

restart_server () {
    echo "Stopping Minecraft server..."

    screen -S $SCREEN_NAME -p 0 -X stuff "stop\n"; sleep 3
    
    echo "Starting Minecraft server..."

    cd $SERVER_PATH; screen -m -d -S $SCREEN_NAME java -Xmx${MEM_MAX}M -Xms${MEM_MIN}M  -jar ${SERVER_JAR} nogui; sleep 3

    echo "Restarted Minecraft server"
}

restart_server_delayed () {
    echo "Restarting Minecraft server in 15 seconds..."

    screen -S $SCREEN_NAME -p 0 -X stuff "say The server will restart in 15 seconds\n"; sleep 10
    screen -S $SCREEN_NAME -p 0 -X stuff "say The server will restart in 5 seconds\n"; sleep 1
    screen -S $SCREEN_NAME -p 0 -X stuff "say The server will restart in 4 seconds\n"; sleep 1
    screen -S $SCREEN_NAME -p 0 -X stuff "say The server will restart in 3 seconds\n"; sleep 1
    screen -S $SCREEN_NAME -p 0 -X stuff "say The server will restart in 2 seconds\n"; sleep 1
    screen -S $SCREEN_NAME -p 0 -X stuff "say The server will restart in 1 second\n"; sleep 1

    restart_server
}

if ! [ $SERVER_STATUS -eq 0 ]; then
    if [ $1 ]; then
        if [ $1 == '-f' ] || [ $1 == '--force' ]; then
            restart_server
        else
            restart_server_delayed
        fi
    else
        restart_server_delayed
    fi
fi