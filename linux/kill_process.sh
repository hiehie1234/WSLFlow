#!/bin/bash
echo "Run kill_process.sh"
cd /usr/share/asus-llm/env
pwd

current_dir=$(cd $(dirname $0); pwd)
echo "current_dir: $current_dir"

# 检查 pidfile 是否存在
if [ -f pidfile ]; then
    PID=$(cat pidfile)
    echo "kPID: $PID"
    kill $PID
    sleep 5
    kill $PID
    rm pidfile
    echo "Process $PID killed."
elif [ -f /tmp/pidfile ]; then
    PID=$(cat /tmp/pidfile)
    echo "kPID: $PID"
    kill $PID
    sleep 5
    kill $PID
    rm /tmp/pidfile
    echo "Process $PID killed."
else
    echo "pidfile not found."
fi
