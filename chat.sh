#!/bin/bash

./url.sh $(./url_query.sh 'https://chatgpt.com?q={query}' $@) 'Profile 1'
