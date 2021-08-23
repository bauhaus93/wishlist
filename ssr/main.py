#!/bin/env python3

import os
import time
import urllib

from bs4 import BeautifulSoup
from selenium import webdriver
from selenium.webdriver.chrome.options import Options
from selenium.webdriver.support.ui import WebDriverWait

options = Options()
options.add_argument("--headless")

URL = "https://winglers-liste.info"
OUTPUT_DIR = "/var/ssr"

with webdriver.Chrome(options=options) as driver:
    wait = WebDriverWait(driver, 10)
    driver.get(URL)
    time.sleep(3)

    print(driver.page_source)
    with open(os.path.join(OUTPUT_DIR, "index.html"), "w") as f:
        f.write(driver.page_source)
