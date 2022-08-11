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

WEBHOOK_ENV='.env-webhook'
if [ $WEBHOOK_ENV ]; then
    if [ -f $WEBHOOK_ENV ]; then
        export $(cat $WEBHOOK_ENV | xargs)
    else
        echo "Please provide a valid webhook environment file"
        exit -1
    fi
else
    echo "Please provide a valid webhook environment file"
    exit -1
fi

ERROR_MESSAGE="Backup failure"
handle_failure () {
    ./discord.sh \
      --webhook-url=$WEBHOOK \
      --username "Minecraft Backups" \
      --text "$ERROR_MESSAGE"
}

echo "Received environemnt file $1"
echo "screen name = ${SCREEN_NAME}"
echo "server path = ${SERVER_PATH}"
echo ""

#Check if server is running, and stop it if so 
if [ $(screen -ls | wc -l) -gt 2 ] && [ $(screen -S $SCREEN_NAME -Q select . ; echo $?) -eq 0 ]; then
    if [ $2 ] && [ $2 = '-f' ] || [ $2 = "--force"]; then
        echo "Stopping Minecraft server"

        screen -S $SCREEN_NAME -p 0 -X stuff "stop\n"; sleep 3

        echo "Minecraft server stopped"
    else
        echo "Stopping Minecraft server in 60 seconds..."

        screen -S $SCREEN_NAME -p 0 -X stuff "say The server will shut down in 1 minute to perform an automated backup\n"; sleep 45
        screen -S $SCREEN_NAME -p 0 -X stuff "say The server will shut down in 15 seconds\n"; sleep 10
        screen -S $SCREEN_NAME -p 0 -X stuff "say The server will shut down in 5 seconds\n"; sleep 1
        screen -S $SCREEN_NAME -p 0 -X stuff "say The server will shut down in 4 seconds\n"; sleep 1
        screen -S $SCREEN_NAME -p 0 -X stuff "say The server will shut down in 3 seconds\n"; sleep 1
        screen -S $SCREEN_NAME -p 0 -X stuff "say The server will shut down in 2 seconds\n"; sleep 1
        screen -S $SCREEN_NAME -p 0 -X stuff "say The server will shut down in 1 second\n"; sleep 1

        screen -S $SCREEN_NAME -p 0 -X stuff "kick @a The server has shut down to perform an automated backup\n"; sleep 3
        screen -S $SCREEN_NAME -p 0 -X stuff "stop\n"; sleep 3

        echo "Minecraft server stopped"

        if [ $(screen -ls | wc -l) -gt 2 ] && [ $(screen -S $SCREEN_NAME -Q select . ; echo $?) -eq 0 ]; then
            ERROR_MESSAGE='Server failed to stop'
            handle_failure
            exit -1
        fi
    fi
fi

if [ ! -d $WORLD_PATH ]; then
    ERROR_MESSAGE='World path was not found'
    handle_failure
    exit -1
fi

if [ ! -d $BACKUP_PATH ]; then
    ERROR_MESSAGE='Backup path was not found'
    handle_failure
    exit -1
fi

BACKUP_FOLDER="$(date '+%m-%d-%Y(%H:%M:%S)')"
FULL_BACKUP_PATH="$BACKUP_PATH/$BACKUP_FOLDER"

echo "Server backup path:"
echo $FULL_BACKUP_PATH

mkdir "$FULL_BACKUP_PATH"

if [ ! -d $FULL_BACKUP_PATH ]; then
    ERROR_MESSAGE='Unable to create backup directory'
    handle_failure
    exit -1
fi