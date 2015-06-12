express = require('express')
util = require('util')
async = require('async')

# Mailgun credentials
API_KEY = '{API_KEY}'
DOMAIN = '{DOMAIN}'

# Twilio credentials
TWILIO_ACCOUNTSID = '{TWILIO_ACCOUNTSID}'
TWILIO_AUTHTOKEN = '{TWILIO_AUTHTOKEN}'

class Notifications
    constructor : (database) ->
        @mailgun = require('mailgun-js')(apiKey : API_KEY, domain : DOMAIN)
        @twilio = require('twilio')(TWILIO_ACCOUNTSID, TWILIO_AUTHTOKEN)
        @database = database

    # POST email to Mailgun API
    postEmail : (req, res) =>
        async.waterfall [
            idempotenceValidation = (callback) =>
                @database.getEmail(req.body['v:custom_id'], (error, result) ->
                    if error?
                        return callback error
                    if result?
                        console.log("Email #{result['v:custom_id']} has already been sent")
                        callback null, true
                    else
                        callback null, false
                )
            postToMailgun = (alreadySent, callback) =>
                if alreadySent
                    callback null, true
                else
                    @mailgun.messages().send(req.body, (error, result) ->
                        if error?
                            console.log "Error sending email to #{req.body.to} : #{util.inspect error}"
                            callback error
                        else
                            callback null, false
                    )
            insertToDatabse = (alreadySent, callback) =>
                if alreadySent
                    callback null
                else
                    @database.insertEmail(req.body, (error, result) ->
                        if error?
                            # Ideally there should be a retry pattern in the event of an error.
                            console.log "Error inserting email #{req.body['v:custom_id']} to database : #{util.inspect error}"
                            callback error
                        else
                            callback null
                    )
        ], (error, result) ->
            if error?
                # AJAX call expects a JSON object
                res.status(500).send error : "An error occured while attempting to send the email : #{util.inspect error}"
            else
                res.status(200).send status : 200

    # POST sms to Twilio API
    postSms : (req, res) =>
        async.waterfall [
            idempotenceValidation = (callback) =>
                @database.getSms(req.body.custom_id, (error, result) ->
                    if error?
                        return callback error
                    if result?
                        console.log "sms #{req.body.custom_id} has already been sent"
                        callback null, true
                    else
                        callback null, false
                )

            postToTwilio = (alreadySent, callback) =>
                if alreadySent
                    callback null, true
                else
                    console.log req.body.sms
                    @twilio.messages.create(req.body.sms, (error, result) ->
                        if error?
                            console.log "Error sending twilio sms to #{req.body.sms.to} : #{util.inspect error}"
                            callback error
                        else
                            callback null, false
                    )

            insertToDatabse = (alreadySent, callback) =>
                if alreadySent
                    callback null
                else
                    @database.insertSms(req.body, (error, result) ->
                        if error?
                            # Ideally there should be a retry pattern in the event of an error.
                            console.log "Error inserting sms #{req.body.custom_id} to database : #{util.inspect error}"
                            callback error
                        else
                            callback null
                    )
        ], (error, result) ->
            if error?
                res.status(500).send error : "An error occured while attempting to send the sms : #{util.inspect error}"
            else
                res.status(200).send status : 200

module.exports = Notifications
