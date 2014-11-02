# import urllib2
import json
import requests

class Feedzai:

    api_url = 'https://sandbox.feedzai.com/v1/'
    api_key = ''

    def __init__(self, api_key):
        self.api_key = api_key


    def _request(self, endpoint, data):
        url = self.api_url + endpoint
        auth = (self.api_key, '')
        headers = {'Content-type': 'application/json'}

        return requests.post(url, json=data, auth=auth, headers=headers)

    def _request_put(self, endpoint, data):
        url = self.api_url + endpoint
        auth = (self.api_key, '')
        headers = {'Content-type': 'application/json'}

        return requests.put(url, json=data, auth=auth, headers=headers)


    def payments(self, data=None):
        ''' Registers a payment with Feedzai '''

        if data is None:
            data = {'id': '1477020110', 'user_id': 'af01-bc14-1245', 'amount': 1250, 'ip': '212.10.114.18', 'user_email': 'howey.1975@gmail.com'}

        try:
            output = self._request('payments', data)
            return json.loads(output.text)
        except Exception as e:
            return {'error': e}

    def label(self, payment_id, data):
        ''' Labels a payment as "ok" or "fraud" within Feedzai'''

        try:
            output = self._request_put('payments/' + str(payment_id).encode('ascii') + '/label', data)
            return json.loads(output.text)
        except Exception as e:
            return {'error': e}
