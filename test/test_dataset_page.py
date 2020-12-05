import httplib
import socket
import time

from seleniumbase import BaseCase

def wait_for_ckan(host='app', port=80, url='/api/action/package_search?rows=0', timeout=60):
    start = time.time()

    while time.time() < start + timeout:
        print 'trying %s' % url
        response = None
        try:
            c = httplib.HTTPConnection(host, port, timeout=5)
            c.request('GET', url)
            response = c.getresponse()
        except httplib.NotConnected as e:
            print 'error %s' % e
            pass
        except socket.error as e:
            print 'error %s' % e
            pass

        if response and response.status == 200:
            print 'success!'
            break

        time.sleep(1)


class MyTestClass(BaseCase):
    @classmethod
    def setUpClass(cls):
        #wait_for_ckan(host='localhost', port=8080)
        wait_for_ckan()

    def test_ckan(self):
        #self.open('http://localhost:8080/dataset')
        self.open('http://app/dataset')
        self.assert_text('DATA CATALOG')

    def test_xkcd(self):
        self.open("https://store.xkcd.com/search")
        self.type('input[name="q"]', "xkcd book")
        self.click('input[value="Search"]')
        self.assert_text("xkcd: volume 0", "h3")
        self.open("https://xkcd.com/353/")
        self.assert_title("xkcd: Python")
        self.assert_element('img[alt="Python"]')
        self.click('a[rel="license"]')
        self.assert_text("free to copy and reuse")
        self.go_back()
        self.click_link_text("About")
        self.assert_exact_text("xkcd.com", "h2")
        self.click_link_text("geohashing")
        self.assert_element("#comic img")
