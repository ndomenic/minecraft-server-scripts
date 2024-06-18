#!/bin/bash

POSITIONAL_ARGS=()
WEBHOOK=""

while [[ $# -gt 0 ]]; do
    case $1 in
        status)
            EXEC_STATUS=true
            shift
            ;;
        display)
            EXEC_DISPLAY=true
            shift
            ;;
        start)
            EXEC_START=true
            shift
            ;;
        stop)
            EXEC_STOP=true
            shift
            ;;
        restart)
            EXEC_RESTART=true
            shift
            ;;
        backup)
            EXEC_BACKUP=true
            shift
            ;;
        *.env-webhook)
            WEBHOOK=$1
            shift
            ;;
        *)
            POSITIONAL_ARGS+=("$1")
            shift
            ;;
    esac
done

if [ $EXEC_STATUS ]; then
    ./status.sh "${POSITIONAL_ARGS[@]}"
    exit 0
fi

if [ $EXEC_DISPLAY ]; then
    ./display.sh "${POSITIONAL_ARGS[@]}"
    exit 0
fi

if [ $EXEC_START ]; then
    ./start.sh "${POSITIONAL_ARGS[@]}"
    exit 0
fi

if [ $EXEC_STOP ]; then
    ./stop.sh "${POSITIONAL_ARGS[@]}"
    exit 0
fi

if [ $EXEC_RESTART ]; then
    ./restart.sh "${POSITIONAL_ARGS[@]}"
    exit 0
fi

if [ $EXEC_BACKUP ]; then
    if [ $WEBHOOK ]; then
        echo "Received Discord webbhook environment file: $WEBHOOK"
        echo ""
    else
        WEBHOOK="/home/ubuntu/minecraft-server-scripts/env/.env-webhook"

        echo "Using default Discord webhook environment file: $WEBHOOK"
        echo ""
    fi

    ./backup.sh "${POSITIONAL_ARGS[@]}" "$WEBHOOK"
    exit 0
fi