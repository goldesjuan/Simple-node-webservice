express = require('express')
router = express.Router()

# Mailgun credentials
api_key = '{API KEY}'
domain = '{DOMAIN}'

# Create Mailgun REST client
mailgun = require('mailgun-js')(
  apiKey: api_key
  domain: domain)

# Twilio credentials
twilio_accountSid = '{TWILIO ACCOUNT SID}'
twilio_authToken = '{TWILIO AUTHTOKEN}'

# Create Twilio REST client
twilio = require('twilio')(twilio_accountSid, twilio_authToken);

###
* POST to sendemail
###
router.post '/sendemail', (req, res) ->
    req.body.from = '{FROM}'
    mailgun.messages().send req.body, (error, body) ->
        res.send if body.message? then msg: body.message else error
        console.log body
        return
    return

###
* POST to sendsms
###
router.post '/sendsms', (req, res) ->
    req.body.from = '{FROM NUMBER}'
    twilio.messages.create req.body, (error, body) ->
        if body?
            res.send 'status' : 'OK'
        else
            res.send 'status' : 'ERROR'
            console.log error
        return
    return

module.exports = router
