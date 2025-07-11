#!/bin/bash

SESSION_NAME="voyager"

if screen -ls | grep -q "$SESSION_NAME"; then
    echo "Attaching to existing screen session..."
    screen -r "$SESSION_NAME"
else
    echo "Creating new screen session..."
    screen -S "$SESSION_NAME" /dev/tty13gpio 4800
fi
