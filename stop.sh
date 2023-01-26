#!/bin/bash

POSITIONAL_ARGS=()
KICK_MESSAGE="The server has shut down"
WARN_MESSAGE="The server will shut down"

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

print_warning () {
    echo "Stopping Minecraft server in 30 seconds..."

    screen -S $SCREEN_NAME -p 0 -X stuff "say $WARN_MESSAGE in 30 seconds\n"; sleep 5
    screen -S $SCREEN_NAME -p 0 -X stuff "say $WARN_MESSAGE in 25 seconds\n"; sleep 5
    screen -S $SCREEN_NAME -p 0 -X stuff "say $WARN_MESSAGE in 20 seconds\n"; sleep 5
    screen -S $SCREEN_NAME -p 0 -X stuff "say $WARN_MESSAGE in 15 seconds\n"; sleep 5
    screen -S $SCREEN_NAME -p 0 -X stuff "say $WARN_MESSAGE in 10 seconds\n"; sleep 1
    screen -S $SCREEN_NAME -p 0 -X stuff "say $WARN_MESSAGE in 9 seconds\n"; sleep 1
    screen -S $SCREEN_NAME -p 0 -X stuff "say $WARN_MESSAGE in 8 seconds\n"; sleep 1
    screen -S $SCREEN_NAME -p 0 -X stuff "say $WARN_MESSAGE in 7 seconds\n"; sleep 1
    screen -S $SCREEN_NAME -p 0 -X stuff "say $WARN_MESSAGE in 6 seconds\n"; sleep 1
    screen -S $SCREEN_NAME -p 0 -X stuff "say $WARN_MESSAGE in 5 seconds\n"; sleep 1
    screen -S $SCREEN_NAME -p 0 -X stuff "say $WARN_MESSAGE in 4 seconds\n"; sleep 1
    screen -S $SCREEN_NAME -p 0 -X stuff "say $WARN_MESSAGE in 3 seconds\n"; sleep 1
    screen -S $SCREEN_NAME -p 0 -X stuff "say $WARN_MESSAGE in 2 seconds\n"; sleep 1
    screen -S $SCREEN_NAME -p 0 -X stuff "say $WARN_MESSAGE in 1 second\n"; sleep 1
}

if ! [ $SERVER_STATUS -eq 0 ]; then
    if ! [ $FORCE ]; then
        print_warning
    fi

    echo "Stopping Minecraft server"

    screen -S $SCREEN_NAME -p 0 -X stuff "kick @a $KICK_MESSAGE\n"; sleep 2
    screen -S $SCREEN_NAME -p 0 -X stuff "stop\n"; sleep 1

    echo "Minecraft server stopped"
    exit 1
fi

exit 0