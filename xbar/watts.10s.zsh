#!/bin/zsh

# AdapterDetails.Watts is only present while a charger is negotiated.
watts=$(
	/usr/sbin/ioreg -r -n AppleSmartBattery -w 0 2>/dev/null |
		/usr/bin/sed -n '/"AdapterDetails"/s/.*"Watts"=\([0-9][0-9]*\).*/\1/p' |
		/usr/bin/head -n 1
)

if [[ -n "$watts" ]]; then
	print -r -- "${watts}w"
else
	# Emit an empty line so xbar replaces the previous title. No output at all
	# makes xbar retain the last value it received.
	print
fi

exit 0
