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
if [ $(screen -ls | wc -l) -gt 2 ] && [ $(screen -S $SCREEN_NAME -Q select . ; echo $?) -eq 0 ]; then
    screen -R $SCREEN_NAME
else 
    echo "The specified server is not running"
    exit -1
fi