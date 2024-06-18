# minecraft-server-scripts

A collection of Bash scripts to manage a Minecraft server. Every script requires a server environment file, as well as a webhook environment file for the backup script. The environment file structures are as follows:

### Server environment file
```
SERVER_NAME=my_server
SERVER_PATH=/home/ubuntu/minecraft
WORLD_FOLDER=world
BACKUP_PATH=/media/minecraft_backups/server
SCREEN_NAME=server
MEM_MAX=2048
MEM_MIN=512
SERVER_JAR=server.jar
```

### Webhook environment file
```
WEBHOOK=https://discord.com/api/webhooks/yourwebhookhere
```

## Start a server

`./mcs.sh start .env-server`

## Stop a server

Stop with default 15 second warning:

`./mcs.sh stop .env-server`

Force stop with no warning:

`./mcs.sh stop .env-server -f` or `./mcs.sh stop .env-server --force`

## Restart a server

Restart with default 15 second warning:

`./mcs.sh restart .env-server`

Force restart with no warning:

`./mcs.sh restart .env-server -f` or `./mcs.sh restart .env-server --force`


## View a running server

`./mcs.sh display .env-server`

To detach from the server's screen session `Ctrl + a + d`

## Get server status

`./mcs.sh status.env-server`

## Backup a server

Backup with default 60 second warning:

`./mcs.sh backup .env-server .env-webhook`

Force backup with no warning:

`./mcs.sh backup .env-server .env-webhook -f ` or `./mcs.sh backup .env-server .env-webhook --force`

If no webhook is supplied with the backup command `./mcs.sh backup .env-server` then a default webhook will be used, located at:
`/home/ubuntu/minecraft-server-scripts/env/.env-webhook`

**Requires a Discord webhook specified in a separate webhook environment file**

The included `discord.sh` script is pulled from the [discord.sh](https://github.com/ChaoticWeg/discord.sh) project on GitHub