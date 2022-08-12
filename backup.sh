#!/bin/bash

./status.sh $1
SERVER_STATUS=$?
export $(cat $1 | xargs)
echo ""

if [ $2 ]; then
    if [ -f $2 ]; then
        export $(cat $2 | xargs)
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
    
    exit -1
}

stop_server () {
    echo "Stopping Minecraft server"

    screen -S $SCREEN_NAME -p 0 -X stuff "kick @a The server has shut down to perform an automated backup\n"; sleep 3
    screen -S $SCREEN_NAME -p 0 -X stuff "stop\n"; sleep 3

    echo "Minecraft server stopped"
}

stop_server_delayed () {
    echo "Stopping Minecraft server in 60 seconds..."

    screen -S $SCREEN_NAME -p 0 -X stuff "say The server will shut down in 1 minute to perform an automated backup\n"; sleep 45
    screen -S $SCREEN_NAME -p 0 -X stuff "say The server will shut down in 15 seconds\n"; sleep 10
    screen -S $SCREEN_NAME -p 0 -X stuff "say The server will shut down in 5 seconds\n"; sleep 1
    screen -S $SCREEN_NAME -p 0 -X stuff "say The server will shut down in 4 seconds\n"; sleep 1
    screen -S $SCREEN_NAME -p 0 -X stuff "say The server will shut down in 3 seconds\n"; sleep 1
    screen -S $SCREEN_NAME -p 0 -X stuff "say The server will shut down in 2 seconds\n"; sleep 1
    screen -S $SCREEN_NAME -p 0 -X stuff "say The server will shut down in 1 second\n"; sleep 1

    stop_server
}

if ! [ $SERVER_STATUS -eq 0 ]; then
    if [ $3 ]; then
        if [ $3 == '-f' ] || [ $3 == '--force' ]; then
            stop_server
        else
            stop_server_delayed
        fi
    else
        stop_server_delayed
    fi

    ./status.sh $1 > /dev/null
    NEW_SERVER_STATUS=$?

    if ! [ $NEW_SERVER_STATUS -eq 0 ]; then
        ERROR_MESSAGE='Server failed to stop'
        handle_failure
    fi
fi

FULL_WORLD_PATH="$SERVER_PATH/$WORLD_FOLDER"
if [ $SERVER_PATH ]; then
    if [ ! -d $SERVER_PATH ]; then
        ERROR_MESSAGE='Server directory does not exist'
        handle_failure
    fi

    if [ $WORLD_FOLDER ]; then
        if [ ! -d $FULL_WORLD_PATH ]; then
            ERROR_MESSAGE='World directory does not exist'
            handle_failure
        fi
    else
        ERROR_MESSAGE='World path was not found in environment file'
        handle_failure
    fi
else
    ERROR_MESSAGE='Server path was not found in environment file'
    handle_failure
fi

if [ $BACKUP_PATH ]; then
    if [ ! -d $BACKUP_PATH ]; then
        ERROR_MESSAGE='Backup directory does not exist'
        handle_failure
    fi
else
    ERROR_MESSAGE='Backup path was not found in environment file'
    handle_failure
fi

BACKUP_FOLDER="$(date '+%m-%d-%Y(%H:%M:%S)')"
FULL_BACKUP_PATH="$BACKUP_PATH/$BACKUP_FOLDER"

echo ""
echo "Server backup path:"
echo $FULL_BACKUP_PATH
echo "World path:"
echo $FULL_WORLD_PATH
echo ""

echo "Beginning backup..."

cp -r $FULL_WORLD_PATH $FULL_BACKUP_PATH

if [ $? != 0 ]; then
    ERROR_MESSAGE='Failed to copy files during backup'
    handle_failure
fi

echo "Verifying files are identical..."

diff -rq --no-dereference $FULL_WORLD_PATH $FULL_BACKUP_PATH

if [ $? != 0 ]; then
    ERROR_MESSAGE="Files are not the same $?"
    handle_failure
fi

echo "Backup completed"

./start.sh $1 > /dev/null

echo "Restarted Minecraft server"

exit 0