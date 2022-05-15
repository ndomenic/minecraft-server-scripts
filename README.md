# minecraft-server-scripts

A collection of Bash scripts to manage a Minecraft server

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