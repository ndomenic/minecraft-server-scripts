#!/bin/bash

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

WEBHOOK=https://discord.com/api/webhooks/1006764427426660502/wW91fSIKOckSPl9FLYItINwG7I9DQEQD_1JkyyaDkqBmOshKUCWo8k_HwMWVgHFmLdmt
./discord.sh \
  --webhook-url=$WEBHOOK \
  --username "Minecraft Backups" \
  --text "Backup failure"