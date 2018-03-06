from django.conf import settings
from .base import FunctionalTest
from urllib.parse import urlparse
from selenium.common.exceptions import WebDriverException
from .server_tools import create_session_on_server
from .management.commands.create_session import create_pre_authenticated_session
import logging

logger = logging.getLogger(__name__)


class MyListsTest(FunctionalTest):

    def create_pre_authenticated_session(self, email):
        if self.staging_server:
            session_key = create_session_on_server(self.staging_server, email)
            domain = urlparse(self.live_server_url).netloc.split(':')[0]
        else:
            session_key = create_pre_authenticated_session(email)
            domain = '.localhost'
        # to set a cookie we need to first visit the domain
        self.browser.get(self.live_server_url)
        # Because of phantomjs restrictions, need to set domain along with cookie
        try:
            self.browser.add_cookie(
                dict(
                    name=settings.SESSION_COOKIE_NAME,
                    value=session_key,
                    path='/',
                    domain=domain,
                ))
        except (WebDriverException) as e:
            logger.debug("Failure to add session id cookie.")

    def test_logged_in_users_lists_are_saved_as_my_lists(self):
        # Edith is a logged-in user
        self.create_pre_authenticated_session('gdklfij135@example.com')

        # She goes to the home page and starts a list
        self.browser.get(self.live_server_url)
        self.add_list_item('Reticulate splines')
        self.add_list_item('Immanentize eschaton')
        first_list_url = self.browser.current_url

        # She notices a "My Lists" section for the first time
        self.browser.find_element_by_link_text('My lists').click()

        # She sees that her list is in there, named according to its first list item
        self.wait_for(
            lambda: self.browser.find_element_by_partial_link_text('Reticulate splines')
        )
        self.browser.find_element_by_partial_link_text(
            'Reticulate splines').click()
        self.wait_for(
            lambda: self.assertEqual(self.browser.current_url, first_list_url))

        # She decides to start another list, just to see
        self.browser.get(self.live_server_url)
        self.add_list_item('Click cows')
        second_list_url = self.browser.current_url

        # Under "my lists" her new list appears
        self.browser.find_element_by_link_text('My lists').click()
        self.wait_for(
            lambda: self.browser.find_element_by_partial_link_text('Click cows')
        )
        self.browser.find_element_by_partial_link_text('Click cows').click()
        self.wait_for(
            lambda: self.assertEqual(self.browser.current_url, second_list_url))

        # She logs out. The my lists option disappears
        self.browser.find_element_by_link_text('Log out').click()
        self.wait_for(lambda: self.assertEqual(
            self.browser.find_elements_by_link_text('My lists'),
            []
        ))
