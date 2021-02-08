#!/bin/bash

HOP_HOST="[-i <priv_key_file_path> ]<user>@<hop_host>"
TARGET_HOST=<target_host>
TARGET_PORT=<target_port>

PORT_FORWARDING="1$TARGET_PORT:$TARGET_HOST:$TARGET_PORT"
PID=$(/bin/ps -ef |grep "$PORT_FORWARDING" |grep -v grep |awk '{print $2}')
if [[ -z $PID ]]
then
    /usr/bin/ssh -fN -g -L $PORT_FORWARDING $HOP_HOST
else
    echo -e "\nThe SSH tunnel is already running with process ID => ${PID}\n"
    exit 1
fi

PID=$(/bin/ps -ef |grep "$PORT_FORWARDING" |grep -v grep |awk '{print $2}')
echo -e "\nFanfare! SSH tunnel up & running in the local port 1$TARGET_PORT!"
echo -e "\nProcess ID of SSH tunnel => ${PID}\n"
