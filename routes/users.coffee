express = require 'express'
async = require 'async'
util = require 'util'

#Database
mongo = require 'mongoskin'

router = express.Router()

###
 * Database helper class
###
class DbHelper
    constructor : (mongo) ->
        @db = mongo.db("mongodb://localhost:27017/nodetest2", {native_parser:true})

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

    deleteUser : (collectionName, userId, callback) ->
        @db.collection(collectionName).removeById userId, (error, result) ->
            if error?
                callback error
            else
                callback null, 'Ok'
        return


dbHelper = new DbHelper mongo

###
 * GET userlist.
###
router.get '/userlist', (req, res) ->
    dbHelper.getCollection('userlist', (error, result) ->
        if error?
            console.log '#{util.inspect error}'
            res.status(500).send 'Error finding users'
        else
            res.json result
        return
    )
    return

###
 * POST to adduser.
###
router.post '/adduser', (req, res) ->
    dbHelper.insertUser(req.body, (error, result) ->
        if error?
            console.log 'Error inserting object in collection userlist : #{util.inspect error}'
            res.status(500).send 'Error inserting user'
        else
            res.status(200).send 'Ok'
        return
    )
    return


###
 * DELETE to deleteuser.
###
router.delete '/deleteuser/:id', (req, res) ->
    userToDelete = req.params.id
    dbHelper.deleteUser('userlist', userToDelete, (error, result) ->
        if error?
            console.log 'Error deleting user : #{util.inspect error}'
            res.status(500).send 'Error deleting user'
        else
            res.status(200).send 'Ok'
        return
    )
    return

module.exports = router
