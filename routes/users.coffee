express = require 'express'
router = express.Router()


###
 * GET userlist.
 ###
router.get '/userlist', (req, res) ->
    db = req.db
    db.collection('userlist').find().toArray (err, items) ->
        res.json items

###
 * POST to adduser.
 ###
router.post '/adduser', (req, res) ->
    db = req.db
    db.collection('userlist').insert req.body, (err, result) ->
        res.send if err is null then msg : '' else msg : err


###
 * DELETE to deleteuser.
 ###
router.delete '/deleteuser/:id', (req, res) ->
    db = req.db
    userToDelete = req.params.id
    db.collection('userlist').removeById userToDelete, (err, result) ->
        res.send if result is 1 then msg : '' else msg: 'error' + err


module.exports = router
