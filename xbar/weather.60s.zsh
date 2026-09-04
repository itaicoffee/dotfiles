#!/bin/zsh

curl -fsS 'wttr.in/New+York?format=%t&m' | sed 's/+//; s/°//; s/C/c/'
