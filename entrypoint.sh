#!/bin/sh

shutdown_handler()
{
    kill -s SIGINT $PID
}

cd /data/
ln -sf "/app/DDNet-Server" .

su ddnet -s /bin/sh -c "$@" &
PID=$!

trap shutdown_handler SIGINT SIGTERM SIGKILL

wait $PID
