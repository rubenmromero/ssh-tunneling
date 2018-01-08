#!/bin/bash

JUMP_HOST="<user>@<hop_host>"
PORT_FORWARDING="<local_port>:<target_host>:<target_port>"

PID=$(/bin/ps -ef |grep "$PORT_FORWARDING" |grep -v grep |awk '{print $2}')
if [[ -z $PID ]]
then
    /usr/bin/ssh -fN -g -L $PORT_FORWARDING $JUMP_HOST
else
    echo -e "\nThe SSH tunnel is already running with process ID => ${PID}\n" 
    exit 1
fi

PID=$(/bin/ps -ef |grep "$PORT_FORWARDING" |grep -v grep |awk '{print $2}')
echo -e "\nFanfare! SSH tunnel up & running!"
echo -e "\nProcess ID of SSH tunnel => ${PID}\n"
