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
        @db.collection(collectionName).find().toArray (error, result) ->
            if error?
                console.log "Error finding items of collection #{collectionName} : #{util.inspect error}"
                return callback error

            callback null, result
        return

    insertUser : (user, finalCallback) ->
        collection = @db.collection 'userlist'
        async.waterfall [
            checkDuplicates = (callback) ->
                collection.findOne { 'username' : user.username }, (error, object) ->
                    if error?
                        return callback error
                    if object?
                        return callback null, true

                    callback null, false
                return
            createUser = (alreadyExists, callback) ->
                if alreadyExists
                    return callback null, 'Ok'

                collection.insert user, (error, result) ->
                    if error?
                        return callback error
                    else
                        callback null, 'Ok'
                return
            ],
            (error, result) ->
                if error?
                    return finalCallback "Error inserting user to collection : #{util.inspect error}"

                finalCallback null, result
        return

    deleteUser : (userId, callback) ->
        @db.collection('userlist').removeById userId, (error, result) ->
            if error?
                callback error
            else
                callback null, 'Ok'
        return

module.exports = DbHelper
