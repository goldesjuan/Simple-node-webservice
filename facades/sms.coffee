###
 * Facade class for sms
###
express = require('express')
util = require('util')
async = require('async')
crypto = require('crypto')
moment = require('moment')
_ = require('lodash')
constants = require('../configuration/configuration')
Twilio = require('twilio')

moment().format()

class Sms
    constructor : (database) ->
        @twilio = new Twilio constants.local.TWILIO_ACCOUNTSID, constants.local.TWILIO_AUTHTOKEN
        @database = database

     # POST sms to Twilio API
    postSms : (req, res) =>
        async.waterfall [
            hash = (callback) =>
                try
                    hasher = crypto.createHash('sha256')
                catch error
                    callback "Could not create hasher #{util.inspect error}"

                payload = req.body
                try
                    hasher.update JSON.stringify(payload)
                catch error
                    callback "Could not create hash #{util.inspect error}"

                hash = hasher.digest 'hex'
                callback null, hash

            idempotenceValidation = (hash, callback) =>
                @database.getSms(hash, (error, result) ->
                    if error?
                        return callback error
                    if result?
                        now = moment()
                        threshold = moment().subtract constants.local.NOTIFICATIONS_DUPLICATES_THRESHOLD_SEC, 's'
                        alreadySent = false
                        _.forEach(result, (sms) ->
                            if moment(sms.timestamp).isBetween threshold, now
                                alreadySent = true
                        )
                        if alreadySent
                            console.log "sms #{hash} has already been sent within the last five minutes"
                            return callback null, true, hash

                    callback null, false, hash
                )

            postToTwilio = (alreadySent, hash, callback) =>
                if alreadySent
                    callback null, true, hash
                else
                    @twilio.messages.create(req.body, (error, result) ->
                        if error?
                            console.log "Error sending twilio sms to #{req.body.to} : #{util.inspect error}"
                            callback error
                        else
                            callback null, false, hash
                    )

            insertToDatabse = (alreadySent, hash, callback) =>
                if alreadySent
                    callback null
                else
                    timestamp = moment.utc().format()
                    sms =
                        'hash' : hash
                        'timestamp' : timestamp

                    @database.insertSms(sms, (error, result) ->
                        if error?
                            # Ideally there should be a retry pattern in the event of an error.
                            console.log "Error inserting sms #{hash} to database : #{util.inspect error}"
                            callback error
                        else
                            callback null
                    )
        ], (error, result) ->
            if error?
                res.status(500).send error : "An error occured while attempting to send the sms : #{util.inspect error}"
            else
                res.status(200).send status : 200

module.exports = Sms
