###
 * Database helper class
###
async = require 'async'
util = require 'util'
mongo = require 'mongoskin'

class DbHelper
    constructor : (databaseUrl) ->
        @db = mongo.db(databaseUrl, {native_parser:true})

    getCollection : (collectionName, callback) ->
        @db.collection(collectionName).find().toArray( (error, result) ->
            if error?
                console.log "Error finding items of collection #{collectionName} : #{util.inspect error}"
                return callback error

            callback null, result
        )

    insertUser : (user, finalCallback) ->
        collection = @db.collection 'userlist'
        async.waterfall [
            checkDuplicates = (callback) ->
                collection.findOne( { 'username' : user.username }, (error, object) ->
                    if error?
                        return callback error
                    if object?
                        return callback null, true

                    callback null, false
                )
            createUser = (alreadyExists, callback) ->
                if alreadyExists
                    return callback null

                collection.insert( user, (error, result) ->
                    if error?
                        callback error
                    else
                        callback null
                )
            ],
            (error, result) ->
                if error?
                    return finalCallback "Error inserting user to collection : #{util.inspect error}"

                finalCallback null

    deleteUser : (userId, callback) ->
        @db.collection('userlist').removeById( userId, (error, result) ->
            if error?
                console.log "Error attempting to delete user #{userId} : #{util.inspect error}"
                callback error
            else
                callback null
        )

    getEmails : (emailHash, callback) ->
        @db.collection('emails').find({'hash' : emailHash}).toArray( (error, result) ->
            if error?
                console.log "Error finding email #{emailHash} : #{util.inspect error}"
                callback error
            else
                callback null, result
        )

    insertEmail : (email, callback) ->
        @db.collection('emails').insert(email, (error, result) ->
            if error?
                console.log "Error inserting email : #{util.inspect error}"
                callback error
            else
                callback null
        )

    getSms : (smsHash, callback) ->
        @db.collection('sms').find({'hash' : smsHash}).toArray( (error, result) ->
            if error?
                console.log "Error finding sms #{smsHash} : #{util.inspect error}"
                callback error
            else
                callback null, result
        )

    insertSms : (sms, callback) ->
        @db.collection('sms').insert(sms, (error, result) ->
            if error?
                console.log "Error inserting sms : #{util.inspect error}"
                callback error
            else
                callback null
        )

module.exports = DbHelper
