from flask import jsonify

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


class FacebookPassiveAuth(SocialAuth):
	def __init__(self, data):
		SocialAuth.__init__(self, data)

	def verify(self, request=None):
		return "Facebook auth yo!"


sms_status = "unverified"

class SMSAuth(SocialAuth):
	from twilio.rest import TwilioRestClient

	def __init__(self, data):
		SocialAuth.__init__(self, data)
		self.client = self.TwilioRestClient(self.data['account_sid'], self.data['auth_token'])

	def verify(self, request=None):
		return open('templates/smsauth/verify.html').read()

	def process(self, request=None):
		if request is None:
			request = {}

		phone = request.form.get('phone', False)
		if phone:
			message = self.client.messages.create(
    	        body='Did you really buy stuff? Reply yes or no.',
        	    to=phone,
            	from_=self.data['from_phone'])

		global status
		status = "unverified"

		return open('templates/smsauth/process.html').read()

	def gateway(self, request=None):
		print request.form
		if request.form['Body'].lower() == 'yes':
			global status
			status = "ok"
			# Tell Nick that all is good
			# Tell Feedzai that all is good
			# Redirect user to complete page (sockets)
			print "good guy"
		else:
			global status
			status = "fraud"
			# Tell Nick that all is bad
			# Tell Feedzai that all is bad
			# Redirect user to failed page (sockets)
			print "bad guy"
		return ''

	def status(self, request=None):
		global sms_status
		return jsonify(status=sms_status)