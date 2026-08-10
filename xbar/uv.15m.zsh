#!/bin/zsh

uv_index=$(curl -fsS --max-time 10 'https://wttr.is/?format=%u' 2>/dev/null) || uv_index=""
uv_index=${uv_index//$'\n'/}

if [[ "$uv_index" == <-> ]]; then
	print "uv $uv_index"
else
	print 'uv --'
fi
