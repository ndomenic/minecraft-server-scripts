#!/bin/bash

POSITIONAL_ARGS=()
KICK_MESSAGE="The server has restarted"
WARN_MESSAGE="The server will restart"

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

if ! [ $SERVER_STATUS -eq 0 ]; then
    if [ $FORCE ]; then
        ./stop.sh $SERVER_ENV -wm "$WARN_MESSAGE" -km "$KICK_MESSAGE" -f
    else
        ./stop.sh $SERVER_ENV -wm "$WARN_MESSAGE" -km "$KICK_MESSAGE"
    fi

    echo ""
    sleep 3
    ./start.sh $SERVER_ENV
    exit 1
fi

exit 0