# minecraft-server-scripts

A collection of Bash scripts to manage a Minecraft server. Every script requires a server environment file, as well as a webhook environment file for the backup script. The environment file structures are as follows:

### Server environment file
```
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

`./start.sh .env-server`

## Stop a server

Stop with default 15 second warning:

`./stop.sh .env-server`

Force stop with no warning:

`./stop.sh .env-server -f` or `./stop.sh .env-server --force`

## Restart a server

Restart with default 15 second warning:

`./restart.sh .env-server`

Force restart with no warning:

`./restart.sh .env-server -f` or `./restart.sh .env-server --force`


## View a running server

`./display.sh .env-server`

To detach from the server's screen session `Ctrl + a + d`

## Get server status

`./status.sh .env-server`

## Backup a server

Backup with default 60 second warning:

`./backup.sh .env-server .env-webhook`

Force backup with no warning:

`./backup.sh .env-server .env-webhook -f ` or `./backup.sh .env-server .env-webhook --force`

**Requires a Discord webhook specified in a separate webhook environment file**

The included `discord.sh` script is pulled from the [discord.sh](https://github.com/ChaoticWeg/discord.sh) project on GitHub