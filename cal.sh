#!/bin/bash

CHROME_PROFILE=$CHROME_PROFILE_WORK || 'Default'
url 'https://calendar.google.com' $CHROME_PROFILE
close_iterm
