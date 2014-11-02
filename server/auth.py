import os
import time

from flask import jsonify, redirect, session
from flask_oauth import OAuth

class SocialAuth:

    def __init__(self, data):
        self.data = data
        pass

    def _call_method(self, method, request=None):
        ''' So-called "dynamic routing" '''
        if method is None or method is '':
            return ''

        # Don't want to call private methods
        if method[:1] is '_':
            return ''
        if request is not None:
            return getattr(self, method)(request)
        else:
            return getattr(self, method)()

    def verify(self, request=None):
        return "[ Verify Form ]"

    def add_feedzai_client(self, feedzai):
        self.feedzai = feedzai



class FacebookPassiveAuth(SocialAuth):

    oauth = OAuth()
    facebook = oauth.remote_app('facebook',
        base_url='https://graph.facebook.com/',
        request_token_url=None,
        access_token_url='/oauth/access_token',
        authorize_url='https://www.facebook.com/dialog/oauth',
        consumer_key=os.getenv('FB_APP_ID', ''),
        consumer_secret=os.getenv('FB_SECRET', ''),
        request_token_params={'scope': 'email,user_birthday,user_photos'})


    def __init__(self, data):
        SocialAuth.__init__(self, data)

    def process(self, request=None):
        return self.facebook.authorize(callback='https://crispybacon.ngrok.com/auth/FacebookPassiveAuth/facebook_authorized')

    def logout(self, request=None):
        session.pop('oauth_token', None)
        return redirect(request.referrer or '/')

    @facebook.authorized_handler
    def facebook_authorized(self, resp):
        if resp is None:
            return 'Access denied: reason=%s error=%s' % (
                request.args['error_reason'],
                request.args['error_description']
            )
        session['oauth_token'] = (resp['access_token'], '')
        me = self.facebook.get('/me')
        return str(me)
        #return redirect('/')

    @facebook.tokengetter
    def get_facebook_oauth_token():
        return session.get('oauth_token')


class SMSAuth(SocialAuth):
    from twilio.rest import TwilioRestClient

    def __init__(self, data):
        SocialAuth.__init__(self, data)
        self.client = self.TwilioRestClient(self.data['account_sid'], self.data['auth_token'])
        self.sms_status = "unverified"
        self.notifications = []

    def verify(self, request=None):
        self.sms_status = "unverified"
        self.notifications[-1]['verification'] = 'sms'
        self.notifications[-1]['status'] = 'unverified'
        self.notifications[-1]['updated_at'] = int(time.time())

        message = self.client.messages.create(
                    body='Hi Lucas, confirming your purchase of $149.99. Please reply with a YES or NO.',
                    to=self.data['your_phone'],
                    from_=self.data['from_phone'])

        return open('templates/smsauth/verify.html').read()


    def process(self, request=None):
        # if request is None:
        #     request = {}

        # phone = request.form.get('phone', False)
        # if phone:
        #     message = self.client.messages.create(
        #         body='Did you really buy stuff? Reply yes or no.',
        #         to=phone,
        #         from_=self.data['from_phone'])

        # global sms_status
        # sms_status = "unverified"

        return open('templates/smsauth/process.html').read()

    def gateway(self, request=None):
        print request.form
        if request.form['Body'].lower() == 'yes':
            self.sms_status = "ok"
            self.notifications[-1]['status'] = 'ok'
            self.notifications[-1]['updated_at'] = int(time.time())
            print self.feedzai.label(self.notifications[-1]['id'], {'label': 'ok'})
            # Tell Nick that all is good - this is done through status2()
            # Tell Feedzai that all is good - done
            # Redirect user to complete page (sockets) - this is done through status()
            print "good guy"
        else:
            self.sms_status = "fraud"
            self.notifications[-1]['status'] = 'fraud'
            self.notifications[-1]['updated_at'] = int(time.time())
            print self.feedzai.label(self.notifications[-1]['id'], {'label': 'fraud'})
            # Tell Nick that all is bad - this is done through status2()
            # Tell Feedzai that all is bad - done
            # Redirect user to failed page (sockets) - this is done through status()
            print "bad guy"
        return ''

    def status(self, request=None):
        if self.sms_status == "ok":
            self.sms_status = "unverified"
            return jsonify(status="ok")

        return jsonify(status=self.sms_status)

    def _add_notification(self, notification):
        self.notifications.append(notification)

    def reset(self):
        self.notifications = []
        return redirect('/auth/SMSAuth/status2')

    def status2(self, request=None):
        return jsonify(data=self.notifications)