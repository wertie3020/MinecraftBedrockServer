#!/bin/bash
# Author: wertie
# Minecraft Bedrock Server crach restart script
# This script will check if the server is running. If not and no restart or stop has been performed, it will restart the server.

# Set path variable
USERPATH="pathvariable"
PathLength=${#USERPATH}
if [[ "$PathLength" -gt 12 ]]; then
    PATH="$USERPATH"
else
    echo "Unable to set path variable.  You likely need to download an updated version of SetupMinecraft.sh from GitHub!"
fi

# Check to make sure we aren't running as root
if [[ $(id -u) = 0 ]]; then
   echo "This script is not meant to be run as root. Please run ./restart.sh as a non-root user, without sudo;  Exiting..."
   exit 1
fi

echo "crach restart is started";

# chek if server is running
while screen -list | grep -q "\.servername"; do
    
    # echo "server is running";

    sleep 5;

done
echo "server crached restarting server now";
# restart server
dirname/minecraftbe/servername/start.sh &