#!/bin/bash

# Example URL - replace with your desired URL
URL=$1

# For the profile shown in the screenshot
PROFILE_DIR=$2 || "Profile 1"  # or it might be "Profile 1" depending on your setup

# Detect OS and set paths
if [[ "$OSTYPE" == "darwin"* ]]; then
    # macOS
    CHROME="/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"
    USER_DATA_DIR="$HOME/Library/Application Support/Google/Chrome"
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    # Linux
    CHROME="google-chrome"
    USER_DATA_DIR="$HOME/.config/google-chrome"
else
    # Windows
    CHROME="/c/Program Files/Google/Chrome/Application/chrome.exe"
    USER_DATA_DIR="$APPDATA/Google/Chrome/User Data"
fi

# Launch Chrome with your profile
"$CHROME" "--user-data-dir=$USER_DATA_DIR" "--profile-directory=$PROFILE_DIR" "$URL"