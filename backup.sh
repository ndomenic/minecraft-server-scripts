#!/bin/bash

POSITIONAL_ARGS=()
KICK_MESSAGE="The server has restarted to perform a backup"
WARN_MESSAGE="The server will restart to perform a backup"

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
        -wm|--warn-message)
        WARN_MESSAGE="$2"
        shift
        shift
        ;;
        -km|--kick-message)
        KICK_MESSAGE="$2"
        shift
        shift
        ;;
        -f|--force)
        FORCE=true
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

if [ $WEBHOOK ]; then
    export $(cat $WEBHOOK | xargs)
else
    echo "Please provide a valid webhook"
    exit -1
fi

ERROR_MESSAGE="Backup failure"
handle_failure () {
    ./discord.sh \
      --webhook-url=$WEBHOOK \
      --username "Minecraft Backups" \
      --text "$ERROR_MESSAGE\nServer: $SERVER_NAME\n$(date '+%b-%d-%Y (%H:%M:%S)')"
    
    exit -1
}

if [ $VERBOSE ]; then
    echo "Received environemnt file $SERVER_ENV"
    echo "screen name = ${SCREEN_NAME}"
    echo "server path = ${SERVER_PATH}"
    echo ""
    ./status.sh $SERVER_ENV
else
    ./status.sh $SERVER_ENV > /dev/null
fi

SERVER_STATUS=$?

RUNNING=false
if ! [ $SERVER_STATUS -eq 0 ]; then
    RUNNING=true

    if [ $FORCE ]; then
        ./stop.sh $SERVER_ENV -wm "$WARN_MESSAGE" -km "$KICK_MESSAGE" -f
    else
        ./stop.sh $SERVER_ENV -wm "$WARN_MESSAGE" -km "$KICK_MESSAGE"
    fi
    
    sleep 30
    if [ $VERBOSE ]; then
        ./status.sh $SERVER_ENV
    else
        ./status.sh $SERVER_ENV > /dev/null
    fi
    SERVER_STATUS=$?

    if ! [ $SERVER_STATUS -eq 0 ]; then
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

BACKUP_FOLDER="$(date '+%b-%d-%Y (%H:%M:%S)')"
FULL_BACKUP_PATH="$BACKUP_PATH/$BACKUP_FOLDER"

echo ""
echo "Server backup path:"
echo $FULL_BACKUP_PATH
echo "World path:"
echo $FULL_WORLD_PATH
echo ""

echo "Beginning backup..."

cp -r "$FULL_WORLD_PATH" "$FULL_BACKUP_PATH"

if [ $? != 0 ]; then
    ERROR_MESSAGE='Failed to copy files during backup'
    handle_failure
fi

echo "Verifying files are identical..."

diff -rq --no-dereference "$FULL_WORLD_PATH" "$FULL_BACKUP_PATH"

if [ $? != 0 ]; then
    ERROR_MESSAGE="Files are not the same $?"
    handle_failure
fi

echo "Backup completed"

if [ $RUNNING ]; then
    if [ $VERBOSE ]; then
        ./start.sh $SERVER_ENV
    else
        ./start.sh $SERVER_ENV > /dev/null
    fi

    if [ $? != 1 ]; then
        ERROR_MESSAGE="Server failed to start"
        handle_failure
    fi
    echo "Restarted Minecraft server"
fi

./discord.sh \
--webhook-url=$WEBHOOK \
--username "Minecraft Backups" \
--text "Backup of server $SERVER_NAME completed on $(date '+%b-%d-%Y (%H:%M:%S)')"

exit 0