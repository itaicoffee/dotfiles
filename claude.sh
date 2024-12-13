#!/bin/bash

# Function to URL encode a string
urlencode() {
    # Convert string to URL-safe format
    local string="$1"
    local strlen=${#string}
    local encoded=""
    local pos c o
    
    for (( pos=0 ; pos<strlen ; pos++ )); do
        c=${string:$pos:1}
        case "$c" in
            [-_.~a-zA-Z0-9] ) # Keep alphanumeric and other safe characters intact
                o="${c}"
                ;;
            * )               # Encode everything else
                printf -v o '%%%02x' "'$c"
                ;;
        esac
        encoded+="${o}"
    done
    echo "${encoded}"
}

# Check if a query was provided
if [ $# -eq 0 ]; then
    echo "Usage: $0 'your query here'"
    exit 1
fi

# Combine all arguments into a single query string
query="$*"

# URL encode the query
encoded_query=$(urlencode "$query")

# Construct the URL
claude_url="https://claude.ai/new?q=${encoded_query}"

url $claude_url 'Profile 1'
close_iterm
