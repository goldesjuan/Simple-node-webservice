###
 * Facade class for emails.
###
express = require('express')
util = require('util')
async = require('async')
crypto = require('crypto')
moment = require('moment')
_ = require('lodash')
constants = require('../configuration/configuration')
Mailgun = require('mailgun-js')

moment().format()

class Emails
    constructor : (database) ->
        @mailgun = new Mailgun(apiKey : constants.local.MAILGUN_API_KEY, domain : constants.local.MAILGUN_DOMAIN)
        @database = database

    # POST email to Mailgun API
    postEmail : (req, res) =>
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
                @database.getEmails(hash, (error, result) ->
                    if error?
                        return callback error
                    if result?
                        now = moment()
                        threshold = moment().subtract constants.local.NOTIFICATIONS_DUPLICATES_THRESHOLD_SEC, 's'
                        alreadySent = false
                        _.forEach(result, (email) ->
                            if moment(email.timestamp).isBetween threshold, now
                                alreadySent = true
                        )
                        if alreadySent
                            console.log "Email #{hash} has already been sent within the last five minutes"
                            return callback null, true, hash

                    callback null, false, hash
                )
            postToMailgun = (alreadySent, hash, callback) =>
                if alreadySent
                    callback null, true, hash
                else
                    @mailgun.messages().send(req.body, (error, result) ->
                        if error?
                            console.log "Error sending email to #{req.body.to} : #{util.inspect error}"
                            callback error
                        else
                            callback null, false, hash
                    )
            insertToDatabse = (alreadySent, hash, callback) =>
                if alreadySent
                    callback null
                else
                    timestamp = moment.utc().format()
                    email =
                        'hash': hash,
                        'timestamp': timestamp

                    @database.insertEmail(email, (error, result) ->
                        if error?
                            # Ideally there should be a retry pattern in the event of an error.
                            console.log "Error inserting email #{hash} to database : #{util.inspect error}"
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

module.exports = Emails
