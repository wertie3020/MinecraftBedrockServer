#!/bin/bash
# Author: James Chambers - https://jamesachambers.com/
# Minecraft Bedrock server startup script using screen

# Check if server is already started
if screen -list | grep -q "\.servername"; then
    echo "Server is already started!  Press screen -r servername to open it"
    exit 1
fi

# Create logs folder if it doesn't exist
if [ ! -d "logs/" ]
then
	mkdir logs
fi

# Check if network interfaces are up
NetworkChecks=0
DefaultRoute=$(route -n | awk '$4 == "UG" {print $2}')
while [ -z "$DefaultRoute" ]; do
    echo "Network interface not up, will try again in 1 second";
    sleep 1;
    DefaultRoute=$(route -n | awk '$4 == "UG" {print $2}')
    NetworkChecks=$((NetworkChecks+1))
    if [ $NetworkChecks -gt 20 ]; then
        echo "Waiting for network interface to come up timed out - starting server without network connection ..."
        break
    fi
done

# Change directory to server directory
cd dirname/minecraftbe/servername

# Take ownership of server files
Permissions=$(sudo chown -R userxname dirname/minecraftbe/servername >/dev/null)

# Create backup
if [ -d "worlds" ]; then
    echo "Backing up server (to minecraftbe/servername/backups folder)"
    tar -pzvcf backups/$(date +%Y.%m.%d.%H.%M.%S).tar.gz worlds
fi

# Rotate backups -- keep most recent 10
Rotate=$(ls -1tr dirname/minecraftbe/servername/backups | head -n -10 | xargs -d '\n' rm -f --)

# Retrieve latest version of Minecraft Bedrock dedicated server
echo "Checking for the latest version of Minecraft Bedrock server ..."

# Test internet connectivity first
wget --quiet http://www.minecraft.net/ -O /dev/null
if [ "$?" != 0 ]; then
    echo "Unable to connect to update website (internet connection may be down).  Skipping update ..."
else
    # Download server index.html to check latest version
    wget -O downloads/version.html https://minecraft.net/en-us/download/server/bedrock/
    DownloadURL=$(grep -o 'https://minecraft.azureedge.net/bin-linux/[^"]*' downloads/version.html)
    DownloadFile=$(echo "$DownloadURL" | sed 's#.*/##')

    # Download latest version of Minecraft Bedrock dedicated server if a new one is available
    if [ -f "downloads/$DownloadFile" ]
    then
        echo "Minecraft Bedrock server is up to date..."
    else
        echo "New version $DownloadFile is available.  Updating Minecraft Bedrock server ..."
        wget -O "downloads/$DownloadFile" "$DownloadURL"
        unzip -o "downloads/$DownloadFile" -x "*server.properties*" "*permissions.json*" "*whitelist.json*" "*valid_known_packs.json*"
    fi
fi

echo "Starting Minecraft server.  To view window type screen -r servername"
echo "To minimize the window and let the server run in the background, press Ctrl+A then Ctrl+D"

screen -L -Logfile logs/servername.$(date +%Y.%m.%d.%H.%M.%S).log -dmS servername /bin/bash -c "LD_LIBRARY_PATH=dirname/minecraftbe/servername dirname/minecraftbe/servername/bedrock_server"
