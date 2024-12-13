#!/bin/bash

# Function to URL encode a string
urlencode() {
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
            * ) # Encode everything else
                printf -v o '%%%02x' "'$c"
                ;;
        esac
        encoded+="${o}"
    done
    echo "${encoded}"
}

# Check if minimum required arguments are provided (URL template + at least one query term)
if [ $# -lt 2 ]; then
    echo "Usage: $0 <url_template> <query_terms...>"
    echo "Example: $0 'https://app.glean.com/search?q={query}' term1 term2 term3"
    exit 1
fi

# Get the URL template from the first argument
url_template="$1"
shift

# Combine remaining arguments into a single query string
query="$*"

# URL encode the query
encoded_query=$(urlencode "$query")

# Replace {query} in the template with the encoded query
final_url="${url_template/\{query\}/$encoded_query}"

# Output the final URL
echo "$final_url"

# Optionally open the URL (uncomment and modify as needed for your system)
# open "$final_url"  # For macOS
# xdg-open "$final_url"  # For Linux
# start "$final_url"  # For Windows
