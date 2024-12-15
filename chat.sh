#!/bin/zsh

CHROME_PROFILE=$CHROME_PROFILE_PERSONAL || 'Profile 1'
url $(url_query 'https://chatgpt.com?q={query}' $@) $CHROME_PROFILE
