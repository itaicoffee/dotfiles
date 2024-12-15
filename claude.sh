#!/bin/sh

claude_url=$(url_query "https://claude.ai/new?q={query}" $@)
chrome_profile=$CHROME_PROFILE_PERSONAL || 'Profile 1'
url $claude_url $chrome_profile
close_iterm
