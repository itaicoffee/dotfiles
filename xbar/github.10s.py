#!/usr/local/bin/python3
"""
Generate an application GitHub token here: github.com/settings/tokens
Optionally use with xbar: github.com/matryer/xbar
"""

import requests


USERNAME = "itaicoffee"
TOKEN = ""


def main():
	url = f"https://api.github.com/issues?q=is:open%20is:pr%20assignee:{USERNAME}"
	headers = {"Authorization": f"token {TOKEN}"}
	r = requests.get(url, headers=headers)
	result = r.json()
	count = len(result)
	print(f"pulls: {count}")


if __name__ == "__main__":
	main()