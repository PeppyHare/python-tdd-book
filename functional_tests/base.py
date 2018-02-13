#!/bin/python3

from django.contrib.staticfiles.testing import StaticLiveServerTestCase
from selenium.common.exceptions import WebDriverException
from selenium import webdriver
from selenium.webdriver.common.keys import Keys
from selenium.webdriver.firefox.options import Options
from selenium.webdriver.common.desired_capabilities import DesiredCapabilities
import time
import os

MAX_WAIT = 3

class FunctionalTest(StaticLiveServerTestCase):

    def setUp(self):
        self.browser = self.get_webdriver()
        staging_server = os.environ.get('STAGING_SERVER')
        if staging_server:
            self.live_server_url = 'http://' + staging_server

    def tearDown(self):
        self.browser.refresh()
        self.browser.quit()

    def wait_for_row_in_list_table(self, row_text):
        start_time = time.time()
        while True:
            try:
                table = self.browser.find_element_by_id('id_list_table')
                rows = table.find_elements_by_tag_name('tr')
                self.assertIn(row_text, [row.text for row in rows])
                return
            except (AssertionError, WebDriverException) as e:
                if time.time() - start_time > MAX_WAIT:
                    raise e
                time.sleep(0.5)

    def wait_for(self, fn):
        start_time = time.time()
        while True:
            try:
                return fn()
            except (AssertionError, WebDriverException) as e:
                if time.time() - start_time > MAX_WAIT:
                    raise e
                time.sleep(0.5)

    def get_webdriver(self):
        # options = Options()
        # options.add_argument("--headless")
        # browser = webdriver.Firefox(firefox_options=options)
        browser = webdriver.Remote(command_executor="http://localhost:4444/wd/hub", desired_capabilities=DesiredCapabilities.CHROME)
        return browser

    def get_item_input_box(self):
        return self.browser.find_element_by_id('id_text')
