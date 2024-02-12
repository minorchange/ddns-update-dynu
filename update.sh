#!/bin/bash


# Get the directory where this script resides
SCRIPT_DIR=$(dirname "$0")

# Read environment variables from file
CONFIG_FILE="$SCRIPT_DIR/config.txt"

if [[ -f "$CONFIG_FILE" ]]; then
    source "$CONFIG_FILE"
else
    echo "Error: Environment file '$CONFIG_FILE' not found."
    exit 1
fi

# Set the maximum size for the logfile in bytes 
MAX_LOG_SIZE_BYTES=100000

# Construct the path to dynu.log relative t`o the script directory
LOG_FILE="$SCRIPT_DIR/update-ddns-dynu-call.log"

# Construct the URL
URL="https://api.dynu.com/nic/update?username=$USERNAME&password=$PASSWORD"

TIMESTAMP=$(date +"%Y-%m-%d %H:%M:%S")

# Execute the update command using curl
echo "Updating Dynu DNS..."
echo "URL: $URL"
echo "Response:"
{
    echo "[$TIMESTAMP] Update attempt:"
    curl -k -K - <<< "url=$URL"
    echo
} >> "$LOG_FILE"

echo "Update complete."

# Check if the logfile exceeds the maximum size
LOG_SIZE=$(stat -c%s "$LOG_FILE")
if [[ $LOG_SIZE -gt $MAX_LOG_SIZE_BYTES ]]; then
    echo "Logfile exceeds maximum size. Truncating to half the maxium size."
    
    # By truncating to half the size the truncation does eventuelly not have to happen each run.
    LINES_TO_REMOVE=$(($MAX_LOG_SIZE_BYTES / 2))
    
    # Remove the specified number of lines from the beginning of the file
    tail -c +$((LINES_TO_REMOVE + 1)) "$LOG_FILE" > "$LOG_FILE.tmp" && mv "$LOG_FILE.tmp" "$LOG_FILE"
    
    echo "Logfile truncated."  
fi