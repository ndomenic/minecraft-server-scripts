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

echo "Received environemnt file $1"
echo "screen name = ${SCREEN_NAME}"
echo "server path = ${SERVER_PATH}"
echo ""

./discord.sh \
  --webhook-url=$WEBHOOK \
  --username "Minecraft Backups" \
  --text "Backup failure"