import ast
import os
import json
import time
import random

from auth import SocialAuth, FacebookPassiveAuth, SMSAuth
from feedzai import Feedzai
from flask import Flask, jsonify, make_response, request, redirect


debug_mode = True
app_name = 'Bacon'

app = Flask(__name__, static_folder='../client/build', static_url_path='')
auths = {}
feedzai = None


@app.route('/')
def home():
    return make_response(open('../client/build/index.html').read())


@app.route('/cart')
def cart():
    ''' Sample cart page, this is the entry point of our demo. '''

    return make_response(open('templates/checkout.html').read())

@app.route('/success')
def success():
    return make_response(open('templates/checkout-ok.html').read())

@app.route('/fail')
def fail():
    return make_response(open('templates/checkout-fraud.html').read())

@app.route('/checkout')
def checkout():
    ''' Checkout page with Feedzai first-pass fraud alerting. '''

    # Test data
    data = {
        'id': int(time.time()),
        'user_id': '1234s56',
        'amount': random.randint(1,100) * 100,
        'ip': '212.10.114.18',
        'user_email': 'howey.1975@gmail.com'
    }

    risk_assessment = feedzai.payments(data)

    risk_id = risk_assessment.get('explanation', {}).get('id')
    risk_score = int(risk_assessment.get('explanation', {}).get('score')) / 1000.0

    if risk_score <= 0.5:
        risk_state = "ok"
        response = make_response(open('templates/checkout-ok.html').read())
    elif risk_score >= 0.75:
        risk_state = "fraud"
        response = make_response(open('templates/checkout-fraud.html').read())
    else:
        risk_state = "sketchy"
        response = redirect('/auth/SMSAuth/process/' + str(risk_score))

    notify = {
        'id': risk_id,
        'score': risk_score,
        'state': {
            'id': risk_state,
            'label': risk_state
        },
        'created_at': int(risk_id), # ID = creation timestamp
        'updated_at': int(risk_id),
        'data': data
    }

    auths['SMSAuth']._add_notification(notify)

    return response or make_response(dict_to_string(notify))


@app.route('/auth', defaults={'path': ''}, methods=['GET', 'POST'])
@app.route('/auth/<path:path>', methods=['GET', 'POST'])
def auth(path):
    ''' Proxy to authentication methods '''

    things = path.split('/')
    
    auth_class = globals().get(things[0], Flask)
    if issubclass(auth_class, SocialAuth):
        if auth_class.__name__ in auths:
            return auths[auth_class.__name__]._call_method(things[1], request)
    else:
        return ''


def dict_to_string(data):
    ''' Cleans up the unicode in dictionary->string conversion. '''

    try:
        return str(ast.literal_eval(json.dumps(data)))
    except:
        return str(json.dumps(data))


if __name__ == '__main__':
    random.seed()

    # Setup Feedzai API
    feedzai = Feedzai(api_key=str(os.getenv('FEEDZAI_KEY', '0000000000000000000000000000000000000000000000000000000000000000')))

    # Setup Authentication Services
    twilio = {
        'account_sid': str(os.getenv('TWILIO_ACC_SID', 'AC00000000000000000000000000000000')),
        'auth_token': str(os.getenv('TWILIO_AUTH_TOKEN', '00000000000000000000000000000000')),
        'from_phone': str(os.getenv('TWILIO_PHONE', '+18888888888')),
        'your_phone': str(os.getenv('YOUR_PHONE', '+18888888888'))
    }
    auths['SMSAuth'] = SMSAuth(twilio)
    auths['SMSAuth'].add_feedzai_client(feedzai)

    auths['FacebookPassiveAuth'] = FacebookPassiveAuth({})
    auths['FacebookPassiveAuth'].add_feedzai_client(feedzai)

    # Start the server
    host = str(os.getenv('HOST', '0.0.0.0'))
    port = int(os.getenv('PORT', 8080))
    app.run(host=host, port=port, debug=debug_mode)
