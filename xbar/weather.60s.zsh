#!/bin/zsh

curl 'wttr.in/New+York?format=3&m' | sed 's/.*: //'