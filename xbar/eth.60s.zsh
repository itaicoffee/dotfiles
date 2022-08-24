#!/bin/zsh

price=$(curl 'https://min-api.cryptocompare.com/data/price?fsym=ETH&tsyms=USD' | sed 's/[^0-9]*//' | sed 's/\..*//')
price_in_thousands=$(($price / 1000.0))
printf "$%.2gk" $price_in_thousands