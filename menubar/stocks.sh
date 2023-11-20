#!/bin/bash

# Stock ticker symbol
ticker="${1:-DUOL}"

# URL of Google Finance page for the stock
url="https://www.google.com/finance/quote/$ticker:NASDAQ"

# Fetch the page and extract the stock price
price=$(curl -s "$url" | sed -n '/data-last-price="/{s/.*data-last-price="\([^"]*\).*/\1/p;q;}')

printf "$%.0f" "$price"
