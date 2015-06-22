express = require 'express'
async = require 'async'
util = require 'util'

class Users
    constructor : (database) ->
        @database = database

    # GET userlist
    list : (req, res) =>
        @database.getCollection('userlist', (error, result) ->
            if error?
                console.log "#{util.inspect error}"
                res.status(500).send 'Error finding users'
            else
                res.json result
        )
    # POST user do database
    postUser : (req, res) =>
        @database.insertUser(req.body, (error, result)->
            if error?
                console.log "Error inserting object in collection userlist : #{util.inspect error}"

                # AJAX call excepts a JSON response.
                res.status(500).send error : 'Error inserting user'
            else
                res.status(200).send status : 200
        )
    # DELETE user
    delete : (req, res)=>
        userId = req.params.id
        @database.deleteUser(userId, (error, result)->
            if error?
                console.log "Error deleting user : #{util.inspect error}"
                res.status(500).send 'Error deleting user'
            else
                res.status(200).send 'Ok'
        )

module.exports = Users
