#!/usr/bin/env python3
import os
import sys

from urllib.parse import urljoin

import requests

from bs4 import BeautifulSoup


def main(version=None):
    url = "http://www.iozone.org/"

    if version != "latest" and version is not None:
        url = urljoin(url, "src/current/")
        result = requests.get(url)
        result.raise_for_status()
        target_text = f"iozone3_{version}.tar"
    else:
        result = requests.get(url)
        result.raise_for_status()
        target_text = "Latest tarball"

    soup = BeautifulSoup(result.content, features="html.parser")
    target = soup.find("a", text=target_text)
    assert target, f"{target_text} not found in {url}"

    filename = target["href"].rsplit("/", 1)[-1]
    url = urljoin(url, target["href"])

    with requests.get(url, stream=True) as result:
        result.raise_for_status()
        with open(filename, "wb") as f:
            for chunk in result.iter_content(chunk_size=4096):
                if chunk:
                    f.write(chunk)

    return 0


if __name__ == "__main__":
    try:
        version = os.environ["IOZONE_VERSION"].strip().casefold()
    except KeyError:
        version = None

    sys.exit(main(version))
