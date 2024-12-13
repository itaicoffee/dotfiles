#!/bin/bash

url $(url_query 'https://app.glean.com/search?q={query}' $@) 'Default'
close_iterm
