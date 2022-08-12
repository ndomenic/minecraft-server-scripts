#!/bin/bash

./status.sh $1
SERVER_STATUS=$?
export $(cat $1 | xargs)
shift 1
echo ""

if ! [ $SERVER_STATUS -eq 0 ]; then
    screen -R $SCREEN_NAME
fi