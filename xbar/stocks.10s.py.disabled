#!/usr/local/bin/python3
import json
import os


_TICKER = "DUOL"


def main():
	url = "https://query2.finance.yahoo.com/v10/finance/quoteSummary/" + _TICKER + "?modules=price"
	stream = os.popen("curl " + url)
	output = stream.read()
	data = json.loads(output)
	price = data["quoteSummary"]["result"][0]["price"]["regularMarketPrice"]["raw"]
	print("$%.0f" % price)


if __name__ == "__main__":
	main()